/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/rings.c,v 1.1 1995/09/22 11:27:41 harrisja Exp $
*
*  $Log: rings.c,v $
 * Revision 1.1  1995/09/22  11:27:41  harrisja
 * Initial version.
 *
*
*/
/**************************************************************************

	This unit defines the routines to include a different ring. Due to 
	the nature of file references needed for linking under UNIX, this 
	file seperates out the different BNRP_initializeRingx calls so that
	the embeded context for ring 0 is only loaded when using just ring 0.
	
**************************************************************************/

#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include <stdio.h>
#include <string.h>
#include "utility.h"		/* for BNRP_loadBase */
#include "fsysprim.h"		/* for BNRP_setupFiles */

/* #define test				/* test external interface calling */

#ifdef Macintosh
#ifndef __powerc
#define noEmbed                         /* Macintosh 68K only */
#endif
#endif

#ifdef ring0
int BNRP_alreadyInited = 0;
#else
extern int BNRP_alreadyInited;
#endif
#define checkInited()			if (BNRP_alreadyInited) { \
									fprintf(stderr, "Ring initialization can only occur once\n"); \
									return(-2); \
									} \
								BNRP_alreadyInited = 1;

extern int BNRP_embedIgnoreContext;

#ifdef ring0
int BNRP_initializeRing0(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base0(void), BNRP_bindRing0(void);

	checkInited();
	BNRP_bindRing0();
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base0.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base0();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef ring1
int BNRP_initializeRing1(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base1(void), BNRP_bindRing1(void);

	checkInited();
	BNRP_bindRing1();
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base1.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base1();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef ring2
int BNRP_initializeRing2(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base2(void), BNRP_bindRing2(void);

	checkInited();
	BNRP_bindRing2();
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base2.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base2();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef ring3
int BNRP_initializeRing3(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base3(void), BNRP_bindRing3(void);

	checkInited();
	BNRP_bindRing3();
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base3.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base3();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef ring4
int BNRP_initializeRing4(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base4(void), BNRP_bindRing4(void);

	checkInited();
	BNRP_bindRing4();
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base4.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base4();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef test
	void myTestProc(short a, int b, long *c)
	{
		*c = a + b;
		}

	void myTest2(float f, double d, long double *ld)
	{
		*ld = f + d;
		}
#endif

#ifdef ring5
int BNRP_initializeRing5(int argc, char **argv)
{
	int i;
	void BNRP_embedContext_base5(void), BNRP_bindRing5(void);

	checkInited();
	BNRP_bindRing5();
#ifdef test
	(void)BNRP_bindProcedure("fred", (BNRP_procedure)myTestProc, 3, BNRP_shortParm, BNRP_intParm, BNRP_varLongParm);
	(void)BNRP_bindProcedure("fred2", (BNRP_procedure)myTest2, 3, BNRP_floatParm, BNRP_doubleParm, BNRP_varExtendedParm);
#endif
	BNRP_setupFiles(argc, argv);
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0)
			return(BNRP_loadBase(1, argv, argv[i+1]));
#ifdef noEmbed
	return(BNRP_loadBase(1, argv, "base5.a"));
#else
	BNRP_embedIgnoreContext = 1;
	BNRP_embedContext_base5();
	BNRP_embedIgnoreContext = 0;
	return(0);
#endif
	}
#endif

#ifdef ring6
void BNRP_initializeAllLowerRings(int argc, char **argv)
{
	void BNRP_bindRing5(void);

	BNRP_bindRing5();
#ifdef test
	(void)BNRP_bindProcedure("fred", (BNRP_procedure)myTestProc, 3, BNRP_shortParm, BNRP_intParm, BNRP_varLongParm);
	(void)BNRP_bindProcedure("fred2", (BNRP_procedure)myTest2, 3, BNRP_floatParm, BNRP_doubleParm, BNRP_varExtendedParm);
	{	float f = 1.0;
		double d = 2.0;
		long double ld;
		myTest2(f,d,&ld);
		}
#endif
	BNRP_setupFiles(argc, argv);
	}
#endif
