/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/parse.c,v 1.11 1998/06/05 06:07:50 csavage Exp $
*
*  $Log: parse.c,v $
 * Revision 1.11  1998/06/05  06:07:50  csavage
 * Addition of a stripQuotes primitive to allow the toggling
 * of how quotes are handled when capsAsVars is false.  The
 * default is to remove quotes - this allows quotes to be kept
 * for check utility.
 *
 * Revision 1.10  1998/03/13  09:04:48  csavage
 * *** empty log message ***
 *
 * Revision 1.9  1998/03/12  16:36:53  csavage
 * Changed BNRP_parse for special case of
 * capitalsAsVariables where we want quotes
 * LEFT around strings during parsing.
 * (case 'd' of BNRP_Parse).
 * Removed previous attempt from remove_Specials
 *
 * Revision 1.8  1998/02/25  08:17:05  csavage
 * error case TOOMANYARGS changed to use MAXARGS (126)
 * rather than MAXREGS (256)
 *
 * Revision 1.7  1998/02/13  11:18:17  csavage
 * Added underscoreAsVariable primitive
 *
 * Revision 1.6  1998/01/05  11:07:58  harrisj
 * BNRP_dumpHex now has a FILE* parameter
 *
 * Revision 1.5  1997/11/21  14:27:36  harrisj
 * Added new primitive called capitalsAsVariables(X).
 * If X is a variable, then it queries the current state.
 * If X is "true" then strings starting with a capital letter are considered to be variables.
 * If X is "false" then strings starting with capitals are considered to be symbols.
 * The default is to consider them to be variables
 *
 * Revision 1.4  1996/07/05  11:03:02  yanzhou
 * The parser has been changed to generate temporary symbols,
 * because permanent symbols could cause run-time "memory leaks".
 *
 * Revision 1.3  1996/06/19  11:38:53  yanzhou
 * BNRP_stringToLong modified so that it no longer fails if the long
 * integer overflows.  Previously, it could hang a BNRProlog session if
 * an integer of more than 10 digits is entered at the console.
 *
 * Revision 1.2  1995/12/04  00:10:22  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.1  1995/09/22  11:25:55  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "prim.h"
#include "parse.h"
#include "interpreter.h"
#include "hash.h"
#include "utility.h"
#include "ioprim.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>			/* for LONG_MAX, LONG_MIN, ULONG_MAX */
#ifndef ULONG_MAX			/* Not defined on some machines */
#define ULONG_MAX	4294967295UL 	/* max value of an unsigned long int */
#endif
#ifndef unix
#include <stdlib.h>			/* for strtol, atof */
#endif

/*#define debug /* */
/*#define echoinput /* */

#define MAXSTATES 37
#define ERRORSTATE 1
char *stt[MAXSTATES], *sat[MAXSTATES];
long BNRP_lastParseErrorPosition;

static BNRP_Boolean capsAsVars = TRUE;
static BNRP_Boolean u_scoreAsVar = TRUE;
static BNRP_Boolean strpQuot = TRUE;

#ifdef debug
#define ERROR(err)			{ *ioresult = err; \
							  printf("\n***** Generating ERROR %ld *****\n\n", err); \
							  if (!(*fileProc)(GETPOSITION, fileIndex, &BNRP_lastParseErrorPosition)) \
							  	  BNRP_lastParseErrorPosition = -1; \
							  printf("Error position = %ld\n", BNRP_lastParseErrorPosition); \
							  if (action EQ 'h') return(FALSE); \
							  state = ERRORSTATE; \
							  goto nextchar; }
#else
#define ERROR(err)			{ *ioresult = err; \
							  if (!(*fileProc)(GETPOSITION, fileIndex, &BNRP_lastParseErrorPosition)) \
							  	  BNRP_lastParseErrorPosition = -1; \
							  if (action EQ 'h') return(FALSE); \
							  state = ERRORSTATE; \
							  goto nextchar; }
#endif

enum charClasses charClass[256];
long BNRP_parserInitialized = FALSE;

