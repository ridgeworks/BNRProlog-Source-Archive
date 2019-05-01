/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/external.c,v 1.12 1998/02/13 10:54:48 harrisj Exp $
 *
 * $Log: external.c,v $
 * Revision 1.12  1998/02/13  10:54:48  harrisj
 * Modified ppc comparison's in BNRP_execute* functions to cope with HSC ppc definition
 *
 * Revision 1.11  1997/12/23  09:48:20  harrisj
 * Added BNRP_dumpTerm() to external interface
 *
 * Revision 1.10  1997/12/22  17:01:03  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.9  1997/08/18  17:21:58  harrisj
 * Added BNRP_lengthList() function and modified BNRP_tag enum
 * so that BNRP_end and BNRP_invalid are equivalent.
 *
 * Revision 1.8  1997/08/12  17:34:52  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.7  1997/03/20  10:16:44  harrisj
 * Added BNRP_primitiveName function to retrieve the name of the
 * currently executing Prolog primitive name from the TCB.
 *
 * Revision 1.6  1996/09/05  17:51:29  harrisj
 * Allow structures to have variable functors. All structure building
 * functions modified to allow this as well as getValue,
 * getNextValue and getIndexedValue.
 *
 * Revision 1.5  1996/07/11  17:40:05  yanzhou
 * BNRP_termToString() is now defined in external.c, it merely tranfers
 * the execution to BNRP_makeTermToString(), which is an internal function
 * defined in ioprim.[hc].
 *
 * Revision 1.4  1996/07/03  19:29:37  yanzhou
 * BNRPLookupTempSymbol needs 2 arguments, only 1 was provided.
 * Now fixed.
 *
 * Revision 1.3  1996/06/24  11:59:19  yanzhou
 * When new structures are being created, their functors
 * are no longer made as permanent symbols; instead, they
 * are now made as temporary symbols.
 *
 * Revision 1.2  1995/12/15  12:10:46  yanzhou
 * BNRP_buildList() and BNRP_buildStructure() are added to the BNRP
 * external interface.  Both of the functions can take an array of
 * BNRP_terms and construct a list or a structure out of it.
 *
 * Revision 1.1  1995/09/22  11:24:14  harrisja
 * Initial version.
 *
 *
 */
/**************************************************************************

	This unit defines the routines generally required by C programs.
	Although broken up into "rings", this is only done so not all the
	routines need to be included if you do not call them.  For obvious
	reasons some functions are grouped together.
	
	Group 0 BNRP_createTCB, BNRP_initializeTCB, BNRP_disposeTCB, BNRP_terminateTCB
	Group 1 BNRP_markheap, BNRP_releaseheap, BNRP_execute, BNRP_executeOnce
	        BNRP_executeNext, BNRP_unify
	Group 2 BNRP_makeVar, BNRP_makeTailvar, BNRP_makeInteger, BNRP_makeFloat,
	        BNRP_makeSymbol, BNRP_makePermSymbol, BNRP_makeTerm, BNRP_termToString
	Group 3 BNRP_newContext, BNRP_loadFile
	Group 4 BNRP_bindPrimitive
	Group 5 BNRP_getValue, BNRP_getIndexedValue, BNRP_getNextValue, 
	        BNRP_getIndexedTerm, BNRP_getNextTerm
	Group 6 BNRP_makeList, BNRP_makeStructure, BNRP_startList,
	        BNRP_startStructure, BNRP_startStructureAtom, BNRP_addTerm
            BNRP_buildStructure, BNRP_buildList <== New 14/12/95 by yanzhou@bnr.ca
	
**************************************************************************/

#include "BNRProlog.h"
#include "base.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>			/* for varargs */
#include <setjmp.h>
#include "core.h"
#include "hardware.h"
#include "memory.h"
#include "interpreter.h"
#include "context.h"
#include "prim.h"
#include "ioprim.h"
#include "loader.h"
#include "tasking.h"
#include "pushpop.h"

/* Feb. 95 Jason Harris */
#define heapcheck(n)	if ((((TCB *)tcb)->heapend - hp) LE (n * sizeof(long))) \
				BNRP_error(HEAPOVERFLOW)
			 

#ifdef ring0
BNRP_TCB *BNRP_createTCB(void)
{
	TCB *tcb;
	
	tcb = (TCB *)BNRP_malloc(sizeof(TCB));
	tcb->space = tcb->freePtr = tcb->ASTbase = tcb->heapbase =
	tcb->trailbase = tcb->envbase = tcb->cpbase = tcb->spbase = tcb->spend =
	tcb->emptyList = tcb->ppsw = 0;
	return((BNRP_TCB *)tcb);
	}
#endif

#ifdef ring0
int BNRP_initializeTCB(
	BNRP_TCB *tcb,
	const char *name,
	long heap_trailSize,
	long env_cpSize)
{
	int res;

	res = BNRP_initializeTask((TCB *) tcb, heap_trailSize,env_cpSize,NULL);
	if(res EQ 0) ((TCB *)tcb)->taskName = BNRPLookupPermSymbol(name);
	return(res);
	}
#endif

#ifdef ring0
int BNRP_terminateTCB(BNRP_TCB *tcb)
{
	((TCB *)tcb)->validation = 0;
	BNRP_disposeMemory((TCB *)tcb);
	return(0);
	}
