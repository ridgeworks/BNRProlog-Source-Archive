/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/procs.c,v 1.3 1997/08/12 17:35:16 harrisj Exp $
*
*  $Log: procs.c,v $
 * Revision 1.3  1997/08/12  17:35:16  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.2  1995/12/04  00:10:23  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.1  1995/09/22  11:26:13  harrisja
 * Initial version.
 *
*
*/
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "BNRProlog.h"
#include "base.h"
#include "context.h"
#include "interpreter.h"
#include "hardware.h"
#include "utility.h"

/* #define test */

#define MAXPARMS 		20
#define BNRP_endParm	BNRP_termParm + 1

#ifdef __mpw							/* Macintosh MPW */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		extended
#define promoteddouble		extended
#define promotedlongdouble	extended
#define BUFFSIZE			60				/* 20 * sizeof(extended) */
#endif

#ifdef THINK_C								/* Macintosh THINK C */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			30				/* maximum number of args allowed */
#endif

#ifdef __MWERKS__                                                       /* Macintosh Metrowerks */
#define promotedint                     int
#define promotedshort           int
#define promotedlong            long
#define promotedfloat           float
#define promoteddouble          double
#define promotedlongdouble      long double
#define BUFFSIZE                        30                              /* maximum number of args allowed */
#endif

#ifdef sun									/* Sun GCC */
#define promotedint			int
#define promotedshort		short
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			60
#define ALIGNMENT			sizeof(long)
typedef long double extended;
#endif

#ifdef hpux									/* HP GCC */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			60
typedef long double extended;
#endif

#ifdef ultrix                                                           /* DECstation GCC */
#define promotedint                     int
#define promotedshort           int
#define promotedlong            long
#define promotedfloat           float
#define promoteddouble          double
#define promotedlongdouble      long double
#define BUFFSIZE                        60
typedef long double extended;
#endif

#ifdef sgi                                                              /* Silicon Graphics GCC */
#define promotedint                     int
#define promotedshort           int
#define promotedlong            long
#define promotedfloat           float
#define promoteddouble          double
#define promotedlongdouble      long double
#define BUFFSIZE                        60
typedef long double extended;
#endif

#ifdef mdelta								/* m68000 GCC */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			60
typedef long double extended;
#endif

#ifdef nav								/* m88000 - NAV */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			60
typedef long double extended;
#endif

#ifdef _AIX                 /* IBM Power/RS6000 AIX 4.1 */
#define promotedint			int
#define promotedshort		int
#define promotedlong		long
#define promotedfloat		float
#define promoteddouble		double
#define promotedlongdouble	long double
#define BUFFSIZE			60
typedef long double extended;
#endif

struct procRecord {
	BNRP_term name;
	BNRP_procedure proc;
	int arity;
	int parmtypes[MAXPARMS+1];
	};
typedef struct procRecord procRecord;
int BNRP_maxProcs = 0;

int BNRP_procBuffer[BUFFSIZE];
void *BNRP_procPtr;

#ifndef test
procRecord *BNRP_procs = NULL;
#else
procRecord BNRP_procs[2];
#define makeint(a, b)				returnint(b)
#define makefloat(a, b)				returnfloat(*b)
#define BNRPLookupSymbol(a,b,c,d)	returnsym(b)
#define checkArg(a, b)				lookatarg(a, b)
#define BNRP_malloc					malloc
#ifdef unix
#include <malloc.h>
#else
#include <stdlib.h>
#endif
#define unify(a, b, c)				b = c
long buffp;

TAG lookatarg(BNRP_term t, long *res)
{
	if (tagof(t) EQ INTTAG) {
		*res = addrof(t);
		return(INTT);
		}
	else if (tagof(t) EQ SYMBOLTAG) {
		*res = addrof(t);
		return(SYMBOLT);
		}
	else if (tagof(t) EQ STRUCTTAG) {
		long *p = (long *)addrof(t);
		
		if (*p++ EQ INTID) {
			*res = *p;
			return(INTT);
			}
		else {
			fpLWA(p);
			*res = (long)p;
			return(FLOATT);
			}
		}
	else {
		*res = 0;
		return(VART);
		}
	}

BNRP_term returnint(long value)
{
	short i;
	long res;
	struct longheader{
		long header;
		long value;
		} *x;
	
	i = value;
	if (value EQ i)
		return(makeintterm(value & 0x0000FFFF));
	/* number bigger than 16 bits */
	headerLWA(buffp);
	res = maketerm(STRUCTTAG, buffp);
	x = (struct longheader *)buffp;
	buffp += sizeof(struct longheader);
	x->header = INTID;
	x->value = value;
	return(res);
	}
	
