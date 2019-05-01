/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/pushpop.h,v 1.1 1995/09/22 11:27:36 harrisja Exp $
*
*  $Log: pushpop.h,v $
 * Revision 1.1  1995/09/22  11:27:36  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_pushpop
#define _H_pushpop

extern long BNRP_amTop, BNRP_amBottom, BNRP_amMax;


#define clearAM()		BNRP_amTop = BNRP_amBottom = 0
#define resetAM()		BNRP_amBottom = 0
#define discardLastAM()	if (--BNRP_amTop LT BNRP_amBottom) BNRP_amBottom = BNRP_amTop
#define discardTopAM()	if (++BNRP_amBottom GT BNRP_amTop) BNRP_amBottom = BNRP_amTop
#define freeAM()		if (BNRP_amMax GT 200) BNRP_freeAM()

void pushAM(long k1, long k2, long d);
BNRP_Boolean findAM(long k1, long k2, long *d);		/* items processed so far */
BNRP_Boolean searchAM(long k1, long k2, long *d);	/* all items pushed so far */
BNRP_Boolean topAM(long *k1, long *k2, long *d);
BNRP_Boolean pullAM(long *k1, long *k2, long *d);
BNRP_Boolean nextAM(long *k1, long *k2, long *d);
long locateAM(long k1, long k2, long *newReg);
void BNRP_freeAM(void);

#endif
