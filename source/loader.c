/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/loader.c,v 1.6 1997/08/12 17:35:05 harrisj Exp $
 *
 * $Log: loader.c,v $
 * Revision 1.6  1997/08/12  17:35:05  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.5  1996/02/13  04:18:33  yanzhou
 * The version numbers of the compiler and the code generator are increased:
 *     compiler from version 25 to version 26,
 *     code generator from time stamp Oct/31/1991 to Feb/15/1996.
 *
 * Revision 1.4  1996/02/08  05:03:14  yanzhou
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
 * Revision 1.4  1996/02/08  04:59:12  yanzhou
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
 * Revision 1.3  1996/02/06  04:38:39  yanzhou
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
 * Revision 1.2  1996/02/01  03:29:48  yanzhou
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
 * Revision 1.1  1995/09/22  11:25:04  harrisja
 * Initial version.
 *
 *
 */
#include <stdio.h>
#include <ctype.h>
#include <setjmp.h>
#include <string.h>
#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "context.h"
#include "interpreter.h"
#include "loader.h"
#include "prim.h"
#include "hash.h"
#include "hardware.h"
#include "utility.h"
#ifndef unix
#include <stdlib.h>			/* for strtol, atol, atof */
#endif
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
#include <errno.h>
#include <sys/errno.h>
#endif

/*#define debug 			/* used to output the .a file as we read through it */
/*#define debugMessages 	/* used to output messages in case of errors */

#define STARTFREESPACE		4096
#define STARTBUFFSIZE		1024
#define STARTNUMREFS		500
#define COMPILERVERSION		26
#define CODEGENDAY			15
#define CODEGENYEAR			96
#define CODGENMONTH			"Feb"


struct symRef {
	BNRP_term ref;
	long key;
	} *BNRP_refs;
int BNRP_numRefs;	
char *BNRP_freePtr, *BNRP_freeSpace, *BNRP_buffSpace;
long BNRP_freeSize, BNRP_buffSize;


static int checkVersion(FILE *f)
{
	int ver, day, year;
	char month[20];
	
	fscanf(f, " ; Compiler Version version %d ; Code Generator Version %[^/]/%d/%d", 
				&ver, month, &day, &year);
	return ((ver NE COMPILERVERSION) ||
			(day NE CODEGENDAY) ||
			(year NE CODEGENYEAR) ||
			(strcmp(month, CODGENMONTH)));
	}

jmp_buf loadbuf;

static void loadError(long err)
{
	longjmp(loadbuf, err);
	}

#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
#define getachar(f, ch)		errno = 0; \
							while ((ch = fgetc(f)) EQ EOF) { \
								if ((ferror(f)) && (errno EQ EINTR)) { \
									clearerr(f); \
									errno = 0; \
									continue; \
									} \
								break; \
								}
#else
#define getachar(f, ch)		ch = fgetc(f);
#endif

static int getToken(int maxLen, FILE *f)
{
	char ch, *buff;
	int numGotten = 0;
	int inQuotes = 1;
	BNRP_Boolean expectSpecial = FALSE;
	BNRP_Boolean skip = FALSE;
	
	buff = BNRP_buffSpace;
	while (!feof(f)) {
		if (maxLen LT 0) {
			if (numGotten GE BNRP_buffSize) {
				long offset;
				
				BNRP_buffSize += STARTBUFFSIZE;
				offset = (long)buff - (long)BNRP_buffSpace;
				BNRP_buffSpace = (char *) BNRP_realloc(BNRP_buffSpace, BNRP_buffSize);
				if (BNRP_buffSpace EQ NULL) {
#ifdef debugMessages
					printf("Unable to increase size of symbol buffer to %ld bytes\n", BNRP_buffSize);
#endif
					loadError(OUTOFTEMPSPACE);
					}
				buff = (char *)((long)BNRP_buffSpace + offset);
				}
			}
		else	/* numGotten >= 0, so stop when we get that many characters */
			if (numGotten GE maxLen) break;
		getachar(f, ch);
#ifdef debug
		printf("%c", ch);
#endif
		if (inQuotes EQ 1) {
			if (ch EQ ';') {
				getachar(f, ch);
				ungetc(ch, f);
				if (ch EQ '\n')
					ch = ';';
				else {
					for (;;) {
						getachar(f, ch);
						if (ch EQ 0) break;
#ifdef debug
						printf("%c", ch);
#endif
						if (ch EQ '\\') { 
							getachar(f, ch);
							continue; 
							}
						if ((ch EQ '\'') || (ch EQ '\"')) inQuotes = -inQuotes;
						if (inQuotes EQ 1)
							if (ch EQ '\n') break;
						if (feof(f)) break;
						}
					ch = ' ';
					}
				}
			if ((isascii(ch) && (isspace(ch))) || (ch EQ EOF)) {
				if (numGotten) break;
				skip = TRUE;
				}
			}
		if (expectSpecial) {
			expectSpecial = FALSE;
			if (ch EQ 'n') ch = '\n';
			else if (ch EQ 't') ch = '\t';
			else if (ch EQ 'b') ch = '\b';
			else if (ch EQ 'r') ch = '\r';
			else if (ch EQ 'f') ch = '\f';
			else if (isxdigit(ch)) {
				char temp[3];
				
				temp[0] = ch;
				getachar(f, temp[1]);
#ifdef debug
				printf("%c", temp[1]);
#endif
				temp[2] = '\0';
				ch = strtol(temp, NULL, 16);
				}
			++numGotten;
			*buff++ = ch;
			}
		else if ((ch EQ '\'') || (ch EQ '\"'))
			inQuotes = -inQuotes;
		else if (ch EQ '\\')
			expectSpecial = TRUE;
		else if (skip)
			skip = FALSE;
		else {
			++numGotten;
			*buff++ = ch;
			}
		}
	*buff = '\0';
	return(numGotten);
	}

void skipToken(FILE *f)
{
	char ch;
	int numGotten = 0;
	int inQuotes = 1;
	BNRP_Boolean expectSpecial = FALSE;
	BNRP_Boolean skip = FALSE;
	
	while (!feof(f)) {
		getachar(f, ch);
#ifdef debug
		printf("%c", ch);
#endif
		if (inQuotes EQ 1) {
			if (ch EQ ';') {
				getachar(f, ch);
				ungetc(ch, f);
				if (ch EQ '\n')
					ch = ';';
				else {
					for (;;) {
						getachar(f, ch);
						if (ch EQ 0) break;
#ifdef debug
						printf("%c", ch);
#endif
						if (ch EQ '\\') { 
							getachar(f, ch);
							continue; 
							}
						if ((ch EQ '\'') || (ch EQ '\"')) inQuotes = -inQuotes;
						if (inQuotes EQ 1)
							if (ch EQ '\n') break;
						if (feof(f)) break;
						}
					ch = ' ';
					}
				}
			if ((isascii(ch) && (isspace(ch))) || (ch EQ EOF)) {
				if (numGotten) break;
				skip = TRUE;
				}
			}
		if (expectSpecial) {
			expectSpecial = FALSE;
			if (ch EQ 'n') ch = '\n';
			else if (ch EQ 't') ch = '\t';
			else if (ch EQ 'b') ch = '\b';
			else if (ch EQ 'r') ch = '\r';
			else if (ch EQ 'f') ch = '\f';
			else if (isxdigit(ch)) {
				getachar(f, ch);
#ifdef debug
				printf("%c", ch);
#endif
				}
			++numGotten;
			}
		else if ((ch EQ '\'') || (ch EQ '\"'))
			inQuotes = -inQuotes;
		else if (ch EQ '\\')
			expectSpecial = TRUE;
		else if (skip)
			skip = FALSE;
		else {
			++numGotten;
			}
		}
	}

