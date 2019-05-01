/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/state.h,v 1.1 1995/09/22 11:28:43 harrisja Exp $
*
*  $Log: state.h,v $
 * Revision 1.1  1995/09/22  11:28:43  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_state
#define _H_state

BNRP_term BNRP_lookupStateSpace(long *ppc, long *hp, long *te);
void BNRP_removeStateSpaces(long generation);

BNRP_Boolean BNRP_NewStatespace(long size, BNRP_term CheckID);

BNRP_Boolean BNRP_newState(TCB *tcb);			/* create a new state space */
BNRP_Boolean BNRP_changedState(TCB *tcb);		/* see if state space has changed */
BNRP_Boolean BNRP_getStateSpaceAtom(TCB *tcb);	/* get the reference for the ss symbol */
BNRP_Boolean BNRP_newObj(TCB *tcb);				/* create a new object */
BNRP_Boolean BNRP_zNewObj(TCB *tcb);			/* create a new object at the end of the chain */
BNRP_Boolean BNRP_putObj(TCB *tcb);				/* replace an object */
BNRP_Boolean BNRP_forgetObj(TCB *tcb);			/* forget an object */
BNRP_Boolean BNRP_hashList(TCB *tcb);			/* get the hash list */
BNRP_Boolean BNRP_stateSpaceStats(TCB *tcb);	/* return state space usage info */
BNRP_Boolean BNRP_dumpSS(TCB *tcb);

#endif
