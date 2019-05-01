/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/utility.c,v 1.14 1998/06/05 06:07:55 csavage Exp $
*
*  $Log: utility.c,v $
 * Revision 1.14  1998/06/05  06:07:55  csavage
 * Addition of a stripQuotes primitive to allow the toggling
 * of how quotes are handled when capsAsVars is false.  The
 * default is to remove quotes - this allows quotes to be kept
 * for check utility.
 *
 * Revision 1.13  1998/03/31  11:19:50  csavage
 * added send/receive TCP/UDP bytes primitives
 *
 * Revision 1.12  1998/02/13  11:18:25  csavage
 * Added underscoreAsVariable primitive
 *
 * Revision 1.11  1997/12/22  17:01:46  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.10  1997/11/21  14:30:55  harrisj
 * New primitive gmtime added to return GMT
 *
 * Revision 1.9  1997/07/31  15:57:41  harrisj
 * Added BNRP_finite primitive to return whether or not
 * a number is finite.  Must use +DA1.1 to compile.
 *
 * Revision 1.8  1996/05/20  16:52:37  neilj
 * Added new primitives:
 *   $sendTCPterm for BNRP_sendTCPterm.
 *   $receiveTCPterm for BNRP_receiveTCPterm.
 *
 * Revision 1.7  1996/04/19  01:29:15  yanzhou
 * Added new primitives random/1 and randomseed/1 to BNRProlog ring 5.
 *
 * Revision 1.6  1996/03/04  03:53:45  yanzhou
 * Improved substring() implementation for better performance.
 * Improved integer_range() implementation (cut before tail recursion).
 *
 * Revision 1.5  1996/01/31  23:52:25  yanzhou
 * New time/date-related primitives:
 *   time, localtime and mktime.
 *
 * Revision 1.4  1995/10/23  16:04:41  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.3  1995/10/19  14:23:50  harrisja
 * additions/deletions to support new networking primitives
 * from networkTCP.h and networkUDP.h
 *
 * Revision 1.2  1995/10/04  09:39:35  harrisja
 * Removed binding of primitives from wollongong.h
 *
 * Revision 1.1  1995/09/22  11:29:04  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include "stats.h"
#include "core.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>			/* for varargs */

#ifdef sunBSD
#include <sys/time.h>
#include <sys/resource.h>
#include <a.out.h>
#endif

#ifdef solaris
#include <sys/time.h>
#include <sys/resource.h>
#endif

#include "common_subex.h"
#include "compare.h"
#include "prim.h"
#include "parse.h"
#include "pushpop.h"
#include "loader.h"
#include "utility.h"
#include "hardware.h"
#include "interpreter.h"
#include "context.h"
#include "memory.h"
#include "tasking.h"
#include "state.h"
#include "ioprim.h"
#include "fsysprim.h"

#ifdef supportNetworking
#include "network.h"
#include "networkTCP.h"
#include "networkUDP.h"
#endif

/* #define debug /* */
/* #define test /* */
/* #define profile_routines /* */

#ifdef profile_routines
#ifdef sunBSD
#include <sys/time.h>
#include <sys/resource.h>
#include <a.out.h>
#endif
#endif

#ifdef ring0
void BNRP_dumpHex(FILE *file, void *start, void *last)
{
	int i = -1;
	unsigned char *Start;
	
	Start = (unsigned char *)((long)start & 0xFFFFFFF0);
	fprintf(file,"\n%p:", Start);
	while ((void *)Start < start) {
		++i;
		fprintf(file,"   ");
		++Start;
		}
	while ((void *)Start < last) {
		if (++i > 15) {
			fprintf(file,"\n%p:", Start);
			i = 0;
			}
		fprintf(file," %02X", *Start);
		++Start;
		}
	fprintf(file,"\n");
	}
#endif

