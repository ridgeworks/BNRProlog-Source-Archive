/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/context.c,v 1.5 1997/08/12 17:34:44 harrisj Exp $
 *
 * $Log: context.c,v $
 * Revision 1.5  1997/08/12  17:34:44  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.4  1996/07/08  10:24:56  yanzhou
 * The logic inside BNRP_makeTempGlobalSymbolPermanent()
 * was not correct.  Now fixed.
 *
 * Revision 1.3  1996/07/05  10:45:56  yanzhou
 * Made the following changes to handle temporary symbols:
 *   1) when a clause is being inserted or added to a context,
 *      the predicate name of the clause is now made permanent.
 *   2) before a new context is created, the temporary global
 *      symbols in the current top-most context are unconditionally
 *      made permanent first.
 *
 * Revision 1.2  1996/04/10  16:00:15  yanzhou
 * FIX:  contextTrail was allowing duplicate undoRecord entries
 *       to be added to the trail chain.  Now fixed.
 *
 * Revision 1.1  1995/09/22  11:23:35  harrisja
 * Initial version.
 *
 */
#include <stddef.h>
#include <stdio.h>
#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "context.h"
#include "hash.h"
#include "prim.h"
#include "state.h"
#include "utility.h"
#include "interpreter.h"
#include "hardware.h"
#include <string.h>		/* for memcpy */

/* #define trace	1 */
/* #define check */
/* #define trace_contexttrail */

#ifdef macintosh
#define DEBUGSTR(s)		DebugStr("\p" s)
#else
#define DEBUGSTR(s)		*(long *)NULL
#endif

typedef struct freeRecord freeRecord;
struct freeRecord {
	long size;						/* size of free block */
	freeRecord *next;				/* next free record in block */
	};
	
typedef struct undoRecord undoRecord;
struct undoRecord {
	long addr;						/* address to be trailed */
	long mask;						/* to isolate only the bits that changed */
	long oldvalue;					/* original value */
	undoRecord *next;				/* next record in chain */
	};
	
typedef struct contextSpace contextSpace;
typedef struct contextHeader contextHeader;

struct contextSpace {
	contextHeader *context;			/* really contextHeader * */
	contextSpace *next;				/* next chunk allocated to this context */
	contextSpace *self;
	long size;						/* size of allocation */
	freeRecord *freep;				/* first free space in this chunk */
	};
	
struct contextHeader {
	long ident1;					/* two atoms for the name of the context */
	long ident2;
	contextHeader *self;
	long generation;				/* used to order state spaces */
	symbolEntry *permSymbols[PERMTABLEMODULUS];
	symbolEntry *localSymbols;
	symbolEntry *tempPermSymbols;
	symbolEntry *tempLocalSymbols;
	contextSpace *firstSpace;		/* first chunk of memory for context */
	contextHeader *prevContext;		/* pointer to previous context */
	undoRecord *undoChain;			/* chain of undo records */
	};

struct spaceHeader {
	contextSpace *space;
	long size;
	};
typedef struct spaceHeader spaceHeader;

#ifdef ring0
contextHeader baseContext,
			  *topContext = NULL,
			  *currContext = NULL;
size_t incrementBase;
long contextGeneration = 0;
#else
extern contextHeader baseContext, *topContext, *currContext;
extern size_t incrementBase;
extern long contextGeneration;
#endif

#ifdef check
extern TCB tcb;
#endif

#ifdef ring0
void *allocSpaceInContext(contextHeader *c, size_t size)
{
	contextSpace *s;
	freeRecord *f, *p;
	size_t minsize;
	long rem;
	spaceHeader *x;
	
	/* round to longword */
	size = (size + sizeof(spaceHeader) + headerAlignment - 1) & -headerAlignment;
	s = c->firstSpace;
	while (s NE NULL) {
		if (s->self NE s) BNRP_error(DANGLINGREFERENCE);
		f = s->freep;
		p = NULL;
		while (f NE NULL) {
			rem = f->size - size;
			if (rem EQ 0) {			/* exact fit */
				if (p EQ NULL) 
					s->freep = f->next;
				else
					p->next = f->next;
				x = (spaceHeader *)f;
				x->space = s;
				x->size = size;
#ifdef trace
				printf("Allocating new chunk @ %p, size %ld\n", (long)x + sizeof(spaceHeader), size);
#endif
#ifdef check
				if (((long)x GE tcb.heapbase) && ((long)x LT tcb.cpbase))
					DEBUGSTR("new chunk in heap1");
#endif
				return((void *)((long)x + sizeof(spaceHeader)));
				}
			if (rem GT (long)sizeof(freeRecord)) {		/* room left over */
				f->size -= size;
				x = (spaceHeader *)((long)f + f->size);
				x->space = s;
				x->size = size;
#ifdef trace
				printf("Allocating new chunk @ %p, size %ld\n", (long)x + sizeof(spaceHeader), size);
#endif
#ifdef check
				if (((long)x GE tcb.heapbase) && ((long)x LT tcb.cpbase))
					DEBUGSTR("new chunk in heap2");
#endif
				return((void *)((long)x + sizeof(spaceHeader)));
				}
			p = f;
			f = f->next;
			}
		s = s->next;
		}
	/* not enough available space, need a new chunk */
	minsize = size + sizeof(contextSpace);
	if (minsize LT incrementBase) {
		if ((s = (contextSpace *)BNRP_malloc(incrementBase)) EQ NULL) 
			return(NULL);
#ifdef trace
		printf("Allocating new block @ %p, size %ld\n", s, incrementBase);
#endif
		s->size = incrementBase;
		f = (freeRecord *)((long)s + minsize);
		f->size = incrementBase - minsize;
		f->next = NULL;
		s->freep = f;
		}
	else {
		if ((s = (contextSpace *)BNRP_malloc(minsize)) EQ NULL) return(NULL);
#ifdef trace
		printf("Allocating new block @ %p, size %ld\n", s, minsize);
#endif
		s->size = minsize;
		s->freep = NULL;
		}
	s->context = c;
	s->next = c->firstSpace;
	c->firstSpace = s;
	s->self = s;
	x = (spaceHeader *)((long)s + sizeof(contextSpace));
	x->space = s;
	x->size = size;
#ifdef trace
	printf("Allocating new chunk @ %p, size %ld\n", (long)x + sizeof(spaceHeader), size);
#endif
#ifdef check
	if (((long)x GE tcb.heapbase) && ((long)x LT tcb.cpbase))
		DEBUGSTR("new chunk in heap3");
#endif
	return((void *)((long)x + sizeof(spaceHeader)));
	}
