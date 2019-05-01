/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/memory.c,v 1.2 1997/12/22 17:01:30 harrisj Exp $
*
*  $Log: memory.c,v $
 * Revision 1.2  1997/12/22  17:01:30  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:25:20  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#ifndef unix
#include <stdlib.h>		/* for exit */
#endif
#include "core.h"
#include "memory.h"
#include "hardware.h"
#ifdef Macintosh
#include <LowMem.h>
#endif

#ifdef adjustMemory
long BNRP_baseOffset;
int BNRP_adjusted = 0;
#endif

void BNRP_initMemory()
{
#ifdef adjustMemory
	char *mem;
	
	if (!BNRP_adjusted) {
		mem = (char *)BNRP_malloc(200);
		BNRP_baseOffset = tagof(mem);
		BNRP_free((void *)mem);
		BNRP_adjusted = 1;
		}
#endif
	}

int BNRP_allocMemory(TCB *tcb, 
					 long heapAndTrail, 
					 long envAndCP)
{
	unsigned long t;
	char *mem;
#ifndef Macintosh
	/* need something on stack to get stack address, needs to be */
	/* big enough that smart compilers don't put it in registers */
	char silly[20];		
#endif
	
	BNRP_initMemory();
	mem = (char *)BNRP_malloc(200);
	if (mem EQ NULL) return(-1);
	if (addrof(maketerm(0, (long)mem)) NE (long)mem) {
		printf("Top bits set on free addresses\n");
		exit(1);
		}
	if (addrof(maketerm(0, ((long)mem + 200))) NE (long)mem + 200) {
		printf("Top bits set on free addresses\n");
		exit(1);
		}
	memset(mem, 0xAA, 200);
	tcb->space = tcb->freePtr = (long)mem;
	tcb->ASTbase = (long)mem + 200;

	t = heapAndTrail + envAndCP;
	mem = BNRP_malloc(t);
	if (mem EQ NULL) return(-1);
	if (addrof(maketerm(0, (long)mem)) NE (long)mem) {
		printf("Top bits set on heap addresses\n");
		exit(2);
		}
	if (addrof(maketerm(0, (long)mem + t)) NE (long)mem + t) {
		printf("Top bits set on heap addresses\n");
		exit(2);
		}
	memset(mem, 0xAA, t);
	tcb->heapbase = (long)mem;
	tcb->trailbase = (long)mem + heapAndTrail - 4;
	tcb->envbase = (long)mem + heapAndTrail;
	tcb->cpbase = (long)mem + heapAndTrail + envAndCP - 4;
#ifdef Macintosh
	tcb->spend = (long)LMGetApplLimit();
#else
	tcb->spend = (long)silly - heapAndTrail;	/* something big for asm version */
#endif

#ifdef HSC
	tcb->spbase = (long)BNRP_malloc(400);
	tcb->spend = tcb->spbase + 400;
#endif

	return(0);
	}

void BNRP_disposeMemory(TCB *tcb)
{
	BNRP_free((void *)tcb->space);
	BNRP_free((void *)tcb->heapbase);
#ifdef HSC
	BNRP_free((void *)tcb->spbase);
#endif
	tcb->space = tcb->freePtr = tcb->ASTbase = tcb->heapbase = 
	tcb->trailbase = tcb->envbase = tcb->cpbase = tcb->spbase = 0;
	}
