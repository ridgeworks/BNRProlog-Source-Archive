/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/state.c,v 1.4 1997/12/22 17:01:38 harrisj Exp $
*
*  $Log: state.c,v $
 * Revision 1.4  1997/12/22  17:01:38  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.3  1996/07/05  11:10:41  yanzhou
 * When a statespace is being added, its name (eg, $local)
 * is now made a permanent symbol in ComputeIndex.
 *
 * Revision 1.2  1996/02/12  03:36:13  yanzhou
 * unsaf-related code segments are now removed:
 *
 *    Removed OpCode  Mode           Code
 *    --------------  --------  ---------
 *    unif_unsaft     HEAD      0x18-0x1F
 *    unif_unsafp     HEAD           0x91
 *    push_unsafp     BODY      0x18-0x1F
 *    push_unsaft     BODY ESC  0x88-0x8F
 *    putunsaf        BODY ESC  0x38-0x3F
 *
 * Revision 1.1  1995/09/22  11:28:42  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "context.h"
#include "hash.h"
#include "state.h"
#include "pushpop.h"
#include "interpreter.h"
#include "hardware.h"
#include "utility.h"
#include <stdio.h>
#include <string.h>
#ifdef unix
#include <unistd.h>			/* for SEEK_SET, SEEK_END */
#include <sys/types.h>
#endif
#ifndef __MWERKS__
#include <fcntl.h>			/* ?? */
#endif
#include <limits.h>			/* for USHRT_MAX */

/* #define trace */
/* #define executiontrace */
/* #define check /* */
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)

/*******************************************************************

	This unit implements the following primitives:
	
		$new_state(size)
		$firstobj(struct, ptr, hash, nextptr)
		$nextobj(ptr, hash, nextptr)
		$lastobj(struct, ptr, hash, prevptr)
		$prevobj(ptr, hash, prevptr)
		$getobj(ptr, struct)
		dispose_obj(ptr)
		new_obj(struct, ptr)
		$zstoreobj(struct, ptr)
		put_obj(ptr, struct)
		$hashlist(index, chain)
		$getsatom(ptr, f)
		
	All primitives take an extra parameter which is the state
	space name.
	
	Objects in the state space are stored in WAM instructions.
	
	NOTE: floating point numbers are not aligned properly on all
	      systems, need to copy the number out before using it
	
*******************************************************************/

#define SMODULUS		PERMTABLEMODULUS
#define STATE_VERSION	0x0A0DFFBB		/* change from interpreter, use 0A and 0D */
										/* to catch CR<->LF conversions */
#define RingT			0xC1
#define ObjT			0xB1
#define StrT			0xA1

typedef struct freeRecord freeRecord;
typedef struct stateHeader stateHeader;
typedef struct stateSpace stateSpace;
typedef struct spaceHeader spaceHeader;
typedef struct ringHeader ringHeader;
typedef struct stateString stateString;
typedef struct stateObject stateObject;
typedef struct stateClauseEntry stateClauseEntry;


struct freeRecord {
	long bytesize;
	freeRecord *next;
	};

struct stateSpace {
	stateHeader *state;				/* state we belong to */
	stateSpace *next;				/* next chunk allocated to this state space */
	long size;						/* size of allocation */
	freeRecord *freep;				/* first free space in this chunk */
	};

struct stateHeader {				/* must be integral number of cells */
	ringHeader *hshtab[SMODULUS];	/* array of rings of strings */
	long tot_size;					/* total size allocated in bytes */
	stateSpace *firstSpace;			/* first chunk of memory for state space */
	};


struct spaceHeader {
	stateSpace *space;
	long size;
	};
	
struct ringHeader {
	short tag;			/* RingT, ObjT, StrT, Funchd, Listhd */
	short hash;			/* indicate which ring we are on */
	ringHeader *next;	/* pointer to next ring */
	ringHeader *prev;	/* pointer to previous ring */
	};

struct stateString {
	ringHeader link;
	long refCount;
	BNRP_term origContext;
	symbolEntry sym;
	};

struct stateObject {
	short tag;
	short filler;
	stateString *father;		/* ptr to functor name */
	stateClauseEntry *cl;		/* clause follows as WAM opcodes */
	};

struct stateClauseEntry {		/* size of this record known in core (unify_address) */
	stateObject *obj;
	long xxfiller;				/* make sure cl is header aligned (8 byte boundary) */
	clauseEntry cl;
	};

/**** global variables *******/
stateHeader *currState = NULL;		/* state space segment base */
BNRP_term SSContext;				/* context containing current state space */
#ifdef check
extern TCB tcb;
#endif


/** The following structures are used to keep track of all state spaces **/

#define NilID			-1
#define GlobalId		0

struct tStateInfo {
	BNRP_term stateSpaceName;
	stateHeader *stateSpaceMemory;
	long contextGeneration;
	short stateSpaceSize;
	BNRP_Boolean Changed;
	};
typedef struct tStateInfo tStateInfo;

tStateInfo *StateInfo = NULL;	/* no state spaces allocated yet */
short HiContext = 0;			/* last record allocated */
short CurrentIndex = NilID;		/* current state space in use */
BNRP_term CurrentId = NilID;	/* term for last used state space */


/*************************************************************************

  Utilities

 *************************************************************************/


static void nilOut(tStateInfo *s)
{
	s->stateSpaceName = NilID;
	s->stateSpaceMemory = NULL;
	s->stateSpaceSize = 0;
	s->contextGeneration = -1;
	s->Changed = FALSE;
	}