#endif

#ifdef ring0
void deallocSpaceInContext(void *it)
{
	contextSpace *s;
	freeRecord *x, *n, *p;
	long size;
	
	x = (freeRecord *)((long)it - sizeof(spaceHeader));
	s = ((spaceHeader *)x)->space;
	if (s->self NE s) BNRP_error(DANGLINGREFERENCE);
	if ((size = ((spaceHeader *)x)->size) GT s->size) return;
	if (size EQ 0) return;
#ifdef trace
	printf("Deallocating chuck @ %p, size %ld\n", it, size);
#endif
	/* found the block containing it */
	if ((n = s->freep) EQ NULL) {
		s->freep = x;
		x->size = size;
		x->next = NULL;
		return;
		}
	if ((long)x LT (long)n) {		/* new free block at front */
		x->next = n;
		s->freep = x;
		}
	else {
		p = NULL;
		while ((long)n LT (long)x) {
			p = n;
			if ((n = n->next) EQ NULL) break;
			}
	
		/* combine with previous if possible */
		if (((long)p + p->size) EQ (long)x) {
			size += p->size;
			x = p;
			}
		else
			p->next = x;
		}
	x->size = size;

	/* combine with next if possible */
	if (((long)x + size) EQ (long)n) {
		x->size += n->size;
		x->next = n->next;
		}
	else
		x->next = n;
	return;
	}
#endif

#ifdef ring0
BNRP_term BNRPMakePermInt(long value)
{
	short i;
	struct longheader{
		long header;
		long value;
		} *x;
	
	i = value;
	if (value EQ i)
		return(makeintterm(value & 0x0000FFFF));
	/* number bigger than 16 bits */
	x = (struct longheader *)allocSpaceInContext(currContext, sizeof(struct longheader));
	if (x EQ NULL) BNRP_error(CONTEXTFULL);
	x->header = INTID;
	x->value = value;
	return(maketerm(STRUCTTAG, (long)x));
	}
#endif

#ifdef ring0
BNRP_term BNRPMakePermFloat(fp *value)
{
	long x, y;
	/* cannot use struct { long, fp } since Sparc C compiler */
	/* will align fp on an 8 byte boundary, wasting a long */
	/* and causing problems in the arithmetic stuff */

#ifdef fpAlignment	
	x = y = (long)allocSpaceInContext(currContext, fpAlignment+fpAlignment);
#else
	x = y = (long)allocSpaceInContext(currContext, sizeof(fp)+sizeof(long));
#endif
	if (x EQ (long)NULL) BNRP_error(CONTEXTFULL);
	push(long, x, FLOATID);
	fpLWA(x);
	*(lf *)x = *(lf *)value;
	if (sizeof(fp) EQ 10) { 
		*(short *)(x + sizeof(fp)) = 0;
		}
	return(maketerm(STRUCTTAG, y));
	}
#endif

#ifdef ring0
symbolEntry *newSymbol(contextHeader *c, const char *s, unsigned char h)
{
	symbolEntry *sym;
	
	if ((sym = (symbolEntry *)allocSpaceInContext(c, strlen(s) + sizeof(symbolEntry))) EQ NULL) 
		return(NULL);
#ifdef trace
	printf("Adding new symbol %s\n", s);
#endif
	sym->firstClause = NULL;
	sym->chain = NULL;
	sym->self = sym;
	sym->opType = notOp;
	sym->opPrecedence = 0;
	sym->locked = sym->closed = 0;
	sym->debug = 0;
	sym->inuse = INUSE;
	sym->hash = h;
	strcpy(sym->name, s);
	return(sym);
	}
#endif

#ifdef ring0
void contextTrail(void *addr, long mask, contextHeader *p)
{
	undoRecord *u;
	
#ifdef check
	if (((long)addr GE tcb.heapbase) && ((long)addr LT tcb.cpbase))
		DEBUGSTR("bad trailing address");
#endif

    /*
     * NEW: 27/03/96 by yanzhou@bnr.ca
     * AIM: to avoid duplicate undoRecord entries
     * 
     *   Check to see if there has already existed an undoRecord that
     *   trails the same address and mask values.  If such an
     *   undoRecord exists, then there is no need to do any thing.
     *
     * BEGIN patch
     */
    u = p->undoChain;
    while (u) {
        if ((u->addr == (long)addr) && (u->mask == ~mask)) {
#ifdef trace_contexttrail
            printf("contextTrail: undoRecord{addr=0x%08x, mask=0x%08x} already exists.\n",
                   (long)addr, mask);
#endif
            return;
        }
        u = u->next;
    };
    /*
     * END patch
     */

	u = (undoRecord *)allocSpaceInContext(currContext, sizeof(undoRecord));
	if (u EQ (undoRecord *)NULL) BNRP_error(CONTEXTFULL);
	u->addr = (long)addr;
	u->mask = ~mask;
	u->oldvalue = *(long *)addr & mask;
	u->next = p->undoChain;
	p->undoChain = u;
#ifdef trace_contexttrail
    printf("contextTrail: new undoRecord{addr=0x%08x, mask=0x%08x} allocated.\n",
           (long)addr, mask);
#endif
}
#endif

#ifdef ring0
void initializeContexts()
{
	int i, h;
	symbolEntry *name;
	
	topContext = currContext = baseContext.self = &baseContext;
	for(i = 0; i LT PERMTABLEMODULUS; ++i)
		baseContext.permSymbols[i] = NULL;
	baseContext.localSymbols = NULL;
	baseContext.tempPermSymbols = NULL;
	baseContext.tempLocalSymbols = NULL;
	baseContext.firstSpace = NULL;
	baseContext.prevContext = NULL;
	baseContext.undoChain = NULL;
	incrementBase = allocationSize;
	h = hashString("base") & (PERMTABLEMODULUS - 1);
	name = newSymbol(currContext, "base", h);
	name->chain = baseContext.permSymbols[h];
	baseContext.permSymbols[h] = name;
	baseContext.ident1 = baseContext.ident2 = maketerm(SYMBOLTAG, (long)name);
	baseContext.generation = contextGeneration = 0;
	}
#endif

