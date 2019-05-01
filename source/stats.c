/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/stats.c,v 1.3 1997/12/22 17:01:40 harrisj Exp $
*
*  $Log: stats.c,v $
 * Revision 1.3  1997/12/22  17:01:40  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.2  1996/02/12  03:38:57  yanzhou
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
 * Revision 1.1  1995/09/22  11:28:44  harrisja
 * Initial version.
 *
*
*/
#include <stdio.h>
#include "base.h"
#include "core.h"
#include "stats.h"

long headCount[256], bodyCount[256], escapeCount[256], escapeCount2[256];
long BNRPprimitiveCalls = 0;

void BNRP_initStats()
{
	int i;
	for (i = 0; i LT 256; ++i) 
		headCount[i] = bodyCount[i] = escapeCount[i] = escapeCount2[i] = 0;
	BNRPprimitiveCalls = 0;
	}


static long countUpHead(int a, int b)
{
	long l = 0;
	int i;
	
	for (i = a; i LE b; ++i) 
		l += headCount[i];
	return(l);
	}

static long countUpBody(int a, int b)
{
	long l = 0;
	int i;
	
	for (i = a; i LE b; ++i) 
		l += bodyCount[i];
	return(l);
	}

static long countUpEscape(int a, int b)
{
	long l = 0;
	int i;
	
	for (i = a; i LE b; ++i) 
		l += escapeCount[i];
	return(l);
	}

static long countUpEscape2(int a, int b)
{
	long l = 0;
	int i;
	
	for (i = a; i LE b; ++i) 
		l += escapeCount2[i];
	return(l);
	}

long BNRP_getLIPS()
{
/*****
	printf("\nNumber of necks =       %ld", headCount[0]);
	printf("\n          neck-checks = %ld", headCount[5]);
	printf("\n          var tests =   %ld", countUpEscape(0x10, 0x1F));
	printf("\n          tvar tests =  %ld", countUpEscape(0x20, 0x2F));
	printf("\n          other tests = %ld", countUpEscape(0x40, 0x4F));
	printf("\n          pop_valt/p =  %ld", countUpEscape(0x50, 0x5F));
	printf("\n          pop_vart/p =  %ld", countUpEscape(0x70, 0x7F));
	printf("\n          compares =    %ld", countUpEscape(0xD9, 0xDE));
	printf("\n          cut =         %ld", escapeCount[1]);
	printf("\n          cut/return =  %ld", escapeCount[2]);
	printf("\n          cut/exec =    %ld", escapeCount[0xE6]);
	printf("\n          fail =        %ld", escapeCount[0x0F]);
*****/	
	return(BNRPprimitiveCalls +					/* primitive calls */
		   headCount[0] + headCount[5] +		/* necks */
		   countUpEscape(0x10, 0x2F) +			/* var, tailvar tests */
		   countUpEscape(0x40, 0x4F) +			/* other tests */
		   countUpEscape(0x50, 0x5F) +			/* pop_valt, pop_valp */
		   countUpEscape(0x70, 0x7F) +			/* pop_vart, pop_varp */
		   countUpEscape(0xD9, 0xDE) +			/* comparisons */
		   escapeCount[0x0F] +					/* fail */
		   escapeCount[0xE6] +					/* cut-exec */
		   escapeCount[1] + escapeCount[2]);	/* ! */
	}