#ifdef ring0
/* tail variables not allowed, reg could be a value or an address */
void deref(long reg, long *taggedValue, TAG *tag, long *value, ptr *lastAddr)
{
	long l;
	ptr addr = (ptr)0xAAAAAAAA;
	
	l = reg;
	addr = NULL;
	while (isVAR(l)) {
		long _l = derefVAR(l);
		if (tagof(_l) EQ TVTAG)
			fprintf(stderr, "deref: Unexpected tail variable\n");
		if (_l EQ l) {					/* point to itself ?? */
			*tag = VART;
			*taggedValue = l;
			*lastAddr = (ptr)(*value = addrof(l));
			return;
			}
		l = _l;
		}
	*taggedValue = l;
	*lastAddr = addr;
	if (l EQ 0)
		*tag = ENDT;
	else 
		if (l & 0x40000000) {				/* bits 11.... */
			if (l & 0x20000000) {			/* bits 111... */
				*tag = SYMBOLT;
				*value = addrof(l);
#if SYMBOLMASK NE 0xE0000000
				error
#endif
				}
			else {						/* bits 110.. */
				li t;
				
				t.l = l;
				*value = t.i.b;
				*tag = INTT;
#if INTMASK NE 0xC0000000
				error
#endif
				}
			}
		else {								/* bits 10.... */
			if (l & 0x20000000) {			/* bits 101... */
				*tag = LISTT;
				*value = addrof(l);
#if LISTMASK NE 0xA0000000
				error
#endif
				}
			else {							/* bits 100... */
				long a;
				li t;
			
				a = *value = addrof(l);
				get(long, a, t.l);
				if (t.i.a EQ NUMBERIDshort) {
					if (t.i.b EQ INTIDshort) {
						get(long, a, *value);
						*tag = INTT;
						}
					else {
						fpLWA(a);
						*value = a;			/* pointer to fp */
						*tag = FLOATT;
						}
					}
				else
					*tag = STRUCTT;
#if STRUCTMASK NE 0x80000000
				error
#endif
				}
			}
	}
#endif

#ifdef ring0
void derefTV(long *p, long *taggedValue, TAG *tag, long *value, ptr *lastAddr)
{
	long l, a;
	ptr addr;
	
	*lastAddr = (ptr)(*p);
	get(long, *p, l);
	while (tagof(l) EQ TVTAG) {
		addr = (ptr)addrof(l);			/* isolate address */
		a = *addr;						/* get what tailvar points at */
		if (a EQ l) {					/* points to itself */
			*taggedValue = a;
			*tag = TAILVART;
			*lastAddr = addr;
			*value = (long)addr;
			return;
			}
		*p = (long)(addr + 1);
		l = a;
		}
	deref(l, taggedValue, tag, value, &addr);
	if (addr NE NULL) *lastAddr = addr;
	}
#endif

#ifdef ring0
void getVarName(TCB *tcb, long result, char *name)
{
	long t;
	char *special = "";
	variableEntry *v;
	
	t = (result - (long)tcb->args) / sizeof(long);
	if (((long *)result)[1] EQ CONSTRAINTMARK) special = "**";
	if (((long *)result)[1] EQ VARIABLEMARK) {
		v = (variableEntry *)result;
		if (*(v->name) EQ '_')
			sprintf(name, "%s%s", v->name, special);
		else
			sprintf(name, "_%s%s", v->name, special);
		}
	else if ((t GE 0) && (t LT MAXREGS))
		sprintf(name, "_R%ld", t);
	else if ((result GE tcb->heapbase) && (result LE tcb->heapend)) {
		t = (result - (long)tcb->heapbase) / sizeof(long);
		sprintf(name, "_H%ld%s", t, special);
		}
	else if ((result GE tcb->envbase) && (result LE tcb->envend)) {
		t = (result - (long)tcb->envbase) / sizeof(long);
		sprintf(name, "_E%ld%s", t, special);
		}
	else
		sprintf(name, "_%08lX%s", result, special);
	}
#endif

