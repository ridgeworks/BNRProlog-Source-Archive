/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/interpreter.c,v 1.5 1997/12/22 17:01:25 harrisj Exp $
*
*  $Log: interpreter.c,v $
 * Revision 1.5  1997/12/22  17:01:25  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.4  1997/08/14  16:25:48  harrisj
 * Fixed tvar unifications in unify() for SR_60018828
 * Previous version in changset of samename didn't work quite right
 *
 * Revision 1.3  1997/05/12  12:49:06  harrisj
 * unify() can now unify tailvar's not in lists or structures.
 *
 * Revision 1.2  1997/04/01  13:45:50  harrisj
 * BNRP_RESUME() body escape bytes 0xE6 and 0x02 modified
 * to read the call arity in as a signed char when doing
 * garbage collection.
 *
 * BNRP_gc_proceed() modified to use the absolute value of args[0].
 *
 * Revision 1.1  1995/09/22  11:24:46  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "core.h"
#include "hash.h"
#include "interpreter.h"
#include "pushpop.h"
#include "prim.h"
#include "context.h"
#include "utility.h"
#include "stats.h"
#include "memory.h"
#include "hardware.h"

/* #define debug 		/* set if gc should output trace of what it does */
/* #define debugcount 3	/* number of gc's to output data for */
/* #define messages		/* set if gc should output messages for unexpected cases */
/* #define messages1	/* */
#define check

#ifdef ring0
void (*BNRPerrorhandler)() = NULL;
long BNRP_numGC = 0;
#endif

#ifdef ring0
BNRP_term makeint(long *address, long value)
{
	short i;
	long res;
	struct longheader{
		long header;
		long value;
		} *x;
	
	i = value;
	if (value EQ i)
		return(makeintterm(value & 0x0000FFFF));
	/* number bigger than 16 bits */
	headerLWA(*address);
	res = maketerm(STRUCTTAG, *address);
	x = (struct longheader *)*address;
	*address += sizeof(struct longheader);
	x->header = INTID;
	x->value = value;
	return(res);
	}
#endif

#ifdef ring0
BNRP_term makefloat(long *address, fp *value)
{
	long res;
	/* cannot use struct { long, fp } since Sparc C compiler */
	/* will align fp on an 8 byte boundary, wasting a long */
	/* and causing problems in the arithmetic stuff */
	
	headerLWA(*address);
	res = maketerm(STRUCTTAG, *address);
	push(long, *address, FLOATID);
	fpLWA(*address);
	*(lf *)*address = *(lf *)value;
	*address += sizeof(fp);
	if (sizeof(fp) EQ 10) { 
		push(short, *address, 0);
		}
	return(res);
	}
#endif

#ifdef ring1
void BNRP_freespace(TCB *tcb, long *s1, long *e1, long *s2, long *e2)
{
	long ce, endce;
	
	ce = tcb->ce + (*(unsigned char *)tcb->cp + 1) * sizeof(long int);
	if (tcb->lcp NE tcb->cpbase) {			/* some choicepoints */
		endce = ((choicepoint *)tcb->lcp)->critical;
		if (ce LT endce) ce = endce;
		}
	*s1 = ce;
	*e1 = tcb->lcp - sizeof(long);
	*s2 = tcb->hp;
	*e2 = tcb->te - sizeof(long);
	}
#endif

#ifdef ring0
long computeKey(long arg)
{
	long val;
	
	val = arg;
	while (tagof(val) EQ TVTAG) {			/* while we have a tail variable */
		long _a = *(long *)addrof(val);		/* get what tailvar points at */
		if (_a EQ val) return(0);			/* really a tail variable so key = 0 */
		val = _a;
		}
	while (isVAR(val)) {					/* while we have a variable */
		register long _l = derefVAR(val);
		if (val EQ _l) return(0);			/* really a variable so key = 0 */
		val = _l;
		}
	if (tagof(val) EQ SYMBOLTAG) {
		symbolEntry *s;
		checksym(val, s);
		return((*(long *)(&s->inuse)) & 0x0FFFFFF);
		}
	else if (tagof(val) EQ LISTTAG) {
		val = addrof(val);						/* remove tag */
		if ((val = *(long *)val) EQ 0)			/* empty list ?? */
			return(0x00000888);
		while (tagof(val) EQ TVTAG) {		/* while a tailvar, chase it */
			long _l = *(long *)addrof(val);
			if (_l EQ val)					/* unbound tailvar */
				return(0);
			val = _l;
			}
		val = (val) ? 0x00000AAA : 0x00000888;
		}
	else if (tagof(val) EQ STRUCTTAG) {
		li t;
		long *addr;
		
		addr = (long *)addrof(val);		/* remove tag */
		t.l = *addr++;							/* get struct header */
		if (t.i.a EQ NUMBERIDshort) {
			if (t.i.b EQ FLOATIDshort) fpLWA(addr);
			/* hash is first 32 bits of number plus type field in bottom to avoid 0 */
			val = *addr + t.i.b;
			}
		else {
			val = *addr;						/* get first arg */
			while (isVAR(val) || isTV(val)) {	/* while we have a variable or TV */
				register long _l = *(long *)addrof(val);
				if (val EQ _l) return(0);		/* unbound so key = 0 */
				val = _l;
				}
			if (tagof(val) EQ SYMBOLTAG) {
				symbolEntry *s;
				checksym(val, s);
				return((*(long *)(&s->inuse)) & 0x0FFFFFF);
				}
			else if (tagof(val) EQ STRUCTTAG) {		/* in case its a number as first argument*/
				addr = (long *)addrof(val);			/* remove tag */
				t.l = *addr++;
				if (t.i.a NE NUMBERIDshort) {
					if (t.i.b EQ FLOATIDshort) fpLWA(addr);
					val = (*addr & 0xFFFFFFF0) | t.i.b;	/* put type field in bottom */
					}
				}
			}
		}
	return(val);
	}
#endif