static BNRP_Boolean ComputeIndex(BNRP_term ss, short *Index, BNRP_Boolean AddState)
{
	short i;

	/* see if we are currently working with the same state space */
	if (ss EQ CurrentId) {
		*Index = CurrentIndex;
		return(TRUE);
		}

	/* see if we can find it in the list */
	for (i = 0; i LT HiContext; ++i) {
		if (StateInfo[i].stateSpaceName EQ ss) {
			*Index = CurrentIndex = i;
			CurrentId = ss;
			return(TRUE);
			}
		}

	/* haven't been able to find it, see if we are adding new state space */
	if (AddState) {
		long t1, t2, generation;

		/*
         * yanzhou@bnr.ca:05/07/96
         * Make the statespace name a permanent sybmol
         *
         * Patch Begin
         */
        if (ss NE GlobalId) BNRP_makeSymbolPermanent(ss);
        /*
         * Patch End
         */

		generation = (ss EQ GlobalId) ? -1 : BNRP_contextOf(symof(ss), &t1, &t2);
		if (HiContext EQ 0) {				/* any state spaces yet ? */
			StateInfo = (tStateInfo *) BNRP_malloc(sizeof(tStateInfo));
			if (StateInfo NE NULL) {
				HiContext = 1;
				nilOut(StateInfo);
				CurrentId = StateInfo[0].stateSpaceName = ss;
				StateInfo[0].contextGeneration = generation;
				*Index = CurrentIndex = 0;
				return(TRUE);
				}
			else
				BNRP_error(STATESPACENOMEMORY);
			}
		else { /* find a hole */
			for (i = 0; i LT HiContext; ++i)
				if (StateInfo[i].stateSpaceName EQ NilID) {
					CurrentId = StateInfo[i].stateSpaceName = ss;
					StateInfo[i].contextGeneration = generation;
					*Index = CurrentIndex = i;
					return(TRUE);
					}
			/* no holes, have to at at end of table */
			StateInfo = (tStateInfo *) BNRP_realloc(StateInfo, ++HiContext * sizeof(tStateInfo));
			if (StateInfo NE NULL) {
				*Index = CurrentIndex = HiContext-1;
				nilOut(&(StateInfo[CurrentIndex]));
				StateInfo[CurrentIndex].stateSpaceName = CurrentId = ss;
				StateInfo[CurrentIndex].contextGeneration = generation;
				return(TRUE);
				}
			else {
				--HiContext;
				BNRP_error(STATESPACENOMEMORY);
				}
			}
		}
	return(FALSE);
	}

#define ReleaseStateSpace(x)	

static void LocateStateSpace(short Index, BNRP_Boolean changing)
{
	SSContext = StateInfo[Index].contextGeneration;
	if (changing) StateInfo[Index].Changed = TRUE;
	currState = StateInfo[Index].stateSpaceMemory;
	}

static void RemoveStateSpace(short Index)
{
	stateSpace *s, *t;
	
	s = StateInfo[Index].stateSpaceMemory->firstSpace;
	while (s NE NULL) {
		t = s->next;
		if (t NE NULL) BNRP_free(s);
		s = t;
		}
	BNRP_free(StateInfo[Index].stateSpaceMemory);
	nilOut(&StateInfo[Index]);
	CurrentId = NilID;
	CurrentIndex = -1;
	}

/******
static void removeAllStateSpaces()
{
	short i;
	
	for (i = 0; i LT HiContext; ++i) RemoveStateSpace(i);
	if (HiContext GT 0)
		BNRP_free(StateInfo);
	StateInfo = NULL;
	HiContext = 0;
	}
*******/

void BNRP_removeStateSpaces(long generation)
{
	short i;
	
	for (i = 0; i LT HiContext; ++i) 
		if (StateInfo[i].contextGeneration GE generation) 
			RemoveStateSpace(i);
	if (generation EQ 0) {			/* removing all state spaces */
		BNRP_free(StateInfo);
		StateInfo = NULL;
		HiContext = 0;
		}
	}

#define DefStateSize	4 * 1024
#define MaxPerCentIncr	15

static void *allocSpaceInStateSpace(size_t size)
{
	stateSpace *s;
	freeRecord *f, *p;
	spaceHeader *x;
	size_t incr, minsize;
	long rem;
	
	/* round to longword */
	size = (size + sizeof(spaceHeader) + headerAlignment - 1) & -headerAlignment;
	for (;;) {
		s = currState->firstSpace;
		while (s NE NULL) {
			f = s->freep;
			p = NULL;
			while (f NE NULL) {
				rem = f->bytesize - size;
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
						*(long *)NULL;
#endif
					return((void *)((long)x + sizeof(spaceHeader)));
					}
				if (rem GT (long)sizeof(freeRecord)) {		/* room left over */
					f->bytesize -= size;
					x = (spaceHeader *)((long)f + f->bytesize);
					x->space = s;
					x->size = size;
#ifdef trace
					printf("Allocating new chunk @ %p, size %ld\n", (long)x + sizeof(spaceHeader), size);
#endif
#ifdef check
					if (((long)x GE tcb.heapbase) && ((long)x LT tcb.cpbase))
						*(long *)NULL;
#endif
					return((void *)((long)x + sizeof(spaceHeader)));
					}
				p = f;
				f = f->next;
				}
			s = s->next;
			}
		/* not enough available space, need a new chunk */
		minsize = size + sizeof(stateSpace);
		incr = (currState->tot_size * MaxPerCentIncr) / 100;
		if (incr LT DefStateSize) incr = DefStateSize;
		if (incr LT minsize) incr = minsize;
		incr = (incr + 1023) & -1024;				/* round up to next K */
		if ((s = (stateSpace *)BNRP_malloc(incr)) EQ NULL) 
			BNRP_error(STATESPACENOMEMORY);
#ifdef trace
		printf("Allocating new block @ %p, size %ld\n", s, incr);
#endif
		s->state = currState;
		s->next = currState->firstSpace;
		currState->firstSpace = s;
		currState->tot_size += incr;
		s->size = incr;
		f = (freeRecord *)((long)s + sizeof(stateSpace));
		f->bytesize = incr - sizeof(stateSpace);
		f->next = NULL;
		s->freep = f;
		}
	}

static void deallocSpaceInStateSpace(void *it)
{
	stateSpace *s;
	freeRecord *x, *n, *p;
	long size;
	
	x = (freeRecord *)((long)it - sizeof(spaceHeader));
	s = ((spaceHeader *)x)->space;
	if ((size = ((spaceHeader *)x)->size) GT s->size) return;
#ifdef trace
	printf("Deallocating chunk @ %p, size %ld\n", it, size);
	memset(it, 0xAA, size - sizeof(spaceHeader));
#endif
	/* found the block containing it */
	if ((n = s->freep) EQ NULL) {
		s->freep = x;
		x->bytesize = size;
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
		if (((long)p + p->bytesize) EQ (long)x) {
			size += p->bytesize;
			x = p;
			}
		else
			p->next = x;
		}
	x->bytesize = size;

	/* combine with next if possible */
	if (((long)x + size) EQ (long)n) {
		x->bytesize += n->bytesize;
		x->next = n->next;
		}
	else
		x->next = n;
	}


