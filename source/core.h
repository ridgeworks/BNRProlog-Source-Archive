/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/core.h,v 1.2 1997/12/22 17:00:59 harrisj Exp $
*
*  $Log: core.h,v $
 * Revision 1.2  1997/12/22  17:00:59  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:23:42  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_core
#define _H_core

#include "BNRProlog.h"

#define VARMASK			0x00000000
#define VARTAG				VARMASK
#define TAILVARMASK		0x20000000
#define TAILVARTAG          TAILVARMASK
#define TVTAG               TAILVARMASK
#define LISTMASK        0xA0000000
#define LISTTAG             LISTMASK
#define STRUCTMASK      0x80000000
#define STRUCTTAG           STRUCTMASK
#define INTMASK         0xC0000000
#define INTTAG              INTMASK
#define SYMBOLMASK      0xE0000000
#define SYMBOLTAG           SYMBOLMASK
#define isVAR(x)		((tagof(x) EQ VARTAG) && (x NE 0))
#define isTV(x)			(tagof(x) EQ TVTAG)

#define STRUCTHEADER    0x8CBE0000
#define UNARYHEADER     0x8CBE0002          /* include atom in count */
#define BINARYHEADER    0x8CBE0003          /* include atom in count */
#define FUNCID          STRUCTHEADER
#define FUNCIDshort     ((short)0x8CBE)
#define NUMBERID        0x0ABC0000
#define NUMBERIDshort   0x0ABC
#define INTIDshort		1
#define INTID			(NUMBERID | INTIDshort)
#define FLOATIDshort	2
#define FLOATID			(NUMBERID | FLOATIDshort)
#define CONSTRAINTMARK	0xFFFFFFFF
#define VARIABLEMARK	0xFFFFFFFE

typedef struct clauseEntry clauseEntry;
struct clauseEntry {
	long key;
	clauseEntry *nextClause;
	clauseEntry *nextSameKeyClause;
	long arity;
	};					/* clause follows immediately */

typedef struct symbolEntry symbolEntry;
struct symbolEntry {
	clauseEntry *firstClause;
	symbolEntry *chain;
	symbolEntry *self;
	short opType;				/* opType, opPrec must be in the same longword */
	short opPrecedence;
	unsigned char locked;		/* locked, closed, debug must be in same longword */
	unsigned char closed;
	short debug;
	unsigned char inuse;		/* must be on a longword boundary !! */
	unsigned char hash;
	char name[1];				/* actual name, room for /0 */
	};
#define notOp		0x00		/* values for opType */
#define xf			0x01
#define yf			0x02
#define fy			0x04
#define fx			0x08
#define yfx			0x10
#define xfy			0x20
#define xfx			0x40
#define bracket		0x80
/* values for inuse */
#define UNUSED			0x00
#define INUSE			0xFF
#define INUSELOCAL		0x11
#define INUSETEMPGLOBAL	0xAA
#define INUSETEMPLOCAL	0x55

#define symof(index)		((symbolEntry *)addrof(index))
#define checksym(index, s)	s = symof(index); \
							if (s NE s->self) BNRP_error(DANGLINGREFERENCE);
#define nameof(index)		symof(index)->name

typedef struct choicepoint choicepoint;
struct choicepoint {
	long clp;			/* next clause pointer */
	long key;			/* key for next clause access */
	long critical;		/* end of previous environment, needed for trailing */
	long hp;			/* heap pointer */
	choicepoint *lcp;	/* previous choicepoint */
	long te;			/* trail end */
	long bce;			/* previous environment */
	long bcp;			/* continuation */
	long procname;		/* name of procedure to restore */
#define numRegs	args[0]	/* number of registers saved */
	long args[1];		/* arguments, room for [0] which is numregs */
/* 	long b;				   current top of stack */
/*	choicepoint *cutb;	   cutb register */
	};

/* tags must be sorted in order for compares */
enum TAG {ENDT, VART, TAILVART, INTT, FLOATT, SYMBOLT, LISTT, STRUCTT};
typedef enum TAG TAG;

#define NAME	-3				/* offsets into current environment */
#define CUTB	-2
#define CE		-1
#define CP		0
#define env(e, offset)			*(long *)(e + ((offset) * sizeof(long)))

