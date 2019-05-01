/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/parse.h,v 1.4 1998/06/05 06:07:53 csavage Exp $
*
*  $Log: parse.h,v $
 * Revision 1.4  1998/06/05  06:07:53  csavage
 * Addition of a stripQuotes primitive to allow the toggling
 * of how quotes are handled when capsAsVars is false.  The
 * default is to remove quotes - this allows quotes to be kept
 * for check utility.
 *
 * Revision 1.3  1998/02/13  11:18:21  csavage
 * Added underscoreAsVariable primitive
 *
 * Revision 1.2  1997/11/21  14:27:39  harrisj
 * Added new primitive called capitalsAsVariables(X).
 * If X is a variable, then it queries the current state.
 * If X is "true" then strings starting with a capital letter are considered to be variables.
 * If X is "false" then strings starting with capitals are considered to be symbols.
 * The default is to consider them to be variables
 *
 * Revision 1.1  1995/09/22  11:25:57  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_parse
#define _H_parse

#include <stdio.h>
#include "BNRProlog.h"
#include "core.h"
#include "ioprim.h"

typedef struct variableEntry variableEntry;
struct variableEntry {
	long reference;
	long mark;
	variableEntry *link;
	unsigned char hash;
	char name[1];
	};

enum charClasses {	r_blank,
					r_letter,
					r_Ereal,
					r_capital,
					r_Ecap,
					r_digit0,
					r_digit,
					r_bar,
					r_lpar,
					r_rpar,
					r_lbra,
					r_rbra,
					r_lcurly,
					r_rcurly,
					r_quote,
					r_dquote,
					r_plus,
					r_minus,
					r_star,
					r_percent,
					r_cr,
					r_vertical,
					r_slash,
					r_comma,
					r_dot,
					r_backslash,
					r_singleatom,
					r_special,
					r_invalid };
					
extern enum charClasses charClass[256];

BNRP_Boolean BNRP_parse(TCB *tcb, overloadIOProcedure fileProc, long fileIndex, long *result, long *ioresult);
void BNRP_initializeParser(void);
BNRP_Boolean BNRP_parseError(TCB *tcb);
BNRP_Boolean BNRP_capitalsAsVariables(TCB *tcb);
BNRP_Boolean BNRP_underscoreAsVariable(TCB *tcb);
BNRP_Boolean BNRP_stripQuotes(TCB *tcb);

#endif