void BNRP_initializeParser()
{
	register int i;
	
	BNRP_parserInitialized = TRUE;
	BNRP_lastParseErrorPosition = -1;
	for (i = 0; i LE 255; ++i) {
		charClass[i] = r_invalid;
		if (isascii((char)i)) {
			if (isdigit((char)i))
				charClass[i] = r_digit;
			else if (isupper((char)i))
				charClass[i] = r_capital;
			else if (islower((char)i))
				charClass[i] = r_letter;
			else if (isspace((char)i))
				charClass[i] = r_blank;
			else if (ispunct((char)i))
				charClass[i] = r_special;
			}
		}
	charClass[(unsigned char)'$'] = r_letter;
	charClass[(unsigned char)'e'] = r_Ereal;
	charClass[(unsigned char)'E'] = r_Ecap;
	charClass[(unsigned char)'0'] = r_digit0;
	charClass[(unsigned char)'_'] = r_bar;
	charClass[(unsigned char)'('] = r_lpar;
	charClass[(unsigned char)')'] = r_rpar;
	charClass[(unsigned char)'['] = r_lbra;
	charClass[(unsigned char)']'] = r_rbra;
	charClass[(unsigned char)'{'] = r_lcurly;
	charClass[(unsigned char)'}'] = r_rcurly;
	charClass[(unsigned char)'\''] = r_quote;
	charClass[(unsigned char)'"'] = r_dquote;
	charClass[(unsigned char)'+'] = r_plus;
	charClass[(unsigned char)'-'] = r_minus;
	charClass[(unsigned char)'*'] = r_star;
	charClass[(unsigned char)'%'] = r_percent;
	charClass[(unsigned char)'\n'] = r_cr;
	charClass[(unsigned char)'\r'] = r_cr;
	charClass[(unsigned char)'|'] = r_vertical;
	charClass[(unsigned char)'/'] = r_slash;
	charClass[(unsigned char)','] = r_comma;
	charClass[(unsigned char)'.'] = r_dot;
	charClass[(unsigned char)'\\'] = r_backslash;
	charClass[(unsigned char)'!'] = r_singleatom;
	charClass[(unsigned char)';'] = r_singleatom;
/*	charClass[(unsigned char)'¹'] = r_letter;              Macintosh pi symbol */
	stt[0] = "0<<AAF=A00000052>>>00CD0?>0>1";    /* 0 '0' init */
	stt[1] = "111111111111111111111111:1111";    /* 1 '1' error */
	stt[2] = "22222222222222242222222223222";    /* 2 '2' in_dq */
	stt[3] = "22222222222222222222222222222";    /* 3 '3' dq_escape */
	stt[4] = "00000000000000020000000000000";    /* 4 '4' dq_in_dq */
	stt[5] = "55555555555555755555555556555";    /* 5 '5' in_q */
	stt[6] = "55555555555555555555555555555";    /* 6 '6' q_escape */
	stt[7] = "00000000000000500000000000000";    /* 7 '7' q_in_q */
	stt[8] = "00000880000000000000000000000";    /* 8 '8' e_digits */
	stt[9] = "1111188111111111JJ11111111111";    /* 9 '9' e_state */
	stt[10] = "01111111111111111111011111111";    /* 10 ':' error_punc */
	stt[11] = "00909;;0000000000000000000000";    /* 11 ';' fraction */
	stt[12] = "0<<<<<<<000000000000000000000";    /* 12 '<' in_id */
	stt[13] = "0<<<<==<000000E000000000K0000";    /* 13 '=' in_int */
	stt[14] = "0000000000000000>>>00>>0>>0>0";    /* 14 '>' in_op */
	stt[15] = "0000000000000000>>>H0>G0>00>0";    /* 15 '?' in_punc */
	stt[16] = "IIIIIIIIIIIIIIIIIIIIIIIIIIIII";    /* 16 '@' in_special */
	stt[17] = "0AAAAAAA0000000000000000R0000";    /* 17 'A' in_var */
	stt[18] = "0BBBBBBB000000000000000000000";    /* 18 'B' in_vartail */
	stt[19] = "O>>BB>>B>>0>>>>>>>>OO>P>>>>>>";    /* 19 'C' in_vertical */
	stt[20] = ">>>>>>>>>>>>>>>>>>0>>>>>>>>>>";    /* 20 'D' init_comment */
	stt[21] = "0EEEEEE0000000000000000000000";    /* 21 'E' int_base */
	stt[22] = "0<<<<==<000000@000000000K0000";    /* 22 'F' int_special */
	stt[23] = ">>>>>>>>>>>>>>>>>>H>>>>>>>>>>";    /* 23 'G' punc_comment */
	stt[24] = "00000000000000000000000000000";    /* 24 'H' punc_space */
	stt[25] = "00000000000000000000000000000";    /* 25 'I' save_special */
	stt[26] = "11111881111111111111111111111";    /* 26 'J' to_e_digits */
	stt[27] = "00000;;0000000000000000000000";    /* 27 'K' to_fraction */
	stt[28] = "L111111110101011111LL1N111111";    /* 28 'L' tv */
	stt[29] = ">>>>>>>>>>>>>>>>>>L>>>>>>>>>>";    /* 29 'M' tv_comment */
	stt[30] = "111111111111111111L1111111111";    /* 30 'N' tv_blank_comment */
	stt[31] = "O00BB00B00000000000OO0Q000000";    /* 31 'O' v_blanks */
	stt[32] = ">>>>>>>>>>>>>>>>>>O>>>>>>>>>>";    /* 32 'P' v_comment */
	stt[33] = "111111111111111111O1111111111";    /* 33 'Q' v_comment2 */
	stt[34] = "111111111111111111111111S1111";    /* 34 'R' add_period */
	stt[35] = "????????????????????????T????";    /* 35 'S' var_period */
	stt[36] = "LLLLLLLLLLLLLLLL>>>LL>MLLLL>L";    /* 36 'T' var_period_period */
	sat[0] = "dccccccconbfmjddccc%dccsccAce";    /* 0 '0' init */
	sat[1] = "ddddddddddddddddddddddddddddd";    /* 1 '1' error */
	sat[2] = "cccccccccccccccdccccccccccccc";    /* 2 '2' in_dq */
	sat[3] = "ccccccccccccccccccccccccccccc";    /* 3 '3' dq_escape */
	sat[4] = "qqqqqqqqxqqqqqqcqqqqqqqqqqqqq";    /* 4 '4' dq_in_dq */
	sat[5] = "ccccccccccccccdcccccccccccccc";    /* 5 '5' in_q */
	sat[6] = "ccccccccccccccccccccccccccccc";    /* 6 '6' q_escape */
	sat[7] = "qqqqqqqqxqqqqqcqqqqqqqqqqqqqq";    /* 7 '7' q_in_q */
	sat[8] = "rrrrrccrrrrrrrrrrrrrrrrrrrrrr";    /* 8 '8' e_digits */
	sat[9] = "eeeeecceeeeeeeeecceeeeeeeeeee";    /* 9 '9' e_state */
	sat[10] = "kdddddddddddddddddddkdddddddd";    /* 10 ':' error_punc */
	sat[11] = "rrcrcccrrrrrrrrrrrrrrrrrrrrrr";    /* 11 ';' fraction */
	sat[12] = "acccccccwaaaaaaaaaaaaaaaaaaaa";    /* 12 '<' in_id */
	sat[13] = "iccccccciiiiiiciiiiiiiiiciiii";    /* 13 '=' in_int */
	sat[14] = "aaaaaaaaaaaaaaaacccaaccaccaca";    /* 14 '>' in_op */
	sat[15] = "haaaaaaaaaaaaaaaccc%hccacaaca";    /* 15 '?' in_punc */
	sat[16] = "ccccccccccccccccccccccccccccc";    /* 16 '@' in_special */
	sat[17] = "vcccccccVvvvvvvvvvvvvvvvvvvvv";    /* 17 'A' in_var */
	sat[18] = "tcccccccttttttttttttttttttttt";    /* 18 'B' in_vartail */
	sat[19] = "dDDyyDDyDDYDDDDDDDD%dDcDDDDDD";    /* 19 'C' in_vertical */
	sat[20] = "DDDDDDDDDDDDDDDDDD/DDDDDDDDDD";    /* 20 'D' init_comment */
	sat[21] = "icccccciiiiiiiiiiiiiiiiiiiiii";    /* 21 'E' int_base */
	sat[22] = "iccccccciiiiiiciiiiiiiiiciiii";    /* 22 'F' int_special */
	sat[23] = "DDDDDDDDDDDDDDDDDD/DDDDDDDDDD";    /* 23 'G' punc_comment */
	sat[24] = "HHHHHHHHHHHHHHHHHHHHhHHHHHHHH";    /* 24 'H' punc_space */
	sat[25] = "iiiiiiiiiiiiiiiiiiiiiiiiiiiii";    /* 25 'I' save_special */
	sat[26] = "eeeeecceeeeeeeeeeeeeeeeeeeeee";    /* 26 'J' to_e_digits */
	sat[27] = "IIIIIccIIIIIIIIIIIIIIIIIIIIII";    /* 27 'K' to_fraction */
	sat[28] = "deeeeeeeeTeTeTeeeee%dedeeeeee";    /* 28 'L' tv */
	sat[29] = "DDDDDDDDDDDDDDDDDD/DDDDDDDDDD";    /* 29 'M' tv_comment */
	sat[30] = "eeeeeeeeeeeeeeeeee/eeeeeeeeee";    /* 30 'N' tv_blank_comment */
	sat[31] = "daayyaayaaYaaaaaaaa%dadaaaaaa";    /* 31 'O' v_blanks */
	sat[32] = "DDDDDDDDDDDDDDDDDD/DDDDDDDDDD";    /* 32 'P' v_comment */
	sat[33] = "eeeeeeeeeeeeeeeeee/eeeeeeeeee";    /* 33 'Q' v_comment2 */
	sat[34] = "eeeeeeeeeeeeeeeeeeeeeeeeceeee";    /* 34 'R' add_period */
	sat[35] = "DDDDDDDDDDDDDDDDDDDDDDDDcDDDD";    /* 35 'S' var_period */
	sat[36] = "DDDDDDDDDDDDDDDDcccDDccDDDDcD";    /* 36 'T' var_period_period */
	}


