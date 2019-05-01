/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/BNRProlog.h,v 1.9 1997/12/23 09:48:17 harrisj Exp $
*
*  $Log: BNRProlog.h,v $
 * Revision 1.9  1997/12/23  09:48:17  harrisj
 * Added BNRP_dumpTerm() to external interface
 *
 * Revision 1.8  1997/09/17  08:14:58  wcorebld
 * Modified BNRP_tag enum to be more backward compatible
 *
 * Revision 1.7  1997/09/01  11:19:01  harrisj
 * Added BNRP_lengthList() function and modified BNRP_tag enum
 * so that BNRP_end and BNRP_invalid are equivalent.
 *
 * Revision 1.6  1997/08/12  17:34:41  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.5  1997/03/20  10:16:40  harrisj
 * Added BNRP_primitiveName function to retrieve the name of the
 * currently executing Prolog primitive name from the TCB.
 *
 * Revision 1.4  1996/05/20  16:42:48  neilj
 * Added BNRP_termToString to external interface.
 *
 * Revision 1.3  1996/01/12  06:20:51  yanzhou
 * Nested comments removed.
 *
 * Revision 1.2  1995/12/15  12:10:44  yanzhou
 * BNRP_buildList() and BNRP_buildStructure() are added to the BNRP external interface.
 * Both of the functions can take an array of BNRP_terms and construct a list or a structure
 * out of it.
 *
 * Revision 1.1  1995/09/22  11:21:39  harrisja
 * Initial version.
 *
*
*/

/**********************************************************************************

	Header file for interface to BNR Prolog
	
	© Bell-Northern Research, 1991
	
**********************************************************************************/

#ifndef _H_BNRProlog		/* include this file only once */
#define _H_BNRProlog

/*      determine if we are using an ANSI-compatible compiler or not */

