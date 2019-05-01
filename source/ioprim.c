/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/ioprim.c,v 1.8 1997/12/19 12:41:44 harrisj Exp $
 *
 * $Log: ioprim.c,v $
 * Revision 1.8  1997/12/19  12:41:44  harrisj
 * Modified BNRP_displayValue to quote the "!" symbol when
 * it is a structure functor.
 *
 * Revision 1.7  1997/08/12  17:34:59  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.6  1997/02/27  17:10:51  harrisj
 * Modified handlePipeIO so that SETEOF would clear the pipe
 * and deallocate all pipe sections except one which will be empty.
 * Previously SETEOF for pipes wasn't doing anything
 *
 * Revision 1.5  1996/09/25  16:26:26  harrisj
 * handleFileIO was not checking error code returned by fflush and vfprintf.
 * This caused such things as full file systems to go undetected.  Now, if
 * an error occurs, an IOERROR is reported.
 *
 * Revision 1.4  1996/08/26  15:05:13  harrisj
 * Added support for stderr in BNRP_checkFile()
 *
 * Revision 1.3  1996/07/11  17:40:10  yanzhou
 * BNRP_termToString() is now defined in external.c, it merely tranfers
 * the execution to BNRP_makeTermToString(), which is an internal function
 * defined in ioprim.[hc].
 *
 * Revision 1.2  1996/05/20  16:43:22  neilj
 * Added implementation of BNRP_termToString (in external interface)
 *
 * Revision 1.1  1995/09/22  11:24:56  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>			/* for va_list, va_arg */
#include <ctype.h>
#include <string.h>
#ifdef unix
#include <unistd.h>			/* for SEEK_SET, SEEK_END */
#endif
#ifdef THINK_C
#include <unix.h>
#endif
#ifdef __MWERKS__
#include <unix.h>
#endif
#ifdef __mpw
#include <files.h>			/* for GetFInfo, SetFinfo */
#endif
#include <setjmp.h>
#include "core.h"
#include "interpreter.h"
#include "parse.h"
#include "prim.h"
#include "utility.h"
#include "pushpop.h"
#include "ioprim.h"
#include "hardware.h"
#include "loader.h"
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
#include <errno.h>
#include <sys/errno.h>
#endif

#define STDIN				0
#define STDOUT				1
#define STDERR				2

#define READONLY			0x1
#define WRITEONLY			0x2
#define READWRITE			0x3

#define TOOLONG				-200

overloadIOProcedure BNRP_printProc;
long BNRP_fileIndex;
TCB *BNRP_printTCB;
char *BNRP_printPos;
long BNRP_printLen, BNRP_printCount;
BNRP_Boolean BNRP_printQuotes, BNRP_printCommas, BNRP_printBlanks, BNRP_printIntervals;
long BNRP_printMsgs;
jmp_buf BNRP_printEnv;



BNRP_Boolean handleFileIO(short selector, long printFile, ...);

#ifdef ring4
BNRP_Boolean handleFileIO(short selector, long printFile, ...)
{
	va_list ap;
	BNRP_Boolean res = TRUE;
	char *c, *d;
	long l, *p;
	short *err;
	
	va_start(ap, printFile);
	switch	(selector) {
		case OUTPUTSTRING:		/* (char *format, ...) */
                                va_arg(ap,int); /* NEW 28/04/95 Don't care about type */
				c = va_arg(ap, char *);
				if ((l = vfprintf((FILE *)printFile, c, ap)) < 0) longjmp(BNRP_printEnv, IOERROR);
				BNRP_printCount += l;
				if (BNRP_printCount GT BNRP_printLen) longjmp(BNRP_printEnv, TOOLONG);
				break;
		case READCHAR:			/* (char *result) */
				c = va_arg(ap, char *);
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
				errno = 0;
				while ((*c = fgetc((FILE *)printFile)) EQ EOF) {
					if ((ferror((FILE *)printFile)) && (errno EQ EINTR)) {
						clearerr((FILE *)printFile);
						errno = 0;
						continue;
						}
					res = FALSE;
					break;
					}
#else
				if (!(res = ((*c = fgetc((FILE *)printFile)) NE EOF)))
					clearerr((FILE *)printFile);
#endif
				break;
		case RETURNCHAR:		/* (char *character) */
				/* although unmodified, passed as pointer to avoid type promotion */
				c = va_arg(ap, char *);
				ungetc(*c, (FILE *)printFile);
				break;
		case OPENFILE:			/* (char *name, char *mode, long *index) */
				c = va_arg(ap, char *);
				d = va_arg(ap, char *);
				p = va_arg(ap, long *);
				res = ((void *)(*p = (long)fopen(c, d)) NE NULL);
#ifdef __mpw
				if (res) {
					FInfo f;
		
					/* using C versions of getfinfo and setfinfo that */
					/* convert the C string to a Pascal string for me */
					if (getfinfo(nameof(BNRP_fileIndex), 0, &f) EQ 0) {
						if ((f.fdType EQ 0) || (f.fdType EQ '    ')) {
							f.fdType = 'TEXT';
							setfinfo(nameof(BNRP_fileIndex), 0, &f);
							}
						}
					}
#endif
				break;
		case CLOSEFILE:			/* () */
				fclose((FILE *)printFile);
				break;
		case GETPOSITION:		/* (long *position) */
				p = va_arg(ap, long *);
				if (feof((FILE *)printFile))
					*p = -1;
				else
					*p = ftell((FILE *)printFile);
				break;
		case SETPOSITION:		/* (long newposition) */
				l = va_arg(ap, long);
				if (l GE 0)
					res = (fseek((FILE *)printFile, l, SEEK_SET) EQ 0);
				else if (l EQ -1)
					res = (fseek((FILE *)printFile, 0, SEEK_END) EQ 0);
				else
					res = FALSE;
				break;
		case SETEOF:			/* () */
				res = BNRP_truncateFile((FILE *)printFile, ftell((FILE *)printFile));
				break;
		case FLUSHFILE:			/* () */
				if(fflush((FILE *)printFile) EQ EOF) longjmp(BNRP_printEnv, IOERROR);
				break;
		case GETERROR:			/* (short *error) */
				err = va_arg(ap, short *);
				*err = ferror((FILE *)printFile);
				clearerr((FILE *)printFile);
				break;
		default:
				res = FALSE;
				break;
		}
	va_end(ap);
	return(res);
	}