#ifdef ring0
int initializeTCB(TCB *tcb, 
				  long heapAndTrail, 
				  long envAndCP)
{
	int i;
	choicepoint *newcp;
									
	if ((i = BNRP_allocMemory(tcb, heapAndTrail, envAndCP)) NE 0) return(i);
	tcb->nargs = tcb->ppsw = tcb->stp = tcb->glbctx = tcb->svsp = tcb->ppc = tcb->procname = 0;
	tcb->te = tcb->trailbase;
	tcb->lcp = tcb->cutb = tcb->cpbase;
	
	tcb->hp = tcb->heapbase;
	tcb->emptyList = maketerm(LISTTAG, tcb->heapbase);
	push(long, tcb->hp, 0);				/* make actual empty list */

	tcb->ce = tcb->envbase;
	/* make dummy self-referencing environment */
	push(BYTE, tcb->ce, 0x07);					/* break code */
	tcb->cp = tcb->ce;							/* cp points at 0 */
	push(BYTE, tcb->ce, 0x00);
	push(BYTE, tcb->ce, 0x07);
	push(BYTE, tcb->ce, 0x00);
	push(long, tcb->ce, 0);						/* no name in environment */
	push(long, tcb->ce, tcb->cutb);
	push(long, tcb->ce, tcb->ce+sizeof(long));
	*(long *)tcb->ce = tcb->envbase;
				/* wjo sept 94: make dummy choicepoint: */
	newcp = (choicepoint *)((long)tcb->cpbase - sizeof(choicepoint));
	newcp->numRegs = 0;			/* arity */
	newcp->procname = 0;
	newcp->bcp = tcb->cp;
	newcp->bce = tcb->ce;
	newcp->te = tcb->te;
	newcp->lcp = 0;
	newcp->hp = tcb->hp;
	newcp->critical = 0;
	newcp->key = 0;
	newcp->clp = 0;
	tcb->lcp = tcb->cutb = (long)newcp;
		/* wjo sept 94: end make dummy choicepoint */
						
	for (i = 1; i LT MAXREGS; ++i)
		tcb->args[i] = 0xAAAAAAAA;
	tcb->constraintHead = tcb->constraintTail = 0;
	return(0);
	}
#endif

#ifdef ring0
void initialGoal(TCB *tcb, BNRP_term a, int arity)
{
	int i;
	
	tcb->ppsw = bodyMode;
#ifdef HSC
        tcb->ppc = tcb->freePtr-1;
#else
        tcb->ppc = tcb->freePtr;
#endif
	push(BYTE, tcb->freePtr, 0x07);
	push(BYTE, tcb->freePtr, 0x0A);
	push(BYTE, tcb->freePtr, arity);
	constantLWA(tcb->freePtr);
	push(long, tcb->freePtr, a);
	push(BYTE, tcb->freePtr, 0x00);
	push(BYTE, tcb->freePtr, 0x07);
	push(BYTE, tcb->freePtr, 0x00);

	/* make unbound variable on heap for each parameter */
	for (i = 1; i LE arity; ++i) {				
		push(long, tcb->hp, tcb->args[i] = makevarterm(tcb->hp));
		}
	}
#endif

#ifdef ring1
static long findUnused(long start, long limit)
{
	long *p;
	
	p = (long *)start;
	if (limit GT start) {
		while ((long)p LE limit) {
			++p;
			while (((long)p LE limit) && (*p NE 0xAAAAAAAA)) ++p;
			if ((p[1] EQ 0xAAAAAAAA) && (p[2] EQ 0xAAAAAAAA) && (p[3] EQ 0xAAAAAAAA))
				return((long)p - start);
			}
		return(limit - start);
		}
	else {
		while ((long)p GE limit) {
			--p;
			while (((long)p GE limit) && (*p NE 0xAAAAAAAA)) --p;
			if ((p[-1] EQ 0xAAAAAAAA) && (p[-2] EQ 0xAAAAAAAA) && (p[-3] EQ 0xAAAAAAAA))
				return(start - (long)p - 4);
			}
		return(start - limit);
		}
	}
#endif

#ifdef ring1
void BNRP_stackSpaceUsed(BNRP_TCB *tcb, long *heap, long *trail, long *env, long *cp)
{
	*heap = findUnused(((TCB *)tcb)->heapbase, ((TCB *)tcb)->heapend);
	*trail = findUnused(((TCB *)tcb)->trailbase, ((TCB *)tcb)->trailend);
	*env = findUnused(((TCB *)tcb)->envbase, ((TCB *)tcb)->envend);
	*cp = findUnused(((TCB *)tcb)->cpbase, ((TCB *)tcb)->cpend);
	}
#endif

#ifdef ring1
void BNRP_stackSpaceCurrent(BNRP_TCB *tcb, long *heap, long *trail, long *env, long *cp)
{
	*heap = ((TCB *)tcb)->hp - ((TCB *)tcb)->heapbase;
	*trail = ((TCB *)tcb)->trailbase - ((TCB *)tcb)->te;
	*env = ((TCB *)tcb)->ce - ((TCB *)tcb)->envbase;
	*cp = ((TCB *)tcb)->cpbase - ((TCB *)tcb)->lcp;
	}
#endif

#define trail(te, addr)					rpush(long, te, *(long *)addr); \
										rpush(long, te, (long)addr);

#define simplebind(val, newval)			{ \
										long _addr = addrof(val); \
										trail(tcb->te, _addr); \
										*(long *)_addr = (long)newval; \
										}
										
#define heapcheck(n)					if ((tcb->heapend - tcb->hp) LE (n * sizeof(long))) \
											BNRP_error(HEAPOVERFLOW)

#ifdef ring2
static void bind(TCB *tcb, long val, long newval)
{
	long *addr;
	
	simplebind(val, newval);
	addr = (long *)addrof(val);
	if (addr[1] EQ CONSTRAINTMARK) {
		heapcheck(2);
		if (tcb->constraintHead EQ 0)
			tcb->constraintHead = maketerm(LISTTAG, tcb->hp);
		else
			*(long *)tcb->constraintTail = maketerm(TVTAG, tcb->hp);
		push(long, tcb->hp, addr[2]);				/* push constraint onto heap */
		tcb->constraintTail = tcb->hp;
		push(long, tcb->hp, 0);					/* end of list */
		}
	}
#endif