#ifdef ring3
void BNRPSetBaseFileName(const char *s)
{
	int h;
	
	if (topContext EQ NULL) initializeContexts();
	h = hashString(s) & (PERMTABLEMODULUS - 1);
	baseContext.ident2 = BNRPMakeSymbol(h, s, PERMSYM, GLOBAL, NULL, 0);
	}
#endif

#ifdef ring3
static BNRP_Boolean BNRP_setContext(long name1, long name2)
{
	contextHeader *p;
	
	if ((p = topContext) EQ NULL) initializeContexts();
	while (p NE NULL) {
		if ((p->ident1 EQ name1) && (p->ident2 EQ name2)) {
			currContext = p;
			return(TRUE);
			}
		p = p->prevContext;
		}
	return(FALSE);
	}
#endif

#ifdef ring3
static void BNRP_makeTempGlobalSymbolPermanent(contextHeader *c)
    /*
     * makes all the temporary global symbols permanent
     */
{
    symbolEntry *prev, *this;
    this = c->tempPermSymbols;
    prev = NULL;
    while (this NE NULL) {
        if (this->inuse EQ INUSETEMPGLOBAL) {
            /* temporary global symbol */

            if (prev EQ NULL)
                c->tempPermSymbols = this->chain;
            else
                prev->chain = this->chain;
            this->chain = c->permSymbols[this->hash];
            c->permSymbols[this->hash] = this;
            this->inuse = INUSE;
        } else
            prev = this;
        if (prev EQ NULL)
            this = c->tempPermSymbols;
        else
            this = prev->chain;
    }
}
#endif

#ifdef ring3
BNRP_Boolean BNRPnewContext(long name1, long name2)
{
	contextHeader *p;
	
	if (BNRP_setContext(name1, name2)) return(FALSE);
	BNRP_makeSymbolPermanent(name1);
	BNRP_makeSymbolPermanent(name2);
    /*
     * yanzhou@bnr.ca:25/06/96:
     * Make all the temporary global symbols in the top-most context permanent
     *
     * Patch Begin
     */
    BNRP_makeTempGlobalSymbolPermanent(topContext);
    /*
     * Patch End
     */
	p = (contextHeader *)BNRP_malloc(sizeof(contextHeader));
	if (p EQ NULL) return(FALSE);
#ifdef trace
	printf("Allocating new header @ %p, size %ld\n", p, sizeof(contextHeader));
#endif

	memcpy(p, topContext, sizeof(contextHeader));
	p->ident1 = name1;
	p->ident2 = name2;
	p->self = p;
	p->generation = ++contextGeneration;
	p->tempPermSymbols = p->localSymbols = p->tempLocalSymbols = NULL;
	p->firstSpace = NULL;
	p->undoChain = NULL;
	p->prevContext = topContext;
	topContext = currContext = p;
#ifdef trace
	printf("New context %s %s\n", nameof(name1), nameof(name2));
#endif

	return(TRUE);
	}
#endif

#ifdef ring3
static BNRP_Boolean removeContext(TCB *tcb, long name1, long name2)
{
	static long waste;
	
	if (!BNRP_setContext(name1, name2)) return(FALSE);
	BNRP_removeStateSpaces(currContext->generation);
	currContext = currContext->prevContext;
	while (topContext NE currContext) {
		contextHeader *p;
		undoRecord *u;
		contextSpace *s;
		long ce;
		
		/* check top context for dangling references from choicepoints */
		choicepoint *lcp = (choicepoint *)tcb->lcp;
		while ((long)lcp NE tcb->cpbase) {
			if (lcp EQ (long)NULL) break;
			if ((lcp->clp NE (long)NULL) && (lcp->procname NE BNRPmarkAtom)) {			/* next clause ?? */
				freeRecord *x;
				contextSpace *s;
				contextHeader *context;
			/*	spaceHeader * foo;*/

/*				printf("Choicepoint proc:  %s\n",nameof(lcp->procname));*/
				x = (freeRecord *)((long)lcp->clp - sizeof(spaceHeader));
			/*	foo = (spaceHeader *)x;*/
				s = ((spaceHeader *)x)->space;
				if (s NE s->self) BNRP_error(DANGLINGREFERENCE);
				context = s->context;
				if (context NE context->self) BNRP_error(DANGLINGREFERENCE);
				if (context EQ topContext) BNRP_error(DANGLINGREFERENCE);
				}
			lcp = lcp->lcp;
			}
		/* check top context for dangling references for continuation pointers */
		ce = tcb->ce;
		while (TRUE) {
			long cp = env(ce, CP);

			/* need to check addresses since cp could point anywhere in a clause */
			s = topContext->firstSpace;			
			while (s NE NULL) {
				long l = cp - (long)s;
				if ((l GT 0) AND (l LE s->size)) BNRP_error(DANGLINGREFERENCE);
				s = s->next;
				}
			if (ce EQ env(ce, CE)) break;		/* out of environments ?? */
			ce = env(ce, CE);					/* no, so back up to previous env */
			}

		p = topContext;
		topContext = p->prevContext;
		u = p->undoChain;
		s = p->firstSpace;
		while (u NE NULL) {
			*(long *)(u->addr) = (*(long *)(u->addr) & u->mask) | u->oldvalue;
#ifdef trace_contexttrail
            printf("removeContext: undoRecord{addr=0x%08x, mask=0x%08x} undone.\n",
                   u->addr, ~(u->mask));
#endif
			u = u->next;
			}
		while (s NE NULL) {
			long te;
			contextSpace *t;

			t = s;
			s = s->next;
			te = tcb->te;
			while (te LT tcb->trailbase) {
				long addr, offset;
				
				addr = *(long *)te;
				offset = addr - (long)t;
				if ((offset GE 0) && (offset LE t->size)) {
/**********
					printf("Found trailed atom %s in context being removed\n", (char *)(addr + 2));
**********/
					*(long *)te = (long)&waste;
					*(long *)(te + sizeof(long)) = 0;
					}
				te += sizeof(long) + sizeof(long);
				}
			t->self = NULL;
			BNRP_free(t);
			}
#ifdef check
		{
		long te = tcb->te;

		while (te LT tcb->trailbase) {
			long addr, offset;
			
			addr = *(long *)te;
			offset = addr - (long)p;
			if ((offset GE 0) && (offset LE sizeof(contextHeader))) {
				printf("Found trailed data in context header being removed\n");
				}
			te += sizeof(long) + sizeof(long);
			}
		}
#endif
		p->self = NULL;
		BNRP_free(p);
		}
	return(TRUE);
	}