int remHeadBytes[256] = {  0, 0, 0, 0, -4, 4, 0, 0,				/* 00 - 07 */
							 -6, -4, -4, -4, -4, -4, -4, -4,	/* 08 - 0F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 10 - 17 */
							-1,-1,-1,-1,-1,-1,-1,-1,			/* 18 - 1F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 20 - 27 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 28 - 2F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 30 - 37 */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 38 - 3F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 40 - 47 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 48 - 4F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 50 - 57 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 58 - 5F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 60 - 67 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 68 - 6F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 70 - 77 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 78 - 7F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 80 - 87 */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 88 - 8F */
							 2,-1, 0, 0, 0, 0, 0, 0,			/* 90 - 97 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 98 - 9F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* A0 - A7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* A8 - AF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* B0 - B7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* B8 - BF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* C0 - C7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* C8 - CF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* D0 - D7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* D8 - DF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* E0 - E7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* E8 - EF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* F0 - F7 */
							 2, 0, 0, 0, 0, 0, 0, 0 };			/* F8 - FF */
int remBodyBytes[256] = {  0, 0, 0, 0, -4, 0, 0, -80,			/* 00 - 07 */
							 -6, -4, -4, -4, -4, -4, -4, -4,	/* 08 - 0F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 10 - 17 */
							-1,-1,-1,-1,-1,-1,-1,-1,			/* 18 - 1F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 20 - 27 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 28 - 2F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 30 - 37 */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 38 - 3F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 40 - 47 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 48 - 4F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 50 - 57 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 58 - 5F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 60 - 67 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 68 - 6F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 70 - 77 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 78 - 7F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 80 - 87 */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 88 - 8F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 90 - 97 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 98 - 9F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* A0 - A7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* A8 - AF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* B0 - B7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* B8 - BF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* C0 - C7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* C8 - CF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* D0 - D7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* D8 - DF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* E0 - E7 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* E8 - EF */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* F0 - F7 */
							 2, 0, 0, 0, 0, 0, 0, 0 };			/* F8 - FF */
int remEscBytes[256] = {  0, 2, 0, 0, -90, 0, -1, -1,			/* 00 - 07 */
							 -1, 2, -62, 0, -60, 2, 0, 0,		/* 08 - 0F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 10 - 17 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 18 - 1F */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 20 - 27 */
							 2, 0, 0, 0, 0, 0, 0, 0,			/* 28 - 2F */
							 0, 2, 0, 0, 0, 2, 0, 0,			/* 30 - 37 */
							-1,-1,-1,-1,-1,-1,-1,-1,			/* 38 - 3F */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 40 - 47 */
							 4, 2, 2, 2, 2, 2, 2, 2,			/* 48 - 4F */
							 4, 2, 2, 2, 2, 2, 2, 2,					/* 50 - 57 */
							 4, 2, 2, 2, 2, 2, 2, 2,					/* 58 - 5F */
							 -82, -80, -80, -80, -80, -80, -80, -80,	/* 60 - 67 */
							 -82, -80, -80, -80, -80, -80, -80, -80,	/* 68 - 6F */
							 4, 2, 2, 2, 2, 2, 2, 2,					/* 70 - 77 */
							 4, 2, 2, 2, 2, 2, 2, 2,					/* 78 - 7F */
							 4, 2, 2, 2, 2, 2, 2, 2,					/* 80 - 87 */
							-1,-1,-1,-1,-1,-1,-1,-1,					/* 88 - 8F */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* 90 - 97 */
							 0, -80, -80, -80, -80, -80, -80, -80,		/* 98 - 9F */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* A0 - A7 */
							 -1, -80, -80, -80, -80, -80, -80, -80,		/* A8 - AF */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* B0 - B7 */
							 -1, -80, -80, -80, -80, -80, -80, -80,		/* B8 - BF */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* C0 - C7 */
							 -1, -80, -80, -80, -80, -80, -80, -80,		/* C8 - CF */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* D0 - D7 */
							 -1, 2, 2, 2, 2, 2, 2, -80,					/* D8 - DF */
							 2, 0, 0, 0, 0, 0, -60, 0,					/* E0 - E7 */
							 -1, -80, -80, -80, -80, -80, -80, -80,		/* E8 - EF */
							 2, 0, 0, 0, 0, 0, 0, 0,					/* F0 - F7 */
							 -80, -80, -80, -80, -80, -80, -80, -80 };	/* F8 - FF */
static int convert(char c)
{
	if ((c >= '0') && (c <= '9'))
		return(c - '0');
	else if ((c >= 'A') && (c <= 'F'))
		return(c - 'A' + 10);
	else if ((c >= 'a') && (c <= 'f'))
		return(c - 'a' + 10);
	else {
#ifdef debugMessages
		printf("Unable to convert >>%c<<\n", c);
#endif
		return(0);
		}
	}

static short getWord(char *c)
{
	short res;
	
	res = convert(c[0]);
	res = (res << 4) + convert(c[1]);
	res = (res << 4) + convert(c[2]);
	res = (res << 4) + convert(c[3]);
	return(res);
	}
	
static char getByte(char *c)
{
	return((convert(c[0]) << 4) + convert(c[1]));
	}

#define addByte(b)		*(BYTE *)BNRP_freePtr = b; \
						BNRP_freePtr += sizeof(BYTE) / sizeof(char)
#define addWord(w)		*(short *)BNRP_freePtr = b; \
						BNRP_freePtr += sizeof(short) / sizeof(char)
#define addLong(l)		constantLWA(BNRP_freePtr); \
						*(long *)BNRP_freePtr = l; \
						BNRP_freePtr += sizeof(long) / sizeof(char)

static BNRP_Boolean findOp(char *p, short *pr, short *ty, BNRP_term *a)
{
	char *pp, c;
	
	if (*p++ NE '(') return(FALSE);
	*pr = strtol(p, &pp, 0);
	*ty = notOp;
	while (*pp EQ ',') {
		++pp;
		if ((c = *pp++) EQ 'x') {
			if (*pp++ EQ 'f') {
				if ((c = *pp++) EQ 'x')
					*ty += xfx;
				else if (c EQ 'y')
					*ty += xfy;
				else {
					*ty += xf;
					--pp;
					}
				}
			}
		else if (c EQ 'y') {
			if (*pp++ EQ 'f') {
				if (*pp++ EQ 'x')
					*ty += yfx;
				else {
					*ty += yf;
					--pp;
					}
				}
			}
		else if (c EQ 'f') {
			if ((c = *pp++) EQ 'x')
				*ty += fx;
			else
				*ty += fy;
			}
		else
			return(FALSE);
		}
	if (*pp++ NE ')') return(FALSE);
	if (*pp++ NE '=') return(FALSE);
	*a = BNRPLookupPermSymbol(pp);
	return(TRUE);
	}