#ifdef ring0
void BNRP_dumpArgInternal(FILE *file, TCB *tcb, long value, long nesting, long prec)
{
	long result, t, orig, p, count, newprec;
	ptr addr;
	TAG tag;
	long LDCount, LDHold, LDk, LDSaveAddr;
	char *sp, varname[20], nextch;
	li arity;
	
	if (value EQ 0xAAAAAAAA) {
		fprintf(file,"unknown");
		return;
		}
	if (++nesting GE 20) {
		fprintf(file,"....");
		return;
		}
	t = (long)&value;
	derefTV(&t, &orig, &tag, &result, &addr);
	switch (tag) {
		case VART:
					getVarName(tcb, result, varname);
					fprintf(file,"%s", varname);
					break;
		case TAILVART:
					getVarName(tcb, result, varname);
					fprintf(file,"%s..", varname);
					break;
		case LISTT:
#ifdef debug
					fprintf(file,"list @ %08lX = ", result);
#endif
					nextch = '[';
					p = addrof(result);
					LDCount = 1;
					LDHold = 2;
					LDk = 0;
					derefTV(&p, &orig, &tag, &result, &addr);
					while (tag NE ENDT) {
						fprintf(file,"%c ", nextch);
						nextch = ',';
						if (tag EQ TAILVART) {
							getVarName(tcb, result, varname);
							fprintf(file,"%s..", varname);
							break;
							}
						BNRP_dumpArgInternal(file, tcb, orig, nesting, 3000);
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
									if (LDSaveAddr EQ p) {
										fprintf(file,"%c ...", nextch);
										break;
										}
									}
								}
							}
						}
					if (nextch EQ '[') fprintf(file,"[]"); else fprintf(file," ]");
					break;
		case STRUCTT:
					count = 0;
					p = result;
					pushAM(value, 0L, 0L);
					if (++count GT 1) fprintf(file,"\n");
#ifdef debug
					fprintf(file,"structure %08lX = ", p);
#endif
					LDCount = 1;
					LDHold = 2;
					LDk = 0;
					get(long, p, arity.l);							/* get header */
					derefTV(&p, &orig, &tag, &result, &addr);		/* get functor */
					if (tag EQ SYMBOLT) {
						sp = ((symbolEntry *)result)->name;
						t = ((symbolEntry *)result)->opType;
						newprec = ((symbolEntry *)result)->opPrecedence;
						}
					else
						t = notOp;
					if ((arity.i.b EQ 2) && (t & (xf | yf))) {
						/* postfix operator */
						if (newprec GE prec) fprintf(file,"(");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_dumpArgInternal(file, tcb, orig, nesting, newprec);
						if (*sp EQ '\0') fprintf(file," ''"); else fprintf(file," %s", sp);
						if (newprec GE prec) fprintf(file,")");
						}
					if ((arity.i.b EQ 2) && (t & (fx | fy))) {
						/* prefix operator */
						if (newprec GE prec) fprintf(file,"(");
						if (*sp EQ '\0') fprintf(file,"'' "); else fprintf(file,"%s ", sp);
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_dumpArgInternal(file, tcb, orig, nesting, newprec);
						if (newprec GE prec) fprintf(file,")");
						}
					else if ((arity.i.b EQ 3) && (t & (xfy | yfx | xfx))) {
						/* infix operator */
						if (newprec GE prec) fprintf(file,"(");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_dumpArgInternal(file, tcb, orig, nesting, newprec);
						if (*sp EQ '\0') fprintf(file," '' "); else fprintf(file," %s ", sp);
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_dumpArgInternal(file, tcb, orig, nesting, newprec);
						if (newprec GE prec) fprintf(file,")");
						}
					else {
						if (tag EQ SYMBOLT) {
							if (BNRP_needsQuotes(sp))
								BNRP_dumpWithQuotes(file, sp);
							else
								fprintf(file,"%s", sp);
							}
						else if (tag EQ VART) {
							getVarName(tcb, result, varname);
							fprintf(file,"%s", varname);
							}
						else
							fprintf(file,"???");
						nextch = '(';
						derefTV(&p, &orig, &tag, &result, &addr);
						while (tag NE ENDT) {
							fprintf(file,"%c ", nextch);
							nextch = ',';
							if (tag EQ TAILVART) {
								getVarName(tcb, result, varname);
								fprintf(file,"%s..", varname);
								break;
								}
							if ((tag EQ STRUCTT) && (searchAM(orig, 0L, &t))) {
								get(long, result, t);		/* get structure header */
								get(long, result, t);		/* get functor name */
								deref(t, &orig, &tag, &result, &addr);
								if (tag EQ SYMBOLT) {
									sp = nameof(result);
									if (BNRP_needsQuotes(sp))
										BNRP_dumpWithQuotes(file, sp);
									else
										fprintf(file,"%s", sp);
									fprintf(file,"(...)");
									}
								else if (tag EQ VART) {
									getVarName(tcb, result, varname);
									fprintf(file,"%s(", varname);
									}
								else
									fprintf(file,"????(...)");
								}
							else {
								BNRP_dumpArgInternal(file, tcb, orig, nesting, 3000);
								}
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
										if (LDSaveAddr EQ p) {
											fprintf(file,"%c ...", nextch);
											break;
											}
										}
									}
								}
							}
						if (nextch EQ '(') fprintf(file,"()"); else fprintf(file," )");
						}
					discardLastAM();
					break;
		case INTT:
					fprintf(file,"%ld", result);
					break;
		case FLOATT:
					fprintf(file,"%1.*g", BNRP_getFPPrecision(), *(fp *)result);
					break;
		case SYMBOLT:
					sp = nameof(result);
					if (BNRP_needsQuotes(sp))
						BNRP_dumpWithQuotes(file, sp);
					else
						fprintf(file,"%s", sp);
					break;
		case ENDT:
					fprintf(file,"**");
					break;
		}
	}
