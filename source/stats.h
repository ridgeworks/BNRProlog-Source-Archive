/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/stats.h,v 1.2 1997/12/22 17:01:42 harrisj Exp $
*
*  $Log: stats.h,v $
 * Revision 1.2  1997/12/22  17:01:42  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:28:46  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_stats
#define _H_stats

extern long headCount[256], bodyCount[256], escapeCount[256], escapeCount2[256], BNRPprimitiveCalls;

void BNRP_initStats();
long BNRP_getLIPS();
void BNRP_printStats();

#endif
