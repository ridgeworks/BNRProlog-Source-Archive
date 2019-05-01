/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/core.c,v 1.13 1997/12/24 09:43:05 harrisj Exp $
 *
 * $Log: core.c,v $
 * Revision 1.13  1997/12/24  09:43:05  harrisj
 * Fixes for HSC integration
 *
 * Revision 1.12  1997/12/22  17:00:55  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.11  1997/04/01  13:45:36  harrisj
 * BNRP_RESUME() body escape bytes 0xE6 and 0x02 modified
 * to read the call arity in as a signed char when doing
 * garbage collection.
 *
 * BNRP_gc_proceed() modified to use the absolute value of args[0].
 *
 * Revision 1.10  1997/03/24  00:33:09  jonesb
 * Corrected case where headCount[1] was incremented
 * instead of headCount[0]
 *
 * Revision 1.9  1997/03/21  00:35:52  jonesb
 * Moved headCount increment statement into a
 * #ifdef DEBUG wrapper. Also placed two instances
 * of the increment in the relevant switch
 * construct in a #ifndef DEBUG wrapper
 *
 * Revision 1.8  1996/02/13  11:13:51  yanzhou
 * On HP-UX 9.0,  x << y == x << (y mod 32).  It is now fixed so that x << y == 0 if (y >= 32).
 *
 * Revision 1.7  1996/02/09  02:19:38  yanzhou
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
 * Revision 1.6  1996/02/06  04:38:31  yanzhou
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
 * Revision 1.5  1996/02/05  06:55:11  yanzhou
 * Permanent variables are now initialized on the heap as well.
 *
 * BNRProlog V4 inherited from the WAM practice of initializing new
 * permanent variables as self-referential pointers on the environment
 * stack.  It was a BAD IDEA, because every place one chases a var
 * chain has to deal with it, hence the unsafe op-codes like unif_unsaf,
 * push_unsaf and putunsaf are needed.  Life is much simpler without it.
 *
 * Changes made to stop allocating permanent variables on the env stack
 * are:
 *
 *   1) in core.c, put_varp is changed from:
 *         put_varp(P,A) :- temp[A] <- ce[P] <- (var | address(ce[P]))
 *      to:
 *         put_varp(P,A) :- temp[A] <- ce[P] <- (var | hp <= hp)
 *
 *   2) in cmp_clause.p, when a new $var structure is constructed by
 *      $var_constructor, it now has "very_safe" as its default safety
 *      value, which  stops compile_clause/3 from generating any
 *      unsafe op-codes (eg., push_unsafp, putunsaf, etc.)
 *
 * Revision 1.4  1996/02/01  03:29:44  yanzhou
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
 * Revision 1.3  1995/12/12  14:21:37  yanzhou
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
 * Revision 1.2  1995/12/04  00:03:27  yanzhou
 * In corebindVV() and BNRP_freeze(), unnecessary makevarterm()'s are removed,
 * which fixes the bug where [freeze(A, A is 1), freeze(B, B is 1), A=B] would
 * fail on hpux9 and cause run-time `dangling reference' error on ibm-aix4.1.
 *
 * Revision 1.1  1995/09/22  11:23:41  harrisja
 * Initial version.
 *
 *
 */
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <setjmp.h>
#include <math.h>
#include <errno.h>
#include <signal.h>
#include <stdarg.h>
#include "base.h"
#include "core.h"
#include "context.h"
#include "prim.h"
#include "ioprim.h"
#include "pushpop.h"
#include "hardware.h"
#include "stats.h"
#include "state.h"
#include "interpreter.h"
#include "tasking.h"
#include "utility.h"

#ifdef __mpw					/* MPW only */
#define DEBUGSTR(s)		DebugStr("\p" s)
#else
#define DEBUGSTR(s)		*(long *)NULL
#endif

/* select gc_cut to garbage collections on cuts */
/* select gc_proceed to do garbage collection on proceeds and cutexec calls */
/* select neither for no garbage collection */
/* #define gc_cut */
#define gc_proceed

/* select cp_full to do complete search for next possible clause before */
/* creating a choicepoint, otherwise it will use nextSameKeyClause and  */
/* check when using the choicepoint to see if the clause really matches */
/* #define cp_full /* */

/* #define executiontrace /* */
/* #define executioncodetrace */
/* #define calldebug */
/* #define debug */
/* #define cutdebug */
/* #define arithdebug */
/* #define checkalignment */
/* #define check					/* extra checks for unexpected items */
/* #define profile					/* if profiling the core */ 

#ifdef DEBUG
#define cutordebug
#define callordebug
#endif
#ifdef cutdebug
#define cutordebug
#endif
#ifdef calldebug
#define callordebug
#endif
#ifdef executioncodetrace
#ifndef executiontrace
#define executiontrace
#endif
#endif

/* #define MAX_ARITH	8	Define moved to core.h	*/

/*******************************************************************************
%                                     Head
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    | * | * . * . * . * . * . * . * | 2 |   .  get_cons .   .   .   |
%      1    | 3 | 2 get_struc(short). 2 . 2 | 2 |   .   .   .   .   .   .   |
%      2    | 2 |   get_list.   .   .   .   | 2 |   .  get_nil  .   .   .   |
%      3   _| 3 | 2 get_valt  2 . 2 . 2 . 2 | 3 | 2 .  get_valp . 2 . 2 . 2 |
%      4    | 2 |   unify_vart  .   .   .   | 2 |   .  unify_varp   .   .   |
%      5    | 2 |   unify_valt  .   .   .   | 2 |   .  unify_valp   .   .   |
%  n   6    | 2 |   tunify_vart .   .   .   | 2 |   .  tunify_varp  .   .   |
%  i   7   _| 2 |   tunify_valt .   .   .   | 2 |   .  tunify_valp  .   .   |
%  b   8    | 3 | 2 . 2 . 2 . 2 . 2 . 2 . 2 | 3 | 2 . 2 . 2 . 2 . 2 . 2 . 2 |
%  b   9    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%  l   A    | 2 |   . xx.   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%  e   B   _| 2 |   .   . yy.   .   .   .   | 2 |   .   .   .   .   .   .   |
%  1   C    | 2 |   .   .   . zz.   .   .   | 2 |   .   .get_varp   .   .   |
%      D    | 2 |   .   get_vart. aa.   .   | 2 |   .   .   .   .   .   .   |
%      E    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%      F   _| 2 |   .   .   .   .   .   .nop| 2 |   .   .   .   .   .   .   |
%
%        xx - unif_address
%        yy - get_cons_by_value
%        zz - unif_cons_by_value
%		 aa - copy_valp            (copy perm to temp, used by state space)
%
%      Corresponding table for body codes is  similar 
%      if  put is substituted for get, push for unify, tpush for tunify,
%       except  -get_val become put_vars and vice-versa
%
%                                     Body
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    | * | * . * . * . * . * . * . * | 2 |   .  put_cons .   .   .   |
%      1    | 2 |   put_struc   .   .   .   | 2 |   .   .   .   .   .   .   |
%      2    | 2 |   put_list.   .   .   .   | 2 |   .  put_nil  .   .   .   |
%      3   _| 2 |   put_void    .   .   .   | 3 | 2 .  put_varp . 2 . 2 . 2 |
%      4    | 2 |   push_vart   .   .   .   | 2 |   .  push_varp    .   .   |
%      5    | 2 |   push_valt   .   .   .   | 2 |   .  push_valp    .   .   |
%  n   6    | 2 |   tpush_vart  .   .   .   | 2 |   .  tpush_varp   .   .   |
%  i   7   _| 2 |   tpush _valt .   .   .   | 2 |   .  tpush_valp   .   .   |
%  b   8    | 3 | 2 . 2 . 2 . 2 . 2 . 2 . 2 | 3 | 2 . 2 . 2 . 2 . 2 . 2 . 2 |
%  b   9    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%  l   A    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%  e   B   _| 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%  1   C    | 2 |   .   put_valt.   .   .   | 2 |   .   .put_valp   .   .   |
%      D    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%      E    | 2 |   .   .   .   .   .   .   | 2 |   .   .   .   .   .   .   |
%      F   _| 2 |   .   .   .   .   .   .nop| 2 |   .   .   .   .   .   .   |
%
%                                     Body Escapes
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    | * | * . * . * . * . * . * . * | * | * . * . * . * . * . * . * |
%      1    | 2 |   .   vart    .   .   .   | 2 |   .  varp     .   .   .   |
%      2    | 2 |   .   tvart   .   .   .   | 2 |   .  tvarp    .   .   .   |
%      3   _| * |       cut/failexit    .** | 3 |   .   .   .   .   .   .   |
%      4    | 2 |   .   testt   .   .   .   | 2 |   .  testp    .   .   .   |
%      5    | 2 |   .   popvalt .   .   .   | 2 |   .  popvalp  .   .   .   |
%  n   6    | 2 |   .   evalt   .   .   .   | 2 |   .  evalp    .   .   .   |
%  i   7   _| 2 |   .   popvart .   .   .   | 2 |   .  popvarp  .   .   .   |
%  b   8    | 3 | 2 . 2 . 2 . 2 . 2 . 2 . 2 | 2 |   .   .   .   .   .   .   |
%  b   9    | 2 |   .   .   .   .   .   .   |cut| + . - . * . //. / .mod. **|
%  l   A    | 2 |   .   .   .   .   .   .   |   |int.flt.flr.cei.rnd.max.min|
%  e   B   _| 2 |   .   .   .   .   .   .   |   |sqt.abs.exp. ln. ++. --.neg|
%  1   C    | 2 |   .   put_vart.   .   .   |   |sin.cos.tan.asn.acs.atn. bn|
%      D    | 2 |   .   .   .   .   .   .   |   | ==. =<. >=. < . > . <>. bs|
%      E    | 2 |   .   .   .   .   .   .   |   |mxi.mxr. pi.cpu. ba. bo. be|
%      F   _| 2 |   .   .   .   .   .   .nop|   |   .   .   .   .   .   .   |
%
%			** - label_env
%           bn - butnot
%           bs - bitshift
%           ba - bitand
%           bo - bitor
%           be - biteq
%
%      The first rows in more detail are:
%
%                       head                 body               body escapes
%       00      |   neck              |  proceed            |  break
%       01      |   unif_void         |  push_void          |  ecut
%       02      |   tunif_void        |  tpush_void         |  dcut
%       03      |   end_seq           |  push_end           |  push_nil
%       04      |   unif_cons(C)      |  push_cons(C)       |  eval_cons(C)
%       05      |   neckcons          |  noop               |  dealloc
%       06      |   alloc             |  dealloc            |
%       07      |   unify_nil         |  escape             |
%       08      |	get_cons		  |  put_cons			|
%       09      |	get_cons		  |  put_cons			|  call indirect
%       0A      |	get_cons		  |  put_cons			|  call
%       0B      |	get_cons		  |  put_cons			|  exec indirect
%       0C      |	get_cons		  |  put_cons			|  exec
%       0D      |	get_cons		  |  put_cons			|  call clause$$/1
%       0E      |	get_cons		  |  put_cons			|  exec $$exec/2
%       0F      |	get_cons		  |  put_cons			|  fail
%
********************************************************************************/

#define NOOP		0xF7

long ppc;						/* program counter */
long ce;						/* current environment */
long envbase;					/* needed for seeing which stack a value is on */
long cp;						/* continuation pointer */
long hp;						/* pointer to top of heap */
long heapbase;
long stp;						/* scratch structure pointer */
long te;
choicepoint *cutb;				/* cut point choicepoint */
choicepoint *lcp;				/* last choicepoint */
long criticalenv, criticalhp;	/* critical address for trailing */
long emptyList;
long *regs;
long specialError;
long BNRPconstraintHeader, BNRPconstraintEnd;
extern li BNRPflags;
extern int BNRP_SwitchedTask;
struct arith {
	lf value;
	long type;
	} ar[MAX_ARITH];

jmp_buf jumpbuf;

#define ERROR(err)						longjmp(jumpbuf, err)
#define ERROREXIT						-9876
#define QUIT							-9877

#define trail(te, addr)					rpush(long, te, *(long *)addr); \
										rpush(long, te, (long)addr); \
										if (te LE trailend) { ERROR(TRAILOVERFLOW); }

#define untrail(te, addr)				rpop(long, te, addr); \
										rpop(long, te, *(long *)addr)

#define e(P)							env(ce, P)

#define bind(val, newval)				{ \
										long _addr = addrof(val); \
										if (_addr GE envbase) { \
                                            printf("TRAP: Prolog term 0x%08x is on the environment stack.\n", val);\
											/* address in environment */ \
											if (_addr LE criticalenv) { \
												trail(te, _addr); \
												} \
											} \
										else { \
											/* address in heap */ \
											if (_addr LE criticalhp) { \
												trail(te, _addr); \
												} \
											} \
										*(long *)_addr = (long)newval; \
										}
										
#define heapcheck(n)					if ((heapend - hp) LE (n * sizeof(long))) { \
											ERROR(HEAPOVERFLOW); \
											}

/****
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
****/

/* #define TRACE		/* define to keep a log of activity */
#ifdef TRACE
#define TRACESIZE	2000
char BNRP_trace[TRACESIZE];

static void traceit(char *format, ...)
{
	va_list ap;
	char buff[100];
	int l;
	
	va_start(ap, format);
	vsprintf(buff, format, ap);
	if ((l = strlen(BNRP_trace)) GT TRACESIZE-100) {
		(void)strcpy(&BNRP_trace[0], &BNRP_trace[100]);
		}
	(void)strcat(BNRP_trace, buff);
	}
#endif

extern void (*BNRPerrorhandler)();

void BNRP_error(long err)
{
	if (BNRPerrorhandler NE NULL) (*BNRPerrorhandler)(err);
	specialError = err;					/* save for call back into RESUME */
	longjmp(jumpbuf, ERROREXIT);		/* jump back into interpreter */
	}
	
BNRP_Boolean BNRP_quit(TCB *tcb)
{
	if (tcb->numargs EQ 0)
		longjmp(jumpbuf, QUIT);			/* jump back into interpreter */
	return(FALSE);
	}
	
static void resetCritical(TCB *tcb)
{
	register long *readte, *newte, finalte, addr, val;
	
	if ((long)lcp EQ tcb->cpbase) {
		criticalenv = envbase;
		criticalhp = heapbase;
		newte = readte = (long *)tcb->trailbase;
		}
	else {
		criticalenv = lcp->critical;
		criticalhp = lcp->hp;
		newte = readte = (long *)lcp->te;
		}
	finalte = te;
	/* first loop, just scan until we hit something */
	/* that needs to be removed from the trail      */
	while ((long)readte GT finalte) {
		val = *--readte;
		addr = *--readte;
		if (addr GE envbase) {
			if ((addr GE criticalenv) && (addr LT (long)lcp)) break;
			}
		else {
			if (addr GE criticalhp) break;
			/* check in case item trailed twice (intervals) */
			if (tagof(val) EQ STRUCTTAG) {
				long _l = addrof(val);
				if ((_l GE criticalhp) && (_l LT envbase)) {
#ifdef check
	printf("Skipping item on trail (%08lx) with old value (%08lx) GT critical2 (%08lx)\n", 
			addr, val, criticalhp);
#endif
					break;
					}
				}
			}
		newte = readte;
		}
	/* second loop, skipped our first thing on the trail, now */
	/* we have to put back anything that needs to be kept     */
	while ((long)readte GT finalte) {
		val = *--readte;
		addr = *--readte;
		if (addr GE envbase) {
			if ((addr GE criticalenv) && (addr LT (long)lcp)) continue;
			}
		else {
			if (addr GE criticalhp) continue;
			/* check in case item trailed twice (intervals) */
			if (tagof(val) EQ STRUCTTAG) {
				long _l = addrof(val);
				if ((_l GE criticalhp) && (_l LT envbase)) {
#ifdef check
	printf("Skipping item on trail (%08lx) with old value (%08lx) GT critical2 (%08lx)\n", 
			addr, val, criticalhp);
#endif
					continue;
					}
				}
			}
		*--newte = val;
		*--newte = addr;
		}
	te = (long)newte;
	}


static void corebind(long val, long newval)
{
	long *addr;
	
	bind(val, newval);
	addr = (long *)addrof(val);
	if (addr[1] EQ CONSTRAINTMARK) {
		heapcheck(2);
		if (BNRPconstraintHeader EQ 0)
			BNRPconstraintHeader = maketerm(LISTTAG, hp);
		else
			*(long *)BNRPconstraintEnd = maketerm(TVTAG, hp);
		push(long, hp, addr[2]);				/* push constraint onto heap */
		BNRPconstraintEnd = hp;
		push(long, hp, 0);						/* end of list */
		BNRPflags.l |= 0x02;
		}
	}

/* Special case when we are binding to the end of the heap */
/* Problem #1:  the tail variable might be at the end of the */
/*				heap so we can just back up hp after trailing, */
/*				if necessary. */
/* Problem #2:  the binding might fire a constraint, which also */
/*				wants to use the heap.  Thus we need to defer the */
/*				binding to hp until after the constraint has fired. */
static long corebindtohp(long val, long tags)
{
	long *p;
	
	p = (long *)addrof(val);
	if (p[1] EQ CONSTRAINTMARK) {			/* constrained variable ?? */
		heapcheck(3);						/* make sure we have enough room */
		if (BNRPconstraintHeader EQ 0)		/* new list of constraints ?? */
			BNRPconstraintHeader = maketerm(LISTTAG, hp);
		else								/* append to existing list */
			*(long *)BNRPconstraintEnd = maketerm(TVTAG, hp);
		push(long, hp, p[2]);				/* push constraint onto heap */
		BNRPconstraintEnd = hp;
		push(long, hp, 0);					/* end of list */
		BNRPflags.l |= 0x02;				/* indicate constraint fired */
		}
	else {
		heapcheck(1);						/* something will be put on heap eventually */
		}
	/* is our TV at the end of the heap ?? */
	/* don't do it across critical to avoid garbage collection problems (91/10/21) */
	if (((long)p EQ hp - sizeof(long)) && (tags EQ TVTAG) && ((long)p GT criticalhp)) {
		/* no longer need to trail it */
		hp -= sizeof(long);					/* and just back up the heap pointer */
		}
	else {									/* no, so bind the TV to the current */
		bind(val, maketerm(tags, hp));		/* end of the heap */
		}
	return(*p);
	}

static void corebindVV(long var1, long var2)
{
	long val, newval, *a1, *a2;
	
	if (var1 EQ var2) return;
	a1 = (long *)addrof(var1);
	a2 = (long *)addrof(var2);
	if (a1[1] EQ CONSTRAINTMARK) {
		if (a2[1] EQ CONSTRAINTMARK) {		/* both variables constrained */
/************** try escaping to Prolog to combine
			long newcons, newvar;

			heapcheck(6);
			if (a2 GT a1) {
				// a2 newer variable, reverse them
				newcons = (long)a1;
				a1 = a2;
				a2 = (long *)newcons;
				}
			newcons = maketerm(LISTTAG, hp);
			if (tagof(a2[2]) EQ LISTTAG) {
				push(long, hp, a1[2]);
				push(long, hp, maketerm(TVTAG, addrof(a2[2])));
				}
			else if (tagof(a1[2]) EQ LISTTAG) {
				push(long, hp, a2[2]);
				push(long, hp, maketerm(TVTAG, addrof(a1[2])));
				}
			else {
				push(long, hp, a1[2]);
				push(long, hp, a2[2]);
				push(long, hp, 0);
				}
			newvar = makevarterm(hp);
			push(long, hp, newvar);
			push(long, hp, CONSTRAINTMARK);
			push(long, hp, newcons);
			bind(var1, newvar);				// binds first var to new var
			val = var2;						// setup so second var binds to new var
			newval = newvar;
******/
			BNRP_term g;
			
			heapcheck(10);
			g = maketerm(STRUCTTAG, hp);
			push(long, hp, FUNCID | 5);
			push(long, hp, BNRP_combineVarAtom);
			push(long, hp, a1[0]);              /* a1[0] is a variable term */
			push(long, hp, a1[2]);
			push(long, hp, a2[0]);              /* a2[0] is a variable term */
			push(long, hp, a2[2]);
			push(long, hp, 0);
			
			if (BNRPconstraintHeader EQ 0)		/* new list of constraints ?? */
				BNRPconstraintHeader = maketerm(LISTTAG, hp);
			else								/* append to existing list */
				*(long *)BNRPconstraintEnd = maketerm(TVTAG, hp);
			push(long, hp, g);					/* push constraint onto heap */
			BNRPconstraintEnd = hp;
			push(long, hp, 0);					/* end of list */
			BNRPflags.l |= 0x02;				/* indicate constraint fired */
			return;
			}
		else {								/* only var1 constrained */
			val = var2;
			newval = var1;
			}
		}
	else if (a2[1] EQ CONSTRAINTMARK) {		/* only var2 constrained */
		val = var1;
		newval = var2;
		}
	else {									/* neither TV constrained */
		if (var1 LT var2) {
			val = var2;
			newval = var1;
			}
		else {
			val = var1;
			newval = var2;
			}
		}
	bind(val, newval);
	}

static void corebindTVTV(long var1, long var2)
{
	long val, newval, *a1, *a2, newcons, newvar;
	
	if (var1 EQ var2) return;
	a1 = (long *)addrof(var1);
	a2 = (long *)addrof(var2);
	if (a1[1] EQ CONSTRAINTMARK) {
		if (a2[1] EQ CONSTRAINTMARK) {		/* both variables constrained */
			heapcheck(6);
			if (a2 GT a1) {
				/* a2 newer variable, reverse them */
				newcons = (long)a1;
				a1 = a2;
				a2 = (long *)newcons;
				}
			newcons = maketerm(LISTTAG, hp);
			if (tagof(a2[2]) EQ LISTTAG) {
				push(long, hp, a1[2]);
				push(long, hp, maketerm(TVTAG, addrof(a2[2])));
				}
			else if (tagof(a1[2]) EQ LISTTAG) {
				push(long, hp, a2[2]);
				push(long, hp, maketerm(TVTAG, addrof(a1[2])));
				}
			else {
				push(long, hp, a1[2]);
				push(long, hp, a2[2]);
				push(long, hp, 0);
				}
			newvar = maketerm(TVTAG, hp);
			push(long, hp, newvar);
			push(long, hp, CONSTRAINTMARK);
			push(long, hp, newcons);
			bind((long)a1, newvar);			/* binds second var to new var */
			val = (long)a2;
			newval = newvar;				/* setup newval so first var binds to new var */
			}
		else {								/* only var1 constrained */
			val = (long)a2;
			newval = var1;
			}
		}
	else if (a2[1] EQ CONSTRAINTMARK) {		/* only var2 constrained */
		val = (long)a1;
		newval = var2;
		}
	else {									/* neither TV constrained */
		if ((long)a1 LT (long)a2) {
			val = (long)a2;
			newval = var1;
			}
		else {
			val = (long)a1;
			newval = var2;
			}
		}
	bind(val, newval);
	}


static BNRP_Boolean coreUnifyList(long list1, long list2)
/* when called, list1 and list2 point to the first element of the lists */
{
	long addr1, addr2, dataaddr1, dataaddr2, l, val1, val2, a, *a1, *a2;
	long LDCount, LDHold, LDk, LDSaveAddr1, LDSaveAddr2;
	
	clearAM();
	pushAM(list1, list2, 0L);
	LDCount = 1;
	LDHold = 2;
	LDk = 0;
	while (pullAM(&addr1, &addr2, &l)) {
		if (addr1 EQ addr2) goto done;		/* don't chase if the same thing */
		LDCount = 1;
		LDHold = 2;
		LDk = 0;
loop:
		dataaddr1 = addr1;
		get(long, addr1, val1);
		while (tagof(val1) EQ TVTAG) {
			l = addrof(val1);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val1) goto tailvar1;
			if (l LT addr1) {				/* loop backwards */
				if (--LDCount LE 0) {
					if (LDk EQ 0) {
						LDk = LDHold;
						LDHold += LDHold;
						LDSaveAddr1 = l;
						LDSaveAddr2 = addr2;
						}
					else {
						--LDk;
						if ((LDSaveAddr1 EQ l) && (LDSaveAddr2 EQ addr2)) {
							/* looped list */
							goto done;
							}
						}
					}
				}
			addr1 = dataaddr1 = l;
			get(long, addr1, val1);
			}
		/* now know that val1 is not a tailvariable */
		dataaddr2 = addr2;
		get(long, addr2, val2);
		while (tagof(val2) EQ TVTAG) {
			l = addrof(val2);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val2) goto tailvar2;
			addr2 = dataaddr2 = l;
			get(long, addr2, val2);
			}
		/* now know that val1, val2 are not tailvariables */
		/* see if val1 is a variable */
		while (isVAR(val1)) {
			register long l = derefVAR(val1);
			if (val1 EQ l) goto var1;
			val1 = l;
			}
		/* now know that val1 is a simple type, check val2 */
		while (isVAR(val2)) {
			register long l = derefVAR(val2);
			if (val2 EQ l) goto var2;
			val2 = l;
			}
		/* now know that val1 and val2 simple types */
		if ((val1 EQ 0) && (val2 EQ 0)) goto done;		/* end of list */
		if (val1 EQ val2) goto loop;
		if ((l = tagof(val1)) NE tagof(val2)) return(FALSE);
		a1 = (long *)addrof(val1);					/* remove tags to get addresses */
		a2 = (long *)addrof(val2);
		if (l EQ LISTTAG) {
			long temp1, temp2;
			
			temp1 = *a1++;
			temp2 = *a2++;
			while ((temp1 EQ temp2) && (temp1 LT 0)) {
				temp1 = *a1++;
				temp2 = *a2++;
				}
			if ((temp1 NE 0) || (temp2 NE 0)) {
				--a1;
				--a2;
				pushAM((long)a1, (long)a2, 0L);
				}
			}
		else if (l EQ STRUCTTAG) {
			li arity1, arity2;
			
			arity1.l = *a1++;
			arity2.l = *a2++;
			if ((arity1.i.a EQ FUNCIDshort) &&
				(arity2.i.a EQ FUNCIDshort) &&
				((arity1.i.b EQ arity2.i.b) || checkArity(arity1.i.b, arity2.i.b)))
					pushAM((long)a1, (long)a2, 0L);
			else
				if ((arity1.i.a EQ NUMBERIDshort) && (arity1.l EQ arity2.l)) {
					switch (arity1.i.b) {
						case INTIDshort:	comparelong(a1, a2, return(FALSE));
											break;
						case FLOATIDshort:	fpLWA(a1);
											fpLWA(a2);
											comparefp(a1, a2, return(FALSE));
											break;
						}
					}
				else
					return(FALSE);
			}
		else
			return(FALSE);
		goto loop;
	
var1:
		/* val1 is a variable, check val2 */
		while (isVAR(val2)) {
			register long l = derefVAR(val2);
			if (val2 EQ l) {
				corebindVV(val1, val2);
				goto loop;
				}
			val2 = l;
			}
		/* val1 is a variable, val2 otherwise so just bind */
		if (val2 EQ 0) return(FALSE);
		corebind(val1, val2);
		goto loop;		

var2:
		/* val2 is a variable, val1 is simple so just bind */
		if (val1 EQ 0) return(FALSE);
		corebind(val2, val1);
		goto loop;
	
tailvar1:
		/* know that val1 points at tail variable, what about val2 */
		dataaddr2 = addr2;
		get(long, addr2, val2);
		while (tagof(val2) EQ TVTAG) {
			l = addrof(val2);				/* isolate address */
			a = *(long *)l;					/* get what tailvar points at */
			if (a EQ val2) {				/* val2 also a tailvariable */
				corebindTVTV(val1, val2);
				goto done;
				}
			addr2 = dataaddr2 = l;
			get(long, addr2, val2);
			}
		/* val2 not a tailvariable, so bind val1 to point at it */
		val1 = addrof(val1);			/* remove TVTAG */
		corebind(val1, maketerm(TVTAG, dataaddr2));
		goto done;
	
tailvar2:
		/* know that val2 is a tailvariable, val1 not so just bind */
		val2 = addrof(val2);			/* remove TVTAG */
		corebind(val2, maketerm(TVTAG, dataaddr1));

done:	;
		}
	freeAM();
	return(TRUE);
	}
	
	
static BNRP_Boolean coreUnify(long t1, long t2)
{
	long val1;
	
	if (t1 EQ t2) return(TRUE);
	
	while (isVAR(t1)) {
		register long val = derefVAR(t1);
		if (t1 EQ val) goto var1;
		t1 = val;
		}
	/* t1 is a nonvar */
	while (isVAR(t2)) {
		register long val = derefVAR(t2);
		if (t2 EQ val) goto var2;
		t2 = val;
		}
	/* t1, t2 are nonvars */
	if (t1 EQ t2) return(TRUE);
	if ((val1 = tagof(t1)) EQ tagof(t2)) {
		if (val1 EQ LISTTAG)
			return(coreUnifyList(addrof(t1), addrof(t2)));
		else if (val1 EQ STRUCTTAG) {
			register long *a1, *a2;
			li arity1, arity2;
			
			a1 = (long *)addrof(t1);			/* remove tags to get addresses */
			a2 = (long *)addrof(t2);
			arity1.l = *a1++;
			arity2.l = *a2++;
			if ((arity1.i.a EQ FUNCIDshort) &&
				(arity2.i.a EQ FUNCIDshort) &&
				((arity1.i.b EQ arity2.i.b) || checkArity(arity1.i.b, arity2.i.b)))
					return(coreUnifyList((long)a1, (long)a2));
			else
				if ((arity1.i.a EQ NUMBERIDshort) && (arity1.l EQ arity2.l)) {
					switch (arity1.i.b) {
						case INTIDshort:	comparelong(a1, a2, return(FALSE));
											break;
						case FLOATIDshort:	fpLWA(a1);
											fpLWA(a2);
											comparefp(a1, a2, return(FALSE));
											break;
						}
					return(TRUE);
					}
			}
		}	
	return(FALSE);
	
var2:
	/* t1 is a nonvar, t2 is a var */
	if (t1 EQ 0) return(FALSE);
	corebind(t2, t1);
	return(TRUE);
	
var1:
	/* t1 is a variable */
	while (isVAR(t2)) {
		register long val2 = derefVAR(t2);
		if (t2 EQ val2) goto var12;
		t2 = val2;
		}
	/* t1 is a var, t2 nonvar */	
	if (t2 EQ 0) return(FALSE);
	corebind(t1, t2);
	return(TRUE);
	
var12:
	/* t1, t2 are variables */
	corebindVV(t1, t2);
	return(TRUE);
	}
	
static clauseEntry *NextClause(clauseEntry *p, long key, long arity)
{
#ifdef cp_full
	/* need to find the next clause that matches, p points at current clause */
	p = (key EQ p->key) ? p->nextSameKeyClause : p->nextClause;
	if (key)							/* keyed access, use nextSameKeyClause */
		while (p NE NULL) {
			if (p->key EQ 0) break;
			if ((p->arity EQ arity) || checkArity(p->arity, arity)) return(p);
			p = p->nextSameKeyClause;
			}
#else
	/* need to find the next clause that matches, p points at starting choice */
	if (p->key EQ key)					/* keyed access, use nextSameKeyClause */
		while (p NE NULL) {
			if (p->key EQ 0) break;
			if ((p->arity EQ arity) || checkArity(p->arity, arity)) return(p);
			p = p->nextSameKeyClause;
			}
#endif
	if (key) {
		while (p NE NULL) {
			if ((p->key EQ 0) || (p->key EQ key))
				if ((p->arity EQ arity) || checkArity(p->arity, arity)) 
					return(p);
			p = p->nextClause;
			}
		}
	else {			/* key = 0, so no need to check clause keys */
		while (p NE NULL) {
			if ((p->arity EQ arity) || checkArity(p->arity, arity)) 
				return(p);
			p = p->nextClause;
			}
		}
	return(NULL);
	}


#define LoadRegisters()			ppc = tcb->ppc; \
								ce = tcb->ce; \
								cp = tcb->cp; \
								envbase = tcb->envbase; \
								hp = tcb->hp; \
								heapbase = tcb->heapbase; \
								stp = tcb->stp; \
								te = tcb->te; \
								cutb = (choicepoint *)tcb->cutb; \
								lcp = (choicepoint *)tcb->lcp; \
								emptyList = tcb->emptyList; \
								regs = tcb->args; \
								if (tcb->lcp EQ tcb->cpbase) { \
									criticalenv = envbase; \
									criticalhp = heapbase; \
									} \
								else { \
									criticalenv = lcp->critical; \
									criticalhp = lcp->hp; \
									}
#define SaveRegisters(arity)	tcb->ppc = ppc; \
								tcb->ce = ce; \
								tcb->cp = cp; \
								tcb->hp = hp; \
								tcb->stp = stp; \
								tcb->te = te; \
								tcb->cutb = (long)cutb; \
								tcb->lcp = (long)lcp; \
								tcb->nargs = arity


#ifdef arithdebug
#define popresult(val)		if (arTOS LT ar) goto Fail; \
							heapcheck(12); \
							if (arTOS->type) { \
								printf("result = %f (%08lx)\n", arTOS->value.f, *(long *)&arTOS->value.f); \
								val = makefloat(&hp, &arTOS->value.f); \
								} \
							else { \
								printf("result = %ld\n", arTOS->value.l); \
								val = makeint(&hp, arTOS->value.l); \
								} \
							--arTOS
#else
#define popresult(val)		if (arTOS LT ar) goto Fail; \
							heapcheck(12); \
							val = (arTOS->type) ? \
								   makefloat(&hp, &arTOS->value.f) : \
								   makeint(&hp, arTOS->value.l); \
							--arTOS
#endif

#define binaryoplfff(op)	if (arTOS LE ar) goto Fail;		/* need two elements */ \
							--arTOS; \
							if (arTOS[1].type) { \
								if (arTOS->type) \
									arTOS->value.f = arTOS->value.f op arTOS[1].value.f; \
								else { \
									arTOS->value.f = (fp)arTOS->value.l op arTOS[1].value.f; \
									arTOS->type = 1; \
									} \
								} \
							else { \
								if (arTOS->type) \
									arTOS->value.f = arTOS->value.f op (fp)arTOS[1].value.l; \
								else \
									arTOS->value.l = arTOS->value.l op arTOS[1].value.l; \
								}
#define unaryopfloat(op)	if (arTOS LT ar) goto Fail; \
							if (arTOS->type)  { \
								arTOS->value.f = op(arTOS->value.f); \
								} \
							else { \
								arTOS->value.f = op((fp)arTOS->value.l); \
								arTOS->type = 1; \
								}
#define unaryopint(op)		if (arTOS LT ar) goto Fail; \
							if (arTOS->type)  { \
								arTOS->value.l = (long)op(arTOS->value.f); \
								arTOS->type = 0; \
								}
#define compareop(op)		if (arTOS LE ar) goto Fail; /* need two elements */ \
							if (arTOS->type) { \
								if (arTOS[-1].type) \
									res = arTOS[-1].value.f op arTOS->value.f; \
								else \
									res = arTOS[-1].value.l op arTOS->value.f; \
								} \
							else \
								if (arTOS[-1].type) \
									res = arTOS[-1].value.f op arTOS->value.l; \
								else \
									res = arTOS[-1].value.l op arTOS->value.l

#define binaryboolop(op)    if (arTOS LE ar) goto Fail; /* need two elements */\
                            --arTOS;\
                            if (arTOS->type || arTOS[1].type) goto Fail;\
                            if ((arTOS->value.l NE 0) && (arTOS->value.l NE 1)) goto Fail;\
                            if ((arTOS[1].value.l NE 0) && (arTOS[1].value.l NE 1)) goto Fail;\
                            arTOS->value.l = arTOS->value.l op arTOS[1].value.l;
									
#define unaryarithop(a)				at = a
#define binaryarithop(a)			at = a
#define comparearithop(a)			at = a; reg = arTOS[-1].value.l
#define constantarithop(a)			++arTOS; arTOS->value.l = a

/* removed sept 15 1994 wjo - replaced by calls to BNRP_removeTaskFromChain
static int cleanup(TCB **tcb)
{
	TCB *current = *tcb;
	if((*tcb)->invoker NE NULL) {
		*tcb = (*tcb)->invoker;
		current->invoker = NULL;
		(*tcb)->invokee = NULL;
		return(1);
		}
	return(0);
	}
***/

long BNRP_RESUME(TCB *tcb)
{
	long val, l, arity, addr, clauseList, callerArity, calleeArity;
	BNRP_term a;
	int i, j, r, writemode;
#define T	r
#define P	r
#ifdef DEBUG
	int save;
#endif
	BNRP_Boolean inClause = FALSE, res;
	unsigned char c;
	jmp_buf oldjumpbuf;
	
#ifdef checkalignment
	if ((long)tcb & 0x03) printf("***** tcb not aligned\n");
	if ((long)&ppc & 0x03) printf("***** ppc not aligned\n");
	if ((long)ar & 0x03) printf("***** ar not aligned\n");
	if ((long)&val & 0x03) printf("***** val not aligned\n");
	if ((long)&clauseList & 0x03) printf("***** clauseList not aligned\n");
#endif
#ifdef TRACE
	BNRP_trace[0] = 0;
#endif
	memcpy(oldjumpbuf, jumpbuf, sizeof(jmp_buf));

    /* install INT and FEP signal handlers */
	oldSigIntHandler = BNRP_installSighandler(SIGINT, BNRP_initSighandler(abortHandler));
    oldSigFpeHandler = BNRP_installSighandler(SIGFPE, BNRP_initSighandler(arithHandler));

#ifdef check
	if (tcp->lcp EQ NULL) {
		printf("lcp NULL when entering\n");
		tcp->lcp = (choicepoint *)tcb->cpbase;
		}
#endif
	if (i = setjmp(jumpbuf)) {
		long result;

	/*	LoadRegisters();  REMOVED 22/07/94  Was causing Prolog to not detect env/cp overflows*/

#ifdef TRACE
		if(tcb->invoker NE NULL) {
			traceit("ERROR %d in task  %d", i, (long)tcb);
			}
		else {
			traceit("ERROR %d\n", i);
			}
#endif

RedoError:
		tcb->ppsw &= ~isolateResult;		/* clear any existing error */
		if (i EQ QUIT) {
			memcpy(jumpbuf, oldjumpbuf, sizeof(jmp_buf));
			BNRP_installSighandler(SIGINT,oldSigIntHandler);  /* Modified Oz 08/12/95 */
			BNRP_installSighandler(SIGFPE,oldSigFpeHandler);  /* Modified Oz 08/12/95 */
			return(0);
			}
		if (i EQ ERROREXIT) {
			if ((i = specialError) NE ARITHERROR) {
				LoadRegisters();			/* from existing TCB */
				}
			}
		tcb->ppsw |= i & isolateResult;		/* add in new error code */

		/* generate current traceback while looking for recovery_unit */
		strcpy(BNRP_lastErrorTraceback, "Traceback:\n");
		if (tagof((result = tcb->procname)) EQ SYMBOLTAG) {
			strcat(BNRP_lastErrorTraceback, "    Executing -> ");
			strncat(BNRP_lastErrorTraceback, 
					nameof(result), 
					tracebackStrLen - strlen(BNRP_lastErrorTraceback));
			if ((i EQ NAMEDCUTNOTFOUND) && (tagof(regs[1]) EQ SYMBOLTAG)) {
				strcat(BNRP_lastErrorTraceback, "(");
				strncat(BNRP_lastErrorTraceback, 
						nameof(regs[1]), 
						tracebackStrLen - strlen(BNRP_lastErrorTraceback) - 2);
				strcat(BNRP_lastErrorTraceback, ")");
				}
			}
		l = ce;
		addr = 0;
		/* go until out of room in the string */
		while ((tracebackStrLen - strlen(BNRP_lastErrorTraceback)) GT 50) {
			result = env(l, NAME) & 0xFFFFFFFE;
			if (tagof(result) NE SYMBOLTAG) break;
			/* keep track of first recovery_unit we discover */
			if ((result EQ recoveryUnitAtom) && (addr EQ 0)) addr = l;
			strcat(BNRP_lastErrorTraceback, "\n    Called by -> "); 
			strncat(BNRP_lastErrorTraceback, 
					nameof(result), 
					tracebackStrLen - strlen(BNRP_lastErrorTraceback));
			if (l EQ env(l, CE)) {			/* at end of envs, end of traceback */
				if (addr NE 0) break;		/* found recovery_unit so go there */
				SaveRegisters(0);			/* no recovery_unit, prepare to exit */
				memcpy(jumpbuf, oldjumpbuf, sizeof(jmp_buf));
				if (BNRP_removeTaskFromChain(&tcb)) {
					LoadRegisters();
					goto RedoError;
					}
				BNRP_installSighandler(SIGINT,oldSigIntHandler);  /* Modified Oz 08/12/95 */
				BNRP_installSighandler(SIGFPE,oldSigFpeHandler);  /* Modified Oz 08/12/95 */
				return(i);
				}
			l = env(l, CE);					/* back up to previous env */
			}
		if (addr NE 0)
			l = addr;						/* env containing recovery_unit */
		else {
			/* no recovery_unit so far, out of traceback room so continue search */
			while (env(l, NAME) NE recoveryUnitAtom) {
				if (l EQ env(l, CE)) {			/* at end of envs, not found */
					SaveRegisters(0);
					memcpy(jumpbuf, oldjumpbuf, sizeof(jmp_buf));
					if (BNRP_removeTaskFromChain(&tcb)) {
						LoadRegisters();
						goto RedoError;
						}
                    BNRP_installSighandler(SIGINT,oldSigIntHandler);  /* Modified Oz 08/12/95 */
                    BNRP_installSighandler(SIGFPE,oldSigFpeHandler);  /* Modified Oz 08/12/95 */
        			return(i);				
					}
				l = env(l, CE);
				}
			}
		res = TRUE;							/* so we fail after cut */
		a = recoveryUnitAtom;
		goto finishNamedCut;
		}
Begin:
	LoadRegisters();

#ifdef DEBUG
	printf("Starting Heap:"); BNRP_dumpHex(stdout, (void *)heapbase, (void *)hp);
	printf("Starting Environment:"); BNRP_dumpHex(stdout, (void *)envbase, (void *)(ce+32));
	printf("Starting lcp = %p, cutb = %p\n", lcp, cutb);
#else
#ifdef cutdebug
	printf("Starting lcp = %p, cutb = %p\n", lcp, cutb);
#endif
#endif

	l = tcb->ppsw & isolateMode;
	if (l EQ bodyMode) goto Body;
	writemode = (l EQ headWriteMode) ? 1 : 0;
	callerArity = calleeArity = 1;
	
Call:
#ifdef check
	if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
		printf("\n\nHelp in call, cp = %08lX is in heap\n", cp);
		ERROR(-10);
		}
#endif
	if (callerArity NE calleeArity) {
#ifdef DEBUG
		printf("Starting call, caller = %ld, callee = %ld, caller registers:\n", 
				callerArity, calleeArity);
		for (j = 1; j LE labs(callerArity); ++j) {
			printf("     ");
			BNRP_dumpArg(stdout, tcb, regs[j]);
			printf("\n");
			}
		printf("Heap:"); BNRP_dumpHex(stdout, (void *)heapbase, (void *)hp);
		printf("Environments:"); BNRP_dumpHex(stdout, (void *)envbase, (void *)(ce+32));
#endif
		/* know that aritys are + -, - +, or - - */
		if (callerArity GE 0) {						/* case + - */
			int arity, i;
			long t;
					
			/* we need to take the parameters from -calleeArity to callerArity */
			/* and make a list on the stack.  regs[-calleeArity] then points to it */
			
			arity = -calleeArity;
			heapcheck(callerArity - arity + 2);
			t = maketerm(LISTTAG, hp);
			for (i = arity; i LE callerArity; ++i) {
				push(long, hp, regs[i]);
				}
			push(long, hp, 0);
			regs[arity] = t;
			}
		else if (calleeArity GE 0) { 				/* case - + */
			int i;
			long l;
			BNRP_Boolean checkEOL = TRUE;
					
			/* we need to expand the caller's tail variable (into possibly variables) */
			/* so that we can make the call with the proper arity.  This may fail if */
			/* the tail variable is bound to a shorter or longer list than necessary */

			i = -callerArity;
			l = regs[i];
			stp = addrof(l);
#ifdef check
			if (tagof(l) NE LISTTAG) 
				printf("Missing list in tail variable call\n");
#endif
			while (i LE calleeArity) {
				get(long, stp, l);
				while (tagof(l) EQ TVTAG) {
					long addr, a;
					
					addr = addrof(l);				/* isolate address */
					a = *(long *)addr;				/* get what tailvar points at */
					if (a EQ l) {					/* unbound tail variable ?? */
						corebindtohp(addr, TVTAG);
						/* make remaining parameters be variables, TV points to heap */
						heapcheck(calleeArity - i + 2);
						while(i LE calleeArity) {
							register long l = makevarterm(hp);
							regs[i++] = l;
							push(long, hp, l);
							}
						push(long, hp, 0);			/* mark end of list */
						checkEOL = FALSE;
						break;						/* will set next reg, who cares */
						}
					stp = addr;
					get(long, stp, l);
					}
				if (l EQ 0) goto Fail;				/* not long enough */
				regs[i++] = l;
				}
			if (checkEOL) {				/* read up to here, check that we have an end-list */
				get(long, stp, l);
				while (tagof(l) EQ TVTAG) {
					long addr, a;
					
					addr = addrof(l);			/* isolate address */
					a = *(long *)addr;				/* get what tailvar points at */
					if (a EQ l) {					/* unbound tailvariable ?? */
						corebind(addr, l = 0);
						break;
						}
					stp = addr;
					get(long, stp, l);
					}
				if (l NE 0) goto Fail;				/* list too long, then error */
				}
			}
		else if (callerArity LT calleeArity) {		/* case - - */
			int a, b, i;
			long t;
					
			/* we need to take the parameters from -calleeArity to -callerArity */
			/* and make a list on the stack.  regs[-calleeArity] then points to it */
			/* Note special handling of tail variable at the end */
			
			a = -calleeArity;
			b = -callerArity;
			heapcheck(b - a + 1);
			t = maketerm(LISTTAG, hp);
			for (i = a; i LT b; ++i) {
				push(long, hp, regs[i]);
				}
			push(long, hp, maketerm(TVTAG, addrof(regs[b])));
			regs[a] = t;
			}
		else {										/* case - -, callerArity GT calleeArity */
			int i, j;
			long l;
					
			/* we need to expand the caller's tail variable (into possibly variables) */
			/* so that we can make the call with the proper arity.  This may fail if */
			/* the tail variable is bound to a shorter list than necessary */

			i = -callerArity;
			j = -calleeArity;
			l = regs[i];
			stp = addrof(l);
#ifdef check
			if (tagof(l) NE LISTTAG) printf("Missing list in tail variable call\n");
#endif
			while (i LT j) {
				get(long, stp, l);
				while (tagof(l) EQ TVTAG) {
					long addr, a;
					
					addr = addrof(l);			/* isolate address */
					a = *(long *)addr;			/* get what tailvar points at */
					if (a EQ l) {				/* unbound tailvariable ?? */
						corebindtohp(addr, TVTAG);
						/* push remaining regs up till last reg (must be TV) */
						heapcheck(j - i + 1);
						while(i LT j) {
							register long t = makevarterm(hp);
							regs[i++] = t;
							push(long, hp, t);
							}
						/* push tailvariable onto the heap at end of list */
						l = maketerm(LISTTAG, hp);  /* Added JR 23/05/95 */
						push(long, hp, maketerm(TVTAG, hp));

						*(long *)hp = 0;		/* clear in case of constraint marker */
						break;					/* to set reg[i++] = l */
						}
					stp = addr;
					get(long, stp, l);
					}
				if (l EQ 0) goto Fail;			/* list not long enough */
				regs[i++] = l;
				}
			if (i EQ j)							/* make tailvariable out of what's left */
				regs[i] = maketerm(LISTTAG, stp);
			}
#ifdef DEBUG
		printf("Doing call, caller = %ld, callee = %ld, caller registers:\n", 
				callerArity, calleeArity);
		for (j = 1; j LE labs(calleeArity); ++j) {
			printf("     ");
			BNRP_dumpArg(stdout, tcb, regs[j]);
			printf("\n");
			}
		printf("Heap:"); BNRP_dumpHex(stdout, (void *)heapbase, (void *)hp);
		printf("Environments:"); BNRP_dumpHex(stdout, (void *)envbase, (void *)(ce+32));
#endif
		}

#ifdef executioncodetrace
	printf("\nHEAD ");
#endif
#ifdef profile
	asm("   .reserve        .HEAD., 4, \"data\", 4");
	asm("M.HEAD:");
	asm("   sethi   %hi(.HEAD.), %o0");
	asm("   call    mcount");
	asm("   or      %o0, %lo(.HEAD.), %o0");
#endif
	while (TRUE) {
#ifdef check
		if ((ppc GE heapbase) && (ppc LE tcb->cpbase)) {
			printf("\n\nHelp in call, c = %d, ppc = %08lX in heap\n\n", c, ppc);
			ERROR(-1);
			}
#endif
		get(unsigned char, ppc, c);
#ifdef DEBUG
		++headCount[c];
		printf("Executing head byte %02X at %p\n", c, ppc-1);
#endif
#ifdef executioncodetrace
		printf("%02X ", c); fflush(stdout);
#endif
		r = c & 0x07;
		switch (c) {
			case 0x00:						/* neck */
#ifndef DEBUG
						++headCount[c];
#endif
#ifdef executiontrace
						printf("NECK:\n");
#endif
						goto Neck;
			case 0x01:						/* unify_void */
						if (writemode) {
							heapcheck(1);
							push(long, hp, makevarterm(hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);			/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, makevarterm(hp));
									*(long *)hp = 0;		/* in case there are constraints */
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (l EQ 0)					/* is it end of a sequence ?? */
								goto Fail;
							}
						break;
			case 0x02:						/* tunif_void */
						if (writemode) {
							heapcheck(1);
							push(long, hp, maketerm(TAILVARTAG, hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						break;
			case 0x03:						/* end_seq */
						if (writemode) {
							heapcheck(1);
							push(long, hp, 0);
							writemode = 0;
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);			/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									corebind(addr, l = 0);
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (l NE 0)						/* must be end */
								goto Fail;
							}
						break;
			case 0xC4:						/* unif_cons_by_value(C) */
						{
						long oldhp;
						
						heapcheck(16);
						if (writemode) {
							oldhp = hp;
							push(long, hp, 0L);
							}
						if ((val = BNRP_lookupStateSpace(&ppc, &hp, &te)) EQ 0) goto Fail;
						if (!writemode) goto finishUnifyCons;
						if (hp NE (oldhp + sizeof(long)))   /* Oct 94 wjo */
							*(long *)oldhp = maketerm(TVTAG, hp);
						else
							hp = oldhp;
						push(long, hp, val);
						}
						break;

			case 0x04:						/* unif_cons(C) */
						constantLWA(ppc);
						get(long, ppc, val);
						if (writemode) {
							heapcheck(1);
							push(long, hp, val);
							}
						else {
							register long l;
						
			finishUnifyCons:
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, l = val);
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							while (isVAR(l)) {
								register long addr = derefVAR(l);
								if (l EQ addr) {			/* must be a variable */
									corebind(addr, l = val);
									break;
									}
								l = addr;
								}
							if (l EQ val) break;
							if (tagof(l) NE STRUCTMASK) goto Fail;
							if (tagof(val) NE STRUCTMASK) goto Fail;
							{
								long *addr1, *addr2;
								li arity1, arity2;
								
								addr1 = (long *)addrof(l);
								addr2 = (long *)addrof(val);
								arity1.l = *addr1++;
								arity2.l = *addr2++;
								if (arity1.i.a NE NUMBERIDshort) goto Fail;
								if (arity1.l NE arity2.l) goto Fail;
								switch (arity1.i.b) {
									case INTIDshort:	comparelong(addr1, addr2, goto Fail);
														break;
									case FLOATIDshort:	fpLWA(addr1);
														fpLWA(addr2);
														comparefp(addr1, addr2, goto Fail);
														break;
									default:			goto Fail;
									}
								}	/* nesting */
							} /* else */
						break;
			case 0x05:						/* neckcon */
#ifndef DEBUG
						++headCount[c];
#endif
#ifdef executiontrace
						printf("NECKCON:\n");
#endif
						goto neckWithCheck;
			case 0xE6:						/* gcalloc */
#ifdef gc_proceed
						if ((BNRP_gcFlag) && (!inClause)) {
							/* if lcp NE cutb then we just created a new cp before this call */
							/* added check for no choicepoints 92/11/04 */
							if (((long)lcp EQ tcb->cpbase) || ((lcp EQ cutb) && ((lcp->bce NE ce) || (lcp->bcp NE cp)))) {
								/* create dummy choicepoint */
								register choicepoint *newcp;
								
								newcp = (choicepoint *)((long)lcp - sizeof(choicepoint));
								if ((long)newcp LE cpend) { ERROR(CPOVERFLOW); }
								newcp->numRegs = -1;			/* arity */
								newcp->procname = 0;
								newcp->bcp = cp;
								newcp->bce = ce;
								newcp->te = te;
								newcp->lcp = lcp;
								criticalhp = newcp->hp = hp;
								if (ce GE criticalenv) {
									int i;
									
									i = *(char *)newcp->bcp;			/* get save byte from caller */
									criticalenv = ce + ((i + 1) * sizeof(long));
									}
								newcp->critical = criticalenv;
								newcp->key = -1;
								newcp->clp = 0;
								lcp = cutb = newcp;
								}
							}
#endif
			case 0x06:						/* alloc */
						{
						long eprime;
						
						eprime = ce;
						if (ce GE criticalenv) {
							unsigned char n;
							
							n = *(unsigned char *)cp;	/* get save byte from caller */
							ce += (n + 1) * sizeof(long);
							}
						else
							ce = criticalenv;
						push(long, ce, tcb->procname);
						push(long, ce, (long)cutb);	/* set up CUTB */
#ifdef cutordebug
						printf("In alloc, lcp = %p, cutb = %p\n", lcp, cutb);
#endif
						push(long, ce, eprime);		/* set up CE */
#ifdef gc_cut
						memset((void *)ce, 0, 48);	/* init env to avoid problems with gc */
#endif
						e(CP) = cp;
						}
						if (ce GE (long)envend) { ERROR(ENVOVERFLOW); }
						break;
			case 0x07:						/* unify_nil */
						if (writemode) {
							heapcheck(1);
							push(long, hp, emptyList);
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, l = emptyList);
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							while (isVAR(l)) {
								register long addr = derefVAR(l);
								if (l EQ addr) {			/* must be a variable */
									corebind(addr, l = emptyList);
									break;
									}
								l = addr;
								}
							if (tagof(l) NE LISTTAG) goto Fail;
							if (l EQ emptyList) break;
							l = addrof(l);
							l = *(long *)l;
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {				/* unbound TV ? */
									corebind(addr, l = 0);
									break;
									}
								l = a;
								}
							if (l NE 0) goto Fail;
							}
						break;
						
			case 0xA2:						/* unif_address(C) */
						{
						register long l;
						long addr1;
						
						addr1 = *(long *)(ppc-1-sizeof(clauseEntry)-sizeof(long)-sizeof(long));
						l = e(1);
						while (isVAR(l)) {
							register long addr = derefVAR(l);
							if (l EQ addr) {			/* must be a variable */
								heapcheck(8);
								corebind(addr, makeint(&hp, addr1));
								break;
								}
							l = addr;
							}
						if (l LE 0) {
							register long *addr;
							if (tagof(l) NE STRUCTMASK) goto Fail;
							addr = (long *)addrof(l);
							if (*addr++ NE INTID) goto Fail;
							if (*addr NE addr1) goto Fail;
							}
						}
						break;

			case 0xB3:						/* get_cons_by_value(C) */
						get(unsigned char, ppc, r);
						heapcheck(16);
						if ((val = BNRP_lookupStateSpace(&ppc, &hp, &te)) EQ 0) goto Fail;
						goto finishGetCons;

			case 0x08:						/* get_cons(C) */
						get(unsigned char, ppc, r);
			case 0x09:
			case 0x0a:
			case 0x0b:
			case 0x0c:
			case 0x0d:
			case 0x0e:
			case 0x0f:
						constantLWA(ppc);
						get(long, ppc, val);
			finishGetCons:
						{
						register long l;
						
						l = regs[r];
						while (isVAR(l)) {
							register long addr = derefVAR(l);
							if (l EQ addr) {			/* must be a variable */
								corebind(addr, l = val);
								break;
								}
							l = addr;
							}
						if (l EQ val) break;
						if (tagof(l) NE STRUCTMASK) goto Fail;
						if (tagof(val) NE STRUCTMASK) goto Fail;
						{
							long *addr1, *addr2;
							li arity1, arity2;
							
							addr1 = (long *)addrof(l);
							addr2 = (long *)addrof(val);
							arity1.l = *addr1++;
							arity2.l = *addr2++;
							if (arity1.i.a NE NUMBERIDshort) goto Fail;
							if (arity1.l NE arity2.l) goto Fail;
							switch (arity1.i.b) {
								case INTIDshort:	comparelong(addr1, addr2, goto Fail);
													break;
								case FLOATIDshort:	fpLWA(addr1);
													fpLWA(addr2);
													comparefp(addr1, addr2, goto Fail);
													break;
								default:			goto Fail;
								}
							}	/* nesting */
						}
						break;
			case 0x10:					/* get_struct(N, R) */
						get(unsigned char, ppc, r);
			case 0x11:
			case 0x12:
			case 0x13:
			case 0x14:
			case 0x15:
			case 0x16:
			case 0x17:
						{
						short arity;
						register long l;
						
						get(char, ppc, arity);
						l = regs[r];
						while (isVAR(l)) {
							register long addr = derefVAR(l);
							if (l EQ addr) {			/* must be a variable */
								writemode = 1;
								corebindtohp(addr, STRUCTTAG);
								push(long, hp, FUNCID | (arity & 0x0000FFFF));
								break;
								}
							l = addr;
							}
						if (tagof(l) EQ STRUCTTAG) {
							li arity1;
							
							stp = addrof(l);
							get(long, stp, arity1.l);
							if (arity1.i.a NE FUNCIDshort) goto Fail;
							if (arity NE arity1.i.b)
								if (!checkArity(arity, arity1.i.b)) goto Fail;
							writemode = 0;
							}
						else if (l LE 0)
							goto Fail;
						}
						break;
			case 0x18:
			case 0x19:
			case 0x1a:
			case 0x1b:
			case 0x1c:
			case 0x1d:
			case 0x1e:
			case 0x1f:
                /* 
                 * HEADER 0x18 - 0x1F
                 * Feb 1996 modified by yanzhou@bnr.ca
                 * WAS: unif_unsaft
                 * NOW: unused
                 */
                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in HEAD.\n", c);
                goto Fail;
                break;
			case 0x91:
                /* 
                 * HEADER 0x91
                 * Feb 1996 modified by yanzhou@bnr.ca
                 * WAS: unif_unsafp
                 * NOW: unused
                 */
                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in HEAD.\n", c);
                goto Fail;
                break;
			case 0x20:					/* get_list(R) */
						get(unsigned char, ppc, r);
			case 0x21:
			case 0x22:
			case 0x23:
			case 0x24:
			case 0x25:
			case 0x26:
			case 0x27:
						l = regs[r];
						while (isVAR(l)) {
							register long addr = derefVAR(l);
							if (l EQ addr) {			/* must be a variable */
								writemode = 1;
								corebindtohp(addr, LISTTAG);
								break;
								}
							l = addr;
							}
						if (tagof(l) EQ LISTTAG) {
							stp = addrof(l);
							writemode = 0;
							}
#ifdef check
						else if (l EQ 0) {
							printf("Unexpected 0 in get_list");
							goto Fail;
							}
#endif
						else if (l LE 0)
							goto Fail;
						break;
			case 0x28:					/* get_nil(R) */
						get(unsigned char, ppc, r);
			case 0x29:
			case 0x2a:
			case 0x2b:
			case 0x2c:
			case 0x2d:
			case 0x2e:
			case 0x2f:
						l = regs[r];
						while (isVAR(l)) {
							register long addr = derefVAR(l);
							if (l EQ addr) {			/* must be a variable */
								corebind(addr, emptyList);
								l = 0;
								break;
								}
							l = addr;
							}
						if (tagof(l) EQ LISTTAG) {
							if (l EQ emptyList) break;
							l = addrof(l);				/* remove tag bits */
							if ((val = *(long *)l) EQ 0) break;
							while (val NE 0) {
								if (tagof(val) NE TVTAG) goto Fail;
								addr = addrof(val);
								l = *(long *)addr;
								if (l EQ val) {			/* unbound tail variable */
									corebind(addr, 0);
									break;
									}
								val = l;
								}
							}
						else if (l NE 0)
							goto Fail;
						break;
			case 0x30:					/* get_valt(T, R) */
						get(unsigned char, ppc, r);
			case 0x31:
			case 0x32:
			case 0x33:
			case 0x34:
			case 0x35:
			case 0x36:
			case 0x37:
						{
						int t;
						
						get(unsigned char, ppc, t);
						if (!coreUnify(regs[t], regs[r])) goto Fail;
						}
						break;
			case 0x38:					/* get_valp(P, R) */
						get(unsigned char, ppc, r);
			case 0x39:
			case 0x3a:
			case 0x3b:
			case 0x3c:
			case 0x3d:
			case 0x3e:
			case 0x3f:
						{
						int p;
						
						get(unsigned char, ppc, p);
						if (p EQ 0) { constantLWA(ppc); get(envExtension, ppc, p); }
#ifdef check
						if (p LE 0) DEBUGSTR("get_valp");
#endif
						if (!coreUnify(e(p), regs[r])) goto Fail;
#ifdef check
						if (tagof(e(p)) EQ TVTAG) printf("Unexpected TV in get_valp\n");
#endif
						}
						break;
			case 0x40:					/* unify_vart(T) */
						get(unsigned char, ppc, T);
			case 0x41:
			case 0x42:
			case 0x43:
			case 0x44:
			case 0x45:
			case 0x46:
			case 0x47:
						if (writemode) {
							heapcheck(1);
							push(long, hp, regs[T] = makevarterm(hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, regs[T] = makevarterm(hp));
									*(long *)hp = 0;		/* in case there are constraints */
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (tagof(l) NE TVTAG) {
								if (l EQ 0)
									goto Fail;
								else
									regs[T] = l;
								}
							}
						break;
			case 0x48:					/* unify_varp(P) */
						get(unsigned char, ppc, P);
						if (P EQ 0) { constantLWA(ppc); get(envExtension, ppc, P); }
			case 0x49:
			case 0x4a:
			case 0x4b:
			case 0x4c:
			case 0x4d:
			case 0x4e:
			case 0x4f:
#ifdef check
						if (P LE 0) DEBUGSTR("unify_varp");
#endif
						if (writemode) {
							heapcheck(1);
							push(long, hp, e(P) = makevarterm(hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, e(P) = makevarterm(hp));
									*(long *)hp = 0;		/* in case there are constraints */
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (tagof(l) NE TVTAG) {
								if (l EQ 0)
									goto Fail;
								else
									e(P) = l;
								}
							}
						break;
			case 0x50:					/* unify_valt(T) */
						get(unsigned char, ppc, T);
			case 0x51:
			case 0x52:
			case 0x53:
			case 0x54:
			case 0x55:
			case 0x56:
			case 0x57:
						if (writemode) {
							heapcheck(1);
							push(long, hp, regs[T]);
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, regs[T]);
									*(long *)hp = 0;		/* in case there are constraints */
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (tagof(l) NE TVTAG)
								if ((l EQ 0) || (!coreUnify(l, regs[T]))) goto Fail;
							}
						break;
			case 0x58:					/* unify_valp(P) */
						get(unsigned char, ppc, P);
						if (P EQ 0) { constantLWA(ppc); get(envExtension, ppc, P); }
			case 0x59:
			case 0x5a:
			case 0x5b:
			case 0x5c:
			case 0x5d:
			case 0x5e:
			case 0x5f:
#ifdef check
						if (P LE 0) DEBUGSTR("unify_valp");
#endif
						if (writemode) {
							heapcheck(1);
							push(long, hp, e(P));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							}
						else {
							register long l;
							
							get(long, stp, l);
							while (tagof(l) EQ TVTAG) {
								addr = addrof(l);		/* isolate address */
								a = *(long *)addr;			/* get what tailvar points at */
								if (a EQ l) {
									writemode = 1;
									corebindtohp(addr, TVTAG);
									push(long, hp, e(P));
									*(long *)hp = 0;		/* in case there are constraints */
									break;
									}
								stp = addr;
								get(long, stp, l);
								}
							if (tagof(l) NE TVTAG) {
								if ((l EQ 0) || (!coreUnify(l, e(P)))) goto Fail;
								}
#ifdef check
							if (tagof(e(P)) EQ TVTAG) printf("Unexpected TV in unify_valp\n");
#endif
							}
						break;
			case 0x60:					/* tunify_vart(T) */
						get(unsigned char, ppc, T);
			case 0x61:
			case 0x62:
			case 0x63:
			case 0x64:
			case 0x65:
			case 0x66:
			case 0x67:
						if (writemode) {
							regs[T] = maketerm(LISTTAG, hp);
							heapcheck(1);
							push(long, hp, maketerm(TVTAG, hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							writemode = 0;
							}
						else {
							regs[T] = maketerm(LISTTAG, stp);
							}
						break;
			case 0x68:					/* tunify_varp(P) */
						get(unsigned char, ppc, P);
						if (P EQ 0) { constantLWA(ppc); get(envExtension, ppc, P); }
			case 0x69:
			case 0x6a:
			case 0x6b:
			case 0x6c:
			case 0x6d:
			case 0x6e:
			case 0x6f:
#ifdef check
						if (P LE 0) DEBUGSTR("tunify_varp");
#endif
						if (writemode) {
							e(P) = maketerm(LISTTAG, hp);
							heapcheck(1);
							push(long, hp, maketerm(TVTAG, hp));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							writemode = 0;
							}
						else {
							e(P) = maketerm(LISTTAG, stp);
							}
						break;
			case 0x70:					/* tunify_valt(T) */
						get(unsigned char, ppc, T);
			case 0x71:
			case 0x72:
			case 0x73:
			case 0x74:
			case 0x75:
			case 0x76:
			case 0x77:
#ifdef check
						if (T LE 0) DEBUGSTR("tunify_valt");
#endif
						if (writemode) {
							heapcheck(1);
							push(long, hp, maketerm(TVTAG, addrof(regs[T])));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							regs[T] = maketerm(LISTTAG, addrof(regs[T]));
							writemode = 0;
							}
						else {
							if (!coreUnify(regs[T], maketerm(LISTTAG, stp))) goto Fail;
							}
						break;
			case 0x78:					/* tunify_valp(P) */
						get(unsigned char, ppc, P);
						if (P EQ 0) { constantLWA(ppc); get(envExtension, ppc, P); }
			case 0x79:
			case 0x7a:
			case 0x7b:
			case 0x7c:
			case 0x7d:
			case 0x7e:
			case 0x7f:
#ifdef check
						if (P LE 0) DEBUGSTR("tunify_valp");
#endif
						if (writemode) {
							heapcheck(1);
							push(long, hp, maketerm(TVTAG, addrof(e(P))));
							*(long *)hp = 0;		/* clear in case of constraint marker */
							writemode = 0;
							}
						else {
							if (!coreUnify(e(P), maketerm(LISTTAG, stp))) goto Fail;
#ifdef check
							if (tagof(e(P)) EQ TVTAG) printf("Unexpected TV in tunify_valp\n");
#endif
							}
						break;
			case 0xD5:						/* copy_valp (copy perm to temp, used by state space)	 */
						get(unsigned char, ppc, P);
						if (P EQ 0) { constantLWA(ppc); get(envExtension, ppc, P); }
						regs[MAXREGS] = (long)makevarterm(&e(P));
			case NOOP:
						break;
			default:						/* get_vart(T, R) */
											/* get_varp(P, R) */
						{
						int p;
						
						p = r;
						r = (c >> 4) & 0x07;
						if (r EQ 0) { get(unsigned char, ppc, r); }
						if (p EQ 0) { get(unsigned char, ppc, p); }
						if (c & 0x08) {		/* get_varp(P, R) */
#ifdef check
							if (p LE 0) DEBUGSTR("get_varp");
							if (tagof(regs[r]) EQ TVTAG) printf("Unexpected TV in get_varp\n");
#endif
							e(p) = regs[r];
							}
						else {
							regs[p] = regs[r];
#ifdef check
							if (p EQ r) DEBUGSTR("Unexpected same register in get_vart");
#endif
							}
						}
						break;
			}
		}
neckWithCheck:
	/* able to check constraints now, so do so */
	if (BNRPflags.i.b) {						/* only check bottom 16 bits */
		a = 0;
		if (BNRPflags.l & 0x01) {
			BNRPflags.l ^= 0x01;				/* clear bit */
			a = attentionAtom;					/* call attention_handler/0 */
			arity = 0;
			}
		else if (BNRPflags.l & 0x02) {
			BNRPflags.l ^= 0x02;				/* clear bit */
			if (BNRPconstraintHeader NE 0) {
				long *_t = (long *)addrof(BNRPconstraintHeader);
				
				if (_t[1] EQ 0) {
					/* only one constraint in list, optimize */
					a = -1;
					regs[1] = _t[0];
					}
				else {
					a = indirectAtom;			/* constraints in list, so call */
					arity = 1;					/* meta-interpreter to handle it */
					regs[1] = BNRPconstraintHeader;
					}
				BNRPconstraintHeader = 0;
				}
			}
		else if (BNRPflags.l & 0x04) {
			BNRPflags.l ^= 0x04;				/* clear bit */
			a = tickAtom;						/* call $tick/0 */
			arity = 0;
			}
		else									/* don't know what happened, clear all bits */
			BNRPflags.i.b = 0;
		if (a NE 0) {							/* do we need to call something ?? */
			/* if size byte is 0 then we must do an alloc first */
			if ((*(char *)ppc EQ 0) && (*(char *)(ppc+1) EQ 6)) {
				long eprime;
				
				eprime = ce;
				if (ce GE criticalenv) {
					unsigned char n;
					
					n = *(unsigned char *)cp;	/* get save byte from caller */
					ce += (n + 1) * sizeof(long);
					}
				else
					ce = criticalenv;
				push(long, ce, tcb->procname);
				push(long, ce, (long)cutb);	/* set up CUTB */
#ifdef cutordebug
				printf("In SPECIAL alloc, lcp = %p, cutb = %p\n", lcp, cutb);
#endif
				push(long, ce, eprime);		/* set up CE */
#ifdef gc_cut
				memset((void *)ce, 0, 48);	/* init env to avoid problems with gc */
#endif
				e(CP) = cp;
				if (ce GE (long)envend) { ERROR(ENVOVERFLOW); }
				}
			if (a EQ -1) goto callIndirect; else goto completeCall;
			}
		}
	ppc += 2;									/* skip over size and extra byte */
Neck:
	/* constraints handled at next call/exec/proceed so that we know */
	/* what registers are in use */
	
Body:
	writemode = 0;
#ifdef DEBUG
	printf("Starting body, registers are:\n");
	for (j = 1; j LE 5; ++j) {
		printf("     ");
		BNRP_dumpArg(stdout, tcb, regs[j]);
		printf("\n");
		}
	printf("Heap:"); BNRP_dumpHex(stdout, (void *)heapbase, (void *)hp);
	printf("Environments:"); BNRP_dumpHex(stdout, (void *)envbase, (void *)(ce+32));
#endif
#ifdef executioncodetrace
	printf("\nBODY ", c);
#endif
#ifdef TRACE
	traceit("BODY\n");
#endif
#ifdef profile
	asm("   .reserve        .BODY., 4, \"data\", 4");
	asm("M.BODY:");
	asm("   sethi   %hi(.BODY.), %o0");
	asm("   call    mcount");
	asm("   or      %o0, %lo(.BODY.), %o0");
#endif
	while (TRUE) {
#ifdef check
		if ((ppc GE heapbase) && (ppc LE tcb->cpbase)) {
			printf("\n\nHelp in body, c = %d, ppc = %08lX in heap\n\n", c, ppc);
			ERROR(-2);
			}
#endif
		get(unsigned char, ppc, c);
#ifdef DEBUG
		++bodyCount[c];
		printf("Executing body byte %02X at %p\n", c, ppc-1);
#endif
#ifdef executioncodetrace
		printf("%02X ", c); fflush(stdout);
#endif
		r = c & 0x07;
		switch (c) {
			case 0x00:								/* proceed */
			Proceed:
						ppc = cp + 1;				/* skip save byte */
#ifdef cutordebug
						printf("In proceed e @ %p, lcp = %p, cutb = %p\n", ce, lcp, cutb);
#endif
#ifdef check
						if ((ppc GE heapbase) && (ppc LE tcb->cpbase)) {
							printf("\n\nHelp in proceed, c = %d, ppc = %08lX in heap\n", c, ppc);
							printf("cp = %08lX\n", cp);
							ERROR(-10);
							}
#endif
#ifdef gc_proceed
						if ((BNRP_gcFlag) && (!inClause) && ((long)lcp NE tcb->cpbase)) {
							/* do garbage collection if the conditions are right */
							if ((ce LT criticalenv) && (ce EQ lcp->bce) && (cp EQ lcp->bcp)) {
								if ((hp - criticalhp) GT BNRP_gcFlag) {
									regs[0] = 0;
									resetCritical(tcb);
									BNRP_gc_proceed(lcp, &hp, te, regs);
									}
								/* if lcp is a dummy cp then remove it */
								if ((lcp->clp EQ 0) && ((long)lcp LT tcb->cpbase)) {
									lcp = lcp->lcp;
									resetCritical(tcb);
									}
								}
							}
#endif
						inClause = FALSE;
						break;
			case 0x01:								/* push_void */
						heapcheck(1);
						push(long, hp, makevarterm(hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x02:								/* tpush_void */
						heapcheck(1);
						push(long, hp, maketerm(TVTAG, hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x03:								/* push_end */
						heapcheck(1);
						push(long, hp, 0);
						break;
			case 0x04:								/* push_cons(C) */
						constantLWA(ppc);
						get(long, ppc, l);
						heapcheck(1);
						push(long, hp, l);
						break;
			case 0x05:								/* nop */
						break;
			case 0x06:								/* dealloc */
						cp = e(CP);
#ifdef check
						if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
							printf("\n\nHelp from dealloc1, cp = %08lX in heap @ %08lX\n\n", cp, &e(CP));
							ERROR(-3);
							}
#endif
						cutb = (choicepoint *)e(CUTB);
						ce = e(CE);
#ifdef DEBUG
						printf("In dealloc, new ce = %p, new cp = %p\n", ce, cp);
#endif
						break;
			case 0x08:								/* put_cons(C, R) */
						get(unsigned char, ppc, r);
			case 0x09:
			case 0x0a:	
			case 0x0b:	
			case 0x0c:	
			case 0x0d:	
			case 0x0e:	
			case 0x0f:	
						constantLWA(ppc);
						get(long, ppc, regs[r]);
						break;
			case 0x10:								/* put_struct(N, R) */
						get(unsigned char, ppc, r);
			case 0x11:	
			case 0x12:	
			case 0x13:	
			case 0x14:	
			case 0x15:	
			case 0x16:	
			case 0x17:	
						get(char, ppc, arity);
						regs[r] = maketerm(STRUCTTAG, hp);
						heapcheck(1);
						push(long, hp, FUNCID | (arity & 0x0000FFFF));
						break;
			case 0x18:
			case 0x19:	
			case 0x1a:	
			case 0x1b:	
			case 0x1c:	
			case 0x1d:	
			case 0x1e:	
			case 0x1f:	
                /*
                 * BODY 0x18 - 0x1F
                 * Feb 1996 modified by yanzhou@bnr.ca
                 * WAS: push_unsafp
                 * NOW: unused
                 */
                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in BODY.\n", c);
                goto Fail;
                break;
			case 0x20:								/* put_list(R) */
						get(unsigned char, ppc, r);
			case 0x21:
			case 0x22:
			case 0x23:
			case 0x24:
			case 0x25:
			case 0x26:
			case 0x27:	
						regs[r] = maketerm(LISTTAG, hp);
						break;
			case 0x28:								/* put_nil(R) */
						get(unsigned char, ppc, r);
			case 0x29:	
			case 0x2a:	
			case 0x2b:	
			case 0x2c:	
			case 0x2d:	
			case 0x2e:	
			case 0x2f:	
						regs[r] = emptyList;
						break;
			case 0x30:								/* put_void(R) */
						get(unsigned char, ppc, r);
			case 0x31:
			case 0x32:
			case 0x33:
			case 0x34:
			case 0x35:
			case 0x36:
			case 0x37:	
						heapcheck(1);
						push(long, hp, regs[r] = makevarterm(hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x38:								/* put_varp(P, R) */
						get(unsigned char, ppc, r);
			case 0x39:	
			case 0x3a:	
			case 0x3b:	
			case 0x3c:	
			case 0x3d:	
			case 0x3e:	
			case 0x3f:	
						{
                            register int p;
						
                            get(unsigned char, ppc, p);
#ifdef check
                            if (p LE 0) DEBUGSTR("put_varp");
#endif
                            /*
                             * Feb 1996 modified by yanzhou@bnr.ca
                             *
                             * WAS:
                             *   Allocating permanent variables on the environment stack
                             *   put_varp(P,A) :- temp[A] <- ce[P] <- (var | address(ce[P]))
                             *
                             * CHANGED TO:
                             *   Allocating permanent variables on the heap
                             *   put_varp(P,A) :- temp[A] <- ce[P] <- (var | hp <= hp)
                             */
                            heapcheck(1);
                            push(long, hp, regs[r] = e(p) = makevarterm(hp));
                            *(long *)hp = 0;    /* clear in case of constraint marker */
						}
						break;
			case 0x40:								/* push_vart(T) */
						get(unsigned char, ppc, T);
			case 0x41:	
			case 0x42:	
			case 0x43:	
			case 0x44:	
			case 0x45:	
			case 0x46:	
			case 0x47:	
						heapcheck(1);
						push(long, hp, regs[T] = makevarterm(hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x48:								/* push_varp(P) */
						get(unsigned char, ppc, P);
			case 0x49:	
			case 0x4a:	
			case 0x4b:	
			case 0x4c:	
			case 0x4d:	
			case 0x4e:	
			case 0x4f:	
#ifdef check
						if (P LE 0) DEBUGSTR("push_varp");
#endif
						heapcheck(1);
						push(long, hp, e(P) = makevarterm(hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x50:								/* push_valt(T) */
						get(unsigned char, ppc, T);
			case 0x51:	
			case 0x52:	
			case 0x53:	
			case 0x54:	
			case 0x55:	
			case 0x56:	
			case 0x57:	
						heapcheck(1);
						push(long, hp, regs[T]);
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x58:								/* push_valp(P) */
						get(unsigned char, ppc, P);
			case 0x59:	
			case 0x5a:	
			case 0x5b:	
			case 0x5c:	
			case 0x5d:	
			case 0x5e:	
			case 0x5f:	
						heapcheck(1);
#ifdef check
						if (P LE 0) DEBUGSTR("push_valp");
#endif
						push(long, hp, e(P));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x60:								/* tpush_vart(T) */
						get(unsigned char, ppc, T);
			case 0x61:	
			case 0x62:	
			case 0x63:	
			case 0x64:	
			case 0x65:	
			case 0x66:	
			case 0x67:	
						regs[T] = maketerm(LISTTAG, hp);
						heapcheck(1);
						push(long, hp, maketerm(TVTAG, hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x68:								/* tpush_varp(P) */
						get(unsigned char, ppc, P);
			case 0x69:	
			case 0x6a:	
			case 0x6b:	
			case 0x6c:	
			case 0x6d:	
			case 0x6e:	
			case 0x6f:	
#ifdef check
						if (P LE 0) DEBUGSTR("tpush_varp");
#endif
						e(P) = maketerm(LISTTAG, hp);
						heapcheck(1);
						push(long, hp, maketerm(TVTAG, hp));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			case 0x70:								/* tpush_valt(T) */
						get(unsigned char, ppc, T);
			case 0x71:	
			case 0x72:	
			case 0x73:	
			case 0x74:	
			case 0x75:	
			case 0x76:	
			case 0x77:
						heapcheck(1);
						push(long, hp, maketerm(TVTAG, addrof(regs[T])));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;	
			case 0x78:								/* tpush_valp(P) */
						get(unsigned char, ppc, P);
			case 0x79:	
			case 0x7a:	
			case 0x7b:	
			case 0x7c:	
			case 0x7d:	
			case 0x7e:	
			case 0x7f:
#ifdef check
						if (P LE 0) DEBUGSTR("tpush_valp");
#endif
						heapcheck(1);
						push(long, hp, maketerm(TVTAG, addrof(e(P))));
						*(long *)hp = 0;			/* clear in case of constraint marker */
						break;
			default:								/* put_valt(T, R) */
													/* put_valp(P, R) */
						{
						int p;
						
						p = r;
						r = (c >> 4) & 0x07;
						if (r EQ 0) { get(unsigned char, ppc, r); }
						if (p EQ 0) { get(unsigned char, ppc, p); }
						if (c & 0x08) {				/* put_valp(P, R) */
#ifdef check
							if (p LE 0) DEBUGSTR("put_valp");
							if (tagof(e(p)) EQ TVTAG) printf("Unexpected TV in put_valp\n");
#endif
							regs[r] = e(p);
							}
						else
							regs[r] = regs[p];
						}
			case NOOP:
						break;

			case 0x07:	{							/* escape */
						register struct arith *arTOS;
						BNRP_term at;
						long reg;
#ifdef gc_cut
						long envSize;
#endif
						
						arTOS = ar-1;
						get(unsigned char, ppc, c);
#ifdef executioncodetrace
						printf("\nESCAPE ");
#endif
						if (!inClause) for (;;) {
#ifdef DEBUG
							printf("Executing escape byte %02X at %p\n", c, ppc-1);
#endif
#ifdef executioncodetrace
							printf("%02X ", c); fflush(stdout);
#endif
							++escapeCount[c];
							r = c & 0x07;
							errno = 0;
							switch (c) {					/* break */
							case 0:		SaveRegisters(10); 
										tcb->ppsw = bodyMode;
										memcpy(jumpbuf, oldjumpbuf, sizeof(jmp_buf));
                                        BNRP_installSighandler(SIGINT,oldSigIntHandler); /* Modified Oz 08/12/95 */
                                        BNRP_installSighandler(SIGFPE,oldSigFpeHandler); /* Modified Oz 08/12/95 */
										return(0);
							case 0x01:						/* ecut */
										l = e(CUTB);
#ifdef gc_cut
										get(unsigned char, ppc, envSize);
#else
										++ppc;
#endif
								quickCut:
										if (l GT (long)lcp) {
											lcp = (choicepoint *)l;
											resetCritical(tcb);
#ifdef gc_cut
											if ((BNRP_gcFlag) && ((long)lcp NE tcb->cpbase) && ((hp - lcp->hp) GT BNRP_gcFlag))
												BNRP_gc(envSize, lcp, &hp, ce, te);
#endif
											}
#ifdef alldebug
										printf("In cut, lcp = %p, cutb = %p\n", lcp, cutb);
#endif
										break;
							case 0x02:						/* dcut */
										if ((l = (long)cutb) LE (long)lcp) break;	/* nothing to cut */
#ifdef gc_cut
										envSize = *(unsigned char *)cp;
#endif
#ifdef gc_proceed
										/* if ! followed by proceed then do gc */
										if ((BNRP_gcFlag) && 
												(*(unsigned char *)ppc EQ 0) &&	/* point at proceed */
												((long)cutb NE tcb->cpbase) &&	/* choicepoint exists */
												((hp - cutb->hp) GT BNRP_gcFlag)) {
											choicepoint *last;
											
											/* gc on and possibly enough space to collect, */
											/* so get ready for gc if possible */
											if ((ce EQ cutb->bce) && (cp EQ cutb->bcp))
												/* use cutb since it's OK */
												last = cutb;
											else {
												/* see what the choicepoint is just before cutb */
												last = lcp;
												while ((long)last->lcp LT (long)cutb) last = last->lcp;
												}
											if ((long)last GT (long)lcp) {
												/* cut to last or almost last choicepoint */
												lcp = last;
												resetCritical(tcb);
												}
											if (((long)lcp NE tcb->cpbase) && ((hp - lcp->hp) GT BNRP_gcFlag)) {
												if ((ce EQ lcp->bce) && (cp EQ lcp->bcp)) {
													regs[0] = *(char *)ppc;
													resetCritical(tcb);
													BNRP_gc_proceed(lcp, &hp, te, regs);
													}
												}
											/* now do the proceed, as otherwise */
											/* the proceed would attempt a gc   */
											ppc = cp + 1;			/* skip save byte */
											
											/* 92/12/11 JR - proceed will get rid of dummy choicepoints, */
											/*               which we're not doing.  Added code to do so */
											last = (choicepoint *)l;
											if ((last->clp EQ 0) && 	/* last is a dummy choicepoint */
												(ce LT criticalenv) &&	/* conditions match */
												(ce EQ last->bce) && 
												(cp EQ last->bcp)) l = (long)last->lcp;
											}
										/* finish the cut */
#endif
										goto quickCut;
							case 0x03:						/* push_nil */
										heapcheck(1);
										push(long, hp, emptyList);
										break;
							case 0x05:
										DEBUGSTR("Body escape 0705");
										break;
							case 0x0A:						/* call */
										get(char, ppc, arity);
										constantLWA(ppc);
										get(BNRP_term, ppc, a);
							completeCall:
#ifdef DEBUG
										save = *(unsigned char *)ppc;
										printf("Size of save is %d\n", save);
#endif
										cp = ppc;
#ifdef check
										if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
											printf("\n\nHelp in completecall, cp = %08lX in heap\n\n", cp);
											ERROR(-3);
											}
#endif
#ifdef DEBUG
										printf("In call, e @ %p, new return addr = %p\n", ce, ppc);
#endif
							finishCall:
										/* when we get here:			*/
										/*	a - atom of functor			*/
										/*	arity - arity of call		*/
										/*	regs[1]..regs[abs(arity)]	*/
											
										if ((BNRPflags.l) && (tcb->procname NE ssAtom)) {
											register long funcaddr;
											li header;
											
											/* first do a heap check */
											/* 3 is for struct header, name, 0 */
											/* 3 is for list item1, struct, 0 */
											if (arity GE 0)
												funcaddr = arity + 6;
											else
												funcaddr = 6 - arity;
											heapcheck(funcaddr);
											
											/* copy current goal onto heap as a structure */
											funcaddr = maketerm(STRUCTTAG, hp);
											header.i.a = FUNCIDshort;
											if (arity GE 0) {
												header.i.b = arity + 1;
												push(long, hp, header.l);
												push(long, hp, a);
												for (i = 1; i LE arity; ++i) {
													push(long, hp, regs[i]);
													}
												push(long, hp, 0);
												}
											else {
												header.i.b = arity - 1;
												push(long, hp, header.l);
												push(long, hp, a);
												for (i = 1; i LT -arity; ++i) {
													push(long, hp, regs[i]);
													}
												push(long, hp, maketerm(TVTAG, addrof(regs[-arity])));
												}
											
											/* see why we got here */
											if (BNRPflags.l & 0x01) {		/* attention ?? */
												BNRPflags.l ^= 0x01;		/* clear bit */
												/* call indirect with [attention_handler, orig_goal] */
												a = indirectAtom;
												arity = 1;
												regs[1] = maketerm(LISTTAG, hp);
												push(long, hp, attentionAtom);
												push(long, hp, funcaddr);
												push(long, hp, 0);
												}
											else if (BNRPflags.l & 0x02) {	/* constraints ?? */
												BNRPflags.l ^= 0x02;		/* clear bit */
												/* do we really have constraints ?? */
												if (BNRPconstraintHeader NE 0) {
													/* yes, so call indirect with [constraints, orig_goal] */
													a = indirectAtom;
													arity = 1;
													regs[1] = BNRPconstraintHeader;
													BNRPconstraintHeader = 0;
													*(long *)BNRPconstraintEnd = maketerm(TVTAG, hp);
													push(long, hp, funcaddr);
													push(long, hp, 0);
													}
												}
											else if (BNRPflags.l & 0x04) {	/* tick ?? */
												BNRPflags.l ^= 0x04;	/* clear bit */
												/* call indirect with [$tick, orig_goal] */
												a = indirectAtom;
												arity = 1;
												regs[1] = maketerm(LISTTAG, hp);
												push(long, hp, tickAtom);
												push(long, hp, funcaddr);
												push(long, hp, 0);
												}
											else if (BNRPflags.l & 0x10000)  {
												symbolEntry *callProc;
												
												callProc = symof(a);
												if (callProc NE callProc->self) 
													ERROR(DANGLINGREFERENCE);
												if (callProc->debug) {
													a = tracerAtom;
													arity = 1;
													regs[1] = funcaddr;
													}
												}
											else			/* don't know, clear all bits, continue normal call */
												BNRPflags.l = 0;
											}
										{
										symbolEntry *callProc;
										clauseEntry *first, *next;
										long key, keysave;
										
								tryCallAgain:
										if (a GE 0) {
											ERROR(INVALIDSYMBOLINCALL);
											}
										cutb = lcp;
										callProc = symof(a);
										if (callProc NE callProc->self) 
											ERROR(DANGLINGREFERENCE);
										key = keysave = (arity EQ 0) ? 0 :
														computeKey((arity NE -1) ? regs[1] : maketerm(TVTAG, addrof(regs[1])));
#ifdef callordebug
										printf("%%%%%%%%%% Starting execution of goal %s\n", callProc->name);
										if (arity)
											for (j = 1; j LE labs(arity); ++j) {
												printf("     ");
												BNRP_dumpArg(stdout, tcb, regs[j]);
												printf("\n");
												}
#endif
#ifdef DEBUG
										printf("First argument key = %08lX\n", key);
										printf("In call lcp = %p, cutb = %p\n", lcp, cutb);
										printf("Heap:"); BNRP_dumpHex(stdout, (void *)heapbase, (void *)hp);
										printf("Environments:"); BNRP_dumpHex(stdout, (void *)envbase, (void *)(ce+32));
#endif
#ifdef cutdebug
										printf("In call lcp = %p, cutb = %p\n", lcp, cutb);
#endif
#ifdef executiontrace
										printf("CALL: %s\n", callProc->name);
							/*			printf("CALL: %s(", callProc->name);
										BNRP_printTCB = tcb;
										for (j = 1; j LE labs(arity); ++j)  { fflush(stdout); BNRP_dumpArg(stdout, tcb, regs[j]); if (j NE labs(arity)) printf(", "); }
										printf(")\n");	*/
#endif
#ifdef TRACE
										traceit("CALL %.50s\n", callProc->name);
#endif
										if ((first = callProc->firstClause) EQ NULL) {
											register long funcaddr;
											li header;
											
											/* debugger must be on */
											if ((BNRPflags.l & 0x10000) EQ 0) goto Fail;
											/* in case no tracer exists */
											if (a EQ tracerAtom) goto Fail;
											
											/* first do a heap check */
											/* 3 is for struct header, name, 0 */
											if (arity GE 0)
												funcaddr = arity + 3;
											else
												funcaddr = 3 - arity;
											heapcheck(funcaddr);
											
											/* copy current goal onto heap as a structure */
											funcaddr = maketerm(STRUCTTAG, hp);
											header.i.a = FUNCIDshort;
											if (arity GE 0) {
												header.i.b = arity + 1;
												push(long, hp, header.l);
												push(long, hp, a);
												for (i = 1; i LE arity; ++i) {
													push(long, hp, regs[i]);
													}
												push(long, hp, 0);
												}
											else {
												header.i.b = arity - 1;
												push(long, hp, header.l);
												push(long, hp, a);
												for (i = 1; i LT -arity; ++i) {
													push(long, hp, regs[i]);
													}
												push(long, hp, maketerm(TVTAG, addrof(regs[-arity])));
												}
											a = tracerAtom;
											arity = 1;
											regs[1] = funcaddr;
											goto tryCallAgain;
											}
										if ((long)first LT 0) {		/* must be a primitive */
											BNRP_Boolean (*address)(), res;
											BNRP_term prevName;
#ifdef check
											long oldhp, oldppc;
#endif
#ifdef profile
											asm("   .reserve        .PRIM., 4, \"data\", 4");
											asm("M.PRIM:");
											asm("   sethi   %hi(.PRIM.), %o0");
											asm("   call    mcount");
											asm("   or      %o0, %lo(.PRIM.), %o0");
#endif
											
											address = (BNRP_Boolean (* )())-((long)first);
											if (arity LT 0) {
														
												/* we need to expand the caller's tail */
												/* variable so that we can call the    */
												/* primitive with the proper arity.    */
									
												arity = -arity;
#ifdef check
												if (tagof(regs[arity]) NE LISTTAG) 
													printf("Missing list in tail variable call\n");
#endif
												stp = addrof(regs[arity]);
												--arity;
												for (;;) {
													long l;
													
													get(long, stp, l);
													while (tagof(l) EQ TVTAG) {
														long a;
														
														stp = addrof(l);			/* isolate address */
														a = *(long *)stp;				/* get what TV points at */
														if (a EQ l) {					/* unbound ?? */
															/* put back tail variable */
															regs[++arity] = maketerm(LISTTAG, stp);
															arity = -arity;
															l = 0;
															break;						
															}
														get(long, stp, l);
														}
													if (l EQ 0) break;				/* not long enough */
													regs[++arity] = l;
													}
#ifdef DEBUG
												printf("%%%%%%%%%% Continuing execution of goal %s\n", callProc->name);
												if (arity)
													for (j = 1; j LE labs(arity); ++j) {
														printf("     ");
														BNRP_dumpArg(stdout, tcb, regs[j]);
														printf("\n");
														}
#endif
												}
											SaveRegisters(arity);
											
											/* save and restore current procedure name in case */
											/* we fail immediately after a primitive call, so  */
											/* that we do not get executing 'primitive' */
											prevName = tcb->procname;
											tcb->procname = a;
											++BNRPprimitiveCalls;
											heapcheck(20);
#ifdef check
											oldppc = ppc; oldhp = hp;
#endif
											if (tcb->constraintHead NE 0) printf("primitive call with constraints\n");
											
											/* Check to see if primitive operation requires the tcb's to be switched */
											if (a EQ BNRP_taskswitch_primitive) {
												tcb->ppsw = bodyMode;	/* clear error code as well */
												res = (*address)(&tcb);
												}
											else
												res = (*address)(tcb);
RetPrim:
#ifdef checkalignment
											if ((long)tcb & 0x03) printf("***** tcb not aligned\n");
#endif
											LoadRegisters();
#ifdef check
											if (hp LT heapbase) printf("hp less than heapbase\n");
											if (hp GT tcb->heapend) printf("hp greater than heapend\n");
											if (oldppc NE ppc) printf("ppc changed in call to %s\n", callProc->name);
											if (hp-oldhp GT 10000) printf("heap up > 10000 in call to %s\n", callProc->name);
#endif
Failing:									if (!res) { 
												tcb->constraintHead = 0;
												goto Fail;
												}
											if (a NE ssAtom) tcb->procname = prevName;
											/* check for constraints */
											if (tcb->constraintHead EQ 0) goto Proceed;
											a = indirectAtom;
											arity = 1;
											regs[1] = tcb->constraintHead;
											tcb->constraintHead = 0;
											goto tryCallAgain;
											}
#ifdef profile
										asm("   .reserve        .CALL., 4, \"data\", 4");
										asm("M.CALL:");
										asm("   sethi   %hi(.CALL.), %o0");
										asm("   call    mcount");
										asm("   or      %o0, %lo(.CALL.), %o0");
#endif
										tcb->procname = a;
										if (key) {									/* if key defined */
											while (first NE NULL) {
												if ((first->arity EQ arity) || checkArity(first->arity, arity)) {
													/* possible match */
													if (first->key EQ 0) break;			/* this goal has no key so it matches everything */
													if (first->key EQ key) break;		/* keys match */
													}
												first = first->nextClause;
												}
											}
										else
											while ((first NE NULL) && (!((first->arity EQ arity) || checkArity(first->arity, arity))))
												first = first->nextClause;
										if (first EQ NULL) goto Fail;
										callerArity = arity;
										calleeArity = first->arity;
										ppc = (long)first + sizeof(clauseEntry);
#ifdef cp_full
										if ((next = NextClause(first, key, arity)) NE NULL) {
#else
										if ((next = (key) ? first->nextSameKeyClause : first->nextClause) NE NULL) {
#endif
											register choicepoint *newcp;
											long absarity;
											
											if ((absarity = arity) LT 0) absarity = -absarity;
											newcp = (choicepoint *)((long)lcp - sizeof(choicepoint) - (absarity * sizeof(long)));
											if ((long)newcp LE cpend) { ERROR(CPOVERFLOW); }
											newcp->key = keysave;
											criticalhp = newcp->hp = hp;
											newcp->te = te;
											newcp->clp = (long)next;
#ifdef check
											if (lcp EQ NULL) {
												printf("lcp NULL when creating cp\n");
												lcp = (choicepoint *)tcb->cpbase;
												}
#endif
											newcp->lcp = lcp;
											newcp->bcp = cp;
											newcp->bce = ce;
									/*		newcp->cutb = cutb;		*/
#ifdef check
											if (cutb NE lcp) printf("**** cutb not lcp *****\n");
#endif
											newcp->procname = tcb->procname;
											if (ce GE criticalenv) {
												int i;
												
												i = *(char *)newcp->bcp;			/* get save byte from caller */
												criticalenv = ce + ((i + 1) * sizeof(long));
												}
											newcp->critical = criticalenv;
#ifdef callordebug
											printf("new choicepoint @ %08lX, env = %08lX, criticalenv = %08lX\n", 
													(long)newcp, ce, criticalenv);
#endif
#ifdef TRACE
											traceit("CP\n");
#endif
											newcp->numRegs = arity;
											for (j = 1; j LE absarity; ++j)
												newcp->args[j] = regs[j];
											lcp = newcp;
											}
										}
										goto Call;
						
							case 0xE6:						/* dcut, exec */
#ifdef gc_proceed
										/* check if we can do a gc on the ! */
										if ((BNRP_gcFlag) && ((long)cutb NE tcb->cpbase) && ((hp - cutb->hp) GT BNRP_gcFlag)) {
											choicepoint *last;
											
											/* gc on and possibly enough space to collect, */
											/* so get ready for gc if possible */
											if ((ce EQ cutb->bce) && (cp EQ cutb->bcp))
												/* use cutb since it's OK */
												last = cutb;
											else {
												/* see what the choicepoint is just before cutb */
												last = lcp;
												while ((long)last->lcp LT (long)cutb) last = last->lcp;
												}
											if ((long)last GT (long)lcp) {
												/* cut to last or almost last choicepoint */
												lcp = last;
												resetCritical(tcb);
												}
											if (((long)lcp NE tcb->cpbase) && ((hp - lcp->hp) GT BNRP_gcFlag)) {
												if ((ce EQ lcp->bce) && (cp EQ lcp->bcp)) {
													regs[0] = *(char *)ppc;
													resetCritical(tcb);
													BNRP_gc_proceed(lcp, &hp, te, regs);
													}
												}
											}
										/* finish the cut */
#endif										
										if ((long)cutb GT (long)lcp) {
											lcp = cutb;
											resetCritical(tcb);
											}
							case 0x0C:						/* exec */
										get(char, ppc, arity);
										constantLWA(ppc);
										get(BNRP_term, ppc, a);
										goto finishCall;
										
							case 0x09:						/* call indirect */
							callIndirect:
#ifdef DEBUG
										save = *(unsigned char *)ppc;
										printf("Size of save is %d\n", save);
#endif
										cp = ppc;
#ifdef check
										if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
											printf("\n\nHelp in callindirect, cp = %08lX in heap\n\n", cp);
											ERROR(-3);
											}
#endif
#ifdef DEBUG
										printf("In call, e @ %p, new return addr = %p\n", ce, ppc);
#endif
							case 0x0B:						/* exec indirect */
							finishIndirect:
#ifdef DEBUG
										printf("     ");
										BNRP_dumpArg(stdout, tcb, regs[1]);
										printf("\n");
#endif										
										{
										long savereg1, val;
										
										savereg1 = val = regs[1];
										while (isVAR(val)) {
											register long l = derefVAR(val);
											if (l EQ val) ERROR(UNEXECUTABLETERM);
											val = l;
											}
										if (tagof(val) EQ STRUCTTAG) {
											li arity1;
											
											addr = addrof(val);
											get(long, addr, arity1.l);
#ifdef DEBUG
											printf("     struct header = %08lX @ %08lX\n", arity1.l, addr-4);
#endif
											if (arity1.i.a NE FUNCIDshort) ERROR(UNEXECUTABLETERM);
											arity = arity1.i.b - 1;
											if (arity LT 0)
												arity = MAXREGS;
											else
												if (arity GE MAXREGS) ERROR(UNEXECUTABLETERM);
											get(long, addr, a);
											while (isVAR(a)) {
												register long l =  derefVAR(a);
												if (l EQ a) ERROR(UNEXECUTABLETERM);
												a = l;
												}
											if (tagof(a) NE SYMBOLMASK) ERROR(UNEXECUTABLETERM);
#ifdef callordebug
											printf("%%%%%%%%%% Trying indirect execution of goal %s, arity %ld\n", nameof(a), arity);
#endif
#ifdef TRACE
											traceit("INDIRECT %.50s\n", nameof(a));
#endif
											for (i = 1; i LE arity; ++i) {
												val = regs[i] = *(long *)addr;
												while (tagof(val) EQ TVTAG) {
													addr = addrof(val);
													val = regs[i] = *(long *)addr;
													/* if unbound tailvar then get out */
													if (val EQ maketerm(TVTAG, addr)) {
														arity = -i;
														regs[i] = maketerm(LISTTAG, addrof(regs[i]));
														goto finishCall;
														}
													}
												addr += sizeof(long);
												if (val EQ 0) break;
												}
											if (arity EQ MAXREGS) arity = i - 1;
											goto finishCall;
											}
										else if (tagof(val) EQ SYMBOLMASK) {
											arity = 0;
											a = val;
											goto finishCall;
											}
										else if (tagof(val) NE LISTMASK) {
											ERROR(UNEXECUTABLETERM);
											}
											
										/* unsure what we have, call indirect handler in Prolog */
										a = indirectAtom;
										arity = 1;
										regs[1] = savereg1;
										}
										goto finishCall;
							
							case 0x0D:						/* call clause$$/3 */
										/* do normal call processing */
										cp = ppc;
#ifdef check
										if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
											printf("\n\nHelp from clause$$, cp = %08lX in heap\n\n", cp);
											ERROR(-3);
											}
#endif
#ifdef callordebug
										printf("In clause$$, e @ %p, new return addr = %p\n", ce, ppc);
#endif
										cutb = lcp;
										/* first argument must be procedure address */
										addr = regs[1];
										while (isVAR(addr))		/* chase variable */
											addr = derefVAR(addr);
										if (tagof(addr) EQ STRUCTMASK) {
											long *a;
																					
											a = (long *)addrof(addr);
											if (*a++ NE INTID) goto Fail;
											addr = *a;
											}
										else if (tagof(addr) EQ INTMASK) {
											li t;
											t.l = addrof(addr);
											addr = t.i.b;
											}
										else
											goto Fail;
											
										{
										clauseEntry *first;

										/* get clause address */
										first = (clauseEntry *)addr;
										/* set ppc to start of clause */
										ppc = addr + sizeof(clauseEntry);
										/* indicate special case */
										inClause = TRUE;
										
										/* create argument list on the heap */
										calleeArity = callerArity = first->arity;
#ifdef callordebug
										printf("In clause$$, creating %ld variables\n", calleeArity);
#endif
										addr = hp;
										if (callerArity GE 0) {
											heapcheck(callerArity + 2);
											for (j = 1; j LE callerArity; ++j) {
												push(long, hp, makevarterm(hp));
												}
											push(long, hp, 0);
											}
										else {
											heapcheck(2 - callerArity);
											for (j = -1; j GT callerArity; --j) {
												push(long, hp, makevarterm(hp));
												}
											push(long, hp, maketerm(TVTAG, hp));
											}
										if (!coreUnify(regs[2], maketerm(LISTTAG, addr))) goto Fail;
										
										/* create resulting list on the heap */
										clauseList = hp;
										push(long, hp, 0);
										if (!coreUnify(regs[3], maketerm(LISTTAG, clauseList))) goto Fail;

										/* time to get the arguments already created */
										if (callerArity GE 0)
											for (j = 1; j LE callerArity; ++j) {
												get(long, addr, regs[j]);
												}
										else {
											for (j = -1; j GE callerArity; --j) {
												get(long, addr, regs[-j]);
												}
											regs[-callerArity] = maketerm(LISTTAG, addrof(regs[-callerArity]));
											}
										}
										goto Call;

							case 0x0E:						/* exec $$exec(address, [args]) */
#ifdef callordebug
										printf("In $$exec");
#endif
										{
										long newppc, list, val, a;
										
										newppc = regs[1];
										while (isVAR(newppc)) {
											register long l = derefVAR(newppc);
											if (l EQ newppc) goto Fail;		/* variable?? */
											newppc = l;
											}
										if (tagof(newppc) EQ STRUCTMASK) {
											long *addr = (long *)addrof(newppc);
											if (*addr++ NE INTID) goto Fail;
											newppc = *addr;
											}
										else if (tagof(newppc) EQ INTMASK)  {
											li t;
											t.l = addrof(newppc);
											newppc = t.i.b;
											}
										else
											goto Fail;
										list = regs[2];
										while (isVAR(list)) {
											register long l = derefVAR(list);
											if (l EQ list) goto Fail;		/* variable?? */
											list = l;
											}
										if (tagof(list) NE LISTMASK) goto Fail;
										list = addrof(list);
										ppc = newppc + sizeof(clauseEntry);
										calleeArity = ((clauseEntry *)newppc)->arity;
#ifdef callordebug
										printf(", new ppc = %p\n", ppc);
#endif
										callerArity = 0;
										for (;;) {
											get(long, list, val);
											while (tagof(val) EQ TVTAG) {		/* while we have a tail variable */
												list = addrof(val);			/* isolate address */
												get(long, list, a);					/* get what tailvar points at */
												if (a EQ val) {						/* really a tail variable */
													regs[++callerArity] = a;
													callerArity = -callerArity;
													goto Call;
													}
												val = a;
												}
											if (val EQ 0) goto Call;
											regs[++callerArity] = val;
#ifdef callordebug
											printf("     "); BNRP_dumpArg(stdout, tcb, val); printf("\n");
#endif
											}
										}
																				
							case 0x0F:						/* fail */
										tcb->procname = failAtom;
										goto Fail;

							case 0x10:						/* vart(T) */
										get(unsigned char, ppc, r);
							case 0x11:
							case 0x12:
							case 0x13:
							case 0x14:
							case 0x15:
							case 0x16:
							case 0x17:
										l = regs[r];
							checkVar:
										while (tagof(l) EQ TVTAG) {
											addr = addrof(l);		/* isolate address */
											a = *(long *)addr;			/* get what tailvar points at */
											if (a EQ l) goto Fail;		/* if tailvar then fail */
											l = a;
											}
										while (isVAR(l)) {
											register long addr = derefVAR(l);
											if (l EQ addr) break;		/* must be a variable */
											l = addr;
											}
										if (l LE 0) goto Fail;			/* not a variable */
										break;

							case 0x18:						/* varp(P) */
										get(unsigned char, ppc, P);
							case 0x19:
							case 0x1A:
							case 0x1B:
							case 0x1C:
							case 0x1D:
							case 0x1E:
							case 0x1F:
#ifdef check
										if (P LE 0) DEBUGSTR("varp");
#endif
										l = e(P);
										goto checkVar;

							case 0x20:						/* tvart(T) */
										get(unsigned char, ppc, T);
							case 0x21:
							case 0x22:
							case 0x23:
							case 0x24:
							case 0x25:
							case 0x26:
							case 0x27:
										l = regs[T];
							checkTailVar:
										/* registers always marked as lists to TVs */
										if (tagof(l) NE LISTTAG) goto Fail;
							checkTailVarAgain:
										addr = addrof(l);		/* isolate address */
										a = *(long *)addr;			/* get what tailvar points at */
										if (a EQ l) break; 			/* if not same tailvar then repeat */
										l = a;
										if (tagof(a) EQ TVTAG) goto checkTailVarAgain;
										goto Fail;

							case 0x28:						/* tvarp(P) */
										get(unsigned char, ppc, P);
							case 0x29:
							case 0x2A:
							case 0x2B:
							case 0x2C:
							case 0x2D:
							case 0x2E:
							case 0x2F:
#ifdef check
										if (P LE 0) DEBUGSTR("tvarp");
#endif
										l = e(P);
										goto checkTailVar;
										
							case 0x30:						/* more_choicepoints */
										/* succeed if ! would do anything, fail otherwise */
										/* note that cp grow downwards */
										/* changed 93/4/23 to skip dummy choicepoints pointed to by lcp */
										{
										choicepoint *__lcp = lcp;
										while (1) {
											if (e(CUTB) LE (long)__lcp) goto Fail;
											/* skip dummy choicepoints */
											if (__lcp->numRegs NE -1) break;
											__lcp = __lcp->lcp;
											}
										}
										break;
										
							case 0x98:						/* cCutsp */
										l = e(CUTB);
										reg = e(CE);
										res = FALSE;
										tcb->procname = cutcutAtom;
#ifdef gc_cut
										envSize = *(unsigned char *)cp;
#endif
										goto cut;
										
							case 0x31:						/* cCut */
										l = e(CUTB);
										reg = e(CE);
										res = FALSE;
										tcb->procname = cutcutAtom;
#ifdef gc_cut
										get(unsigned char, ppc, envSize);
#else
										++ppc;
#endif
#ifdef cutordebug
										printf("in cCut, lcp = %08lX, cutb = %08lX", (long)lcp, l);
#else
#ifdef calldebug
										printf("in cCut\n");
#endif
#endif
							cut:
										if (l GE (long)lcp) {
											choicepoint *nextcp;
											
											/* must reset cp to at most e(CUTB) */
											nextcp = lcp;
											while ((long)nextcp->lcp LT l)
												nextcp = nextcp->lcp;
#ifdef cutordebug
											printf(", nextcp = %08lX, search for %08lX\n", (long)nextcp, reg);
#endif
#ifdef cutdebug
											printf("Choicepoints:"); BNRP_dumpHex(stdout, (void *)lcp, (void *)tcb->cpbase);
#endif
											lcp = (choicepoint *)l;
											if (nextcp->bce EQ reg)
												lcp = nextcp;
#ifdef cutdebug
											printf("new lcp = %08lX\n", (long)lcp);
#endif
											resetCritical(tcb);
#ifdef gc_cut
											if ((!res) && (BNRP_gcFlag) && ((long)lcp NE tcb->cpbase) && ((hp - lcp->hp) GT BNRP_gcFlag))
												BNRP_gc(envSize, lcp, &hp, ce, te);
#endif
											}
										if (res) goto Fail;
										break;
							case 0x32:						/* cdCut */
										l = (long)cutb;
										reg = ce;
										res = FALSE;
										tcb->procname = cutcutAtom;
#ifdef gc_cut
										envSize = *(unsigned char *)cp;
#endif
#ifdef cutordebug
										printf("in cdCut, lcp = %08lX, cutb = %08lX", (long)lcp, l);
#else
#ifdef calldebug
										printf("in cdCut\n");
#endif
#endif
										goto cut;
							case 0x33:						/* cCutFail */
										l = e(CUTB);
										reg = e(CE);
										res = TRUE;
										tcb->procname = cutFailAtom;
#ifdef cutordebug
										printf("in cCutFail, lcp = %08lX, cutb = %08lX", (long)lcp, l);
#else
#ifdef calldebug
										printf("in cCutFail\n");
#endif
#endif
										goto cut;
							case 0x34:						/* cdCutFail */
										l = (long)cutb;
										reg = ce;
										res = TRUE;
										tcb->procname = cutFailAtom;
#ifdef cutordebug
										printf("in cdCutFail, lcp = %08lX, cutb = %08lX", (long)lcp, l);
#else
#ifdef calldebug
										printf("in cdCutFail\n");
#endif
#endif
										goto cut;
										
							case 0x35:						/* cut(name) */
										res = FALSE;
										tcb->procname = cutcutAtom;
#ifdef gc_cut
										get(unsigned char, ppc, envSize);
#else
										++ppc;
#endif
							namedCut:
										while (isVAR(regs[1])) {
											register long l = derefVAR(regs[1]);
											if (l EQ regs[1]) goto Fail;
											regs[1] = l;
											}
										l = ce;
										while (regs[1] NE env(l, NAME)) {
											if (l EQ env(l, CE)) { ERROR(NAMEDCUTNOTFOUND); }
											l = env(l, CE);
											}
										a = regs[1];
							finishNamedCut:
										if (env(l, CUTB) GT (long)lcp) { 
											lcp = (choicepoint *)env(l, CUTB);
											resetCritical(tcb);
#ifdef gc_cut
											if ((!res) && (BNRP_gcFlag) && ((long)lcp NE tcb->cpbase) &&((hp - lcp->hp) GT BNRP_gcFlag))
												BNRP_gc(envSize, lcp, &hp, ce, te);
#endif
											}
										/* update all envs up till this name to reflect new lcp */
										l = ce;
										while (a NE env(l, NAME)) {
											env(l, CUTB) = (long)lcp;
											l = env(l, CE);
											}
										if (res) goto Fail;
										break;
							case 0x36:						/* failexit(name) */
										res = TRUE;
										tcb->procname = cutFailAtom;
										goto namedCut;

							case 0x37:						/* label_env */
										/* special opcode, generated by inline code */
										/* reg[2] names the current environment */
										l = regs[2];
										while (isVAR(l)) {
											register long t = derefVAR(l);
											if (l EQ t) break;
											l = t;
											}
										if (tagof(l) EQ SYMBOLTAG) {
											e(NAME) = l;
											}
										break;
							case 0x40:						/* testt(T) */
										get(unsigned char, ppc, r);
							case 0x41:
							case 0x42:
							case 0x43:
							case 0x44:
							case 0x45:
							case 0x46:
							case 0x47:
										l = regs[r];
							test:
										get(unsigned char, ppc, c);		/* mask */
										while (tagof(l) EQ TVTAG) {
											addr = addrof(l);		/* isolate address */
											a = *(long *)addr;			/* get what tailvar points at */
											if (l EQ a) goto Fail;		/* if tailvar then fail */
											l = a;
											}
										while (isVAR(l)) {
											register long a = derefVAR(l);
											if (l EQ a) goto Fail;		/* must be a variable */
											l = a;
											}
										/* know we have a non-var, check against mask */
										/* mask bits are ?, ?, ?, fp, int, sym, str, list */
										if (l & 0x40000000) {				/* bits 11.... */
											if (l & 0x20000000) {			/* bits 111..., symbol*/
												if (c & 0x04) break;
												}
											else {							/* bits 110.., int */
												if (c & 0x08) break;
												}
											}
										else {								/* bits 10.... */
											if (l & 0x20000000) {			/* bits 101..., list */
												if (c & 0x01) break;
												}
											else {							/* bits 100..., struct */
												long a;
												li t;
											
												a = addrof(l);
												get(long, a, t.l);
												if (t.i.a EQ NUMBERIDshort) {
													if (t.i.b EQ INTIDshort) {
														if (c & 0x08) break;
														}
													else if (t.i.b EQ FLOATIDshort) {
														if (c & 0x10) break;
														}
													}
												else 
													if (c & 0x02) break;
												}
											}
										goto Fail;

							case 0x48:						/* testp(P) */
										get(unsigned char, ppc, P);
							case 0x49:
							case 0x4A:
							case 0x4B:
							case 0x4C:
							case 0x4D:
							case 0x4E:
							case 0x4F:
#ifdef check
										if (P LE 0) DEBUGSTR("testp");
#endif
										l = e(P);
										goto test;

							case 0x38:
							case 0x39:
							case 0x3A:
							case 0x3B:
							case 0x3C:
							case 0x3D:
							case 0x3E:
							case 0x3F:
                                /* 
                                 * BODY ESCAPE 0x38 - 0x3F
                                 * Feb 1996 modified by yanzhou@bnr.ca
                                 * WAS: putunsaf
                                 * NOW: unused
                                 */
                                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in BODY ESCAPE.\n", c);
                                goto Fail;
                                break;

							case 0x88:
							case 0x89:	
							case 0x8A:	
							case 0x8B:	
							case 0x8C:	
							case 0x8D:	
							case 0x8E:	
							case 0x8F:
                                /*
                                 * BODY ESCAPE 0x88 - 0x8F
                                 * Feb 1996 modified by yanzhou@bnr.ca
                                 * WAS: push_unsaft
                                 * NOW: unused
                                 */
                                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in BODY ESCAPE.\n", c);
                                goto Fail;
                                break;

							case 0x50:			/* pop_valt(T) */
										get(unsigned char, ppc, r);
							case 0x51:	
							case 0x52:	
							case 0x53:	
							case 0x54:	
							case 0x55:	
							case 0x56:	
							case 0x57:	
										l = regs[r];
							checkAnswer:
										while (isVAR(l)) {
											register long val1 = derefVAR(l);
											if (l EQ val1) break;
											l = val1;
											}
										if (isVAR(l)) {
											/* l is an unbound var */
											popresult(val);
											if (((long *)addrof(l))[1] EQ CONSTRAINTMARK) {
												a = evalConstrainedAtom;
												arity = 2;
												regs[1] = l;
												regs[2] = val;
												goto completeCall;
												}
											++ppc;			/* skip save byte */
											if (!coreUnify(l, val)) goto Fail;
											break;
											}
										/* l is bound to something, coerce to == */
										++arTOS;
										if (tagof(l) EQ INTMASK) {
											li t;
											
											t.l = l;
											arTOS->type = 0;
											arTOS->value.l = t.i.b;
											}
										else if (tagof(l) EQ STRUCTTAG) {
											li arity;
											
											val = addrof(l);
											get(long, val, arity.l);
											if (arity.i.a EQ NUMBERIDshort)
												switch (arity.i.b) {
													case INTIDshort:
															arTOS->type = 0;
															get(long, val, arTOS->value.l);
															break;
													case FLOATIDshort:
															arTOS->type = 1;
															fpLWA(val);
															arTOS->value = *(lf *)val;
															break;
													default:
															goto Fail;
													}
											else
												goto Fail;
											}
										else
											goto Fail;
										compareop(EQ);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;

							case 0x58:			/* pop_valp(P) */
										get(unsigned char, ppc, P);
							case 0x59:	
							case 0x5a:	
							case 0x5b:	
							case 0x5c:	
							case 0x5d:	
							case 0x5e:	
							case 0x5f:	
#ifdef check
										if (P LE 0) DEBUGSTR("pop_valp");
#endif
										l = e(P);
										goto checkAnswer;

							case 0x04:					/* eval_cons(C) */
										constantLWA(ppc);
										get(long, ppc, val);
										goto decoded;
							case 0x60:			/* evalt(T) */
										get(unsigned char, ppc, T);
							case 0x61:	
							case 0x62:	
							case 0x63:	
							case 0x64:	
							case 0x65:	
							case 0x66:	
							case 0x67:	
										val = regs[T];
										goto decode;
							case 0x68:			/* evalp(P) */
										get(unsigned char, ppc, P);
							case 0x69:	
							case 0x6a:	
							case 0x6b:	
							case 0x6c:	
							case 0x6d:	
							case 0x6e:	
							case 0x6f:	
#ifdef check
										if (P LE 0) DEBUGSTR("evalp");
#endif
										val = e(P);
							decode:
										while (isVAR(val)) {
											register long l = derefVAR(val);
											if (l EQ val) goto stackArguments;
											val = l;
											}
							decoded:
										if (tagof(val) EQ INTMASK) {
											li t;
											
											t.l = val;
											++arTOS;
											arTOS->type = 0;
											arTOS->value.l = t.i.b;
#if INTMASK NE 0xC0000000
											error
#endif
#ifdef arithdebug
											printf("pushing short %ld\n", arTOS->value.l);
#endif
											goto escapeAgain;
											}
										else {
											register struct arith *arp;
											li arity;
																					
											if (tagof(val) EQ STRUCTTAG) {
												val = addrof(val);
												get(long, val, arity.l);
												if (arity.i.a EQ NUMBERIDshort)
													switch (arity.i.b) {
														case INTIDshort:
																++arTOS;
																arTOS->type = 0;
																get(long, val, arTOS->value.l);
#ifdef arithdebug
																printf("pushing long %ld\n", arTOS->value.l);
#endif
																goto escapeAgain;
														case FLOATIDshort:
																++arTOS;
																arTOS->type = 1;
																fpLWA(val);
																arTOS->value = *(lf *)val;
#ifdef arithdebug
																printf("pushing fp %f\n", arTOS->value.f);
#endif
																goto escapeAgain;
														}
												}
							stackArguments:
											arp = ar;
											while (arp LE arTOS) {
												heapcheck(12);
												arp->value.l = (arp->type) ?
																makefloat(&hp, &arp->value.f) :
																makeint(&hp, arp->value.l);
												++arp;
												}
											/* back up ppc if we pointed to a multiple byte instruction */
											if ((c EQ 0x60) || (c EQ 0x68))
												--ppc;
											else if (c EQ 0x04)
												ppc -= sizeof(long);
											goto MetaArithmetic;
											}
							case 0x70:			/* pop_vart(T) */
										get(unsigned char, ppc, T);
							case 0x71:	
							case 0x72:	
							case 0x73:	
							case 0x74:	
							case 0x75:	
							case 0x76:	
							case 0x77:
										++ppc;			/* skip save byte */
										popresult(val);
										regs[T] = val;
										break;
							case 0x78:			/* pop_valp(P) */
										get(unsigned char, ppc, P);
							case 0x79:	
							case 0x7a:	
							case 0x7b:	
							case 0x7c:	
							case 0x7d:	
							case 0x7e:	
							case 0x7f:
										++ppc;			/* skip save byte */
										popresult(val);
#ifdef check
										if (P LE 0) DEBUGSTR("pop_valp");
										if (tagof(val) EQ TVTAG) printf("Unexpected TV in pop_valp\n");
#endif
										e(P) = val;
										break;
												
							case 0x99:							/* addition */
										binaryoplfff(+);
										goto escapeAgain;
							case 0x9A:							/* subtraction */
										binaryoplfff(-);
										goto escapeAgain;
							case 0x9B:							/* multiplication */
										binaryoplfff(*);
										goto escapeAgain;
							case 0x9C:							/* integer division */
										if (arTOS LE ar) goto Fail; /* need two elements */
										--arTOS;
										if (arTOS[1].type) {
											if (arTOS[1].value.f EQ 0.0) { ERROR(DIVIDEBY0); }
											if (arTOS->type)
												arTOS->value.l = arTOS->value.f / arTOS[1].value.f;
											else
												arTOS->value.l = arTOS->value.l / arTOS[1].value.f;
											}
										else {
											if (arTOS[1].value.l EQ 0) { ERROR(DIVIDEBY0); }
											if (arTOS->type)
												arTOS->value.l = arTOS->value.f / arTOS[1].value.l;
											else
												arTOS->value.l = arTOS->value.l / arTOS[1].value.l;
											}
										arTOS->type = 0;
										goto escapeAgain;
							case 0x9D:							/* regular division */
										if (arTOS LE ar) goto Fail;	/* need two elements */
										--arTOS;
										if (arTOS[1].type) {
											if (arTOS[1].value.f EQ 0.0) { ERROR(DIVIDEBY0); }
											if (arTOS->type)
												arTOS->value.f = arTOS->value.f / arTOS[1].value.f;
											else
												arTOS->value.f = (fp)arTOS->value.l / arTOS[1].value.f;
											}
										else {
											if (arTOS[1].value.l EQ 0) { ERROR(DIVIDEBY0); }
											if (arTOS->type)
												arTOS->value.f = arTOS->value.f / (fp)arTOS[1].value.l;
											else
												arTOS->value.f = (fp)arTOS->value.l / (fp)arTOS[1].value.l;
											}
										arTOS->type = 1;
										goto escapeAgain;
							case 0x9E:							/* mod */
										if (arTOS LE ar) goto Fail; /* need two elements */
										if (arTOS->type) goto Fail;
										--arTOS;
										if (arTOS->type) goto Fail;
										arTOS->value.l %= arTOS[1].value.l;
										goto escapeAgain;
							case 0x9F:							/* ** */
										if (arTOS LE ar) goto Fail; /* need two elements */
										--arTOS;
										if (arTOS[1].type) {
											if (arTOS->type)
												arTOS->value.f = pow(arTOS->value.f, arTOS[1].value.f);
											else {
												arTOS->value.f = pow((fp)arTOS->value.l, arTOS[1].value.f);
												arTOS->type = 1;
												}
											}
										else {
											if (arTOS->type)
												arTOS->value.f = pow(arTOS->value.f, (fp)arTOS[1].value.l);
											else
												arTOS->value.l = pow((fp)arTOS->value.l, (fp)arTOS[1].value.l);
											}
										goto escapeAgain;
							case 0xA9:							/* int */
										if (arTOS->type) {
											arTOS->type = 0;
											arTOS->value.l = arTOS->value.f;
											}
										goto escapeAgain;
							case 0xAA:							/* float */
										if (!arTOS->type) {
											arTOS->type = 1;
											arTOS->value.f = (fp)arTOS->value.l;
											}
										goto escapeAgain;
							case 0xAB:							/* floor */
										unaryopint(floor);
										goto escapeAgain;
							case 0xAC:							/* ceiling */
										unaryopint(ceil);
										goto escapeAgain;
							case 0xAD:							/* round */
										if (arTOS->type) {
											arTOS->type = 0;
											if (arTOS->value.f LT 0)
												arTOS->value.l = arTOS->value.f - 0.5;
											else
												arTOS->value.l = arTOS->value.f + 0.5;
											}
										goto escapeAgain;
							case 0xAE:							/* max */
										compareop(LT);
										if (res) {
											arTOS[-1].value = arTOS->value;
											arTOS[-1].type = arTOS->type;
											}
										--arTOS;
										goto escapeAgain;
							case 0xAF:							/* min */
										compareop(GT);
										if (res) {
											arTOS[-1].value = arTOS->value;
											arTOS[-1].type = arTOS->type;
											}
										--arTOS;
										goto escapeAgain;
							case 0xB9:							/* sqrt */
										unaryopfloat(sqrt);
										goto escapeAgain;
							case 0xBA:							/* abs */
										if (arTOS LT ar) goto Fail;
										if (arTOS->type)
											arTOS->value.f = fabs(arTOS->value.f);
										else if (arTOS->value.l LT 0)
											arTOS->value.l = -arTOS->value.l;
										goto escapeAgain;
							case 0xBB:							/* exp */
										unaryopfloat(exp);
										goto escapeAgain;
							case 0xBC:							/* ln */
										unaryopfloat(log);
										goto escapeAgain;
							case 0xBD:							/* increment */
										if (arTOS LT ar) goto Fail;
										if (arTOS->type)
											++arTOS->value.f;
										else
											++arTOS->value.l;
										goto escapeAgain;
							case 0xBE:							/* decrement */
										if (arTOS LT ar) goto Fail;
										if (arTOS->type)
											--arTOS->value.f;
										else
											--arTOS->value.l;
										goto escapeAgain;
							case 0xBF:							/* negate */
										if (arTOS LT ar) goto Fail;
										if (arTOS->type)
											arTOS->value.f = -arTOS->value.f;
										else
											arTOS->value.l = -arTOS->value.l;
										goto escapeAgain;
							case 0xC9:							/* sin */
										unaryopfloat(sin);
										goto escapeAgain;
							case 0xCA:							/* cos */
										unaryopfloat(cos);
										goto escapeAgain;
							case 0xCB:							/* tan */
										unaryopfloat(tan);
										goto escapeAgain;
							case 0xCC:							/* asin */
										unaryopfloat(asin);
										goto escapeAgain;
							case 0xCD:							/* acos */
										unaryopfloat(acos);
										goto escapeAgain;
							case 0xCE:							/* atan */
										unaryopfloat(atan);
										goto escapeAgain;
							case 0xD9:							/* == */
										compareop(EQ);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xDA:							/* =< */
										compareop(LE);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xDB:							/* >= */
										compareop(GE);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xDC:							/* < */
										compareop(LT);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xDD:							/* > */
										compareop(GT);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xDE:							/* <> */
										compareop(NE);
										arTOS -= 2;
										if (!res) goto Fail;
										++ppc;			/* skip save byte */
										break;
							case 0xE9:							/* maxint */
										++arTOS;
										arTOS->type = 0;
										arTOS->value.l = BNRP_getMaxLong();
										goto escapeAgain;
							case 0xEA:							/* maxfloat */
										++arTOS;
										arTOS->type = 1;
										arTOS->value.f = BNRP_getMaxFP();
										goto escapeAgain;
							case 0xEB:							/* pi */
										++arTOS;
										arTOS->type = 1;
										arTOS->value.f = M_PI;
										goto escapeAgain;
							case 0xEC:							/* cputime */
										++arTOS;
										arTOS->type = 0;
										arTOS->value.l = getCPUTime();
							case NOOP:							/* NOP must loop around */
										goto escapeAgain;

                            case 0xCF:          /* binary butnot    */
                                        if (arTOS LE ar) goto Fail; /* 2 elements      */
                                        --arTOS;
                                        if (arTOS->type || arTOS[1].type) goto Fail;
                                        arTOS->value.l &= (~ arTOS[1].value.l);
                                        goto escapeAgain;

                            case 0xDF:          /* binary bitshift */
                                        if (arTOS LE ar) goto Fail; /* 2 elements      */
                                        --arTOS;
                                        if (arTOS->type || arTOS[1].type) goto Fail;
                                        else {
                                            long  bits = arTOS[1].value.l;

                                            if (bits GE 0) {
                                                if (bits GE sizeof(long)*8)
                                                    arTOS->value.l = 0;
                                                else
                                                    arTOS->value.l = (unsigned long)arTOS->value.l << bits;
                                            } else {
                                                bits = -bits;
                                                if (bits GE sizeof(long)*8)
                                                    arTOS->value.l = 0;
                                                else
                                                    arTOS->value.l = (unsigned long)arTOS->value.l >> bits;
                                            }
                                        }
                                        goto escapeAgain;

                            case 0xED:          /* binary bitand */
                                        if (arTOS LE ar) goto Fail; /* 2 elements      */
                                        --arTOS;
                                        if (arTOS->type || arTOS[1].type) goto Fail;
                                        arTOS->value.l &= arTOS[1].value.l;
                                        goto escapeAgain;

                            case 0xEE:          /* binary bitor  */
                                        if (arTOS LE ar) goto Fail; /* 2 elements      */
                                        --arTOS;
                                        if (arTOS->type || arTOS[1].type) goto Fail;
                                        arTOS->value.l |= arTOS[1].value.l;
                                        goto escapeAgain;

                            case 0xEF:          /* binary biteq */
                                        if (arTOS LE ar) goto Fail; /* 2 elements      */
                                        --arTOS;
                                        if (arTOS->type || arTOS[1].type) goto Fail;
                                        arTOS->value.l = ~(arTOS->value.l ^ arTOS[1].value.l);
                                        goto escapeAgain;

                            case 0xF8:          /* unary ~      */
                                        if (arTOS LT ar) goto Fail; /* 1 element       */
                                        if (arTOS->type) goto Fail;
                                        if (arTOS->value.l EQ 0)
                                            arTOS->value.l = 1;
                                        else if (arTOS->value.l EQ 1)
                                            arTOS->value.l = 0;
                                        else
                                            goto Fail;
                                        goto escapeAgain;
 
                            case 0xF9:          /* binary and   */
                                        binaryboolop(&);
                                        goto escapeAgain;
 
                            case 0xFA:          /* binary or    */
                                        binaryboolop(|);
                                        goto escapeAgain;
 
                            case 0xFB:          /* binary xor   */
                                        binaryboolop(^);
                                        goto escapeAgain;
 
                            case 0xFC:          /* binary ->    */
                                        binaryboolop(<=);
                                        goto escapeAgain;
 
							case 0xFD:							/* relation == */
										compareop(EQ);
										arTOS --;
                                        arTOS->type    = 0;
                                        arTOS->value.l = res;
                                        goto escapeAgain;
 
							case 0xFE:							/* relation >  */
										compareop(GT);
										arTOS --;
                                        arTOS->type    = 0;
                                        arTOS->value.l = res;
                                        goto escapeAgain;
 
							case 0xFF:							/* relation <  */
										compareop(LT);
										arTOS --;
                                        arTOS->type    = 0;
                                        arTOS->value.l = res;
                                        goto escapeAgain;
 
							default:
										if ((c & 0x88) EQ 0x80) {		/* put_vart(T, R) */
											int t;
											
											if (r EQ 0) { get(unsigned char, ppc, r); }
											t = (c >> 4) & 0x07;
											if (t EQ 0) { get(unsigned char, ppc, t); }
											heapcheck(1);
											push(long, hp, regs[r] = regs[t] = makevarterm(hp));
											*(long *)hp = 0;			/* clear in case of constraint marker */
											}
										else {
#ifdef check
											printf("Unimplemented escape sequence %02X in body\n", c);
#endif
											goto Fail;
											}
										break;
								}	/* case */
							break;
							
					escapeAgain:
#ifdef check
							if ((ppc GE heapbase) && (ppc LE tcb->cpbase)) {
								printf("\n\nHelp in escapeagain, c = %d, ppc = %08lX in heap\n\n", c, ppc);
								ERROR(-4);
								}
#endif
							if (errno NE 0) {
								if ((errno EQ ERANGE) || (errno EQ EDOM)) ERROR(ARITHERROR);
								errno = 0;
								}

							get(unsigned char, ppc, c);
							}	/* for */
						else 
					MetaArithmetic:	
						for (;;) {		/* inClause */
#ifdef DEBUG
							printf("Executing clause$$ escape byte %02X at %p\n", c, ppc-1);
#endif
							/* ++escapeCount[c]; */
							r = c & 0x07;
							switch (c) {
							case 0:		SaveRegisters(10); 
										tcb->ppsw = 0;
										memcpy(jumpbuf, oldjumpbuf, sizeof(jmp_buf));
                                        BNRP_installSighandler(SIGINT,oldSigIntHandler);  /* Modified Oz 08/12/95 */
                                        BNRP_installSighandler(SIGFPE,oldSigFpeHandler);  /* Modified Oz 08/12/95 */

										return(0);
							case 0x01:						/* ecut */
										++ppc;
							case 0x02:						/* dcut */
										a = cutAtom;
										arity = 0;
										goto addClause;
							case 0x03:						/* push_nil */
										heapcheck(1);
										push(long, hp, emptyList);
										break;
							case 0x05:
										DEBUGSTR("Body escape 0705");
										break;
							case 0x0A:						/* call */
										get(char, ppc, arity);
										constantLWA(ppc);
										get(BNRP_term, ppc, a);
#ifdef DEBUG
										get(unsigned char, ppc, save);
										printf("Size of save is %d\n", save);
#else
										++ppc;				/* skip save byte */
#endif
										goto addClause;
							
							case 0xE6:						/* dcut, exec */
										*(long *)clauseList = maketerm(TVTAG, hp);
										push(long, hp, cutAtom);
   				                                                heapcheck(2);       /* NEW Jan. 1995 Jason Harris*/
										clauseList = hp;
										push(long, hp, 0);
							case 0x0C:						/* exec */
										get(char, ppc, arity);
										constantLWA(ppc);
										get(BNRP_term, ppc, a);
							addLastClause:
										inClause = FALSE;
										ppc = cp + 1;				/* proceed, skip save byte */
							addClause:
										if (arity GT 0) {
											long newterm;
											
											newterm = hp;
											heapcheck(arity + 5);
											push(long, hp, (FUNCID | (arity + 1)));
											push(long, hp, a);
											for (j = 1; j LE arity; ++j) {
												push(long, hp, regs[j]);
												}
											push(long, hp, 0);
											a = maketerm(STRUCTTAG, newterm);
											}
										else if (arity LT 0) {
											long newterm;
											li arity1;
											
											newterm = hp;
											heapcheck(5 - arity);
											arity1.i.a = FUNCIDshort;
											arity1.i.b = arity - 1;
											push(long, hp, arity1.l);
											push(long, hp, a);
											for (j = -1; j GT arity; --j) {
												push(long, hp, regs[-j]);
												}
											push(long, hp, maketerm(TVTAG, addrof(regs[-arity])));
											a = maketerm(STRUCTTAG, newterm);
											}
										*(long *)clauseList = maketerm(TVTAG, hp);
										push(long, hp, a);
										clauseList = hp;
										push(long, hp, 0);
										break;
										
							case 0x09:						/* call indirect */
#ifdef DEBUG
										get(unsigned char, ppc, save);
										printf("Size of save is %d\n", save);
#else
										++ppc;				/* skip save byte */
#endif
							finishClauseIndirect:
										arity = 0;
										a = regs[1];
										goto addClause;
							case 0x0B:						/* exec indirect */
										inClause = FALSE;
										goto finishClauseIndirect;
							case 0x0D:						/* call clause$$/3 */
										/* do normal call processing */
										++ppc;				/* skip save byte */
										a = clauseAtom;
										arity = 3;
										goto addClause;
							case 0x0E:						/* exec $$exec(address, [args]) */
										a = execAtom;
										arity = 2;
										goto addLastClause;

							case 0x0F:						/* fail */
										a = failAtom;
										arity = 0;
										goto addLastClause;

							case 0x10:						/* vart(T) */
										get(unsigned char, ppc, T);
							case 0x11:
							case 0x12:
							case 0x13:
							case 0x14:
							case 0x15:
							case 0x16:
							case 0x17:
										l = regs[T];
							constructvar:
										a = maketerm(STRUCTTAG, hp);
										arity = 0;
										heapcheck(4);
										push(long, hp, UNARYHEADER);
										push(long, hp, varAtom);
										push(long, hp, l);
										push(long, hp, 0);
										goto addClause;

							case 0x18:						/* varp(P) */
										get(unsigned char, ppc, P);
							case 0x19:
							case 0x1A:
							case 0x1B:
							case 0x1C:
							case 0x1D:
							case 0x1E:
							case 0x1F:
#ifdef check
										if (P LE 0) DEBUGSTR("varp");
#endif
										l = e(P);
										goto constructvar;

							case 0x20:						/* tvart(T) */
										get(unsigned char, ppc, T);
							case 0x21:
							case 0x22:
							case 0x23:
							case 0x24:
							case 0x25:
							case 0x26:
							case 0x27:
										l = regs[T];
							constructtv:
										l = maketerm(TVTAG, addrof(l));	/* convert from list to TV */
										a = maketerm(STRUCTTAG, hp);
										arity = 0;
										heapcheck(4);
										push(long, hp, UNARYHEADER);
										push(long, hp, tailvarAtom);
										push(long, hp, l);
										push(long, hp, 0);
										goto addClause;

							case 0x28:						/* tvarp(P) */
										get(unsigned char, ppc, P);
							case 0x29:
							case 0x2A:
							case 0x2B:
							case 0x2C:
							case 0x2D:
							case 0x2E:
							case 0x2F:
#ifdef check
										if (P LE 0) DEBUGSTR("tvarp");
#endif
										l = e(P);
										goto constructtv;

							
							case 0x30:						/* more_choicepoints */
										/* only generated by inline$, so why bother with it */
										break;
										
							case 0x31:						/* cCut */
										++ppc;
							case 0x98:						/* cCutsp */
							case 0x32:						/* cdCut */
										a = cutcutAtom;
										arity = 0;
										goto addClause;

							case 0x33:						/* cCutFail */
							case 0x34:						/* cdCutFail */
										a = cutFailAtom;
										arity = 0;
										goto addLastClause;

							case 0x35:						/* cut(name) */
										++ppc;
										a = cutcutAtom;
										arity = 1;
										goto addClause;

							case 0x36:						/* failexit(name) */
										a = cutFailAtom;
										arity = 1;
										goto addClause;

							case 0x37:						/* label_env */
										/* name never used in clause mode, so why bother */
										break;
							
							case 0x40:						/* testt(T) */
										get(unsigned char, ppc, T);
							case 0x41:
							case 0x42:
							case 0x43:
							case 0x44:
							case 0x45:
							case 0x46:
							case 0x47:
										l = regs[T];
							constructFilter:
										get(unsigned char, ppc, c);
										a = maketerm(STRUCTTAG, hp);
										arity = 0;
										heapcheck(4);
										push(long, hp, UNARYHEADER);
										push(long, hp, BNRP_filterNames[c]);
										push(long, hp, l);
										push(long, hp, 0);
										goto addClause;

							case 0x48:						/* testp(P) */
										get(unsigned char, ppc, P);
							case 0x49:
							case 0x4A:
							case 0x4B:
							case 0x4C:
							case 0x4D:
							case 0x4E:
							case 0x4F:
#ifdef check
										if (P LE 0) DEBUGSTR("testp");
#endif
										l = e(P);
										goto constructFilter;

							case 0x38:
							case 0x39:
							case 0x3A:
							case 0x3B:
							case 0x3C:
							case 0x3D:
							case 0x3E:
							case 0x3F:
                                /* 
                                 * BODY ESCAPE (InClause) 0x38 - 0x3F
                                 * Feb 1996 modified by yanzhou@bnr.ca
                                 * WAS: putunsaf
                                 * NOW: unused
                                 */
                                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in BODY ESCAPE (InClause).\n", c);
                                goto failClause;
                                break;

							case 0x88:
							case 0x89:	
							case 0x8A:	
							case 0x8B:	
							case 0x8C:	
							case 0x8D:	
							case 0x8E:	
							case 0x8F:	
                                /*
                                 * BODY ESCAPE (InClause) 0x88 - 0x8F
                                 * Feb 1996 modified by yanzhou@bnr.ca
                                 * WAS: push_unsaft
                                 * NOW: unused
                                 */
                                printf("BNRP_RESUME(): unimplemented opcode 0x%02x in BODY ESCAPE (InClause).\n", c);
                                goto failClause;
                                break;

							case 0x50:			/* pop_valt(T) */
										get(unsigned char, ppc, T);
							case 0x51:	
							case 0x52:	
							case 0x53:	
							case 0x54:	
							case 0x55:	
							case 0x56:	
							case 0x57:	
										at = isAtom; 
										reg = regs[T];
										goto arithADDCLAUSE;
							case 0x58:			/* pop_valp(P) */
										get(unsigned char, ppc, P);
							case 0x59:	
							case 0x5a:	
							case 0x5b:	
							case 0x5c:	
							case 0x5d:	
							case 0x5e:	
							case 0x5f:	
										at = isAtom; 
#ifdef check
										if (P LE 0) DEBUGSTR("pop_valp");
#endif
										reg = e(P);
										goto arithADDCLAUSE;
							case 0x04:			/* eval_cons(C) */
										constantLWA(ppc);
										++arTOS;
										get(long, ppc, arTOS->value.l);
							case NOOP:			/* NOP must loop around */
										goto arithNONE;
							case 0x60:			/* evalt(T) */
										get(unsigned char, ppc, T);
							case 0x61:	
							case 0x62:	
							case 0x63:	
							case 0x64:	
							case 0x65:	
							case 0x66:	
							case 0x67:	
										++arTOS;
										arTOS->value.l = regs[T];
										goto arithNONE;
							case 0x68:			/* evalp(P) */
										get(unsigned char, ppc, P);
							case 0x69:	
							case 0x6a:	
							case 0x6b:	
							case 0x6c:	
							case 0x6d:	
							case 0x6e:	
							case 0x6f:	
										++arTOS;
#ifdef check
										if (P LE 0) DEBUGSTR("evalp");
#endif
										arTOS->value.l = e(P);
										goto arithNONE;
							case 0x70:			/* pop_vart(T) */
										get(unsigned char, ppc, T);
							case 0x71:	
							case 0x72:	
							case 0x73:	
							case 0x74:	
							case 0x75:	
							case 0x76:	
							case 0x77:
										at = isAtom; 
										heapcheck(1);
										push(long, hp, reg = regs[T] = makevarterm(hp));
										*(long *)hp = 0;			/* clear in case of constraint marker */
										goto arithADDCLAUSE;
							case 0x78:			/* pop_valp(P) */
										get(unsigned char, ppc, P);
							case 0x79:	
							case 0x7a:	
							case 0x7b:	
							case 0x7c:	
							case 0x7d:	
							case 0x7e:	
							case 0x7f:
										at = isAtom; 
#ifdef check
										if (P LE 0) DEBUGSTR("pop_valp");
#endif
										heapcheck(1);
										push(long, hp, reg = e(P) = makevarterm(hp));
										*(long *)hp = 0;			/* clear in case of constraint marker */
										goto arithADDCLAUSE;
							case 0x99:							/* addition */
										binaryarithop(plusAtom);
										goto arithBINARY;
							case 0x9A:							/* subtraction */
										binaryarithop(minusAtom);
										goto arithBINARY;
							case 0x9B:							/* multiplication */
										binaryarithop(starAtom);
										goto arithBINARY;
							case 0x9C:							/* integer division */
										binaryarithop(slashslashAtom);
										goto arithBINARY;
							case 0x9D:							/* regular division */
										binaryarithop(slashAtom);
										goto arithBINARY;
							case 0x9E:							/* mod */
										binaryarithop(modAtom);
										goto arithBINARY;
							case 0x9F:							/* ** */
										binaryarithop(starstarAtom);
										goto arithBINARY;
							case 0xA9:							/* int */
										unaryarithop(intAtom);
										goto arithUNARY;
							case 0xAA:							/* float */
										unaryarithop(floatAtom);
										goto arithUNARY;
							case 0xAB:							/* floor */
										unaryarithop(floorAtom);
										goto arithUNARY;
							case 0xAC:							/* ceiling */
										unaryarithop(ceilAtom);
										goto arithUNARY;
							case 0xAD:							/* round */
										unaryarithop(roundAtom);
										goto arithUNARY;
							case 0xAE:							/* max */
										binaryarithop(maxAtom);
										goto arithBINARY;
							case 0xAF:							/* min */
										binaryarithop(minAtom);
										goto arithBINARY;
							case 0xB9:							/* sqrt */
										unaryarithop(sqrtAtom);
										goto arithUNARY;
							case 0xBA:							/* abs */
										unaryarithop(absAtom);
										goto arithUNARY;
							case 0xBB:							/* exp */
										unaryarithop(expAtom);
										goto arithUNARY;
							case 0xBC:							/* ln */
										unaryarithop(lnAtom);
										goto arithUNARY;
							case 0xBD:							/* increment */
										++arTOS;
										heapcheck(2);
										arTOS->value.l = makeint(&hp, 1);
										binaryarithop(plusAtom);
										goto arithBINARY;
							case 0xBE:							/* decrement */
										++arTOS;
										heapcheck(2);
										arTOS->value.l = makeint(&hp, 1);
										binaryarithop(minusAtom);
										goto arithBINARY;
							case 0xBF:							/* negate */
										unaryarithop(minusAtom);
										goto arithUNARY;
							case 0xC9:							/* sin */
										unaryarithop(sinAtom);
										goto arithUNARY;
							case 0xCA:							/* cos */
										unaryarithop(cosAtom);
										goto arithUNARY;
							case 0xCB:							/* tan */
										unaryarithop(tanAtom);
										goto arithUNARY;
							case 0xCC:							/* asin */
										unaryarithop(asinAtom);
										goto arithUNARY;
							case 0xCD:							/* acos */
										unaryarithop(acosAtom);
										goto arithUNARY;
							case 0xCE:							/* atan */
										unaryarithop(atanAtom);
										goto arithUNARY;
							case 0xD9:							/* == */
										comparearithop(eqAtom);
										goto arithCOMPARE;
							case 0xDA:							/* =< */
										comparearithop(leAtom);
										goto arithCOMPARE;
							case 0xDB:							/* >= */
										comparearithop(geAtom);
										goto arithCOMPARE;
							case 0xDC:							/* < */
										comparearithop(ltAtom);
										goto arithCOMPARE;
							case 0xDD:							/* > */
										comparearithop(gtAtom);
										goto arithCOMPARE;
							case 0xDE:							/* <> */
										comparearithop(neAtom);
										goto arithCOMPARE;
							case 0xE9:							/* maxint */
										constantarithop(maxintAtom);
										goto arithCONSTANT;
							case 0xEA:							/* maxfloat */
										constantarithop(maxfloatAtom);
										goto arithCONSTANT;
							case 0xEB:							/* pi */
										constantarithop(piAtom);
										goto arithCONSTANT;
							case 0xEC:							/* cputime */
										constantarithop(cputimeAtom);
										goto arithCONSTANT;
							case 0xCF:                          /* butnot   */  
										binaryarithop(butnotAtom);
										goto arithBINARY;
							case 0xDF:                          /* bitshift */
										binaryarithop(bitshiftAtom);
										goto arithBINARY;
							case 0xED:                          /* bitand */
										binaryarithop(bitandAtom);
										goto arithBINARY;
							case 0xEE:                          /* bitor */
										binaryarithop(bitorAtom);
										goto arithBINARY;
							case 0xEF:                          /* biteq */
										binaryarithop(biteqAtom);
										goto arithBINARY;
							case 0xF8:                          /* ~     */
										unaryarithop(boolnotAtom);
										goto arithUNARY;
							case 0xF9:                          /* and   */
										binaryarithop(boolandAtom);
										goto arithBINARY;
							case 0xFA:                          /* or    */
										binaryarithop(boolorAtom);
										goto arithBINARY;
							case 0xFB:                          /* xor   */
										binaryarithop(boolxorAtom);
										goto arithBINARY;
							case 0xFC:                          /* ->    */
										binaryarithop(ifAtom);
										goto arithBINARY;
							case 0xFD:                          /* relation == */
										binaryarithop(eqAtom);
										goto arithBINARY;
 
							case 0xFE:                          /* relation >  */
										binaryarithop(gtAtom);
										goto arithBINARY;
 
							case 0xFF:                          /* relation <  */
										binaryarithop(ltAtom);
										goto arithBINARY;

							default:
										if ((c & 0x88) EQ 0x80) {		/* put_vart(T, R) */
											int t;
											
											if (r EQ 0) { get(unsigned char, ppc, r); }
											t = (c >> 4) & 0x07;
											if (t EQ 0) { get(unsigned char, ppc, t); }
											heapcheck(1);
											push(long, hp, regs[r] = regs[t] = makevarterm(hp));
											*(long *)hp = 0;			/* clear in case of constraint marker */
											}
										else {
#ifdef check
											printf("Unimplemented escape sequence %02X in clause mode\n", c);
#endif
											}
										break;
								}  /* case */
							break;
							
					arithBINARY: {
							if (arTOS LE ar) goto failClause;
							val = maketerm(STRUCTTAG, hp);
							heapcheck(5);
							push(long, hp, BINARYHEADER);
							push(long, hp, at);
							push(long, hp, arTOS[-1].value.l);
							push(long, hp, arTOS[0].value.l);
							push(long, hp, 0);
							--arTOS;
							arTOS->value.l = val;
							}
							goto arithNONE;
					
					arithUNARY: {
							if (arTOS LT ar) goto failClause;
							val = maketerm(STRUCTTAG, hp);
							heapcheck(4);
							push(long, hp, UNARYHEADER);
							push(long, hp, at);
							push(long, hp, arTOS->value.l);
							push(long, hp, 0);
							arTOS->value.l = val;
							}
							goto arithNONE;

					failClause:
							a = eofAtom;
							arity = 0;
							goto addLastClause;
							
					arithADDCLAUSE:
					arithCOMPARE: {
							if (!inClause) {
								a = at;
								arity = 2;
								regs[1] = reg;
								regs[2] = arTOS->value.l;
								goto completeCall;
								}
							a = maketerm(STRUCTTAG, hp);
							heapcheck(7);
							push(long, hp, BINARYHEADER);
							push(long, hp, at);
							push(long, hp, reg);
							push(long, hp, arTOS->value.l);
							push(long, hp, 0);
							
							*(long *)clauseList = maketerm(TVTAG, hp);
							push(long, hp, a);
							clauseList = hp;
							push(long, hp, 0);
							++ppc;			/* skip save byte */
							}
							break;

					arithCONSTANT:
					arithNONE:
#ifdef check
							if ((ppc GE heapbase) && (ppc LE tcb->cpbase)) {
								printf("\n\nHelp in arithnone, c = %d, ppc = %08lX in heap\n\n", c, ppc);
								ERROR(-5);
								}
#endif
							get(unsigned char, ppc, c);
							}
						}
						break;

			}
		}
	
Fail:
#ifdef TRACE
	traceit("FAIL ");
#endif
#ifdef profile
	asm("   .reserve        .FAIL., 4, \"data\", 4");
	asm("M.FAIL:");
	asm("   sethi   %hi(.FAIL.), %o0");
	asm("   call    mcount");
	asm("   or      %o0, %lo(.FAIL.), %o0");
#endif
	/* no more constraints. bit may be set, but we will check this anyway */
	BNRPconstraintHeader = 0;

	if (((long)lcp EQ tcb->cpbase) || ((long)lcp EQ 0)) {  /* wjo sept 94 */
		if(tcb->invoker NE NULL) {
			res = BNRP_removeTaskFromChain(&tcb);
			goto RetPrim;
			}
		ERROR(OUTOFCHOICEPOINTS);
		}
	if (lcp->clp EQ 0) {
		lcp = lcp->lcp;
		goto Fail;
		}
#ifndef cp_full
	/* if we created cp just using nextSameKeyClause, then we need to do */
	/* a full check to find a match on arity, ... */
	if ((lcp->clp = (long)NextClause((clauseEntry *)(lcp->clp), lcp->key, lcp->numRegs)) EQ (long)NULL) {
		/* dummy choicepoint, doesn't point to anything useful, so remove it and try again */
		lcp = lcp->lcp;				
		goto Fail;
		}
#endif
	hp = criticalhp = lcp->hp;
	while (te LT lcp->te) {
		untrail(te, val);
		}
	criticalenv = lcp->critical;
	ppc = (lcp->clp + sizeof(clauseEntry));
	ce = lcp->bce;
	cp = lcp->bcp;
#ifdef check
	if ((cp GE heapbase) && (cp LE tcb->cpbase)) {
		printf("\n\nHelp from fail, cp = %08lX in heap\n\n", cp);
		ERROR(-3);
		}
#endif
#ifdef executiontrace
/*
	if (tcb->procname NE lcp->procname) {
		printf("FAIL: %s(...)\n", nameof(tcb->procname)); 
		fflush(stdout);
		} */
#endif
	cutb = lcp->lcp;		/* was lcp->cutb before, appears not needed */
	tcb->procname = lcp->procname;
	callerArity = lcp->numRegs;
	calleeArity = ((clauseEntry *)(lcp->clp))->arity;
	if ((l = callerArity) LT 0) l = -l;
	for (j = 1; j LE l; ++j)
		regs[j] = lcp->args[j];
#ifdef DEBUG
	printf("%%%%%%%%%% Trying new clause of goal %s (cp @ %08lX)\n", nameof(tcb->procname), (long)lcp);
	for (j = 1; j LE l; ++j) {
		printf("     ");
		BNRP_dumpArg(stdout, tcb, regs[j]);
		printf("\n");
		}
	printf("In fail, e @ %p, ppc = %p, new return addr = %p\n", ce, ppc, cp);
#else
#ifdef calldebug
	printf("Trying new clause of goal %s (cp @ %08lX)\n", nameof(tcb->procname), (long)lcp);
#endif
#endif
#ifdef executiontrace
	printf("REDO: %s\n", nameof(tcb->procname)); /*
	printf("REDO: %s(", nameof(tcb->procname));
	BNRP_printTCB = tcb;
	for (j = 1; j LE l; ++j) { fflush(stdout); BNRP_dumpArg(stdout, tcb, regs[j]); if (j NE l) printf(", "); }
	printf(")\n");  */
#endif
#ifdef TRACE
	traceit("REDO %.50s\n", nameof(tcb->procname));
#endif

	/* see if a following clause is useable */
#ifdef cp_full
	if ((lcp->clp = (long)NextClause((clauseEntry *)(lcp->clp), lcp->key, lcp->numRegs)) EQ (long)NULL) {
#else
	lcp->clp = (long)((lcp->key) ? ((clauseEntry *)(lcp->clp))->nextSameKeyClause : 
								   ((clauseEntry *)(lcp->clp))->nextClause);
	if (lcp->clp EQ (long)NULL) {
#endif
		/* no more possible clauses, remove choicepoint for good */
		lcp = lcp->lcp;
		resetCritical(tcb);
		}
	goto Call;
	}