BNRP_term returnfloat(fp value)
{
	long res;
	/* cannot use struct { long, fp } since Sparc C compiler */
	/* will align fp on an 8 byte boundary, wasting a long */
	/* and causing problems in the arithmetic stuff */
	
	headerLWA(buffp);
	res = maketerm(STRUCTTAG, buffp);
	push(long, buffp, FLOATID);
	fpLWA(buffp);
	memcpy((void *)buffp, &value, sizeof(fp));
	buffp += sizeof(fp);
	if (sizeof(fp) EQ 10) { 
		push(short, buffp, 0);
		}
	return(res);
	}
	
BNRP_term returnsym(char *p)
{
	BNRP_term res;
	
	headerLWA(buffp);
	res = maketerm(SYMBOLTAG, buffp);
	strcpy((char *)buffp, p);
	buffp += strlen(p) + 1;
	return(res);
	}
#endif

#ifdef ALIGNMENT
#define copyval(f, t)		memcpy(BNRP_procPtr, &t, sizeof(f)); \
							incr_procPtr(sizeof(f)); \
							if (sizeof(f) LT ALIGNMENT) { \
								memcpy(BNRP_procPtr, &t, sizeof(f)); \
								incr_procPtr(sizeof(f)); \
								}
#else
#define copyval(f, t)		*(f *)BNRP_procPtr = t; \
							incr_procPtr(sizeof(f))							
#endif

#define incr_procPtr(s)		BNRP_procPtr = (void *)((long)BNRP_procPtr + s)
#define handleint(f, t)		if (tag NE INTT) break; \
							t = l; \
							copyval(promoted ## f, t); \
							return(BNRP_handleArg(tcb, index, arg+1))
#define handlevarint(f, t)	if (tag EQ INTT) \
								t = l; \
							else if (tag EQ VART) \
								t = 0; \
							else \
								break; \
							*(f **)BNRP_procPtr = &t; \
							incr_procPtr(sizeof(f *)); \
							if (!BNRP_handleArg(tcb, index, arg+1)) break; \
							l = t; \
							return(unify(tcb, tcb->args[arg], makeint(&tcb->hp, l)))
#define handlefp(f, t)		if (tag EQ INTT) \
								t = l; \
							else if (tag EQ FLOATT) \
								t = *(fp *)l; \
							else \
								break; \
							copyval(promoted ## f, t); \
							return(BNRP_handleArg(tcb, index, arg+1))
#define handlevarfp(f, t)	if (tag EQ INTT) \
								t = l; \
							else if (tag EQ FLOATT) \
								t = *(fp *)l; \
							else if (tag EQ VART) \
								t = 0.0; \
							else \
								break; \
							*(f **)BNRP_procPtr = &t; \
							incr_procPtr(sizeof(f *)); \
							if (!BNRP_handleArg(tcb, index, arg+1)) break; \
							if (tag NE INTT) { \
								fp _f = t; \
								return(unify(tcb, tcb->args[arg], makefloat(&tcb->hp, &_f))); \
								} \
							return(t EQ l)

static BNRP_Boolean BNRP_handleArg(TCB *tcb, int index, int arg)
{
	union {
		int i;
		short s;
		long l;
		float f;
		double d;
		long double ld;
		char *p;
		BNRP_term t;
		} t;
	TAG tag;
	long l;
	int result;
	char * savep;

	if (BNRP_procs[index].parmtypes[arg-1] EQ BNRP_endParm) {
		l = (long)BNRP_procPtr - (long)BNRP_procBuffer;
		if (l GT MAXPARMS*sizeof(promoteddouble)) return(FALSE);
		switch (l) {
			case sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0]);
					return(TRUE);
			case 2*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1]);
					return(TRUE);
			case 3*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2]);
					return(TRUE);
			case 4*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3]);
					return(TRUE);
			case 5*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4]);
					return(TRUE);
			case 6*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5]);
					return(TRUE);
			case 7*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5],
											 BNRP_procBuffer[6]);
					return(TRUE);
			case 8*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5],
											 BNRP_procBuffer[6],
											 BNRP_procBuffer[7]);
					return(TRUE);
			case 9*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5],
											 BNRP_procBuffer[6],
											 BNRP_procBuffer[7],
											 BNRP_procBuffer[8]);
					return(TRUE);
			case 10*sizeof(int):
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5],
											 BNRP_procBuffer[6],
											 BNRP_procBuffer[7],
											 BNRP_procBuffer[8],
											 BNRP_procBuffer[9]);
					return(TRUE);
			default:
					(BNRP_procs[index].proc)(BNRP_procBuffer[0],
											 BNRP_procBuffer[1],
											 BNRP_procBuffer[2],
											 BNRP_procBuffer[3],
											 BNRP_procBuffer[4],
											 BNRP_procBuffer[5],
											 BNRP_procBuffer[6],
											 BNRP_procBuffer[7],
											 BNRP_procBuffer[8],
											 BNRP_procBuffer[9],
											 BNRP_procBuffer[10],
											 BNRP_procBuffer[11],
											 BNRP_procBuffer[12],
											 BNRP_procBuffer[13],
											 BNRP_procBuffer[14],
											 BNRP_procBuffer[15],
											 BNRP_procBuffer[16],
											 BNRP_procBuffer[17],
											 BNRP_procBuffer[18],
											 BNRP_procBuffer[19],
											 BNRP_procBuffer[20],
											 BNRP_procBuffer[21],
											 BNRP_procBuffer[22],
											 BNRP_procBuffer[23],
											 BNRP_procBuffer[24],
											 BNRP_procBuffer[25],
											 BNRP_procBuffer[26],
											 BNRP_procBuffer[27],
											 BNRP_procBuffer[28],
											 BNRP_procBuffer[29],
#ifdef THINK_C
											 BNRP_procBuffer[30]);