#ifndef _NO_PROTO			/* if no prototypes requested, don't check compiler type */
#ifdef __cplusplus                      /* C++ */
#define _NEEDS_PROTO
#endif
#ifdef __STDC__				/* regular ANSI compilers */
#define _NEEDS_PROTO
#endif
#ifdef applec				/* Macintosh MPW C */
#define _NEEDS_PROTO
#endif
#if defined(powerc) || defined (__powerc)	/* Macintosh PowerPC */
#define _NEEDS_PROTO
#endif
#ifdef THINK_C				/* Macintosh THINK C */
#define _NEEDS_PROTO
#endif
#endif
#ifdef __cplusplus                      /* For C++ declare as external C  */
extern "C" {
#endif

#include <stdio.h>			/* For FILE */

/*			Type Definitions										*/

typedef unsigned short BNRP_Boolean;

typedef enum {	
	BNRP_intParm,				/* int				*/
	BNRP_varIntParm,			/* int *			*/
	BNRP_shortParm,				/* short int		*/
	BNRP_varShortParm,			/* short int *		*/
	BNRP_longParm,				/* long int			*/
	BNRP_varLongParm,			/* long int *		*/
	BNRP_floatParm,				/* float			*/
	BNRP_varFloatParm,			/* float *			*/
	BNRP_doubleParm,			/* double			*/
	BNRP_varDoubleParm,			/* double *			*/
	BNRP_extendedParm,			/* long double		*/
	BNRP_varExtendedParm,		/* long double *	*/
	BNRP_symbolParm,			/* char *			*/
	BNRP_varSymbolParm,			/* char **			*/
	BNRP_termParm				/* BNRP_term		*/
	} BNRP_parms;
	
typedef enum {
	BNRP_invalid,
	BNRP_end=BNRP_invalid,
	BNRP_var=2,
	BNRP_tailvar,
	BNRP_integer,
	BNRP_float,
	BNRP_symbol,
	BNRP_list,
	BNRP_structure
	} BNRP_tag;
	

/* 	- task control block
	- user-accessible fields are numargs, arg[1], arg[2], ... */

#define BNRP_MAXREGS			256
#define numargs					args[0]

typedef struct BNRP_runHeader {
	long reserved[31];
	long args[BNRP_MAXREGS];
	} BNRP_TCB;				

typedef struct BNRP_mark {			/*	- heap mark block, size 20 bytes	*/
	long data[5];
	} BNRP_mark;
								
typedef long BNRP_term;				/*	- size 4 bytes (long **)	*/

typedef union BNRP_result {			/* depends on tag */
	long int ival;		/* BNRP_int */
	double fval;		/* BNRP_float */
	struct {			/* BNRP_symbol */
		BNRP_term orig;
		char *sval;
		} sym;
	BNRP_term tval;		/* BNRP_var, BNRP_tailvar */
	struct {			/* BNRP_list, BNRP_structure */
		BNRP_term first;
		BNRP_term functor_term; /* NEW BNRP_structure only */
		char *functor;	/* BNRP_structure only */
		int arity;		/* BNRP_structure only */
		} term;
	} BNRP_result;

typedef BNRP_Boolean (*BNRP_primitive)(BNRP_TCB *);
/* typedef BNRP_Boolean (*BNRP_primitive)();   WAS THIS IN JR's Version */
typedef void (*BNRP_procedure)();

/* 		Embedding Prolog into a program									*/

#ifdef _NEEDS_PROTO

int BNRP_initializeAllRings(int argc, char **argv);
int BNRP_initializeRing0(int argc, char **argv);
int BNRP_initializeRing1(int argc, char **argv);
int BNRP_initializeRing2(int argc, char **argv);
int BNRP_initializeRing3(int argc, char **argv);
int BNRP_initializeRing4(int argc, char **argv);
int BNRP_initializeRing5(int argc, char **argv);

int BNRP_newContext(
	const char *name1,			/* name of new context */
	const char *name2);			/* second name of new context */
	
int BNRP_loadFile(
	const char *filename);		/* name of the file to be loaded */

int BNRP_initializeTCB(
	BNRP_TCB *tcb,			/* task control block */
	const char *name,				/* task name */
	long heap_trailSize,	/* size of the heap and trail in bytes */
	long env_cpSize);		/* size of the environment space and choicepoint stack in bytes */

int BNRP_terminateTCB(
	BNRP_TCB *tcb);			/* task control block */

BNRP_TCB *BNRP_createTCB(void);

int BNRP_disposeTCB(
	BNRP_TCB **tcb);		/* task control block to be discarded */

/*		Defining procedures visible to Prolog							*/

int BNRP_bindPrimitive(
	const char *name,					/* name by which Prolog will call the procedure */
	BNRP_primitive procedure);	/* address of the procedure to be called */
	
int BNRP_bindProcedure(
	const char *name,					/* name by which Prolog will call the procedure */
	BNRP_procedure procedure,	/* address of the procedure to be called */
	int arity,					/* number of parameters expected */
	...);						/* type of each parameter in order */

void BNRP_primitiveName(
	BNRP_TCB *tcb,
	char *nameBuffer);

/*		Calling Prolog from foreign code								*/

int BNRP_execute(
	BNRP_TCB *tcb,
	BNRP_term term);

int BNRP_executeOnce(
	BNRP_TCB *tcb,
	BNRP_term term);

int BNRP_executeNext(
	BNRP_TCB *tcb);


/*		Examining Prolog terms											*/

BNRP_tag BNRP_getValue(
	BNRP_term term,		/* term to be decoded */
	BNRP_result *result);/* structure which contains the type of the term and its value */

BNRP_tag BNRP_getIndexedValue(
	BNRP_term term,		/* term to be decoded */
	int position,		/* index of the argument, may be 0 for structure name */
	BNRP_result *result);/* structure which contains the type of the term and its value 
							(another term in the case of lists and structures) */

BNRP_tag BNRP_getNextValue(
	BNRP_term *term,	/* term to be decoded, updated to point at next item*/
	BNRP_result *result);/* structure which contains the type of the term and its value 
							(another term in the case of lists and structures) */

BNRP_term BNRP_getIndexedTerm(
	BNRP_term term,		/* term to be decoded */
	int position);		/* index of the argument, may be 0 for structure name */

BNRP_term BNRP_getNextTerm(
	BNRP_term *term);	/* term to be decoded, updated to point at next item*/

BNRP_Boolean BNRP_listLength(
	 BNRP_term term,	/* list whose length is to be determined */
	 long *length);

void BNRP_dumpTerm(
	 FILE *file,		/* file to dump term to */
	 BNRP_term term);	/* term to dump */

/*		Creating Prolog terms											*/

BNRP_term BNRP_makeVar(
	BNRP_TCB *tcb);

BNRP_term BNRP_makeTailvar(
	BNRP_TCB *tcb);

BNRP_term BNRP_makeInteger(
	BNRP_TCB *tcb,
	long int l);

BNRP_term BNRP_makeFloat(
	BNRP_TCB *tcb,
	double d);
	
BNRP_term BNRP_makeSymbol(
	BNRP_TCB *tcb,
	const char *s);

BNRP_term BNRP_makePermSymbol(
	const char *s);

BNRP_term BNRP_makeList(
	BNRP_TCB *tcb,
	long arity,
	...);						/* actually any number of BNRP_term's */

BNRP_term BNRP_makeStructure(
	BNRP_TCB *tcb,
	const char *name,
	long arity,
	...);						/* actually any number of BNRP_term's */

BNRP_term BNRP_startList(
	BNRP_TCB *tcb);

BNRP_term BNRP_startStructure(
	BNRP_TCB *tcb,
	const char *name);

BNRP_term BNRP_startStructureAtom(
	BNRP_TCB *tcb,
	BNRP_term term1);
	
BNRP_term BNRP_makeTerm(
               BNRP_TCB *tcb,
               const char *s);

BNRP_Boolean BNRP_termToString(
	 BNRP_TCB	*tcb,
	 BNRP_term	term,
	 char*		buffer,
	 long		buflen);

BNRP_Boolean BNRP_addTerm(
	BNRP_TCB *tcb,
	BNRP_term term, 
	BNRP_term newTerm);
	
BNRP_term BNRP_buildList(
	BNRP_TCB *tcb,
	long arity,                                 /* number of terms */
    BNRP_term *terms);                          /* array of terms  */

BNRP_term BNRP_buildStructure(
	BNRP_TCB *tcb,
	const char *name,
	long arity,                                 /* number of terms */
    BNRP_term *terms);                          /* array of terms  */

/*		Unifying Prolog terms											*/

BNRP_Boolean BNRP_unify(
	BNRP_TCB *tcb,
	BNRP_term term1,
	BNRP_term term2);

/*		Storage reclamation aids										*/

void BNRP_markheap(
	BNRP_TCB *tcb,
	BNRP_mark *mark);
	
void BNRP_releaseheap(
	BNRP_TCB *tcb,
	BNRP_mark *mark);		/* created by a BNRP_markheap call */

/*		Memory usage routines											*/

void BNRP_contextSpaceUsed(
	long *allocated,
	long *used,
	long *nsym);

void BNRP_stackSpaceUsed(
	BNRP_TCB *tcb,
	long *heap,
	long *trail,
	long *env,
	long *cp);

void BNRP_stackSpaceCurrent(
	BNRP_TCB *tcb,
	long *heap,
	long *trail,
	long *env,
	long *cp);
	
void BNRP_error(long err);

/*		Used when compiling Prolog to C									*/

void BNRP_embedContext(
	const char *contextname,
	long version);
	
long BNRP_embedSymbol(
	const char *symbol);
	
long BNRP_embedInt(
	long i);
	
long BNRP_embedFloat(
	double f);

void BNRP_embedOperator(
	const char *op, /* was "operator", but operator is a reserved word in C++ */
	long precedence,
	const char *type);
	
void BNRP_embedClause(
	const char *predicate,
	long arity,
	long hash,
	long *clauseStart);
	
#ifdef __cplusplus              /* close the extern "C" {  */
}
#endif


