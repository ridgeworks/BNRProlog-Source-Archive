/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/memory.h,v 1.1 1995/09/22 11:25:22 harrisja Exp $
*
*  $Log: memory.h,v $
 * Revision 1.1  1995/09/22  11:25:22  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_memory
#define _H_memory

#include "core.h"

void BNRP_initMemory(void);
int BNRP_allocMemory(TCB *tcb, 
					 long heapAndTrail, 
					 long envAndCP);
void BNRP_disposeMemory(TCB *tcb);

#endif