#endif

#ifdef ring0
void BNRP_dumpArg(FILE *file, TCB *tcb, long value)
{
	clearAM();
#ifdef debug
	fprintf(file,"%08lX -> ", value);
#endif
	fprintf(file,"%08lX -> ", value);
	BNRP_dumpArgInternal(file, tcb, value, 1, 3000);
	fprintf(file,"\n");
	freeAM();
	}
#endif

#ifdef ring0
TAG checkArg(long reg, long *value)
{
	long l;
	
	l = reg;
	while (isVAR(reg) || isTV(reg)) {
		register long ll = addrof(reg);
		l = *(long *)ll;
		if (l EQ reg) {			/* point to itself ?? */
			*value = ll;
			return((tagof(l) EQ TVTAG) ? TAILVART : VART);
			}
		reg = l;
		}
	if (l EQ 0) return(ENDT);
	if (l & 0x40000000) {				/* bits 11.... */
		if (l & 0x20000000) {			/* bits 111... */
			*value = l;
			return(SYMBOLT);
#if SYMBOLMASK NE 0xE0000000
			error
#endif
			}
		else {							/* bits 110.. */
			li t;
			
			t.l = l;
			*value = t.i.b;
			return(INTT);
#if INTMASK NE 0xC0000000
			error
#endif
			}
		}
	else {								/* bits 10.... */
		if (l & 0x20000000) {			/* bits 101... */
			*value = addrof(l);
			return(LISTT);
#if LISTMASK NE 0xA0000000
			error
#endif
			}
		else {							/* bits 100... */
			long a;
			li t;
		
			a = *value = addrof(l);
			get(long, a, t.l);
			if (t.i.a EQ NUMBERIDshort) {
				if (t.i.b EQ INTIDshort) {
					get(long, a, *value);
					return(INTT);
					}
				else {
					fpLWA(a);
					*value = a;			/* pointer to fp */
					return(FLOATT);
					}
				}
			return(STRUCTT);
#if STRUCTMASK NE 0x80000000
			error
#endif
			}
		}
	}
#endif