static BNRP_Boolean BNRP_stringToLong(char *s, long *res)
{
	long base = 10, result = 0, next;
	register char c;

/***** parser can only input positive numbers (minus may be the operator)	
	if (*s EQ '-') {
		++s;
		maxnum = (long) LONG_MIN / base;
		maxoff = labs(LONG_MIN % base);
		while ((c = *s++) NE '\0') {
			if isdigit(c)
				next = (c - '0');
			else if islower(c)
				next = (c - 'a') + 10;
			else if isupper(c)
				next = (c - 'A') + 10;
			else if (c EQ '\'') {
				base = -result;
				result = 0;
				maxnum = (long) LONG_MIN / base;
				maxoff = labs(LONG_MIN % base);
				continue;
				}
			else
				next = 9999;
			if (next > base) return(FALSE);
			if (result LT maxnum) 
				return(FALSE);
			else if ((result EQ maxnum) && (next GT maxoff)) 
				return(FALSE);
			result = result * base - next;
			}
		}
	else {
*****/
	while ((c = *s++) NE '\0') {
		if (isdigit(c))
			next = (c - '0');
		else if (islower(c))
			next = (c - 'a') + 10;
		else if (isupper(c))
			next = (c - 'A') + 10;
		else if (c EQ '\'') {
			/* do we see 0'c, in which case return c as an integer */
			if ((base = result) EQ 0) {
				*res = (long)*s;
				return(TRUE);
				}
			result = 0;
			continue;
			}
		else
			next = 9999;
		if (next > base) return(FALSE);
		result = result * base + next;
		}
	*res = result;
	return(TRUE);
	}
	

/*********************************************************************************

	Variable are stored on the heap in variableEntry's.  For variables,
	the reference field points to itself (unbound variable) and the address
	of the reference field is returned.  For tailvariables, the reference 
	field is marked as a list and points at a unbound tailvariable, which
	is the address returned.  This allows for conversion from X to [X..] at
	any time as the variables all point at the reference field, which can be
	changed to a list.
	
*********************************************************************************/

variableEntry *varChain, *newSymbolChain;

long lookupVariable(variableEntry *s, long *hp)
{
	variableEntry *p;
	int h;

	/* special case if anonymous */
	if ((s->name[0] EQ '_') && (s->name[1] EQ '\0')) {
		long result = makevarterm(*hp);
		push(long, *hp, result);
		return(result);
		}
	h = hashString(s->name);
	p = varChain;
	while (p NE NULL) {
		if ((p->hash EQ h) && (strcmp(p->name, s->name) EQ 0))
			return(p->reference);
		p = p->link;
		}
	/* not found, create new entry */
	*hp += sizeof(variableEntry) + strlen(s->name);		/* commit heap pointer */
	headerLWA(*hp);
	s->hash = h;
	s->link = varChain;
	varChain = s;
	s->reference = makevarterm((long)&s->reference);
	s->mark = VARIABLEMARK;
	return(s->reference);
	}
	