#ifdef ring2
static void bindtohp(TCB *tcb, long val, long tags)
{
	long *p, criticalhp;
	
	p = (long *)addrof(val);
	if (p[1] EQ CONSTRAINTMARK) {				/* constrained variable ?? */
		heapcheck(3);							/* make sure we have enough room */
		if (tcb->constraintHead EQ 0)			/* new list of constraints ?? */
			tcb->constraintHead = maketerm(LISTTAG, tcb->hp);
		else									/* append to existing list */
			*(long *)tcb->constraintTail = maketerm(TVTAG, tcb->hp);
		push(long, tcb->hp, p[2]);				/* push constraint onto heap */
		tcb->constraintTail = tcb->hp;
		push(long, tcb->hp, 0);					/* end of list */
		}
	else {
		heapcheck(1);							/* something will be put on heap eventually */
		}
	/* is our TV at the end of the heap ?? */
	/* don't do it across critical to avoid garbage collection problems (91/10/21) */
	criticalhp = (tcb->lcp EQ tcb->cpbase) ? tcb->heapbase : ((choicepoint *)tcb->lcp)->hp;
	if (((long)p EQ tcb->hp - sizeof(long)) && (tags EQ TVTAG) && ((long)p GT criticalhp)) {
		/* no longer need to trail it */
		tcb->hp -= sizeof(long);				/* and just back up the heap pointer */
		}
	else {										/* no, so bind the TV to the current */
		bind(tcb, val, maketerm(tags, tcb->hp));	/* end of the heap */
		}
	}
#endif

#ifdef ring2
static void bindVV(TCB *tcb, long var1, long var2)
{
	long *a1, *a2, newcons, newvar;
	
	if (var1 EQ var2) return;
	a1 = (long *)addrof(var1);
	a2 = (long *)addrof(var2);
	if (a1[1] EQ CONSTRAINTMARK) {
		if (a2[1] EQ CONSTRAINTMARK) {		/* both variables constrained */
			register long hp;
			
			heapcheck(6);
			if (a2 GT a1) {
				/* a2 newer variable, reverse them */
				hp = (long)a1;
				a1 = a2;
				a2 = (long *)hp;
				}
			hp = tcb->hp;
			newcons = maketerm(LISTTAG, hp);
			if (tagof(a2[2]) EQ LISTTAG) {
				push(long, hp, a1[2]);
				push(long, hp, maketerm(TVTAG, addrof(a2[2])));
				}
			else if (tagof(a1[2]) EQ LISTTAG) {
				push(long, hp, a2[2]);
				push(long, hp, maketerm(TVTAG, addrof(a1[2])));
				}
			else {
				push(long, hp, a1[2]);
				push(long, hp, a2[2]);
				push(long, hp, 0);
				}
			newvar = makevarterm(hp);
			push(long, hp, newvar);
			push(long, hp, CONSTRAINTMARK);
			push(long, hp, newcons);
			tcb->hp = hp;
			simplebind(var1, newvar);		/* binds first var to new var */
			simplebind(var2, newvar);		/* binds second var to new var */
			}
		else {								/* only var1 constrained */
			simplebind(var2, var1);
			}
		}
	else if (a2[1] EQ CONSTRAINTMARK) {		/* only var2 constrained */
		simplebind(var1, var2);
		}
	else {									/* neither TV constrained */
		if (var1 LT var2) {
			simplebind(var2, var1);
			}
		else {
			simplebind(var1, var2);
			}
		}
	}
#endif

#ifdef ring2
static void bindTVTV(TCB *tcb, long var1, long var2)
{
	long *a1, *a2, newcons, newvar;
	
	if (var1 EQ var2) return;
	a1 = (long *)addrof(var1);
	a2 = (long *)addrof(var2);
	if (a1[1] EQ CONSTRAINTMARK) {
		if (a2[1] EQ CONSTRAINTMARK) {		/* both variables constrained */
			register long hp;
			
			heapcheck(6);
			if (a2 GT a1) {
				/* a2 newer variable, reverse them */
				hp = (long)a1;
				a1 = a2;
				a2 = (long *)hp;
				}
			hp = tcb->hp;
			newcons = maketerm(LISTTAG, hp);
			if (tagof(a2[2]) EQ LISTTAG) {
				push(long, hp, a1[2]);
				push(long, hp, maketerm(TVTAG, addrof(a2[2])));
				}
			else if (tagof(a1[2]) EQ LISTTAG) {
				push(long, hp, a2[2]);
				push(long, hp, maketerm(TVTAG, addrof(a1[2])));
				}
			else {
				push(long, hp, a1[2]);
				push(long, hp, a2[2]);
				push(long, hp, 0);
				}
			newvar = maketerm(TVTAG, hp);
			push(long, hp, newvar);
			push(long, hp, CONSTRAINTMARK);
			push(long, hp, newcons);
			tcb->hp = hp;
			simplebind((long)a1, newvar);	/* binds first var to new var */
			simplebind((long)a2, newvar);	/* binds second var to new var */
			}
		else {								/* only var1 constrained */
			simplebind((long)a2, var1);
			}
		}
	else if (a2[1] EQ CONSTRAINTMARK) {		/* only var2 constrained */
		simplebind((long)a1, var2);
		}
	else {									/* neither TV constrained */
		if ((long)a1 LT (long)a2) {
			simplebind((long)a2, var1);
			}
		else {
			simplebind((long)a1, var2);
			}
		}
	}
#endif

#ifdef ring2
BNRP_Boolean checkArity(long arity1, long arity2)
{
	if (arity1 EQ arity2)
		return(TRUE);
	else if ((arity1 GE 0) && (arity2 GE 0))
		return(FALSE);
	else if ((arity1 LT 0) && (arity2 LT 0))
		return(TRUE);
	else
		return((arity1 + arity2) GE -1);
	}
#endif

