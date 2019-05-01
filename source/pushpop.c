/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/pushpop.c,v 1.1 1995/09/22 11:27:35 harrisja Exp $
*
*  $Log: pushpop.c,v $
 * Revision 1.1  1995/09/22  11:27:35  harrisja
 * Initial version.
 *
*
*/
#include "base.h"
#include "core.h"
#include "pushpop.h"
#include "hardware.h"
#include <stdio.h>

#ifdef test
#define trace
#endif

struct amStruct {
	long key1, key2, dat;
	} *BNRP_am = NULL;
	
long BNRP_amTop, BNRP_amBottom, BNRP_amMax = 0;


void BNRP_freeAM(void)
{
	if (BNRP_am NE NULL) BNRP_free(BNRP_am);
	BNRP_am = NULL;
	BNRP_amMax = 0;
	}

void pushAM(long k1, long k2, long d)
{
	if (++BNRP_amTop GE BNRP_amMax) {
		BNRP_amMax += 100;
		if (BNRP_am EQ NULL)
			BNRP_am = (struct amStruct *) BNRP_malloc(BNRP_amMax * sizeof(struct amStruct));
		else
			BNRP_am = (struct amStruct *) BNRP_realloc(BNRP_am, BNRP_amMax * sizeof(struct amStruct));
		if (BNRP_am EQ NULL)
#ifdef test
			exit(1);
#else
			BNRP_error(OUTOFAMSPACE);
#endif
		}
#ifdef trace
	printf("Pushing key1 = %08lx, key2 = %ld, data = %ld into position %ld\n", k1, k2, d, BNRP_amTop);
#endif
	BNRP_am[BNRP_amTop].key1 = k1;
	BNRP_am[BNRP_amTop].key2 = k2;
	BNRP_am[BNRP_amTop].dat = d;
	}
	
BNRP_Boolean findAM(long k1, long k2, long *d)
{
	int i;

	for (i = 1; i LE BNRP_amBottom; ++i)
		if ((BNRP_am[i].key1 EQ k1) && (BNRP_am[i].key2 EQ k2)) {
			*d = BNRP_am[i].dat;
			return(TRUE);
			}
	return(FALSE);
	}

BNRP_Boolean searchAM(long k1, long k2, long *d)
{
	int i;

	for (i = 1; i LE BNRP_amTop; ++i)
		if (BNRP_am[i].key1 EQ k1) 
			if (BNRP_am[i].key2 EQ k2) {
				*d = BNRP_am[i].dat;
				return(TRUE);
				}
	return(FALSE);
	}

BNRP_Boolean pullAM(long *k1, long *k2, long *d)
{
	int next;
	long dat;

	next = BNRP_amBottom + 1;
	while (next LE BNRP_amTop) {
		if (findAM(BNRP_am[next].key1, BNRP_am[next].key2, &dat)) {
			/* fixup ?? */
			++next;
			}
		else
			break;
		}
	if (next GT BNRP_amTop) return(FALSE);
	BNRP_amBottom = next;
	*k1 = BNRP_am[next].key1;
	*k2 = BNRP_am[next].key2;
	*d = BNRP_am[next].dat;
	return(TRUE);
	}
	
BNRP_Boolean nextAM(long *k1, long *k2, long *d)
{
	if (BNRP_amBottom GE BNRP_amTop) return(FALSE);
	++BNRP_amBottom;
	*k1 = BNRP_am[BNRP_amBottom].key1;
	*k2 = BNRP_am[BNRP_amBottom].key2;
	*d = BNRP_am[BNRP_amBottom].dat;
#ifdef trace
	printf("NextAM returns key1 = %08lx, key2 = %ld, data = %ld from position %ld\n", *k1, *k2, *d, BNRP_amBottom);
#endif
	return(TRUE);
	}
	
BNRP_Boolean topAM(long *k1, long *k2, long *d)
{
	if (BNRP_amBottom GE BNRP_amTop) return(FALSE);
	*k1 = BNRP_am[BNRP_amBottom+1].key1;
	*k2 = BNRP_am[BNRP_amBottom+1].key2;
	*d = BNRP_am[BNRP_amBottom+1].dat;
	return(TRUE);
	}
	