#endif

#ifdef ring2
static BNRP_Boolean handleCharOutput(short selector, long ignored, ...)
{
	va_list ap;
	BNRP_Boolean res = TRUE;
	unsigned long l;
	short *i;
	char *c;
	
	va_start(ap, ignored);
	switch	(selector) {
		case OUTPUTSTRING:		/* (char *format, ...) */
				/* BSD sprintf returns string, not count */
                                va_arg(ap, int);  /* NEW 28/04/95 Don't care about type */
				c = va_arg(ap, char *);
				l = vsprintf(BNRP_printPos, c, ap);
				l = strlen(BNRP_printPos);
				BNRP_printCount += l;
				BNRP_printPos += l;
				if (BNRP_printCount GT BNRP_printLen) longjmp(BNRP_printEnv, TOOLONG);
				break;
		case GETERROR:			/* (short *error) */
				i = va_arg(ap, short *);
				*i = 0;
		case FLUSHFILE:			/* () */
				break;
		case READCHAR:			/* (char *result) */
		case RETURNCHAR:		/* (char *character) */
		case OPENFILE:			/* (char *name, char *mode, long *index) */
		case CLOSEFILE:			/* () */
		case GETPOSITION:		/* (long *position) */
		case SETPOSITION:		/* (long newposition) */
		case SETEOF:			/* () */
				res = FALSE;	/* not supported when outputing to string */
				break;
		}
	va_end(ap);
	return(res);
	}
#endif


#ifdef ring2
static BNRP_Boolean handleCharInput(short selector, long ignored, ...)
{
	va_list ap;
	BNRP_Boolean res = TRUE;
	char *c;
	short *i;
	
	va_start(ap, ignored);
	switch	(selector) {
		case OUTPUTSTRING:		/* (char *format, ...) */
		case OPENFILE:			/* (char *name, char *mode, long *index) */
		case CLOSEFILE:			/* () */
		case GETPOSITION:		/* (long *position) */
		case SETPOSITION:		/* (long newposition) */
		case SETEOF:			/* () */
				res = FALSE;	/* not support for reading from string */
				break;
		case READCHAR:			/* (char *result) */
				c = va_arg(ap, char *);
				if ((*c = *BNRP_printPos++) EQ '\0') {
					*c = EOF;
					--BNRP_printPos;
					}
				break;
		case RETURNCHAR:		/* (char *character) */
				if (*BNRP_printPos NE '\0') --BNRP_printPos;
				break;
		case GETERROR:			/* (short *error) */
				i = va_arg(ap, short *);
				*i = 0;
		case FLUSHFILE:			/* () */
				break;
		}
	va_end(ap);
	return(res);
	}
#endif
/* support for pipes */

#define PIPEBUFFER	2040
typedef struct pipePiece pipePiece;
struct pipePiece {
	pipePiece *nextPiece;
	short nextChar;
	short lastChar;
	char c[PIPEBUFFER];			/* total size 2K */
	};
typedef struct pipeHeader pipeHeader;
struct pipeHeader {
	pipePiece *firstPiece;
	pipePiece *lastPiece;
	};

