/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/ioprim.h,v 1.3 1997/08/12 17:35:03 harrisj Exp $
*
*  $Log: ioprim.h,v $
 * Revision 1.3  1997/08/12  17:35:03  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.2  1996/07/11  17:40:14  yanzhou
 * BNRP_termToString() is now defined in external.c, it merely tranfers
 * the execution to BNRP_makeTermToString(), which is an internal function
 * defined in ioprim.[hc].
 *
 * Revision 1.1  1995/09/22  11:24:58  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_ioprim
#define _H_ioprim

#include "core.h"
#include <stdio.h>

typedef BNRP_Boolean (*overloadIOProcedure)(short, long, ...);
extern overloadIOProcedure BNRP_printProc;
extern long BNRP_fileIndex;
extern TCB *BNRP_printTCB;
extern char *BNRP_printPos;
extern long BNRP_printLen;
#define USEHP				0x12345678
/****  Oz fix for keyboard abuse problem
 #define output(s)	(void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, s) 
*****/
/******
#define output(s) (void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, s, "")
#define output2(s, v)		(void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, s, v)
#define outputstr(v)		(void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, "%s", v)
#define outputchar(v)		(void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, "%c", v)
*******/

#define NONSTRING               0
#define STRING                  1

#define output(s)               (void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, STRING, s, "")
#define output2(s, v)           (void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, NONSTRING, s, v)
#define outputstr(v)            (void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, STRING, "%s", v)
#define outputchar(v)           (void)(*BNRP_printProc)(OUTPUTSTRING, BNRP_fileIndex, NONSTRING, "%c", v)

BNRP_Boolean BNRP_openFile(TCB *tcb);
BNRP_Boolean BNRP_closeFile(TCB *tcb);
BNRP_Boolean BNRP_getChar(TCB *tcb);
BNRP_Boolean BNRP_readFile(TCB *tcb);
BNRP_Boolean BNRP_readFileSymbol(TCB *tcb);
BNRP_Boolean BNRP_readlnFile(TCB *tcb);
BNRP_Boolean BNRP_writeFile(TCB *tcb);
BNRP_Boolean BNRP_writeFileSymbol(TCB *tcb);
BNRP_Boolean BNRP_atFile(TCB *tcb);
BNRP_Boolean BNRP_seekFile(TCB *tcb);
BNRP_Boolean BNRP_eofFile(TCB *tcb);
BNRP_Boolean BNRP_consultFile(TCB *tcb);
BNRP_Boolean BNRP_doTraceback(TCB *tcb);

BNRP_term    BNRP_makeTermFromString(TCB *tcb, const char *s); /* added by Oz 04/95 */
BNRP_Boolean BNRP_makeTermToString(TCB *tcb, BNRP_term term, char *buffer, long buflen);
                                                         /* added by Oz 07/96 */

#define OUTPUTSTRING	0
#define READCHAR		1
#define RETURNCHAR		2
#define OPENFILE		3
#define CLOSEFILE		4
#define GETPOSITION		5
#define SETPOSITION		6
#define SETEOF			7
#define FLUSHFILE		8
#define GETERROR		9

void BNRP_dumpWithQuotes(FILE *f, char *s);
BNRP_Boolean BNRP_needsQuotes(char *s);

#endif