long locateAM(long k1, long k2, long *newReg)
{
	long i, nextReg = 0, nextPos = 0;

#ifdef trace
	printf("Locating key1 = %08lx", k1);
#endif
	for (i = 1; i LE BNRP_amBottom; ++i) {
		if (BNRP_am[i].key1 EQ k1) {		/* found what we're looking for ? */
			if (BNRP_am[i].key2 NE 0) {		/* yes, is it locked ? */
				if (BNRP_am[i].dat EQ 0)	/* yes it's locked, but reused */
					continue;				/* keep looking, find where it's been reused */
				else {						/* locked, and still in use */
#ifdef trace
					printf(" returning %ld since locked\n", BNRP_am[i].dat);
#endif
					return(BNRP_am[i].dat);	/* great, this is it */
					}
				}
			else {							/* not locked */
				BNRP_am[i].key2 = 1;		/* lock it */
				if (BNRP_am[i].dat NE 0) { 	/* still in a register ?? */
#ifdef trace
					printf(" returning %ld now locked\n", BNRP_am[i].dat);
#endif
					return(BNRP_am[i].dat);	/* reuse the register */
					}
				else {
					nextReg = ++(*newReg);	/* allocate a new register, since not locked doesn't occur again */
					pushAM(k1, 1L, nextReg);
#ifdef trace
					printf(" returning new %d (reused by not available)\n", -nextReg);
#endif
					return(-nextReg);		/* indicate not found (sort of) */
					}
				}
			}
		else {								/* value doesn't exist, keep track of free locations */
			if (BNRP_am[i].key2 EQ 0)		/* this one not locked */
				if (nextReg EQ 0) {			/* just save first one */
					nextReg = BNRP_am[i].dat;
					nextPos = i;
					}
			}
		}
	/* haven't found k1 yet, so continue search through unprocessed data (may */
	/* have seen first occurance without register, look for one with register) */
	for (i = BNRP_amBottom; i LE BNRP_amTop; ++i) {
		if (BNRP_am[i].key1 EQ k1) {		/* found what we're looking for ? */
			BNRP_am[i].key2 = 1;			/* lock it */
#ifdef trace
			printf(" returning unprocessed %d\n", BNRP_am[i].dat);
#endif
			return(BNRP_am[i].dat);			/* return existing register */
			}
		}
	if (nextReg NE 0)						/* possible to reuse a register */
		BNRP_am[nextPos].dat = 0;			/* mark register as reused */
	else
		nextReg = ++(*newReg);				/* allocate a new register */

	pushAM(k1, k2, nextReg);				/* save for later processing */
#ifdef trace
	printf(" returning newly allocated %d\n", -nextReg);
#endif
	return(-nextReg);						/* didn't find it */
	}
	

#ifdef test
main()
{
	long i, l, reg, k1, k2, d, item;
	
	clearAM();
	item = 100; reg = 0;
	pushAM(++item, 0, ++reg);
	pushAM(++item, 0, ++reg);
	pushAM(++item, 0, ++reg);
	for (i = 1; i LE 6; ++i) {
		nextAM(&k1, &k2, &d);
		l = locateAM(++item, &reg);
		if (l GT 0) printf("locate says to reuse reg %ld\n", l); else printf("locate says to use NEW reg %ld\n", -l); 
		if (i EQ 3) {
			l = locateAM(++item, &reg);
			if (l GT 0) printf("locate says to reuse reg %ld\n", l); else printf("locate says to use NEW reg %ld\n", -l); 
			}
		}
	printf("\n\n");
	
	clearAM();
	item = 100; reg = 0;
	pushAM(++item, 0, ++reg);
	pushAM(++item, 0, ++reg);
	pushAM(++item, 0, ++reg);
	pushAM(++item, 0, ++reg);
	for (i = 103; i LE 105; ++i) {
		l = locateAM(i, &reg);
		if (l GT 0) printf("locate says to reuse reg %ld\n", l); else printf("locate says to use NEW reg %ld\n", -l); 
		}
	nextAM(&k1, &k2, &d);
	nextAM(&k1, &k2, &d);
	nextAM(&k1, &k2, &d);
	for (i = 103; i LE 107; ++i) {
		l = locateAM(i, &reg);
		if (l GT 0) printf("locate says to reuse reg %ld\n", l); else printf("locate says to use NEW reg %ld\n", -l); 
		}
	for (i = 101; i LE 104; ++i) {
		l = locateAM(i, &reg);
		if (l GT 0) printf("locate says to reuse reg %ld\n", l); else printf("locate says to use NEW reg %ld\n", -l); 
		}
	while (nextAM(&k1, &k2, &d)) ;
	}
#endif