long lookupTailVariable(variableEntry *s, long *hp)
{
	variableEntry *p;
	int h;
	
	/* special case if anonymous */
	if (*s->name EQ '_')
		if ((strcmp(s->name, "_..") EQ 0) || (strcmp(s->name, "_") EQ 0)) {
			long result = maketerm(TVTAG, *hp);
			push(long, *hp, result);
			return(result);
			}
	h = hashString(s->name);
	p = varChain;
	while (p NE NULL) {
		if ((p->hash EQ h) && (strcmp(p->name, s->name) EQ 0)) {
			if (tagof(p->reference) EQ LISTTAG) {
				long addr = addrof(p->reference);
				return(*(long *)addr);		/* return tailvariable */
				}
			else {							/* marked as a variable, convert to a list */
				long result = maketerm(TVTAG, *hp);
				p->reference = maketerm(LISTTAG, *hp);
				push(long, *hp, result);
				return(result);
				}
			}
		p = p->link;
		}
	/* not found, create new entry */
	*hp += sizeof(variableEntry) + strlen(s->name);		/* commit heap pointer */
	headerLWA(*hp);
	s->hash = h;
	s->mark = VARIABLEMARK;
	s->link = varChain;
	varChain = s;
	s->reference = maketerm(LISTTAG, *hp);
	{ long result = maketerm(TVTAG, *hp);
	push(long, *hp, result);
	return(result);
	}}

void convertToTailVariable(long varAddress, long *hp)
{
	long val, *addr;
	
	val = *(long *)varAddress;
	addr = (long *)addrof(val);
	if (tagof(val) EQ LISTTAG) {		/* already there as a tail variable */
		*(long *)varAddress = *addr;
		}
	else {
		long result = maketerm(TVTAG, *hp);
		*addr = maketerm(LISTTAG, *hp);
		push(long, *hp, result);
		*(long *)varAddress = result;
		}
	}

int removeSpecial(variableEntry *s)
{
	char *p, c, buff[3];

	p = s->name;
	while ((p = strchr(p, '\\')) NE NULL) {
		c = *strcpy(p, &p[1]);
		switch (c) {
			case 'a':	*p = '\a';
						break;
			case 'v':	*p = '\v';
						break;
			case 't':	*p = '\t';
						break;
			case 'b':	*p = '\b';
						break;
			case 'f':	*p = '\f';
						break;
			case 'n':	*p = '\n';
						break;
			case 'r':	*p = '\r';
						break;
			case '\\':
			case '\'':
			case '"':
			case '`':
						++p;
						break;
			case 'x':
						buff[0] = p[1];
						buff[1] = p[2];
						buff[2] = '\0';
						if (!isxdigit(buff[0]) || !isxdigit(buff[1])) return(1);
						strcpy(p, &p[2]);		/* remove 2 hex digits */
						c = (unsigned char)strtol(buff, NULL, 16);
						*p++ = c;
						break;
			default:
						buff[0] = c;
						buff[1] = p[1];
						buff[2] = '\0';
						if (!isxdigit(buff[0]) || !isxdigit(buff[1])) return(1);
						strcpy(p, &p[1]);		/* remove first digit */
						c = (unsigned char)strtol(buff, NULL, 16);
						*p++ = c;
						break;
			}
     
		}
	return(0);
	}

BNRP_Boolean isNumber(long n, TAG *tag, long *l)
{
	li t;
	long a;
				
	if (tagof(n) EQ INTTAG) {
		t.l = n;
		*l = t.i.b;
		*tag = INTT;
		return(TRUE);
		}
	else if (tagof(n) EQ STRUCTTAG) {
		a = addrof(n);
		get(long, a, t.l);
		if (t.i.a EQ NUMBERIDshort) {
			if (t.i.b EQ INTIDshort) {
				get(long, a, *l);
				*tag = INTT;
				}
			else {
				fpLWA(a);
				*l = a;				/* pointer to fp */
				*tag = FLOATT;
				}
			return(TRUE);
			}
		}
	return(FALSE);
	}

#define OPunary			(fx + fy + yf + xf)
#define OPbinary		(xfx + yfx + xfy)
#define OPprefix		(fx + fy)
#define OPpostfix		(xf + yf)
#define OPpre_y			(yfx + yf)
#define OPpost_y		(xfy + fy)
#define OPnot_postfix	(xfx + xfy + yfx + fx + fy + bracket)
#define OPnot_prefix	(xfx + xfy + yfx + xf + yf + bracket)

#define STARTBRA		(((bracket + fy) * 0x10000L) + 2047)	/* highest precedence */
#define ENDBRA			((bracket * 0x10000L) + 2046)			/* second highest precedence */
#define OPENBRA			(((bracket + fy) * 0x10000L) + 2045)	/* third highest precedence */
#define CLOSEBRA		((bracket * 0x10000L) + 2044)			/* fourth highest precedence */
#define COMMA			((yfx * 0x10000L) + 1200)
#define VERTICALLIST	0x12345678
#define STARTBRAMARKER	0x0FFFFFF1

#define ENDLIST			0					/* ] */
#define ENDPAR			1					/* ) */
#define ENDCON			2					/* } */
#define ENDPUNC			3					/* final . */

#define NewTempSymbol		s = (variableEntry *)hp; p = s->name

extern li BNRPflags;


#define heapcheck(n)                    if ((tcb->heapend - hp) LE (n * sizeof(long))) \
                                                BNRP_error(HEAPOVERFLOW)


