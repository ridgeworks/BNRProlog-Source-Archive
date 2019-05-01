/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/tasking.h,v 1.1 1995/09/22 11:28:57 harrisja Exp $
*
*  $Log: tasking.h,v $
 * Revision 1.1  1995/09/22  11:28:57  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_tasking
#define _H_tasking

int BNRP_initializeTask(TCB *tcb, long heap_trailSize, long env_cpSize,TCB *current_task);

BNRP_Boolean BNRP_init_task(TCB * tcb);
BNRP_Boolean BNRP_end_task(TCB * tcb);
BNRP_Boolean BNRP_next_task(TCB * tcb);
BNRP_Boolean BNRP_task_switch(TCB ** tcb);
BNRP_Boolean BNRP_reply(TCB * tcb);
BNRP_Boolean BNRP_self(TCB * tcb);
BNRP_Boolean BNRP_selfID(TCB *tcb);
BNRP_Boolean BNRP_test_task(TCB * tcb);
BNRP_Boolean BNRP_task_status(TCB * tcb);
BNRP_Boolean BNRP_removeTaskFromChain(TCB ** tcb);
#endif
