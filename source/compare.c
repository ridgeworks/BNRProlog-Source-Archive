/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/compare.c,v 1.1 1995/09/22 11:23:15 harrisja Exp $
*
*  $Log: compare.c,v $
 * Revision 1.1  1995/09/22  11:23:15  harrisja
 * Initial version.
 *
*
*/
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "BNRProlog.h"
#include "base.h"
#include "prim.h"
#include "pushpop.h"
#include "utility.h"
#include "compare.h"
#include "context.h"
#include "interpreter.h"

static BNRP_Boolean compareTerm(TCB *tcb, BNRP_term *left, BNRP_term *right, BNRP_Boolean *recurse, BNRP_Boolean *less)
{
	/* returns true if simple terms are equal, otherwise  */
	/* false and less is true if x < y in standard order; */
	/* set recurse to true if functor or list             */
	
	TAG leftTag, rightTag;
	long leftVal, rightVal, lname, rname;
	li leftArity, rightArity;
	
	*recurse = FALSE;
	if (*left EQ *right) return(TRUE);
	leftTag = checkArg(*left, &leftVal);
	rightTag = checkArg(*right, &rightVal);
	if (leftTag EQ rightTag) {
		if (leftVal EQ rightVal) return(TRUE);
		switch (leftTag) {
			case SYMBOLT:
							*less = strcmp(nameof(leftVal), nameof(rightVal)) LT 0;
							return(FALSE);
			case INTT:
							*less = leftVal LT rightVal;
							return(FALSE);
			case FLOATT:
							/* since floats return pointers, see if they point at same number */
							*less = *(fp *)leftVal LT *(fp *)rightVal;
							return(*(fp *)leftVal EQ *(fp *)rightVal);
			case STRUCTT:
							get(long, leftVal, leftArity.l);
							get(long, rightVal, rightArity.l);
 							/* must both be regular structures, so just recurse */
							get(long, leftVal, lname);
							get(long, rightVal, rname);
							if (lname NE rname) {
								if (!(compareTerm(tcb, &lname, &rname, recurse, less)))
									return(FALSE);	
								}
							if (leftArity.i.b NE rightArity.i.b) {
								*less = leftArity.i.b LT rightArity.i.b;
								return(FALSE);
								}
			case LISTT:
							*left = leftVal;
							*right = rightVal;
							*recurse = TRUE;
							return(TRUE);
			default:
							*less = leftVal LT rightVal;
							return(FALSE);
			}
		}
	if ((leftTag EQ INTT) && (rightTag EQ FLOATT)) {
		*less = leftVal LE *(fp *)rightVal;
		}
	else if ((leftTag EQ FLOATT) && (rightTag EQ INTT)) {
		*less = *(fp *)leftVal LT rightVal;
		}
	else
		*less = leftTag LT rightTag;
	return(FALSE);
	}

