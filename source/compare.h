/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/compare.h,v 1.1 1995/09/22 11:23:17 harrisja Exp $
*
*  $Log: compare.h,v $
 * Revision 1.1  1995/09/22  11:23:17  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_compare
#define _H_compare

BNRP_Boolean BNRP_breadth_first_compare(TCB *tcb);
BNRP_Boolean BNRP_first_var(TCB *tcb);
BNRP_Boolean BNRP_var_list(TCB *tcb);
BNRP_Boolean BNRP_spanning_tree(TCB *tcb);
BNRP_Boolean BNRP_decompose(TCB *tcb);
BNRP_Boolean BNRP_acyclic(TCB *tcb);
BNRP_Boolean BNRP_ground(TCB *tcb);

#endif