#ifdef ring5
#ifdef profile_routines
#ifdef sunBSD
static BNRP_Boolean getusage(TCB *tcb)
{
	struct rusage rusage;
	BNRP_term list;
	
	if ((tcb->numargs EQ 1) && (getrusage(RUSAGE_SELF, &rusage) EQ 0)) {
		list = BNRP_makeList((BNRP_TCB *)tcb, 16,
							makeint(&tcb->hp, rusage.ru_utime.tv_sec * 1000 + rusage.ru_utime.tv_usec / 1000),
							makeint(&tcb->hp, rusage.ru_stime.tv_sec * 1000 + rusage.ru_stime.tv_usec / 1000),
							makeint(&tcb->hp, rusage.ru_maxrss),
							makeint(&tcb->hp, rusage.ru_ixrss),
							makeint(&tcb->hp, rusage.ru_idrss),
							makeint(&tcb->hp, rusage.ru_isrss),
							makeint(&tcb->hp, rusage.ru_minflt),
							makeint(&tcb->hp, rusage.ru_majflt),
							makeint(&tcb->hp, rusage.ru_nswap),
							makeint(&tcb->hp, rusage.ru_inblock),
							makeint(&tcb->hp, rusage.ru_oublock),
							makeint(&tcb->hp, rusage.ru_msgsnd),
							makeint(&tcb->hp, rusage.ru_msgrcv),
							makeint(&tcb->hp, rusage.ru_nsignals),
							makeint(&tcb->hp, rusage.ru_nvcsw),
							makeint(&tcb->hp, rusage.ru_nivcsw));
		return(unify(tcb, tcb->args[1], list));
		}
	return(FALSE);
	}
static BNRP_Boolean profile(TCB *tcb)
{
	long n;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &n) EQ INTT))
		moncontrol(n);
	return(TRUE);
	}
#endif
#endif
#endif

#ifdef ring0
int BNRP_loadBase(int argc, char **argv, char *defaultbase)
{
	char *base = defaultbase, *p, *q;
	char fullbasename[MAXPATHLEN], fullprogname[MAXPATHLEN];	
	int i;
	FILE *f;

	for (i = 1; i LT argc; ++i) {
		if (strcmp(argv[i], "-load") NE 0) continue;
		base = argv[i+1];
		break;
		}

	/* can we find this base using our current working directory ?? */
	if ((f = fopen(base, "r")) NE NULL) {
		fclose(f);
		realpath(base, fullbasename);
		}
	else {
		/* try using the path for the application */
		/* if argv[0] does not contain a partial path, */
		/* then it must be on the search path, */
		/* so let BNRP_findfile find it */
		BNRP_findfile(argv[0], fullprogname);
		p = strrchr(fullprogname, FS_SEPARATOR);
		if (p NE NULL) {
			++p;		/* skip separator */
			q = base;	/* copy base name to the end of the directory */
			while (*p++ = *q++) ;
			realpath(fullprogname, fullbasename);
			if ((f = fopen(fullbasename, "r")) NE NULL) 
				fclose(f);
			else
				BNRP_findfile(base, fullbasename);
			}
		else
			BNRP_findfile(base, fullbasename);
		}
/*	BNRPSetBaseFileName(fullbasename);	*/
	return(loadFile(fullbasename));
	}
#endif

#ifdef ring0
void BNRP_bindRing0(void)
{
	BNRP_initializeGlobals();
	/* from core.c or bnrint.s */
	BNRPBindPrimitive("$quit", BNRP_quit);
	/* from prim.c */
	BNRPBindPrimitive("!", BNRP_eCut);
	BNRPBindPrimitive("$fixcutb", BNRP_fixCutb);
	BNRPBindPrimitive("error", BNRP_doError);
	BNRPBindPrimitive("get_error_code", BNRP_doGetErrorCode);
	BNRPBindPrimitive("gc", BNRP_set_gc);
	}
#endif