#ifdef ring4
static BNRP_Boolean handlePipeIO(short selector, long pipe, ...)
{
	va_list ap;
	BNRP_Boolean res = TRUE;
	char *c, buff[100];
	long l, *p, len;
	short *err;
	pipePiece *curr, *next;
	
	va_start(ap, pipe);
	switch	(selector) {
		case OUTPUTSTRING:		/* (char *format, ...) */
                                va_arg(ap, int); /* NEW 28/04/95 Don't care about type */
				c = va_arg(ap, char *);
				if (strcmp(c, "%s") EQ 0) {
					/* optimize if just a string being printed */
					/* get next argument which is the only string */
					c = va_arg(ap, char *);
					}
				else if (strchr(c, '%') EQ NULL) {
					/* don't need printf fancy stuff, c points at string */
					}
				else {
					vsprintf(buff, c, ap);
					c = buff;
					}
				l = strlen(c);
				BNRP_printCount += l;
				if (BNRP_printCount GT BNRP_printLen) longjmp(BNRP_printEnv, TOOLONG);
				if ((curr = ((pipeHeader *)pipe)->lastPiece) EQ NULL) {
					curr = (pipePiece *)BNRP_malloc(sizeof(pipePiece));
					if (curr EQ NULL) longjmp(BNRP_printEnv, OUTOFMEMORY);
					((pipeHeader *)pipe)->firstPiece = ((pipeHeader *)pipe)->lastPiece = curr;
					curr->nextPiece = NULL;
					curr->nextChar = curr->lastChar = 0;
					}
				while (l GT (len = (PIPEBUFFER-(curr->lastChar)))) {
					memcpy(&(curr->c[curr->lastChar]), c, len);
					curr->lastChar += len;
					c += len;
					l -= len;
					curr->nextPiece = (pipePiece *)BNRP_malloc(sizeof(pipePiece));
					if (curr->nextPiece EQ NULL) longjmp(BNRP_printEnv, OUTOFMEMORY);
					curr = curr->nextPiece;
					curr->nextPiece = NULL;
					curr->nextChar = curr->lastChar = 0;
					((pipeHeader *)pipe)->lastPiece = curr;
					}
				/* remainder fits in this piece, just copy over */
				memcpy(&(curr->c[curr->lastChar]), c, l);
				curr->lastChar += l;
				break;
		case READCHAR:			/* (char *result) */
				c = va_arg(ap, char *);
				if (((curr = ((pipeHeader *)pipe)->firstPiece) NE NULL) && (curr->nextChar LT curr->lastChar)) {
					*c = curr->c[curr->nextChar];
					if (++curr->nextChar GE curr->lastChar) {
						if (curr->nextPiece EQ NULL) {
							/* leave an empty buffer */
							curr->nextChar = curr->lastChar = 0;
							}
						else {
							/* advance to next buffer */
							((pipeHeader *)pipe)->firstPiece = curr->nextPiece;
							BNRP_free(curr);
							}
						}
					}
				else {
					*c = EOF;
					res = FALSE;
					}
				break;
		case RETURNCHAR:		/* (char *character) */
				/* although unmodified, passed as pointer to avoid type promotion */
				c = va_arg(ap, char *);
				if ((curr = ((pipeHeader *)pipe)->firstPiece) EQ NULL) {
					/* impossible since pipe just created */
					res = FALSE;
					}
				else if (curr->nextChar EQ 0) {
					/* no room at beginning */
					if (curr->lastChar NE 0) {
						/* create new first piece if firstPiece is not empty */
						curr = (pipePiece *)BNRP_malloc(sizeof(pipePiece));
						if (curr EQ NULL) longjmp(BNRP_printEnv, OUTOFMEMORY);
						curr->nextPiece = ((pipeHeader *)pipe)->firstPiece;
						((pipeHeader *)pipe)->firstPiece = curr;
						}
					curr->nextChar = PIPEBUFFER-1;
					curr->lastChar = PIPEBUFFER;
					curr->c[curr->nextChar] = *c;
					}
				else
					curr->c[--curr->nextChar] = *c;
				break;
		case CLOSEFILE:			/* () */
				curr = ((pipeHeader *)pipe)->firstPiece;
				while (curr NE NULL) {
					next = curr->nextPiece;
					BNRP_free(curr);
					curr = next;
					}
				((pipeHeader *)pipe)->firstPiece = ((pipeHeader *)pipe)->lastPiece = NULL;
				BNRP_free((void *)pipe);
				break;
		case GETPOSITION:		/* (long *position) */
				p = va_arg(ap, long *);
				*p = 0;
				break;
		case SETPOSITION:		/* (long newposition) */
				l = va_arg(ap, long);
				if (l GT 0) {
					curr = ((pipeHeader *)pipe)->firstPiece;
					while ((curr NE NULL) &&
						   (curr NE ((pipeHeader *)pipe)->lastPiece) && 
						   (l GE (curr->lastChar - curr->nextChar))) {
						l -= curr->lastChar - curr->nextChar;
						next = curr->nextPiece;
						BNRP_free(curr);
						((pipeHeader *)pipe)->firstPiece = curr = next;
						}
					if (curr NE NULL) {
						/* know that l chars should fit in this buffer */
						/* or this is the only buffer left */
						curr->nextChar += l;
						if ((curr->nextChar GT curr->lastChar) || (l GT PIPEBUFFER))
							/* must be last buffer, clear it */
							curr->nextChar = curr->lastChar = 0;
						}
					}
				else if (l EQ -1) {
					curr = ((pipeHeader *)pipe)->firstPiece;
					while ((curr NE NULL) && (curr NE ((pipeHeader *)pipe)->lastPiece)) {
						next = curr->nextPiece;
						BNRP_free(curr);
						curr = next;
						}
					((pipeHeader *)pipe)->firstPiece = ((pipeHeader *)pipe)->lastPiece = curr;
					if (curr NE NULL) {
						curr->nextChar = curr->lastChar = 0;
						curr->nextPiece = NULL;
						}
					}
				else
					res = (l EQ 0);
				break;
		case GETERROR:			/* (short *error) */
				err = va_arg(ap, short *);
				*err = 0;
				break;
		case SETEOF:			/* () */
				 curr = ((pipeHeader *)pipe)->firstPiece;
				 while ((curr NE NULL) && (curr NE ((pipeHeader *)pipe)->lastPiece)) {
				       next = curr->nextPiece;
				       BNRP_free(curr);
				       curr = next;
				       }
				 ((pipeHeader *)pipe)->firstPiece = ((pipeHeader *)pipe)->lastPiece = curr;
				 if (curr NE NULL) {
				       curr->nextChar = curr->lastChar = 0;
				       curr->nextPiece = NULL;
				       }
				 break;

		case OPENFILE:			/* (char *name, char *mode, long *index) */
		default:
				res = FALSE;
		case FLUSHFILE:			/* () */
				break;
		}
	va_end(ap);
#ifdef debugpipes
	printf("\nPipe @ %ld, first = %p, last = %p\n", pipe, ((pipeHeader *)pipe)->firstPiece, ((pipeHeader *)pipe)->lastPiece);
	curr = ((pipeHeader *)pipe)->firstPiece;
	while (curr NE NULL) {
		printf("%p: (%d)", curr, curr->nextChar);
		for (l = curr->nextChar; l LT curr->lastChar; ++l) printf("%c", curr->c[l]);
		printf("(%d)\n", curr->lastChar);
		curr = curr->nextPiece;
		}
#endif
	return(res);
	}