#ifdef ring2
static BNRP_Boolean unifyList(TCB *tcb, long list1, long list2)
/* when called, list1 and list2 point to the first element of the lists */
{
	long addr1, addr2, dataaddr1, dataaddr2, l, val1, val2, a, *a1, *a2;
	long LDCount, LDHold, LDk, LDSaveAddr1, LDSaveAddr2;
	
	clearAM();
	pushAM(list1, list2, 0L);
	LDCount = 1;
	LDHold = 2;
	LDk = 0;
	while (pullAM(&addr1, &addr2, &l)) {
		if (addr1 EQ addr2) goto done;
		LDCount = 1;
		LDHold = 2;
		LDk = 0;
loop:
		dataaddr1 = addr1;
		get(long, addr1, val1);
		while (tagof(val1) EQ TVTAG) {
			l = addrof(val1);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val1) goto tailvar1;
			if (l LT addr1) {				/* loop backwards */
				if (--LDCount LE 0) {
					if (LDk EQ 0) {
						LDk = LDHold;
						LDHold += LDHold;
						LDSaveAddr1 = l;
						LDSaveAddr2 = addr2;
						}
					else {
						--LDk;
						if ((LDSaveAddr1 EQ l) && (LDSaveAddr2 EQ addr2)) {
							/* looped list */
							goto done;
							}
						}
					}
				}
			addr1 = dataaddr1 = l;
			get(long, addr1, val1);
			}
		/* now know that val1 is not a tailvariable */
		dataaddr2 = addr2;
		get(long, addr2, val2);
		while (tagof(val2) EQ TVTAG) {
			l = addrof(val2);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val2) goto tailvar2;
			addr2 = dataaddr2 = l;
			get(long, addr2, val2);
			}
		/* now know that val1, val2 are not tailvariables */
		/* see if val1 is a variable */
		while (isVAR(val1)) {
			register long l = derefVAR(val1);
			if (val1 EQ l) goto var1;
			val1 = l;
			}
		/* now know that val1 is a simple type, check val2 */
		while (isVAR(val2)) {
			register long l = derefVAR(val2);
			if (val2 EQ l) goto var2;
			val2 = l;
			}
		/* now know that val1 and val2 simple types */
		if ((val1 EQ 0) && (val2 EQ 0)) goto done;	/* end of list */
		if (val1 EQ val2) goto loop;
		if ((l = tagof(val1)) NE tagof(val2)) return(FALSE);
		a1 = (long *)addrof(val1);				/* remove tags to get addresses */
		a2 = (long *)addrof(val2);
		if (l EQ LISTTAG) {
			long temp1, temp2;
			
			temp1 = *a1++;
			temp2 = *a2++;
			while ((temp1 EQ temp2) && (temp1 LT 0)) {
				temp1 = *a1++;
				temp2 = *a2++;
				}
			if ((temp1 NE 0) || (temp2 NE 0)) {
				--a1;
				--a2;
				pushAM((long)a1, (long)a2, 0L);
				}
			}
		else if (l EQ STRUCTTAG) {
			li arity1, arity2;
			
			arity1.l = *a1++;
			arity2.l = *a2++;
			if ((arity1.i.a EQ FUNCIDshort) &&
				(arity2.i.a EQ FUNCIDshort) &&
				((arity1.i.b EQ arity2.i.b) || checkArity(arity1.i.b, arity2.i.b)))
					pushAM((long)a1, (long)a2, 0L);
			else
				if ((arity1.i.a EQ NUMBERIDshort) && (arity1.l EQ arity2.l)) {
					switch (arity1.i.b) {
						case INTIDshort:	comparelong(a1, a2, return(FALSE));
											break;
						case FLOATIDshort:	fpLWA(a1);
											fpLWA(a2);
											comparefp(a1, a2, return(FALSE));
											break;
						}
					}
				else
					return(FALSE);
			}

		else
			return(FALSE);
		goto loop;
	
var1:
		/* val1 is a variable, check val2 */
		while (isVAR(val2)) {
			register long l = derefVAR(val2);
			if (val2 EQ l) {
				bindVV(tcb, val1, val2);
				goto loop;
				}
			val2 = l;
			}
		/* val1 is a variable, val2 otherwise so just bind */
		if (val2 EQ 0) return(FALSE);
		bind(tcb, val1, val2);
		goto loop;		

var2:
		/* val2 is a variable, val1 is simple so just bind */
		if (val1 EQ 0) return(FALSE);
		bind(tcb, val2, val1);
		goto loop;
	
tailvar1:
		/* know that val1 points at tail variable, what about val2 */
		dataaddr2 = addr2;
		get(long, addr2, val2);
		while (tagof(val2) EQ TVTAG) {
			l = addrof(val2);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val2) {				/* val2 also a tailvariable */
				bindTVTV(tcb, val1, val2);
				goto done;
				}
			addr2 = dataaddr2 = l;
			get(long, addr2, val2);
			}
		/* val2 not a tailvariable, so bind val1 to point at it */
		val1 = addrof(val1);			/* remove TVTAG */
		bind(tcb, val1, maketerm(TVTAG, dataaddr2));
		goto done;
	
tailvar2:
		/* know that val2 is a tailvariable, val1 not so just bind */
		val2 = addrof(val2);			/* remove TVTAG */
		bind(tcb, val2, maketerm(TVTAG, dataaddr1));

done:	;
		}
	freeAM();
	return(TRUE);
	}
#endif

#ifdef ring2

BNRP_Boolean unify(TCB *tcb, long t1, long t2)
{
	long val1;
	
	if (t1 EQ t2) return(TRUE);
	
	while (isVAR(t1)) {
		register long val1 = derefVAR(t1);
		if (t1 EQ val1) goto var1;
		t1 = val1;
		}
	/* t1 is a nonvar */
	while (isVAR(t2)) {
		register long val2 = derefVAR(t2);
		if (t2 EQ val2) goto var2;
		t2 = val2;
		}
	while (isTV(t1)) {
		register long val1 = derefVAR(t1);
		if (t1 EQ val1) goto tailvar1;
		t1 = val1;
		}
	/* t1 is a nontvar */
	while (isTV(t2)) {
		register long val2 = derefVAR(t2);
		if (t2 EQ val2) goto tailvar2;
		t2 = val2;
		}
	/* t1, t2 are nonvars */
	if (t1 EQ t2) return(TRUE);	
	if ((val1 = tagof(t1)) EQ tagof(t2)) {
		if (val1 EQ LISTTAG)
			return(unifyList(tcb, addrof(t1), addrof(t2)));
		else if (val1 EQ STRUCTTAG) {
			register long *a1, *a2;
			li arity1, arity2;
			
			a1 = (long *)addrof(t1);			/* remove tags to get addresses */
			a2 = (long *)addrof(t2);
			arity1.l = *a1++;
			arity2.l = *a2++;
			if ((arity1.i.a EQ FUNCIDshort) &&
				(arity2.i.a EQ FUNCIDshort) &&
				((arity1.i.b EQ arity2.i.b) || checkArity(arity1.i.b, arity2.i.b)))
					return(unifyList(tcb, (long)a1, (long)a2));
			else
				if ((arity1.i.a EQ NUMBERIDshort) && (arity1.l EQ arity2.l)) {
					switch (arity1.i.b) {
						case INTIDshort:	comparelong(a1, a2, return(FALSE));
											break;
						case FLOATIDshort:	fpLWA(a1); 
											fpLWA(a2);
											comparefp(a1, a2, return(FALSE));
											break;
						}
					return(TRUE);
					}
			}
		}	
	return(FALSE);

var2:
	/* t1 is a nonvar, t2 is a var */
	if (tagof(t2) EQ TVTAG) {
		if ((tagof(t1) NE ENDT) && (tagof(t1) NE LISTTAG)) return(FALSE);
		bind(tcb, addrof(t2), maketerm(TVTAG,addrof(t1)));
		}
	else {
		if (t1 EQ 0) return(FALSE);
		bind(tcb, t2, t1);
		}
	return(TRUE);
	
var1:
	/* t1 is a variable or tailvariable */
	if (tagof(t1) EQ TVTAG) goto tailvar1;
	while (isVAR(t2)) {
		register long val2 = *(long *)addrof(t2);
		if (t2 EQ val2) goto var12;
		t2 = val2;
		}
	/* t1 is a var, t2 nonvar */	
	if (t2 EQ 0) return(FALSE);
	bind(tcb, t1, t2);
	return(TRUE);
	
var12:
	/* t1, t2 are variables */
	bindVV(tcb, t1, t2);
	return(TRUE);

tailvar2:
	/* t1 is a nontvar, t2 is a tvar */
	 if ((tagof(t1) NE ENDT) && (tagof(t1) NE LISTTAG)) return(FALSE);
	 bind(tcb, addrof(t2), maketerm(TVTAG,addrof(t1)));
	return(TRUE);

tailvar1:
	/* t1 is a tailvariable, look at t2 */
	while (isTV(t2)) {
		register long val2 = *(long *)addrof(t2);
		if (t2 EQ val2) goto tailvar12;
		t2 = val2;
		}
	if (isVAR(t2)) return(FALSE);
	/* t1 is a TV, t2 nonvar */	
	if ((t2 NE 0) && (tagof(t2) NE LISTTAG)) return(FALSE);
	bind(tcb, addrof(t1), maketerm(TVTAG,addrof(t2)));
	return(TRUE);
	
tailvar12:
	/* t1 is a TV, t2 is a variable/TV */
	if (tagof(t2) EQ VART) return(FALSE);
	bindTVTV(tcb, t1, t2);
	return(TRUE);
	}