static void checkIndex(short index)
{
	if (index GE BNRP_numRefs) {
		BNRP_refs = (struct symRef *) BNRP_realloc(BNRP_refs, (index + 50) * sizeof(struct symRef));
		if (BNRP_refs EQ NULL) 
			index = -1;
		else while(BNRP_numRefs+1 LT (index+50))
			BNRP_refs[++BNRP_numRefs].ref = 0;
		}
	if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
		printf("Invalid symbol in checkIndex\n");
#endif
		loadError(LOADTOOMANYSYMBOLS);
		}
	}

int loadFile(const char *filename)
{
#ifdef unix
	long atol();
	double atof();
#endif
	FILE *f;
	short inProc, index;
	long arity = 0, key = 0;
	int i, j;
	BNRP_term a = 0;
	short pr, ty;
	BNRP_Boolean inBody, sawESC;
  
	if ((f = fopen(filename, "r")) EQ NULL) {
#ifdef debugMessages
		printf("Unable to find %s\n", filename);
#endif
		return(BADFILENAME);
		}
	if (checkVersion(f)) {
#ifdef debugMessages
		printf("Incorrect compiler and/or code generator used\n");
#endif
		return(BADFILENAME);
		}
	BNRP_freeSize = STARTFREESPACE;
	BNRP_freeSpace = (char *) BNRP_malloc(BNRP_freeSize);
	if (BNRP_freeSpace EQ NULL) {
#ifdef debugMessages
		printf("Unable to allocate temporary space for clause\n");
#endif
		return(LOADNOTEMPSPACE);
		}
	BNRP_buffSize = STARTBUFFSIZE;
	BNRP_buffSpace = (char *) BNRP_malloc(BNRP_buffSize);
	if (BNRP_buffSpace EQ NULL) {
#ifdef debugMessages
		printf("Unable to allocate temporary space for symbols\n");
#endif
		BNRP_free(BNRP_freeSpace);
		return(LOADNOTEMPSPACE);
		}
	BNRP_numRefs = STARTNUMREFS;
	BNRP_refs = (struct symRef *) BNRP_malloc(STARTNUMREFS*sizeof(struct symRef));
	if (BNRP_refs EQ NULL) {
#ifdef debugMessages
		printf("Unable to allocate array for symbol references\n");
#endif
		BNRP_free(BNRP_freeSpace);
		BNRP_free(BNRP_buffSpace);
		return(LOADNOTEMPSPACE);
		}
	for (i = 0; i LT BNRP_numRefs; ++i)
		BNRP_refs[i].ref = 0;
	onerrorexecute(loadError);
	if (i = setjmp(loadbuf)) {
		onerrorexecute(NULL);
		if (BNRP_refs NE NULL) BNRP_free(BNRP_refs);
		if (BNRP_freeSpace NE NULL) BNRP_free(BNRP_freeSpace);
		if (BNRP_buffSpace NE NULL) BNRP_free(BNRP_buffSpace);
#ifdef debugMessages
		printf("Unexpected error %ld during load\n", (long)i);
		for (j = 0; j LT 5; ++j) {
			if (fgets(BNRP_buffSpace, BNRP_buffSize, f) EQ (char *)NULL) {
				printf("EOF??\n");
				break;
				}
			printf("%s", BNRP_buffSpace);
			}
#endif
		return(i);
		}

#ifdef debugMessages
	printf("Loading %s pass #1...\n", filename);
#endif
	while (getToken(2, f)) {
		if ((BNRP_buffSpace[0] EQ 's') && (BNRP_buffSpace[1] EQ 'y')) {
			inProc = 0;
			getToken(1, f);		/* get rid of (sy)m */
			getToken(-1, f);
			index = -getWord(BNRP_buffSpace);
			checkIndex(index);
			switch (BNRP_buffSpace[5]) {
				case 's':								/* symbol sym=name */
							a = BNRPLookupPermSymbol(&BNRP_buffSpace[9]);
							break;
				case 'i':								/* symbol int=value */
							a = BNRPMakePermInt(atol(&BNRP_buffSpace[9]));
							break;
				case 'f':								/* symbol flt=value */
							{	fp t = atof(&BNRP_buffSpace[9]);
								a = BNRPMakePermFloat(&t);
								}
							break;
				case 'o':								/* operator op(prec,type)=name */
#ifdef debugMessages
							if (findOp(&BNRP_buffSpace[7], &pr, &ty, &a)) {
								if ((symof(a)->opType NE ty) || (symof(a)->opPrecedence NE pr))
									printf("Warning:  Operator \"%s\" defined differently than at compile time\n", nameof(a));
								}
							else
								printf("Unrecognized op definition\n");
#else
							(void)findOp(&BNRP_buffSpace[7], &pr, &ty, &a);
#endif
							break;
				case 'n':								/* operator newop(prec,type)=name */
							if (findOp(&BNRP_buffSpace[10], &pr, &ty, &a)) {
#ifdef debugMessages
								if (!BNRP_addOperator(a, ty, pr))
									printf("Warning:  Unable to change definition of operator \"%s\"\n", nameof(a));
#else
								(void)BNRP_addOperator(a, ty, pr);
#endif
								}
#ifdef debugMessages
							else
								printf("Unrecognized newop definition\n");
#endif
							break;
#ifdef debugMessages
				default:	
							printf("unrecognized symbol type\n");
#endif
				}
			BNRP_refs[index].ref = a;
			BNRP_refs[index].key = 0;
			}
		else {
			register int j;
			/* flush out rest of line */
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
			errno = 0;
			for (;;) {
				while ((j = fgetc(f)) EQ EOF) {
					if ((ferror(f)) && (errno EQ EINTR)) {
						clearerr(f);
						errno = 0;
						continue;
						}
					break;
					}
				if ((j EQ '\n') || (j EQ EOF)) break;
				}
#else
			while ((j = fgetc(f)) NE '\n')
				if (j EQ EOF) break;
#endif
			}
		}

#ifdef debugMessages
	printf("Loading %s pass #2...\n", filename);
#endif
	f = freopen(filename, "r", f);
	inProc = 0;
	BNRP_freePtr = BNRP_freeSpace;
	while (getToken(2, f)) {
		if (((long)BNRP_freePtr - (long)BNRP_freeSpace) GT (BNRP_freeSize - 20)) {
			long offset;
			
			BNRP_freeSize += STARTFREESPACE;
			offset = (long)BNRP_freePtr - (long)BNRP_freeSpace;
			BNRP_freeSpace = (char *) BNRP_realloc(BNRP_freeSpace, BNRP_freeSize);
			if (BNRP_freeSpace EQ NULL) {
#ifdef debugMessages
				printf("Unable to allocate more temp space\n");
#endif
				loadError(OUTOFTEMPSPACE);
				}
			BNRP_freePtr = (char *)((long)BNRP_freeSpace + offset);
			}
		if ((BNRP_buffSpace[0] EQ 'p') && (BNRP_buffSpace[1] EQ 'r')) {
			if (inProc NE 0) {
				if (tagof(a) NE SYMBOLTAG) {
#ifdef debugMessages
					printf("Clause defined for a non-symbol\n");
#endif
					loadError(INVALIDSYMBOLINCALL);
					}
				if (BNRP_addClause(a, arity, key, (long)BNRP_freePtr - (long)BNRP_freeSpace, BNRP_freeSpace, FALSE) EQ NULL)
					loadError(CLOSEDCLAUSE);
				}
			getToken(2, f);		/* get rid of (pr)oc */
			getToken(10, f);
			index = -getWord(BNRP_buffSpace);
			if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
				printf("Too many symbols\n");
#endif
				loadError(LOADTOOMANYSYMBOLS);
				}
			if ((a = BNRP_refs[index].ref) EQ 0) {
#ifdef debugMessages
				printf("Invalid symbol reference\n");
#endif
				loadError(INVALIDSYMBOLINCALL);
				}
			key = getWord(&BNRP_buffSpace[4]);
			if (key LT 0) {			/* symbol table reference */
				if ((index = -key) GE BNRP_numRefs) {
#ifdef debugMessages
					printf("Invalid symbol in key\n");
#endif
					loadError(LOADTOOMANYSYMBOLS);
					}
				if ((key = BNRP_refs[index].key) EQ 0)
					key = BNRP_refs[index].key = computeKey(BNRP_refs[index].ref);
				}
			arity = getByte(&BNRP_buffSpace[8]);
			inProc = 1;
			inBody = sawESC = FALSE;
			BNRP_freePtr = BNRP_freeSpace;
			}
		else if ((BNRP_buffSpace[0] EQ 's') && (BNRP_buffSpace[1] EQ 'y')) {
			if (inProc NE 0) {
				if (tagof(a) NE SYMBOLTAG) {
#ifdef debugMessages
					printf("Clause defined for a non-symbol\n");
#endif
					loadError(INVALIDSYMBOLINCALL);
					}
				if (BNRP_addClause(a, arity, key, (long)BNRP_freePtr - (long)BNRP_freeSpace, BNRP_freeSpace, FALSE) EQ NULL)
					loadError(CLOSEDCLAUSE);
				inProc = 0;
				}
			/* flush out rest of line */
			getToken(1, f);		/* get rid of (sy)m */
			skipToken(f);
			}
		else if (inProc) {
			i = (unsigned char)getByte(BNRP_buffSpace);
			addByte(i);
			if (inBody)
				if (sawESC) {
					j = remEscBytes[i];
					sawESC = FALSE;
					}
				else
					j = remBodyBytes[i];
			else
				j = remHeadBytes[i];
			if ((i EQ 0) || (i EQ 5)) inBody = TRUE;
			while (j GT 0) {
				getToken(2, f);
				addByte(getByte(BNRP_buffSpace));
				j -= 2;
				}
			if (j LT 0) {
				if (j EQ -4) {
					getToken(4, f);
					index = -getWord(BNRP_buffSpace);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -4)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -4)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					}
				else if (j EQ -6) {
					getToken(2, f);
					addByte(getByte(BNRP_buffSpace));
					getToken(4, f);
					index = -getWord(BNRP_buffSpace);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -6)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -6)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					}
				else if (j EQ -60) {
					getToken(6, f);
					addByte(getByte(BNRP_buffSpace));
					index = -getWord(&BNRP_buffSpace[2]);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -60)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -60)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					}
				else if (j EQ -62) {
					getToken(8, f);
					addByte(getByte(BNRP_buffSpace));
					index = -getWord(&BNRP_buffSpace[2]);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -62)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -62)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					addByte(getByte(&BNRP_buffSpace[6]));
					}
				else if (j EQ -64) {
					getToken(6, f);
					addByte(getByte(BNRP_buffSpace));
					index = -getWord(&BNRP_buffSpace[2]);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -64)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -64)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					if (j & 0x80) {
						getToken(2, f);
						addByte(getByte(BNRP_buffSpace));
						}
					}
				else if (j EQ -80) 
					sawESC = TRUE;
				else if (j EQ -82) {
					sawESC = TRUE;
					getToken(2, f);
					addByte(getByte(BNRP_buffSpace));
					}
				else if (j EQ -84) {
					sawESC = TRUE;
					getToken(2, f);
					addByte(getByte(BNRP_buffSpace));
					getToken(2, f);
					addByte(getByte(BNRP_buffSpace));
					}
				else if (j EQ -90) {
					sawESC = TRUE;
					getToken(4, f);
					index = -getWord(BNRP_buffSpace);
					if ((index LE 0) || (index GE BNRP_numRefs)) {
#ifdef debugMessages
						printf("Too many symbols (ref -90)\n");
#endif
						loadError(LOADTOOMANYSYMBOLS);
						}
					if (BNRP_refs[index].ref EQ 0) {
#ifdef debugMessages
						printf("Invalid symbol reference (ref -90)\n");
#endif
						loadError(INVALIDSYMBOLINCALL);
						}
					addLong((long)BNRP_refs[index].ref);
					}
				else if (j EQ -1) {
#ifdef debugMessages
					getToken(100, f);
					printf("Loader detects unimplemented escape opcode %02X near %s\n", i, BNRP_buffSpace);
#endif
					skipToken(f);
					}