BNRP_Boolean BNRP_parse(TCB *tcb, overloadIOProcedure fileProc, long fileIndex, long *result, long *ioresult)
{
#ifdef unix
	double atof();
#endif
	int class, state = 0, action, brackettype, sawEOF = 0;
	long hp, ce, sp, endce;
	variableEntry *s;
	char *p, ch;
	long token = 0, func, first, second, newstruct, lastoperand;
	BNRP_Boolean expectOperand, newChar, seenPrefix;
	union {
		long opstuff;
		struct {
#ifdef REVERSE_ENDIAN
			short opprec, optype;
#else
			short optype, opprec;
#endif
			} op;
		} L, R;
	long stackspace[200];		/* space for 100 operators */
	
	if (!BNRP_parserInitialized) BNRP_initializeParser();
	*ioresult = KILLED;
	varChain = newSymbolChain = NULL;
	BNRP_freespace(tcb, &ce, &func, &hp, &first);
	endce = ce;
	sp = (long)stackspace;
	headerLWA(sp);
	push(long, sp, STARTBRAMARKER);
	push(long, sp, STARTBRA);
#ifdef debug
	printf("Starting operator stack:"); BNRP_dumpHex(stdout, (void *)stackspace, (void *)sp);
#endif
	expectOperand = newChar = TRUE;
	seenPrefix = FALSE;
	for (;;) {
		NewTempSymbol;

nextchar:
		if (newChar) {
			if (BNRPflags.l & 0x01) {
				BNRPflags.l ^= 0x01;				/* clear bit */
				*ioresult = 1;
#ifdef debug
				printf("flag before read\n"); 
#endif
				return(FALSE);
				}
			(*fileProc)(READCHAR, fileIndex, &ch);
#ifdef echoinput
			printf(">%c<", ch);
#endif
processChar:
			if (BNRPflags.l & 0x01) {
				BNRPflags.l ^= 0x01;				/* clear bit */
				*ioresult = 1;
#ifdef debug
				printf("flag after read\n"); 
#endif
				return(FALSE);
				}
			if (ch EQ EOF) {
				if (sawEOF) { 
					pop(long, sp, first);			/* throw away type and precedence */
					pop(long, sp, first);			/* get token */
					if ((ce EQ endce) && (token EQ 0))
						/* nothing on operator or operand stack */
						*ioresult = NOMORE;
					else
						*ioresult = UNEXPECTEDEOF;
					return(FALSE);
					}
				sawEOF = 1;
				ch = '\n';
				}
			class = charClass[(unsigned char)ch];
			}
		newChar = TRUE;
skipchar:
		action = sat[state][class];
		state = stt[state][class] - '0';
#ifdef debug
		printf("ch = %c, class = %d, action = %c, newstate = %c\n", ch, class, action, state + '0');
		if (class NE charClass[(unsigned char)ch]) printf("\n\n***** Class incorrect *****\n\n");
#endif
		switch (action) {
			case 'C':											/* start new symbol */
						NewTempSymbol;
			case 'c':											/* concat */
						*p++ = ch;
			case 'd':		
						/* If capitals as variables is false (ie capitals are not variables) and 
						   the current character is a quote and we're not stripping out quotes, then 
						   leave the quotes in. Else strip out quotes (by not explicitly leaving them in) */
						if(!capsAsVars && (class == 15 || class == 14) && !strpQuot)
						   *p++ = ch;									/* discard */
						goto nextchar;
			case 'D':											/* defer */
						goto skipchar;
						
			case 'H':											/* halt and reuse */
						/* return this char to stream */
						(*fileProc)(RETURNCHAR, fileIndex, &ch);
			case 'h':											/* halt */
						R.opstuff = ENDBRA;
						brackettype = ENDPUNC;
						token = 0;
						/* don't generate error for nothing to parse */
						if ((expectOperand) && (ce NE endce)) ERROR(MISSINGOPERAND);
						goto checkoperator;

			case 'I':											/* integer_dot */
						(*fileProc)(RETURNCHAR, fileIndex, &ch);
						sawEOF = 0;
						ch = '.';			/* pretend we just got a dot */
						class = r_dot;
						--p;				/* remove dot from integer */
			case 'i':											/* integer */
						*p = '\0';
						if (!BNRP_stringToLong(s->name, &token)) {
							newChar = TRUE;
							ERROR(BADINTEGER);
							}
						token = makeint(&hp, token);
						newChar = FALSE;
						goto operand;
			case 'r':											/* real */
						{
						fp t;

						*p = '\0';
						t = atof(s->name);
						token = makefloat(&hp, &t);
						newChar = FALSE;
						}
						goto operand;
			case 'A':											/* single atom */
						*p++ = ch;
						*p = '\0';
						token = BNRPLookupSymbol(tcb, s->name, TEMPSYM, (s->name[0] NE '$'));
						goto operator;
			case 'a':											/* atom */
						*p = '\0';
						token = BNRPLookupSymbol(tcb, s->name, TEMPSYM, (s->name[0] NE '$'));
						newChar = FALSE;
						goto operator;
			case 'q':											/* quoted string */
						*p = '\0';
						newChar = FALSE;
						if (removeSpecial(s)) ERROR(BADCHARACTER);
						token = BNRPLookupSymbol(tcb, s->name, TEMPSYM, (s->name[0] NE '$'));
						goto operand;

			case 'v':											/* variable */
						*p = '\0';
						token = lookupVariable(s, &hp);
						heapcheck(1);
						newChar = FALSE;
						goto operand;
			case 't':											/* tailvariable */
						*p = '\0';
						token = lookupTailVariable(s, &hp);
						heapcheck(1);
						newChar = FALSE;
						goto operand;
			case 'T':											/* convert to tailvariable */
						if (lastoperand EQ 0) {
							newChar = TRUE;
							ERROR(BADTAILVAR);
							}
						heapcheck(1);
						convertToTailVariable(lastoperand, &hp);
						lastoperand = 0;
						goto skipchar;
						
			case 'b':											/* [ */
						func = maketerm(LISTTAG, ce);
						goto openbrackets;
			case 'm':											/* { */
						func = maketerm(STRUCTTAG, ce);
						push(long, ce, curlyAtom);
#ifdef debug
						printf("Adding functor {} (%08lX)\n", curlyAtom);
#endif
						goto openbrackets;
			case 'o':											/* ( */
						func = 0;
						goto openbrackets;
			case 'x':											/* 'func'( */
						*p = '\0';
						if (removeSpecial(s)) {
							newChar = TRUE;
							ERROR(BADCHARACTER);
							}
			case 'w':											/* func( */
						*p = '\0';
						token = BNRPLookupSymbol(tcb, s->name, TEMPSYM, (s->name[0] NE '$'));
						func = maketerm(STRUCTTAG, ce);
						push(long, ce, token);
#ifdef debug
						printf("Adding functor %s (%08lX)\n", s->name, token);
#endif
						goto openbrackets;
			case 'V':											/* Var( */
						*p = '\0';
						token = lookupVariable(s, &hp);
						heapcheck(1);
						func = maketerm(STRUCTTAG, ce);
						push(long, ce, token);
#ifdef debug
						printf("Adding variable functor %s (%08lX)\n", s->name, token);
#endif
						goto openbrackets;

			case 'f':											/* ] */
						R.opstuff = CLOSEBRA;
						brackettype = ENDLIST;
						token = 0;
						goto checkoperator;
			case 'n':											/* ) */
						R.opstuff = CLOSEBRA;
						brackettype = ENDPAR;
						token = 0;
						goto checkoperator;
			case 'j':											/* } */
						R.opstuff = CLOSEBRA;
						brackettype = ENDCON;
						token = 0;
						goto checkoperator;
			case 'y':											/* defer edinburgh list construction */
						newChar = FALSE;
						first = *(long *)(sp - sizeof(long));
						func = *(long *)(sp - sizeof(long) - sizeof(long));
						if ((first NE OPENBRA) || (tagof(func) NE LISTTAG)) {
							newChar = TRUE;
							ERROR(VERTICALNOTINLIST);
							}
			case 's':											/* , */
						R.opstuff = COMMA;
						token = commaAtom;
						if (expectOperand && !seenPrefix) {
							newChar = TRUE;
							ERROR(MISSINGOPERAND);
							}
						goto checkoperator;
			case 'Y':											/* | then [ */
						first = *(long *)(sp - sizeof(long));
						func = *(long *)(sp - sizeof(long) - sizeof(long));
						if ((first NE OPENBRA) || (tagof(func) NE LISTTAG)) {
							newChar = TRUE;
							ERROR(VERTICALNOTINLIST);
							}
						R.opstuff = COMMA;
						token = VERTICALLIST;
						goto checkoperator;
						
			case '/':											/* eat comment */
						--p;			/* since / in buffer already */
						{
						int nesting = 1;
						char c;
						
						if (!(*fileProc)(GETPOSITION, fileIndex, &BNRP_lastParseErrorPosition)) 
							BNRP_lastParseErrorPosition = -1;
						while (nesting GT 0) {
							(*fileProc)(READCHAR, fileIndex, &c);
						reuse_c:
							if (c EQ '*') {
								(*fileProc)(READCHAR, fileIndex, &c);
								if (c EQ '/') 
									--nesting;
								else
									goto reuse_c;		/* in case we have **/
								}
							else if (c EQ '/') {
								(*fileProc)(READCHAR, fileIndex, &c);
								if (c EQ '*') 
									++nesting;
								else
									goto reuse_c;
								}
							else if (c EQ EOF) {
								*ioresult = COMMENTNOTCOMPLETE;
								return(FALSE);
								}
							}
						}
						ch = ' ';
						class = r_blank;
						goto skipchar;
			case '%':											/* end of line comment */
						while ((ch NE '\n') && (ch NE EOF)) {
							(*fileProc)(READCHAR, fileIndex, &ch);
							}
						goto processChar;		/* either ch = '\n' or EOF */
						
			case 'e':											/* error */
						goto nextchar;
			case 'k':											/* kill */
						return(FALSE);
			
			default:
						newChar = TRUE;
						ERROR(UNEXPECTEDACTION);
			}
		
operand:
		if (!expectOperand) {
			newChar = TRUE;
			ERROR(MISSINGOPERATOR);
			}
		lastoperand = ce;
		push(long, ce, token);
#ifdef debug
		printf("Adding operand %08lX\n", token);
#endif
		expectOperand = seenPrefix = FALSE;
		goto loop;
		
openbrackets:
		if (!expectOperand) {					/* !!!!! */
			newChar = TRUE;
			ERROR(MISSINGOPERATOR);
			}
#ifdef debug
		printf("Adding bracket %08lX\n", func);
#endif
		push(long, sp, func);
		push(long, sp, OPENBRA);
		seenPrefix = FALSE;						/**** added *******/
		goto loop;
		
operator:
		R.op.optype = symof(token)->opType;
		if (R.op.optype EQ notOp) goto operand;
		if (expectOperand) {
			if ((R.op.optype &= OPprefix) EQ 0) goto operand;
			seenPrefix = TRUE;
			}
		else {
			R.op.optype &= OPnot_prefix;
			seenPrefix = FALSE;
			}
		R.op.opprec = symof(token)->opPrecedence;
		lastoperand = 0;
checkoperator:
		if (seenPrefix) {
			if ((R.op.optype & OPprefix) EQ 0) {		/* convert prefix op to operand */
				/* ERROR(INCORRECTOPERATOR); */
				pop(long, sp, L.opstuff);				/* ignore operator stuff */
				pop(long, sp, func);					/* get atom */
				lastoperand = ce;
				push(long, ce, func);					/* put on operand stack */
				seenPrefix = FALSE;
#ifdef debug
				printf("Adding operator as operand %08lX\n", func);
#endif
				}
			else
				R.op.optype &= OPprefix;
			}
		pop(long, sp, L.opstuff);
#ifdef debug
		printf("Comparing operator type = %04X, precedence = %d\n", L.op.optype, L.op.opprec);
		printf("       with right, type = %04X, precedence = %d\n", R.op.optype, R.op.opprec);
#endif
		while (L.op.opprec LE R.op.opprec) {			/* possible reductions */
			if (L.op.opprec EQ R.op.opprec) {			/* use types to discrimate if equal */
				if ((R.op.optype & OPpre_y) NE 0)		/* reduce if R in yf, yfx */
					R.op.optype &= OPpre_y;
				else									/* push */
					break;								/* out of reduce loop */
				}
			else
				if ((R.op.optype & OPnot_prefix) EQ 0) {
					newChar = TRUE;
					ERROR(NOTPREFIXOP);
					}
			if (L.op.optype EQ notOp) {
				newChar = TRUE;
				ERROR(NOMOREOPCHOICES);
				}
			pop(long, sp, func);					/* get principal functor */
			if ((func LE 0) && (tagof(func) NE SYMBOLTAG)) break;
			if ((L.op.optype & OPunary) NE 0) {		/* unary */
				TAG tag;
				
				pop(long, ce, first);				/* get only argument */
				if (ce LT endce) {
					newChar = TRUE;
					ERROR(MISSINGOPERAND);
					}
				if ((func EQ minusAtom) && isNumber(first, &tag, &second)) {
					/* special case of -(number), handle inline */
					if (tag EQ INTT)
						newstruct = makeint(&hp, -second);
					else {
						fp f;
						
						fpLWA(second);
						f = - *(fp *)second;
						newstruct = makefloat(&hp, &f);
						}
					}
				else {
					newstruct = maketerm(STRUCTTAG, hp);
					heapcheck(4);
					push(long, hp, UNARYHEADER);
					push(long, hp, func);				/* push functor */
					push(long, hp, first);				/* push argument */
					push(long, hp, 0);					/* end of sequence */
					}
				}
			else if ((L.op.optype & OPbinary) NE 0) {	/* dyadic */
				pop(long, ce, second);				/* get second argument */
				pop(long, ce, first);				/* get first argument */
				if (ce LT endce) {
					newChar = TRUE;
					ERROR(MISSINGOPERAND);
					}
				newstruct = maketerm(STRUCTTAG, hp);
				heapcheck(5);
				push(long, hp, BINARYHEADER);
				push(long, hp, func);				/* push functor */
				push(long, hp, first);				/* push first argument */
				push(long, hp, second);				/* now put down second argument */
				push(long, hp, 0);					/* end of sequence */
				}
			else {
				newChar = TRUE;
				ERROR(UNRECOGNIZEDOPTYPE);
				}
			push(long, ce, newstruct);				/* push resulting pointer back on */
			pop(long, sp, L.opstuff);				/* get next operator */
#ifdef debug
			printf("After reduce:\n");
			printf("Operator stack:"); BNRP_dumpHex(stdout, (void *)stackspace, (void *)sp);
			printf("Operand stack:"); BNRP_dumpHex(stdout, (void *)endce, (void *)ce);
			printf("Heap:"); BNRP_dumpHex(stdout, (void *)tcb->hp, (void *)hp);
			printf("Comparing operator type = %04X, precedence = %d\n", L.op.optype, L.op.opprec);
			printf("       with right, type = %04X, precedence = %d\n", R.op.optype, R.op.opprec);
#endif
			}
		/* push */
		if (L.op.opprec EQ R.op.opprec)				/* if L = R then */
			L.op.optype &= OPpost_y;				/* restrict op to be xfy, fy */
		else {										/* else L > R */
			if (token EQ commaAtom) {
#ifdef debug
				printf("comma\n");
#endif
				push(long, sp, L.opstuff);			/* push L back on stack */
				expectOperand = TRUE;
				seenPrefix = FALSE;
				goto loop;
				}
			else if (token EQ VERTICALLIST) {
#ifdef debug
				printf("| then [\n");
#endif
				push(long, sp, L.opstuff);			/* push L back on stack */
				expectOperand = TRUE;
				seenPrefix = FALSE;
				func = LISTTAG;
				goto openbrackets;
				}
			else if (R.op.optype & bracket) {
				register long addr;
				long orig, arity, last;
				
				if (!(L.op.optype & bracket)) {
					newChar = TRUE;
					ERROR(MISMATCHEDBRACKETS);
					}
				pop(long, sp, func);
#ifdef debug
				printf("Comparing closing bracket %d with %08lX\n", brackettype, func);
#endif
				switch (brackettype) {
					case ENDCON:
									if (tagof(func) NE STRUCTTAG) {
										newChar = TRUE;
										ERROR(BRACKETMISMATCH);
										}
									orig = addr = addrof(func);
									if (*(long *)addr NE curlyAtom) {
										newChar = TRUE;
										ERROR(BRACKETMISMATCH);
										}
									goto finishbra;
					case ENDPAR:
									if (func EQ 0) goto loop;		/* matching ( */
									if (tagof(func) NE STRUCTTAG) {
										newChar = TRUE;
										ERROR(BRACKETMISMATCH);
										}
									orig = addr = addrof(func);
							finishbra:
									expectOperand = FALSE;
									token = maketerm(STRUCTTAG, hp);
									arity = (ce - addr) / 4;
									if (arity GE MAXARGS) {
										newChar = TRUE;
										ERROR(TOOMANYARGS);
										}
									pop(long, ce, last);
									if (tagof(last) EQ TVTAG) arity = -arity;
									heapcheck(ce - addr + 3);
									push(long, hp, FUNCID | (arity & 0x0000FFFF));
									while (addr LT ce) {
										get(long, addr, first);
										push(long, hp, first);
										}
									push(long, hp, last);	/* save last item as well */
									push(long, hp, 0);		/* end of structure */
									ce = orig;				/* restore ce */
									push(long, ce, token);
									goto loop;
					case ENDLIST:
									if (tagof(func) NE LISTTAG) {
										newChar = TRUE;
										ERROR(BRACKETMISMATCH);
										}
									if (func EQ LISTTAG) goto loop;	/* from | [ */
									orig = addr = addrof(func);
									expectOperand = FALSE;
									token = maketerm(LISTTAG, hp);
									/* copy from addr to ce onto hp */
									heapcheck(ce - addr + 2);
									while (addr LT ce) {
										get(long, addr, first);
										push(long, hp, first);
										}
									push(long, hp, 0);		/* end of list */
									ce = orig;				/* restore ce */
									push(long, ce, token);
									goto loop;
					case ENDPUNC:
									if (func NE STARTBRAMARKER) {		/* must be matching open */
										*ioresult = INCOMPLETE;
										return(FALSE);
										}
									*result = maketerm(LISTTAG, hp);
									heapcheck(ce - endce + 3);
									while (ce NE endce) {
										get(long, endce, func);
										push(long, hp, func);
										}
									push(long, hp, 0);
									push(long, hp, 0);
									tcb->hp = hp;			/* commit changes made */
									*ioresult = 0;
									return(TRUE);
					}
				newChar = TRUE;
				ERROR(SYNTAX);
				}
			else
				L.op.optype &= OPnot_postfix;			/* restrict op to be xfx, xfy, yfx, fx, fy */
			}
		if (L.op.optype EQ 0) {				/* error if no remaining choices */
			newChar = TRUE;
			ERROR(NOMOREOPCHOICES);
			}
		push(long, sp, L.opstuff);
#ifdef debug
		printf("Pushing operator %08lX, type = %04X, precedence = %d\n", token, R.op.optype, R.op.opprec);
#endif
		push(long, sp, token);
		push(long, sp, R.opstuff);
		if ((R.op.optype & OPbinary) NE 0) {
			expectOperand = TRUE;
			seenPrefix = FALSE;
			}

loop:	;
#ifdef debug
		printf("Operator stack:"); BNRP_dumpHex(stdout, (void *)stackspace, (void *)sp);
		printf("Operand stack:"); BNRP_dumpHex(stdout, (void *)endce, (void *)ce);
		printf("Heap:"); BNRP_dumpHex(stdout, (void *)tcb->hp, (void *)hp);
#endif
		}
	return(token NE 0);
	}