#endif


#ifdef ring2
/* Used for unifying point intervals*/
void unifyQuick(TCB *tcb, long var, long val)
{
	long * addr;

	simplebind(var, val);
	addr = (long *)addrof(var);
	if (tagof(addr[2]) EQ LISTTAG) /*Only lists of constraints are woken up*/
	{		
		heapcheck(2);
		if (tcb->constraintHead EQ 0)
		{	tcb->constraintHead = maketerm(LISTTAG, tcb->hp);}
		else
			*(long *)tcb->constraintTail = maketerm(TVTAG, tcb->hp);
		push(long, tcb->hp, addrof(addr[2]));	/* push constraint onto heap */
		tcb->constraintTail = tcb->hp;
		push(long, tcb->hp, 0);					/* end of list */
	}
}
#endif

#ifdef debug
extern TCB tcb;
#endif

#ifdef ring0

extern li BNRPflags;

void abortHandler(int sig)
{
/* yanzhou@bnr.ca:08/12/95: commented out
 *      signal(sig, abortHandler); */           /* reestablish our handler */
        BNRPflags.l |= 0x01;
        fflush(stdin);
        }

void arithHandler(int sig)
{
/* yanzhou@bnr.ca:08/12/95: commented out
 *      signal(sig, arithHandler); */           /* reestablish our handler */
        BNRP_error(ARITHERROR);
        }

long BNRP_CheckAlignment()
{
        return(0);
        }

#endif

#ifdef ring0
#define inR(addr)				((addr GE BNRP_R.bottom) && (addr LT BNRP_R.top))
#define inRprime(addr)			((addr GE BNRP_Rprime.bottom) && (addr LT BNRP_Rprime.top))

long BNRP_Roffset;
struct {
	long bottom, top;
	} BNRP_R, BNRP_Rprime;