#endif

#ifdef ring3
void BNRP_removeAllContexts(void)
{
	while (topContext NE NULL) {
		contextHeader *p = topContext;
		contextSpace *s = topContext->firstSpace;
		
		topContext = p->prevContext;
		while (s NE NULL) {
			contextSpace *t = s;
			s = s->next;
			t->self = NULL;
			BNRP_free(t);
			}
		if (p EQ &baseContext) return;
		p->self = NULL;
		BNRP_free(p);
		}
	}
#endif

#ifdef ring3
/********************************** note that these two things could be defined 
#define topContext(n1, n2)			BNRP_parentContext(0L, 0L, n1, n2)
#define currentContext(n1, n2)		BNRP_parentContext(0L, 1L, n1, n2)
**************************************************************************/
BNRP_Boolean BNRP_parentContext(long name1, long name2, long *pname1, long *pname2)
{
	contextHeader *p;
	
	if ((p = topContext) EQ NULL) initializeContexts();
	if (name1 EQ 0) {
		if (name2) p = currContext;
		}
	else
		while (p NE NULL) {
			if ((p->ident1 EQ name1) && (p->ident2 EQ name2)) {
				p = p->prevContext;
				break;
				}
			p = p->prevContext;
			}
	if (p EQ NULL) return(FALSE);
	*pname1 = p->ident1;
	*pname2 = p->ident2;
	return(TRUE);
	}
#endif