BNRP_Boolean BNRP_NewStatespace(long size, BNRP_term CheckID)
/* Gets appropriate sized segment and initializes freelist and header */
/* - must be first primitive called. if (a state space already exists, */
/* it will fail. Size must be GT 3. */
{
	short Index, i;
	long bsize;
	stateSpace *s;
	freeRecord *f;

	if (!ComputeIndex(CheckID, &Index, TRUE)) return(FALSE);

	/* see if state space already exists, then check that sizes match */
	if (StateInfo[Index].stateSpaceSize NE 0) {
		StateInfo[Index].stateSpaceSize = StateInfo[Index].stateSpaceMemory->tot_size / 1024;
		return((long)StateInfo[Index].stateSpaceSize EQ size);
		}

	/* have to create a new state space */
	LocateStateSpace(Index, FALSE);
	bsize = size * 1024;
	StateInfo[Index].stateSpaceSize = (short)size;
	StateInfo[Index].stateSpaceMemory = currState = (stateHeader *)BNRP_malloc(bsize);
	if (currState EQ NULL) BNRP_error(STATESPACENOMEMORY);
#ifdef trace
	printf("Allocating state space @ %08lX, size = %ldK\n", currState, size);
	memset(currState, 0, bsize);
#endif
#ifdef check
	memset(currState, 0, bsize);
#endif
	s = (stateSpace *)((long)currState + sizeof(stateHeader));
	f = (freeRecord *)((long)s + sizeof(stateSpace));

	for (i = 0; i LT SMODULUS; ++i)
		currState->hshtab[i] = NULL;
	currState->tot_size = bsize;
	currState->firstSpace = s;

	s->state = currState;
	s->next = NULL;
	s->size = bsize - sizeof(stateSpace);
	s->freep = f;

	f->bytesize = bsize - sizeof(stateHeader) - sizeof(stateSpace);
	f->next = NULL;
	ReleaseStateSpace(Index);
	return(TRUE);
	}

/*****************************************************************************

 Ring utilities

*****************************************************************************/

static ringHeader *newRing(short hash)
{
	ringHeader *r;
	
	r = (ringHeader *)allocSpaceInStateSpace(sizeof(ringHeader));
	if (r NE NULL) {
		r->tag = RingT;
		r->next = r->prev = r;
		if ((r->hash = hash) GE 0)
			currState->hshtab[hash] = r;
		}
	return(r);
	}

static void linkRing(ringHeader *q, ringHeader *it)
/* link item (must be free) onto a ring after q */
{
	ringHeader *next;

	if (it->next NE it->prev) BNRP_error(STATESPACEBADRING);
	next = q->next;
	it->next = next;
	q->next = it;
	it->prev = q;
	next->prev = it;
	}

static void unlinkRing(ringHeader *it)
/* remove item from ring */
{
	ringHeader *next, *prev;

	next = it->next;
	prev = it->prev;
	next->prev = prev;
	prev->next = next;
	it->next = it->prev = it;
	}

/*****************************************************************************

  Search utilities

*****************************************************************************/

static stateString *stateSpaceFind(BNRP_term t)
{
	char *s;
	short hash;
	ringHeader *r;
	stateString *ss;
	long context = 0, t1, t2;
	symbolEntry *sym;
	
	checksym(t, sym);
	hash = sym->hash;
	if ((r = currState->hshtab[hash]) NE NULL) {
		s = sym->name;
		if (*s EQ '$')
			if ((context = BNRP_contextOf(sym, &t1, &t2)) GT SSContext) 
				context = 0;
		ss = (stateString *)r->next;
		while (ss->link.tag NE RingT) {
			if (context EQ ss->origContext) {
				register char *p, *q, c;
				
				p = s;
				q = ss->sym.name;
				while ((c = *p++) EQ *q++)
					if (c EQ 0) return(ss);
				}
			ss = (stateString *)ss->link.next;
			}
		}
	return(NULL);
	}

/* find string in state space (exact lexical  comparison) or creates it */

static stateString *stateSpaceLookup(BNRP_term t)
{
	stateString *a;
	ringHeader *r;
	short h;
	long t1, t2, context;

	if ((a = stateSpaceFind(t)) EQ NULL) {
		char *s;
		symbolEntry *sym;
		
		checksym(t, sym);
		s = sym->name;
		a = (stateString *)allocSpaceInStateSpace(strlen(s) + sizeof(stateString) - 1);
		if (a EQ NULL) BNRP_error(STATESPACENOSTRING);
		a->link.tag = StrT;
		h = a->link.hash = a->sym.hash = sym->hash;
		a->link.next = a->link.prev = NULL;
		a->refCount = 0;
		a->origContext = 0;
		if (*s EQ '$')
			if ((context = BNRP_contextOf(sym, &t1, &t2)) LE SSContext) 
				a->origContext = context;
		a->sym.firstClause = NULL;
		a->sym.chain = NULL;
		a->sym.self = &a->sym;
		a->sym.opType = notOp;
		a->sym.opPrecedence = 0;
		a->sym.locked = 1;
		a->sym.closed = 1;
		a->sym.debug = 0;
		a->sym.inuse = 0;
		strcpy(a->sym.name, s);

		/* add to ring, creating if it doesn't exist */
		r = currState->hshtab[h];
		if (r EQ NULL) r = newRing(h);
		linkRing(r, &a->link);
		}
	return(a);
	}

static void incref(stateString *s)
{
	if (s->link.tag NE StrT) BNRP_error(STATESPACEBADTAG);
	++s->refCount;
	}


static void unref(stateString *s)

/* unref - decrements the ref count on strings, and when it becomes */
/* 0 it removes and deallocates the object list head if it exists */
/* and deletes the string from the hashlist  and deallocs it. */
/* does not remove hashlist head! */

{
	ringHeader *header;
	
	if (s->link.tag NE StrT) BNRP_error(STATESPACEBADTAG);
	if (--s->refCount EQ 0) {
	
		/* make sure no lingering clauses attached to this symbol */
		if (s->sym.firstClause NE NULL) BNRP_error(STATESPACEBADRING);

		/* unlink symbol from the ring */
		if (s->link.next EQ s->link.prev) {
			/* we are only thing in ring, remove header as well */			
			header = s->link.next;
			if (header->tag NE RingT) BNRP_error(STATESPACEBADTAG);
			currState->hshtab[header->hash] = NULL;
			deallocSpaceInStateSpace(header);
			}
		else	
			/* just unlink us from the ring */
			unlinkRing(&s->link);
		deallocSpaceInStateSpace(s);
		}
	}

#define opMaxReg			7
#define opUnifyAddr			0xA2		/* unif_address */
#define opNOP				0xF7
#define opAlloc				0x06
#define opCopyTemp			0xD5
#define opGetStruct			0x10		/* get_struct(N, T) */
#define opGetList			0x20		/* get_list(T) */
#define opSSGetCons			0xB3		/* get_cons_by_value(T, Tag, C) */
#define opSSUnifyCons		0xC4		/* unif_cons_by_value(Tag, C) */
#define opSymbolTag			0x00
#define opIntTag			0x01
#define opFloatTag			0x02
#define opGetCons			0x08		/* get_cons(C) */
#define opUnifyCons			0x04		/* unify_cons(C) */
#define opGetValt			0x30		/* get_valt(T) */
#define opGetValp			0x38		/* get_valp(P) */
#define opUnifyVart			0x40		/* unif_vart(T) */
#define opUnifyVarp			0x48		/* unif_varp(P) */
#define opUnifyValt			0x50		/* unif_valt(T) */
#define opUnifyValp			0x58		/* unif_valp(P) */
#define opTUnifyVart		0x60		/* tunif_vart(T) */
#define opTUnifyVarp		0x68		/* tunif_varp(P) */
#define opTUnifyValt		0x70		/* tunif_valt(T) */
#define opTUnifyValp		0x78		/* tunif_valp(P) */
#define opEndSeq			0x03		/* end_seq */
#define opNeckCons1			0x05		/* neckcons(0) */
#define opNeckCons2			0x00
#define opNeckCons3			0x06
#define opDealloc			0x06
#define opProceed			0x00		/* proceed */