#ifdef debugMessages
				else
					printf("LOADER: Unimplemented count of %d\n", j);
#endif
				}
			}
		else {
#ifdef debugMessages
			printf("LOADER: Unrecognized %s", BNRP_buffSpace);
			fgets(BNRP_buffSpace, BNRP_buffSize, f);
			printf("%s\n", BNRP_buffSpace);
#endif
			loadError(-1);
			}
		}
	fclose(f);
	onerrorexecute(NULL);
	BNRP_free(BNRP_refs);
	BNRP_free(BNRP_freeSpace);
	BNRP_free(BNRP_buffSpace);
	return(0);
	}

#ifdef debugMessages
static void checkName(char *sp, char *name)
{
	if (strcmp(sp, name) NE 0)
		printf("HASHING ERROR: %s not equal to %s (hash = %d)\n", sp, name, hashString(sp));
	}
#else
#define checkName(a, b)
#endif

#ifdef debugMessages
#define emitCons(tag, t)			constantLWA(BNRP_freePtr); \
									if (tag EQ INTT) \
										*(long *)BNRP_freePtr = BNRPMakePermInt(t); \
									else if (tag EQ FLOATT) \
										*(long *)BNRP_freePtr = BNRPMakePermFloat((fp *)t); \
									else if (tag EQ SYMBOLT) { \
										t = maketerm(SYMBOLMASK, t); \
										BNRP_makeSymbolPermanent(t); \
										*(long *)BNRP_freePtr = t; \
										} \
									else \
										printf("ERROR: Bad constant in emitCons\n"); \
									BNRP_freePtr += sizeof(long)
#else
#define emitCons(tag, t)			constantLWA(BNRP_freePtr); \
									if (tag EQ INTT) \
										*(long *)BNRP_freePtr = BNRPMakePermInt(t); \
									else if (tag EQ FLOATT) \
										*(long *)BNRP_freePtr = BNRPMakePermFloat((fp *)t); \
									else if (tag EQ SYMBOLT) { \
										t = maketerm(SYMBOLMASK, t); \
										BNRP_makeSymbolPermanent(t); \
										*(long *)BNRP_freePtr = t; \
										} \
									BNRP_freePtr += sizeof(long)
#endif
#define addOpcode(op, reg)			if (reg GT 7) { \
										*BNRP_freePtr++ = op; \
										*BNRP_freePtr++ = reg; \
										} \
									else \
										*BNRP_freePtr++ = op | reg