#ifdef ring1
clauseEntry *BNRP_addClause(BNRP_term pred, long arity, long key, long size, void *data, BNRP_Boolean addFront)
{
	clauseEntry *clp, *cp, *next, *lastSameKey;
	symbolEntry *sym;
	spaceHeader *x;
	
	/* assume that we can only add to the topmost context */
	if (currContext NE topContext) return(NULL);
	checksym(pred, sym);
	if (sym->closed) return(NULL);

    /*
     * yanzhou@bnr.ca:24/06/96:
     * Make sure the predicate name is a permanent symbol
     */
    BNRP_makeSymbolPermanent(pred);
	
	/* see if it is defining a primitive ?? */
	if ((arity EQ 0) && (key EQ 0) && (size EQ 0)) {
		if (sym->firstClause NE NULL) return(NULL);
		sym->closed = TRUE;
		sym->firstClause = (clauseEntry *)(-(long)data);
		return(sym->firstClause);
		}

	/* see if it is an attempt to overload a primitive ?? */
	if ((long)sym->firstClause LT 0) {
		fprintf(stderr, "Attempt to redefine primitive %s\n", sym->name);
		return(NULL);
		}

	/* allocate clause space in top context */
	if ((clp = (clauseEntry *)allocSpaceInContext(currContext, size + sizeof(clauseEntry))) EQ NULL) 
		return(NULL);
	clp->key = key;
	clp->arity = arity;
	clp->nextClause = NULL;
	clp->nextSameKeyClause = NULL;
	memcpy((void *)((long)clp + sizeof(clauseEntry)), data, size);
	
	/* clause now in current context, link it in in the proper place */
	/* if pointer being changed not in current context then we need to trail it */
	cp = lastSameKey = NULL;
	if (!addFront) {
		/* have to find proper position in chain */
		next = sym->firstClause;
		if (key NE 0) {
			while (next NE NULL) {
				x = (spaceHeader *)((long)next - sizeof(spaceHeader));
				if (x->space->context NE currContext) break;
				cp = next;
				if ((cp->key EQ key) || (cp->key EQ 0)) lastSameKey = cp;
				next = next->nextClause;
				}
			}
		else {						/* key = 0 */
			while (next NE NULL) {
				x = (spaceHeader *)((long)next - sizeof(spaceHeader));
				if (x->space->context NE currContext) break;
				cp = next;
				if (cp->key EQ 0) lastSameKey = cp;
				
				/* since we are adding to the end, all null */
				/* nextSameKeyClauses will end up pointing to */
				/* this new clause, so do it now */
				if (cp->nextSameKeyClause EQ NULL) 
					cp->nextSameKeyClause = clp;
				next = next->nextClause;
				}
			}
		}
		
	/* now cp points at the clause after which we must insert clp */
	if (cp EQ NULL) {			/* need to add at the front */
		x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
		if (x->space->context NE currContext) 
			contextTrail(&sym->firstClause, 0xFFFFFFFF, currContext);
		clp->nextClause = sym->firstClause;
		sym->firstClause = clp;
		}
	else {						/* need to add after cp, cp in this context */
		clp->nextClause = cp->nextClause;
		cp->nextClause = clp;
		if (cp->key EQ 0) cp->nextSameKeyClause = clp;
		}
		
	/* relink all the clauses in the chain, especially for same key links */
	if (key NE 0) {
		if (lastSameKey NE NULL) {
			if (lastSameKey->key EQ key) {
				/* case ... key ... new ... key ... with no 0's */
				/* just need to insert the new entry in the chain */
				clp->nextSameKeyClause = lastSameKey->nextSameKeyClause;
				lastSameKey->nextSameKeyClause = clp;
				return(clp);
				}
			else {
				/* case ... 0 ... new ... key ... */
				/* need to search from clp to find next same key clause */
				next = clp->nextClause;
				}
			}
		else { /* lastSameKey = NULL */
			/* case ... new ... key ... */
			/* need to search from clp to find next same key clause */
			next = clp->nextClause;
			}

		/* scan from next until we hit a clause with key or 0, */
		/* which becomes nextSameKeyClause */
		while (next NE NULL) {
			if (next->key EQ key) break;
			if (next->key EQ 0) break;
			next = next->nextClause;
			}
		clp->nextSameKeyClause = next;
		}
	else {				/* key = 0 */
		/* case ... 0 ... */
		/* any clauses before clp may link over the zero, so must relink */
		/* from the last 0 (or beginning) to this clause */
		clp->nextSameKeyClause = clp->nextClause;
		if (clp->nextClause EQ NULL) {
			/* case ... 0 */
			/* we have already fixed any null pointers to point at clp, */
			/* so all clauses before us are linked to us.  Since there  */
			/* is nothing behind us, nobody can point over us */
			return(clp);
			}
		if ((cp NE NULL) && (cp->key EQ 0)) {
			/* case ... 0 0 ... */
			/* previous clause had key of 0, nothing special to do */
			cp->nextSameKeyClause = clp;
			return(clp);
			}
		/* case ... 0 ... 0 ... */
		/* any clauses between the last 0 and this clause must be relinked */
		if ((cp = lastSameKey) EQ NULL) cp = sym->firstClause;
		while (cp NE clp) {
			next = cp->nextClause;
			if (cp->key) {
				while (next NE NULL) {
					if (next->key EQ cp->key) break;
					if (next->key EQ 0) break;
					next = next->nextClause;
					}
				}
			cp->nextSameKeyClause = next;
			cp = cp->nextClause;
			}
		}
	return(clp);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_insertClause(BNRP_term pred, long arity, long key, void *data)
{
	symbolEntry *sym;
	clauseEntry *clp;
	spaceHeader *x;
	
	/* assume that we can only add to the topmost context */
	if (currContext NE topContext) return(FALSE);
	checksym(pred, sym);
	
    /*
     * yanzhou@bnr.ca:24/06/96:
     * Make sure the predicate name is a permanent symbol
     */
    BNRP_makeSymbolPermanent(pred);
	
	/* see if it is an attempt to overload a primitive ?? */
	if ((long)sym->firstClause LT 0) {
		fprintf(stderr, "Attempt to redefine primitive %s\n", sym->name);
		return(FALSE);
		}

	/* allocate clause space in top context */
	x = (spaceHeader *)((long)data);
	x->space = currContext->firstSpace;
	x->size = 0;
	
	clp = (clauseEntry *)((long)data + sizeof(spaceHeader));
	clp->key = key;
	clp->arity = arity;
	clp->nextClause = NULL;
	clp->nextSameKeyClause = NULL;
	
	/* clause now in current context, link it in in the proper place */
	/* if pointer being changed not in current context then we need to trail it */

	/* now cp points at the clause after which we must insert clp */
	x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
	if (x->space->context NE currContext) 
		contextTrail(&sym->firstClause, 0xFFFFFFFF, currContext);
	clp->nextClause = sym->firstClause;
	sym->firstClause = clp;
		
	/* relink all the clauses in the chain, especially for same key links */
	if (key EQ 0) {
		clp->nextSameKeyClause = clp->nextClause;
		}
	else {
		clauseEntry *next = clp->nextClause;
		/* scan from next until we hit a clause with key or 0, */
		/* which becomes nextSameKeyClause */
		while (next NE NULL) {
			if (next->key EQ key) break;
			if (next->key EQ 0) break;
			next = next->nextClause;
			}
		clp->nextSameKeyClause = next;
		}
	return(TRUE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_removeClause(BNRP_term pred, clauseEntry *c)
{
	symbolEntry *sym;
	clauseEntry *cp;
	spaceHeader *x;
	
	x = (spaceHeader *)((long)c - sizeof(spaceHeader));
	if ((topContext NE currContext) || (x->space->context NE currContext)) return(FALSE);
	checksym(pred, sym);
	if ((cp = sym->firstClause) EQ c)
		sym->firstClause = c->nextClause;
		/* no need to relink clauses since we get rid of first one only */
	else {
		while (cp NE NULL) {
			if (cp->nextSameKeyClause EQ c) {
				if (cp->key EQ c->key)		/* could be n -> n or 0 -> 0 */
					cp->nextSameKeyClause = c->nextSameKeyClause;
				else if (c->key NE 0)		/* 0 -> n */
					cp->nextSameKeyClause = c->nextClause;
				else {						/* n -> 0, search for next possible clause */
					clauseEntry *next = c->nextClause;
					while (next NE NULL) {
						if (next->key EQ cp->key) break;
						if (next->key EQ 0) break;
						next = next->nextClause;
						}
					cp->nextSameKeyClause = next;
					}
				}
			if (cp->nextClause EQ c) {
				cp->nextClause = c->nextClause;
				break;
				}
			cp = cp->nextClause;
			}
		}
	/* free up the space used for the clause */
	deallocSpaceInContext(c);
	return(TRUE);
	}
#endif

#ifdef ring1
long BNRP_contextOf(void *clp, long *name1, long *name2)
{
	spaceHeader *x;
	contextHeader *c;
	
	if (topContext EQ NULL) initializeContexts();
	x = (spaceHeader *)((long)clp - sizeof(spaceHeader));
	if (x->space NE x->space->self) BNRP_error(DANGLINGREFERENCE);
	c = x->space->context;
	if (c NE c->self) BNRP_error(DANGLINGREFERENCE);
	*name1 = c->ident1;
	*name2 = c->ident2;
	return(c->generation);
	}
#endif

#ifdef ring0
static symbolEntry *chaseChain(symbolEntry *first, const char *s, unsigned char h)
{
	symbolEntry *copy = first;
	
	while (copy NE NULL) {
		if (copy->hash EQ h) {
			register char *p, *q, c;
			
			p = (char *)s;
			q = copy->name;
			while ((c = *p++) EQ *q++)
				if (c EQ 0) return(copy);
			}
		copy = copy->chain;
		}
	return(NULL);
	}
#endif

#ifdef ring0
static symbolEntry *chasePermChain(symbolEntry *first, const char *s)
{
	register symbolEntry *copy = first;
	register char *p, *q, c;
	
	while (copy NE NULL) {
		
		p = (char *)s;
		q = copy->name;
		while ((c = *p++) EQ *q++)
			if (c EQ 0) return(copy);
		copy = copy->chain;
		}
	return(NULL);
	}
#endif

#ifdef ring0
static symbolEntry *chaseTempChain(symbolEntry **first, const char *s, int h)
{
	/* working down a temporary chain, free up space if possible */
	symbolEntry *next, *prev, *t;
	
	next = *first;
	prev = NULL;
	while (next NE NULL) {
#ifdef check
		if (((long)next GE tcb.heapbase) && ((long)next LT tcb.cpbase))
			DEBUGSTR("bad address in temp chain");
#endif
		if (next->inuse EQ UNUSED) {
			if (prev EQ NULL)
				*first = next->chain;
			else
				prev->chain = next->chain;
			t = next;
			next = next->chain;
			deallocSpaceInContext(t);
			continue;
			}
		if (next->hash EQ h) {
			register char *p, *q, c;
			
			p = (char *)s;
			q = next->name;
			while ((c = *p++) EQ *q++)
				if (c EQ 0) return(next);
			}
		prev = next;
		next = next->chain;
		}
	return(NULL);
	}
#endif

#ifdef ring0
BNRP_term BNRPMakeSymbol(int h, 
						 const char *s, 
						 BNRP_Boolean temp, 
						 BNRP_Boolean global, 
						 long *te,
						 long contextGeneration)
{
	symbolEntry *sym;
	long *addr;

#ifdef check
	if ((h LT 0) || (h GT PERMTABLEMODULUS)) 
		DEBUGSTR("Bad hash");
#endif
	if (global) {
		if ((sym = chasePermChain(currContext->permSymbols[h], s)) EQ NULL)
			if ((sym = chaseTempChain(&currContext->tempPermSymbols, s, h)) NE NULL) {
				if (!temp) BNRP_makeSymbolPermanent(maketerm(SYMBOLTAG,(long)sym));
				}
			else {
				if ((sym = newSymbol(currContext, s, h)) EQ NULL) BNRP_error(CONTEXTFULL);
				if (temp) {
					sym->chain = currContext->tempPermSymbols;
					sym->inuse = UNUSED;
					addr = (long *)&sym->inuse;
					rpush(long, *te, *addr);
					rpush(long, *te, (long)addr);
					sym->inuse = INUSETEMPGLOBAL;
					currContext->tempPermSymbols = sym;
					}
				else {
					sym->inuse = INUSE;
					sym->chain = currContext->permSymbols[h];
					currContext->permSymbols[h] = sym;
					}
				}
		return(maketerm(SYMBOLTAG, (long)sym));
		}
	else {
		contextHeader *c = currContext;

		if (contextGeneration) {
			c = topContext;
			while (c->generation NE contextGeneration) {
				if ((c = c->prevContext) EQ NULL) {
					c = currContext;
					break;
					}
				}
			}
		if ((sym = chaseChain(c->localSymbols, s, h)) EQ NULL)
			if ((sym = chaseTempChain(&c->tempLocalSymbols, s, h)) NE NULL) {
				if (!temp) BNRP_makeSymbolPermanent(maketerm(SYMBOLTAG, (long)sym));
				}
			else {
				if ((sym = newSymbol(c, s, h)) EQ NULL) BNRP_error(CONTEXTFULL);
				if (temp) {
					sym->chain = c->tempLocalSymbols;
					sym->inuse = UNUSED;
					addr = (long *)&sym->inuse;
					rpush(long, *te, *addr);
					rpush(long, *te, (long)addr);
					sym->inuse = INUSETEMPLOCAL;
					c->tempLocalSymbols = sym;
					}
				else {
					sym->inuse = INUSELOCAL;
					sym->chain = c->localSymbols;
					c->localSymbols = sym;
					}
				}
		return(maketerm(SYMBOLTAG, (long)sym));
		}
	}
#endif

#ifdef ring0
BNRP_term BNRPLookupSymbol(TCB *tcb, const char *s, BNRP_Boolean temp, BNRP_Boolean global)
{
	int h;
	
	if (topContext EQ NULL) initializeContexts();
	h = hashString(s) & (PERMTABLEMODULUS - 1);
	return(BNRPMakeSymbol(h, s, temp, global, &tcb->te, 0));
	}
#endif

#ifdef ring0
BNRP_term BNRPLookupPermSymbol(const char *s)
{
	int h;
	
	if (topContext EQ NULL) initializeContexts();
	h = hashString(s) & (PERMTABLEMODULUS - 1);
	return(BNRPMakeSymbol(h, s, PERMSYM, (*s EQ '$') ? LOCAL : GLOBAL, NULL, 0));
	}
#endif

#ifdef ring0
BNRP_term BNRPLookupTempSymbol(TCB *tcb, const char *s)
{
	int h;
	
	if (topContext EQ NULL) initializeContexts();
	h = hashString(s) & (PERMTABLEMODULUS - 1);
	return(BNRPMakeSymbol(h, s, TEMPSYM, (*s EQ '$') ? LOCAL : GLOBAL, &tcb->te, 0));
	}
#endif

#ifdef ring0
BNRP_Boolean BNRPFindSymbol(const char *s, BNRP_Boolean global, BNRP_term *atom)
{
	symbolEntry *sym;
	int h;
	
	if (topContext EQ NULL) initializeContexts();
	h = hashString(s) & (PERMTABLEMODULUS - 1);
	if (global) {
		if ((sym = chasePermChain(currContext->permSymbols[h], s)) EQ NULL)
			sym = chaseTempChain(&currContext->tempPermSymbols, s, h);
		}
	else {
		if ((sym = chaseChain(currContext->localSymbols, s, h)) EQ NULL)
			sym = chaseTempChain(&currContext->tempLocalSymbols, s, h);
		}
	*atom = maketerm(SYMBOLTAG, addrof((long)sym));
	return(sym NE NULL);
	}
#endif

#ifdef ring0
void BNRP_cleanupTempSymbols(void)
{
	/* cheat by looking for a string with an invalid hash code */
	/* this will cleanup any unused symbols */
	(void)chaseTempChain(&currContext->tempPermSymbols, "", PERMTABLEMODULUS);
	(void)chaseTempChain(&currContext->tempLocalSymbols, "", PERMTABLEMODULUS);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_setLocked(BNRP_term symbol, BNRP_Boolean newval)
{
	symbolEntry *sym;
	spaceHeader *x;
	
	checksym(symbol, sym);
	if (sym->locked EQ newval) return(TRUE);
	x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
	if (x->space->context NE currContext) 
		/* not in current context so we need to trail it */
		contextTrail(&sym->locked, 0xFF000000, currContext);
	sym->locked = newval;
	return(TRUE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_setClosed(BNRP_term symbol, BNRP_Boolean newval)
{
	symbolEntry *sym;
	spaceHeader *x;
	
	checksym(symbol, sym);
	if (sym->locked EQ newval) return(TRUE);
	x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
	if (x->space->context NE currContext) 
		/* not in current context so we need to trail it */
		contextTrail(&sym->locked, 0x00FF0000, currContext);
	sym->closed = newval;
	return(TRUE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_setDebug(BNRP_term symbol, short newval)
{
	symbolEntry *sym;

	checksym(symbol, sym);
	sym->debug = newval;
	return(TRUE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_queryLocked(BNRP_term symbol)
{
	symbolEntry *sym;
	
	checksym(symbol, sym);
	return(sym->locked);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_queryClosed(BNRP_term symbol)
{
	symbolEntry *sym;
	
	checksym(symbol, sym);
	return(sym->closed);
	}
#endif

#ifdef ring3
short BNRP_queryDebug(BNRP_term symbol)
{
	symbolEntry *sym;
	
	checksym(symbol, sym);
	return(sym->debug);
	}
#endif

#ifdef ring0
BNRP_Boolean BNRP_addOperator(BNRP_term symbol, int newType, int newPrecedence)
{
	symbolEntry *sym;
	spaceHeader *x;
	
	checksym(symbol, sym);
#ifdef trace
	printf("Adding operator definition for %s, prec = %d, type = %04X\n",
			sym->name, newPrecedence, newType);
#endif
	/* do some checking first */

	if ((sym->opPrecedence EQ newPrecedence) && (sym->opType EQ newType))
		return(TRUE);

        /* above line modified by Jason Harris, Feb. 95 */

	if ((sym->opPrecedence NE newPrecedence) && (sym->opPrecedence NE 0))
		return(FALSE);
	if (sym->opType NE notOp) {		/* need to check matches */
		if (newType & xf)
			if (sym->opType & (yf | fy | fx)) return(FALSE);
		if (newType & yf)
			if (sym->opType & (xf | fy | fx)) return(FALSE);
		if (newType & fy)
			if (sym->opType & (xf | yf | fx)) return(FALSE);
		if (newType & fx)
			if (sym->opType & (xf | yf | fy)) return(FALSE);
		if (newType & yfx)
			if (sym->opType & (xfy | xfx)) return(FALSE);
		if (newType & xfy)
			if (sym->opType & (yfx | xfx)) return(FALSE);
		if (newType & xfx)
			if (sym->opType & (yfx | xfy)) return(FALSE); 
		}
	x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
	if (x->space->context NE currContext) 
		/* not in current context so we need to trail it */
		contextTrail(&sym->opType, 0xFFFFFFFF, currContext);
	sym->opType |= newType;
	sym->opPrecedence = newPrecedence;
	return(TRUE);
	}
#endif

#ifdef ring0
void BNRP_makeSymbolPermanent(BNRP_term symbol)
{
	symbolEntry *sym, *p, *n;
	spaceHeader *x;
	contextHeader *c;
	
	checksym(symbol, sym);
	x = (spaceHeader *)((long)sym - sizeof(spaceHeader));
	if (x->space NE x->space->self) BNRP_error(DANGLINGREFERENCE);
	c = x->space->context;
	if (c NE c->self) BNRP_error(DANGLINGREFERENCE);
	if (sym->inuse EQ INUSETEMPGLOBAL) {
		n = c->tempPermSymbols;
		p = NULL;
		while (n NE NULL) {
			if ((long)n EQ (long)sym) {
				if (p EQ NULL) 
					c->tempPermSymbols = n->chain;
				else
					p->chain = n->chain;
				n->chain = c->permSymbols[sym->hash];
				c->permSymbols[sym->hash] = n;
				sym->inuse = INUSE;
				break;
				}
			p = n;
			n = n->chain;
			}
		}
	else if (sym->inuse EQ INUSETEMPLOCAL) {
		n = c->tempLocalSymbols;
		p = NULL;
		while (n NE NULL) {
			if ((long)n EQ (long)sym) {
				if (p EQ NULL) 
					c->tempLocalSymbols = n->chain;
				else
					p->chain = n->chain;
				n->chain = c->localSymbols;
				c->localSymbols = n;
				sym->inuse = INUSELOCAL;
				break;
				}
			p = n;
			n = n->chain;
			}
		}
	}
#endif


#ifdef ring1
void BNRP_contextSpaceUsed(long *allocated, long *used, long *nsym)
{
	contextHeader *c;
	contextSpace *s;
	symbolEntry *sym;
	freeRecord *f;
	int i;
	register long size, avail, syms;
	
	size = avail = syms = 0;
	c = topContext;
	while (c NE NULL) {
		size += sizeof(contextHeader);
		s = c->firstSpace;
		while (s NE NULL) {
			size += s->size;
			f = s->freep;
			while (f NE NULL) {
				avail += f->size;
				f = f->next;
				}
			s = s->next;
			}
		sym = c->localSymbols;
		while (sym NE NULL) {
			++syms;
			sym = sym->chain;
			}
		sym = c->tempPermSymbols;
		while (sym NE NULL) {
			++syms;
			sym = sym->chain;
			}
		sym = c->tempLocalSymbols;
		while (sym NE NULL) {
			++syms;
			sym = sym->chain;
			}
		c = c->prevContext;
		}
	for (i = 0; i LT PERMTABLEMODULUS; ++i) {
		sym = topContext->permSymbols[i];
		while (sym NE NULL) {
			++syms;
			sym = sym->chain;
			}
		}
	*allocated = size;
	*used = size - avail;
	*nsym = syms;
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_enterContext(TCB *tcb)
{
	BNRP_term name1, name2;
	
	if ((tcb->numargs EQ 2) && 
		(checkArg(tcb->args[1], &name1) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &name2) EQ SYMBOLT)) {
#ifdef trace
			printf("Trying new context on %s %s\n", nameof(name1), nameof(name2));
#endif
			return(BNRPnewContext(name1, name2));
			}
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_exitContext(TCB *tcb)
{
	BNRP_term name1, name2;
	
	if ((tcb->numargs EQ 2) && 
		(checkArg(tcb->args[1], &name1) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &name2) EQ SYMBOLT)) {
#ifdef trace
			printf("Trying to remove context %s %s\n", nameof(name1), nameof(name2));
#endif
			return(removeContext(tcb, name1, name2));
			}
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_listContexts(TCB *tcb)
{
	contextHeader *c;
	BNRP_term res;
	
	if (tcb->numargs EQ 1) {
		c = topContext;
		res = maketerm(LISTTAG, tcb->hp);
		while (c NE NULL) {
			push(BNRP_term, tcb->hp, c->ident1);
			push(BNRP_term, tcb->hp, c->ident2);
			c = c->prevContext;
			}
		push(BNRP_term, tcb->hp, 0L);
		return(unify(tcb, tcb->args[1], res));
		}
	return(FALSE);
	}
#endif

#ifdef ring3
symbolEntry *BNRP_getNextSymbol(symbolEntry *p)
{
	/* return the symbol table entries in some order.   */
	/* Hard to do since given a previous symbol we need */
	/* to find the next without remembering any state.  */
	
	int i;
	symbolEntry *sym;
	contextHeader *c;
	spaceHeader *x;
	
	if (p EQ NULL) {
		i = 0;
		goto scan;
		}
	/* already have one, find the next */
	sym = p->chain;
	if ((p->inuse EQ INUSETEMPGLOBAL) || (p->inuse EQ INUSETEMPLOCAL)) {
		while (sym NE NULL) {
			if (sym->inuse NE UNUSED) break;
			sym = sym->chain;
			}
		if (sym NE NULL) return(sym);
		}
	else if (sym NE NULL) {
		sym->inuse = p->inuse;		/* copy flag in case it is marked unused */
		return(sym);
		}
	
	/* at the end of a chain, move to next chain */
	if (p->inuse EQ INUSE) {
		i = p->hash + 1;
scan:
		for (; i LT PERMTABLEMODULUS; ++i)
			if ((sym = topContext->permSymbols[i]) NE NULL) {
				sym->inuse = INUSE;		/* so we know it was on perm chain */
				return(sym);
				}
		c = topContext;
		goto scantempchains;
		}

	/* not on a permanent chain, now determine context of p */
	x = (spaceHeader *)((long)p - sizeof(spaceHeader));
	c = x->space->context;
	
	i = p->inuse;
	if (i EQ INUSELOCAL) {			/* end of locals, try temp globals */
		sym = c->tempPermSymbols;
		while (sym NE NULL) {
			if (sym->inuse NE UNUSED) return(sym);
			sym = sym->chain;
			}
		i = INUSETEMPGLOBAL;		/* so we continue in the next loop
		}
	if (i EQ INUSETEMPGLOBAL) {		/* end of temp globals, try temp locals */
		sym = c->tempLocalSymbols;
		while (sym NE NULL) {
			if (sym->inuse NE UNUSED) return(sym);
			sym = sym->chain;
			}
		}
	/* so far we are at the end of the temp locals, so try previous contexts */
	c = c->prevContext;
scantempchains:
	while (c NE NULL) {
		if ((sym = c->localSymbols) NE NULL) {
			sym->inuse = INUSELOCAL;
			return(sym);
			}
		sym = c->tempPermSymbols;
		while (sym NE NULL) {
			if (sym->inuse NE UNUSED) return(sym);
			sym = sym->chain;
			}
		sym = c->tempLocalSymbols;
		while (sym NE NULL) {
			if (sym->inuse NE UNUSED) return(sym);
			sym = sym->chain;
			}
		c = c->prevContext;
		}
	return(NULL);
	}
#endif

#ifdef ring3
void BNRP_setAllDebugBits(long andMask, long orMask)
{
	contextHeader *c;
	int i;
	symbolEntry *sym;
	
	c = topContext;
	for (i = 0; i LT PERMTABLEMODULUS; ++i) {
		sym = c->permSymbols[i];
		while (sym NE NULL) {
			if (sym->firstClause NE NULL) 
				sym->debug = (sym->debug & andMask) | orMask;
			sym = sym->chain;
			}
		}
	if (c NE &baseContext) {			/* don't do base */
		sym = c->localSymbols;
		while (sym NE NULL) {
			if (sym->firstClause NE NULL) 
				sym->debug = (sym->debug & andMask) | orMask;
			sym = sym->chain;
			}
		/* don't need to do tempPermSymbols and tempLocalSymbols since */
		/* they won't have any clauses defined for them */
		/* c = c->prevContext; */
		}
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_isPrimitive(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT)) {
			symbolEntry *sym;
			checksym(name, sym);
			return((long)(sym->firstClause) LT 0);
			}
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_predicateSymbol(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT)) {
			symbolEntry *sym;
			checksym(name, sym);
			return(sym->firstClause NE NULL);
			}
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_prevPredicate(TCB *tcb)
{
	BNRP_term name;
	symbolEntry *prev, *next;
	
	if (tcb->numargs EQ 1)
		prev = NULL;
	else if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &name) EQ SYMBOLT)) {
		checksym(name, prev);
		}
	else
		return(FALSE);
	while (1) {
		next = BNRP_getNextSymbol(prev);
		if (next EQ NULL) break;
		if (next->firstClause NE NULL)
			return(unify(tcb, tcb->args[tcb->numargs], maketerm(SYMBOLTAG, (long)next)));
		prev = next;
		}
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_prevSymbol(TCB *tcb)
{
	BNRP_term name;
	symbolEntry *prev, *next;
		
	if (tcb->numargs EQ 1)
		prev = NULL;
	else if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &name) EQ SYMBOLT)) {
		checksym(name, prev);
		}
	else
		return(FALSE);
	next = BNRP_getNextSymbol(prev);
	if (next NE NULL)
		return(unify(tcb, tcb->args[tcb->numargs], maketerm(SYMBOLTAG, (long)next)));
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_closeDefinition(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT))
			return(BNRP_setClosed(name, TRUE));
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_closedDefinition(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT))
			return(BNRP_queryClosed(name));
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_hideDefinition(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT))
			return(BNRP_setLocked(name, TRUE));
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_notHiddenDefinition(TCB *tcb)
{
	BNRP_term name;
	
	if ((tcb->numargs EQ 1) && 
		(checkArg(tcb->args[1], &name) EQ SYMBOLT))
			return(BNRP_queryLocked(name) EQ FALSE);
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_getContextOf(TCB *tcb)
{
	long l;
	contextHeader *c;
	spaceHeader *x;
	
	if ((tcb->numargs EQ 3) && (checkArg(tcb->args[1], &l) EQ INTT)) {
		if (l EQ 0)
			c = &baseContext;
		else {
			x = (spaceHeader *)(l - sizeof(spaceHeader));
			if (x->space NE x->space->self) BNRP_error(DANGLINGREFERENCE);
			c = x->space->context;
			if (c NE c->self) BNRP_error(DANGLINGREFERENCE);
			}
		return(unify(tcb, tcb->args[2], c->ident1) && 
			   unify(tcb, tcb->args[3], c->ident2));
		}
	return(FALSE);
	}
#endif