BNRP_Boolean BNRP_parseError(TCB *tcb)
{
	return((tcb->numargs EQ 1) && 
		   (unify(tcb, tcb->args[1], makeint(&tcb->hp, BNRP_lastParseErrorPosition))));
	}
	

BNRP_Boolean BNRP_capitalsAsVariables(TCB *tcb)
{
   TAG tag;
   long flag;
   int i;
   
   if(tcb->numargs NE 1) return FALSE;
   
   tag = checkArg(tcb->args[1],&flag);
   
   if(tag EQ VART)
   {
      /* Query the status of how the parser handles capital letters */
      if(capsAsVars)
      {
	 /* Treats them as variables */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "true")));
      }
      else
      {
	 /* Treats them as symbols */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "false")));
      }
   }
   else if(tag EQ SYMBOLT)
   {
      if(strcmp(nameof(flag),"true") EQ 0)
      {
	 /* Treat capitals as variables */
	 for (i = 0; i LE 255; ++i)
	 {
	    if (isascii((char)i))
	    {
	       if (isupper((char)i))
		  charClass[i] = r_capital;
	    }
	 }	 
	 capsAsVars = TRUE;
      }
      else if(strcmp(nameof(flag),"false") EQ 0)
      {
	 /* Treat capitals as symbols */
	 for (i = 0; i LE 255; ++i)
	 {
	    if (isascii((char)i))
	    {
	       if (isupper((char)i))
		  charClass[i] = r_letter;
	    }
	 }
	 capsAsVars = FALSE;
      }
      else
      {
	 return FALSE;
      }
   }
   else
   {
      return FALSE;
   }
   
   return TRUE;
}
 