static void removeClauseReferences(stateClauseEntry *cl)

/* scan entire structure for unreferencing atoms */

{
	register long p;
	register unsigned char c;
	
	p = (long)cl + sizeof(stateClauseEntry);
	if (*(unsigned char *)p++ NE opUnifyAddr) {
		printf("Clause removal problem @ %08lX\n", p);
		return;
		}
	for (;;) {
		get(unsigned char, p, c);
		switch (c) {
			case opProceed:						/* neck */
			case opNeckCons1:					/* neckcon */
						return;
			
			case opSSGetCons:					/* get_cons_by_value(C) */
						p += sizeof(char);
			case opSSUnifyCons:					/* unif_cons_by_value(C) */
						get(unsigned char, p, c);
						constantLWA(p);
						if (c EQ opIntTag)
							p += sizeof(long);
						else if (c EQ opFloatTag) {
							fpLWA(p);
							p += sizeof(fp);
							}
						else if (c EQ opSymbolTag) {
							long l;
							stateString *s;
							
							get(long, p, l);
							s = (stateString *)l;
							unref(s);
							}
						break;

			case opGetCons:							/* get_cons(C) */
						p += sizeof(char);
			case opGetCons+1:
			case opGetCons+2:
			case opGetCons+3:
			case opGetCons+4:
			case opGetCons+5:
			case opGetCons+6:
			case opGetCons+7:
			case opUnifyCons:
						constantLWA(p);
						p += sizeof(long);
						break;

			case opGetValp:						/* get_valp(P, R) */
						p += sizeof(char);		/* skip register R */
			case opGetValp+1:
			case opGetValp+2:
			case opGetValp+3:
			case opGetValp+4:
			case opGetValp+5:
			case opGetValp+6:
			case opGetValp+7:
			case opUnifyVarp:					/* unify_varp(P) */
			case opUnifyValp:					/* unify_valp(P) */
			case opTUnifyVarp:					/* tunify_varp(P) */
			case opTUnifyValp:					/* tunify_valp(P) */
			case opCopyTemp:
						get(unsigned char, p, c);	/* get perm index */
						if (c EQ 0) {
							constantLWA(p);
							p += sizeof(envExtension);
							}
						break;

			case opGetStruct:					/* get_struct(N, R) */
			case opGetValt:						/* get_valt(T, R) */
			case 0x80:							/* get_vart(T, R) */
			case 0x88:							/* get_varp(P, R) */
						p += sizeof(char);
			case opGetStruct+1:
			case opGetStruct+2:
			case opGetStruct+3:
			case opGetStruct+4:
			case opGetStruct+5:
			case opGetStruct+6:
			case opGetStruct+7:
			case opGetList:						/* get_list(R) */
			case 0x28:							/* get_nil(R) */
			case opGetValt+1:
			case opGetValt+2:
			case opGetValt+3:
			case opGetValt+4:
			case opGetValt+5:
			case opGetValt+6:
			case opGetValt+7:
			case opUnifyVart:					/* unify_vart(T) */
			case opUnifyValt:					/* unify_valt(T) */
			case opTUnifyVart:					/* tunify_vart(T) */
			case opTUnifyValt:					/* tunify_valt(T) */
			case 0x81:
			case 0x82:
			case 0x83:
			case 0x84:
			case 0x85:
			case 0x86:
			case 0x87:
			case 0x89:
			case 0x8A:
			case 0x8B:
			case 0x8C:
			case 0x8D:
			case 0x8E:
			case 0x8F:
			case 0x90:
			case 0x98:
			case 0xA0:
			case 0xA8:
			case 0xB0:
			case 0xB8:
			case 0xC0:
			case 0xC8:
			case 0xD0:
			case 0xD8:
			case 0xE0:
			case 0xE8:
			case 0xF0:
			case 0xF8:
						p += sizeof(char);		/* skip register */
						break;
			}
		}
	}


/*****************************************************************************

   Copy Utilities

*****************************************************************************/

#define addOpcode(op)		*(char *)opptr++ = (char)op
						
#define addOpcodeReg(op, r)	if (r LE opMaxReg) { \
								addOpcode(op + r); \
								} \
							else { \
								addOpcode(op); \
								addOpcode(r); \
								}
				
#define addENVRegister(r)	if (r LT MAXREGS+MAXREGS) { \
								addOpcode(r - MAXREGS + 1); \
								} \
							else { \
								addOpcode(0); \
								constantLWA(opptr); \
								*(envExtension *)opptr = (envExtension)(r - MAXREGS + 1); \
								opptr += sizeof(long); \
								}
		