BNRP_Boolean BNRP_breadth_first_compare(TCB *tcb)
{
	BNRP_Boolean areEqual, less, recurse, cont, checkLoop;
	long l, r, newl, newr, t;
	BNRP_term dat;
	long LDk = 0, LDhold = 2, LDleft, LDright;
	
	if (tcb->numargs EQ 3) {
		l = tcb->args[1];
		r = tcb->args[2];
		areEqual = compareTerm(tcb, &l, &r, &recurse, &less);
		if (recurse) {
			clearAM();
			pushAM(l, r, 0L);
			while (areEqual && pullAM(&l, &r, &dat)) {
				cont = TRUE;
				while (areEqual && cont) {
					checkLoop = FALSE;
					get(long, l, newl);
					while (tagof(newl) EQ TAILVARTAG) {
						t = addrof(newl);
						if (newl EQ *(long *)t) {			/* unbound TV */
							cont = FALSE;
							break;
							}
						if (t LT l) checkLoop = TRUE;
						l = t;
						get(long, l, newl);
						}
					get(long, r, newr);
					while (tagof(newr) EQ TAILVARTAG) {
						t = addrof(newr);
						if (newr EQ *(long *)t) {			/* unbound TV */
							cont = FALSE;
							break;
							}
						if (t LT r) checkLoop = TRUE;
						r = t;
						get(long, r, newr);
						}
					if (newl EQ 0) {
						areEqual = (newr EQ 0);		/* equal if other at end too */
						less = (newr NE 0);			/* less if right not at end */
						break;
						}
					if (newr EQ 0) {
						areEqual = FALSE;			/* not equal since l = 0 done above */
						less = FALSE;				/* not less since left is longer */
						break;
						}
					if (checkLoop) {
						if (LDk EQ 0) {
							LDk = LDhold;
							LDhold += LDhold;
							LDleft = l;
							LDright = r;
							}
						else {
							--LDk;
							if ((LDleft EQ l) && (LDright EQ r)) {
								/* looped around, still the same */
								areEqual = TRUE;
								cont = FALSE;
								}
							}
						}
					if (cont && (newl NE newr)) {
						areEqual = compareTerm(tcb, &newl, &newr, &recurse, &less);
						if (recurse) pushAM(newl, newr, 0L);
						}
					else {
						areEqual = (newl EQ newr);
						less = (newl LT newr);
						}
					}
				}
			freeAM();
			}
		if (areEqual)
			dat = BNRPLookupSymbol(tcb, "@=", PERMSYM, GLOBAL);
		else if (less)
			dat = BNRPLookupSymbol(tcb, "@<", PERMSYM, GLOBAL);
		else
			dat = BNRPLookupSymbol(tcb, "@>", PERMSYM, GLOBAL);
		return(unify(tcb, tcb->args[3], dat));
		}
	return(FALSE);	
	}

BNRP_Boolean BNRP_first_var(TCB *tcb)
{
	long l, r, dat, oldl;
	TAG t;
	BNRP_Boolean done, checkLoop;
	long LDk = 0, LDhold = 2, LDdat;
	
	if (tcb->numargs EQ 2) {
		clearAM();
		pushAM(tcb->args[1], 0L, 0L);
		while (pullAM(&l, &r, &dat)) {
			t = checkArg(l, &dat);
			switch (t) {
				case VART:	
							freeAM();
							return(unify(tcb, tcb->args[2], makevarterm(dat)));
				case STRUCTT:
							get(long, dat, l);			/* skip header */
				case LISTT:
							done = checkLoop = FALSE;
							while (!done) {
								get(long, dat, l);
								while (tagof(l) EQ TAILVARTAG) {
									oldl = l;
									r = addrof(l);
									if (r LT dat) checkLoop = TRUE;
									dat = r;
									get(long, dat, l);
									if (l EQ oldl) break;	/* tailvariable */
									}
								switch (checkArg(l, &r)) {
									case VART:	
												freeAM();
												return(unify(tcb, tcb->args[2], makevarterm(r)));
									case TAILVART:
									case ENDT:
												checkLoop = FALSE;
												done = TRUE;
												break;
									case STRUCTT:
									case LISTT:
												pushAM(l, 0L, 0L);
												break;
									}
								if (checkLoop) {
									if (LDk EQ 0) {
										LDk = LDhold;
										LDhold += LDhold;
										LDdat = dat;
										}
									else {
										--LDk;
										if (LDdat EQ dat)
											done = TRUE;
										}
									}
								}
							break;
				}
			}
		freeAM();
		}
	return(FALSE);
	}

#define heapcheck(n)    if ((tcb->heapend - tcb->hp) LE (n * sizeof(long))) \
                                 BNRP_error(HEAPOVERFLOW)