BNRP_Boolean BNRP_underscoreAsVariable(TCB *tcb)
{
   /* Allows the parser interpretation of the underscore as an anonomous
      variable (and as the initial character of a variable) to be turned off; 
      instead treating it as a normal, lower-case letter. */
   TAG tag;
   long flag;
   int i;
   
   if(tcb->numargs NE 1) return FALSE;
   
   tag = checkArg(tcb->args[1],&flag);
   
   if(tag EQ VART)
   {
      /* Query the status of how the parser handles '_' */
      if(u_scoreAsVar)
      {
	 /* Treats '_' as variable */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "true")));
      }
      else
      {
	 /* Treats '_' as symbol */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "false")));
      }
   }
   else if(tag EQ SYMBOLT)
   {
      /* Set the status of how the parser handles '_' */
      if(strcmp(nameof(flag),"true") EQ 0)
      {
	 /* Treat '_' as variable */
	charClass[(unsigned char)'_'] = r_bar;
	u_scoreAsVar = TRUE;
      }
      else if(strcmp(nameof(flag),"false") EQ 0)
      {
	 /* Treat '_' as symbol */
	charClass[(unsigned char)'_'] = r_letter;
	u_scoreAsVar = FALSE;
      }
      else
      {
	 return FALSE;
      }
   }
   else
   {
      return FALSE;
   }
   
   return TRUE;
}