/* runtime errors */
#define OUTOFCHOICEPOINTS			-1			/* i.e. goal fails */
#define DANGLINGREFERENCE			1
#define UNEXECUTABLETERM			16
#define OUTOFMEMORY					100
#define STATESPACENOMEMORY				OUTOFMEMORY
#define CONTEXTFULL						OUTOFMEMORY
#define LOADNOSPACE						OUTOFMEMORY
#define LOADTOOMANYSYMBOLS				OUTOFMEMORY
#define LOADNOTEMPSPACE					OUTOFMEMORY
#define OUTOFTEMPSPACE					OUTOFMEMORY
#define OUTOFAMSPACE					OUTOFMEMORY
#define GLOBALSTACKOVERFLOW			101
#define HEAPOVERFLOW					GLOBALSTACKOVERFLOW
#define TRAILOVERFLOW					GLOBALSTACKOVERFLOW
#define LOCALSTACKOVERFLOW			102
#define ENVOVERFLOW						LOCALSTACKOVERFLOW
#define CPOVERFLOW						LOCALSTACKOVERFLOW
#define NAMEDCUTNOTFOUND			103
#define DIVIDEBY0					104
#define ARITHERROR					105
/*****
#define UNABLETOLOADSTATESPACE		106
#define BADSTATESPACEVERSION			UNABLETOLOADSTATESPACE
#define BADITEMINSTATESPACE				UNABLETOLOADSTATESPACE
#define BADSTATESPACESIZE				UNABLETOLOADSTATESPACE
*****/
#define STATESPACECORRUPT			107
#define STATESPACEBADALLOC				STATESPACECORRUPT
#define STATESPACEBADFREELIST			STATESPACECORRUPT
#define STATESPACEBADRING				STATESPACECORRUPT
#define STATESPACEBADTAG				STATESPACECORRUPT
#define STATESPACENOSTRING				STATESPACECORRUPT
#define STATESPACEBADOPCODE				STATESPACECORRUPT
#define STATESPACELOOP				108
#define INTERNALERROR				109
#define INVALIDSYMBOLINCALL				INTERNALERROR
#define BADSTATESPACEHEADER				INTERNALERROR
#define NOPROCEDUREDEFINED				INTERNALERROR
#define STATESPACETOOBIG			110
#define CLOSEDCLAUSE				111

/* I/O errors, try to avoid I/O errors generated by the system */
#define IOERROR						9999
#define UNABLETOCLOSESTREAM			9998
#define STREAMNOTOPEN				9997
#define BADFILENAME					9996

/* syntax errors, attempt to be compatible with BNRProlog 3.0 */
#define NOMORE				-39
#define UNEXPECTEDEOF		2
#define MISSINGOPERAND		4
#define BADCHARACTER		16
#define BADTAILVAR			17
#define MISSINGOPERATOR		20
#define BRACKETMISMATCH		24
#define NOMOREOPCHOICES		30
#define NOTPREFIXOP			30
#define KILLED				33
#define INCOMPLETE			34
#define SYNTAX				35
#define UNEXPECTEDACTION	36
#define TOOMANYARGS			42
#define MISMATCHEDBRACKETS	43
#define BADINTEGER			44
#define VERTICALNOTINLIST	45
#define UNRECOGNIZEDOPTYPE	46
#define COMMENTNOTCOMPLETE	47

extern void (*BNRPerrorhandler)();
#define onerrorexecute(p)				BNRPerrorhandler = p

long BNRP_RESUME(TCB *p);

#ifdef HSC
long BNRP_RESUME2(TCB *p);
BNRP_Boolean fixArities(TCB* tcb, long* callerArity, long* calleeArity);
#endif

BNRP_Boolean BNRP_quit(TCB *tcb);
long BNRP_CheckAlignment();

BNRP_Boolean BNRP_iterate(TCB *p);
BNRP_Boolean BNRP_fuzz(TCB *p);

#ifdef HSC
BNRP_Boolean inClause = 0;
long clauseList;
#endif

#define envExtension	long
#define MAX_ARITH	8
#endif