BNRP_Boolean BNRP_var_list(TCB *tcb)
/* given an expression, return a list of variables and tailvariables, 
   including duplicates */
{
	BNRP_term dat, varlist, tvarlist;
	long l, addr, type, t, cnt = 100;
	BNRP_Boolean checkLoop;
	long LDk = 0, LDhold = 2, LDdat;

	if (tcb->numargs EQ 3) {
		switch (checkArg(tcb->args[1], &dat)) {
			case STRUCTT:
						get(long, dat, l);			/* skip header */
			case LISTT:
						clearAM();
						pushAM(dat, 0L, 0L);
						varlist = maketerm(LISTTAG, tcb->hp);
						while (pullAM(&addr, &type, &dat)) {
							while (type EQ 0) {		/* only lists and structures */
								checkLoop = FALSE;
								get(long, addr, l);
								while (tagof(l) EQ TAILVARTAG) {
									t = addrof(l);
									if (l EQ *(long *)t) break;
									if (t LT addr) checkLoop = TRUE;
									addr = t;
									get(long, addr, l);
									}
								switch (checkArg(l, &dat)) {
									case ENDT:
												type = 1;
												break;
									case VART:
												heapcheck(2);
												push(long, tcb->hp, makevarterm(dat));
												break;
									case TAILVART:
												pushAM(l, ++cnt, 0);
												type = 1;
												break;
									case STRUCTT:
												get(long, dat, l);			/* skip header */
									case LISTT:
												pushAM(dat, 0L, 0L);
												break;
									}
								if (checkLoop) {
									if (LDk EQ 0) {
										LDk = LDhold;
										LDhold += LDhold;
										LDdat = addr;
										}
									else {
										--LDk;
										if (LDdat EQ addr) {
											/* looped around, still the same */
											type = 1;
											}
										}
									}
								}
							}
						push(long, tcb->hp, 0L);		/* finish off var list */
						tvarlist = maketerm(LISTTAG, tcb->hp);
						resetAM();
						while (pullAM(&addr, &type, &dat))
							if (type NE 0) {
								heapcheck(2);
								push(long, tcb->hp, maketerm(LISTTAG, addrof(addr)));
								}
						push(long, tcb->hp, 0L);
						freeAM();
						break;
			case VART:				/* return variable in list, empty TV list */
						heapcheck(2);
						varlist = maketerm(LISTTAG, tcb->hp);
						push(long, tcb->hp, makevarterm(dat));
						tvarlist = maketerm(LISTTAG, tcb->hp);
						push(long, tcb->hp, 0L);
						break;
			default:				/* return empty var and TV lists */
						heapcheck(1);
						varlist = tvarlist = maketerm(LISTTAG, tcb->hp);
						push(long, tcb->hp, 0L);
						break;
			}
		return(unify(tcb, tcb->args[2], varlist) && unify(tcb, tcb->args[3], tvarlist));
		}
	return(FALSE);
	}

	
/****************************************************************************

SpanningTree primitive

****************************************************************************/