void BNRP_printStats()
{
	printf("\nNumber of necks =       %ld", headCount[0]);
	printf("\nNumber of unify_void =  %ld", headCount[1]);
	printf("\nNumber of tunify_void = %ld", headCount[2]);
	printf("\nNumber of end_seq =     %ld", headCount[3]);
	printf("\nNumber of unify_cons =  %ld", headCount[4]);
	printf("\nNumber of nops =        %ld", headCount[5]);
	printf("\nNumber of alloc =       %ld", headCount[6]);
	printf("\nNumber of unify_nil =   %ld", headCount[7]);
	printf("\nNumber of get_cons =    %ld", countUpHead(8, 15));
	printf("\nNumber of get_struct =  %ld", countUpHead(16, 23));
	printf("\nNumber of get_list =    %ld", countUpHead(32, 39));
	printf("\nNumber of get_nil =     %ld", countUpHead(40, 47));
	printf("\nNumber of get_valt =    %ld", countUpHead(48, 55));
	printf("\nNumber of get_valp =    %ld", countUpHead(56, 63));
	printf("\nNumber of unify_vart =  %ld", countUpHead(64, 71));
	printf("\nNumber of unify_varp =  %ld", countUpHead(72, 79));
	printf("\nNumber of unify_valt =  %ld", countUpHead(80, 87));
	printf("\nNumber of unify_valp =  %ld", countUpHead(88, 95));
	printf("\nNumber of tunify_vart = %ld", countUpHead(96, 103));
	printf("\nNumber of tunify_varp = %ld", countUpHead(104, 111));
	printf("\nNumber of tunify_valt = %ld", countUpHead(112, 119));
	printf("\nNumber of tunify_valp = %ld", countUpHead(120, 127));
	printf("\nNumber of get_vart    = %ld", countUpHead(128, 135) +
											countUpHead(144, 151) + 
											countUpHead(160, 167) +
											countUpHead(176, 183) +
											countUpHead(192, 199) +
											countUpHead(208, 215) +
											countUpHead(224, 231) +
											countUpHead(240, 247));
	printf("\nNumber of get_varp    = %ld", countUpHead(136, 143) +
											countUpHead(152, 159) +
											countUpHead(168, 175) +
											countUpHead(184, 191) +
											countUpHead(200, 207) +
											countUpHead(216, 223) +
											countUpHead(232, 239) +
											countUpHead(248, 255));
	printf("\nNumber of proceeds =    %ld", bodyCount[0]);
	printf("\nNumber of push_void =   %ld", bodyCount[1]);
	printf("\nNumber of tpush_void =  %ld", bodyCount[2]);
	printf("\nNumber of push_end =    %ld", bodyCount[3]);
	printf("\nNumber of push_cons =   %ld", bodyCount[4]);
	printf("\nNumber of nops =        %ld", bodyCount[5]);
	printf("\nNumber of call/exec =   %ld", bodyCount[6]);
	printf("\nNumber of escape =      %ld", bodyCount[7]);
	printf("\n          break =       %ld", escapeCount[0]);
	printf("\n          cut =         %ld", escapeCount[1]);
	printf("\n          cut/return =  %ld", escapeCount[2]);
	printf("\n          push_nil =    %ld", escapeCount[3]);
	printf("\n          dealloc =     %ld", escapeCount[5]);
	printf("\n          put_vart =    %ld", countUpEscape(128, 135) +
											countUpEscape(144, 151) + 
											countUpEscape(160, 167) +
											countUpEscape(176, 183) +
											countUpEscape(192, 199) +
											countUpEscape(208, 215) +
											countUpEscape(224, 231) +
											countUpEscape(240, 247));
	printf("\nNumber of put_cons =    %ld", countUpBody(8, 15));
	printf("\nNumber of put_struct =  %ld", countUpBody(16, 23));
	printf("\nNumber of put_list =    %ld", countUpBody(32, 39));
	printf("\nNumber of put_nil =     %ld", countUpBody(40, 47));
	printf("\nNumber of put_void =    %ld", countUpBody(48, 55));
	printf("\nNumber of put_varp =    %ld", countUpBody(56, 63));
	printf("\nNumber of push_vart =   %ld", countUpBody(64, 71));
	printf("\nNumber of push_varp =   %ld", countUpBody(72, 79));
	printf("\nNumber of push_valt =   %ld", countUpBody(80, 87));
	printf("\nNumber of push_valp =   %ld", countUpBody(88, 95));
	printf("\nNumber of tpush_vart =  %ld", countUpBody(96, 103));
	printf("\nNumber of tpush_varp =  %ld", countUpBody(104, 111));
	printf("\nNumber of tpush_valt =  %ld", countUpBody(112, 119));
	printf("\nNumber of tpush_valp =  %ld", countUpBody(120, 127));
	printf("\nNumber of put_valt =    %ld", countUpBody(128, 135) +
											countUpBody(144, 151) + 
											countUpBody(160, 167) +
											countUpBody(176, 183) +
											countUpBody(192, 199) +
											countUpBody(208, 215) +
											countUpBody(224, 231) +
											countUpBody(240, 247));
	printf("\nNumber of put_valp =    %ld", countUpBody(136, 143) +
											countUpBody(152, 159) +
											countUpBody(168, 175) +
											countUpBody(184, 191) +
											countUpBody(200, 207) +
											countUpBody(216, 223) +
											countUpBody(232, 239) +
											countUpBody(248, 255));
	printf("\n          eval_cons =   %ld", escapeCount[4]);
	printf("\n          pop_valt =    %ld", countUpEscape(0x50, 0x57));
	printf("\n          pop_valp =    %ld", countUpEscape(0x58, 0x5F));
	printf("\n          pop_vart =    %ld", countUpEscape(0x70, 0x77));
	printf("\n          pop_varp =    %ld", countUpEscape(0x78, 0x7F));
	printf("\n          evalt =       %ld", countUpEscape(0x60, 0x67));
	printf("\n          evalp =       %ld", countUpEscape(0x68, 0x6F));

        printf("\n\nTotal number of head codes: %d",countUpHead(0,255));
        printf("\n\nTotal number of body codes: %d",countUpBody(0,255));
        printf("\n\nTotal number of escape codes: %d",countUpEscape(0,255));
        printf("\n\nTotal number of escape codes (clause mode): %d",countUpEscape2(0,255));
	}

