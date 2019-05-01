/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/embed.c,v 1.2 1997/08/12 17:34:50 harrisj Exp $
*
*  $Log: embed.c,v $
 * Revision 1.2  1997/08/12  17:34:50  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.1  1995/09/22  11:24:03  harrisja
 * Initial version.
 *
*
*/
#include <stdio.h>
#include <string.h>
#include "BNRProlog.h"
#include "base.h"
#include "context.h"
#include "interpreter.h"

long BNRP_embedSymbol(const char *symbol)
{
	return(BNRPLookupPermSymbol(symbol));
	}

long BNRP_embedInt(long i)
{
	return(BNRPMakePermInt(i));
	}

long BNRP_embedFloat(double f)
{
	fp _f = f;
	
	return(BNRPMakePermFloat(&_f));
	}

static BNRP_Boolean BNRP_lookupOp(const char *p, short *ty, BNRP_Boolean *new)
{
	char c;
	
	*ty = notOp;
	*new = FALSE;
	while ((c = *p++)) {
		if (c EQ 'x') {
			if (*p++ EQ 'f') {
				if ((c = *p++) EQ 'x')
					*ty += xfx;
				else if (c EQ 'y')
					*ty += xfy;
				else {
					*ty += xf;
					--p;
					}
				}
			}
		else if (c EQ 'y') {
			if (*p++ EQ 'f') {
				if (*p++ EQ 'x')
					*ty += yfx;
				else {
					*ty += yf;
					--p;
					}
				}
			}
		else if (c EQ 'f') {
			if ((c = *p++) EQ 'x')
				*ty += fx;
			else
				*ty += fy;
			}
		else if (c EQ 'n') {
			++p;	/* skip e */
			++p;	/* skip w */
			*new = TRUE;
			}
		else if (c NE ' ')
			return(FALSE);
		}
	return(TRUE);
	}

int BNRP_embedIgnoreContext = 0;
char BNRP_embedLastContext[32];

void BNRP_embedOperator(const char *operator, long precedence, const char *type)
{
	BNRP_term a;
	short ty, pr;
	BNRP_Boolean new;
	
	a = BNRPLookupPermSymbol(operator);
	if (BNRP_lookupOp(type, &ty, &new) AND (precedence GE 0) AND (precedence LE 1200)) {
		pr = (short)precedence;
		if (new)  {
			if (!BNRP_addOperator(a, ty, pr))
				fprintf(stderr, "Warning:  Unable to add definition of operator \"%s\"\n", nameof(a));
			}
/*		else if (((symof(a)->opType NE ty) || (symof(a)->opPrecedence NE pr)) && (BNRP_embedIgnoreContext EQ 0))
			fprintf(stderr, "Warning:  Operator \"%s\" defined differently than at compile time\n", nameof(a));
*/ /* Mod by Jason Harris Feb. 95 */
		else if ((((symof(a)->opType & ty) EQ 0) || (symof(a)->opPrecedence NE pr)) && (BNRP_embedIgnoreContext EQ 0))
                        fprintf(stderr, "Warning:  Operator \"%s\" defined differently than at compile time\n", nameof(a));

		}
	}

void BNRP_embedContext(const char *contextname, long version)
{
	BNRP_term name1, name2;
	
	if (version NE 1) 
		fprintf(stderr, "Incorrect file version loading context %s\n", contextname);
	
	strncpy(BNRP_embedLastContext, contextname, 32);
	BNRP_embedLastContext[31] = '\0';
	
	if (BNRP_embedIgnoreContext EQ 0) {
		name1 = BNRPLookupPermSymbol(contextname);
		name2 = BNRPLookupPermSymbol("::c");
		(void)BNRPnewContext(name1, name2);
		}
	
	/* force creation of a symbol that is not referenced so that a    */
	/* chunk of allocated memory is kept for the context, and that    */
	/* chunk will never go away since we will use the first space     */
	/* when BNRP_insertClause is called for clauses. This is required */
	/* so that the context of the clause can be determined.           */
	(void)BNRPLookupPermSymbol("$local");
	}

void BNRP_embedClause(const char *predicate, long arity, long hash, long *clauseStart)
{
	BNRP_term pred;
	long key;
	
	pred = BNRPLookupPermSymbol(predicate);
	if ((key = hash) EQ -1) key = computeKey(*clauseStart);
	if (!BNRP_insertClause(pred, arity, key, (clauseEntry *)clauseStart))
		fprintf(stderr, "Unable to add clause from compiled Prolog context %s\n", BNRP_embedLastContext);
	}