static BNRP_Boolean spanningtree(TCB *tcb, BNRP_Boolean simplify)
{
	BNRP_term t1, t2, loopvar, loopedterm, loopedvarterm;
	long a, b, fix, first, val, newvar, t;
	BNRP_Boolean looped, continueOn;
	TAG tag;
	long orig, result, addr;
	long LDHold, LDk, LDSaveAddr, LDSaveHP, LDOrig;
	
	if (tcb->numargs NE 3) return(FALSE);
	clearAM();
	t1 = 0;
	t = tcb->args[1];
	while (isVAR(t)) {						/* while variable */
		register long a = derefVAR(t);		/* chase variable */
		if (t EQ a) return(FALSE);			/* really a variable so error */
		t = a;
		}
	if (isTV(t)) return(FALSE);
	pushAM(t, 0L, (long)&t1);
	while (topAM(&a, &b, &fix)) {
		if (b EQ 0) {					/* a structure, needs to be processed */
			if (findAM(a, b, &first)) {	/* have we done it already ?? */
				val = *(long *)first;
				if (val LE 0) {
					/* not done or a structure, therefore   */
					/* we must create a unification for it  */
					pushAM(maketerm(STRUCTTAG, tcb->hp), 1L, 0L);
					push(long, tcb->hp, BINARYHEADER);
					push(long, tcb->hp, unificationAtom);
					newvar = makevarterm(tcb->hp);
					push(long, tcb->hp, newvar);
					push(long, tcb->hp, val);
					push(long, tcb->hp, 0L);
					val = newvar;
					}
				*(long *)fix = val;		/* update this entry */
				if (simplify) *(long *)first = val;
				}
			else {						/* structure not already processed */
				tag = checkArg(a, &val);
				if (tag EQ STRUCTT) {
					*(long *)fix = maketerm(STRUCTTAG, tcb->hp);
					get(long, val, b);
					push(long, tcb->hp, b);
					}
				else if (tag EQ LISTT)
					*(long *)fix = maketerm(LISTTAG, tcb->hp);
				else if (fix EQ (long)&t1) {		/* first time, return nonvars */
					t2 = maketerm(LISTTAG, tcb->hp);
					push(long, tcb->hp, 0L);
					freeAM();
					return(unify(tcb, tcb->args[2], a) & unify(tcb, tcb->args[3], t2));
					}
				else {
					freeAM();
					return(FALSE);
					}
				looped = FALSE;
				continueOn = TRUE;
				t = *(long *)val;
				while (tagof(t) EQ TVTAG) {
					val = addrof(t);			/* isolate address */
					a = *(long *)val;			/* get what tailvar points at */
					if (a EQ t) break;			/* points to itself */
					t = a;
					}
				LDk = 2;						/* prime loop detection with */
				LDHold = 4;						/* pointer to first object */
				LDSaveAddr = val;
				LDSaveHP = tcb->hp;
				while (continueOn) {
					LDOrig = val;
					derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
					switch (tag) {
						case ENDT:
									result = 0;
									continueOn = FALSE;
									break;
						case LISTT:
						case STRUCTT:
									pushAM(orig, 0L, tcb->hp);
						case INTT:
						case FLOATT:
						case SYMBOLT:
									result = orig;
									break;
						case VART:
									orig = *(long *)addr;
									if (searchAM(orig, 2L, &addr))
										orig = addr;
									else {
										pushAM(orig, 2L, makevarterm(tcb->hp));
										orig = makevarterm(tcb->hp);
										}
									break;
						case TAILVART:
									orig = *(long *)addr;
									if (searchAM(orig, 3L, &addr))
										orig = addr;
									else {
										pushAM(orig, 3L, maketerm(TVTAG, tcb->hp));
										orig = maketerm(TVTAG, tcb->hp);
										}
									continueOn = FALSE;
									break;
						}
					push(long, tcb->hp, orig);
					t = *(long *)val;			/* peek at next value */
					if ((continueOn) && (tagof(t) EQ TVTAG)) {
						do {
							val = addrof(t);			/* isolate address */
							a = *(long *)val;			/* get what tailvar points at */
							if (a EQ t) break;			/* points to itself */
							t = a;
							} while (tagof(t) EQ TVTAG);
						if (val EQ LDOrig) {			/* definate loop */
							looped = TRUE;
							continueOn = FALSE;
							LDSaveHP = tcb->hp - sizeof(long);
							LDSaveAddr = val;
							}
						else if (val LT LDOrig) {		/* possible loop */
							if (LDk EQ 0) {
								LDk = LDHold;
								LDHold += LDHold;
								LDSaveAddr = val;
								LDSaveHP = tcb->hp;
								}
							else {
								--LDk;
								if (LDSaveAddr EQ val) {
									looped = TRUE;
									continueOn = FALSE;
									}
								}
							}
						}
					} /* while continueOn */
				if (looped) {
					/* start of the loop, place tailvariable at end. */
					/* shorten loop just laid down if simplify is on */
					/* since we just passed the loop a second time.  */
					if (simplify) tcb->hp = LDSaveHP;	/* backup to start */
					loopvar = maketerm(TVTAG, tcb->hp);
					pushAM(loopvar, 3L, loopvar);
					push(long, tcb->hp, loopvar);

					/* need to pull out the loop.  We know that val and  */
					/* LDSaveAddr point to the same thing, which is the  */
					/* first thing in the loop.  loopvar is the tailvar  */
					/* we put in at the end of the original copy.        */
					
					/* make a list with just the loop [X..] */
					loopedvarterm = maketerm(LISTTAG, tcb->hp);
					push(long, tcb->hp, loopvar);
					
					/* now make a list with the loop in it, followed by X.. */
					loopedterm = maketerm(LISTTAG, tcb->hp);
					do {
						derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
						switch (tag) {
							case LISTT:
							case STRUCTT:
										pushAM(orig, 0L, tcb->hp);
							case INTT:
							case FLOATT:
							case SYMBOLT:
										result = orig;
										break;
							case VART:
										orig = *(long *)addr;
										if (searchAM(orig, 2L, &addr))
											orig = addr;
										else {
											pushAM(orig, 2L, tcb->hp);
											orig = tcb->hp;
											}
										break;
							case TAILVART:
										orig = *(long *)addr;
										if (searchAM(orig, 3L, &addr))
											orig = addr;
										else {
											pushAM(orig, 3L, maketerm(TVTAG, tcb->hp));
											orig = maketerm(TVTAG, tcb->hp);
											}
										continueOn = FALSE;
										break;
							}
						push(long, tcb->hp, orig);
						t = *(long *)val;
						while (tagof(t) EQ TVTAG) {
							val = addrof(t);			/* isolate address */
							a = *(long *)val;			/* get what tailvar points at */
							if (a EQ t) break;			/* points to itself */
							t = a;
							}
						} while (val NE LDSaveAddr);
					push(long, tcb->hp, loopvar);
					
					pushAM(maketerm(STRUCTTAG, tcb->hp), 1L, 0L);
					push(long, tcb->hp, BINARYHEADER);
					push(long, tcb->hp, unificationAtom);
					push(long, tcb->hp, loopedvarterm);
					push(long, tcb->hp, loopedterm);
					push(long, tcb->hp, 0L);
					} /* looped */
				} /* ! findAM() */
			} /* b EQ 0 */
		discardTopAM();					/* skip the entry just processed */
		}
		
	/* make a list out of the unifications created */
	resetAM();
	t2 = maketerm(LISTTAG, tcb->hp);
	while (nextAM(&a, &b, &fix))
		if (b EQ 1) {
			push(long, tcb->hp, a);
			}
	push(long, tcb->hp, 0L);
	freeAM();
	return(unify(tcb, tcb->args[2], t1) & unify(tcb, tcb->args[3], t2));
	}
	
