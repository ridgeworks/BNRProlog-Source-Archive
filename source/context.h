/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/context.h,v 1.2 1997/08/12 17:34:48 harrisj Exp $
*
*  $Log: context.h,v $
 * Revision 1.2  1997/08/12  17:34:48  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.1  1995/09/22  11:23:37  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_context
#define _H_context

#include "core.h"

#define PERMTABLEMODULUS	256		/* must be a power of 2 */

BNRP_Boolean BNRPnewContext(long name1, long name2);

clauseEntry *BNRP_addClause(BNRP_term pred, long arity, long key, long size, void *data, BNRP_Boolean addFront);
BNRP_Boolean BNRP_insertClause(BNRP_term pred, long arity, long key, void *data);
BNRP_Boolean BNRP_removeClause(BNRP_term pred, clauseEntry *clp);
long BNRP_contextOf(void *clp, long *name1, long *name2);
BNRP_term BNRPMakePermInt(long value);
BNRP_term BNRPMakePermFloat(fp *value);
BNRP_term BNRPMakeSymbol(int h, const char *s, BNRP_Boolean temp, BNRP_Boolean global, long *te, long contextGeneration);
BNRP_term BNRPLookupPermSymbol(const char *s);
BNRP_term BNRPLookupTempSymbol(TCB *tcb, const char *s);
void BNRP_cleanupTempSymbols(void);
void BNRPSetBaseFileName(const char *s);

BNRP_Boolean BNRP_addOperator(BNRP_term symbol, int newType, int newPrecedence);
BNRP_Boolean BNRP_setLocked(BNRP_term symbol, BNRP_Boolean newval);
BNRP_Boolean BNRP_setClosed(BNRP_term symbol, BNRP_Boolean newval);
BNRP_Boolean BNRP_setDebug(BNRP_term symbol, short newval);
BNRP_Boolean BNRP_queryLocked(BNRP_term symbol);
BNRP_Boolean BNRP_queryClosed(BNRP_term symbol);
short BNRP_queryDebug(BNRP_term symbol);
void BNRP_makeSymbolPermanent(BNRP_term symbol);
symbolEntry *BNRP_getNextSymbol(symbolEntry *p);
void BNRP_setAllDebugBits(long andMask, long orMask);

BNRP_Boolean BNRP_enterContext(TCB *tcb);
BNRP_Boolean BNRP_exitContext(TCB *tcb);
BNRP_Boolean BNRP_listContexts(TCB *tcb);
BNRP_Boolean BNRP_isPrimitive(TCB *tcb);
BNRP_Boolean BNRP_predicateSymbol(TCB *tcb);
BNRP_Boolean BNRP_prevPredicate(TCB *tcb);
BNRP_Boolean BNRP_prevSymbol(TCB *tcb);
BNRP_Boolean BNRP_closeDefinition(TCB *tcb);
BNRP_Boolean BNRP_closedDefinition(TCB *tcb);
BNRP_Boolean BNRP_hideDefinition(TCB *tcb);
BNRP_Boolean BNRP_notHiddenDefinition(TCB *tcb);
BNRP_Boolean BNRP_getContextOf(TCB *tcb);

#endif