#else
											 BNRP_procBuffer[30],
											 BNRP_procBuffer[31],
											 BNRP_procBuffer[32],
											 BNRP_procBuffer[33],
											 BNRP_procBuffer[34],
											 BNRP_procBuffer[35],
											 BNRP_procBuffer[36],
											 BNRP_procBuffer[37],
											 BNRP_procBuffer[38],
											 BNRP_procBuffer[39],
											 BNRP_procBuffer[40],
											 BNRP_procBuffer[41],
											 BNRP_procBuffer[42],
											 BNRP_procBuffer[43],
											 BNRP_procBuffer[44],
											 BNRP_procBuffer[45],
											 BNRP_procBuffer[46],
											 BNRP_procBuffer[47],
											 BNRP_procBuffer[48],
											 BNRP_procBuffer[49],
											 BNRP_procBuffer[50],
											 BNRP_procBuffer[51],
											 BNRP_procBuffer[52],
											 BNRP_procBuffer[53],
											 BNRP_procBuffer[54],
											 BNRP_procBuffer[55],
											 BNRP_procBuffer[56],
											 BNRP_procBuffer[57],
											 BNRP_procBuffer[58],
											 BNRP_procBuffer[59]);
#endif
					return(TRUE);
			}
		}
	tag = checkArg(tcb->args[arg], &l);
	switch (BNRP_procs[index].parmtypes[arg-1]) {
		case BNRP_intParm:
				handleint(int, t.i);
		case BNRP_varIntParm:
				handlevarint(int, t.i);
		case BNRP_shortParm:
				handleint(short, t.s);
		case BNRP_varShortParm:
				handlevarint(short, t.s);
		case BNRP_longParm:
				handleint(long, t.l);
		case BNRP_varLongParm:
				handlevarint(long, t.l);
		case BNRP_floatParm:
				handlefp(float, t.f);
		case BNRP_varFloatParm:
				handlevarfp(float, t.f);
		case BNRP_doubleParm:
				handlefp(double, t.d);
		case BNRP_varDoubleParm:
				handlevarfp(double, t.d);
		case BNRP_extendedParm:
				handlefp(long double, t.ld);
		case BNRP_varExtendedParm:
				handlevarfp(long double, t.ld);
		case BNRP_symbolParm:
				if (tag NE SYMBOLT) break;
				t.p = BNRP_malloc(strlen(nameof(l)) + 1);
				strcpy(t.p, nameof(l));
				*(char **)BNRP_procPtr = t.p;
				incr_procPtr(sizeof(char *));
				/* Fix to a memory leak 13/01/95
				return(BNRP_handleArg(tcb, index, arg+1)); */
				result = BNRP_handleArg(tcb, index, arg+1);
				BNRP_free(t.p);
				return(result);
		case BNRP_varSymbolParm:
				if (tag EQ SYMBOLT) {
					/* t.p = (char *)BNRP_malloc(strlen(nameof(l))); */
					savep = t.p = (char *)BNRP_malloc(strlen(nameof(1)) + 1); /*leak & memory overwrite fix Jason Harris 95 */
					strcpy(t.p, nameof(l));
					}
				else if (tag EQ VART)
					t.p = savep = NULL;
				else
					break;
				*(char ***)BNRP_procPtr = &t.p;
				incr_procPtr(sizeof(char **));
				/* Leak fix 13/01/95
				if (!BNRP_handleArg(tcb, index, arg+1)) break;
				return(unify(tcb, tcb->args[arg], BNRPLookupSymbol(tcb, t.p, TEMPSYM, (*t.p EQ '$') ? LOCAL : GLOBAL))); */
				result = BNRP_handleArg(tcb, index, arg+1);
				if (result)
					result = unify(tcb, tcb->args[arg], BNRPLookupSymbol(tcb, t.p, TEMPSYM, (*t.p EQ '$') ? LOCAL : GLOBAL));
				if (savep)
					BNRP_free(savep);
				return(result);

		case BNRP_termParm:
				t.t = tcb->args[arg];
				*(BNRP_term *)BNRP_procPtr = t.t;
				incr_procPtr(sizeof(BNRP_term));
				return(BNRP_handleArg(tcb, index, arg+1));
		}
	return(FALSE);
	}