#endif	

#ifdef ring1
BNRP_Boolean BNRP_needsQuotes(char *s)
{
	register unsigned char c;
	enum charClasses cl;
	
	c = *s++;
	cl = charClass[c];
	if (cl EQ r_bar) {				/* variable name */
		while (c = *s++) {
			cl = charClass[c];
			if (cl EQ r_letter) continue;
			if (cl EQ r_Ereal) continue;
			if (cl EQ r_capital) continue;
			if (cl EQ r_Ecap) continue;
			if (cl EQ r_digit0) continue;
			if (cl EQ r_digit) continue;
			if (cl EQ r_dot) {		/* must end in .. */
				if ((c = *s++) EQ 0) return(TRUE);
				if (charClass[c] NE r_dot) return(TRUE);
				return(*s NE 0);
				}
			if (cl NE r_bar) return(TRUE);
			}
		return(FALSE);
		}
	if ((cl NE r_letter) && 
		(cl NE r_Ereal) && 
		(cl NE r_singleatom)) return(TRUE);
	while (c = *s++) {
		cl = charClass[c];
		if (cl EQ r_letter) continue;
		if (cl EQ r_Ereal) continue;
		if (cl EQ r_capital) continue;
		if (cl EQ r_Ecap) continue;
		if (cl EQ r_digit0) continue;
		if (cl EQ r_digit) continue;
		if (cl NE r_bar) return(TRUE);
		}
	return(FALSE);
	}
#endif

#ifdef ring1
void BNRP_outputWithQuotes(char *s)
{
	char buff[104];
	register unsigned char c;
	int pos = 1;
	
	buff[0] = '\"';
	while (c = *s++) {
		if (pos GE 100) {
			buff[pos] = '\0';
			outputstr(buff);
			pos = 0;
			}
		if (c EQ '\n') { buff[pos++] = '\\'; buff[pos++] = 'n'; }
		else if (c EQ '\t') { buff[pos++] = '\\'; buff[pos++] = 't'; }
		else if (c EQ '\b') { buff[pos++] = '\\'; buff[pos++] = 'b'; }
		else if (c EQ '\r') { buff[pos++] = '\\'; buff[pos++] = 'r'; }
		else if (c EQ '\f') { buff[pos++] = '\\'; buff[pos++] = 'f'; }
		else if (c EQ '\\') { buff[pos++] = '\\'; buff[pos++] = '\\'; }
		else if (c EQ '\'') { buff[pos++] = '\\'; buff[pos++] = '\''; }
		else if (c EQ '"') { buff[pos++] = '\\'; buff[pos++] = '"'; }
		else if (charClass[c] EQ r_invalid) {
			sprintf(&buff[pos], "\\%02X", c);
			pos += 3;
			} 
		else 
			buff[pos++] = c;
		}
	buff[pos++] = '\"';
	buff[pos] = '\0';
	outputstr(buff);
	}
#endif

#ifdef ring4
void BNRP_dumpWithQuotes(FILE *f, char *s)
{
	BNRP_fileIndex = (long)f;
	BNRP_printProc = handleFileIO;
	BNRP_printCount = 0;
	BNRP_printLen = BNRP_getMaxLong();
	BNRP_outputWithQuotes(s);
	}
#endif

/* Change name from displayValue to BNRP_displayValue so that BNRP_termToString (ring 2)
   will compile. */
extern void BNRP_displayValue(long value, long nesting, long prec);