#define addDualOpcode(op, r1, r2)	if (r1 GT 7) { \
										if (r2 GT 7) { \
											*BNRP_freePtr++ = op; \
											*BNRP_freePtr++ = r1; \
											*BNRP_freePtr++ = r2; \
											} \
										else { \
											*BNRP_freePtr++ = op | r2; \
											*BNRP_freePtr++ = r1; \
											} \
										} \
									else \
										if (r2 GT 7) { \
											*BNRP_freePtr++ = op | (r1 << 4); \
											*BNRP_freePtr++ = r2; \
											} \
										else \
											*BNRP_freePtr++ = op | (r1 << 4) | r2

static BNRP_Boolean scanList(BNRP_term list)
{
	long p, orig, result, orig1, orig2;
	long LDCount = 1, LDHold = 2, LDk = 0, LDSaveAddr;
	ptr addr;
	TAG tag;
	char *sp;
	
	p = addrof(list);
	derefTV(&p, &orig, &tag, &result, &addr);
	while (tag NE ENDT) {
		if (((long)BNRP_freePtr - (long)BNRP_freeSpace) GT (BNRP_freeSize - 20)) {
			long offset;
			
			BNRP_freeSize += STARTFREESPACE;
			offset = (long)BNRP_freePtr - (long)BNRP_freeSpace;
			BNRP_freeSpace = (char *) BNRP_realloc(BNRP_freeSpace, BNRP_freeSize);
			if (BNRP_freeSpace EQ NULL) {
#ifdef debugMessages
				printf("ERROR: Clause too long to load\n");
#endif
				return(FALSE);
				}
			BNRP_freePtr = (char *)((long)BNRP_freeSpace + offset);
			}
		if (tag EQ SYMBOLT) {
			symbolEntry *s;
			checksym(result, s);
			sp = s->name;
#ifdef debugMessages
			if (s->hash NE hashString(sp)) 
				printf("ERROR: HASH PROBLEM with %s: was %u, s/b %u\n", sp, s->hash, hashString(sp));
#endif
			switch ((unsigned char)s->hash) {
				case 5:		checkName(sp, "dcut");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x02;
							break;
				case 6:		checkName(sp, "floor");
							*BNRP_freePtr++ = 0xAB;
							break;
				case 7:		checkName(sp, "push_void");
							*BNRP_freePtr++ = 0x01;
							break;
				case 14:	if (*sp EQ 'e') {
								checkName(sp, "escape");
								*BNRP_freePtr++ = 0x07;
								}
							else {
								checkName(sp, "neckproceed");
								*BNRP_freePtr++ = 0x05;
								*BNRP_freePtr++ = 0x00;
								}
							break;
				case 19:	checkName(sp, "->");  /* boolean -> */
							*BNRP_freePtr++ = 0xFC;
							break;
				case 21:	checkName(sp, "and"); /* boolean and */
							*BNRP_freePtr++ = 0xF9;
							break;
				case 23:	checkName(sp, "acos");
							*BNRP_freePtr++ = 0xCD;
							break;
				case 24:	checkName(sp, "alloc");
							*BNRP_freePtr++ = 0x06;
							break;
				case 26:	checkName(sp, "=:="); /* relation == */
							*BNRP_freePtr++ = 0xFD;
							break;
				case 34:	checkName(sp, "neg");
							*BNRP_freePtr++ = 0xBF;
							break;
				case 36:	checkName(sp, "push_end");
							*BNRP_freePtr++ = 0x03;
							break;
				case 37:	checkName(sp, "dealloc");
							*BNRP_freePtr++ = 0x06;
							break;
				case 42:	checkName(sp, "+");
							*BNRP_freePtr++ = 0x99;
							break;
				case 43:	checkName(sp, "*");
							*BNRP_freePtr++ = 0x9B;
							break;
				case 44:	checkName(sp, "-");
							*BNRP_freePtr++ = 0x9A;
							break;
				case 46:	checkName(sp, "/");
							*BNRP_freePtr++ = 0x9D;
							break;
				case 48:	checkName(sp, "//");
							*BNRP_freePtr++ = 0x9C;
							break;
				case 56:	checkName(sp, "**");
							*BNRP_freePtr++ = 0x9F;
							break;
				case 57:	checkName(sp, "mod");
							*BNRP_freePtr++ = 0x9E;
							break;
				case 59:	checkName(sp, "biteq");
							*BNRP_freePtr++ = 0xEF;
							break;
				case 61:	checkName(sp, "<");
							*BNRP_freePtr++ = 0xFF;
							break;
				case 62:	checkName(sp, "cdcutfail");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x34;
							break;
				case 63:	checkName(sp, ">");
							*BNRP_freePtr++ = 0xFE;
							break;
				case 78:	checkName(sp, "round");
							*BNRP_freePtr++ = 0xAD;
							break;
				case 84:	checkName(sp, "=\\=");
							*BNRP_freePtr++ = 0xFD;
							*BNRP_freePtr++ = 0xF8;
							break;
				case 88:	checkName(sp, "cos");
							*BNRP_freePtr++ = 0xCA;
							break;
				case 92:	checkName(sp, "nor");
							*BNRP_freePtr++ = 0xFA;
							*BNRP_freePtr++ = 0xF8;
							break;
				case 93:	checkName(sp, "min");
							*BNRP_freePtr++ = 0xAF;
							break;
				case 94:	checkName(sp, "bitshift");
							*BNRP_freePtr++ = 0xDF;
							break;
				case 103:	checkName(sp, "sin");
							*BNRP_freePtr++ = 0xC9;
							break;
				case 113:	checkName(sp, "unif_void");
							*BNRP_freePtr++ = 0x01;
							break;
				case 114:	checkName(sp, "ceiling");
							*BNRP_freePtr++ = 0xAC;
							break;
				case 118:	checkName(sp, "more_choicepoints");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x30;
							break;
				case 119:	checkName(sp, "bitand");
							*BNRP_freePtr++ = 0xED;
							break;
				case 121:	checkName(sp, "cdcutreturn");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x32;
							*BNRP_freePtr++ = 0x00;
							break;
				case 122:	checkName(sp, "butnot");
							*BNRP_freePtr++ = 0xCF;
							break;
				case 127:	checkName(sp, "~");
							*BNRP_freePtr++ = 0xF8;
							break;
				case 132:	checkName(sp, "inc");
							*BNRP_freePtr++ = 0xBD;
							break;
				case 146:	checkName(sp, "tunif_void");
							*BNRP_freePtr++ = 0x02;
							break;
				case 148:	checkName(sp, "neck");
							*BNRP_freePtr++ = 0x00;
							break;
				case 150:	checkName(sp, "ccutsp");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x98;
							break;
				case 152:	checkName(sp, "ln");
							*BNRP_freePtr++ = 0xBC;
							break;
				case 154:	checkName(sp, "noop");
							*BNRP_freePtr++ = 0x05;
							break;
				case 156:	checkName(sp, "tan");
							*BNRP_freePtr++ = 0xCB;
							break;
				case 160:	if (sp[1] EQ 'a') {
								checkName(sp, "fail");
								*BNRP_freePtr++ = 0x07;
								*BNRP_freePtr++ = 0x0F;
								}
							else {
								checkName(sp, "float");
								*BNRP_freePtr++ = 0xAA;
								}
							break;
				case 166:	checkName(sp, "tpush_void");
							*BNRP_freePtr++ = 0x02;
							break;
				case 168:	checkName(sp, "asin");
							*BNRP_freePtr++ = 0xCC;
							break;
				case 170:	checkName(sp, "or");
							*BNRP_freePtr++ = 0xFA;
							break;
				case 173:	if (*sp EQ 'c') {
								checkName(sp, "cutreturn");
								*BNRP_freePtr++ = 0x07;
								*BNRP_freePtr++ = 0x02;
								*BNRP_freePtr++ = 0x00;
								}
							else {
								checkName(sp, "label_env");
								*BNRP_freePtr++ = 0x07;
								*BNRP_freePtr++ = 0x37;
								}
							break;
				case 178:	checkName(sp, "exp");
							*BNRP_freePtr++ = 0xBB;
							break;
				case 183:	checkName(sp, "sqrt");
							*BNRP_freePtr++ = 0xB9;
							break;
				case 184:	checkName(sp, "cdcut");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x32;
							break;
				case 186:	checkName(sp, "max");
							*BNRP_freePtr++ = 0xAE;
							break;
				case 187:	checkName(sp, "push_nil");
							*BNRP_freePtr++ = 0x07;
							*BNRP_freePtr++ = 0x03;
							break;
				case 189:	checkName(sp, "atan");
							*BNRP_freePtr++ = 0xCE;
							break;
				case 197:	checkName(sp, "bitor");
							*BNRP_freePtr++ = 0xEE;
							break;
				case 198:	checkName(sp, "proceed");
							*BNRP_freePtr++ = 0x00;
							break;
				case 199:	checkName(sp, "end_seq");
							*BNRP_freePtr++ = 0x03;
							break;
				case 200:	if (*sp EQ 'c') {
                                checkName(sp, "ccutfail");
                                *BNRP_freePtr++ = 0x07;
                                *BNRP_freePtr++ = 0x33;
                            } else {
                                checkName(sp, "=<");
                                *BNRP_freePtr++ = 0xFE;
                                *BNRP_freePtr++ = 0xF8;
                            }
							break;
				case 201:	if (*sp EQ 'n') {
                                checkName(sp, "nand");
							    *BNRP_freePtr++ = 0xF9;
							    *BNRP_freePtr++ = 0xF8;
                            } else {
                                checkName(sp, "==");
							    *BNRP_freePtr++ = 0xFD;
                            }
							break;
				case 203:	checkName(sp, "integer");
							*BNRP_freePtr++ = 0xA9;
							break;
				case 214:	checkName(sp, ">=");
							*BNRP_freePtr++ = 0xFF;
							*BNRP_freePtr++ = 0xF8;
							break;
				case 221:	checkName(sp, "<>");
							*BNRP_freePtr++ = 0xFD;
							*BNRP_freePtr++ = 0xF8;
							break;
				case 231:	checkName(sp, "gcalloc");
							*BNRP_freePtr++ = 0xE6;
							break;
				case 236:	checkName(sp, "abs");
							*BNRP_freePtr++ = 0xBA;
							break;
				case 239:	checkName(sp, "dec");
							*BNRP_freePtr++ = 0xBE;
							break;
				case 240:	checkName(sp, "unif_nil");
							*BNRP_freePtr++ = 0x07;
							break;
				case 242:	checkName(sp, "xor");
							*BNRP_freePtr++ = 0xFB;
							break;
				default:
							checkName(sp, "??????");
							return(FALSE);
				}
			}
		else if (tag EQ STRUCTT) {
			long p, arg1, arg2;
			li arity;
			unsigned char hash;
			TAG arg1tag, arg2tag;
			symbolEntry *s;
			
			p = result;
			get(long, p, arity.l);							/* get header */
			derefTV(&p, &orig, &tag, &result, &addr);		/* get functor */
			if (tag NE SYMBOLT) {
#ifdef debugMessages
				printf("ERROR: Not a symbol in structure name\n");
#endif
				return(FALSE);
				}
			checksym(result, s);
			sp = s->name;
			hash = s->hash;
#ifdef debugMessages
			if (hash NE hashString(sp)) 
				printf("ERROR: HASH PROBLEM with %s: was %u, s/b %u\n", sp, hash, hashString(sp));
#endif
			derefTV(&p, &orig1, &arg1tag, &arg1, &addr);
			derefTV(&p, &orig2, &arg2tag, &arg2, &addr);
			if (arg2tag EQ ENDT) {							/* arity 1 structure */
				switch (hash) {										
					case 1:		checkName(sp, "push_varp");
								addOpcode(0x48, arg1);
								break;
					case 3:
					case 5:		checkName(sp, "push_vart");
								addOpcode(0x40, arg1);
								break;
					case 8:		checkName(sp, "eval_valp");
								addOpcode(0x68, arg1);
								break;
					case 12:	checkName(sp, "eval_valt");
								addOpcode(0x60, arg1);
								break;
					case 14:	checkName(sp, "cutexec");
								if (arg1tag EQ STRUCTT) {
									long p;
									
									p = arg1;
									get(long, p, arity.l);						/* get header */
									derefTV(&p, &orig, &tag, &result, &addr);	/* get functor */
									if (tag NE SYMBOLT)  {
#ifdef debugMessages
										printf("ERROR: Not a symbol in cutexec name\n");
#endif
										return(FALSE);
										}
									checkName(nameof(result), "/");
									derefTV(&p, &orig, &arg1tag, &arg1, &addr);
									if (arg1tag NE SYMBOLT)  {
#ifdef debugMessages
										printf("ERROR: Not a symbol in cutexec proc name\n");
#endif
										return(FALSE);
										}
									sp = nameof(arg1);
									derefTV(&p, &orig, &tag, &result, &addr);
									if (tag NE INTT)  {
#ifdef debugMessages
										printf("ERROR: Not a int in cutexec arity\n");
#endif
										return(FALSE);
										}
									*BNRP_freePtr++ = 0x07;
									*BNRP_freePtr++ = 0xE6;
									*BNRP_freePtr++ = result;
									emitCons(arg1tag, arg1);
									}
								break;
					case 25:	checkName(sp, "get_list");
								addOpcode(0x20, arg1);
								break;
					case 34:	checkName(sp, "tvarp");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x28, arg1);
								break;
					case 37:	checkName(sp, "eval_sym");
								if (arg1tag EQ SYMBOLT)
									switch (symof(arg1)->hash) {
										case 86:	*BNRP_freePtr++ = 0xE9;	/* maxint */
													break;
										case 39:	*BNRP_freePtr++ = 0xEA;	/* maxreal */
													break;
										case 45:						/* pi */
										case 184:	*BNRP_freePtr++ = 0xEB;
													break;
										case 145:	*BNRP_freePtr++ = 0xEC;	/* cputime */
													break;
#ifdef debugMessages
										default:	
													printf("ERROR: Unrecognized %s in eval_sym\n", nameof(arg1));
													break;
#endif
										}
#ifdef debugMessages
								else
									printf("ERROR: Unrecognized item in eval_sym\n");
#endif
								break;
					case 38:	checkName(sp, "tvart");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x20, arg1);
								break;
					case 46:	checkName(sp, "put_list");
								addOpcode(0x20, arg1);
								break;
					case 61:	checkName(sp, "<");
								*BNRP_freePtr++ = 0xDC;
								*BNRP_freePtr++ = arg1;
								break;
					case 63:	checkName(sp, ">");
								*BNRP_freePtr++ = 0xDD;
								*BNRP_freePtr++ = arg1;
								break;
					case 64:	checkName(sp, "push_cons");
								if (arg1tag EQ LISTT) {			/* must be empty list */
									*BNRP_freePtr++ = 0x07;
									*BNRP_freePtr++ = 0x03;
									}
								else {
									*BNRP_freePtr++ = 0x04;
									emitCons(arg1tag, arg1);
									}
								break;
					case 82:	checkName(sp, "tunif_vart");
								addOpcode(0x60, arg1);
								break;
					case 86:	checkName(sp, "tunif_varp");
								addOpcode(0x68, arg1);
								break;
					case 98:	checkName(sp, "vart");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x10, arg1);
								break;
					case 102:	checkName(sp, "varp");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x18, arg1);
								break;
					case 105:	checkName(sp, "ccut");
								*BNRP_freePtr++ = 0x07;
								*BNRP_freePtr++ = 0x31;
								*BNRP_freePtr++ = arg1;
								break;
					case 113:	checkName(sp, "tunif_valp");
								addOpcode(0x78, arg1);
								break;
					case 115:	if (*sp EQ 't') {
									checkName(sp, "tpush_varp");
									addOpcode(0x68, arg1);
									}
								else {
									checkName(sp, "exec");
									if (arg1tag EQ STRUCTT) {
										long p;
										
										p = arg1;
										get(long, p, arity.l);						/* get header */
										derefTV(&p, &orig, &tag, &result, &addr);	/* get functor */
										if (tag NE SYMBOLT)  {
#ifdef debugMessages
											printf("ERROR: Not a symbol in exec name\n");
#endif
											return(FALSE);
											}
										checkName(nameof(result), "/");
										derefTV(&p, &orig, &arg1tag, &arg1, &addr);
										if (arg1tag NE SYMBOLT)  {
#ifdef debugMessages
											printf("ERROR: Not a symbol in exec proc name\n");
#endif
											return(FALSE);
											}
										sp = nameof(arg1);
										derefTV(&p, &orig, &tag, &result, &addr);
										if (tag NE INTT)  {
#ifdef debugMessages
											printf("ERROR: Not a int in exec arity\n");
#endif
											return(FALSE);
											}
										if ((strcmp(sp, "exec$$") EQ 0) && (result EQ 2)) {
											*BNRP_freePtr++ = 0x07;
											*BNRP_freePtr++ = 0x0E;
											}
										else if ((strcmp(sp, "call_i") EQ 0) && (result EQ 1)) {
											*BNRP_freePtr++ = 0x07;
											*BNRP_freePtr++ = 0x0B;
											}
										else {
											*BNRP_freePtr++ = 0x07;
											*BNRP_freePtr++ = 0x0C;
											*BNRP_freePtr++ = result;
											emitCons(arg1tag, arg1);
											}
										}
									}
								break;
					case 117:	checkName(sp, "tunif_valt");
								addOpcode(0x70, arg1);
								break;
					case 119:	checkName(sp, "tpush_vart");
								addOpcode(0x60, arg1);
								break;
					case 130:	checkName(sp, "neckcon");
								*BNRP_freePtr++ = 0x05;
								*BNRP_freePtr++ = arg1;
								*BNRP_freePtr++ = (arg1 EQ 0) ? 0x06 : 0x05;
								break;
					case 137:	checkName(sp, "unif_vart");
								addOpcode(0x40, arg1);
								break;
					case 138:	checkName(sp, "push_valt");
								addOpcode(0x50, arg1);
								break;
					case 140:	checkName(sp, "put_nil");
								addOpcode(0x28, arg1);
								break;
					case 141:	checkName(sp, "unif_varp");
								addOpcode(0x48, arg1);
								break;
					case 142:	checkName(sp, "push_valp");
								addOpcode(0x58, arg1);
								break;
					case 152:	checkName(sp, "put_void");
								addOpcode(0x30, arg1);
								break;
					case 162:	checkName(sp, "unif_valt");
								addOpcode(0x50, arg1);
								break;
					case 166:	checkName(sp, "unif_valp");
								addOpcode(0x58, arg1);
								break;
					case 174:	checkName(sp, "get_nil");
								addOpcode(0x28, arg1);
								break;
					case 197:	checkName(sp, "unif_cons");
								if (arg1tag EQ LISTT) {
									*BNRP_freePtr++ = 0x07;		/* must be empty list */
									derefTV(&arg1, &orig, &arg1tag, &result, &addr);
#ifdef debugMessages
									if (arg1tag NE ENDT) printf("ERROR: Not an empty list for unif_cons\n");
#endif
									}
								else {
									*BNRP_freePtr++ = 0x04;
									emitCons(arg1tag, arg1);
									}
								break;
					case 200:	checkName(sp, "=<");
								*BNRP_freePtr++ = 0xDA;
								*BNRP_freePtr++ = arg1;
								break;
					case 201:	checkName(sp, "==");
								*BNRP_freePtr++ = 0xD9;
								*BNRP_freePtr++ = arg1;
								break;
					case 203:	checkName(sp, "ecut");
								*BNRP_freePtr++ = 0x07;
								*BNRP_freePtr++ = 0x01;
								*BNRP_freePtr++ = arg1;
								break;
					case 214:	checkName(sp, ">=");
								*BNRP_freePtr++ = 0xDB;
								*BNRP_freePtr++ = arg1;
								break;
					case 221:	if (*sp EQ '<') {
									checkName(sp, "<>");
									*BNRP_freePtr++ = 0xDE;
									*BNRP_freePtr++ = arg1;
									}
								else {
									checkName(sp, "comment");
									}
								break;
					case 234:	checkName(sp, "hcomment");
								break;
					case 241:	checkName(sp, "=/=");
								*BNRP_freePtr++ = 0xDE;
								*BNRP_freePtr++ = arg1;
								break;
					case 250:	checkName(sp, "eval_cons");
								*BNRP_freePtr++ = 0x04;
								emitCons(arg1tag, arg1);
								break;
					case 251:	checkName(sp, "tpush_valt");
								addOpcode(0x70, arg1);
								break;
					case 255:	checkName(sp, "tpush_valp");
								addOpcode(0x78, arg1);
								break;
					default:
								checkName(sp, "??????");
								return(FALSE);
					}
				}
			else {											/* arity 2 structure */
				switch (hash) {
					case 1:		checkName(sp, "testt");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x40, arg1);
					checkFilterType:
								if (arg2tag NE SYMBOLT) {
#ifdef debugMessages
									printf("ERROR: bad test type in testt/testp\n");
#endif
									return(FALSE);
									}
								if (orig2 EQ numberAtom)
									*BNRP_freePtr++ = 0x18;
								else if (orig2 EQ nonNumberAtom)
									*BNRP_freePtr++ = 0x07;
								else {
									int i;
									
									for (i = 0; i LT 32; ++i)
										if (orig2 EQ BNRP_filterNames[i]) {
											*BNRP_freePtr++ = i;
											break;
											}
									if (i GE 32) {	/* filter not found */
#ifdef debugMessages
										printf("ERROR: bad filter type in testt/testp\n");
#endif
										return(FALSE);
										}
									}
								break;
					case 5:		checkName(sp, "testp");
								*BNRP_freePtr++ = 0x07;
								addOpcode(0x48, arg1);
								goto checkFilterType;
					case 10:	checkName(sp, "pop_varp");
								addOpcode(0x78, arg1);
								*BNRP_freePtr++ = arg2;
								break;
					case 14:	checkName(sp, "pop_vart");
								addOpcode(0x70, arg1);
								*BNRP_freePtr++ = arg2;
								break;
					case 35:	checkName(sp, "get_valp");
								addOpcode(0x38, arg2);
								*BNRP_freePtr++ = arg1;
								break;
					case 37:	checkName(sp, "call");
								if (arg1tag EQ STRUCTT) {
									long p;
									
									p = arg1;
									get(long, p, arity.l);						/* get header */
									derefTV(&p, &orig, &tag, &result, &addr);	/* get functor */
									if (tag NE SYMBOLT)  {
#ifdef debugMessages
										printf("ERROR: Not a symbol in call\n");
#endif
										return(FALSE);
										}
									checkName(nameof(result), "/");
									derefTV(&p, &orig, &arg1tag, &arg1, &addr);
									if (arg1tag NE SYMBOLT)  {
#ifdef debugMessages
										printf("ERROR: Not a symbol in call arg1\n");
#endif
										return(FALSE);
										}
									sp = nameof(arg1);
									derefTV(&p, &orig, &tag, &result, &addr);
									if (tag NE INTT)  {
#ifdef debugMessages
										printf("ERROR: Not a int in call arity\n");
#endif
										return(FALSE);
										}
									if ((strcmp(sp, "call_i") EQ 0) && (result EQ 1)) {
										*BNRP_freePtr++ = 0x07;
										*BNRP_freePtr++ = 0x09;
										*BNRP_freePtr++ = arg2;
										}
									else if ((strcmp(sp, "clause$$") EQ 0) && (result EQ 3)) {
										*BNRP_freePtr++ = 0x07;
										*BNRP_freePtr++ = 0x0D;
										*BNRP_freePtr++ = arg2;
										}
									else if ((strcmp(sp, "cut") EQ 0) && (result EQ 1)) {
										*BNRP_freePtr++ = 0x07;
										*BNRP_freePtr++ = 0x35;
										*BNRP_freePtr++ = arg2;
										}
									else if ((strcmp(sp, "failexit") EQ 0) && (result EQ 1)) {
										*BNRP_freePtr++ = 0x07;
										*BNRP_freePtr++ = 0x36;
										}
									else {
										*BNRP_freePtr++ = 0x07;
										*BNRP_freePtr++ = 0x0A;
										*BNRP_freePtr++ = result;
										emitCons(arg1tag, arg1);
										*BNRP_freePtr++ = arg2;
										}
									}
								break;
					case 39:	checkName(sp, "get_valt");
								if (arg1 EQ arg2) break;
								addOpcode(0x30, arg2);
								*BNRP_freePtr++ = arg1;
								break;
					case 43:	checkName(sp, "get_varp");
								addDualOpcode(0x88, arg2, arg1);
								break;
					case 47:	checkName(sp, "get_vart");
								if (arg1 EQ arg2) break;
								addDualOpcode(0x80, arg2, arg1);
								break;
					case 97:	checkName(sp, "put_struc");
								addOpcode(0x10, arg2);
								*BNRP_freePtr++ = arg1;
								break;
					case 98:	checkName(sp, "put_valt");
								if (arg1 EQ arg2) break;
								addDualOpcode(0x80, arg2, arg1);
								break;
					case 102:	checkName(sp, "put_valp");
								addDualOpcode(0x88, arg2, arg1);
								break;
					case 134:	checkName(sp, "get_struc");
								addOpcode(0x10, arg2);
								*BNRP_freePtr++ = arg1;
								break;
					case 195:	checkName(sp, "put_varp");
								addOpcode(0x38, arg2);
								*BNRP_freePtr++ = arg1;
								break;
					case 198:	checkName(sp, "get_cons");
								addOpcode(0x08, arg2);
								emitCons(arg1tag, arg1);
								break;
					case 199:	checkName(sp, "put_vart");
								if (arg1 NE arg2) {
									*BNRP_freePtr++ = 0x07;
									addDualOpcode(0x80, arg2, arg1);
									}
#ifdef debugMessages
								else 
									printf("ERROR: put_vart %d %d\n", arg1, arg2);
#endif
								break;
					case 234:	if (sp[1] EQ 'u') {
									checkName(sp, "put_cons");
									addOpcode(0x08, arg2);
									emitCons(arg1tag, arg1);
									}
								else {
									checkName(sp, "pop_valt");
									addOpcode(0x50, arg1);
									*BNRP_freePtr++ = arg2;
									}
								break;
					case 238:	checkName(sp, "pop_valp");
								addOpcode(0x58, arg1);
								*BNRP_freePtr++ = arg2;
								break;
					default:
								checkName(sp, "??????");
								return(FALSE);
					}
				}


			}
		else if (tag EQ LISTT) {
			if (!scanList(result)) return(FALSE);
			}
		else {
#ifdef debugMessages
			printf("ERROR: Unrecognized type in list\n");
#endif
			return(FALSE);
			}
		orig = p;
		derefTV(&p, &orig, &tag, &result, &addr);
		if (p LE orig) {			/* possible loop */
			if (--LDCount LE 0) {
				if (LDk EQ 0) {
					LDk = LDHold;
					LDHold += LDHold;
					LDSaveAddr = p;
					}
				else {
					--LDk;
					if (LDSaveAddr EQ p)  {
#ifdef debugMessages
						printf("ERROR: Unexpected loop\n");
#endif
						return(FALSE);
						}
					}
				}
			}
		}
	return(TRUE);
	}
	
