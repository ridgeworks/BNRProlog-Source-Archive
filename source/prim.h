/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/prim.h,v 1.7 1997/11/21 14:29:16 harrisj Exp $
 *
 * $Log: prim.h,v $
 * Revision 1.7  1997/11/21  14:29:16  harrisj
 * New primitive called globalCounter(X) has been added.
 * X is unified with an integer that is incremented each time the
 * primitive is called.  X starts at zero.
 *
 * Revision 1.6  1997/08/12  17:35:14  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.5  1997/07/31  15:57:38  harrisj
 * Added BNRP_finite primitive to return whether or not
 * a number is finite.  Must use +DA1.1 to compile.
 *
 * Revision 1.4  1996/03/04  03:53:44  yanzhou
 * Improved substring() implementation for better performance.
 * Improved integer_range() implementation (cut before tail recursion).
 *
 * Revision 1.3  1996/02/08  05:03:17  yanzhou
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
 * Revision 1.3  1996/02/08  04:59:15  yanzhou
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
 * Revision 1.2  1996/02/01  03:29:50  yanzhou
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
 * Revision 1.1  1995/09/22  11:26:11  harrisja
 * Initial version.
 *
 *
 */
#ifndef _H_prim
#define _H_prim

extern BNRP_term	curlyAtom,			/* used by parser */
					commaAtom,
					cutAtom, 			/* used by clause$$ */
					cutcutAtom,
					cutFailAtom,
					isAtom,
					recoveryUnitAtom,
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
extern long BNRP_gcFlag;
extern long BNRP_intervalOperations, BNRP_intervalIterations;

BNRP_Boolean BNRPBindPrimitive(const char *name, BNRP_Boolean (*address)());
void BNRP_initializeGlobals(void);

/* ring 0 */
BNRP_Boolean BNRP_eCut(TCB *tcb);
BNRP_Boolean BNRP_fixCutb(TCB *tcb);
BNRP_Boolean BNRP_doError(TCB *tcb);
BNRP_Boolean BNRP_doGetErrorCode(TCB *tcb);
BNRP_Boolean BNRP_delay(TCB *tcb);
/* ring 1 */
BNRP_Boolean BNRP_newCounter(TCB *tcb);
BNRP_Boolean BNRP_incrCounter(TCB *tcb);
BNRP_Boolean BNRP_globalCounter(TCB *tcb);
BNRP_Boolean BNRP_freeze(TCB *tcb);
BNRP_Boolean BNRP_joinVar(TCB *tcb);
BNRP_Boolean BNRP_name(TCB *tcb);
BNRP_Boolean BNRP_concat(TCB *tcb);
BNRP_Boolean BNRP_substring(TCB *tcb);
BNRP_Boolean BNRP_strstr(TCB *tcb);
BNRP_Boolean BNRP_lowercase(TCB *tcb);
BNRP_Boolean BNRP_uppercase(TCB *tcb);
BNRP_Boolean BNRP_namelength(TCB *tcb);
BNRP_Boolean BNRP_gensym(TCB *tcb);
BNRP_Boolean BNRP_constrain(TCB *tcb);
BNRP_Boolean BNRP_getConstraint(TCB *tcb);
BNRP_Boolean BNRP_regularStatus(TCB *tcb);
BNRP_Boolean BNRP_memoryStatus(TCB *tcb);
/* ring 2 */
/* ring 3 */
/* ring 4 */
BNRP_Boolean BNRP_configuration(TCB *tcb);
BNRP_Boolean BNRP_setTrace(TCB *tcb);
BNRP_Boolean BNRP_setTraceAll(TCB *tcb);
BNRP_Boolean BNRP_setUnknown(TCB *tcb);
BNRP_Boolean BNRP_enableTrace(TCB *tcb);
BNRP_Boolean BNRP_goal(TCB *tcb);


BNRP_Boolean BNRP_getAddress(TCB *tcb);
BNRP_Boolean BNRP_getArity(TCB *tcb);
BNRP_Boolean BNRP_defineOperator(TCB *tcb);
BNRP_Boolean BNRP_retract(TCB *tcb);
BNRP_Boolean BNRP_set_gc(TCB *tcb);
BNRP_Boolean BNRP_enableTimer(TCB *tcb);
BNRP_Boolean BNRP_reEnableTimer(TCB *tcb);
BNRP_Boolean BNRP_readLocalTime(TCB *tcb);
BNRP_Boolean BNRP_dpprim(TCB *tcb);
BNRP_Boolean BNRP_examinefp(TCB *tcb);
BNRP_Boolean BNRP_finite(TCB *tcb);
extern long BNRP_MaxOperations, BNRP_IntervalIncrement, BNRP_IntervalDecrement;
BNRP_Boolean BNRP_setintervalconstraints(TCB *tcb);
BNRP_Boolean BNRP_replaceFloat(TCB *tcb);

long getCPUTime();
void BNRP_traceback(TCB *tcb, long numItems);
void BNRP_choicepoints(TCB *tcb, long numItems);

#define tracebackStrLen		500
extern char BNRP_lastErrorTraceback[tracebackStrLen];

extern long BNRP_intervalOperations, BNRP_intervalIterations;

#endif