BNRP_Boolean BNRP_stripQuotes(TCB *tcb)
{
   /* Allows the parser to choose whether or not to strip out quotes when the
      capitalsAsVariables flag (capsAsVars) is set to FALSE.  In some cases it is 
      useful to have quotes around a single word beginning with a capital letter, ie.
      for the lint debugger - other times it is more useful to have no quotes. 
      Is ONLY important when capsAsVars = FALSE*/
   TAG tag;
   long flag;
   int i;
   
   if(tcb->numargs NE 1) return FALSE;
   
   tag = checkArg(tcb->args[1],&flag);
   
   if(tag EQ VART)
   {
      /* Query the status of how the parser handles quotes */
      if(strpQuot)
      {
	 /* Quotes are currently being stripped */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "true")));
      }
      else
      {
	 /* Quotes are currently being left (or added) */
	 return(unify(tcb,tcb->args[1], BNRPLookupTempSymbol(tcb, "false")));
      }
   }
   else if(tag EQ SYMBOLT)
   {
      /* Set the status of how the parser handles quotes */
      if(strcmp(nameof(flag),"true") EQ 0)
      {
	 /* Strip out quotes = true*/
	strpQuot = TRUE;
      }
      else if(strcmp(nameof(flag),"false") EQ 0)
      {
	 /* Don't srtip out (ie. add) quotes = false*/
	strpQuot = FALSE;
      }
      else
      {
	 return FALSE;
      }
   }
   else
   {
      return FALSE;
   }
   
   return TRUE;
}