long copytoRprime(long val)
{
	long result = val, *addr, tag, l, ll, *headerAddress, *a;
	li header;
#ifdef check
	long orig = val;
#endif

#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
	printf("Checking %08lX", val);
#endif
	addr = (long *)addrof(val);
	if ((tag = tagof(val)) EQ VARTAG) {
		l = *addr;
		if (inRprime(addrof(l))) {							/* already copied out ?? */
			result = makevarterm(addrof(l) - BNRP_Roffset);	/* point at whats been copied */
			}
		else {
			result = makevarterm(BNRP_Rprime.top - BNRP_Roffset);
			ll = *addr++ = makevarterm(BNRP_Rprime.top);	/* point existing var at new var */
copyVar:
			if (l EQ val) {									/* really is an unbound var or TV */
				/* create new var */
				push(long, BNRP_Rprime.top, ll);
				if (*addr++ EQ CONSTRAINTMARK) {			/* constrained var ?? */
					push(long, BNRP_Rprime.top, CONSTRAINTMARK);
					l = *addr;								/* get constraint */
					if (tagof(l) EQ TVTAG) {				/* was constraint already copied */
						register long _ll = addrof(l);
						header = *(li *)_ll;				/* see if structure header at new address */
						l = maketerm((header.i.a EQ FUNCIDshort) ? STRUCTTAG : LISTTAG, _ll);
						}
					push(long, BNRP_Rprime.top, l);			/* copy constraint */
					}
				}
			else {
				push(long, BNRP_Rprime.top, l);				/* copy contents */
				}
			}
		}
	else if (tag EQ TVTAG) {
		l = *addr;
		/* may have already been copied out, but not neccesarily     */
		/* since only first thing in the list might have been copied */
		result = maketerm(TVTAG, (BNRP_Rprime.top - BNRP_Roffset));
		ll = *addr++ = maketerm(TVTAG, BNRP_Rprime.top);	/* point existing TV at new TV */
		goto copyVar;
		}
	else if (tag EQ STRUCTTAG) {
		result = maketerm(STRUCTTAG, (BNRP_Rprime.top - BNRP_Roffset));
		header.l = *addr;
		if (header.i.a EQ NUMBERIDshort) {
			*addr++ = makevarterm(BNRP_Rprime.top);			/* replace header with new address */
			push(long, BNRP_Rprime.top, header.l);
			switch (header.i.b) {
				case INTIDshort:	*(long *)BNRP_Rprime.top = *addr;
									BNRP_Rprime.top += sizeof(long);
									break;
				case FLOATIDshort:	fpLWA(BNRP_Rprime.top);
									fpLWA(addr);
									*(fp *)BNRP_Rprime.top = *(fp *)addr;
									BNRP_Rprime.top += sizeof(fp);
									break;
				}
			}
		else if (header.i.a EQ FUNCIDshort) {
			*addr++ = makevarterm(BNRP_Rprime.top);			/* replace header with new address */
			headerAddress = (long *)BNRP_Rprime.top;
			push(long, BNRP_Rprime.top, header.l);
	copyItems:
			header.i.b = 0;
			for (;;) {
				val = *addr++;
				while (tagof(val) EQ TVTAG) {
					addr = (long *)addrof(val);
					if (!inR((long)addr)) break;			/* TV out of R, so stop */
					if ((l = *addr++) EQ val) break;		/* unbound TV, so stop */
					val = l;								/* chase again */
					}
				while (isVAR(val)) {
					long *_addr = (long *)addrof(val);
					if (!inR((long)_addr)) break;			/* variable out of R so stop */
					if ((l = *_addr) EQ val) break;			/* unbound var, so stop */
					if (tagof(val = l) EQ TVTAG)			/* chase again */
						if (inRprime(addrof(l))) {			/* must be an already moved variable */
							val = makevarterm(addrof(l));	/* remove TVTAG */
							break;							/* out of this loop */
							}
					}
				/* chased variable as far as it goes in R, see what happens now */
				a = (long *)addrof(val);
				tag = tagof(val);
				if inR((long)a) {			
					/* something references R */
					if (tag EQ VARTAG) {
						/* if unconstrained var then move to R', else leave alone */
						/* let pass through R' copy the variable w/constriant to R' */
						if (a[1] NE CONSTRAINTMARK) {
							val = *a = makevarterm(BNRP_Rprime.top);
							addr[-1] = maketerm(TVTAG, BNRP_Rprime.top);
							}
						}
					else if (tag EQ TVTAG) {
						/* if unconstrained TV then move to R', else leave unmodified */
						/* let pass through R' copy the TV w/constriant to R' */
						if (a[1] NE CONSTRAINTMARK)
							addr[-1] = val = *a = maketerm(TVTAG, BNRP_Rprime.top);
						}
					else 
						/* for lists and structures leave unchanged till pass of R' */
						/* however, update addr to point at new copy */
						addr[-1] = maketerm(TVTAG, BNRP_Rprime.top);
					}
				else
					if (inR((long)addr)) addr[-1] = maketerm(TVTAG, BNRP_Rprime.top);
				push(long, BNRP_Rprime.top, val);
				if (val EQ 0) break;
				if (tag EQ TVTAG) {
					header.i.b = -header.i.b - 1;
					break;
					}
				++header.i.b;
				}
			if (headerAddress NE NULL) *headerAddress = header.l;
			}
		else {		/* header is a already moved address in Rprime, so return it */
			long addr = addrof(header.l);
#ifdef messages1
			printf("gc: header %08lX (address %08lX)", header.l, addr);
#endif
			if (!inRprime(addr)) {
#ifdef messages
				printf("gc: Unrecognized structure header %08lX starting at %08lX\n", header.l, orig);
#endif
				addr = addrof(0xAAAAAAAA);
				}
			else
				addr -= BNRP_Roffset;
#ifdef messages1
			printf(", updated address %08lX\n", addr);
#endif
			result = maketerm(STRUCTTAG, addr);
			}
		}
	else if (tag EQ LISTTAG) {
		/* setup result, jump into midst of structure loop */
		if ((tagof(*addr) EQ TVTAG) && (inRprime(addrof(*addr))))
			result = maketerm(LISTTAG, (addrof(*addr) - BNRP_Roffset));
		else {
			result = maketerm(LISTTAG, (BNRP_Rprime.top - BNRP_Roffset));
			headerAddress = NULL;
			goto copyItems;
			}
		}
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
	printf(", new value %08lX\n", result);
#endif
#ifdef check
	if (tagof(result) NE tagof(orig)) 
		printf("***** Switching tags in gc: orig %08lX, result %08lX\n", orig, result);
#endif
	return(result);
	}

void BNRP_gc(long esize, choicepoint *lcp, long *hp, long ce, long te)
{
	long l, ll, e, i, *addr;
	struct trail {
		long addr;
		long old;
		} *teptr;
	void *p = NULL;
#ifdef debug
	long origesize = esize & 0x0FF;
#endif

	e = ce;
	while (e GT lcp->bce) {
		e = env(e,CE);
		}
	if (e NE lcp->bce) return;

	BNRP_R.bottom = lcp->hp;
	BNRP_R.top = *hp;
	BNRP_Roffset = *hp - BNRP_R.bottom;		/* size of R */
	if ((te - *hp) GE BNRP_Roffset) {		/* enough space on heap */
		BNRP_Rprime.top = BNRP_Rprime.bottom = *hp;
		}
	else {									/* not enough space on heap, try memory */
		if ((p = (void *)BNRP_malloc(BNRP_Roffset)) EQ NULL) return;
		BNRP_Rprime.top = BNRP_Rprime.bottom = (long)p;
		BNRP_Roffset = BNRP_Rprime.bottom - BNRP_R.bottom;
		}
	++BNRP_numGC;
	if (BNRP_gcFlag LT 0)
		if (BNRP_numGC + BNRP_gcFlag GT 0) return;

	esize &= 0x0FF;			/* strip down to a single unsigned byte */
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount) {
#endif
	printf("\n\nExecuting GC %ld, Heap at cut:", BNRP_numGC);
	BNRP_dumpHex(stdout, (void *)lcp->hp, (void *)*hp);
	printf("Environment at cut:");
	BNRP_dumpHex(stdout, (void *)lcp->bce, (void *)(ce + ((origesize + 1) * sizeof(long))));
	printf("Trail at cut:\n");
	teptr = (struct trail *)te;
	while ((long)teptr LT lcp->te) {
		printf("Trailed address %p, trailed %08lX, bound to %08lX\n", 
				teptr->addr, teptr->old, *(long *)(teptr->addr));
		++teptr;
		}
	teptr = (struct trail *)te;
	while ((long)teptr LT lcp->te) {
		ll = *(long *)(teptr->addr);			/* dereference address to get what it's bound to */
		if inR(addrof(ll)) BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
		++teptr;
		}
	e = ce;
	l = origesize;
	while (e GE lcp->bce) {
		printf("Examining env @ %p, size = %ld\n", e, l);
		for (i = 1; i LE l; ++i) {
			long t;
			t = env(e,i);
			if inR(addrof(t)) BNRP_dumpArg(stdout, &tcb, t);
			}
		l = *(unsigned char *)(env(e,CP));
		e = env(e,CE);
		}
#ifdef debugcount
	}