#define addOpcodeEnv(op, r)	if (r LE opMaxReg) { \
								addOpcode(op ## t + r); \
								} \
							else if (r LT MAXREGS) { \
								addOpcode(op ## t); \
								addOpcode(r); \
								} \
							else { \
								addOpcode(op ## p); \
								addENVRegister(r); \
								}
						
static BNRP_Boolean copyToStateSpace(TCB *tcb,
									BNRP_term x,
									stateString **functor,
									stateClauseEntry **cl)
{
	long currReg, nextReg = 0, s1, e1, s2, e2;
	long *space, *spacestart, *spaceend;
	long opptr;
	long dat, t, val, orig, result, addr, objarity, hash;
	size_t size;
	long LDCount, LDHold, LDk, LDSaveAddr;
	li arity;
	TAG tag;
	stateString *s;
	
	clearAM();
	/* X must be a structure */
	if (checkArg(x, &val) NE STRUCTT) return(FALSE);	
	get(long, val, arity.l);
	/* must have a symbol for a name */
	derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
	if (tag NE SYMBOLT) return(FALSE);
	if ((*functor = stateSpaceLookup(orig)) EQ NULL) return(FALSE);
	/* get first argument */
	derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
	hash = (tag EQ ENDT) ? 0 : computeKey(orig);
	LDCount = 1;
	LDHold = 2;
	LDk = 0;
	objarity = 0;
	while (tag NE ENDT) {
		/* copy all arguments to initial structure to registers */
		pushAM(orig, ((tag EQ VART) || (tag EQ TAILVART)) ? 2 : 0, ++nextReg);
		if (nextReg GT MAXREGS) BNRP_error(STATESPACETOOBIG);
		++objarity;
		if (tag EQ TAILVART) {
			objarity = -objarity;
			break;
			}
		/* get next piece */
		t = val;
		derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
		if (val LE t) {			/* possible loop */
			if (--LDCount LE 0) {
				if (LDk EQ 0) {
					LDk = LDHold;
					LDHold += LDHold;
					LDSaveAddr = val;
					}
				else {
					--LDk;
					if (LDSaveAddr EQ val)
						BNRP_error(STATESPACELOOP);
					}
				}
			}
		}

	/* get as much free space as possible */
	BNRP_freespace(tcb, &s1, &e1, &s2, &e2);
	if ((e1 - s1) GT (e2 - s2)) {
		space = spacestart = (long *)s1;
		spaceend = (long *)e1;
		}
	else {
		space = spacestart = (long *)s2;
		spaceend = (long *)e2;
		}
	headerLWA(space);
	opptr = (long)space;
	addOpcode(opUnifyAddr);			/* must be first opcode */
	addOpcode(opNOP);				/* in case we must issue an alloc */
	while (nextAM(&dat, &val, &currReg)) {
		long oldReg = currReg;
		if (currReg GE MAXREGS) {			/* out in the environment, move it back to a reg */
			addOpcode(opCopyTemp);
			addENVRegister(currReg);
			currReg = MAXREGS;				/* assumes opcode moves it to this register !!! */
			}
		switch (checkArg(dat, &val)) {
			case INTT:
						if (tagof(dat) EQ INTTAG) {			/* short integer */
							addOpcodeReg(opGetCons, currReg);
							val = dat;
							}
						else {
							addOpcode(opSSGetCons);
							addOpcode(currReg);
							addOpcode(opIntTag);
							}
						constantLWA(opptr);
						*(long *)opptr = val;
						opptr += sizeof(long) / sizeof(char);
						break;
			case FLOATT:
						addOpcode(opSSGetCons);
						addOpcode(currReg);
						addOpcode(opFloatTag);
#ifdef fpAlignment
						fpLWA(opptr);
#else
						constantLWA(opptr);
#endif
						*(fp *)opptr = *(fp *)val;
						opptr += sizeof(fp) / sizeof(char);
						break;
			case SYMBOLT:
						if ((SSContext LT 0) || 
							(BNRP_contextOf(symof(val), &s1, &s2) GT SSContext) ||
							((symof(val)->inuse NE INUSE) && (symof(val)->inuse NE INUSELOCAL))) {
							addOpcode(opSSGetCons);
							addOpcode(currReg);
							addOpcode(opSymbolTag);
							if ((s = stateSpaceLookup(val)) EQ NULL)
								BNRP_error(STATESPACENOSTRING);
							incref(s);
							val = (long)s;
							}
						else {
							addOpcodeReg(opGetCons, currReg);
							}
						constantLWA(opptr);
						*(long *)opptr = val;
						opptr += sizeof(long) / sizeof(char);
						break;
			case VART:
						/* do nothing unless it matches with a previous register */
						if ((searchAM(dat, 2, &addr)) && (addr NE oldReg)) {
							if (addr LE MAXREGS) {
								addOpcodeReg(opGetValt, currReg);
								addOpcode(addr);
								}
							else {
								addOpcodeReg(opGetValp, currReg);
								addENVRegister(addr);
								}
							}
						break;
			case TAILVART:
						/* not sure what to do, so leave register as is */
						break;
			case STRUCTT:
						get(long, val, arity.l);
						addOpcodeReg(opGetStruct, currReg);
						addOpcode(arity.i.b);
						goto addBody;
						
			case LISTT:
						addOpcodeReg(opGetList, currReg);
			addBody:
						LDCount = 1;
						LDHold = 2;
						LDk = 0;
						derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
						while (tag NE ENDT) {
							switch (tag) {
								case INTT:
											if (tagof(orig) EQ INTTAG) {	/* short integer */
												addOpcode(opUnifyCons);
												result = orig;
												}
											else {
												addOpcode(opSSUnifyCons);
												addOpcode(opIntTag);
												}
											constantLWA(opptr);
											*(long *)opptr = result;
											opptr += sizeof(long) / sizeof(char);
											break;
								case FLOATT:
											addOpcode(opSSUnifyCons);
											addOpcode(opFloatTag);
#ifdef fpAlignment
											fpLWA(opptr);
#else
											constantLWA(opptr);
#endif
											*(fp *)opptr = *(fp *)result;
											opptr += sizeof(fp) / sizeof(char);
											break;
								case SYMBOLT:
											if ((SSContext LT 0) || 
												(BNRP_contextOf(symof(orig), &s1, &s2) GT SSContext) ||
												((symof(orig)->inuse NE INUSE) && (symof(orig)->inuse NE INUSELOCAL))) {
												addOpcode(opSSUnifyCons);
												addOpcode(opSymbolTag);
												if ((s = stateSpaceLookup(orig)) EQ NULL)
													BNRP_error(STATESPACENOSTRING);
												incref(s);
												orig = (long)s;
												}
											else {
												addOpcode(opUnifyCons);
												}
											constantLWA(opptr);
											*(long *)opptr = orig;
											opptr += sizeof(long) / sizeof(char);
											break;
								case VART:
											orig = *(long *)addr;
											if ((addr = locateAM(orig, 2, &nextReg)) GT 0) {
												addOpcodeEnv(opUnifyVal, addr);
												}
											else {
												addOpcodeEnv(opUnifyVar, -addr);
												}
											break;
								case LISTT:
								case STRUCTT:
											if ((addr = locateAM(orig, 0, &nextReg)) GT 0) {
												addOpcodeEnv(opUnifyVal, addr);
												}
											else {
												addOpcodeEnv(opUnifyVar, -addr);
												}
											break;
								case TAILVART:
											orig = *(long *)addr;
											if ((addr = locateAM(orig, 2, &nextReg)) GT 0) {
												addOpcodeEnv(opTUnifyVal, addr);
												}
											else {
												addOpcodeEnv(opTUnifyVar, -addr);
												}
											goto doneBody;
								}
							/* get next symbol */
							t = val;
							derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
							if (val LE t) {			/* possible loop */
								if (--LDCount LE 0) {
									if (LDk EQ 0) {
										LDk = LDHold;
										LDHold += LDHold;
										LDSaveAddr = val;
										}
									else {
										--LDk;
										if (LDSaveAddr EQ val)
											BNRP_error(STATESPACELOOP);
										}
									}
								}
							}
						addOpcode(opEndSeq);
				doneBody:
						break;
			}
		}
	addOpcode(opNeckCons1);
	addOpcode(opNeckCons2);
	addOpcode(opNeckCons3);
	if (nextReg GE MAXREGS) {
		char *p = (char *)space;
		++p;						/* skip first opcode */
		*p = opAlloc;				/* issue an alloc at beginning */
		addOpcode(opDealloc);		/* issue dealloc at end */
		}
	addOpcode(opProceed);
	size = (size_t)((long)opptr - (long)space);
	*cl = (stateClauseEntry *)allocSpaceInStateSpace(sizeof(stateClauseEntry) + size);
	(*cl)->obj = NULL;
	(*cl)->cl.key = hash;
	(*cl)->cl.nextClause = (*cl)->cl.nextSameKeyClause = NULL;
	(*cl)->cl.arity = objarity;
	memcpy((void *)((long)(*cl)+sizeof(stateClauseEntry)), space, size);
#ifdef check
	if (offsetof(stateClauseEntry, cl) & (headerAlignment -1))
		printf("Warning: clause field in stateClauseEntry not properly aligned\n");
	if (sizeof(stateClauseEntry) & (headerAlignment -1))
		printf("Warning: stateClauseEntry not properly size\n");
#endif
#ifdef trace
	printf("Saving item @ %08lx (clause header @ %08lx)\n", (long)(*cl)+sizeof(stateClauseEntry), (long)(*cl));
#endif
	freeAM();
	return(TRUE);
	}

BNRP_term BNRP_lookupStateSpace(long *ppc, long *hp, long *te)
{
	unsigned char c;
	long l;
	
	get(unsigned char, *ppc, c);		/* mask */
	constantLWA(*ppc);
	if (c EQ opSymbolTag) {
		stateString *s;
		get(long, *ppc, l);
		s = (stateString *)l;
		return(BNRPMakeSymbol(s->sym.hash, s->sym.name, TEMPSYM, (*s->sym.name NE '$'), te, s->origContext));
		}
	else if (c EQ opIntTag) {
		get(long, *ppc, l);
		return(makeint(hp, l));
		}
	else if (c EQ opFloatTag) {
		fpLWA(*ppc);
		l = makefloat(hp, (fp *)*ppc);
		*ppc += sizeof(fp);
		return(l);
		}
	return(0);
	}


/*****************************************************************************

 Store object

*****************************************************************************/

#ifdef silly
static void checkClauseChain(clauseEntry *first, char *msg)
{

	clauseEntry *curr = first;
	while (curr NE NULL) {
		clauseEntry *next = curr->nextClause, *find = curr->nextSameKeyClause;
		
		while (next NE find) {
			if (next EQ NULL) fprintf(stderr, "%s: Unable to find nextSame clause for %08lx\n", msg, (long)curr);
			next = next->nextClause;
			}
		if (curr->key EQ 0) {
			if (curr->nextClause NE find) {
				fprintf(stderr, "%s: Key of 0, next (%lx) NE nextSameKey (%lx), clause %lx\n", 
								msg, (long)curr->nextClause, (long)curr->nextSameKeyClause, (long)curr);
				curr->nextSameKeyClause = curr->nextClause;
				}
			}
		else if (find NE NULL) {
			next = curr->nextClause;
			while ((next->key NE 0) && (next->key NE curr->key)) {
				next = next->nextClause;
				if (next EQ NULL) break;
				}
			if (next NE find)
				fprintf(stderr, "%s: Wrong next key linkage for %08lx\n", msg, (long)curr);
			}
		curr = curr->nextClause;
		}
	}
#endif

static void insertClauseBefore(stateString *functor, 
							   clauseEntry *object, 
							   clauseEntry *nextCl)

/* insert clause 'object' into 'functor's clause chain before clause 'nextCl' */

{
	long key;
	clauseEntry *curr, *last, *lastSameKey;
	
	key = object->key;
#ifdef silly
	checkClauseChain(functor->sym.firstClause, "Before insertClauseBefore");
#endif
	curr = functor->sym.firstClause;
	last = lastSameKey = NULL;
	while (curr NE nextCl) {
		if ((curr->key EQ key) || (curr->key EQ 0))
			lastSameKey = curr;
		if (key EQ 0)
			if (curr->nextSameKeyClause EQ NULL)
				curr->nextSameKeyClause = object;
		last = curr;
		curr = curr->nextClause;
		}
	/* now insert the clause */
	if (last EQ NULL) {
		object->nextClause = functor->sym.firstClause;
		functor->sym.firstClause = object;
		}
	else {
		object->nextClause = last->nextClause;
		last->nextClause = object;
		if (last->key EQ 0) last->nextSameKeyClause = object;
		if (lastSameKey NE NULL) {
			if (lastSameKey->key NE 0) {
				object->nextSameKeyClause = lastSameKey->nextSameKeyClause;
				lastSameKey->nextSameKeyClause = object;
#ifdef silly
				checkClauseChain(functor->sym.firstClause, "After quick insertClauseBefore");
#endif
				return;
				}
			}
		}
	/* check from here forward to fill in nextSameKeyClause value */
	if (key EQ 0)
		object->nextSameKeyClause = object->nextClause;
	else
		while (nextCl NE NULL) {
			if ((nextCl->key EQ key) || (nextCl->key EQ 0)) {
				object->nextSameKeyClause = nextCl;
				break;
				}
			nextCl = nextCl->nextClause;
			}
#ifdef silly
	checkClauseChain(functor->sym.firstClause, "After insertClauseBefore");
#endif
	}

static void unlinkClause(stateString *functor, clauseEntry *object)

/* remove references to clause 'object' into 'functor's clause chain */

{
	register clauseEntry *curr;
	long key;
	
#ifdef silly
	checkClauseChain(functor->sym.firstClause, "Before unlinkClause");
#endif
	if ((curr = functor->sym.firstClause) EQ object) {
		functor->sym.firstClause = object->nextClause;
		/* no need to relink clauses at all */
		return;
		}
	key = object->key;
	while (curr NE NULL) {
		if (curr->nextSameKeyClause EQ object) {
			if (curr->key EQ key)		/* could be n -> n or 0 -> 0 */
				curr->nextSameKeyClause = object->nextSameKeyClause;
			else if (key NE 0)			/* 0 -> n */
				curr->nextSameKeyClause = object->nextClause;
			else {						/* n -> 0, search for next possible clause */
				clauseEntry *next = object->nextClause;
				while (next NE NULL) {
					if (next->key EQ curr->key) break;
					if (next->key EQ 0) break;
					next = next->nextClause;
					}
				curr->nextSameKeyClause = next;
				}
			}
		if (curr->nextClause EQ object) {
			curr->nextClause = object->nextClause;
			break;
			}
		curr = curr->nextClause;
		}
#ifdef silly
	checkClauseChain(functor->sym.firstClause, "After unlinkClause");
#endif
	}

static BNRP_Boolean Remember(TCB *tcb, BNRP_term x, long *index, BNRP_Boolean front)

/* Stores structure x in state space- */
/* it must be a functor (NOT a list) */
/* returns FALSE if no room or structure exceeds depth limit  */

{
	stateString *functor;
	stateClauseEntry *cl;
	stateObject *obj;

	if (!copyToStateSpace(tcb, x, &functor, &cl)) return(FALSE);

	obj = (stateObject *)allocSpaceInStateSpace(sizeof(stateObject));
	obj->tag = ObjT;
	obj->father = functor;
	incref(functor);				/* clause reference */
	obj->cl = cl;
	cl->obj = obj;
	*index = (long)obj;

	insertClauseBefore(functor, &cl->cl, (front) ? functor->sym.firstClause : NULL);
	return(TRUE);
	}


static BNRP_Boolean Replace(TCB *tcb, long l, BNRP_term x)

/* Stores structure x in state space, replacing what is pointed to by l */
/* Returns FALSE if x NOT a functor or no room */

{
	stateObject *obj;
	stateString *functor;
	stateClauseEntry *cl;
	clauseEntry *next;

	obj = (stateObject *)l;
	if (obj->tag NE ObjT) return(FALSE);
	
	/* copy new term to state space */
	if (copyToStateSpace(tcb, x, &functor, &cl)) {
		if (functor EQ obj->father) {
			next = obj->cl->cl.nextClause;
			removeClauseReferences(obj->cl);
			unlinkClause(functor, &obj->cl->cl);
			deallocSpaceInStateSpace(obj->cl);
			obj->cl = cl;
			cl->obj = obj;
			insertClauseBefore(functor, &cl->cl, next);
			return(TRUE);
			}
		deallocSpaceInStateSpace(cl);
		}
	return(FALSE);
	}


/*****************************************************************************

 Forget

*****************************************************************************/

static BNRP_Boolean Forget(long l)

/* removes object from state space */

{
	stateObject *obp;
	spaceHeader *s;

	obp = (stateObject *)l;
	if (obp->tag NE ObjT) return(FALSE);
	s = (spaceHeader *)(l - sizeof(spaceHeader));
	if (s->space->state NE currState) return(FALSE);
	removeClauseReferences(obp->cl);		/* scan clause, removing references to ss atoms */
	unlinkClause(obp->father, &obp->cl->cl);/* unlink from clause chain */
	deallocSpaceInStateSpace(obp->cl);		/* dispose clause */
	unref(obp->father);						/* remove clause reference to name */
	deallocSpaceInStateSpace(obp);			/* dispose object */
	return(TRUE);
	}

/***************************************************************************

 State Space Primitives

***************************************************************************/

#define validate(i, id)		if (tcb->numargs EQ i-1)							\
								id = GlobalId;									\
							else if ((tcb->numargs NE i) || 					\
									 (checkArg(tcb->args[i], &id) NE SYMBOLT))	\
								return(FALSE)

#define findit(id, i, b)	if (id EQ CurrentId)					\
								i = CurrentIndex;					\
							else if (!ComputeIndex(id, &i, b))		\
								return(FALSE)

#ifdef executiontrace
#define preamble		printf("Starting execution of goal %s\n", nameof(tcb->procname)); \
						if (tcb->numargs GE 1) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[1]); printf("\n"); } \
						if (tcb->numargs GE 2) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[2]); printf("\n"); } \
						if (tcb->numargs GE 3) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[3]); printf("\n"); } \
						if (tcb->numargs GE 4) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[4]); printf("\n"); } \
						if (tcb->numargs GE 5) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[5]); printf("\n"); }