#ifdef ring1
void BNRP_bindRing1(void)
{
	void BNRP_bindRing0(void);
	
	BNRP_bindRing0();
	/* from compare.c */
	BNRPBindPrimitive("breadth_first_compare", BNRP_breadth_first_compare);
	BNRPBindPrimitive("$first_var", BNRP_first_var);
	BNRPBindPrimitive("$var_list", BNRP_var_list);
	BNRPBindPrimitive("spanning_tree", BNRP_spanning_tree);
	BNRPBindPrimitive("decompose", BNRP_decompose);
	BNRPBindPrimitive("acyclic", BNRP_acyclic);
	BNRPBindPrimitive("ground", BNRP_ground);
	/* from prim.c */
	BNRPBindPrimitive("new_counter", BNRP_newCounter);
	BNRPBindPrimitive("$counter", BNRP_incrCounter);
	BNRPBindPrimitive("globalCounter", BNRP_globalCounter);
	BNRPBindPrimitive("freeze", BNRP_freeze);
	BNRPBindPrimitive("$joinvar", BNRP_joinVar);
/*	BNRPBindPrimitive("$constrain", BNRP_constrain);	*/
	BNRPBindPrimitive("$name", BNRP_name);
	BNRPBindPrimitive("$concat", BNRP_concat);
	BNRPBindPrimitive("$substring", BNRP_substring);
    BNRPBindPrimitive("$strstr", BNRP_strstr);  /* new Mar. 1, 1996 */ 
	BNRPBindPrimitive("lowercase", BNRP_lowercase);
	BNRPBindPrimitive("uppercase", BNRP_uppercase);
	BNRPBindPrimitive("namelength", BNRP_namelength);
	BNRPBindPrimitive("gensym", BNRP_gensym);
	BNRPBindPrimitive("$get_constraint", BNRP_getConstraint);
	BNRPBindPrimitive("stats", BNRP_regularStatus);
	BNRPBindPrimitive("$memory_status", BNRP_memoryStatus);
	BNRPBindPrimitive("enable_timer", BNRP_enableTimer);
	BNRPBindPrimitive("$reenable_timer", BNRP_reEnableTimer);
	BNRPBindPrimitive("$delay", BNRP_delay);
	/* from state.c */
	BNRPBindPrimitive("$new_state", BNRP_newState);
	BNRPBindPrimitive("state_changed", BNRP_changedState);
	BNRPBindPrimitive("$ss", BNRP_getStateSpaceAtom);
	BNRPBindPrimitive("new_obj", BNRP_newObj);
	BNRPBindPrimitive("$zstoreobj", BNRP_zNewObj);
	BNRPBindPrimitive("put_obj", BNRP_putObj);
	BNRPBindPrimitive("dispose_obj", BNRP_forgetObj);
	BNRPBindPrimitive("$hashlist", BNRP_hashList);
	BNRPBindPrimitive("$dumpSS", BNRP_dumpSS);
	BNRPBindPrimitive("$statestatus", BNRP_stateSpaceStats);
	
	BNRP_initializeParser();
	if (!BNRP_NewStatespace(20, BNRPLookupPermSymbol("$local")))
		fprintf(stderr, "Unable to create local state space for base\n");
	}
#endif

#ifdef ring2
void BNRP_bindRing2(void)		/* only use for ring2, not ring3 */
{
	void BNRP_bindRing1(void);
	
	BNRP_bindRing1();
	/* from ioprim.c */
	BNRPBindPrimitive("$fread", BNRP_readFileSymbol);
	BNRPBindPrimitive("$fwrite", BNRP_writeFileSymbol);
	}
#endif