#endif
#endif
	teptr = (struct trail *)te;
	while ((long)teptr LT lcp->te) {
		ll = *(long *)(teptr->addr);			/* dereference address to get what it's bound to */
		if inR(addrof(ll)) {					/* copy to R prime */
			/* we leave addresses in Rprime since we may have trailed an env address */
			if (tagof(ll) EQ TVTAG)
				*(long *)(teptr->addr) = maketerm(TVTAG, (addrof(copytoRprime(maketerm(LISTTAG, addrof(ll)))))) + BNRP_Roffset;
			else
				*(long *)(teptr->addr) = copytoRprime(ll) + BNRP_Roffset;
			}
#ifdef messages
		else if inRprime(addrof(ll))			/* shouldn't happen */
			printf("gc: Unexpected item %08lX in trail\n", ll);
#endif
		++teptr;
		}
	e = ce;
	while (e GE lcp->bce) {
#ifdef debug
#ifdef debugcount
		if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
		printf("Examining env @ %p, size = %ld\n", e, esize);
#endif
		for (i = 1; i LE esize; ++i) {
			long t;
			t = env(e,i);
			if inR(addrof(t)) {
#ifdef messages
				if (tagof(t) EQ TVTAG) printf("Unexpected TV in environment\n");
#endif
				while (tagof(t) EQ VARTAG) {
					long tt;
					if (!inR(t)) break;					/* var outside R, so stop */
					if ((tt = *(long *)t) EQ t) break;	/* unbound variable ? */
					t = tt;								/* chase variable */
					}
				/* if t is in R, then copy it to new heap and replace */
				/* e(i). Otherwise, replace e(i) in case we chased a  */
				/* variable though and then out of R. If address in   */
				/* R' then already copied, substitute new address.    */
				l = addrof(t);
				if inR(l)
					t = copytoRprime(t);
				else if inRprime(l) {
					/* if copied out as part of list then TV tag set */
					/* not needed since we have a variable that we followed */
					/* TV must be contained inside lists and structures */
					if (tagof(t) EQ TVTAG) t = addrof(t);
					t -= BNRP_Roffset;
					}
				env(e,i) = t;
				}
			/* if e(i) was trailed, then address is in R' and we don't need to check it */
			/* later pass through trail again will get it */
			}
		esize = *(unsigned char *)(env(e,CP));
		e = env(e,CE);
		}
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
	printf("Examining R'\n");
#endif
	addr = (long *)BNRP_Rprime.bottom;
	while ((long)addr LT BNRP_Rprime.top) {
		li ll;
		l = addrof(ll.l = *addr);
		if inR(l)
			ll.l = copytoRprime(ll.l);
		else if inRprime(l)
			if (tagof(ll.l) NE INTTAG)	/* in case heap at low addresses */
				ll.l -= BNRP_Roffset;
		*addr++ = ll.l;
		if (ll.i.a EQ NUMBERIDshort) {
			if (ll.i.b EQ INTIDshort)
				++addr;
			else {
				fpLWA(addr);
				addr += (sizeof(fp) / sizeof(long));
				}
			}
		}
	/* scan trail to move copied items to their final resting place */
	teptr = (struct trail *)te;
	while ((long)teptr LT lcp->te) {
		ll = *(long *)(teptr->addr);
		if inRprime(addrof(ll))	
			*(long *)(teptr->addr) = ll - BNRP_Roffset;
		++teptr;
		}

	l = BNRP_Rprime.top - BNRP_Rprime.bottom;		/* size of R' */
	memcpy((void *)BNRP_R.bottom, (void *)BNRP_Rprime.bottom, l);
	*hp = BNRP_R.bottom + l;
	if (p NE NULL) BNRP_free(p);
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount) {
#endif
	printf("\nHeap after GC:");
	BNRP_dumpHex(stdout, (void *)lcp->hp, (void *)*hp);
	printf("Environment after GC:");
	BNRP_dumpHex(stdout, (void *)lcp->bce, (void *)(ce + ((origesize + 1) * sizeof(long))));
	printf("Trail after GC:\n");
	l = te;
	while (l LT lcp->te) {
		get(long, l, e);		/* get address from trail */
		get(long, l, i);		/* get previous contents from trail */
		ll = *(long *)e;		/* dereference address to get what it's bound to */
		printf("Address %p, trailed %08lX, now bound to %08lX\n", e, i, ll);
		}
	teptr = (struct trail *)te;
	while ((long)teptr LT lcp->te) {
		ll = *(long *)(teptr->addr);			/* dereference address to get what it's bound to */
		if inR(addrof(ll)) BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
		++teptr;
		}
	e = ce;
	l = origesize;
	while (e GE lcp->bce) {
		printf("Examining env @ %p, size = %ld\n", e, l);
		for (i = 1; i LE l; ++i) {
			long t;
			t = env(e,i);
			if inR(addrof(t)) BNRP_dumpArg(stdout, &tcb, t);
			}
		l = *(unsigned char *)(env(e,CP));
		e = env(e,CE);
		}
	printf("GC: heap was %ld bytes, now %ld bytes\n", BNRP_Roffset, BNRP_Rprime.top - BNRP_R.top);
#ifdef debugcount
	}
#endif
#endif
	}
	