#ifndef test
static BNRP_Boolean BNRP_handleProcedure(TCB *tcb)
{
	int i;
	
	for (i = 0; i LT BNRP_maxProcs; ++i) {
		if (BNRP_procs[i].name EQ tcb->procname) break;
		}
	if (i GE BNRP_maxProcs) return(FALSE);
	if (tcb->numargs NE BNRP_procs[i].arity) return(FALSE);
	BNRP_procPtr = (void *)BNRP_procBuffer;
	return(BNRP_handleArg(tcb, i, 1));
	}

#define notAllowed(x)	if (k EQ x) { \
							printf("Sorry, but BNRP_bindProcedure does not currently support type " \
								   #x " on this system\n"); \
							BNRP_procs[i].name = 0; \
							return(-1); \
							} \

int BNRP_bindProcedure(
	const char *name,
	void (*procedure)(),
	int arity,
	...)
{
	BNRP_term functor;
	int i, j, k;
	va_list next;

	if ((arity LT 0) || (arity GT MAXPARMS)) return(-1);
	functor = BNRPLookupPermSymbol(name);
	if (BNRP_maxProcs EQ 0) {
		if ((BNRP_procs = BNRP_malloc(sizeof(procRecord))) EQ NULL) return(-1);
		BNRP_maxProcs = 1;
		i = 0;
		}
	else {
		i = BNRP_maxProcs;
		if ((BNRP_procs = BNRP_realloc(BNRP_procs, (i + 1) * sizeof(procRecord))) EQ NULL) return(-1);
		++BNRP_maxProcs;
		}
	BNRP_procs[i].name = functor;
	BNRP_procs[i].proc = procedure;
	BNRP_procs[i].arity = arity;
	va_start(next, arity);
	for (j = 0; j LT arity; ++j) {
		k = BNRP_procs[i].parmtypes[j] = va_arg(next, int);
#ifdef ultrix
		notAllowed(BNRP_floatParm);
		notAllowed(BNRP_doubleParm);
		notAllowed(BNRP_extendedParm);
#endif
		}
	BNRP_procs[i].parmtypes[j] = BNRP_endParm;
	va_end(next);
	return((BNRP_addClause(functor, 0L, 0L, 0L, (void *)BNRP_handleProcedure, TRUE) EQ NULL) ? -1 : 0);
	}
#endif