#ifdef ring3
void BNRP_bindRing3(void)
{
	void BNRP_bindRing1(void);
	
	/* skip ring2 since we have "better" primitives than those in ring2 */
	BNRP_bindRing1();
	/* from context.c */
	BNRPBindPrimitive("$enter_context", BNRP_enterContext);
	BNRPBindPrimitive("$exit_context", BNRP_exitContext);
	BNRPBindPrimitive("$context_list", BNRP_listContexts);
	BNRPBindPrimitive("$primitive", BNRP_isPrimitive);
	BNRPBindPrimitive("$predicate_symbol", BNRP_predicateSymbol);
	BNRPBindPrimitive("$prev_pred", BNRP_prevPredicate);
	BNRPBindPrimitive("$prev_symbol", BNRP_prevSymbol);
	BNRPBindPrimitive("$close_definition", BNRP_closeDefinition);
	BNRPBindPrimitive("$closed", BNRP_closedDefinition);
	BNRPBindPrimitive("$hide", BNRP_hideDefinition);
	BNRPBindPrimitive("$visible", BNRP_notHiddenDefinition);
	BNRPBindPrimitive("$ord_in", BNRP_getContextOf);
	/* from ioprim.c */
	BNRPBindPrimitive("$consult", BNRP_consultFile);
	}
#endif

#ifdef ring4
void BNRP_bindRing4(void)
{
	void BNRP_bindRing3(void);
	
	BNRP_bindRing3();
	/* from ioprim.c */
	BNRPBindPrimitive("$fopen", BNRP_openFile);
	BNRPBindPrimitive("$fclose", BNRP_closeFile);
	BNRPBindPrimitive("$fread", BNRP_readFile);
	BNRPBindPrimitive("$fwrite", BNRP_writeFile);
	BNRPBindPrimitive("$freadchar", BNRP_getChar);
	BNRPBindPrimitive("$freadln", BNRP_readlnFile);
	BNRPBindPrimitive("$at", BNRP_atFile);
	BNRPBindPrimitive("$seek", BNRP_seekFile);
	BNRPBindPrimitive("$set_end_of_file", BNRP_eofFile);
	/* from parse.c */
	BNRPBindPrimitive("lastparsererrorposition", BNRP_parseError);
	BNRPBindPrimitive("capitalsAsVariables", BNRP_capitalsAsVariables);
	BNRPBindPrimitive("underscoreAsVariable", BNRP_underscoreAsVariable);
	BNRPBindPrimitive("stripQuotes", BNRP_stripQuotes);

	/* from loader.c */
	BNRPBindPrimitive("$assert_clause", BNRP_inCoreLoader);
	/* from prim.c */
	BNRPBindPrimitive("$define_op", BNRP_defineOperator);
	BNRPBindPrimitive("$retract", BNRP_retract);
	BNRPBindPrimitive("$$address", BNRP_getAddress);
	BNRPBindPrimitive("$$arity", BNRP_getArity);
	/* from fsysprim.c */
	BNRPBindPrimitive("defaultdir", BNRP_defaultDir);
	BNRPBindPrimitive("$isfile", BNRP_isFile);
	BNRPBindPrimitive("fullfilename", BNRP_fullFileName);
	BNRPBindPrimitive("$listdirectories",BNRP_listdirectories);
	BNRPBindPrimitive("$listfiles",BNRP_listfiles);
	BNRPBindPrimitive("$listvolumes",BNRP_listvolumes);
	BNRPBindPrimitive("deletefile",BNRP_removeFile);
	BNRPBindPrimitive("createdirectory",BNRP_createDir);
	BNRPBindPrimitive("deletedirectory",BNRP_removeDir);
	BNRPBindPrimitive("applicationdir",BNRP_appdir);
	BNRPBindPrimitive("getappfiles",BNRP_getappfiles);
	}
#endif