void BNRP_gc_proceed(choicepoint *lcp, long *hp, long te, long *regs)
{
	long l, ll, *addr, sizeofR;
	struct trail {
		long addr;
		long old;
		} *teptr;
	void *p = NULL;
	int i;

	BNRP_R.bottom = lcp->hp;
	BNRP_R.top = *hp;
	sizeofR = *hp - BNRP_R.bottom;						/* size of R */
	if ((te - *hp) GE sizeofR+sizeofR) {				/* enough space on heap */
		BNRP_Rprime.bottom = *hp;
		}
	else {									/* not enough space on heap, try memory */
		if ((p = (void *)BNRP_malloc(sizeofR+sizeofR)) EQ NULL) return;
		BNRP_Rprime.bottom = (long)p;
		}
#ifdef fpAlignment
	l = BNRP_R.bottom & (fpAlignment - 1);
	while ((BNRP_Rprime.bottom & (fpAlignment - 1)) NE l)
		BNRP_Rprime.bottom += sizeof(long);
#endif
	BNRP_Rprime.top = BNRP_Rprime.bottom;
	BNRP_Roffset = BNRP_Rprime.bottom - BNRP_R.bottom;
	++BNRP_numGC;
	if (BNRP_gcFlag LT 0)
		if (BNRP_numGC + BNRP_gcFlag GT 0) return;

#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount) {
#endif
		printf("\n\nExecuting GC %ld, Heap at proceed:", BNRP_numGC);
		BNRP_dumpHex(stdout, (void *)lcp->hp, (void *)*hp);
		printf("Registers at proceed:\n");
		for (i = 1; i LE labs(regs[0]); ++i) {
			ll = regs[i];
			if inR(addrof(ll)) 
				BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
			else
				printf("Skipping register %08lX\n", ll);
			}
		printf("Trail at proceed:\n");
		for (teptr = (struct trail *)te; (long)teptr LT lcp->te; ++teptr) {
			ll = *(long *)(teptr->addr);			/* dereference address to get what it's bound to */
 			if ((inR(addrof(teptr->old))) && (tagof(teptr->old) EQ STRUCTTAG)) {
 				printf("****WARNING******  old address in trail points into R ********************\n");
 				}
 			if (teptr->addr GE ((teptr->addr GT te) ? lcp->critical : lcp->hp)) {
				printf("Skipping trailed %08lX, bound to %08lX\n", teptr->addr, ll);
				continue;
				}
			printf("Trailed address %p, trailed %08lX, bound to %08lX\n", 
					teptr->addr, teptr->old, ll);
			if inR(addrof(ll)) BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
			}
#ifdef debugcount
		}
#endif
#endif

#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
		printf("Examining registers\n");
#endif
	for (i = 1; i LE labs(regs[0]); ++i) {
		ll = regs[i];
		if inR(addrof(ll)) {					/* must copy to R prime */
			if (tagof(ll) EQ TVTAG)
				regs[i] = maketerm(TVTAG, (addrof(copytoRprime(maketerm(LISTTAG, addrof(ll))))));
			else
				regs[i] = copytoRprime(ll);
			}
		}
		
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
		printf("Examining trail\n");
#endif
	for (teptr = (struct trail *)te; (long)teptr LT lcp->te; ++teptr) {
		/* if trailed address past old hp or old ce then ignore it */
		/* (excess stuff on trail not yet trimmed) */
		if (teptr->addr GE ((teptr->addr GT te) ? lcp->critical : lcp->hp)) continue;

		/* special check in case something is on the trail that is to be   */
		/* reset to something in R, which is a bug.  Simply ignore for now */
		if ((inR(addrof(teptr->old))) && (tagof(teptr->old) EQ STRUCTTAG)) {
#ifdef check
			printf("****WARNING******  old address (%08lx) in trail (item = %08lx) points into R ********************\n", teptr->old, teptr->addr);
#endif
			teptr->old = maketerm(STRUCTTAG, 0x0aaa0aaa);
			continue;
			}

		/* dereference address to get what it's bound to */
		ll = *(long *)(teptr->addr);
		if inR(addrof(ll)) {					/* copy to R prime */
			if (tagof(ll) EQ TVTAG)
				*(long *)(teptr->addr) = maketerm(TVTAG, (addrof(copytoRprime(maketerm(LISTTAG, addrof(ll))))));
			else
				*(long *)(teptr->addr) = copytoRprime(ll);
			}
		}
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount)
#endif
		printf("Examining R'\n");
#endif
	addr = (long *)BNRP_Rprime.bottom;
	while ((long)addr LT BNRP_Rprime.top) {
		li ll;
		l = addrof(ll.l = *addr);
		if inR(l)
			ll.l = copytoRprime(ll.l);
		else if inRprime(l)
			if (tagof(ll.l) NE INTTAG)	/* in case heap at low addresses */
				ll.l -= BNRP_Roffset;
		*addr++ = ll.l;
		if (ll.i.a EQ NUMBERIDshort) {
			if (ll.i.b EQ INTIDshort)
				++addr;
			else {
				fpLWA(addr);
				addr += (sizeof(fp) / sizeof(long));
				}
			}
		}
		
	l = BNRP_Rprime.top - BNRP_Rprime.bottom;		/* size of R' */
#ifdef Macintosh
	/* memmove allows for overlapping regions, so we are OK */
	memmove((void *)BNRP_R.bottom, (void *)BNRP_Rprime.bottom, l);
#else
	/* using memcpy, we have to avoid overlapping copies */
	if (l LE sizeofR)		/* size of R' <= size of R ?? (usual case) */
		memcpy((void *)BNRP_R.bottom, (void *)BNRP_Rprime.bottom, l);
	else {
		/* rare cases we we grow the heap, so do it in two chunks */
		memcpy((void *)BNRP_R.bottom, (void *)BNRP_Rprime.bottom, sizeofR);
		memcpy((void *)(BNRP_R.bottom+sizeofR), (void *)(BNRP_Rprime.bottom+sizeofR), l-sizeofR);
		}		
#endif
	*hp = BNRP_R.bottom + l;
	if (p NE NULL) BNRP_free(p);
#ifdef debug
#ifdef debugcount
	if (BNRP_numGC + BNRP_gcFlag GT -debugcount) {
#endif
		printf("\nHeap after GC:");
		BNRP_dumpHex(stdout, (void *)lcp->hp, (void *)*hp);
		printf("Registers after GC:\n");
		for (i = 1; i LE labs(regs[0]); ++i) {
			ll = regs[i];
			if inR(addrof(ll)) BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
			}
		printf("Trail after GC:\n");
		for (teptr = (struct trail *)te; (long)teptr LT lcp->te; ++teptr) {
			if (teptr->addr GE ((teptr->addr GT te) ? lcp->critical : lcp->hp)) continue;
			ll = *(long *)(teptr->addr);			/* dereference address to get what it's bound to */
			printf("Trailed address %p, trailed %08lX, bound to %08lX\n", 
					teptr->addr, teptr->old, ll);
			if inR(addrof(ll)) BNRP_dumpArg(stdout, &tcb, (tagof(ll) EQ TVTAG) ? maketerm(LISTTAG, addrof(ll)) : ll);
			}
		printf("GC: heap was %ld bytes, now %ld bytes\n", BNRP_Roffset, BNRP_Rprime.top - BNRP_R.top);
#ifdef debugcount
		}
#endif
#endif
	}
#endif