#ifdef ring1
void BNRP_displayValue(long value, long nesting, long prec)
{
	long result, t, orig, p, count, newprec, functor;
	ptr addr;
	TAG tag;
	long LDCount, LDHold, LDk, LDSaveAddr;
	char *sp, varname[20], nextch;
	li arity;
	
	if (value EQ 0xAAAAAAAA) {
		output("unknown");
		return;
		}
	if (++nesting GE 20) {
		output("....");
		return;
		}
	t = (long)&value;
	derefTV(&t, &orig, &tag, &result, &addr);
	switch (tag) {
		case VART:
					getVarName(BNRP_printTCB, result, varname);
					outputstr(varname);
					break;
		case TAILVART:
					getVarName(BNRP_printTCB, result, varname);
					outputstr(varname);
					output("..");
					break;
		case LISTT:
					nextch = '[';
					p = addrof(result);
					LDCount = 1;
					LDHold = 2;
					LDk = 0;
					derefTV(&p, &orig, &tag, &result, &addr);
					while (tag NE ENDT) {
						outputchar(nextch);
						if ((BNRP_printBlanks) && (nextch EQ ',')) output(" ");
						nextch = ',';
						if (tag EQ TAILVART) {
							getVarName(BNRP_printTCB, result, varname);
							outputstr(varname);
							output("..");
							break;
							}
						BNRP_displayValue(orig, nesting, 3000);
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
										output2("%c ...", nextch);
										break;
										}
									}
								}
							}
						}
					if (nextch EQ '[') output("[]"); else output("]");
					break;
		case STRUCTT:
					count = 0;
					p = result;
					pushAM(value, 0L, 0L);
					if (++count GT 1) output("\n");
					LDCount = 1;
					LDHold = 2;
					LDk = 0;
					get(long, p, arity.l);							/* get header */
					derefTV(&p, &orig, &tag, &result, &addr);		/* get functor */
					if (tag EQ SYMBOLT) {
						symbolEntry *s;
						checksym(result, s);
						sp = s->name;
						t = s->opType;
						newprec = s->opPrecedence;
						}
					else
						t = notOp;
					if ((t NE notOp) && (arity.i.b LT 0)) {
						long result, t, orig;
						ptr addr;
						TAG tag = SYMBOLT;
						
						t = p;
						arity.i.b = 0;
						while (tag NE ENDT) {
							++arity.i.b;
							derefTV(&t, &orig, &tag, &result, &addr);
							if (tag EQ TAILVART) {
								arity.i.b = -arity.i.b - 1;
								break;
								}
							}
						}
					if ((arity.i.b EQ 2) && (t & (xf | yf))) {
						/* postfix operator */
						if (newprec GE prec) output("(");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_displayValue(orig, nesting, newprec);
						output(" ");
						outputstr(sp);
						if (newprec GE prec) output(")");
						}
					if ((arity.i.b EQ 2) && (t & (fx | fy))) {
						/* prefix operator */
						if (newprec GE prec) output("(");
						outputstr(sp);
						output(" ");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_displayValue(orig, nesting, newprec);
						if (newprec GE prec) output(")");
						}
					else if ((arity.i.b EQ 3) && (t & (xfy | yfx | xfx))) {
						/* infix operator */
						if (newprec GE prec) output("(");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_displayValue(orig, nesting, newprec);
						output(" ");
						outputstr(sp);
						output(" ");
						derefTV(&p, &orig, &tag, &result, &addr);
						BNRP_displayValue(orig, nesting, newprec);
						if (newprec GE prec) output(")");
						}
					else {
						nextch = '(';
						functor = orig;
						if (functor EQ curlyAtom) {		/* special case for { */
							nextch = '{';
							}
						else if (BNRP_printQuotes && (functor EQ cutAtom)) {	/* special case for ! */
							 BNRP_outputWithQuotes(sp);
							 }
						else if (tag EQ SYMBOLT) {
							if (BNRP_printQuotes && BNRP_needsQuotes(sp))
								BNRP_outputWithQuotes(sp);
							else
								outputstr(sp);
							}
						else if (tag EQ VART) {
							getVarName(BNRP_printTCB, result, varname);
							outputstr(varname);
							}
						else
							output("???functor???");
						derefTV(&p, &orig, &tag, &result, &addr);
						while (tag NE ENDT) {
							outputchar(nextch);
							if ((BNRP_printBlanks) && (nextch EQ ',')) output(" ");
							nextch = ',';
							if (tag EQ TAILVART) {
								getVarName(BNRP_printTCB, result, varname);
								outputstr(varname);
								output("..");
								break;
								}
							if ((tag EQ STRUCTT) && (searchAM(orig, 0L, &t))) {
								get(long, result, t);		/* get structure header */
								get(long, result, t);		/* get functor name */
								deref(t, &orig, &tag, &result, &addr);
								if (tag EQ SYMBOLT) {
									sp = nameof(result);
									outputstr(sp);
									output("(...)");
									}
								else if (tag EQ VART) {
									getVarName(BNRP_printTCB, result, varname);
									outputstr(varname);
									output("(");
									}
								else
									output("????(...)");
								}
							else {
								BNRP_displayValue(orig, nesting, 3000);
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
											output2("%c ...", nextch);
											break;
											}
										}
									}
								}
							}
						if (nextch EQ '(') 
							output("()"); 
						else if (nextch EQ '{') 
							output("{}"); 
						else if (functor EQ curlyAtom)
							output("}"); 
						else 
							output(")");
						}
					discardLastAM();
					break;
		case INTT:
					output2("%ld", result);
					break;
		case FLOATT:{
					fp t;
					char buff[100], *p;
					
					t = *(fp *)result;
					sprintf(buff, "%1.*g", BNRP_getFPPrecision(), t);
					if ((strchr(buff, '.') NE NULL) || (!(isdigit(*buff) || (*buff EQ '-')))) {
						outputstr(buff);
						break;
						}
					/* need a ".0" since there is no decimal present */
					if ((p = strchr(buff, 'e')) NE NULL) {
						*p++ = '\0';
						outputstr(buff);
						outputstr(".0e");
						outputstr(p);
						break;
						}
					if ((p = strchr(buff, 'E')) NE NULL) {
						*p++ = '\0';
						outputstr(buff);
						outputstr(".0E");
						outputstr(p);
						break;
						}
					outputstr(buff);
					outputstr(".0");
					}
					break;
		case SYMBOLT:
					sp = nameof(result);
					if (BNRP_printQuotes && BNRP_needsQuotes(sp))
						BNRP_outputWithQuotes(sp);
					else
						outputstr(sp);
					break;
		case ENDT:
					output("**");
					break;
		}
	}
#endif

