/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/interpreter.h,v 1.2 1997/12/22 17:01:27 harrisj Exp $
*
*  $Log: interpreter.h,v $
 * Revision 1.2  1997/12/22  17:01:27  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:24:48  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_interpreter
#define _H_interpreter

#include "base.h"

#define LASTAST	(symbolEntry *)0xABCDABCD

BNRP_term makeint(long *address, long value);
BNRP_term makefloat(long *address, fp *value);
void BNRP_freespace(TCB *tcb, long *s1, long *e1, long *s2, long *e2);

long computeKey(long arg);
BNRP_term lookupExisting(TCB *tcb, symbolEntry *s);
void insertExisting(TCB *tcb, symbolEntry *s);

/* int initializeTCB(TCB *tcb, 
				  long heapAndTrail, 
				  long envAndCP); 	REMOVED 20/06/94 */

void initialGoal(TCB *tcb, BNRP_term a, int arity);
BNRP_Boolean unify(TCB *tcb, long t1, long t2);
void unifyQuick(TCB *tcb, long t1, long t2);
BNRP_Boolean checkArity(long arity1, long arity2);
void BNRP_gc(long esize, choicepoint *lcp, long *hp, long ce, long te);
void BNRP_gc_proceed(choicepoint *lcp, long *hp, long te, long *regs);
extern long BNRP_numGC;

void abortHandler(int sig);
void arithHandler(int sig);

#endif