#define alldone(r)		if (r) { \
							printf("Succeeding goal %s\n", nameof(tcb->procname)); \
							if (tcb->numargs GE 1) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[1]); printf("\n"); } \
							if (tcb->numargs GE 2) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[2]); printf("\n"); } \
							if (tcb->numargs GE 3) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[3]); printf("\n"); } \
							if (tcb->numargs GE 4) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[4]); printf("\n"); } \
							if (tcb->numargs GE 5) { printf("     "); BNRP_dumpArg(stdout, tcb, tcb->args[5]); printf("\n"); } \
							} \
						else \
							printf("Failing goal %s\n", nameof(tcb->procname)); \
						return(r)
#else
#define preamble
#define alldone(r)		return(r)
#endif


BNRP_Boolean BNRP_newState(TCB *tcb)				/* create a new state space */
{
	BNRP_term CheckID;
	TAG tag;
	long Size;
	short Index;
	BNRP_Boolean res = FALSE;

	preamble;
	validate(2, CheckID);
	tag = checkArg(tcb->args[1], &Size);
	if (tag EQ VART) {					/* we only want to query size */
		if (ComputeIndex(CheckID, &Index, FALSE))
			Size = StateInfo[Index].stateSpaceSize = StateInfo[Index].stateSpaceMemory->tot_size / 1024;
		else
			Size = 0;
		res = unify(tcb, tcb->args[1], makeint(&tcb->hp, Size));
		}
	else if (tag EQ INTT) {				/* set size, fail if different */
		if (Size EQ 0) {
			if (ComputeIndex(CheckID, &Index, FALSE))
			/* if such a state space exists remove it */
				RemoveStateSpace(Index);
			res = TRUE;
			}
		else if (Size GE 3)
			res = BNRP_NewStatespace(Size, CheckID);
		}
	alldone(res);
	}