BNRP_Boolean BNRP_spanning_tree(TCB *tcb)
{
	return(spanningtree(tcb, FALSE));
	}
	
BNRP_Boolean BNRP_decompose(TCB *tcb)
{
	return(spanningtree(tcb, TRUE));
	}
	

BNRP_Boolean checkAcyclic(long val)
{
	/* Returns TRUE if val has no cycles. */
	/* Made recursive to avoid hitting common subexpressions */

	long t;
	BNRP_Boolean continueOn = TRUE;
	TAG tag;
	long orig, result, addr;
	long LDHold = 2, LDk = 0, LDSaveAddr;
 
	/* first check to see if we have seen this term already */
	if (searchAM(val, 0L, &t)) return(FALSE);
	pushAM(val, 0L, 0L);
	while (continueOn) {
		t = val;
		derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
		switch (tag) {
			case ENDT:
			case TAILVART:
						continueOn = FALSE;
						break;
			case STRUCTT:
						result += sizeof(long);			/* skip header */
			case LISTT:
						if (!checkAcyclic(result)) {
							discardLastAM();
							return(FALSE);
							}
						break;
			}
		if (val LE t) {			/* possible loop */
			if (LDk EQ 0) {
				LDk = LDHold;
				LDHold += LDHold;
				LDSaveAddr = val;
				}
			else {
				if (LDSaveAddr EQ val)  {
					discardLastAM();
					return(FALSE);
					}
				--LDk;
				}
			} /* possible loop */
		} /* while continueOn */
	discardLastAM();
	return(TRUE);
	}

