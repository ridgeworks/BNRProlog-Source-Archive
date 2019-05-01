/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/prim.c,v 1.14 1998/10/25 23:17:59 csavage Exp $
 *
 * $Log: prim.c,v $
 * Revision 1.14  1998/10/25  23:17:59  csavage
 * *** empty log message ***
 *
 * Revision 1.13  1997/11/21  14:29:11  harrisj
 * New primitive called globalCounter(X) has been added.
 * X is unified with an integer that is incremented each time the
 * primitive is called.  X starts at zero.
 *
 * Revision 1.12  1997/09/04  11:56:57  harrisj
 * Added memory_status\2 which doesn't calculate high water marks nor returns state space and context space used.
 *
 * Revision 1.11  1997/08/12  17:35:11  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.10  1997/07/31  15:57:36  harrisj
 * Added BNRP_finite primitive to return whether or not
 * a number is finite.  Must use +DA1.1 to compile.
 *
 * Revision 1.9  1997/03/21  10:28:42  harrisj
 * combining tailvar freeze constraints wasn't working properly.
 * joinvar primitive modified to support tailvars and the
 * combinevar predicate also modified to support tailvars.
 *
 * Revision 1.8  1996/06/24  12:03:34  yanzhou
 * The primtives listed below are modified, so that
 * they no longer create any permanent symbols on
 * return.  All symbols are now made as temporary
 * symbols:
 *     o BNRP_name
 *     o BNRP_concat
 *     o BNRP_substring
 *     o BNRP_lower
 *     o BNRP_upper
 *
 * Revision 1.7  1996/06/19  11:59:43  yanzhou
 * By default, the empty string "" is now a permanent symbol
 * in BNRProlog.
 *
 * REASON: The function computeKey() uses the first two
 * characters from a symbol to compute a hash key for it; but
 * an empty string "" does not have two characters in it, which
 * may potentially cause problems.
 *
 * Revision 1.6  1996/03/04  03:53:42  yanzhou
 * Improved substring() implementation for better performance.
 * Improved integer_range() implementation (cut before tail recursion).
 *
 * Revision 1.5  1996/02/08  05:03:16  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.5  1996/02/08  04:59:14  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   core.h             - new BOOLEANREQUIRED run-time error
 *   base5.p            - new $error_string() clause for the BOOLEANREQUIRED
 *                        run-time error
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.4  1996/02/01  03:29:49  yanzhou
 * New bit-wise operators added:
 *
 *  OPERATOR   TYPE   PRIORITY   WAM ESC CODE   HASH
 *  ------------------------------------------------
 *  butnot      yfx        600             CF    122
 *  bitshift    yfx        600             DF     94
 *  bitand      yfx        600             ED    119
 *  bitor       yfx        600             EE    197
 *  biteq       yfx        600             EF     59
 *
 *  Modified files are:
 *  base0.p            - new op() and eval() clauses.
 *  cmp_arithmetic.p   - new $func2() clauses.
 *  compile.p          - new $esc() entries.
 *  core.c             - new CF/DF/ED/EE/EF entries
 *                         in escape and in-clause modes.
 *  loader.c           - new hash entries in scanList(),
 *                         and -80 entries in remEscBytes[].
 *  prim.[hc]          - new atoms
 *
 * Revision 1.3  1995/12/12  14:21:53  yanzhou
 * 1) Signals, depending on the underlying OS, can now be handled
 * in one of the 3 ways listed below:
 *    USE_SIGACTION (POSIX) hpux9,ibm-aix4.1,nav88k-sysVr4,sunOS4.1
 *    USE_SIGSET    (SVID2) mdelta
 *    USE_SIGVECTOR (BSD)   sgi
 *
 * 2) Also changed is the way in which connect() timed-outs are
 * detected.  Was using SIGALRM to force a blocking connect() to
 * exit prematurally.  Now uses a combination of POSIX non-blocking
 * I/O mode (O_NONBLOCK) and select(), which handles the
 * situation more elegantly.
 *
 * 3) Now uses SA_RESTART if it is supported by the underlying OS.
 * This way, when a system call is interrupted by a signal, it is
 * transparently restarted on exit of the signal.
 * There is no need to define TICK_INTERRUPTS_SYSTEM_CALLS if
 * SA_RESTART is in effect.
 *
 * Revision 1.2  1995/12/04  00:03:31  yanzhou
 * In corebindVV() and BNRP_freeze(), unnecessary makevarterm()'s are removed,
 * which fixes the bug where [freeze(A, A is 1), freeze(B, B is 1), A=B] would
 * fail on hpux9 and cause run-time `dangling reference' error on ibm-aix4.1.
 *
 * Revision 1.1  1995/09/22  11:26:10  harrisja
 * Initial version.
 *
 *
 */
/* first line of prim.c */
#include "BNRProlog.h"
#include "base.h"
#include <stdio.h>
#ifdef mdelta             /* Not defined on mdelta */
#define _SIZE_T
#endif
#include <stddef.h>
#ifndef unix
#include <stdlib.h>		/* for system() */
#endif
#include <ctype.h>
#include <string.h>
#include <time.h>
#ifndef __MWERKS__
#include <values.h>		/* for MAXSHORT */
#endif
#ifndef MAXSHORT
#include <limits.h>
#define MAXSHORT	SHRT_MAX		/* new ANSI C name ? */
#endif
#include <math.h>
#include "core.h"
#include "interpreter.h"
#include "utility.h"
#include "context.h"
#include "compare.h"
#include "prim.h"
#include "ioprim.h"
#include "parse.h"
#include "ioprim.h"
#include "state.h"
#include "hardware.h"
#include "loader.h"
#include "stats.h"
#include "memory.h"

/* #define testinterface */

#ifdef ring0
BNRP_term	curlyAtom,			/* used by parser */
			commaAtom,
			cutAtom, 			/* used by clause$$ */
			cutcutAtom,
			cutFailAtom,
			recoveryUnitAtom,
			isAtom,
			plusAtom,
			minusAtom,
			starAtom,
			slashAtom,
			slashslashAtom,
			modAtom,
			starstarAtom,
			intAtom,
			floatAtom,
			floorAtom,
			ceilAtom,
			roundAtom,
			maxAtom,
			minAtom,
			sqrtAtom,
			absAtom,
			expAtom,
			lnAtom,
			sinAtom,
			cosAtom,
			tanAtom,
			asinAtom,
			acosAtom,
			atanAtom,
			maxintAtom,
			maxfloatAtom,
			piAtom,
			cputimeAtom,
            butnotAtom,
            bitshiftAtom,
            bitandAtom,
            bitorAtom,
            biteqAtom,
            boolnotAtom,
            boolandAtom,
            boolorAtom,
            boolxorAtom,
			eqAtom,
			neAtom,
			ltAtom,
			gtAtom,
			geAtom,
			leAtom,
			clauseAtom,
			execAtom,
			failAtom,
			varAtom,
			tailvarAtom,
			BNRP_filterNames[32],
			numberAtom,
			nonNumberAtom,
			attentionAtom,
			ifAtom,
			orAtom,
			indirectAtom,
			unificationAtom,
			eofAtom,
			tracerAtom,
			tickAtom,
			ssAtom,
			intervalAtom,
			integralAtom,
			booleanAtom,
			evalConstrainedAtom,
			noopnodeAtom,
			BNRPmarkAtom,
			BNRP_combineVarAtom,
			BNRP_defaultTaskName,
			BNRP_taskswitch_primitive;

BNRP_term	counterAtom, indirectListAtom;
#else
extern BNRP_term counterAtom, indirectListAtom;
/* other atoms are extern in prim.h */
#endif



#ifdef ring0
BNRP_Boolean BNRPBindPrimitive(const char *name, BNRP_Boolean (*address)())
{
	BNRP_term symbol;
	
	symbol = BNRPLookupPermSymbol(name);
	return(BNRP_addClause(symbol, 0L, 0L, 0L, (void *)address, TRUE) != NULL);
	}
#endif

/* #define tracecut /* */

#ifdef ring0
/* this procedure handles edinburgh cut when it is meta-interpreted */
/* only. This means that we need to be able to skip -> and ;, as    */
/*  well as any calls used by the meta-interpreter.					*/                
BNRP_Boolean BNRP_eCut(TCB *tcb)
{
	long l, ll, result, cutb, thisenv;
	char *sp;

	if (tcb->numargs EQ 0) {
#ifdef tracecut
		printf("    Executing -> !\n");
#endif
		l = tcb->ce;
		for (;;) {
			/* get name from this environment, clearing mark bit */
			result = env(l, NAME) & 0xFFFFFFFE;
			/* name must be a symbol or we're done */
			if (tagof(result) NE SYMBOLTAG) break;
#ifdef tracecut
			sp = nameof(result);
			printf("    Called by -> ");
			if (BNRP_needsQuotes(sp))
				BNRP_dumpWithQuotes(stdout, sp);
			else
				printf("%s", sp);
#endif
			/* get cut point from environment */
			cutb = env(l, CUTB);
#ifdef tracecut
			printf("(e @ %08lX, cutb = %08lX)\n", l, cutb);
#endif
			/* get previous environment */
			if (l EQ (ll = env(l, CE))) break;
			thisenv = l;
			l = ll;
			if (result EQ ifAtom) continue;				/* skip -> */
			if (result EQ orAtom) continue;				/* skip ; */
			if (result EQ indirectAtom) continue;		/* skip $$callindirect in base */
			if (result EQ indirectListAtom) continue;	/* skip $$calllistindirect in base */
			/* skip $$callindirect and $$calllistindirect outside of base (debugger) */
			sp = nameof(result);
			if ((sp[0] EQ '$') && (sp[1] EQ '$')) {		/* save some calls if possible */
				if (strcmp(sp, "$$callindirect") EQ 0) continue;
				if (strcmp(sp, "$$calllistindirect") EQ 0) continue;
				}
			/* must cut into this environment */
			if (cutb GE tcb->lcp) {
#ifdef tracecut
				choicepoint *nextcp;
				
				/* must reset cp to at most cutb */
				nextcp = (choicepoint *)tcb->lcp;
#ifdef tracecut
				printf("top choicepoint @ %08lX, env = %08lX, name = %s\n", tcb->lcp, nextcp->bce, nameof(nextcp->procname));
#endif
				while ((long)nextcp->lcp LT cutb) {
					nextcp = nextcp->lcp;
#ifdef tracecut
					printf("next choicepoint @ %08lX, env = %08lX, name = %s\n", (long)nextcp, nextcp->bce, nameof(nextcp->procname));
#endif
					}
#ifdef tracecut
				printf("last choicepoint @ %08lX, env = %08lX, name = %s\n", (long)nextcp->lcp, nextcp->lcp->bce, nameof(nextcp->lcp->procname));
				printf("lcp was %08lX ", tcb->lcp);
#endif
#endif
				tcb->lcp = cutb;
				/* commented out 93/05/03 now that calls to ; and -> are not execs
				if (nextcp->bce LE thisenv)
					tcb->lcp = (long)nextcp;
				*/
#ifdef tracecut
				printf("changed to %08lX, cutb = %08lX\n", tcb->lcp, cutb);
#endif
				}
			break;
			}
		return(TRUE);
		}
	return(FALSE);
	}
#endif

#ifdef ring0
BNRP_Boolean BNRP_fixCutb(TCB *tcb)
{
	long ce, result;
#ifdef debug
	choicepoint *cp;
	
	ce = tcb->ce;
	while ((result = env(ce, CE)) NE ce) {
		printf("Env @ %08lx, cutb = %08lx, name = %s\n", ce, env(ce, CUTB), nameof(env(ce, NAME)));
		ce = result;
		}
	cp = (choicepoint *)tcb->lcp;
	while ((long)cp NE tcb->cpbase) {
		if (cp EQ NULL) break;
		printf("CP @ %08lx, ce = %08lx, name = %s\n", (long)cp, cp->bce, nameof(cp->procname));
		cp = cp->lcp;
		}
#endif
	/* get previous env */
	ce = env(tcb->ce, CE);						
	/* only skip over $$calllistindirect calls to get to $$callindirect to be skipped */
	result = env(ce, NAME) & 0xFFFFFFFE;
	while (result EQ indirectListAtom) {
		ce = env(ce, CE);
		result = env(ce, NAME) & 0xFFFFFFFE;
		}
	if (result EQ indirectAtom) {
		/* reset cutb, both as a register and the one saved in the current env */
		tcb->cutb = env(tcb->ce, CUTB) = env(ce, CUTB);
		}
	return(tcb->numargs EQ 0);
	}
#endif

#ifdef ring0
/* the following string is set inside the core on any error */
char BNRP_lastErrorTraceback[tracebackStrLen] = "\0";

void BNRP_errorTraceback(TCB *tcb)
/* only used from assembler, C core does this inline */
{
	long l, result;
	
	strcpy(BNRP_lastErrorTraceback, "Traceback:");
	if (tagof((result = tcb->procname)) EQ SYMBOLTAG) {
		strcat(BNRP_lastErrorTraceback, "\n    Executing -> ");
		strncat(BNRP_lastErrorTraceback, 
				nameof(result), 
				tracebackStrLen - strlen(BNRP_lastErrorTraceback));
		if (((tcb->ppsw & isolateResult) EQ NAMEDCUTNOTFOUND) && (tagof(tcb->args[1]) EQ SYMBOLTAG)) {
			strcat(BNRP_lastErrorTraceback, "(");
			strncat(BNRP_lastErrorTraceback, 
					nameof(tcb->args[1]), 
					tracebackStrLen - strlen(BNRP_lastErrorTraceback) - 2);
			strcat(BNRP_lastErrorTraceback, ")");
			}
		}
	l = tcb->ce;
	while ((tracebackStrLen - strlen(BNRP_lastErrorTraceback)) GT 50) {
		result = env(l, NAME) & 0xFFFFFFFE;
		if (tagof(result) NE SYMBOLTAG) break;
		/* keep track of first recovery_unit we discover */
		strcat(BNRP_lastErrorTraceback, "\n    Called by -> "); 
		strncat(BNRP_lastErrorTraceback, 
				nameof(result), 
				tracebackStrLen - strlen(BNRP_lastErrorTraceback));
		if (l EQ env(l, CE)) break;
		l = env(l, CE);					/* back up to previous env */
		}
	}
#endif

#ifdef ring5
void BNRP_traceback(TCB *tcb, long numItems)
{
	long l, ll, result, i;
	char *sp;
	
	l = tcb->ce;
	output("Traceback:\n    Executing -> traceback");
	for (i = 0; i LT numItems; ++i) {
		result = env(l, NAME) & 0xFFFFFFFE;
		if (tagof(result) NE SYMBOLTAG) break;
		sp = nameof(result);
		output("\n    Called by -> ");
		if (BNRP_needsQuotes(sp))
			BNRP_dumpWithQuotes((FILE *)BNRP_fileIndex, sp);
		else
			outputstr(sp);
		if (l EQ (ll = env(l, CE))) break;
		l = ll;
		}
	output("\n\n");
	}
#endif

#ifdef ring5
void BNRP_choicepoints(TCB *tcb, long numItems)
{
	choicepoint *lcp = (choicepoint *)tcb->lcp;
	
	output("Choicepoints:");
	while ((long)lcp NE tcb->cpbase) {
		if (lcp EQ NULL) break;
		if (lcp->clp NE (long)NULL) {			/* next clause exists ?? */
			char *sp = nameof(lcp->procname);
			output("\n-> ");
			if (BNRP_needsQuotes(sp))
				BNRP_dumpWithQuotes((FILE *)BNRP_fileIndex, sp);
			else
				outputstr(sp);
			if (--numItems LE 0) break;
			}
		lcp = lcp->lcp;
		}
	output("\n\n");
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_goal(TCB *tcb)
{
	long n, l, result, next;
	
	if ((tcb->numargs EQ 3) && (checkArg(tcb->args[1], &n) EQ INTT)) {
		if (n EQ 0) n = tcb->ce;
		
		l = tcb->ce;
		while (n NE l) {
			if (l EQ (next = env(l, CE))) return(FALSE);
			l = next;
			}
		result = env(l, NAME) & 0xFFFFFFFE;
		if (result EQ tracerAtom) {
			next = env(l, 1);
			if (tagof(next) EQ STRUCTTAG) {
				result = maketerm(STRUCTTAG, tcb->hp);
				push(long, tcb->hp, UNARYHEADER);
				push(long, tcb->hp, tracerAtom);
				push(long, tcb->hp, next);
				push(long, tcb->hp, 0L);
				}
			}
		next = env(l, CE);
		return(unify(tcb, tcb->args[2], result) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, next)));
		}
	return(FALSE);
	}
#endif

#ifdef ring0
BNRP_Boolean BNRP_doGetErrorCode(TCB *tcb)
{
	if (tcb->numargs EQ 1)
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, tcb->ppsw & isolateResult)));
	else if (tcb->numargs EQ 2)
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, tcb->ppsw & isolateResult)) &&
			   unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, BNRP_lastErrorTraceback, TEMPSYM, GLOBAL)));
	else
		return(FALSE);
	}
#endif

#ifdef ring0
BNRP_Boolean BNRP_doError(TCB *tcb)
{
	long err;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &err) EQ INTT))
		BNRP_error(err);		/* this will not return */
	return(FALSE);
	}
#endif

#ifdef ring0
long getCPUTime()
{
	fp f;
	
	return(BNRP_getUserTime(FALSE, &f));
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_getAddress(TCB *tcb)
{
	BNRP_term proc;
	long index;
	clauseEntry *cp;

	if ((tcb->numargs EQ 3) && 
		(checkArg(tcb->args[1], &proc) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &index) EQ INTT)) {
		symbolEntry *s;
		
		checksym(proc, s);
		cp = s->firstClause;
		if ((long)cp LT 0)
			return(FALSE);
		else if (index NE 0)
			while (cp NE NULL) {
				if ((long)cp EQ index) {
					cp = cp->nextClause;
					break;
					}
				cp = cp->nextClause;
				}
		if (cp NE NULL)
			return(unify(tcb, tcb->args[3], makeint(&tcb->hp, (long)cp)));
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_getArity(TCB *tcb)
{
	long index;
	clauseEntry *cp;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &index) EQ INTT)) {
		cp = (clauseEntry *)index;
		return(unify(tcb, tcb->args[2], makeint(&tcb->hp, cp->arity)));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_newCounter(TCB *tcb)
{
	long l;
	BNRP_term i, t1, t2;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &l) EQ INTT) && 
							   (checkArg(tcb->args[2], &t1) EQ VART)) {
		/* first create a long integer on the heap */
		i = maketerm(STRUCTTAG, tcb->hp);
		push(long, tcb->hp, INTID);
		push(long, tcb->hp, l);
		/* now make a term that points to it */
		t1 = maketerm(STRUCTTAG, tcb->hp);
		push(long, tcb->hp, UNARYHEADER);
		push(long, tcb->hp, counterAtom);
		push(long, tcb->hp, i);
		push(long, tcb->hp, 0);
		t2 = maketerm(STRUCTTAG, tcb->hp);
		push(long, tcb->hp, UNARYHEADER);
		push(long, tcb->hp, counterAtom);
		push(long, tcb->hp, t1);
		push(long, tcb->hp, 0);
		return(unify(tcb, tcb->args[2], t2));
		}
	return(FALSE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_incrCounter(TCB *tcb)
{
	long struc, *p, *q;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &struc) EQ STRUCTT)) {
		p = (long *)addrof(struc);
		if (*p++ EQ UNARYHEADER)
			if (*p++ EQ counterAtom)
				if (tagof(*p) EQ STRUCTTAG) {
					q = (long *)addrof(*p);
					if (*q++ EQ INTID) {
						++*q;
						return(TRUE);
						}
					}
		}
	return(FALSE);
	}
#endif

#ifdef ring1
static long int globalCounter=0;

BNRP_Boolean BNRP_globalCounter(TCB *tcb)
{
   if(tcb->numargs NE 1) return FALSE;
   
   return(unify(tcb, tcb->args[1], makeint(&tcb->hp, globalCounter++)));
}
#endif


#define trail(te, addr)					rpush(long, te, *(long *)addr); \
										rpush(long, te, (long)addr);
										
#define heapcheck(n)					if ((tcb->heapend - tcb->hp) LE (n * sizeof(long))) \
											BNRP_error(HEAPOVERFLOW)


#ifdef ring1
BNRP_Boolean BNRP_freeze(TCB *tcb)
{
	long var, mask, *p, cons, t1;
	BNRP_tag t;
	
	if (tcb->numargs EQ 2) {
		heapcheck(12);           /* New Jan 95--was 10 */
		cons = tcb->args[2];
		if ((t = (BNRP_tag)checkArg(tcb->args[1], &var)) EQ VART) {
			p = (long *)addrof(var);
			mask = VARTAG;
			}
		else if (t EQ LISTT) {
			for (;;) {
				p = (long *)addrof(var);
				var = *p;
				if (tagof(var) NE TAILVARTAG) goto fireConstraint;
				if (addrof(var) EQ (long)p) break;
				/* loop until we get to the end of the chain */
				}
			mask = TAILVARMASK;
			}
		else {
			/* not a var or TV, so simply fire the constraint, 
			   assume no other constraints pending */
fireConstraint:
			if (tagof(cons) EQ LISTTAG)
				tcb->constraintHead = cons;
			else {
				tcb->constraintHead = maketerm(LISTTAG, tcb->hp);
				push(long, tcb->hp, cons);
				push(long, tcb->hp, 0);
				}
			return(TRUE);
			}
		/* p points to the VAR or TV */
		/* now check second argument for constraint */
		while ((t1 = tagof(cons)) EQ VARTAG) {
			register long _ll = derefVAR(cons);
			if (cons EQ _ll) return(FALSE);
			cons = _ll;
			}
		if ((t1 EQ LISTTAG) || (t1 EQ STRUCTTAG) || (t1 EQ SYMBOLTAG)) {
			register long hp = tcb->hp;
			
			if (p[1] EQ CONSTRAINTMARK) {
				/* var already has a constraint, combine them */
/**** code removed 93/7/20 JR to let prolog combine constraints
				register long newcons = maketerm(LISTTAG, hp);
				
				if (t EQ LISTTAG) {
					push(long, hp, p[2]);					// original constraint 
					push(long, hp, maketerm(TVTAG, addrof(cons)));	// new list appended as TV
					}
				else if (tagof(p[2]) EQ LISTTAG) {
					push(long, hp, cons);					// new constraint
					push(long, hp, maketerm(TVTAG, addrof(p[2])));	// old list appended as TV 
					}
				else {
					push(long, hp, p[2]);					// original constraint
					push(long, hp, cons);					// new constraint
					push(long, hp, 0);						// terminate list
					}
				cons = newcons;
*****/
				BNRP_term g, tvar_list, tvar_list2;
				if(mask EQ TAILVARMASK)
				{
				   tvar_list = maketerm(LISTTAG,hp);
				   push(long, hp, p[0]);
				   push(long, hp, 0);
				   
				   tvar_list2 = maketerm(LISTTAG,hp);
				   push(long, hp, maketerm(TVTAG,hp));
				   push(long, hp, 0);
				 }
				
				g = maketerm(STRUCTTAG, hp);
				push(long, hp, FUNCID | 5);
				push(long, hp, BNRP_combineVarAtom);
				if(mask EQ VARMASK) {
				   push(long, hp, p[0]);           /* p[0] is a variable term */
				}
				else {
				   push(long, hp, tvar_list);
				}
				push(long, hp, p[2]);
				if(mask EQ VARMASK) {
				   push(long, hp, makevarterm(hp));
				}
				else {
				   push(long, hp, tvar_list2);
				}
				push(long, hp, cons);
				push(long, hp, 0);
				
				if (tcb->constraintHead EQ 0)		/* new list of constraints ?? */
					tcb->constraintHead = maketerm(LISTTAG, hp);
				else								/* append to existing list */
					*(long *)(tcb->constraintTail) = maketerm(TVTAG, hp);
				push(long, hp, g);					/* push constraint onto heap */
				tcb->constraintTail = hp;
				push(long, hp, 0);					/* end of list */
				tcb->hp = hp;
				return(TRUE);
				}
				
			trail(tcb->te, (long)p);			/* save existing variable */
			*p = maketerm(mask, hp);			/* bind old var to new var */
			push(long, hp, maketerm(mask, hp));	/* create new var on the heap */
			push(long, hp, CONSTRAINTMARK);
			push(long, hp, cons);
			*(long *)hp = 0;			/* make sure another constraint marker not next */
			tcb->hp = hp;
			return(TRUE);
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_joinVar(TCB *tcb)
{
	long var1, var2, *p1, *p2, cons;
	
	if (tcb->numargs NE 3) return(FALSE);
	var1 = tcb->args[1];
	var2 = tcb->args[2];
	if((tagof(var1) EQ VARTAG) && (tagof(var2) EQ VARTAG)) {
	   while (tagof(var1) EQ VARTAG) {
		   p1 = (long *)addrof(var1);
		   if (var1 EQ *p1) break;
		   var1 = *p1;
		   }
	   while (tagof(var2) EQ VARTAG) {
		   p2 = (long *)addrof(var2);
		   if (var2 EQ *p2) break;
		   var2 = *p2;
		   }
	    }
	else if((tagof(var1) EQ LISTTAG) && (tagof(var2) EQ LISTTAG)) {
	   p1 = (long *)addrof(var1);
	   var1 = *p1;
	   p2 = (long *)addrof(var1);
	   var2 = *p2;
	   while (tagof(var1) EQ TVTAG) {
		   p1 = (long *)addrof(var1);
		   if (var1 EQ *p1) break;
		   var1 = *p1;
		   }

	   while (tagof(var2) EQ TVTAG) {
		   p2 = (long *)addrof(var2);
		   if (var2 EQ *p2) break;
		   var2 = *p2;
		   }
	    }

	cons = tcb->args[3];
	/* now check second argument for constraint */
	while (tagof(cons) EQ VARTAG) {
		register long _ll = derefVAR(cons);
		if (cons EQ _ll) return(FALSE);
		cons = _ll;
		}
	heapcheck(4);
	trail(tcb->te, (long)p1);				/* save existing variable */
	trail(tcb->te, (long)p2);
	*p1 = *p2 = maketerm(tagof(var1), tcb->hp);	/* bind old vars to new var */
	push(long, tcb->hp, *p1);				/* create new var on the heap */
	push(long, tcb->hp, CONSTRAINTMARK);
	push(long, tcb->hp, cons);
	*(long *)tcb->hp = 0;					/* make sure another constraint marker not next */
	return(TRUE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_name(TCB *tcb)
{
	long result, p, orig, t;
	unsigned char *sp;
	long LDCount, LDHold, LDk, LDSaveAddr;
	ptr addr;
	TAG tag;
	
	if (tcb->numargs EQ 2) {
		if (checkArg(tcb->args[1], &result) EQ SYMBOLT) {
			sp = (unsigned char *)nameof(result);
			if ((strlen((char *)sp) * 4) GT (tcb->heapend - tcb->hp)) return(FALSE);
			result = maketerm(LISTTAG, tcb->hp);
			while (*sp) {
				push(long, tcb->hp, makeintterm(*sp++));
				}
			push(long, tcb->hp, 0);
			return(unify(tcb, tcb->args[2], result));
			}
		else if (checkArg(tcb->args[2], &result) EQ LISTT) {
			sp = (unsigned char *)tcb->hp;
			p = addrof(result);
			LDCount = 1;
			LDHold = 2;
			LDk = 0;
			derefTV(&p, &orig, &tag, &result, &addr);
			while (tag EQ INTT) {
				if ((result LE 0) || (result GT 255)) return(FALSE);
				*sp++ = (char)result;
				t = p;
				derefTV(&p, &orig, &tag, &result, &addr);
				if (p LE t) {			/* possible loop */
					if (--LDCount LE 0) {
						if (LDk EQ 0) {
							LDk = LDHold;
							LDHold += LDHold;
							LDSaveAddr = p;
							}
						else {
							--LDk;
							if (LDSaveAddr EQ p) break;
							}
						}
					}
				}
			if (tag EQ ENDT) {
				*sp = '\0';
				return(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)(tcb->hp) NE '$'))));
				}
			}
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_concat(TCB *tcb)
{
	long result1, result2;
	char *s1, *s2, *new;
	size_t l1, l2;
	
	if ((tcb->numargs EQ 3) && 
		(checkArg(tcb->args[1], &result1) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &result2) EQ SYMBOLT)) {
		s1 = nameof(result1);
		s2 = nameof(result2);
		l1 = strlen(s1);
		l2 = strlen(s2);
		if ((l1 + l2) GT (tcb->heapend - tcb->hp)) return(FALSE);
		new = (char *)tcb->hp;
		strcpy(new, s1);
		new += l1;
		strcpy(new, s2);
		return(unify(tcb, tcb->args[3], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)tcb->hp NE '$'))));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_substring(TCB *tcb)
{
	long result, index, len;
	char *sp, *new;
	
	if ((tcb->numargs EQ 4) && 
		(checkArg(tcb->args[1], &result) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &index) EQ INTT) &&
		(checkArg(tcb->args[3], &len) EQ INTT)) {
		sp = nameof(result);
		--index;				/* since offsets start at 0 */
		if (index + len GT strlen(sp)) return(FALSE);
		if (len GE (tcb->heapend - tcb->hp)) return(FALSE);
		new = (char *)tcb->hp;
		sp += index;
		strncpy(new, sp, len);
		new[len] = '\0';
		return(unify(tcb, tcb->args[4], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)tcb->hp NE '$'))));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_strstr(TCB *tcb)
{
    long s1, start, s2;
	char *str1, *str2, *found;
    int  index;
	
	if ((tcb->numargs EQ 4) && 
		(checkArg(tcb->args[1], &s1) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &start) EQ INTT) &&
		(checkArg(tcb->args[3], &s2) EQ SYMBOLT)) {
        str1 = nameof(s1);
        if (start GT strlen(str1))
            return FALSE;                       /* end of string reached    */

        str2 = nameof(s2);

        found = strstr(str1+start-1, str2);
        if (!found) return FALSE;               /* failed                   */

        index = found - str1 + 1;               /* relative position from 1 */

		return unify(tcb, tcb->args[4], makeint(&tcb->hp, index));
    }
	return FALSE;
}
#endif

#ifdef ring1
BNRP_Boolean BNRP_lowercase(TCB *tcb)
{
	long result;
	unsigned char *sp, *new;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
		sp = (unsigned char *)nameof(result);
		if (strlen((char *)sp) GT (tcb->heapend - tcb->hp)) return(FALSE);
		new = (unsigned char *)tcb->hp;
		while (*sp)
			*new++ = tolower(*sp++);
		*new = '\0';
		return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)tcb->hp NE '$'))));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_uppercase(TCB *tcb)
{
	long result;
	unsigned char *sp, *new;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
		sp = (unsigned char *)nameof(result);
		if (strlen((char *)sp) GT (tcb->heapend - tcb->hp)) return(FALSE);
		new = (unsigned char *)tcb->hp;
		while (*sp)
			*new++ = toupper(*sp++);
		*new = '\0';
		return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)tcb->hp NE '$'))));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_namelength(TCB *tcb)
{
	long result, len;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
		len = strlen(nameof(result));
		return(unify(tcb, tcb->args[2], makeint(&tcb->hp, len)));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
long gensymIndex = 0;

BNRP_Boolean BNRP_gensym(TCB *tcb)
{
	long len;
	BNRP_term result;
	char *sp, *new;
	BNRP_Boolean found = TRUE;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
		len = strlen(sp = nameof(result));
		if (len+20 GT (tcb->heapend - tcb->hp)) return(FALSE);
		new = (char *)tcb->hp;
		while (found) {
			sprintf(new, "%s%ld", sp, ++gensymIndex);
			found = BNRPFindSymbol(new, GLOBAL, &result);
			}
		return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, new, TEMPSYM, (*new NE '$'))));
		}
	return(FALSE);	
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_getConstraint(TCB *tcb)
{
	long var1, *addr;
	TAG tag1;
	
	if (tcb->numargs EQ 2) {
		tag1 = checkArg(tcb->args[1], &var1);
		addr = (long *)addrof(var1);
		if ((tag1 EQ VART) && (addr[1] EQ CONSTRAINTMARK)) {
			return(unify(tcb, tcb->args[2], addr[2]));
			}
		else if (tag1 EQ LISTT) {
			while (tagof(addr[0]) EQ TVTAG) {
				if (addr[0] EQ maketerm(TVTAG, (long)addr)) break;
				addr = (long *)addrof(addr[0]);
				}
			if ((tagof(addr[0]) EQ TVTAG) && (addr[1] EQ CONSTRAINTMARK))
				return(unify(tcb, tcb->args[2], addr[2]));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_defineOperator(TCB *tcb)
{
	BNRP_term result;
	long prec;
	long ty;
	static int newtype[7] = { xf, yf, fy, fx, yfx, xfy, xfx };

	if ((tcb->numargs EQ 3) && 
		(checkArg(tcb->args[1], &result) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &prec) EQ INTT) &&
		(checkArg(tcb->args[3], &ty) EQ INTT))
		if ((ty GE 0) && (ty LT 7)) {
			int t, p;
			
			t = newtype[ty];
			p = prec;
			return(BNRP_addOperator(result, t, p));
			}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_retract(TCB *tcb)
{
	BNRP_term pred;
	clauseEntry *c;
	long l;
	
	if ((tcb->numargs EQ 2) && 
		(checkArg(tcb->args[1], &pred) EQ SYMBOLT) &&
		(checkArg(tcb->args[2], &l) EQ INTT)) {
		c = (clauseEntry *)l;
		return (BNRP_removeClause(pred, c));
		}
	return(FALSE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_configuration(TCB *tcb)
{
	TAG tag;
	BNRP_term l;
	char *conf;
	
	if (tcb->numargs EQ 1) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ SYMBOLT) {
			return(BNRP_setConfig(nameof(l)));
			}
		else if (tag EQ VART) {
			if ((conf = BNRP_getConfig()) EQ NULL) return(FALSE);
			return(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, conf, TEMPSYM, GLOBAL)));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring0
long BNRP_statStartTime = 0, BNRP_statElapsedTime = 0;
#else
extern long BNRP_statStartTime, BNRP_statElapsedTime;
#endif

#ifdef ring1
long BNRP_intervalOperations = 0, BNRP_intervalIterations = 0;

BNRP_Boolean BNRP_regularStatus(TCB *tcb)
{
	fp t;
	long endTime, userTime, elapsedTime;
	long s1, e1, s2, e2;
	
	if (tcb->numargs EQ 0) {
		BNRP_freespace(tcb, &s1, &e1, &s2, &e2);
		memset((void *)s1, 0xAA, e1-s1);
		memset((void *)s2, 0xAA, e2-s2);
		BNRP_initStats();
		BNRP_numGC = 0;
		BNRP_intervalOperations = BNRP_intervalIterations = 0;
		BNRP_statStartTime = BNRP_getUserTime(TRUE, &t);
		BNRP_statElapsedTime = BNRP_getElapsedTime();
		return(TRUE);
		}
	else if (tcb->numargs EQ 5) {
		endTime = BNRP_getUserTime(FALSE, &t);
		userTime = endTime - BNRP_statStartTime - (long)t;
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRP_getLIPS() - BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[2], makeint(&tcb->hp, BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, BNRP_intervalOperations)) &&
			   unify(tcb, tcb->args[4], makeint(&tcb->hp, BNRP_intervalIterations)) &&
			   unify(tcb, tcb->args[5], makeint(&tcb->hp, userTime)));
		}
	else if (tcb->numargs EQ 6) {
		endTime = BNRP_getUserTime(FALSE, &t);
		userTime = endTime - BNRP_statStartTime - (long)t;
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRP_getLIPS() - BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[2], makeint(&tcb->hp, BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, BNRP_intervalOperations)) &&
			   unify(tcb, tcb->args[4], makeint(&tcb->hp, BNRP_intervalIterations)) &&
			   unify(tcb, tcb->args[5], makeint(&tcb->hp, userTime)) &&
			   unify(tcb, tcb->args[6], makeint(&tcb->hp, BNRP_numGC)));
		}
	else if (tcb->numargs EQ 7) {
		endTime = BNRP_getUserTime(FALSE, &t);
		userTime = endTime - BNRP_statStartTime - (long)t;
		elapsedTime = BNRP_getElapsedTime() - BNRP_statElapsedTime;
		return(unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRP_getLIPS() - BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[2], makeint(&tcb->hp, BNRPprimitiveCalls)) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, BNRP_intervalOperations)) &&
			   unify(tcb, tcb->args[4], makeint(&tcb->hp, BNRP_intervalIterations)) &&
			   unify(tcb, tcb->args[5], makeint(&tcb->hp, userTime)) &&
			   unify(tcb, tcb->args[6], makeint(&tcb->hp, BNRP_numGC)) &&
			   unify(tcb, tcb->args[7], makeint(&tcb->hp, elapsedTime)));
		}
	return(FALSE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_memoryStatus(TCB *tcb)
{
	long s1, e1, s2, e2;
	long heapAndTrailTotal, heapAndTrailCurrent;
	long envAndCPTotal, envAndCPCurrent;
	
	if ((tcb->numargs NE 9) && (tcb->numargs NE 4)) return(FALSE);
	BNRP_freespace(tcb, &s1, &e1, &s2, &e2);
	heapAndTrailTotal = tcb->trailbase - tcb->heapbase + sizeof(long);
	heapAndTrailCurrent = heapAndTrailTotal - (e2 - s2);
	envAndCPTotal = tcb->cpbase - tcb->envbase + sizeof(long);
	envAndCPCurrent = envAndCPTotal - (e1 - s1);

	if(tcb->numargs EQ 9)
	{
	   long heap, trail, env, cp, nsym;
	   long contextTotal, contextCurrent, contextMaximum;
	   long heapAndTrailMaximum, envAndCPMaximum;

	   BNRP_stackSpaceUsed((BNRP_TCB *)tcb, &heap, &trail, &env, &cp);
	   BNRP_contextSpaceUsed(&contextTotal, &contextMaximum, &nsym);
	   contextCurrent = contextMaximum;
	   
	   if ((heapAndTrailMaximum = heap + trail) GT heapAndTrailTotal)
		   heapAndTrailMaximum = heapAndTrailTotal;
	   if (heapAndTrailMaximum LT heapAndTrailCurrent) 
		   heapAndTrailMaximum = heapAndTrailCurrent;
	   if ((envAndCPMaximum = env + cp) GT envAndCPTotal)
		   envAndCPMaximum = envAndCPTotal;
	   if (envAndCPMaximum LT envAndCPCurrent) 
		   envAndCPMaximum = envAndCPCurrent;
	   return(unify(tcb, tcb->args[1], makeint(&tcb->hp, contextTotal)) &&
		      unify(tcb, tcb->args[2], makeint(&tcb->hp, contextCurrent)) &&
		      unify(tcb, tcb->args[3], makeint(&tcb->hp, contextMaximum)) &&
		      unify(tcb, tcb->args[4], makeint(&tcb->hp, heapAndTrailTotal)) &&
		      unify(tcb, tcb->args[5], makeint(&tcb->hp, heapAndTrailCurrent)) &&
		      unify(tcb, tcb->args[6], makeint(&tcb->hp, heapAndTrailMaximum)) &&
		      unify(tcb, tcb->args[7], makeint(&tcb->hp, envAndCPTotal)) &&
		      unify(tcb, tcb->args[8], makeint(&tcb->hp, envAndCPCurrent)) &&
		      unify(tcb, tcb->args[9], makeint(&tcb->hp, envAndCPMaximum)));
	}
	else {
	   return(unify(tcb, tcb->args[1], makeint(&tcb->hp, heapAndTrailTotal)) &&
		      unify(tcb, tcb->args[2], makeint(&tcb->hp, heapAndTrailCurrent)) &&
		      unify(tcb, tcb->args[3], makeint(&tcb->hp, envAndCPTotal)) &&
		      unify(tcb, tcb->args[4], makeint(&tcb->hp, envAndCPCurrent)));
	}
}
#endif

#ifdef ring0
long BNRP_gcFlag = 0;

BNRP_Boolean BNRP_set_gc(TCB *tcb)
{
	TAG tag;
	BNRP_term l;
	
	if (tcb->numargs EQ 1)
		if ((tag = checkArg(tcb->args[1], &l)) EQ INTT) {
			BNRP_gcFlag = l;
			return(TRUE);
			}
		else if (tag EQ VART)
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRP_gcFlag)));
	return(FALSE);
	}
#endif

#ifdef testinterface
static void BNRP_dumplowlevel(TAG tag, BNRP_result r)
{
	switch (tag) {
		case BNRP_invalid:
							printf("Invalid\n");
							break;
		case BNRP_end:
							printf("End\n");
							break;
		case BNRP_var:
							printf("Var @ %08lX\n", r.tval);
							break;
		case BNRP_tailvar:
							printf("Tailvar @ %08lX\n", r.tval);
							break;
		case BNRP_integer:
							printf("Integer %ld\n", r.ival);
							break;
		case BNRP_float:
							printf("Float %lf\n", r.fval);
							break;
		case BNRP_symbol:
							printf("Symbol '%s' @ %08lX\n", r.sym.sval, r.sym.orig);
							break;
		case BNRP_list:
							printf("List: first %08lX\n", r.term.first);
							break;
		case BNRP_structure:
							printf("Structure '%s', first %08lX\n", r.term.functor, r.term.first);
							break;
		}
	}

static BNRP_Boolean BNRP_testlowlevel(BNRP_TCB *tcb)
{
	TAG tag;
	BNRP_result r, r1;
	int i;
	BNRP_term t, t1;
	
	if (tcb->numargs EQ 1) {
		tag = BNRP_getValue(tcb->args[1], &r);
		BNRP_dumplowlevel(tag, r);
		if ((tag EQ BNRP_list) || (tag EQ BNRP_structure)) {
			i = (tag EQ BNRP_structure) ? 0 : 1;
			do {
				tag = BNRP_getIndexedValue(tcb->args[1], i++, &r1);
				BNRP_dumplowlevel(tag, r1);
				} while (tag NE BNRP_invalid);
			printf("last term was %d\n", i-1);
			t = r.term.first;
			i = 0;
			do {
				tag = BNRP_getIndexedValue(t, ++i, &r1);
				BNRP_dumplowlevel(tag, r1);
				} while (tag NE BNRP_invalid);
			printf("last term was %d\n", i-1);
			do {
				tag = BNRP_getNextValue(&t, &r1);
				BNRP_dumplowlevel(tag, r1);
				} while (tag NE BNRP_invalid);
			}
		else if (tag EQ BNRP_var) {
			t = BNRP_startList(tcb);
			BNRP_addTerm(tcb, t, BNRP_makeSymbol(tcb, "hello"));
			BNRP_addTerm(tcb, t, BNRP_makeInteger(tcb, 1));
			BNRP_addTerm(tcb, t, BNRP_makeFloat(tcb, 123.45));
			BNRP_addTerm(tcb, t, BNRP_makeStructure(tcb, "fred", 1, BNRP_makeInteger(tcb, 100)));
			t1 = BNRP_startStructure(tcb, "hello");
			BNRP_addTerm(tcb, t1, BNRP_makeSymbol(tcb, "world"));
			BNRP_addTerm(tcb, t1, BNRP_makeFloat(tcb, 1.0));
			BNRP_addTerm(tcb, t1, BNRP_makeSymbol(tcb, "there"));
			BNRP_addTerm(tcb, t, t1);
			BNRP_addTerm(tcb, t, BNRP_makeList(tcb, 2, BNRP_makeInteger(tcb, 1000), BNRP_makeInteger(tcb, 1001)));
			BNRP_unify(tcb, tcb->args[1], t);
			}
		}
	return(TRUE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_setTrace(TCB *tcb)
{
	BNRP_term pred;
	long l;
	short i;
	TAG tag;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &pred) EQ SYMBOLT)) {
		if ((tag = checkArg(tcb->args[2], &l)) EQ INTT) {
			i = l;
			if (pred EQ tracerAtom) return(FALSE);
			return(BNRP_setDebug(pred, i));
			}
		else if (tag EQ VART) {
			l = BNRP_queryDebug(pred);
			return(unify(tcb, tcb->args[2], makeint(&tcb->hp, l)));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_setTraceAll(TCB *tcb)
{
	long andMask, orMask;
	long result, p, orig, t;
	long LDCount, LDHold, LDk, LDSaveAddr;
	ptr addr;
	TAG tag;
	
	if ((tcb->numargs EQ 3) && 
		(checkArg(tcb->args[1], &andMask) EQ INTT) &&
		(checkArg(tcb->args[2], &orMask) EQ INTT) &&
		(checkArg(tcb->args[3], &result) EQ LISTT)) {
			
			/* set bits on everything except local predicates in base */
			BNRP_setAllDebugBits(andMask, orMask);
			
			/* clear out bits on any predicate in list */
			p = addrof(result);
			LDCount = 1;
			LDHold = 2;
			LDk = 0;
			derefTV(&p, &orig, &tag, &result, &addr);
			while (tag EQ SYMBOLT) {
				if (!BNRP_setDebug(result, 0)) break;
				t = p;
				derefTV(&p, &orig, &tag, &result, &addr);
				if (p LE t) {			/* possible loop */
					if (--LDCount LE 0) {
						if (LDk EQ 0) {
							LDk = LDHold;
							LDHold += LDHold;
							LDSaveAddr = p;
							}
						else {
							--LDk;
							if (LDSaveAddr EQ p) break;
							}
						}
					}
				}
			return(tag EQ ENDT);
			}
	return(FALSE);
	}
#endif

/* flag bits used:														*/
/*		 0 - attention handler											*/
/*		 1 - constraints encountered in core (from primitives in TCB)	*/
/*		 2 - timer tick (currently not used)							*/
/*		16 - debug flag													*/
#ifdef ring0
long BNRPflags = 0;
long BNRPunknown = 0;
#else
extern long BNRPflags, BNRPunknown;
#endif

#ifdef ring5
BNRP_Boolean BNRP_setUnknown(TCB *tcb)
{
	long l;
	TAG tag;
	
	if (tcb->numargs EQ 1) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ INTT) {
			BNRPunknown = l;
			return(TRUE);
			}
		else if (tag EQ VART)
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRPunknown)));
		}
	return(FALSE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_enableTrace(TCB *tcb)
{
	long l;
	TAG tag;
	
	if (tcb->numargs EQ 1) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ INTT) {
			if (l)
				BNRPflags |= 0x10000;
			else
				BNRPflags &= 0xFFFEFFFF;
			return(TRUE);
			}
		else if (tag EQ VART) {
			l = (BNRPflags & 0x10000) ? 1 : 0;
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, l)));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_delay(TCB *tcb)
{
	long l, ignoreTicks;
	TAG tag;
	fp t = 0.0;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[2], &ignoreTicks) EQ INTT)) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ INTT)
			t = (fp)l;
		else if (tag EQ FLOATT)
			t = *(fp *)l;
		if (t GT 0.0) BNRP_sleep(t, ignoreTicks);
		}
	return(TRUE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_inTick = FALSE;
fp BNRP_tickCount = 0.0;

static void handleTick()
{
	if (!BNRP_inTick) {
		BNRPflags |= 0x04;
		BNRP_inTick = TRUE;
		}
	}
	
BNRP_Boolean BNRP_enableTimer(TCB *tcb)
{
	long l;
	TAG tag;
	
	if (tcb->numargs EQ 1) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ INTT) {
			BNRP_tickCount = (l GT 0) ? l : 0.0;
			BNRP_setTimer(&BNRP_tickCount, handleTick);
			BNRP_inTick = FALSE;
			return(TRUE);
			}
		else if (tag EQ FLOATT) {
			BNRP_tickCount = *(fp *)l;
			if (BNRP_tickCount LT 0.0) BNRP_tickCount = 0.0;
			BNRP_setTimer(&BNRP_tickCount, handleTick);
			BNRP_inTick = FALSE;
			return(TRUE);
			}
		else if (tag EQ VART) {
			return(unify(tcb, tcb->args[1], makefloat(&tcb->hp, &BNRP_tickCount)));
			}
		}
	return(FALSE);
	}

BNRP_Boolean BNRP_reEnableTimer(TCB *tcb)
{
#pragma unused(tcb)
	BNRP_inTick = FALSE;
	return(TRUE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_dpprim(TCB *tcb)
{
	long B;
	long result, p, orig, N, J, K;
	ptr addrN, addrJ, addrK;
	TAG tag;
	
	if ((tcb->numargs EQ 3) && (checkArg(tcb->args[1], &B) EQ INTT) && (checkArg(tcb->args[2], &result) EQ LISTT))
		if ((B EQ 0) || (B EQ 1)) {
			/* check each argument in the list to be an short positive integer */
			p = addrof(result);
			derefTV(&p, &orig, &tag, &N, &addrN);
			/* fail if N = 0 as well */
			if ((tag EQ INTT) && (N GT 0) && (N LE MAXSHORT)) {
				trail(tcb->te, addrN);	/* save existing N */
				*addrN = makeintterm(--N);
				derefTV(&p, &orig, &tag, &J, &addrJ);
				if ((tag EQ INTT) && (J GE 0) && (J LE MAXSHORT)) {
					derefTV(&p, &orig, &tag, &K, &addrK);
					if ((tag EQ INTT) && (K GE 0) && (K LE MAXSHORT)) {
						if (B EQ 0) {
							if (J EQ 0) return(FALSE);
							trail(tcb->te, addrJ);	/* save existing J */
							*addrJ = makeintterm(--J);
							if ((J EQ 0) && (K EQ N) && (N GT 0))
								return(unify(tcb, tcb->args[3], makeintterm(1)));
							}
						else {
							if (K EQ 0) return(FALSE);
							trail(tcb->te, addrK);	/* save existing K */
							*addrK = makeintterm(--K);
							if ((K EQ 0) && (J EQ N) && (N GT 0))
								return(unify(tcb, tcb->args[3], makeintterm(0)));
							}
						return(N GE (J + K));
						}
					}
				}
			}
	return(FALSE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_finite(TCB *tcb)
{
   long l;
   TAG tag;  
   if(tcb->numargs NE 1) return(FALSE);
   
   if((tag = checkArg(tcb->args[1], &l)) EQ INTT) return(TRUE);
   
   if(tag EQ FLOATT)
   {
#ifdef AIX
      fp* x = *(fp **) l;
      if (finite(x)) return(TRUE);
#else
      if(finite(*(fp *)l)) return(TRUE); 
#endif
    }      
   return(FALSE);
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_examinefp(TCB *tcb)
{
	long l;
	
	if (tcb->numargs EQ 2) 
		if (checkArg(tcb->args[1], &l) EQ FLOATT) {
			char buff[20];
			sprintf(buff, "%08lx%08lx", *(long *)l, *(long *)(l + sizeof(long)));
			return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, buff, TEMPSYM, GLOBAL)));
			}
		else if (checkArg(tcb->args[2], &l) EQ SYMBOLT) {
			char *name = nameof(l);
			fp f;
			long *p = (long *)&f;
			if (strlen(name) NE 16) return(FALSE);
			if (sscanf(name, "%8lx%8lx", &p[0], &p[1]) NE 2) return(FALSE);
			return(unify(tcb, tcb->args[1], makefloat(&tcb->hp, &f)));
			}
	return(FALSE);
	}
#endif

#ifdef ring5
long BNRP_MaxOperations = 10000,
	 BNRP_IntervalIncrement = 8,
	 BNRP_IntervalDecrement = 1;

BNRP_Boolean BNRP_setintervalconstraints(TCB *tcb)
{
	TAG tag;
	long l1, l2, l3;
	
	if (tcb->numargs NE 3) return(FALSE);
	if ((tag = checkArg(tcb->args[1], &l1)) EQ VART) {
		if (!unify(tcb, tcb->args[1], makeint(&tcb->hp, l1 = BNRP_MaxOperations)))
			return(FALSE);
		}
	else if (tag NE INTT)
		return(FALSE);
	if ((tag = checkArg(tcb->args[2], &l2)) EQ VART) {
		if (!unify(tcb, tcb->args[2], makeint(&tcb->hp, l2 = BNRP_IntervalIncrement)))
			return(FALSE);
		}
	else if (tag NE INTT)
		return(FALSE);
	if ((tag = checkArg(tcb->args[3], &l3)) EQ VART) {
		if (!unify(tcb, tcb->args[3], makeint(&tcb->hp, l3 = BNRP_IntervalDecrement)))
			return(FALSE);
		}
	else if (tag NE INTT)
		return(FALSE);
	BNRP_MaxOperations = l1;
	BNRP_IntervalIncrement = l2;
	BNRP_IntervalDecrement = l3;
	return(TRUE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_replaceFloat(TCB *tcb)
{
	long f1, f2;
	
	if ((tcb->numargs EQ 2) &&
		(checkArg(tcb->args[1], &f1) EQ FLOATT) &&
		(checkArg(tcb->args[2], &f2) EQ FLOATT)) {
			*(fp *)f1 = *(fp *)f2;
			return(TRUE);
			}
	return(FALSE);
	}
#endif
	
#ifdef ring0
void BNRP_initializeGlobals()
{
	fp t;
	int i;
/****	Removed by Oz 04/95       */
/*	signal(SIGINT, abortHandler); */
/*	signal(SIGFPE, arithHandler); */
/****                             */
	BNRP_initMemory();
	BNRP_initializeParser();

    /* 
     * yanzhou@bnr.ca: Jun 17 1996
     *   make the empty string "" a permanent symbol
     */
    BNRPLookupPermSymbol("");
	curlyAtom = BNRPLookupPermSymbol("{}");
	commaAtom = BNRPLookupPermSymbol(",");
	cutAtom = BNRPLookupPermSymbol("!");
	cutcutAtom = BNRPLookupPermSymbol("cut");
	cutFailAtom = BNRPLookupPermSymbol("failexit");
	recoveryUnitAtom = BNRPLookupPermSymbol("recovery_unit");
	isAtom = BNRPLookupPermSymbol("is");
	plusAtom = BNRPLookupPermSymbol("+");
	minusAtom = BNRPLookupPermSymbol("-");
	starAtom = BNRPLookupPermSymbol("*");
	slashAtom = BNRPLookupPermSymbol("/");
	slashslashAtom = BNRPLookupPermSymbol("//");
	modAtom = BNRPLookupPermSymbol("mod");
	starstarAtom = BNRPLookupPermSymbol("**");
	intAtom = BNRPLookupPermSymbol("integer");
	floatAtom = BNRPLookupPermSymbol("float");
	floorAtom = BNRPLookupPermSymbol("floor");
	ceilAtom = BNRPLookupPermSymbol("ceiling");
	roundAtom = BNRPLookupPermSymbol("round");
	maxAtom = BNRPLookupPermSymbol("max");
	minAtom = BNRPLookupPermSymbol("min");
	sqrtAtom = BNRPLookupPermSymbol("sqrt");
	absAtom = BNRPLookupPermSymbol("abs");
	expAtom = BNRPLookupPermSymbol("exp");
	lnAtom = BNRPLookupPermSymbol("ln");
	sinAtom = BNRPLookupPermSymbol("sin");
	cosAtom = BNRPLookupPermSymbol("cos");
	tanAtom = BNRPLookupPermSymbol("tan");
	asinAtom = BNRPLookupPermSymbol("asin");
	acosAtom = BNRPLookupPermSymbol("acos");
	atanAtom = BNRPLookupPermSymbol("atan");
	maxintAtom = BNRPLookupPermSymbol("maxint");
	maxfloatAtom = BNRPLookupPermSymbol("maxreal");
	piAtom = BNRPLookupPermSymbol("pi");
	cputimeAtom = BNRPLookupPermSymbol("cputime");
	butnotAtom = BNRPLookupPermSymbol("butnot");
	bitshiftAtom = BNRPLookupPermSymbol("bitshift");
	bitandAtom = BNRPLookupPermSymbol("bitand");
	bitorAtom = BNRPLookupPermSymbol("bitor");
	biteqAtom = BNRPLookupPermSymbol("biteq");
	boolnotAtom = BNRPLookupPermSymbol("~");
	boolandAtom = BNRPLookupPermSymbol("and");
	boolorAtom  = BNRPLookupPermSymbol("or");
	boolxorAtom = BNRPLookupPermSymbol("xor");
	eqAtom = BNRPLookupPermSymbol("==");
	neAtom = BNRPLookupPermSymbol("<>");
	ltAtom = BNRPLookupPermSymbol("<");
	gtAtom = BNRPLookupPermSymbol(">");
	geAtom = BNRPLookupPermSymbol(">=");
	leAtom = BNRPLookupPermSymbol("=<");
	clauseAtom = BNRPLookupPermSymbol("clause$$");
	execAtom = BNRPLookupPermSymbol("$$exec");
	failAtom = BNRPLookupPermSymbol("fail");
	varAtom = BNRPLookupPermSymbol("var");
	tailvarAtom = BNRPLookupPermSymbol("tailvar");
	BNRP_filterNames[0] = BNRPLookupPermSymbol("unknownfilter");
	for (i = 1; i LT 32; ++i) BNRP_filterNames[i] = BNRP_filterNames[0];
	BNRP_filterNames[0x01] = BNRPLookupPermSymbol("list");
	BNRP_filterNames[0x1E] = BNRPLookupPermSymbol("nonlist");
	BNRP_filterNames[0x02] = BNRPLookupPermSymbol("structure");
	BNRP_filterNames[0x1D] = BNRPLookupPermSymbol("nonstructure");
	BNRP_filterNames[0x03] = BNRPLookupPermSymbol("compound");
	BNRP_filterNames[0x1C] = BNRPLookupPermSymbol("noncompound");
	BNRP_filterNames[0x04] = BNRPLookupPermSymbol("symbol");
	BNRP_filterNames[0x1B] = BNRPLookupPermSymbol("nonsymbol");
	BNRP_filterNames[0x08] = intAtom;
	BNRP_filterNames[0x17] = BNRPLookupPermSymbol("noninteger");
	BNRP_filterNames[0x10] = floatAtom;
	BNRP_filterNames[0x0F] = BNRPLookupPermSymbol("nonfloat");
	BNRP_filterNames[0x18] = BNRPLookupPermSymbol("numeric");
	BNRP_filterNames[0x07] = BNRPLookupPermSymbol("nonnumeric");
	BNRP_filterNames[0x1F] = BNRPLookupPermSymbol("nonvar");
	numberAtom = BNRPLookupPermSymbol("number");
	nonNumberAtom = BNRPLookupPermSymbol("nonnumber");
	attentionAtom = BNRPLookupPermSymbol("attention_handler");
	unificationAtom = BNRPLookupPermSymbol("=");
	ifAtom = BNRPLookupPermSymbol("->");
	orAtom = BNRPLookupPermSymbol(";");
	indirectAtom = BNRPLookupPermSymbol("$$callindirect");
	indirectListAtom = BNRPLookupPermSymbol("$$calllistindirect");
	eofAtom = BNRPLookupPermSymbol("end_of_file");
	tracerAtom = BNRPLookupPermSymbol("tracer");
	tickAtom = BNRPLookupPermSymbol("$tick");
	ssAtom = BNRPLookupPermSymbol("$ss");
	intervalAtom = BNRPLookupPermSymbol("$interval");
	integralAtom = BNRPLookupPermSymbol("$integral");
	booleanAtom = BNRPLookupPermSymbol("$boolean");
	noopnodeAtom = BNRPLookupPermSymbol("$noopnode");
	evalConstrainedAtom = BNRPLookupPermSymbol("$evalconstrained");
	BNRP_combineVarAtom = BNRPLookupPermSymbol("$combinevar");
	
	counterAtom = BNRPLookupPermSymbol("$counter");
	BNRPmarkAtom = BNRPLookupPermSymbol("BNRP_mark");
	BNRP_defaultTaskName = BNRPLookupPermSymbol("BNRP_defaultTaskName");
	BNRP_taskswitch_primitive = BNRPLookupPermSymbol("$task_switch");
	
#ifdef testinterface
	BNRPBindPrimitive("test", testlowlevel);
#endif

	BNRP_initStats();
	BNRP_statStartTime = BNRP_getUserTime(TRUE, &t);
	BNRP_statElapsedTime = BNRP_getElapsedTime();
	}
#endif