BNRP_Boolean BNRP_changedState(TCB *tcb)			/* see if state space has changed */
{
	BNRP_term CheckID;
	short Index;

	validate(1, CheckID);
	if (ComputeIndex(CheckID, &Index, FALSE))
		return(StateInfo[Index].Changed);
	else
		return(FALSE);
	}


static BNRP_Boolean inStateSpace(long addr)
{
	stateSpace *s;
	long diff;

	s = currState->firstSpace;
	while (s NE NULL) {
		diff = addr - (long)s;
		if ((diff GE 0) && (diff LE s->size)) return(TRUE);
		s = s->next;
		}
	return(FALSE);
	}


BNRP_Boolean BNRP_getStateSpaceAtom(TCB *tcb)
{
	BNRP_term CheckID, val, orig;
	short Index;
	TAG tag;
	stateString *s;
	stateObject *o;
	BNRP_Boolean res = FALSE;

	preamble;
	validate(4, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, FALSE);
	tag = checkArg(tcb->args[1], &val);
	if ((tag EQ INTT) && inStateSpace(val)) {
		o = (stateObject *)val;
		if (o->tag EQ ObjT) {
			s = o->father;
			if ((s NE NULL) && (s->sym.firstClause NE NULL)) {
				val = maketerm(SYMBOLTAG, (long)&s->sym);
				orig = BNRPMakeSymbol(s->sym.hash, s->sym.name, TEMPSYM, (*s->sym.name NE '$'), &tcb->te, s->origContext);
				res = unify(tcb, tcb->args[2], orig) && unify(tcb, tcb->args[3], val);
				}
			}
		}
	else if ((tag EQ VART) && (checkArg(tcb->args[2], &val) EQ SYMBOLT)) {
		s = stateSpaceFind(val);
		if ((s NE NULL) && (s->sym.firstClause NE NULL)) {
			val = maketerm(SYMBOLTAG, (long)&s->sym);
			res = unify(tcb, tcb->args[3], val);
			}
		}
	alldone(res);
	}