#else		/* _NO_PROTO, see definitions above for comments */

int BNRP_initializeAllRings();
int BNRP_initializeRing0();
int BNRP_initializeRing1();
int BNRP_initializeRing2();
int BNRP_initializeRing3();
int BNRP_newContext();
int BNRP_loadFile();
BNRP_TCB *BNRP_createTCB();
int BNRP_initializeTCB();
int BNRP_terminateTCB();
int BNRP_bindPrimitive();
int BNRP_bindProcedure();
void BNRP_primitiveName();
int BNRP_execute();
int BNRP_executeOnce();
int BNRP_executeNext();
BNRP_tag BNRP_getValue();
BNRP_tag BNRP_getIndexedValue();
BNRP_tag BNRP_getNextValue();
BNRP_term BNRP_getIndexedTerm();
BNRP_term BNRP_getNextTerm();
BNRP_Boolean BNRP_listLength();
void BNRP_dumpTerm();
BNRP_term BNRP_makeVar();
BNRP_term BNRP_makeTailvar();
BNRP_term BNRP_makeInteger();
BNRP_term BNRP_makeFloat();
BNRP_term BNRP_makeSymbol();
BNRP_term BNRP_makePermSymbol();
BNRP_term BNRP_makeList();
BNRP_term BNRP_makeStructure();
BNRP_term BNRP_buildList();
BNRP_term BNRP_buildStructure();
BNRP_term BNRP_startList();
BNRP_term BNRP_startStructure();
BNRP_term BNRP_startStructureAtom();
BNRP_term BNRP_makeTerm();
BNRP_Boolean BNRP_termToString();
BNRP_Boolean BNRP_addTerm();
BNRP_Boolean BNRP_unify();
void BNRP_markheap();
void BNRP_releaseheap();
void BNRP_contextSpaceUsed();
void BNRP_stackSpaceUsed();
void BNRP_stackSpaceCurrent();
void BNRP_error();
void BNRP_embedContext();
long BNRP_embedSymbol();
long BNRP_embedInt();
long BNRP_embedFloat();
void BNRP_embedOperator();
void BNRP_embedClause();

#endif			/*_NO_PROTO */

#endif