#endif

#ifdef ring0
int BNRP_disposeTCB(BNRP_TCB **tcb)
{
	((TCB *)tcb)->validation = 0;
        if (((TCB *)(*tcb))->heapbase NE 0) BNRP_disposeMemory((TCB *)*tcb);
	BNRP_free((void *)*tcb);
	*tcb = NULL;
	return(0);
	}
#endif

#ifdef ring4
int BNRP_bindPrimitive(
	const char *name,
	BNRP_Boolean (*procedure)())
{
	return(BNRPBindPrimitive(name, procedure) ? 0 : 1);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_unify(
	BNRP_TCB *tcb,
	BNRP_term term1,
	BNRP_term term2)
{
	return(unify((TCB *)tcb, term1, term2));
	}
#endif


/*		Storage reclamation aids										*/

#ifdef ring1
struct {
	clauseEntry c;
	long space;
	} BNRP_markClause = {0, 0, 0, 0, 0};
long BNRP_markFailure = 0;
	
#define BNRP_marker		0x12349876

void BNRP_markheap(
	BNRP_TCB *tcb,
	BNRP_mark *mark)
{
	register choicepoint *newcp;
	long criticalenv;
	
	/* create a new choicepoint if we have enough room */
	newcp = (choicepoint *)(((TCB *)tcb)->lcp - sizeof(choicepoint));
	if ((long)newcp LE ((TCB *)tcb)->cpend) return;

	/* figure out end of the env stack */
	criticalenv = (((TCB *)tcb)->lcp EQ ((TCB *)tcb)->cpbase) 
				  ? ((TCB *)tcb)->envbase
				  : ((choicepoint *)(((TCB *)tcb)->lcp))->critical;
	if (((TCB *)tcb)->ce GT criticalenv) {
		unsigned char n;
		
		n = *(unsigned char *)((TCB *)tcb)->cp;		/* get save byte from caller */
		criticalenv = ((TCB *)tcb)->ce + ((n + 1) * sizeof(long));
		}
	if ((criticalenv + (4 * sizeof(long))) GT ((TCB *)tcb)->envend) return;
	
	/* fill in all the fields with existing values in the TCB */
	newcp->numRegs = 0;						/* arity */
	newcp->procname = BNRPmarkAtom;			/* name for tracing, etc.. */
	newcp->bcp = ((TCB *)tcb)->cp;
	newcp->bce = ((TCB *)tcb)->ce;
	newcp->te = ((TCB *)tcb)->te;
	newcp->lcp = (choicepoint *)((TCB *)tcb)->lcp;
	newcp->hp = ((TCB *)tcb)->hp;
	newcp->key = 0;							/* match everything */
	newcp->clp = (long)&BNRP_markClause;
	newcp->critical = criticalenv;
	
	/* make sure that this clause has a break in it */
	BNRP_markFailure = (long)&BNRP_markClause + sizeof(clauseEntry);
	push(BYTE, BNRP_markFailure, 0x00);		/* neck */
	push(BYTE, BNRP_markFailure, 0x07);		/* break */
	push(BYTE, BNRP_markFailure, 0x00);
	/* BNRP_markFailure now points at where the ppc should be when we fail */
	/* make the clause loop to itself, so that it can never be removed */
	/* except by BNRP_releaseheap */
	BNRP_markClause.c.nextClause = BNRP_markClause.c.nextSameKeyClause = &BNRP_markClause.c;

	/* create a looped environment so that named cuts don't jump across it */
	/* restoring the choicepoint will reset ce below this newly created one */
	push(long, criticalenv, 0);				/* procname */
	push(long, criticalenv, (long)newcp);	/* set up CUTB */
	push(long, criticalenv, criticalenv+sizeof(long));	/* set up CE to point at itself */
	*(long *)criticalenv = ((TCB *)tcb)->cp;
	((TCB *)tcb)->ce = criticalenv;

	/* keep track of this choicepoint and the te for use in release */
	mark->data[0] = BNRP_marker;
	mark->data[1] = (long)newcp;
	mark->data[2] = ((TCB *)tcb)->te;
	mark->data[3] = ((TCB *)tcb)->procname;
	mark->data[4] = ((((TCB *)tcb)->ppsw & isolateFlags) EQ 0) ? ((TCB *)tcb)->ppc : -1;
	
	/* update registers to point at new dummy choicepoint */
	((TCB *)tcb)->lcp = ((TCB *)tcb)->cutb = (long)newcp;
	}
	
void BNRP_releaseheap(
	BNRP_TCB *tcb,
	BNRP_mark *mark)
{
	if (mark->data[0] EQ BNRP_marker) {
		if (mark->data[1] GE ((TCB *)tcb)->lcp) {
			choicepoint *x = (choicepoint *)mark->data[1];
		
			((TCB *)tcb)->hp = x->hp;
			((TCB *)tcb)->ce = x->bce;
			((TCB *)tcb)->cp = x->bcp;
			((TCB *)tcb)->cutb = ((TCB *)tcb)->lcp = (long)x->lcp;
			}
		while (((TCB *)tcb)->te LT mark->data[2]) {
			long addr;
			
			rpop(long, ((TCB *)tcb)->te, addr);
			rpop(long, ((TCB *)tcb)->te, *(long *)addr);
			}
		((TCB *)tcb)->te = mark->data[2];
		((TCB *)tcb)->procname = mark->data[3];
		if (mark->data[4] EQ -1) {
			((TCB *)tcb)->ppc = 0;
			((TCB *)tcb)->ppsw |= isolateFlags;		/* mark as unexecutable */
			}
		else {
			((TCB *)tcb)->ppc = mark->data[4];		/* reset ppc */
			((TCB *)tcb)->ppsw = bodyMode;			/* allow execution to continue */
			}
		BNRP_cleanupTempSymbols();
		mark->data[0] = 0;
		}
	else
		fprintf(stderr, "Attempt to BNRP_releaseheap to an invalid mark\n");
	}
#endif

/*		Execution procedures										*/

#ifdef ring1
int BNRP_execute(
	BNRP_TCB *tcb,
	BNRP_term term)
{
	TCB *t;
	long freePtr;
	int result;
	
	t = (TCB *)tcb;
	t->ppsw = bodyMode;
	/*t->ppc = freePtr = t->freePtr;*/
	freePtr = t->freePtr;
#ifdef HSC
	t->ppc = freePtr-1;
#else
	t->ppc = freePtr;
#endif
	push(BYTE, freePtr, 0x07);			/* call indirect */
	push(BYTE, freePtr, 0x09);
	push(BYTE, freePtr, 0x00);
	push(BYTE, freePtr, 0x07);			/* break */
	push(BYTE, freePtr, 0x00);
	push(BYTE, freePtr, 0x07);			/* fail */
	push(BYTE, freePtr, 0x0F);
	tcb->args[1] = term;
	if ((t->lcp NE t->cpbase) && (((choicepoint *)t->lcp)->clp EQ (long)&BNRP_markClause)) {
		/* update te so execution failures don't remove temp symbols */
		/* until the appropriate releaseheap is done */
		((choicepoint *)t->lcp)->te = t->te;
		}

#ifdef HSC
	oldSigIntHandler = BNRP_installSighandler(SIGINT, BNRP_initSighandler(abortHandler));
	oldSigFpeHandler = BNRP_installSighandler(SIGFPE, BNRP_initSighandler(arithHandler));
#endif

	result = BNRP_RESUME(t);

#ifdef HSC
	BNRP_installSighandler(SIGINT,oldSigIntHandler); /* Modified Oz 08/12/95 */
	BNRP_installSighandler(SIGFPE,oldSigFpeHandler); /* Modified Oz 08/12/95 */
#endif

	t->ppsw &= ~isolateFlags;

#ifdef HSC
	if ((result EQ 0) && ((t->ppc+1) EQ BNRP_markFailure)) {
#else
	if ((result EQ 0) && (t->ppc EQ BNRP_markFailure)) {
#endif
		result = OUTOFCHOICEPOINTS;
		t->ppsw = isolateFlags | result;		/* mark as non-executable */
		}
	return(result);
	}
#endif

#ifdef ring1
int BNRP_executeOnce(
	BNRP_TCB *tcb,
	BNRP_term term)
{
	TCB *t;
	long opcode[8], freePtr;
	int result;
	
	t = (TCB *)tcb;
	t->ppsw = bodyMode;
	/* t->ppc = freePtr = (long)&opcode; */
	freePtr = (long)&opcode;
#ifdef HSC
	t->ppc = freePtr-1;
#else
	t->ppc = freePtr;
#endif
	push(BYTE, freePtr, 0x07);			/* call indirect */
	push(BYTE, freePtr, 0x09);
	push(BYTE, freePtr, 0x00);
	push(BYTE, freePtr, 0x07);			/* ! */
	push(BYTE, freePtr, 0x02);
	push(BYTE, freePtr, 0x07);			/* break */
	push(BYTE, freePtr, 0x00);
	push(BYTE, freePtr, 0x07);			/* fail */
	push(BYTE, freePtr, 0x0F);
	tcb->args[1] = term;
	if ((t->lcp NE t->cpbase) && (((choicepoint *)t->lcp)->clp EQ (long)&BNRP_markClause)) {
		/* update te so execution failures don't remove temp symbols */
		/* until the appropriate releaseheap is done */
		((choicepoint *)t->lcp)->te = t->te;
		}

#ifdef HSC
	oldSigIntHandler = BNRP_installSighandler(SIGINT, BNRP_initSighandler(abortHandler));
	oldSigFpeHandler = BNRP_installSighandler(SIGFPE, BNRP_initSighandler(arithHandler));
#endif

	result = BNRP_RESUME(t);

#ifdef HSC
	BNRP_installSighandler(SIGINT,oldSigIntHandler); /* Modified Oz 08/12/95 */
	BNRP_installSighandler(SIGFPE,oldSigFpeHandler); /* Modified Oz 08/12/95 */
#endif

#ifdef HSC
	if ((result EQ 0) && ((t->ppc+1) EQ BNRP_markFailure)) {
#else
	if ((result EQ 0) && (t->ppc EQ BNRP_markFailure)) {
#endif
		result = OUTOFCHOICEPOINTS;
		t->ppsw = isolateFlags | result;	/* mark as non-executable */
		}
	else
		t->ppsw |= isolateFlags;			/* mark as non-executable */
	return(result);
	}
#endif

#ifdef ring1
int BNRP_executeNext(
	BNRP_TCB *tcb)
{
	TCB *t;
	int result;
	
	t = (TCB *)tcb;
	if (t->ppsw & isolateFlags NE 0) {
		t->ppsw &= ~isolateResult;
		t->ppsw |= OUTOFCHOICEPOINTS & isolateResult;
		result = OUTOFCHOICEPOINTS;
		}
	else {
#ifdef HSC
                oldSigIntHandler = BNRP_installSighandler(SIGINT, BNRP_initSighandler(abortHandler));
                oldSigFpeHandler = BNRP_installSighandler(SIGFPE, BNRP_initSighandler(arithHandler));
#endif

                result = BNRP_RESUME(t);

#ifdef HSC
                BNRP_installSighandler(SIGINT,oldSigIntHandler); /* Modified Oz 08/12/95 */
                BNRP_installSighandler(SIGFPE,oldSigFpeHandler); /* Modified Oz 08/12/95 */
#endif

#ifdef HSC
	if ((result EQ 0) && ((t->ppc+1) EQ BNRP_markFailure)) {
#else
	if ((result EQ 0) && (t->ppc EQ BNRP_markFailure)) {
#endif
			result = OUTOFCHOICEPOINTS;
			t->ppsw = isolateFlags | result;	/* mark as non-executable */
			}
		}
	return(result);
	}
#endif

#ifdef ring2
BNRP_term BNRP_makeVar(
	BNRP_TCB *tcb)
{
	long res, hp;
	
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(1);           /* Feb. 95 Jason Harris */
	push(long, hp, res = makevarterm(hp));
	((TCB *)tcb)->hp = hp;
	return(res);
	}
#endif

#ifdef ring2
BNRP_term BNRP_makeTailvar(
	BNRP_TCB *tcb)
{
	long res, hp;
	
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(1);           /* Feb. 95 Jason Harris */
	push(long, hp, res = maketerm(TVTAG, hp));
	((TCB *)tcb)->hp = hp;
	return(res);
	}
#endif

#ifdef ring2
BNRP_term BNRP_makeInteger(
	BNRP_TCB *tcb,
	long int l)
{
	return(makeint(&((TCB *)tcb)->hp, l));
	}
#endif

#ifdef ring2
BNRP_term BNRP_makeFloat(
	BNRP_TCB *tcb,
	double d)
{
	fp t;
	
	t = d;
	return(makefloat(&((TCB *)tcb)->hp, &t));
	}
#endif

#ifdef ring2
BNRP_term BNRP_makeSymbol(
	BNRP_TCB *tcb,
	const char *s)
{
	return(BNRPLookupTempSymbol((TCB *)tcb, s));
	}
#endif

#ifdef ring2
BNRP_term BNRP_makePermSymbol(const char *s)
{
	return(BNRPLookupPermSymbol(s));
	}
#endif

#ifdef ring2  /* added by Oz, April 95 */
BNRP_term BNRP_makeTerm(
	BNRP_TCB *tcb, 
	const char * s)
{
	BNRP_term result;
	
	if ((result = BNRP_makeTermFromString((TCB *)tcb, s)) EQ (BNRP_term)0)
		return(BNRP_makeSymbol(tcb, s));
	else
		return(result);
	}
#endif

#ifdef ring2  /* added by Oz, July 96 */
BNRP_Boolean BNRP_termToString( BNRP_TCB  *tcb,
                                BNRP_term  term,
                                char      *buffer,
                                long       buflen)
{
    return BNRP_makeTermToString((TCB *)tcb, term, buffer, buflen);
}
#endif

#ifdef ring3
int BNRP_newContext(const char *name1, const char *name2)
{
	return(BNRPnewContext(BNRPLookupPermSymbol(name1), BNRPLookupPermSymbol(name2)) ? 0 : OUTOFMEMORY);
	}
#endif

#ifdef ring3	
int BNRP_loadFile(
	const char *filename)
{
	return(loadFile(filename));
	}
#endif

#ifdef ring5
BNRP_tag BNRP_getValue(
	BNRP_term term,
	BNRP_result *result)
{
	BNRP_term l;
	
	if ((l = term) EQ 0) return(BNRP_invalid);
	while (isVAR(l) || isTV(l)) {
		register long ll = *(long *)(addrof(l));
		if (l EQ ll) {					/* point to itself ?? */
			(*result).tval = l;
			return((tagof(l) EQ TVTAG) ? BNRP_tailvar : BNRP_var);
			}
		l = ll;
		}
	if (l EQ 0) return(BNRP_end);
	if (l & 0x40000000) {				/* bits 11.... */
		if (l & 0x20000000) {			/* bits 111... */
			(*result).sym.sval = nameof(l);
			(*result).sym.orig = l;
			return(BNRP_symbol);
#if SYMBOLMASK NE 0xE0000000
			error
#endif
			}
		else {							/* bits 110.. */
			li t;
			
			t.l = l;
			(*result).ival = t.i.b;
			return(BNRP_integer);
#if INTMASK NE 0xC0000000
			error
#endif
			}
		}
	else {								/* bits 10.... */
		if (l & 0x20000000) {			/* bits 101... */
			(*result).term.first = maketerm(TVTAG, addrof(l));
			return(BNRP_list);
#if LISTMASK NE 0xA0000000
			error
#endif
			}
		else {							/* bits 100... */
			long a;
			li t;
			BNRP_term b;
		
			a = addrof(l);
			get(long, a, t.l);
			if (t.i.a EQ NUMBERIDshort) {
				if (t.i.b EQ INTIDshort) {
					get(long, a, (*result).ival);
					return(BNRP_integer);
					}
				else {
					fpLWA(a);
					(*result).fval = *(fp *)a;
					return(BNRP_float);
					}
				}
			get(long, a, b);
/*			while (tagof(b) EQ VARMASK)
				b = derefVAR(b); */

			while (isVAR(b) || isTV(b)) {
			    register long bb = *(long *)(addrof(b));
			      if (b EQ bb) break;	/* point to itself ?? */
			    b = bb;
			 }

			(*result).term.first = maketerm(TVTAG, a);
			(*result).term.functor_term = b;  /* New from Oz 04/95 */
			if (isVAR(b))
			   (*result).term.functor = "_";
			else
			   (*result).term.functor = nameof(b);
			/* don't include functor name in arity call */
			(*result).term.arity = t.i.b + ((t.i.b GT 0) ? -1 : 1);
			return(BNRP_structure);
#if STRUCTMASK NE 0x80000000
			error
#endif
			}
		}
	}
#endif

#ifdef ring5
BNRP_tag BNRP_getIndexedValue(
	BNRP_term term,
	int position,
	BNRP_result *result)
{
	BNRP_term l, ll;

	l = 0;
	memset(result, 0, sizeof(BNRP_result));
	if ((ll = tagof(term)) EQ STRUCTTAG) {
		if (position LT 0) return(BNRP_invalid);
		term = addrof(term);
		get(long, term, l);			/* get header */
		get(long, term, l);			/* get functor */
		}
	else if ((ll EQ TVTAG) || (ll EQ LISTTAG)) {
		if (position LE 0) return(BNRP_invalid);
		term = addrof(term);
		}
	else 
		return(BNRP_invalid);
	while (--position GE 0) {
		get(long, term, l);
		/* if tailvariable then we must chase it */
		while (tagof(l) EQ TVTAG) {
			term = addrof(l);
			get(long, term, ll);
			if (l EQ ll) {			/* point to itself ?? */
				(*result).tval = ll;
				return((position EQ 0) ? BNRP_tailvar : BNRP_invalid);
				}
			l = ll;
			}
		if (l EQ 0) 				/* end of list prematurely ?? */
			return((position EQ 0) ? BNRP_end : BNRP_invalid);
		}

	while (tagof(l) EQ VARTAG) {
		register long ll = derefVAR(l);
		if (l EQ ll) {							/* unbound var ?? */
			(*result).tval = l;
			return(BNRP_var);
			}
		l = ll;
		}
		
	if (l & 0x40000000) {				/* bits 11.... */
		if (l & 0x20000000) {			/* bits 111... */
			(*result).sym.sval = nameof(l);
			(*result).sym.orig = l;
			return(BNRP_symbol);
#if SYMBOLMASK NE 0xE0000000
			error
#endif
			}
		else {							/* bits 110.. */
			li t;
			
			t.l = l;
			(*result).ival = t.i.b;
			return(BNRP_integer);
#if INTMASK NE 0xC0000000
			error
#endif
			}
		}
	else {								/* bits 10.... */
		if (l & 0x20000000) {			/* bits 101... */
			(*result).term.first = maketerm(TVTAG, addrof(l));
			return(BNRP_list);
#if LISTMASK NE 0xA0000000
			error
#endif
			}
		else {							/* bits 100... */
			long a;
			li t;
			BNRP_term b;
		
			a = addrof(l);
			get(long, a, t.l);
			if (t.i.a EQ NUMBERIDshort) {
				if (t.i.b EQ INTIDshort) {
					get(long, a, (*result).ival);
					return(BNRP_integer);
					}
				else {
					fpLWA(a);
					(*result).fval = *(fp *)a;
					return(BNRP_float);
					}
				}
			get(long, a, b);
			while (isVAR(b) || isTV(b)) {
			    register long bb = *(long *)(addrof(b));
			      if (b EQ bb) break;	/* point to itself ?? */
			    b = bb;
			 }

			(*result).term.first = maketerm(TVTAG, a);
			(*result).term.functor_term = b;  /* New from Oz 04/95 */
			if (isVAR(b))
			   (*result).term.functor = "_";
			else
			   (*result).term.functor = nameof(b);

			/* don't include functor name in arity call */
			(*result).term.arity = t.i.b + ((t.i.b GT 0) ? -1 : 1);
			return(BNRP_structure);
#if STRUCTMASK NE 0x80000000
			error
#endif
			}
		}
	}
#endif

#ifdef ring5
BNRP_tag BNRP_getNextValue(
	BNRP_term *term,
	BNRP_result *result)
{
	BNRP_term l, ll;
	
	memset(result, 0, sizeof(BNRP_result));
	if (tagof(*term) NE TVTAG) return(BNRP_invalid);
	*term = addrof(*term);
	get(long, *term, l);
	while (tagof(l) EQ TVTAG) {
		*term = addrof(l);
		get(long, *term, ll);
		if (l EQ ll) {					/* point to itself (unbound TV) ?? */
			(*result).tval = ll;
			*term = 0;					/* so next call returns invalid */
			return(BNRP_tailvar);
			}
		l = ll;
		}
	if (l EQ 0) {
		*term = 0;						/* so next call returns invalid */
		return(BNRP_end);
		}
	*term = maketerm(TVTAG, addrof(*term));
	while (tagof(l) EQ VARTAG) {
		register long ll = derefVAR(l);
		if (l EQ ll) {					/* point to itself ?? */
			(*result).tval = l;
			return(BNRP_var);
			}
		l = ll;
		}
	if (l & 0x40000000) {				/* bits 11.... */
		if (l & 0x20000000) {			/* bits 111... */
			(*result).sym.sval = nameof(l);
			(*result).sym.orig = l;
			return(BNRP_symbol);
#if SYMBOLMASK NE 0xE0000000
			error
#endif
			}
		else {							/* bits 110.. */
			li t;
			
			t.l = l;
			(*result).ival = t.i.b;
			return(BNRP_integer);
#if INTMASK NE 0xC0000000
			error
#endif
			}
		}
	else {								/* bits 10.... */
		if (l & 0x20000000) {			/* bits 101... */
			(*result).term.first = maketerm(TVTAG, addrof(l));
			return(BNRP_list);
#if LISTMASK NE 0xA0000000
			error
#endif
			}
		else {							/* bits 100... */
			long a;
			li t;
			BNRP_term b;
		
			a = addrof(l);
			get(long, a, t.l);
			if (t.i.a EQ NUMBERIDshort) {
				if (t.i.b EQ INTIDshort) {
					get(long, a, (*result).ival);
					return(BNRP_integer);
					}
				else {
					fpLWA(a);
					(*result).fval = *(fp *)a;
					return(BNRP_float);
					}
				}
			get(long, a, b);

			while (isVAR(b) || isTV(b)) {
			    register long bb = *(long *)(addrof(b));
			      if (b EQ bb) break;	/* point to itself ?? */
			    b = bb;
			 }

			(*result).term.first = maketerm(TVTAG, a);
			(*result).term.functor_term = b;  /* New from Oz 04/95 */
			if (isVAR(b))
			   (*result).term.functor = "_";
			else
			   (*result).term.functor = nameof(b);

			/* don't include functor name in arity call */
			(*result).term.arity = t.i.b + ((t.i.b GT 0) ? -1 : 1);
			return(BNRP_structure);
#if STRUCTMASK NE 0x80000000
			error
#endif
			}
		}
	}
#endif

#ifdef ring5
BNRP_term BNRP_getIndexedTerm(
	BNRP_term term,
	int position)
{
	BNRP_term l, ll;

	l = 0;
	if ((ll = tagof(term)) EQ STRUCTTAG) {
		if (position LT 0) return(0);
		term = addrof(term);
		get(long, term, l);			/* get header */
		get(long, term, l);			/* get functor */
		}
	else if ((ll EQ TVTAG) || (ll EQ LISTTAG)) {
		if (position LE 0) return(0);
		term = addrof(term);
		}
	else 
		return(0);
	while (--position GE 0) {
		get(long, term, l);
		/* if tailvariable then we must chase it */
		while (tagof(l) EQ TVTAG) {
			term = addrof(l);
			get(long, term, ll);
			if (l EQ ll)						/* point to itself ?? */
				return((position EQ 0) ? l : 0);
			l = ll;
			}
		if (l EQ 0) return(0);					/* end of list prematurely ?? */
		}

	while (tagof(l) EQ VARTAG) {
		register long ll = derefVAR(l);
		if (l EQ ll) break;						/* unbound var ?? */
		l = ll;
		}
	return(l);
	}
#endif

#ifdef ring5
BNRP_term BNRP_getNextTerm(
	BNRP_term *term)
{
	BNRP_term l, ll;
	
	if (tagof(*term) NE TVTAG) return(0);
	*term = addrof(*term);
	get(long, *term, l);
	while (tagof(l) EQ TVTAG) {
		*term = addrof(l);
		get(long, *term, ll);
		if (l EQ ll) {						/* unbound TV ?? */
			*term = 0;						/* so next call returns invalid */
			return(ll);						/* return TV */
			}
		l = ll;
		}
	if (l EQ 0) {							/* end of list ?? */
		*term = 0;							/* so next call returns invalid */
		return(0);							/* return end */
		}
	*term = maketerm(TVTAG, addrof(*term));
	while (tagof(l) EQ VARTAG) {
		register long ll = derefVAR(l);
		if (l EQ ll) break;					/* point to itself ?? */
		l = ll;
		}
	return(l);
	}
#endif

#ifdef ring6
BNRP_term BNRP_makeList(
	BNRP_TCB *tcb,
	long arity,
	...)					/* actually any number of BNRP_term's */
{
	long res, hp;
	va_list ap;
	
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(arity + 1);                   /* Feb. 95 Jason Harris */
	res = maketerm(LISTTAG, hp);
	va_start(ap, arity);
	while (arity GT 0) {
		push(BNRP_term, hp, va_arg(ap, BNRP_term));
		--arity;
		}
	va_end(ap);
	push(long, hp, 0L);
	((TCB *)tcb)->hp = hp;
	return(res);
	}
#endif

#ifdef ring6
BNRP_term BNRP_makeStructure(
	BNRP_TCB *tcb,
	const char *name,
	long arity,
	...)					/* actually any number of BNRP_term's */
{
	long start, hp;
	va_list ap;
	li header;
	BNRP_term t, a;

	 if(name EQ NULL)
	    a = BNRP_makeVar(tcb);
	 else	
	   a = BNRPLookupTempSymbol((TCB *)tcb, name);
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(arity + 3);                 /* Feb. 95 Jason Harris */
	start = hp;
	header.l = STRUCTHEADER + 1;	/* include functor in count */
	push(long, hp, header.l);
	push(BNRP_term, hp, a);
	va_start(ap, arity);
	while (arity GT 0) {
		t = va_arg(ap, BNRP_term);
		push(BNRP_term, hp, t);
		++header.i.b;
		--arity;
		}
	va_end(ap);
	push(long, hp, 0L);
	if (tagof(t) EQ TVTAG) header.i.b = -header.i.b;
	*(long *)start = header.l;		/* update header with arity */
	((TCB *)tcb)->hp = hp;
	return(maketerm(STRUCTTAG, start));
	}
#endif

#ifdef ring6
BNRP_term BNRP_startList(
	BNRP_TCB *tcb)
{
	long hp, res;
	
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(1);                  /* Feb. 95 Jason Harris */
	res = maketerm(LISTTAG, hp);
	push(long, hp, 0L);
	((TCB *)tcb)->hp = hp;
	return(res);
	}
#endif

#ifdef ring6
BNRP_term BNRP_startStructure(
	BNRP_TCB *tcb,
	const char *name)
{
	long res, hp;
	BNRP_term a;

	 if(name EQ NULL)
	    a = BNRP_makeVar(tcb);
	 else	
	    a = BNRPLookupTempSymbol((TCB *)tcb, name);
	hp = ((TCB *)tcb)->hp;
	headerLWA(hp);
	heapcheck(3);                /* Feb. 95 Jason Harris */
	res = maketerm(STRUCTTAG, hp);
	push(long, hp, STRUCTHEADER + 1);		/* include functor in count */
	push(BNRP_term, hp, a);
	push(long, hp, 0L);
	((TCB *)tcb)->hp = hp;
	return(res);
	}
#endif

#ifdef ring6
BNRP_term BNRP_startStructureAtom(      /* startStructure variant */
        BNRP_TCB *tcb,
        BNRP_term a)
{
        long res, hp;

	if((tagof(a) NE SYMBOLTAG) && (tagof(a) NE VARTAG)) return((BNRP_term)NULL);
        hp = ((TCB *)tcb)->hp;
        headerLWA(hp);
        heapcheck(3);                /* Feb. 95 Jason Harris */
        res = maketerm(STRUCTTAG, hp);
        push(long, hp, STRUCTHEADER + 1); /* include functor in count */
        push(BNRP_term, hp, a);
        push(long, hp, 0L);
        ((TCB *)tcb)->hp = hp;
        return(res);
        }
#endif

#ifdef ring6
BNRP_Boolean BNRP_addTerm(
	BNRP_TCB *tcb,
	BNRP_term term, 
	BNRP_term newTerm)
{
	long hp, start, *addr = NULL;
	li header;
	BNRP_term t;
	BNRP_Boolean fixup = FALSE;
	
	start = addrof(term);
	if ((t = tagof(term)) EQ STRUCTTAG) {
		header.l = *(long *)start;
		if (header.i.b GE 0) {
			++header.i.b;
			addr = (long *)start;
			*addr = header.l;
			start += (header.i.b * sizeof(BNRP_term));		/* index to end */
			}
		else {			/* header already contains a TV, arity < 0 */
			start -= (header.i.b * sizeof(BNRP_term));		/* index to end */
			}
		}
	else if (t NE LISTTAG)
		return(FALSE);
	
	while ((t = *(long *)start) NE 0) {
		if (tagof(t) EQ TVTAG) {
			start = addrof(t);
			if (*(long *)start EQ t) return(FALSE);			/* unbound TV */
			}
		else
			start += sizeof(BNRP_term);
		}
		
	if (tagof(newTerm) EQ TVTAG) {
		*(long *)start = newTerm;
		fixup = (addr NE NULL);
		}
	else {				/* need to add two cells, see if at end of heap already */
		hp = ((TCB *)tcb)->hp;
		constantLWA(hp);
		heapcheck(2);                /* Feb. 95 Jason Harris */
		if (start EQ hp-sizeof(BNRP_term)) {
			*(long *)start = newTerm;
			}
		else {
			*(long *)start = maketerm(TVTAG, hp);
			fixup = (addr NE NULL);
			push(long, hp, newTerm);
			}
		push(long, hp, 0L);
		((TCB *)tcb)->hp = hp;
		}
	if (fixup) {
		header.i.b = -header.i.b;
		*addr = header.l;
		}
	return(TRUE);
	}
#endif

#ifdef ring6
BNRP_term BNRP_buildStructure(
	BNRP_TCB  *tcb,
	const char      *name,                       /* functor name      */
	long       arity,                           /* list arity        */
    BNRP_term *terms)                           /* array of terms    */
{
    BNRP_term a;                                /* for functor name  */
    long      hp;                               /* local hp register */
    long      start;                            /* start location    */
	li        header;                           /* struct header     */
    int       i;                                /* temporary var     */
	
    if (arity LT 0)
        arity = 0;                              /* empty structure          */

      if(name EQ NULL)
	 a = BNRP_makeVar(tcb);
      else
	 a = BNRPLookupTempSymbol((TCB *)tcb, name); /* functor name             */

	hp = ((TCB *)tcb)->hp;                      /* local hp register        */
	headerLWA(hp);                              /* header alignment         */
	heapcheck(arity + 3);                       /* enough heap space ?      */

	start = hp;                                 /* save the start location  */
	header.l = STRUCTHEADER + 1 + arity;        /* include functor in count */
	push(long, hp, header.l);                   /* STRUCTHEADER | arity+1   */

	push(BNRP_term, hp, a);                     /* functor                  */
    for (i=0; i<arity; i++) {
        push(BNRP_term, hp, terms[i]);          /* terms[i]                 */
    }
	push(long, hp, 0L);                         /* end of structure          */

    if (arity) {
        if (tagof(terms[arity-1]) EQ TVTAG) {   /* the last term is a TV     */
            header.i.b = -header.i.b;
            *(long *)start = header.l;          /* STRUCTHEADER | -(arity+1) */
        }
    }
            
	((TCB *)tcb)->hp = hp;                      /* update global hp register */
	return(maketerm(STRUCTTAG, start));
}
#endif

#ifdef ring6
BNRP_term BNRP_buildList(
	BNRP_TCB  *tcb,                             /* Task Control Block        */
	long       arity,                           /* arity                     */
    BNRP_term *terms)                           /* array of terms            */
{
    long      hp;                               /* local hp register copy    */
    BNRP_term listerm;                          /* result list term          */
    int       i;

    if (arity LT 0)
        arity = 0;                              /* negative arity is ignored */

	hp = ((TCB *)tcb)->hp;                      /* local hp copy                 */
	headerLWA(hp);                              /* header alignment              */
	heapcheck(arity + 1);                       /* enough heap space available ? */
	listerm = maketerm(LISTTAG, hp);            /* result list term              */

	for (i=0; i<arity; i++) {
		push(BNRP_term, hp, terms[i]);          /* terms[i]                      */
    }
	push(long, hp, 0L);                         /* end of list                   */

	((TCB *)tcb)->hp = hp;                      /* update global hp register     */
	return(listerm);
}
#endif

#ifdef ring6
void BNRP_primitiveName(BNRP_TCB *tcb, char * nameBuffer)
{
      /* Copy contents of tcb->procname into nameBuffer */
      if(((TCB *)tcb)->procname EQ 0)
	 nameBuffer[0] = '\0';
      else
	 strcpy(nameBuffer, nameof(((TCB *)tcb)->procname));
}
#endif

#ifdef ring6
BNRP_Boolean BNRP_listLength(BNRP_term list, long * length)
{
   long l = list;
   long * next;
   long size=0;


   /* Dereference list */
   while (isVAR(l) || isTV(l))
   {
      register long ll = *(long *)(addrof(l));
      if (l EQ ll)
	 return(FALSE);
      l = ll;
   }

   /* Check to see if derefed term is a list */
   if(tagof(l) NE LISTTAG)
      return(FALSE);

   /* Get address of list */
   next = (long *)addrof(l);

   /* Repeat until we hit the end of the list */
   while(*next NE 0)
   {
      size++;

      /* Chase down tail variables */
      while(tagof(*next) == TVTAG)
      {
	 l  = addrof(*next);
	 if((long)next == l)	/* Unbound tailvar */
	 {
	    /*size--;*/
	    *length = 0-size;
	    return(TRUE);
	 }
	 next = (long *)l;
      }
      ++next;
   }

   *length = size;
   return(TRUE);
}
#endif

#ifdef ring6

extern BNRP_Boolean handleFileIO(short selector, long printFile, ...);
extern BNRP_Boolean BNRP_printQuotes;
extern BNRP_Boolean BNRP_printCommas;
extern BNRP_Boolean BNRP_printBlanks;
extern BNRP_Boolean BNRP_printIntervals;
extern long BNRP_printCount;
extern jmp_buf BNRP_printEnv;

void BNRP_dumpTerm(FILE *file, BNRP_term term)
{
   long result = 0;

   /* set up AM for printing */
   clearAM();

   /* Set file location */
   BNRP_fileIndex = (long)file;
   BNRP_printProc = handleFileIO;
   BNRP_printCount = 0;
   BNRP_printLen = BNRP_getMaxLong();

   /* set options (same as writeq) */
   BNRP_printQuotes = TRUE;
   BNRP_printCommas = FALSE;
   BNRP_printBlanks = FALSE;
   BNRP_printIntervals = FALSE;

   /* Handle any errors */
   if(result = setjmp(BNRP_printEnv))
   {
      /* Error occured */
      return;
   }

   /* Display the term */
   BNRP_displayValue(term, 1, 3000);

   /* Flush the file */
   (void)(*BNRP_printProc)(FLUSHFILE, BNRP_fileIndex);

   /* clean-up */
   freeAM();

   return;
}
#endif