BNRP_Boolean BNRP_newObj(TCB *tcb)				/* create a new object */
{
	BNRP_term CheckID;
	short Index;
	long loc;
	BNRP_Boolean res = FALSE;

	preamble;
	validate(3, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, TRUE);
	if (checkArg(tcb->args[2], &loc) EQ VART)
		if (Remember(tcb, tcb->args[1], &loc, TRUE))
			res = unify(tcb, tcb->args[2], makeint(&tcb->hp, loc));
	ReleaseStateSpace(Index);
	alldone(res);
	}


BNRP_Boolean BNRP_zNewObj(TCB *tcb)				/* create a new object at the end of the chain */
{
	BNRP_term CheckID;
	short Index;
	long loc;
	BNRP_Boolean res = FALSE;

	preamble;
	validate(3, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, TRUE);
	if (checkArg(tcb->args[2], &loc) EQ VART)
		if (Remember(tcb, tcb->args[1], &loc, FALSE))
			res = unify(tcb, tcb->args[2], makeint(&tcb->hp, loc));
	ReleaseStateSpace(Index);
	alldone(res);
	}


BNRP_Boolean BNRP_putObj(TCB *tcb)				/* replace an object */
{
	BNRP_term CheckID;
	short Index;
	BNRP_Boolean res = FALSE;
	long loc;

	preamble;
	validate(3, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, TRUE);
	if ((checkArg(tcb->args[1], &loc) EQ INTT) && inStateSpace(loc))
		res = Replace(tcb, loc, tcb->args[2]);
	ReleaseStateSpace(Index);
	alldone(res);
	}


BNRP_Boolean BNRP_forgetObj(TCB *tcb)			/* forget an object */
{
	BNRP_term CheckID;
	short Index;
	long loc;
	BNRP_Boolean res = FALSE;

	preamble;
	validate(2, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, TRUE);
	if ((checkArg(tcb->args[1], &loc) EQ INTT) && inStateSpace(loc))
		res = Forget(loc);
	ReleaseStateSpace(Index);
	alldone(res);
	}


BNRP_Boolean BNRP_hashList(TCB *tcb)				/* get the hash list */
/* Logic: given a valid index into the hash table, returns
          a token pointer into the list; fails if index out of
          range;  use NextObj to walk through the list */
{
	BNRP_term CheckID, result;
	short Index;
	long val, lastaddr;
	BNRP_Boolean res = FALSE;
	ringHeader *r;
	stateString *ss;

	preamble;
	validate(3, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, FALSE);
	if (checkArg(tcb->args[1], &val) EQ INTT) {
		if ((val GE 0) && (val LT SMODULUS)) {
			r = currState->hshtab[val];
			result = maketerm(LISTTAG, tcb->hp);
			while (r NE NULL) {
				if (r->tag EQ StrT) {
					lastaddr = tcb->hp;
					push(long, tcb->hp, 0);		/* filler for now */
					ss = (stateString *)r;
					val = BNRPMakeSymbol(ss->sym.hash, 
										 ss->sym.name, 
										 TEMPSYM, 
										 (*ss->sym.name NE '$'), 
										 &tcb->te, 
										 ss->origContext);
					/* may have created new symbol so check */
					if (lastaddr + sizeof(long) NE tcb->hp) {
						push(long, tcb->hp, val);
						val = maketerm(TVTAG, (tcb->hp - sizeof(long)));
						}
					*(long *)lastaddr = val;
					}
				r = r->next;
				if (r->tag EQ RingT) break;
				}
			push(long, tcb->hp, 0);
			res = unify(tcb, tcb->args[2], result);
			}
		}
	ReleaseStateSpace(Index);
	alldone(res);
	}


BNRP_Boolean BNRP_stateSpaceStats(TCB *tcb)		/* return state space usage info */
{
	BNRP_term CheckID;
	short Index;
	long allocated, used;
	stateSpace *s;
	freeRecord *f;

	validate(3, CheckID);
	if (CheckID EQ CurrentId)
		Index = CurrentIndex;
	else if (!ComputeIndex(CheckID, &Index, FALSE))
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, 0)) &&
			   unify(tcb, tcb->args[2], makeint(&tcb->hp, 0)));
	LocateStateSpace(Index, FALSE);
	used = allocated = currState->tot_size;
	s = currState->firstSpace;
	while (s NE NULL) {
		f = s->freep;
		while (f NE NULL) {
			used -= f->bytesize;
			f = f->next;
			}
		s = s->next;
		}
	ReleaseStateSpace(Index);
	return(unify(tcb, tcb->args[1], makeint(&tcb->hp, allocated)) &&
		   unify(tcb, tcb->args[2], makeint(&tcb->hp, used)));
	}

BNRP_Boolean BNRP_dumpSS(TCB *tcb)
{
	BNRP_term CheckID;
	short Index, i;
	ringHeader *r;
	stateString *ss;
	clauseEntry *p;

	preamble;
	validate(1, CheckID);
	findit(CheckID, Index, FALSE);
	LocateStateSpace(Index, FALSE);
	for (i = 0; i LT SMODULUS; ++i) {
		if ((r = currState->hshtab[i]) NE NULL) {
			printf("Entry %d\n", i);
			while (r NE NULL) {
				if (r->tag EQ StrT) {
					ss = (stateString *)r;
					printf("  %p %5ld %s\n", ss, ss->refCount, ss->sym.name);
					p = ss->sym.firstClause;
					while (p NE NULL) {
						printf("    %p -> %p %p %08lX %ld\n", p, p->nextClause, p->nextSameKeyClause, p->key, p->arity);
						p = p->nextClause;
						}
					}
				r = r->next;
				if (r->tag EQ RingT) break;
				}
			}
		}
	ReleaseStateSpace(Index);
	alldone(TRUE);
	}