BNRP_Boolean BNRP_acyclic(TCB *tcb)
{
	long addr;
	
	if (tcb->numargs EQ 1) {
		clearAM();
		switch (checkArg(tcb->args[1], &addr)) {
			case STRUCTT:
							addr += sizeof(long);			/* skip header */
			case LISTT:
							return(checkAcyclic(addr));
			}
		freeAM();
		return(TRUE);
		}
	return(FALSE);
	}

BNRP_Boolean BNRP_ground(TCB *tcb)
{
	long orig, result, addr, t, val, b;
	long LDHold, LDk, LDSaveAddr;
	BNRP_Boolean continueOn;
	TAG tag;
	
	if (tcb->numargs NE 1) return(FALSE);
	clearAM();
	switch (checkArg(tcb->args[1], &addr)) {
		case STRUCTT:
					addr += sizeof(long);			/* skip header */
		case LISTT:
					pushAM(addr, 0L, 0L);
					while (pullAM(&val, &b, &t)) {
						LDHold = 2;
						LDk = 0;
						continueOn = TRUE;
						while (continueOn) {
							t = val;
							derefTV(&val, &orig, &tag, &result, (ptr *)&addr);
							switch (tag) {
								case ENDT:
											continueOn = FALSE;
											break;
								case STRUCTT:
											result += sizeof(long);		/* skip header */
								case LISTT:
											pushAM(result, 0L, 0L);
											break;
								case VART:
								case TAILVART:
											freeAM();
											return(FALSE);
								}
							if (val LE t) {					/* possible loop */
								if (LDk EQ 0) {
									LDk = LDHold;
									LDHold += LDHold;
									LDSaveAddr = val;
									}
								else {
									--LDk;
									if (LDSaveAddr EQ val) continueOn = FALSE;
									}
								} /* possible loop */
							} /* while continueOn */
						} /* while pullAM() */
					freeAM();
					break;
		case VART:
		case TAILVART:
					return(FALSE);
		} /* case */
	return(TRUE);
	}

/**************

FUNCTION do_bind_vars: BNRP_Boolean;

	BEGIN

		do_bind_vars := FALSE;
		WITH arglist DO
			IF number = 1 THEN
				do_bind_vars := bindnames(x.tag, x.val, x.sube);
	END;

FUNCTION do_occurs_in: BNRP_Boolean;

{ occurs_in(expr, var) returns true if var part of expr }

	CONST
		ValidMaskx = (2 ** ord(VarT)) + (2 ** ord(intt)) + (2 ** ord(RealT)) + (2 ** ord(atomt)) + (2 ** ord(WordT)) + (2 **
					 ord(IntervalT));
		ValidMasky = ValidMaskx + (2 ** ord(listT)) + (2 ** ord(funct));

	BEGIN
		do_occurs_in := FALSE;
		WITH arglist DO
			IF (number = 2) & BTST(ValidMaskx, ord(x.tag)) & BTST(ValidMasky, ord(y.tag)) THEN
				IF BTST(ValidMaskx, ord(y.tag)) THEN
					do_occurs_in := (x.tag = y.tag) & (x.val = y.val) & (x.sube = y.sube)
				ELSE
					do_occurs_in := FindVar(y.val, y.sube, x.tag, x.val, x.sube);
	END;


****************/