#ifdef test
#define newproc(t, f)		void test_ ## t (t a, t b, t *c) \
							{ \
								printf("In test_" #t " with a = " f ", b = " f "\n", a, b); \
								*c = a + b; \
								}

newproc(int, "%d")
newproc(short, "%hd")
newproc(long, "%ld")
newproc(float, "%f")
newproc(double, "%lf")
newproc(extended, "%lf")

main()
{
	TCB tcb;
	long space[1000], l;

	buffp = (long)space;
	if (addrof(buffp) NE buffp) {
		printf("buffer problems, trying malloc\n");
		buffp = (long)malloc(4000);
		if (addrof(buffp) NE buffp) {
			printf("buffer problems prevent execution\n");
			exit(0);
			}
		}

	BNRP_procs[0].proc = (BNRP_procedure)test_int;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_intParm;
	BNRP_procs[0].parmtypes[1] = BNRP_intParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varIntParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(1);
	tcb.args[2] = returnint(2);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ INTT)
			if (l EQ 3)
				printf("test_int case OK\n");
			else
				printf("**** ERROR: test_int case returns wrong result\n");
		else
			printf("**** ERROR: test_int case returns wrong tag\n");
	else
		printf("**** ERROR: test_int case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_short;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_shortParm;
	BNRP_procs[0].parmtypes[1] = BNRP_shortParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varShortParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(10);
	tcb.args[2] = returnint(20);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ INTT)
			if (l EQ 30)
				printf("test_short case OK\n");
			else
				printf("**** ERROR: test_short case returns wrong result\n");
		else
			printf("**** ERROR: test_short case returns wrong tag\n");
	else
		printf("**** ERROR: test_short case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_long;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_longParm;
	BNRP_procs[0].parmtypes[1] = BNRP_longParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varLongParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(100);
	tcb.args[2] = returnint(200);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ INTT)
			if (l EQ 300)
				printf("test_long case OK\n");
			else
				printf("**** ERROR: test_long case returns wrong result\n");
		else
			printf("**** ERROR: test_long case returns wrong tag\n");
	else
		printf("**** ERROR: test_long case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_double;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_doubleParm;
	BNRP_procs[0].parmtypes[1] = BNRP_doubleParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varDoubleParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(1);
	tcb.args[2] = returnint(2);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 3.0)
				printf("test_double with ints case OK\n");
			else
				printf("**** ERROR: test_double with ints case returns wrong result\n");
		else
			printf("**** ERROR: test_double with ints case returns wrong tag\n");
	else
		printf("**** ERROR: test_double with ints case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_double;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_doubleParm;
	BNRP_procs[0].parmtypes[1] = BNRP_doubleParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varDoubleParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnfloat(10.0);
	tcb.args[2] = returnfloat(20.0);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 30.0)
				printf("test_double with floats case OK\n");
			else
				printf("**** ERROR: test_double with floats case returns wrong result\n");
		else
			printf("**** ERROR: test_double with floats case returns wrong tag\n");
	else
		printf("**** ERROR: test_double with floats case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_float;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_floatParm;
	BNRP_procs[0].parmtypes[1] = BNRP_floatParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varFloatParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(1);
	tcb.args[2] = returnint(2);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 3.0)
				printf("test_float with ints case OK\n");
			else
				printf("**** ERROR: test_float with ints case returns wrong result\n");
		else
			printf("**** ERROR: test_float with ints case returns wrong tag\n");
	else
		printf("**** ERROR: test_float with ints case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_float;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_floatParm;
	BNRP_procs[0].parmtypes[1] = BNRP_floatParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varFloatParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnfloat(10.0);
	tcb.args[2] = returnfloat(20.0);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 30.0)
				printf("test_float with floats case OK\n");
			else
				printf("**** ERROR: test_float with floats case returns wrong result\n");
		else
			printf("**** ERROR: test_float with floats case returns wrong tag\n");
	else
		printf("**** ERROR: test_float with floats case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_extended;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_extendedParm;
	BNRP_procs[0].parmtypes[1] = BNRP_extendedParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varExtendedParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnint(1);
	tcb.args[2] = returnint(2);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 3.0)
				printf("test_extended with ints case OK\n");
			else
				printf("**** ERROR: test_extended with ints case returns wrong result\n");
		else
			printf("**** ERROR: test_extended with ints case returns wrong tag\n");
	else
		printf("**** ERROR: test_extended with ints case fails\n");

	BNRP_procs[0].proc = (BNRP_procedure)test_extended;
	BNRP_procs[0].arity = 3;
	BNRP_procs[0].parmtypes[0] = BNRP_extendedParm;
	BNRP_procs[0].parmtypes[1] = BNRP_extendedParm;
	BNRP_procs[0].parmtypes[2] = BNRP_varExtendedParm;
	BNRP_procs[0].parmtypes[3] = BNRP_endParm;
	tcb.args[0] = 3;
	tcb.args[1] = returnfloat(10.0);
	tcb.args[2] = returnfloat(20.0);
	tcb.args[3] = 0;
	BNRP_procPtr = (void *)BNRP_procBuffer;
	if (BNRP_handleArg(&tcb, 0, 1))
		if (checkArg(tcb.args[3], &l) EQ FLOATT)
			if (*(fp *)l EQ 30.0)
				printf("test_extended with floats case OK\n");
			else
				printf("**** ERROR: test_extended with floats case returns wrong result\n");
		else
			printf("**** ERROR: test_extended with floats case returns wrong tag\n");
	else
		printf("**** ERROR: test_extended with floats case fails\n");
	}
#endif