#ifdef ring5
void BNRP_bindRing5(void)
{
	void BNRP_bindRing4(void);
	
	BNRP_bindRing4();
	/* from prim.c */
	BNRPBindPrimitive("enable_trace", BNRP_enableTrace);
	BNRPBindPrimitive("$set_trace", BNRP_setTrace);
	BNRPBindPrimitive("$set_trace_all", BNRP_setTraceAll);
	BNRPBindPrimitive("$unknown", BNRP_setUnknown);
	BNRPBindPrimitive("$goal", BNRP_goal);
	BNRPBindPrimitive("$configuration", BNRP_configuration);
	BNRPBindPrimitive("$dpprim", BNRP_dpprim);
	BNRPBindPrimitive("$examinefp", BNRP_examinefp);
	BNRPBindPrimitive("finite", BNRP_finite);
	BNRPBindPrimitive("$intervalcontrol", BNRP_setintervalconstraints);
	BNRPBindPrimitive("$replace_float", BNRP_replaceFloat);
	/* from ioprim.c */
	BNRPBindPrimitive("$traceback", BNRP_doTraceback);
	/* from fsysprim.c */
	BNRPBindPrimitive("system", BNRP_systemCall);
	BNRPBindPrimitive("getenv", BNRP_getenv);
	BNRPBindPrimitive("timedate", BNRP_timeAndDate);
	BNRPBindPrimitive("time", BNRP_time);
	BNRPBindPrimitive("localtime", BNRP_localtime);
	BNRPBindPrimitive("mktime", BNRP_mktime);
	BNRPBindPrimitive("gmtime", BNRP_gmtime);
	BNRPBindPrimitive("random", BNRP_random);
	BNRPBindPrimitive("randomseed", BNRP_randomseed);
	/* from interval.c */
	BNRPBindPrimitive("$iterate", BNRP_iterate);
	BNRPBindPrimitive("$fuzz", BNRP_fuzz);
	/* from common_subex.c */
	BNRPBindPrimitive("$findCommonSubex", BNRP_findCommonSubex);
	/* from tasking.c */
	BNRPBindPrimitive("$init_task", BNRP_init_task);
	BNRPBindPrimitive("$end_task", BNRP_end_task);
	BNRPBindPrimitive("$next_task", BNRP_next_task);
	BNRPBindPrimitive("$task_switch", BNRP_task_switch);
	BNRPBindPrimitive("$reply", BNRP_reply);
	BNRPBindPrimitive("$test_task", BNRP_test_task);
	BNRPBindPrimitive("self", BNRP_self);
	BNRPBindPrimitive("selfID", BNRP_selfID);
	BNRPBindPrimitive("$task_status", BNRP_task_status);
#ifdef supportNetworking
	/* from network.c */
	BNRPBindPrimitive("$closesocket",BNRP_closesocket);
	BNRPBindPrimitive("$netname",BNRP_netname);
	BNRPBindPrimitive("$networkconfiguration",BNRP_networkConfiguration);
	BNRPBindPrimitive("$setsocketopt",BNRP_setsocketopt);
	/* from networkTCP.h */
	BNRPBindPrimitive("$opensocketTCP",BNRP_opensocketTCP);
	BNRPBindPrimitive("$listensocket",BNRP_listenSocket);
	BNRPBindPrimitive("$acceptconnection",BNRP_acceptCon);
	BNRPBindPrimitive("$makeconnection",BNRP_makeCon);
	BNRPBindPrimitive("$sendmessageTCP",BNRP_sendmessageTCP);
	BNRPBindPrimitive("$receivemessageTCP",BNRP_receivemessageTCP);
	BNRPBindPrimitive("$receiveTCPterm", BNRP_receiveTCPterm);
	BNRPBindPrimitive("$sendTCPterm", BNRP_sendTCPterm);
	BNRPBindPrimitive("$receiveTCPbytes", BNRP_receiveTCPbytes);
	BNRPBindPrimitive("$sendTCPbytes", BNRP_sendTCPbytes);
       	/* from networkUDP.h */
	BNRPBindPrimitive("$opensocketUDP",BNRP_opensocketUDP);
	BNRPBindPrimitive("$sendmessageUDP",BNRP_sendmessageUDP);
	BNRPBindPrimitive("$receivemessageUDP",BNRP_receivemessageUDP);
	BNRPBindPrimitive("$sendUDPbytes",BNRP_sendUDPbytes);
	BNRPBindPrimitive("$receiveUDPbytes",BNRP_receiveUDPbytes);
	
#endif
#ifdef profile_routines
#ifdef sunBSD
	BNRPBindPrimitive("getrusage", getusage);
	BNRPBindPrimitive("profile", profile);
#endif
#endif
	}
#endif