#ifdef ring2
BNRP_Boolean BNRP_checkSymbol(TCB *tcb, int mode)
{
	long index;
	TAG tag;
	
	BNRP_printTCB = tcb;
	BNRP_printCount = 0;
	BNRP_printLen = BNRP_getMaxLong();
	if (((tag = checkArg(tcb->args[1], &index)) EQ SYMBOLT) && (mode EQ READONLY)) {
		BNRP_fileIndex = USEHP;
		BNRP_printPos = nameof(index);
		BNRP_printProc = handleCharInput;
		return(TRUE);
		}
	else if (((tag EQ VART) || (tag EQ SYMBOLT)) && (mode EQ WRITEONLY)) {
		BNRP_fileIndex = USEHP;
		BNRP_printPos = (char *)tcb->hp;
		BNRP_printLen = tcb->heapend - tcb->hp - 100;
		BNRP_printProc = handleCharOutput;
		return(TRUE);
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_checkFile(TCB *tcb, int mode)
{
	long index;
	TAG tag;
	
	if (BNRP_checkSymbol(tcb, mode)) return(TRUE);
	if ((tag = checkArg(tcb->args[1], &index)) EQ INTT) {
		if (index EQ STDIN) {
			if ((mode & READONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stdin;
			BNRP_printProc = handleFileIO;
			}
		else if (index EQ STDOUT) {
			if ((mode & WRITEONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stdout;
			BNRP_printProc = handleFileIO;
			}
		else if (index EQ STDERR) {
			if ((mode & WRITEONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stderr;
			BNRP_printProc = handleFileIO;
			}
		else {
#ifndef solaris
			/* this doesn't work under Solaris */
			/* is this a test to make sure that index is actually a file? */
			if (fileno((FILE *)index) EQ EOF) return(FALSE);
#endif
			BNRP_fileIndex = index;
			BNRP_printProc = handleFileIO;
			}
		return(TRUE);
		}
	else if (tag EQ LISTT) {
		long p, orig, t;
		ptr addr;
	
		p = addrof(index);
		derefTV(&p, &orig, &tag, &BNRP_fileIndex, &addr);
		if (tag NE INTT) return(FALSE);
		derefTV(&p, &orig, &tag, &t, &addr);
		if (tag NE INTT) return(FALSE);
		BNRP_printProc = (overloadIOProcedure)t;
		if (BNRP_fileIndex EQ STDIN) {
			if ((mode & READONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stdin;
			}
		else if (BNRP_fileIndex EQ STDOUT) {
			if ((mode & WRITEONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stdout;
			}
		else if (BNRP_fileIndex EQ STDERR) {
			if ((mode & WRITEONLY) EQ 0) return(FALSE);
			BNRP_fileIndex = (long)stderr;
			}
		return(TRUE);
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_openFile(TCB *tcb)
{
	long BNRP_fileIndex, modeIndex, fileResult;
	pipeHeader *p;
	
	if ((tcb->numargs EQ 5) && 
		(checkArg(tcb->args[2], &BNRP_fileIndex) EQ SYMBOLT) && 
		(checkArg(tcb->args[3], &modeIndex) EQ SYMBOLT)) {
		if (handleFileIO(OPENFILE, (long)NULL, nameof(BNRP_fileIndex), nameof(modeIndex), &fileResult))
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, fileResult)) &&
				   unify(tcb, tcb->args[4], makeint(&tcb->hp, 0)) &&
				   unify(tcb, tcb->args[5], makeint(&tcb->hp, (long)handleFileIO)));
		else
			return(unify(tcb, tcb->args[4], makeint(&tcb->hp, BADFILENAME)));
		}
	else if ((tcb->numargs EQ 4) && 
		(checkArg(tcb->args[2], &BNRP_fileIndex) EQ SYMBOLT) && 
		(checkArg(tcb->args[3], &modeIndex) EQ SYMBOLT)) {
		if (handleFileIO(OPENFILE, (long)NULL, nameof(BNRP_fileIndex), nameof(modeIndex), &fileResult))
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, fileResult)) &&
				   unify(tcb, tcb->args[4], makeint(&tcb->hp, 0)));
		else
			return(unify(tcb, tcb->args[4], makeint(&tcb->hp, BADFILENAME)));
		}
	else if (tcb->numargs EQ 3) {			/* open a pipe */
		p = (pipeHeader *)BNRP_malloc(sizeof(pipeHeader));
		if (p NE NULL) {
			p->firstPiece = p->lastPiece = NULL;
			return(unify(tcb, tcb->args[1], makeint(&tcb->hp, (long)p)) &&
				   unify(tcb, tcb->args[2], makeint(&tcb->hp, (long)handlePipeIO)) &&
				   unify(tcb, tcb->args[3], makeint(&tcb->hp, 0)));
			}
		else
			return(unify(tcb, tcb->args[3], makeint(&tcb->hp, OUTOFMEMORY)));
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_closeFile(TCB *tcb)
{
	short err;
	
	if ((tcb->numargs EQ 2) && (BNRP_checkFile(tcb, READWRITE))) {
		(void)(*BNRP_printProc)(CLOSEFILE, BNRP_fileIndex);
		(void)(*BNRP_printProc)(GETERROR, BNRP_fileIndex, &err);
		return(unify(tcb, tcb->args[2], makeint(&tcb->hp, err)));
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_getChar(TCB *tcb)
{
	char buff[2];
	short err;
	
	if ((tcb->numargs EQ 4) && (BNRP_checkFile(tcb, READONLY)) &&
		(checkArg(tcb->args[4], &BNRP_printMsgs) EQ INTT)) {
		if (!(*BNRP_printProc)(READCHAR, BNRP_fileIndex, buff)) return(FALSE);
		buff[1] = '\0';
		(void)(*BNRP_printProc)(GETERROR, BNRP_fileIndex, &err);
		return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, buff, TEMPSYM, (buff[0] NE '$'))) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, err)));
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_readlnFile(TCB *tcb)
{
	char buffer[1025], c, *p, *a;
	short err;
	long size;
	
	if ((tcb->numargs EQ 4) && (BNRP_checkFile(tcb, READONLY)) &&
		(checkArg(tcb->args[4], &BNRP_printMsgs) EQ INTT)) {
		a = p = buffer;
		size = 1024;
		err = 0;
		while (--size GE 0) {
			if (!(*BNRP_printProc)(READCHAR, BNRP_fileIndex, &c)) {
				if (c EQ EOF) {
					/* if characters in buffer pretend EOF is \n for now */
					if (p EQ buffer) err = NOMORE;
					}
				else {
					(void)(*BNRP_printProc)(GETERROR, BNRP_fileIndex, &err);
					if (err EQ 0) err = IOERROR;
					}
				break;
				}
			if (c EQ '\n') break;
			*p++ = c;
			}
		if (size LT 0) {				/* out of space, try for bigger line */			
			long s1, e1, s2, e2, z1, z2;
			char *start;
			
			BNRP_freespace(tcb, &s1, &e1, &s2, &e2);
			z1 = e1 - s1;
			z2 = e2 - s2;
			a = start = (char *)((z1 GT z2) ? s1 : s2);
			memcpy(start, buffer, 1024);
			p = (char *)((long)start + 1024);
			size = ((z1 GT z2) ? z1 : z2) - 1024;
			while (--size GE 0) {
				if (!(*BNRP_printProc)(READCHAR, BNRP_fileIndex, &c)) {
					if (c EQ EOF) break;
					(void)(*BNRP_printProc)(GETERROR, BNRP_fileIndex, &err);
					if (err EQ 0) err = IOERROR;
					break;
					}
				if (c EQ '\n') break;
				*p++ = c;
				}
			}
		*p = '\0';							/* terminate string */
		return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, a, TEMPSYM, (a[0] NE '$'))) &&
			   unify(tcb, tcb->args[3], makeint(&tcb->hp, err)));
		}
	return(FALSE);
	}
#endif

#ifdef ring2
BNRP_Boolean BNRP_readFileSymbol(TCB *tcb)
{
	long result, ioresult;
	
	if ((tcb->numargs EQ 4) && (BNRP_checkSymbol(tcb, READONLY)) &&
		(checkArg(tcb->args[4], &BNRP_printMsgs) EQ INTT))
		if (BNRP_parse(tcb, BNRP_printProc, BNRP_fileIndex, &result, &ioresult))
			return(unify(tcb, tcb->args[2], result) && unify(tcb, tcb->args[3], makeint(&tcb->hp, ioresult)));
		else
			return(unify(tcb, tcb->args[3], makeint(&tcb->hp, ioresult)));
	return(FALSE);
	}
#endif

/* Added by Oz 04/95 */

#ifdef ring2
BNRP_term BNRP_makeTermFromString(TCB *tcb, const char * s)
{
        long result, ioresult;
        BNRP_printTCB = tcb;
        BNRP_printCount = 0;
        BNRP_printLen = BNRP_getMaxLong();
        BNRP_fileIndex = USEHP;
        BNRP_printPos = (char *)s;
        BNRP_printProc = handleCharInput;
        if (BNRP_parse(tcb, BNRP_printProc, BNRP_fileIndex, &result, &ioresult))
        	return((BNRP_term)result);
        else
        	return((BNRP_term)0);
	}
#endif


#ifdef ring4
BNRP_Boolean BNRP_readFile(TCB *tcb)
{
	long result, ioresult;
	
	if ((tcb->numargs EQ 4) && (BNRP_checkFile(tcb, READONLY)) &&
		(checkArg(tcb->args[4], &BNRP_printMsgs) EQ INTT))
		if (BNRP_parse(tcb, BNRP_printProc, BNRP_fileIndex, &result, &ioresult))
			return(unify(tcb, tcb->args[2], result) && unify(tcb, tcb->args[3], makeint(&tcb->hp, ioresult)));
		else
			return(unify(tcb, tcb->args[3], makeint(&tcb->hp, ioresult)));
	return(FALSE);
	}
#endif

#ifdef ring1
BNRP_Boolean BNRP_finishWrite(TCB *tcb)
{
	long options, items, maxLength, result = 0;
	int printPeriod;
	TAG tag;
	long p, orig, parm, t;
	ptr addr;
	long LDCount, LDHold, LDk, LDSaveAddr;
	
	if ((checkArg(tcb->args[2], &options) EQ INTT) &&
		(checkArg(tcb->args[4], &items) EQ LISTT) &&
		(checkArg(tcb->args[3], &maxLength) EQ INTT)) {
		
		/* set up AM for printing */
		clearAM();
		
		/* lower printing length if specified */
		if ((maxLength GT 0) && (maxLength LT BNRP_printLen)) BNRP_printLen = maxLength;
		
		/* get options */
		BNRP_printQuotes = ((options & 0x10) NE 0);
		BNRP_printCommas = ((options & 0x08) NE 0);
		BNRP_printBlanks = ((options & 0x04) NE 0);
		BNRP_printIntervals = ((options & 0x02) NE 0);
		printPeriod = ((options & 0x01) NE 0);

		/* set up error exit */
		if (result = setjmp(BNRP_printEnv)) {
			return(unify(tcb, tcb->args[5], makeint(&tcb->hp, result)));
			}

		/* go through the list, printing things one at a time */
		p = addrof(items);
		LDCount = 1;
		LDHold = 2;
		LDk = 0;
		derefTV(&p, &orig, &tag, &parm, &addr);
		while (tag NE ENDT) {
			BNRP_displayValue(orig, 1, 3000);
			if (tag EQ TAILVART) break;
			t = p;
			derefTV(&p, &orig, &tag, &parm, &addr);
			if (tag NE ENDT) {
				if (BNRP_printCommas) output(",");
				if (BNRP_printBlanks) output(" ");
				}
			if (p LE t) {			/* possible loop */
				if (--LDCount LE 0) {
					if (LDk EQ 0) {
						LDk = LDHold;
						LDHold += LDHold;
						LDSaveAddr = p;
						}
					else {
						--LDk;
						if (LDSaveAddr EQ p) return(FALSE);
						}
					}
				}
			}
		if (printPeriod) output(". ");
		if ((long)BNRP_fileIndex EQ USEHP) {
			if (!(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, (char *)tcb->hp, TEMPSYM, (*(char *)(tcb->hp) NE '$')))))
				result = IOERROR;
			}
		else
			(void)(*BNRP_printProc)(FLUSHFILE, BNRP_fileIndex);
		freeAM();
		return(unify(tcb, tcb->args[5], makeint(&tcb->hp, result)) &&
			   unify(tcb, tcb->args[6], makeint(&tcb->hp, BNRP_printCount)));
		}
	return(FALSE);
	}
#endif

#ifdef ring2
/*
 * BNRP_makeTermToString
 * ---------------------
 * Convert a Prolog term to a string representation in a fashion similar to
 * get_term and put_term
 */
BNRP_Boolean BNRP_makeTermToString(
	 TCB       *tcb,
	 BNRP_term	term,
	 char*		buffer,
	 long		buflen)
{
   /* Set up the initial print parameters to point to the buffer. */   
   BNRP_printTCB = tcb;
   BNRP_printCount = 0;
   BNRP_printLen = buflen - 100;			
   BNRP_fileIndex = USEHP;
   BNRP_printPos = buffer;
   BNRP_printProc = handleCharOutput;
   
   /* Make sure enough room for minimum result. */
   if (BNRP_printLen <= 3) {
      *buffer = 0;
      return FALSE;
   }

   /* set up AM for printing */
   clearAM();

   /* set options */
   BNRP_printQuotes = TRUE;
   BNRP_printCommas = TRUE;
   BNRP_printBlanks = FALSE;
   BNRP_printIntervals = TRUE;

   /* set up error exit */
   if (setjmp(BNRP_printEnv)) {
      *buffer = 0;			/* buffer set empty on failure */
      freeAM();
      return FALSE;
   }

   /* Format the term. Use large negative number for initial nesting level to avoid
      an elipsis for deeply nested terms. */
   BNRP_displayValue(term, -9999, 3000);
   output(". ");
   *BNRP_printPos = 0;		/* Terminating NUL byte */

   freeAM();
   
   return TRUE;
}
#endif

#ifdef ring2
BNRP_Boolean BNRP_writeFileSymbol(TCB *tcb)
{
	return(((tcb->numargs EQ 6) && (BNRP_checkSymbol(tcb, WRITEONLY)))
			? BNRP_finishWrite(tcb) : FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_writeFile(TCB *tcb)
{
	return(((tcb->numargs EQ 6) && (BNRP_checkFile(tcb, WRITEONLY)))
			? BNRP_finishWrite(tcb) : FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_atFile(TCB *tcb)
{
	long pos;
	
	if ((tcb->numargs EQ 2) && (BNRP_checkFile(tcb, READWRITE)))
		if ((*BNRP_printProc)(GETPOSITION, BNRP_fileIndex, &pos))
			if (pos EQ -1)
				return(unify(tcb, tcb->args[2], eofAtom));
			else
				return(unify(tcb, tcb->args[2], makeint(&tcb->hp, pos)));
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_seekFile(TCB *tcb)
{
	long pos;
	TAG t;
	
	if ((tcb->numargs EQ 2) && (BNRP_checkFile(tcb, READWRITE))) {
		t = checkArg(tcb->args[2], &pos);
		if (t EQ INTT)
			return((*BNRP_printProc)(SETPOSITION, BNRP_fileIndex, pos));
		else if ((t EQ SYMBOLT) && (pos EQ eofAtom))
			return((*BNRP_printProc)(SETPOSITION, BNRP_fileIndex, -1L));
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_eofFile(TCB *tcb)
{
	if ((tcb->numargs EQ 1) && (BNRP_checkFile(tcb, READWRITE)))
		return((*BNRP_printProc)(SETEOF, BNRP_fileIndex));
	return(FALSE);
	}
#endif

#ifdef ring3
BNRP_Boolean BNRP_consultFile(TCB *tcb)
{
	BNRP_term name;
	int res = -1;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &name) EQ SYMBOLT))
		res = loadFile(nameof(name));
	return(res EQ 0);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_doTraceback(TCB *tcb)
{
	long n;
	
	if ((tcb->numargs EQ 2) && (BNRP_checkFile(tcb, READWRITE)))
		switch (checkArg(tcb->args[2], &n)) {
			case INTT:
						/* user got parms right */
						BNRP_traceback(tcb, n);
						return(TRUE);
			case SYMBOLT:
						if (strcmp(nameof(n), "choicepoints") EQ 0) {
							BNRP_choicepoints(tcb, 16);
							return(TRUE);
							}
			}
	/* possible error, so output to stdout if possible */
	BNRP_fileIndex = (long)stdout;
	BNRP_printProc = handleFileIO;
	BNRP_traceback(tcb, 16);
	return(TRUE);
	}
#endif