BNRP_Boolean BNRP_inCoreLoader(TCB *tcb)
{
	BNRP_term pred, list;
	long arity, key, pos;
	BNRP_Boolean returnString, res;
	
	if ((tcb->numargs EQ 5) &&
		(checkArg(tcb->args[1], &pos) EQ INTT) &&
		(checkArg(tcb->args[2], &pred) EQ SYMBOLT) &&
		(checkArg(tcb->args[3], &arity) EQ INTT) &&
		(checkArg(tcb->args[5], &list) EQ LISTT)) {
		key = computeKey(tcb->args[4]);
		returnString = FALSE;
		}
	else if ((tcb->numargs EQ 6) &&
			 (checkArg(tcb->args[5], &list) EQ LISTT)) {
		returnString = TRUE;
		}
	else
		return(FALSE);

	BNRP_freeSize = STARTFREESPACE;
	BNRP_freeSpace = (char *) BNRP_malloc(BNRP_freeSize);
	if (BNRP_freeSpace EQ NULL) {
#ifdef debugMessages
		printf("Unable to allocate temporary space for clause\n");
#endif
		return(FALSE);
		}
	BNRP_freePtr = BNRP_freeSpace;

	if (!scanList(list)) {
		if (BNRP_freeSpace NE NULL) BNRP_free(BNRP_freeSpace);
		return(FALSE);
		}
	
	if (returnString) {
		char *p, buff[1000], *b;
		
		b = buff;
		for (p = BNRP_freeSpace; p NE BNRP_freePtr; ++p) {
			sprintf(b, "%02X", *p & 0x0FF);
			b += 2;
			}
		return(unify(tcb, tcb->args[6], BNRPLookupSymbol(tcb, buff, TEMPSYM, GLOBAL)));
		}
	res = (BNRP_addClause(pred, arity, key, (long)BNRP_freePtr - (long)BNRP_freeSpace, BNRP_freeSpace, (pos NE 0)) NE NULL);
	BNRP_free(BNRP_freeSpace);
	return(res);
	}
