/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProText.c,v 1.3 1996/02/13 00:56:18 yanzhou Exp $
 *
 * $Log: ProText.c,v $
 * Revision 1.3  1996/02/13  00:56:18  yanzhou
 * OUTPUTSTRING of handleWindowIO is changed/optimized:
 *   1) a minor bug fixed, where the char immediately after the cursor position
 *      would get deleted.
 *   2) the cursor position is only shown whenever new lines have been inserted.
 *
 * Revision 1.2  1996/02/12  08:03:36  yanzhou
 * Minor changes to text windows:
 *   1) XmNautoShowCursorPosition is once again set to FALSE
 *   2) in handleWindowIO, XmTextShowPosition is called to force the cursor
 *      to be visible
 *   3) handleWindowIO now uses an on-stack local buffer if it is large
 *      enough to hold an output string.  Was calling XtMalloc().
 *
 * Revision 1.1  1995/09/22  11:26:58  harrisja
 * Initial version.
 *
 *
 */

/* include files */

#include <stdio.h>
#include <stddef.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#include <stdarg.h>
#else
#include <varargs.h>
#include <strings.h>
#endif
#include <string.h>
#include <memory.h>
#include <setjmp.h>

#include <X11/Xatom.h>   /* X and Motif libraries */
#include <X11/IntrinsicP.h>
#include <X11/Xlib.h>

#include <Xm/Xm.h>
#include <Xm/CascadeB.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/MainW.h>
#include <Xm/BulletinB.h>
#include <Xm/MwmUtil.h>
#include <Xm/RowColumn.h>
#include <Xm/Text.h>
#include <Xm/FileSB.h>
#include <Xm/CutPaste.h>

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProGraf.h"
#include "ProMenus.h"
#include "ProText.h"
#include "ProWindows.h"
#include "ProEvents.h"
#include "Prolog.h"

#define MAX_STRING_SIZE	1024
#define MAX_CLIPBOARD_TRIES 100	

XFontStruct	*sys_font,*appl_font;
FontInfo	sys_font_info,appl_font_info;

#define FONT_CACHE_SIZE 100
struct font_cache {
	FontInfo	*info;
	XFontStruct	*font;
} fontCache[FONT_CACHE_SIZE];
int	numCachedFonts = 0;

Atom		XA_CLIPBOARD,XA_TIMESTAMP;
Boolean		ScrapReqOutstanding = FALSE;
Time		LastScrapChangedTime = (Time) NULL;

XmTextPosition SearchString();

char *TextGetSelection(w)
PTextWindow *w;
{
	if (w == (PTextWindow *) focus_window)
		return XmTextGetSelection(w->text);
	else {
		XmTextPosition len;
		char *s;
		Arg args[1];

		if (w->contents == NULL) {
			XtSetArg(args[0], XmNvalue, &(w->contents));
			XtGetValues(w->text,args,1);
		}
		len = w->selEnd-w->selStart;
		s = XtMalloc((int)len+1);
		strncpy(s,w->contents+w->selStart,(int)len);
		s[len] = '\0';
		return s;
	}
}

void TextGetSelectionPosition(w,start,end)
PTextWindow *w;
XmTextPosition *start,*end;
{
	if (w == (PTextWindow *) focus_window) {
		if (!XmTextGetSelectionPosition(w->text,start,end))
			*start = *end = XmTextGetInsertionPosition(w->text);
	} else {
		*start = w->selStart;
		*end = w->selEnd;
	}
#ifdef xDEBUG
	if (DebugTrace)
		printf("TextGetSelectionPosition(%d,%d)\n",*start,*end);
#endif
}


void TextSetSelection(w,start,end)
PTextWindow *w;
XmTextPosition start,end;
{	
	if (w == (PTextWindow *) focus_window) {
		XmTextSetSelection(w->text,start,end,XtLastTimestampProcessed(display));
#ifdef xDEBUG
		if (DebugTrace)
			printf("TextSetSelection(%d,%d)\n",start,end);
#endif
	}
	else {
		XmTextSetHighlight(w->text,w->selStart,w->selEnd,XmHIGHLIGHT_NORMAL);
		w->selStart = start;
		w->selEnd = end;
		XmTextSetHighlight(w->text,start,end,XmHIGHLIGHT_SELECTED);
#ifdef xDEBUG
		if (DebugTrace)
			printf("TextSetHighlight(%d,%d)\n",start,end);
#endif
	}
}

/* moves the cursor but doesn't cause the window to scroll */
void TextSetCursorPosition(w,pos)
PTextWindow *w;
XmTextPosition pos;
{
	/*Arg	args[1]; REMOVED 06/95 */

	if (w == (PTextWindow *) focus_window) {
		XmTextSetSelection(w->text,pos,pos,XtLastTimestampProcessed(display));
	}
	else {
		XmTextSetHighlight(w->text,w->selStart,w->selEnd,XmHIGHLIGHT_NORMAL);
		w->selStart = pos;
		w->selEnd = pos;
	}
}

void TextSetInsertionPosition(w,pos)
PTextWindow *w;
XmTextPosition pos;
{
	if (w == (PTextWindow *) focus_window) {
		XmTextSetSelection(w->text,pos,pos,XtLastTimestampProcessed(display));
		XmTextShowPosition(w->text,pos);  /* NEW 06/95 */
#ifdef xDEBUG
		if (DebugTrace)
			printf("TextSetInsertionPosition(%d)\n",pos);
#endif
	}
	else {
		XmTextSetHighlight(w->text,w->selStart,w->selEnd,XmHIGHLIGHT_NORMAL);
		w->selStart = pos;
		w->selEnd = pos;
	}
}

void TextSwapSelection(from,to)
PTextWindow *from,*to;
{   
	Boolean     setHighlight = FALSE;

	if (from == to) return;

	if (from &&
	    (from->type == ptext)) {
            XmTextGetSelectionPosition(from->text,&from->selStart,&from->selEnd);
	    setHighlight = TRUE;
	}

	if (to && (to->type == ptext))
	    XmTextSetSelection(to->text,to->selStart,to->selEnd,XtLastTimestampProcessed(display));

	if (setHighlight)
	    XmTextSetHighlight(from->text,from->selStart,from->selEnd,XmHIGHLIGHT_SELECTED);
}

void TextInsert(w,pos,s)
PTextWindow *w;
XmTextPosition pos;
char *s;
{
	XmTextInsert(w->text, pos, s);
}

void TextReplace(w,start,end,s)
PTextWindow *w;
XmTextPosition start,end;
char *s;
{
	XmTextReplace(w->text,start,end,s);
	if (start == end) {
		start = end += strlen(s);
		TextSetSelection(w,start,end);
	}
}

Boolean TextCut(w)
PTextWindow *w;
{
	Boolean result;
	XmTextPosition start, end;

	XmTextGetSelectionPosition(w->text,&start,&end);
	TextSwapSelection((PTextWindow *)focus_window, w);
	result = XmTextCut(w->text, XtLastTimestampProcessed(display));
	TextSwapSelection(w,(PTextWindow *)focus_window);
	TextSetInsertionPosition(w, start);
	return result;
}


Boolean TextCopy(w)
PTextWindow *w;
{
	Boolean result;

	TextSwapSelection((PTextWindow *)focus_window, w);
	result = XmTextCopy(w->text, XtLastTimestampProcessed(display));
	TextSwapSelection(w,(PTextWindow *)focus_window);
	return result;
}

Boolean TextPaste(w)
PTextWindow *w;
{
	Boolean result;
	XmTextPosition	start,end;
	int	status = 0;
	unsigned long length;

	TextSwapSelection((PTextWindow *)focus_window, w);
	XmTextGetSelectionPosition(w->text,&start,&end);
    status = XmClipboardInquireLength(display, XtWindow(w->text), "STRING", &length);

    if (status == ClipboardNoData || length == 0) return False;

	result = XmTextPaste(w->text);
	/* REMOVED start += length-1; fix for cursor positioning problem */
	start += length;	/* NEW */
	XmTextSetSelection(w->text,start,start,XtLastTimestampProcessed(display));
	TextSwapSelection(w,(PTextWindow *)focus_window);
	return result;
}

Boolean TextRemove(w)
PTextWindow *w;
{
	Boolean result;
	XmTextPosition	start,end;
	
	TextSwapSelection((PTextWindow *)focus_window, w);
	XmTextGetSelectionPosition(w->text,&start,&end);
	if (start != end)
		result = XmTextRemove(w->text);
	else
		result = TRUE;
	XmTextSetSelection(w->text,start,start,XtLastTimestampProcessed(display));
	TextSwapSelection(w,(PTextWindow *)focus_window);
	return result;
}

/* Prolog primitive getSelection(+W,-Sel) */
BNRP_Boolean getSelection(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*s;
	BNRP_tag	tag;
	BNRP_Boolean	res = FALSE;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	s = TextGetSelection(w);
	if (s == NULL) s = XtNewString("");

#ifdef xDEBUG
	if (DebugTrace)
		printf("getSelection(%s)\n",s);
#endif
	if ((tag=BNRP_getValue(tcb->args[2], &p)) == BNRP_var)
		res = BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb,s));
	else if (tag == BNRP_list) {
		BNRP_term	list = p.term.first;
		ioProc		proc;
		long		fileP;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		fileP = (long) p.ival;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		proc = (ioProc) p.ival;
		/* REMOVED Apr. 95 (void) (*proc)(OUTPUTSTRING, fileP, s); */
		(void) (*proc)(OUTPUTSTRING, fileP, STRING, s,"");  /* NEW */
		res = TRUE;
	}
	XtFree(s);
	return res;
	
}

/* Prolog primitive getselectcabs(+W,-Start,-End) */
BNRP_Boolean getSelectCAbs(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	XmTextPosition  start,end;

	if (tcb->numargs != 3)
		return FALSE;
		
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	TextGetSelectionPosition(w, &start, &end);

#ifdef xDEBUG
	if (DebugTrace)
		printf("getSelectCAbs(%d,%d)\n",start,end);
#endif

	return BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb,(long int)start)) &&
	       BNRP_unify(tcb, tcb->args[3], BNRP_makeInteger(tcb,(long int)end));
}

/* Prolog primitive setcursorposition(+W,+Pos) */
BNRP_Boolean setCursorPosition(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	XmTextPosition  pos,textLen;

	if (tcb->numargs != 2)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	textLen = XmTextGetLastPosition(w->text);

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	pos = p.ival;
	if (pos > textLen) pos = textLen;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setCursorPosition(%d)\n",pos);
#endif

	TextSetCursorPosition(w,pos);

	return TRUE;
}

/* Prolog primitive setselectcabs(+W,+Start,+End) */
BNRP_Boolean setSelectCAbs(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	XmTextPosition  start,end,textLen;

	if (tcb->numargs != 3)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	textLen = XmTextGetLastPosition(w->text);

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	start = p.ival;
	if (start > textLen) start = textLen;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	end = p.ival;
	if (end > textLen) end = textLen;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setSelectCAbs(%d,%d)\n",start,end);
#endif

	TextSetSelection(w,start,end);

	return TRUE;
}

/* Prolog primitive setselectlabs(+W,+Start,+End) */
BNRP_Boolean setSelectLAbs(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	XmTextPosition  start,end;
	int  		lstart,lend;
	Arg		args[1];
	char		*s;

	if (tcb->numargs != 3) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	lstart = p.ival;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	lend = p.ival - lstart;			/* make lend relative to start line */

	if (w->contents == NULL) {
		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text,args,1);
	}
	
	for(start=0,s=w->contents;(lstart>0) && *s;s++,start++)
		if (*s == '\n') lstart--;

	for(end=start;(lend>0) && *s;s++,end++)
		if (*s == '\n') lend--;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setSelectLAbs(%d,%d)\n",lstart,lend);
#endif

	TextSetSelection(w,start,end);

	return TRUE;
}

/* Prolog primitive setselectlrel(+W,+Start,+End) */
BNRP_Boolean setSelectLRel(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow		*w;
	BNRP_result		p;
	XmTextPosition  start,end;
	int  			lstart,lend;
	char			*s;

	if (tcb->numargs != 3) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	lstart = p.ival;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	lend = p.ival;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setSelectLRel(%d,%d)\n",lstart,lend);
#endif

	TextGetSelectionPosition(w,&start,&end);
	if (w->contents == NULL) {
		Arg args[1];

		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text,args,1);
	}

	/* move start to after next n <cr>'s if n > 0, */
	/* else back over -n <cr>'s and stop behind the previous one */
	s = w->contents+start;
	if (lstart > 0) {
		char c;
		while (c = *s++) {				/* go until end of file */
			++start;					/* advance to next character */
			if (c == '\n')				/* <cr> encountered */
				if (--lstart == 0)		/* decrement number of lines to skip */
					break;				/* if at 0, then leave cursor after <cr> */
			}
		}
	else {			/* lstart <= 0 */
		while (--start > 0) {			/* go till start of file */
			if (*--s == '\n')			/* previous char a <cr> */
				if (++lstart > 0) {		/* yes, have we gone the distance ? */
					++start;			/* advance to after <cr> */
					break;				/* get out of here */
					}
			}
		}

	/* move end to after next n <cr>'s if n > 0, */
	/* else back over -n <cr>'s and stop behind the previous one */
	s = w->contents+end;
	if (lend > 0) {
		char c;
		while (c = *s++) {				/* go until end of file */
			++end;						/* advance to next character */
			if (c == '\n')				/* <cr> encountered */
				if (--lend == 0)		/* decrement number of lines to skip */
					break;				/* if at 0, then leave cursor after <cr> */
			}
		}
	else {			/* lend <= 0 */
		while (--end > 0) {				/* go till start of file */
			if (*--s == '\n')			/* previous char a <cr> ? */
				if (++lend > 0) {		/* yes, have we gone the distance ? */
					++end;				/* advance to after <cr> */
					break;				/* get out of here */
					}
			}
		}
	TextSetSelection(w,start,end);
	return TRUE;
}

/* Prolog primitive setselectcrel(+W,+Start,+End) */
BNRP_Boolean setSelectCRel(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	XmTextPosition  start,end,selStart,selEnd,lastPos;

	if (tcb->numargs != 3)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	start = p.ival;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	end = p.ival;

	TextGetSelectionPosition(w,&selStart,&selEnd);
	lastPos = XmTextGetLastPosition(w->text);

	/* fix 93/04/16 JR to handle end_of_file properly, */
	/* comes in as maxint, adding selStart makes it */
	/* negative, so it becomes 0 */
	if (start > lastPos) 
		start = lastPos;
	else {
		start = selStart + start;
		if (start < 0) start = 0;
		else if (start > lastPos) start = lastPos;
	}

	/* fix 93/04/16 JR as above for end */
	if (end > lastPos) 
		end = lastPos;
	else {
		end = selEnd + end;
		if (end < 0) end = 0;
		else if (end > lastPos) end = lastPos;
	}

#ifdef xDEBUG
	if (DebugTrace)
		printf("setSelectCRel(%d,%d)\n",start,end);
#endif

	TextSetSelection(w,start,end);

	return TRUE;
}

/* Prolog primitive setselection(+W,+Sel) */
BNRP_Boolean setSelection(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*find;
	int		findLen,textLen;
	XmTextPosition  start,end,place;
	BNRP_Boolean	Found;
	Arg		args[1];

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	find = p.sym.sval;

	findLen = strlen(find);
	if (findLen == 0) return FALSE;

	if (w->contents == NULL) {
		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text,args,1);
	}
	textLen = XmTextGetLastPosition(w->text);
	
	TextGetSelectionPosition(w, &start, &end);
	if ((start != end) && ((end-start) == findLen)) {
		if ((w->caseSense) ? (strncmp(find, w->contents+start, findLen) == 0) : eqStrN(find, w->contents+start, findLen)) { 
		/* make sure we pick something else */
			start++;
			end--;
		}
	}

	if (w->scanForward) {
		place = SearchString(w->contents, start, textLen-start, find, findLen, w->caseSense);
		Found = (place <= textLen);
	} else {
		place = SearchString(w->contents, end, -end-1, find, findLen, w->caseSense);
		Found = (place >= 0);
	}

	if (Found) {
#ifdef xDEBUG
		if (DebugTrace)
			printf("setSelection(%s,%d,%d)\n",find,place,place+findLen);
#endif
		TextSetSelection(w,place,place+findLen);
		XmTextShowPosition(w->text,place);	/* NEW 07/95 When doing a 'Find', wasn't moving cursor to new location */
	}

	return Found;
	
}

/* Prolog primitive getcsize(+W,?Chars) */
BNRP_Boolean getCsize(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	return BNRP_unify(tcb, tcb->args[2], 
			BNRP_makeInteger(tcb, (long int)XmTextGetLastPosition(w->text)));
	
}

/* Prolog primitive getlsize(+W,?Lines) */
BNRP_Boolean getLsize(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*s;
	int		lines=0;
	Arg		args[1];

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (w->contents == NULL) {
		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text, args, 1);
	}
	
	for (s=w->contents;*s;s++)
		if (*s == '\n') lines++;
	
	return BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, (long int)lines));
	
}

/* Prolog primitive getselectlabs(+W,?start,?end) */
BNRP_Boolean getSelectLAbs(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*s;
	int		lstart=0,lend=0;
	XmTextPosition  start,end;
	Arg		args[1];

	if (tcb->numargs != 3) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (w->contents == NULL) {
		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text, args, 1);
	}
	
	TextGetSelectionPosition(w,&start,&end);

	for (s=w->contents;start && *s;s++,start--)
		if (*s == '\n') lstart++;
	lend = lstart;
	for (;end & *s;s++,end--);
		if (*s == '\n') lend++;

	return BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, (long int)lstart)) 
	    && BNRP_unify(tcb, tcb->args[3], BNRP_makeInteger(tcb, (long int)lend));
	
}

/* Prolog primitive doeditaction(+W,+EditAction) */
BNRP_Boolean doEditAction(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;

#ifdef DEBUG
	if (DebugTrace)
		printf("editAction(%s)\n",p.sym.sval);
#endif

	if (strcmp(p.sym.sval, "cut") == 0)
		return TextCut(w);
	else if (strcmp(p.sym.sval, "copy") == 0)
		return TextCopy(w);
	else if (strcmp(p.sym.sval, "paste") == 0)
		return TextPaste(w);
	else if (strcmp(p.sym.sval, "clear") == 0)
		return TextRemove(w);
	return FALSE;
}

char *contentsOfPipe(proc,fileP)
ioProc	proc;
long int	fileP;
{
	char	*s,c;
	int		i,j;
	s = XtMalloc(MAX_STRING_SIZE+1);
	i = j = 0;
	while ((*proc)(READCHAR, fileP, &c)) {
		if (c == EOF) break;
		s[i++] = c;
		j++;
		if (j == MAX_STRING_SIZE) {
			s = XtRealloc(s,i+MAX_STRING_SIZE+1);
			j = 0;
		}
	}
	s[i] = '\0';
	return s;
}

/* Prolog primitive doinsert(+W,+S) */
BNRP_Boolean doInsert(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*s;
	XmTextPosition	start,end,len;
	BNRP_tag	tag;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if ((tag=BNRP_getValue(tcb->args[2], &p)) == BNRP_symbol) {
		s = XtNewString(p.sym.sval);
	}
	else if (tag == BNRP_list) {
		BNRP_term	list = p.term.first;
		ioProc		proc;
		long		fileP;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		fileP = (long) p.ival;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		proc = (ioProc) p.ival;
		s = contentsOfPipe(proc,fileP);
	}
	else return FALSE;

#ifdef DEBUG
	if (DebugTrace)
		printf("doInsert(%s)\n",s);
#endif

	TextGetSelectionPosition(w,&start,&end);
	/* added 93/04/30 JR to fix the highlighted text when we are done */
	if (start != end) TextSetSelection(w, start, start);
	TextInsert(w,start,s);
	len = strlen(s);
	TextSetSelection(w, start+len, end+len);
	XtFree(s);
	return TRUE;
}

/* Prolog primitive doreplace(+W,+S) */
BNRP_Boolean doReplace(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	char		*s;
	XmTextPosition	start,end;
	BNRP_tag	tag;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if ((tag=BNRP_getValue(tcb->args[2], &p)) == BNRP_symbol) {
		s = XtNewString(p.sym.sval);
	}
	else if (tag == BNRP_list) {
		BNRP_term	list = p.term.first;
		ioProc		proc;
		long		fileP;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		fileP = (long) p.ival;
		if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
		proc = (ioProc) p.ival;
		s = contentsOfPipe(proc,fileP);
	}
	else return FALSE;

#ifdef DEBUG
	if (DebugTrace)
		printf("doReplace(%s)\n",s);
#endif

	TextGetSelectionPosition(w,&start,&end);
	/* added 93/04/30 JR to fix the highlighted text when we are done */
	if (start != end) TextSetSelection(w, start, start);
	TextReplace(w,start,end,s);
	TextSetInsertionPosition(w, start+strlen(s));
	XtFree(s);
	return TRUE;
}

/* Prolog primitive getscandirection(+W,?ScanDirection) */
BNRP_Boolean getScanDirection(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

#ifdef xDEBUG
	if (DebugTrace)
		printf("getScanDirection(%s)\n",w->scanForward ? "forward" 
							       : "backward");
#endif

	return BNRP_unify(tcb, tcb->args[2],
				BNRP_makeSymbol(tcb, w->scanForward ? "forward" : "backward"));
}

/* Prolog primitive getcasesense(+W,?YesNo) */
BNRP_Boolean getCaseSense(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

#ifdef xDEBUG
	if (DebugTrace)
		printf("getCaseSense(%s)\n",w->caseSense ? "yes" : "no");
#endif

	return BNRP_unify(tcb, tcb->args[2], 
						BNRP_makeSymbol(tcb,(w->caseSense ? "yes" : "no")));
}

/* Prolog primitive setcasesense(+W,+YesNo) */
BNRP_Boolean setCaseSense(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	if (strcmp(p.sym.sval,"yes") == 0)
		w->caseSense = TRUE;
	else if (strcmp(p.sym.sval,"no") == 0)
		w->caseSense = FALSE;
	else
		return FALSE;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setCaseSense(%s)\n",w->caseSense ? "yes" : "no");
#endif

	return TRUE;
}

/* Prolog primitive setscandirection(+W,+Direction) */
BNRP_Boolean setScanDirection(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	if (strcmp(p.sym.sval,"forward") == 0)
		w->scanForward = TRUE;
	else if (strcmp(p.sym.sval,"backward") == 0)
		w->scanForward = FALSE;
	else 
		return FALSE;

#ifdef xDEBUG
	if (DebugTrace)
		printf("setScanDirection(%s)\n",w->scanForward ? "forward" 
							       : "backward");
#endif

	return TRUE;
}

BNRP_Boolean commonGetTextSize(tcb,fontInfo)
BNRP_TCB	*tcb;
FontInfo	*fontInfo;
{
	return BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, (long int)fontInfo->size));
}

BNRP_Boolean commonGetTextFont(tcb,fontInfo)
BNRP_TCB	*tcb;
FontInfo	*fontInfo;
{
	return BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb, fontInfo->name));
}

/* Prolog primitive gettextsize(+W,?Size) */
BNRP_Boolean getTextSize(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	return commonGetTextSize(tcb, &w->fontInfo);
}

/* gettextwidth(+W, +S, -W) */
BNRP_Boolean getTextWidth(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	PTextWindow	*w;

	if (tcb->numargs != 3) return FALSE;

	if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
	w = (PTextWindow *)p.ival;

	if (BNRP_getValue(tcb->args[2],&p) != BNRP_symbol) return FALSE;
	return BNRP_unify(tcb, tcb->args[3], 
							BNRP_makeInteger(tcb, (long int) XTextWidth(w->font, p.sym.sval, strlen(p.sym.sval))));
	
}
/* Prolog primitive gettextfont(+W,?Font) */
BNRP_Boolean getTextFont(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	return commonGetTextFont(tcb, &w->fontInfo);
}

XFontStruct *findCachedFont(info)
FontInfo *info;
{
	int	i;

	for (i=0;i<numCachedFonts;i++)
		if ((fontCache[i].info->size == info->size) &&
			(fontCache[i].info->weight == info->weight) &&
			(fontCache[i].info->slant == info->slant) &&
			(strcmp(fontCache[i].info->name, info->name)==0))
			return fontCache[i].font;
	return NULL;
}

Boolean cachedFont(font)
XFontStruct	*font;
{
	int	i;

	for (i=0;i<numCachedFonts;i++)
		if (fontCache[i].font == font)
			return TRUE;
	return FALSE;
}

void cacheFont(info,font)
FontInfo	*info;
XFontStruct	*font;

{
	if (numCachedFonts >= FONT_CACHE_SIZE) return;
	if (cachedFont(font)) return; /* should be redundant */

	fontCache[numCachedFonts].info = (FontInfo *) XtMalloc(sizeof(FontInfo));
	*(fontCache[numCachedFonts].info) = *info;
	fontCache[numCachedFonts].info->name = XtNewString(info->name);
	fontCache[numCachedFonts].font = font;
	numCachedFonts++;
}

void GetFontInfo(font, info)
XFontStruct	*font;
FontInfo	*info;
{
	int i;
	char *prop_name,*temp,*c;

	info->name = NULL;
	info->weight = NORMAL_WEIGHT;
	info->slant = NORMAL_SLANT;
	info->size = 12;

	for(i=0;i<font->n_properties;i++) {
		if (font->properties[i].name == XA_POINT_SIZE) {
			info->size = font->properties[i].card32/10;
		}
		else if (font->properties[i].name == XA_FAMILY_NAME) {
			info->name = XGetAtomName(display, font->properties[i].card32);
			for (c=info->name;*c;c++) 
				*c = tolower(*c);
		}
		else {
			prop_name = XGetAtomName(display,font->properties[i].name);
			if (strcmp(prop_name, "WEIGHT_NAME") == 0) {
				if (temp = XGetAtomName(display, font->properties[i].card32)) {
					if (strcmp(temp,"Medium") == 0)
						info->weight = NORMAL_WEIGHT;
					else if (strcmp(temp,"Bold") == 0)
						info->weight = BOLD_WEIGHT;
					XFree(temp);
				}
			}
			else if (strcmp(prop_name, "SLANT") == 0) {
				if (temp = XGetAtomName(display, font->properties[i].card32)) {
					if (strcmp(temp,"R") == 0)
						info->slant = NORMAL_SLANT;
					else if (strcmp(temp,"I") == 0)
						info->slant = ITALIC_SLANT;
					XFree(temp);
				}
			}
			XFree(prop_name);
		}
	}
}

XFontStruct *getFontBySpec(fontSpec)
char	*fontSpec;
{
	char	**fontNames;
	int		i,count;
	XFontStruct	*font = NULL;
	
#ifdef DEBUG
	if (DebugTrace)
		printf("Get font %s\n",fontSpec);
#endif
	fontNames = XListFonts(display, fontSpec, 1, &count);
	for (i=0;i<count;i++) {
		font = XLoadQueryFont(display, fontNames[i]);
		if (font) break;
	}
	XFreeFontNames(fontNames);
	return font;
}

XFontStruct	*getFont(info,exact)
FontInfo	*info;
Boolean		exact;
{
	char	fontSpec[256];
	XFontStruct	*font = NULL;
	char	*weight,*slant,*temp,*prop_name;
	char	**fontNames;
	char	*fontName;
	int		i,diff,min_diff,min_i,count;
	int		matches;
	Boolean	failed_match;
#ifdef fontDEBUG
	Atom	value;
#endif

	if (strcmp(info->name,"applfont") == 0)
		fontName = appl_font_info.name;
	else if (strcmp(info->name, "systemfont") == 0)
		fontName = sys_font_info.name;
	else
		fontName = info->name;
	if (font = findCachedFont(info))
		return font;

	switch (info->weight) {
	case NORMAL_WEIGHT:	weight = "Medium";
						break;
	case BOLD_WEIGHT:	weight = "Bold";
	}
	switch (info->slant) {
	case NORMAL_SLANT:	slant = "R";	
						break;
	case ITALIC_SLANT:	slant = "I";
	}

	font = XLoadQueryFont(display, fontName);
	if (font) {
		/* check size, weight and slant match */

		matches = 3;	/* number of properties we have to check */
						/* if a property is unspecified we assume it matches */
		failed_match = FALSE;

		for(i=0;i<font->n_properties;i++) {

			prop_name = XGetAtomName(display,font->properties[i].name);
			if (font->properties[i].name == XA_POINT_SIZE) {
				XFree(prop_name);
				if (font->properties[i].card32 != info->size*10) {
					failed_match = TRUE;
				 	break; /* no match */
				}
				if (--matches == 0)	break; /* match */
			}
			else if (strcmp(prop_name,"WEIGHT_NAME") == 0) {
				XFree(prop_name);
				if (temp = XGetAtomName(display, font->properties[i].card32)) {
					if (strcmp(temp,weight)) {
						XFree(temp);
						failed_match = TRUE;
				 		break; /* no match */
					}
					XFree(temp);
					if (--matches == 0) break; /* match */
				}
			}
			else if (strcmp(prop_name,"SLANT") == 0) {
				XFree(prop_name);
				if (temp = XGetAtomName(display, font->properties[i].card32)) {
					if (strcmp(temp,slant)) {
						if ((info->slant != ITALIC_SLANT) || (strcmp(temp,"O"))) { /* Oblique matches italic */
							XFree(temp);
							failed_match = TRUE;
							break; /* no match */
						}
					}
					XFree(temp);
					if (--matches == 0) break; /* match */
				}
			}
			else XFree(prop_name);
		}
		if (failed_match) 
			XFreeFont(display,font);
		else {
			goto return_font;
		}
	}

	sprintf(fontSpec,"-*-%s-%s-%s-*-*-%d-%d-75-75-*-*-iso8859-*", fontName, weight, slant, info->size, info->size*10);
	font = getFontBySpec(fontSpec);
	if (font) goto return_font;

	if (info->slant == ITALIC_SLANT) {	/* if couldn't find italic, try oblique */
		sprintf(fontSpec,"-*-%s-%s-o-*-*-%d-%d-75-75-*-*-iso8859-*", fontName, weight, info->size, info->size*10);
		font = getFontBySpec(fontSpec);
		if (font) goto return_font;
	}

	if (exact) goto return_font; /* if want exact match, give up now */

	if (info->slant == ITALIC_SLANT) {	/* if couldn't find italic, try any slant */
		sprintf(fontSpec,"-*-%s-%s-*-*-*-%d-%d-75-75-*-*-iso8859-*", fontName, weight, info->size, info->size*10);
		font = getFontBySpec(fontSpec);
		if (font) goto return_font;
	}

	/* wild card size and try to pick the closest size */	
try_list:
	sprintf(fontSpec,"-*-%s-%s-%s-*-*-*-*-75-75-*-*-iso8859-*", fontName, weight, slant);
	fontNames = XListFonts(display, fontSpec, 100, &count);
	min_diff = 32767;
	for (i=0;i<count;i++) {
		diff = getSize(fontNames[i]) - info->size;
		if (diff < 0) diff = -diff;
		if (diff < min_diff) {
			min_diff = diff;
			min_i = i;
		}
	}
	if (min_diff <= MAX_FONT_SIZE_DIFF)
		font = XLoadQueryFont(display, fontNames[min_i]);
	else if (strcmp(slant,"I")==0) {
		slant = "*";
		XFreeFontNames(fontNames);
		goto try_list;
	}
	else if (strcmp(weight,"Bold")==0) {
		weight = "*";
		XFreeFontNames(fontNames);
		goto try_list;
	}
	XFreeFontNames(fontNames);
		
return_font:
#ifdef fontDEBUG
		printf("Font Properties for: %s\n",fontName);
		if (font) {
			for(i=0;i<font->n_properties;i++) {
				temp = XGetAtomName(display,font->properties[i].name);
				printf("     %s(%d)",temp,font->properties[i].name);
				XFree(temp);
				if (XGetFontProperty(font, font->properties[i].name, &value)) {
					printf(" = %d ", value);
					if (temp=XGetAtomName(display,value)) {
						printf(" = %s", temp);
						XFree(temp);
					}
				}
				printf("\n");	
			}
		}
#endif
	cacheFont(info,font);
	return font;
}

BNRP_Boolean setTextSize(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	Boolean	res = FALSE;
	XFontStruct		*font;
	Arg		args[2];
	int		n;
	FontInfo	info;
	XmFontList	fontList;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	if (p.ival == w->fontInfo.size) return TRUE;

	info.name = w->fontInfo.name;
	info.size = p.ival;	
	info.weight = w->fontInfo.weight;
	info.slant = w->fontInfo.slant;
	if (font = getFont(&info,FALSE)) {
		n=0;
		XtSetArg(args[n], XmNfontList, fontList=XmFontListCreate(font, charset)); n++;
		XtSetValues(w->text,args,n);
		XmFontListFree(fontList);
		res = TRUE;
		w->fontInfo.size = p.ival;
		w->font = font;
	}
	return res;
}

/* Prolog primitive settextfont(+W,+Font) */
BNRP_Boolean setTextFont(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	Boolean	res = FALSE;
	XFontStruct		*font;
	Arg		args[2];
	int		n;
	FontInfo	info;
	XmFontList	fontList;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	if (strcmp(w->fontInfo.name,p.sym.sval) == 0) return TRUE;

	info.name = p.sym.sval;
	info.size = w->fontInfo.size;	
	info.weight = w->fontInfo.weight;
	info.slant = w->fontInfo.slant;
	if (font = getFont(&info,FALSE)) {
		n=0;
		XtSetArg(args[n], XmNfontList, fontList=XmFontListCreate(font, charset)); n++;
		XtSetValues(w->text,args,n);
		XmFontListFree(fontList);
		w->fontInfo.name = XtRealloc(w->fontInfo.name, strlen(p.sym.sval)+1);
		strcpy(w->fontInfo.name, p.sym.sval);
		w->font = font;
		res = TRUE;
	}
	return res;
}

BNRP_Boolean commonGetTextFace(tcb, fontInfo)
BNRP_TCB	*tcb;
FontInfo	*fontInfo;
{
	BNRP_term	result = BNRP_startList(tcb);

	if (fontInfo->weight == BOLD_WEIGHT)
		BNRP_addTerm(tcb, result, BNRP_makeSymbol(tcb, "bold"));
	if (fontInfo->slant == ITALIC_SLANT)
		BNRP_addTerm(tcb, result, BNRP_makeSymbol(tcb, "italic"));

	return BNRP_unify(tcb, tcb->args[2], result);
}

/* Prolog primitive gettextface(+W,-Face) */
BNRP_Boolean getTextFace(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	return commonGetTextFace(tcb,&w->fontInfo);
}

/* Prolog primitive settextface(+W,+Face) */
BNRP_Boolean setTextFace(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	BNRP_result	p;
	FontInfo	info;
	BNRP_term	curr_term;
	XFontStruct	*font;
	int			n;
	Arg			args[2];
	BNRP_tag	tag;
	XmFontList	fontList;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_list) return FALSE;
	
	info.weight = NORMAL_WEIGHT;
	info.slant = NORMAL_SLANT;
	curr_term = p.term.first;
	while ((tag = BNRP_getNextValue(&curr_term,&p)) != BNRP_end) {
		if (tag == BNRP_var) return TRUE;
		if (tag == BNRP_tailvar) return TRUE;
		if (tag != BNRP_symbol) return FALSE;
		if (strcmp(p.sym.sval,"bold") == 0)
			info.weight = BOLD_WEIGHT;
		else if (strcmp(p.sym.sval,"italic") == 0)
			info.slant = ITALIC_SLANT;
	}

	if ((info.weight != w->fontInfo.weight) || (info.slant != w->fontInfo.slant)) {
		info.name = w->fontInfo.name;
		info.size = w->fontInfo.size;
		if (font = getFont(&info,FALSE)) {
			n=0;
			XtSetArg(args[n], XmNfontList, fontList=XmFontListCreate(font, charset)); n++;
			XtSetValues(w->text,args,n);
			XmFontListFree(fontList);
			w->fontInfo.weight = info.weight;
			w->fontInfo.slant = info.slant;
			w->font = font;
			return TRUE;
		}
		return FALSE;
	}
	return TRUE;
}

char	*getFamily(font)
char	*font;
{
	char *start,*end,*family;
	int	len;

	start = strchr(font, '-');		/* first - (should be first character) */
	start = strchr(++start, '-');	/* second - (separates foundry and family) */
	end = strchr(++start, '-'); 	/* third - (end of family) */
	len = end-start;
	family = XtMalloc(len+1);
	memcpy(family, start, len);
	family[len] = '\0';
	for (start=family;*start;start++) 
		*start = tolower(*start);
	return family;
}

/* Prolog primitive listfonts(-FontList) */
BNRP_Boolean listFonts(tcb)
BNRP_TCB	*tcb;
{
#define MAX_FAMILIES	30 
	char	**fontNames;
	char	*fontFamilies[MAX_FAMILIES];
	char	*family;
	int		i,j,count,numFamilies=0;
	BNRP_term	result = BNRP_startList(tcb);
	Boolean	found;

	if (tcb->numargs != 1) return FALSE;

	fontNames = XListFonts(display, "-*-*-*-*-*-*-*-*-*-*-*-*-iso8859-*", 32767, &count);
	
	fontFamilies[numFamilies++] = XtNewString("systemfont");
	fontFamilies[numFamilies++] = XtNewString("applfont");
	for (i=0;i<count;i++) {
		family = getFamily(fontNames[i]);
		found = FALSE;
		for (j=0;j<numFamilies;j++) {
			if (strcmp(family, fontFamilies[j]) == 0) {
				found = TRUE;
				break;
			}
		}
		if (!found && (numFamilies < MAX_FAMILIES))
			fontFamilies[numFamilies++] = family;
		else
			XtFree(family);
	}

	for (i=0;i<numFamilies;i++) {
		BNRP_addTerm(tcb, result, BNRP_makeSymbol(tcb, fontFamilies[i]));
		XtFree(fontFamilies[i]);
	}
	XFreeFontNames(fontNames);

	return BNRP_unify(tcb,tcb->args[1],result);
}

int	getSize(font)
char	*font;
{
	char	*start,*end;
	int		size;

	/* size in pixels is 7th field in font name */
	start = strchr(font,'-');		/* foundry */
	start = strchr(++start,'-');	/* family */
	start = strchr(++start,'-');	/* weight */
	start = strchr(++start,'-');	/* slant */
	start = strchr(++start,'-');	/* set width */
	start = strchr(++start,'-');	/* ? */
	start = strchr(++start,'-');	/* pixels */
	end = strchr(++start,'-');
	*end = '\0';
	sscanf(start,"%d",&size);
	*end = '-';

	return size;
	
}
/* Prolog primitive listsizes(+Font,-Sizes) */
BNRP_Boolean listSizes(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	char	fontSpec[50];
	char	**fontNames;
	int		fontSizes[30];
	int		size;
	int		i,j,count,numSizes=0;
	BNRP_term	result = BNRP_startList(tcb);
	Boolean	found;
	char	*fontName;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1],&p) != BNRP_symbol) return FALSE;

	if (strcmp(p.sym.sval,"applfont") == 0)
		fontName = appl_font_info.name;
	else if (strcmp(p.sym.sval, "systemfont") == 0)
		fontName = sys_font_info.name;
	else
		fontName = p.sym.sval;
	sprintf(fontSpec,"-*-%s-*-*-*-*-*-*-*-*-*-*-iso8859-*",fontName);
	fontNames = XListFonts(display, fontSpec, 32767, &count);
	
	for (i=0;i<count;i++) {
		size = getSize(fontNames[i]);
		found = FALSE;
		for (j=0;j<numSizes;j++) {
			if (size == fontSizes[j]) {
				found = TRUE;
				break;
			}
		}
		if (!found) {
			fontSizes[numSizes++] = size;
		}
	}

	for (i=0;i<numSizes;i++) {
		BNRP_addTerm(tcb, result, BNRP_makeInteger(tcb, (long int)fontSizes[i]));
	}
	XFreeFontNames(fontNames);

	return BNRP_unify(tcb,tcb->args[2],result);
}

/* Prolog primitive $fontinfo(+Font, +Size, +Face, -Ascent, -Descent, -Leading, -MaxWidth, -AvgWidth) */
BNRP_Boolean fontInfo(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	Boolean	res;
	XFontStruct	*font;
	FontInfo	info;
	BNRP_term	list;
	BNRP_tag	tag;
	
	if (tcb->numargs != 8) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_symbol) return FALSE;
	info.name = p.sym.sval;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	info.size = p.ival;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_list) return FALSE;
	info.weight = NORMAL_WEIGHT;
	info.slant = NORMAL_SLANT;
	list = p.term.first;
	while ((tag = BNRP_getNextValue(&list,&p)) != BNRP_end) {
		if (tag != BNRP_symbol) return FALSE;
		if (strcmp(p.sym.sval,"bold") == 0)
			info.weight = BOLD_WEIGHT;
		else if (strcmp(p.sym.sval,"italic") == 0)
			info.slant = ITALIC_SLANT;
	}

	

	if (font = getFont(&info,TRUE)) {
		/* REMOVED MAr. 95 long int avgcharwidth = 0; */
		unsigned long avgcharwidth = 0; /* NEW */
		if ((!XGetFontProperty(font, XA_QUAD_WIDTH, &avgcharwidth)) ||
			(avgcharwidth == 0)) {
			if (font->per_char && font->min_char_or_byte2 <= '0' &&
								  font->max_char_or_byte2 >= '0')
				avgcharwidth = font->per_char['0' - font->min_char_or_byte2].width;
			else
				avgcharwidth = font->max_bounds.width;
		}
		if (avgcharwidth <= 0) avgcharwidth = 1;
		res =  BNRP_unify(tcb, tcb->args[4], BNRP_makeInteger(tcb, (long int)font->ascent))
			&& BNRP_unify(tcb, tcb->args[5], BNRP_makeInteger(tcb, (long int)font->descent))
			&& BNRP_unify(tcb, tcb->args[6], BNRP_makeInteger(tcb, 1L))
			&& BNRP_unify(tcb, tcb->args[7], BNRP_makeInteger(tcb, (long int)font->max_bounds.width))
			&& BNRP_unify(tcb, tcb->args[8], BNRP_makeInteger(tcb, avgcharwidth));
		if (!cachedFont(font)) XFreeFont(display,font);
		return res;
	}
	else return FALSE;
}

int eqStrN(s1,s2,n)
char *s1,*s2;
int  n; /* length of s2 (s2 may not be null terminated) */
{
	if (n == 0) return TRUE;
	for (n--;tolower(*s1)==tolower(*s2);s1++,s2++,n--)
		if (n == 0) return TRUE;
	return FALSE;
}
			
#ifdef _NO_PROTO
BNRP_Boolean handleWindowIO(va_alist)
va_dcl
{
	short selector;
	PTextWindow *w;
#else
BNRP_Boolean handleWindowIO(short selector, PTextWindow *w, ...)
{
#endif
	va_list	ap;
	BNRP_Boolean	res = TRUE;
	char 	*c, *text;
	long	l, *p;
	short	*err;
	char	*buff;
	XmTextPosition	start,end,last;
	Arg		args[1];
extern long BNRP_printLen, BNRP_printCount;
extern jmp_buf	BNRP_printEnv;
    int     len;
    char    buffOnStack[MAX_STRING_SIZE + 64];
#define TOOLONG	-200

#ifdef SYSV
	va_start(ap, w);
#else
	va_start(ap);
	selector = va_arg(ap, short);
	w = va_arg(ap, PTextWindow *);
#endif

	switch (selector) {
		case OUTPUTSTRING:	/* (char *format, ...) */
		{
			char *outstring;
			int string = va_arg(ap, int); /* NEW 28/04/95 Is outstring a string? */
			c = va_arg(ap, char *);
			if(string) /* NEW 28/04/95 strlen() blows up if arg is not a string */
			{
				outstring = va_arg(ap, char *);
                len = strlen(c) + strlen(outstring) + 1;
                if (len <= sizeof(buffOnStack))
                    buff = buffOnStack;
                else
                    buff = XtMalloc(len);
				sprintf(buff, c, outstring);
			}
			else
			{ /* Presuming that outstring is not a string,
                 MAX_STRING_SIZE should be adequate room */
                len = strlen(c) + MAX_STRING_SIZE;
                if (len <= sizeof(buffOnStack))
                    buff = buffOnStack;
                else
                    buff = XtMalloc(len);
				vsprintf(buff,c,ap);
			}


#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(OUTPUTSTRING, %s)\n",buff);
#endif
			l = strlen(buff);
			BNRP_printCount += l;
			if (BNRP_printCount > BNRP_printLen) {
				if (buff != buffOnStack) XtFree(buff);
				longjmp(BNRP_printEnv, TOOLONG);
			}
			TextGetSelectionPosition(w,&start,&end);
			TextInsert(w,start,buff);
            end = start + l;
            TextSetSelection(w, end, end);
            /*
             * Show the cursor position ONLY IF one or more new
             * lines have just been sent to output
             */
            while (--l >= 0) {
                if (buff[l] == '\n') {
                    XmTextShowPosition(w->text,end);
                    break;
                }
            }
			w->err = 0;
			if (buff != buffOnStack) XtFree(buff);
			break;
		}

		case READCHAR:		/* (char *result) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(READCHAR)\n");
#endif
			TextGetSelectionPosition(w,&start,&end);
			last = XmTextGetLastPosition(w->text);
			c = va_arg(ap, char *);
			if (start < last) {
				if (w->contents == NULL) {
					XtSetArg(args[0], XmNvalue, &(w->contents));
					XtGetValues(w->text, args, 1);
				}
				*c = w->contents[start];
				TextSetInsertionPosition(w,start+1);
                XmTextShowPosition(w->text,start+1);
				w->err = 0;
			}
			else {
				*c = EOF;
				w->err = -39;
				res = FALSE;
			}
			break;
		case RETURNCHAR:	/* (char *character) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(RETURNCHAR)\n");
#endif
			TextGetSelectionPosition(w,&start,&end);
			if (start > 0) {
				c = va_arg(ap, char *);
				if (w->contents == NULL) {
					XtSetArg(args[0], XmNvalue, &(w->contents));
					XtGetValues(w->text, args, 1);
				}
				if (w->contents[--start] != *c) {
					w->contents[start] = *c;
					XtSetArg(args[0], XmNvalue, w->contents);
					XtSetValues(w->text, args, 1);
				}
				TextSetInsertionPosition(w,start);
                XmTextShowPosition(w->text,start);
			    w->err = 0;
			}
			else {
				res = FALSE;
				w->err = -39;
			}
			break;
		case OPENFILE:		/* (char *name, char *mode, long *index) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(OPENFILE)\n");
#endif
			res = FALSE;
			break;
		case CLOSEFILE:		/* () */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(CLOSEFILE)\n");
#endif
			res = FALSE;
			break;
		case GETPOSITION:	/* (long *position) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(GETPOSITION)\n");
#endif
			TextGetSelectionPosition(w,&start,&end);
			last = XmTextGetLastPosition(w->text);
			p = va_arg(ap, long *);
			if (start == last)
				*p = -1;
			else
				*p = start;
			w->err = 0;
			break;
		case SETPOSITION:	/* (long newposition) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(SETPOSITION)\n");
#endif
			w->err = 0;
			l = va_arg(ap, long);
			last = XmTextGetLastPosition(w->text);
			if (l >= 0 && l <= last)
				TextSetInsertionPosition(w,l);
			else if (l == -1)
				TextSetInsertionPosition(w,XmTextGetLastPosition(w->text));
			else {
				res = FALSE;
				w->err = -39;
			}
			break;
		case SETEOF:		/* () */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(SETEOF)\n");
#endif
			TextGetSelectionPosition(w,&start,&end);
			if (w->contents == NULL) {
				XtSetArg(args[0], XmNvalue, &(w->contents));
				XtGetValues(w->text, args, 1);
			}
			w->contents[start] = '\0';
			XtSetArg(args[0], XmNvalue, w->contents);
			XtSetValues(w->text, args, 1);
			w->err = 0;
			break;
		case FLUSHFILE:		/* () */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(FLUSHFILE)\n");
#endif
			break;
		case GETERROR:		/* (short *error) */
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(GETERROR)\n");
#endif
			err = va_arg(ap, short *);
			*err = w->err;
			break;
		default:
#ifdef xDEBUG
			if (DebugTrace)
				printf("windowIO(??? UNKNOWN %d ???)\n",selector);
#endif
			res = FALSE;
			break;
	}
	va_end(ap);
	return res;
}

BNRP_Boolean window_io_proc(tcb)
BNRP_TCB	*tcb;
{
#ifdef xDEBUG
	if (DebugTrace)
		printf("window_io_proc\n");
#endif
	if (tcb->numargs != 1) return FALSE;
	return BNRP_unify(tcb, tcb->args[1], BNRP_makeInteger(tcb, (long int) handleWindowIO));
}


/* FindValidWidgetId - returns a valid widget id for the application */

Widget FindValidWidgetId()

{
	Widget				valid_widget = NULL;
	PAnyWindow			*w;
	XWindowAttributes	window_attr;
	Window				wind;

	/* search the window table for a valid widget id */
	for (w = (PAnyWindow *)windowtab; w != NULL; w = w->next_window) {
		if ((w->type != unused) &&
			((valid_widget = (w->app_shell)) != (Widget) NULL) &&
			((wind=XtWindow(w->app_shell)) != (Window) NULL) &&
			(XGetWindowAttributes(display,wind,&window_attr) != 0) &&
			(window_attr.map_state == IsViewable))
			return valid_widget;
	}
	return NULL;
}


/* FindValidWindowId - returns a valid window id for the application */

Window FindValidWindowId()

{	Widget	valid_widget;

	if ((valid_widget = FindValidWidgetId()) != (Widget) NULL) 
		return XtWindow(valid_widget);
	else
		return (Window) NULL;
}


/* Prolog primitive $texttoscrap(+symbol) - copies the symbol to the clipboard */

BNRP_Boolean textToScrap(tcb)
BNRP_TCB        *tcb;
{
        BNRP_result     p;
        long            item_id;
        Window          valid_window_id;
	Boolean		res;
	XmString	s;
	int		i;
	int		status;

#ifdef DEBUG
	if (DebugTrace) printf("In texttoscrap\n");
#endif

        if (tcb->numargs != 1) return FALSE;
        if (BNRP_getValue(tcb->args[1], &p) != BNRP_symbol) return FALSE;

        /* search for a valid window id for the clipboard functions */
        if ((valid_window_id = FindValidWindowId()) == (Window)NULL) return FALSE;

        s=XmStringCreateLtoR("BNR Prolog",charset);
	for (i=0; (i<MAX_CLIPBOARD_TRIES) &&
        	((status = XmClipboardStartCopy(display,valid_window_id,
                                s, XtLastTimestampProcessed(display),
                                NULL,NULL,&item_id)) != ClipboardSuccess); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardStartCopy : %d tries.\n",i);
#endif
	/* REMOVED Mar. 95 XtFree(s); */
	XtFree((char *)s);	/* NEW */
        if (status != ClipboardSuccess)
        	return FALSE;

        for (i=0; (i<MAX_CLIPBOARD_TRIES) && 
		((status = XmClipboardCopy(display,valid_window_id,item_id,
			"STRING",p.sym.sval,strlen(p.sym.sval),(int)NULL,NULL)) 
			!= ClipboardSuccess); i++); 
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardCopy : %d tries.\n",i);
#endif
	if (status != ClipboardSuccess) {
		XmClipboardCancelCopy(display,valid_window_id,item_id);
                return FALSE;
		}

	for (i=0; (i<MAX_CLIPBOARD_TRIES) && 
		((status = XmClipboardEndCopy(display,valid_window_id,item_id))
			 != ClipboardSuccess); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardEndCopy : %d tries.\n",i);
#endif

	return (status == ClipboardSuccess); 
}


/* Prolog primitive $scraptotext(?string) - unifies string with the symbol in the scrap */

BNRP_Boolean scrapToText(tcb)
BNRP_TCB        *tcb;

{
        Window          valid_window_id;
        int             status;
        unsigned long   length,num;
        /* REMOVED Mar. 95 int          private_id */
        long             private_id;    /* NEW */
        char            *buffer;
        BNRP_Boolean    result;
	int 		i;

#ifdef DEBUG
        if (DebugTrace) printf("In scraptotext.\n");
#endif

        if (tcb->numargs != 1) return FALSE;

        /* search for a valid window id for the clipboard functions */
        if ((valid_window_id = FindValidWindowId()) == (Window) NULL) return FALSE;

        for (i=0; (i<MAX_CLIPBOARD_TRIES) && (XmClipboardStartRetrieve(display,valid_window_id,
                XtLastTimestampProcessed(display)) != ClipboardSuccess); i++) ;
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardStartRetrieve : %d tries.\n",i);
#endif
        if (i >= MAX_CLIPBOARD_TRIES)
        	return FALSE;

        for (i=0; (i<MAX_CLIPBOARD_TRIES) && ((status = XmClipboardInquireLength(display,valid_window_id,
                "STRING",&length)) != ClipboardSuccess) && (status != ClipboardNoData); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardInquireLength : %d tries.\n",i);
#endif

        if (status != ClipboardSuccess || length == 0) {
#ifdef DEBUG
                if (DebugTrace)
                        printf("ClipboardInquireLength failed: status %d, length %d.\n",status,length);
#endif
                XmClipboardEndRetrieve(display,valid_window_id);
                return FALSE;
                }

        buffer = (char *)XtMalloc(length+1);
        for (i=0; (i<MAX_CLIPBOARD_TRIES) && ((status = XmClipboardRetrieve(display,valid_window_id ,
                "STRING",buffer,length,&num,&private_id)) != ClipboardSuccess); i++) ;
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardRetrieve : %d tries.\n",i);
#endif
        if (status != ClipboardSuccess) {
#ifdef DEBUG
                if (DebugTrace)
                        printf("ClipboardRetrieve failed: status %d, num_bytes %d.\n",status,num);
#endif
                XmClipboardEndRetrieve(display,valid_window_id);
                XtFree(buffer);
                return FALSE;
                }
        buffer[length] = '\0';

        XmClipboardEndRetrieve(display,valid_window_id);
        result = BNRP_unify(tcb,tcb->args[1],BNRP_makeSymbol(tcb,buffer));

        XtFree(buffer);
        return result;
}



/* Prolog primitive $scrapcontents(?symbol) - unifies symbol with the type of data in the scrap */

BNRP_Boolean scrapContents(tcb)
BNRP_TCB        *tcb;

{
        Window          valid_window_id;
        int             status;
        unsigned long   length;
        BNRP_Boolean    result;
	int		i;

#ifdef DEBUG
	if (DebugTrace) printf("In Scrapcontents\n");
#endif

        if (tcb->numargs != 1) return FALSE;

        /* search for a valid window id for the clipboard functions */
        if ((valid_window_id = FindValidWindowId()) == (Window) NULL) return FALSE;

	/* Check for TEXT data in scrap */
        for (i=0; (i<MAX_CLIPBOARD_TRIES) && ((status = XmClipboardInquireLength(display,valid_window_id,
                "STRING",&length)) != ClipboardSuccess) && (status != ClipboardNoData) ; i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("Scrapcontents: ClipboardInquireLength : %d tries, status %d.\n",i,status);
#endif
        if ((status == ClipboardSuccess) && (length != 0))
                return BNRP_unify(tcb,tcb->args[1],BNRP_makeSymbol(tcb,"TEXT"));

        /* Check for PICT data */
        for (i=0; (i<MAX_CLIPBOARD_TRIES) && ((status = XmClipboardInquireLength(display,valid_window_id,
                "BNRP_PICT",&length)) != ClipboardSuccess) && (status != ClipboardNoData); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardInquireLength : %d tries, status %d.\n",i,status);
#endif
        if ((status == ClipboardSuccess) && (length != 0))
                return BNRP_unify(tcb,tcb->args[1],BNRP_makeSymbol(tcb,"PICT"));

        return FALSE;
}


/* Prolog primitive $picttoscrap(+PipeID) - write the picture specified in PipeID to the scrap */

BNRP_Boolean pictToScrap(tcb)
BNRP_TCB        *tcb;

{
        Window          valid_window_id;
        int             status;
        unsigned long   length;
        BNRP_result     p;
        char            *s;
	BNRP_term       list;
	ioProc          proc;
        long            fileP;
	long		item_id;
	XmString	str;
	int		i;

#ifdef DEBUG
	if (DebugTrace) printf("In $picttoscrap\n");
#endif

        if (tcb->numargs != 1) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_list) 
		return FALSE;
	list = p.term.first;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
       	fileP = (long) p.ival;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
        proc = (ioProc) p.ival;

        /* search for a valid window id for the clipboard functions */
        if ((valid_window_id = FindValidWindowId()) == (Window) NULL) return FALSE;

	/* Try only once to register the format in case didn't work at init time*/
	XmClipboardRegisterFormat(display,"BNRP_PICT",8);

	/* Copy the picture to the clipboard */
        str=XmStringCreateLtoR("BNR Prolog",charset);
	for (i=0; (i<MAX_CLIPBOARD_TRIES) && 
		((status = XmClipboardStartCopy(display,valid_window_id,
                                str, XtLastTimestampProcessed(display),
                                NULL,NULL,&item_id)) != ClipboardSuccess); i++);
        /* REMOVED Mar. 95 XtFree(str); */
        XtFree((char *)str);    /* NEW */
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardStartCopy : %d tries.\n",i);
#endif
	if (status != ClipboardSuccess) return FALSE;

        s = contentsOfPipe(proc,fileP);
	for (i=0; (i<MAX_CLIPBOARD_TRIES) &&
		((status = XmClipboardCopy(display,valid_window_id,item_id,"BNRP_PICT",s,
                                strlen(s),(int)NULL,NULL)) != ClipboardSuccess); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardCopy : %d tries.\n",i);
#endif

        if (status == ClipboardSuccess) {
		for (i=0; (i<MAX_CLIPBOARD_TRIES) &&
			((status = XmClipboardEndCopy(display,valid_window_id,item_id))
			 != ClipboardSuccess); i++);
#ifdef DEBUG
		if (DebugTrace) printf("ClipboardEndCopy : %d tries.\n",i);
#endif
		}
	else
		XmClipboardCancelCopy(display,valid_window_id,item_id);

	XtFree(s);
        return (status == ClipboardSuccess);
}


/* Prolog primitive $scraptopict(-PictureID) - loads a picture from the clipboard and assigns it ID PictureID */

BNRP_Boolean scrapToPict(tcb)
BNRP_TCB        *tcb;

{
        Window          valid_window_id;
        int             status;
        BNRP_result     p;
        char            *buffer;
	BNRP_term       list;
	ioProc          proc;
        long            fileP;
        unsigned long   length,num;
	/* REMOVED Mar. 95 int             private_id; */
        long            private_id;  /* NEW */
	int		i;

#ifdef DEBUG
	if (DebugTrace) printf("In $scraptopict\n");
#endif

        if (tcb->numargs != 1) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_list) 
		return FALSE;
	list = p.term.first;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
       	fileP = (long) p.ival;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
        proc = (ioProc) p.ival;

        /* search for a valid window id for the clipboard functions */
        if ((valid_window_id = FindValidWindowId()) == (Window)NULL) return FALSE;

	/* Check for BNRP_PICT data in scrap and retrieve it */
        for (i=0; (i<MAX_CLIPBOARD_TRIES) && 
		(XmClipboardStartRetrieve(display,valid_window_id,
			XtLastTimestampProcessed(display)) != ClipboardSuccess); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardStartRetrieve : %d tries.\n",i);
#endif
        if (i >= MAX_CLIPBOARD_TRIES) return FALSE;

        for (i=0; (i<MAX_CLIPBOARD_TRIES) && 
		((status = XmClipboardInquireLength(display,valid_window_id,
                	"BNRP_PICT",&length)) != ClipboardSuccess) && 
		(status != ClipboardNoData); i++);
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardInquireLength : %d tries.\n",i);
#endif

        if (status != ClipboardSuccess || length == 0) {
#ifdef DEBUG
                if (DebugTrace)
                        printf("ClipboardInquireLength failed: status %d, length %d.\n",status,length);
#endif
        	XmClipboardEndRetrieve(display,valid_window_id);
                return FALSE;
		}

        buffer = (char *)XtMalloc(length+1);
        for (i=0; (i<MAX_CLIPBOARD_TRIES) &&
		 ((status = XmClipboardRetrieve(display,valid_window_id,"BNRP_PICT",buffer,length,
                                &num,&private_id)) != ClipboardSuccess); i++); 
#ifdef DEBUG
        if (DebugTrace)
                printf("ClipboardRetrieve : %d tries.\n",i);
#endif

        XmClipboardEndRetrieve(display,valid_window_id);

	if (status != ClipboardSuccess) {
                XtFree(buffer);
                return FALSE;
                }

	/* Place data in pipe */
        buffer[length] = '\0';
	/* REMOVED Apr. 95 (void) (*proc)(OUTPUTSTRING, fileP, buffer); */
	(void) (*proc)(OUTPUTSTRING, fileP, STRING,buffer,"");  /* NEW */
	XtFree(buffer);
        return TRUE;
}

/* $charat(+Window, +X, +Y, -Pos) */
BNRP_Boolean charAt(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	Position	x,y;
	BNRP_result     p;

	if (tcb->numargs != 4) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;
	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	x = (Position) p.ival;
	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	y = (Position) p.ival;

	return BNRP_unify(tcb, tcb->args[4], BNRP_makeInteger(tcb,(long int)XmTextXYToPos(w->text, x, y)));
}

/* $getchar(+Window, +Pos, -Char) */
BNRP_Boolean getCharAt(tcb)
BNRP_TCB	*tcb;
{
	PTextWindow	*w;
	XmTextPosition	pos;
	BNRP_result     p;
	Arg	args[1];
	char	s[2];
	XmTextPosition  textLen;

	if (tcb->numargs != 3) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PTextWindow *) p.ival;
	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	pos = (XmTextPosition) p.ival;
	textLen = XmTextGetLastPosition(w->text);
	if (pos < 0) pos = 0;
	if (pos > textLen) pos = textLen;
	if (w->contents == NULL) {
		XtSetArg(args[0], XmNvalue, &(w->contents));
		XtGetValues(w->text, args, 1);
	}
	
	s[0] = w->contents[pos];
	s[1] = '\0';

	return BNRP_unify(tcb, tcb->args[3], BNRP_makeSymbol(tcb,s));
}

void BindPTextPrimitives()
{
	int	i;

	BNRPBindPrimitive("$getselection", getSelection);
	BNRPBindPrimitive("$getselectcabs", getSelectCAbs);
	BNRPBindPrimitive("$getselectlabs", getSelectLAbs);
	BNRPBindPrimitive("$getscandirection", getScanDirection);
	BNRPBindPrimitive("$getcasesense", getCaseSense);
	BNRPBindPrimitive("$getcsize", getCsize);
	BNRPBindPrimitive("$getlsize", getLsize);
	BNRPBindPrimitive("$gettextfont", getTextFont);
	BNRPBindPrimitive("$gettextsize", getTextSize);
	BNRPBindPrimitive("$gettextface", getTextFace);
	BNRPBindPrimitive("$gettextwidth", getTextWidth);
	BNRPBindPrimitive("$setselection", setSelection);
	BNRPBindPrimitive("$setselectcabs", setSelectCAbs);
	BNRPBindPrimitive("$setcursorposition", setCursorPosition);
	BNRPBindPrimitive("$setselectlabs", setSelectLAbs);
	BNRPBindPrimitive("$setselectcrel", setSelectCRel);
	BNRPBindPrimitive("$setselectlrel", setSelectLRel);
	BNRPBindPrimitive("$setscandirection", setScanDirection);
	BNRPBindPrimitive("$setcasesense", setCaseSense);
	BNRPBindPrimitive("$settextfont", setTextFont);
	BNRPBindPrimitive("$settextsize", setTextSize);
	BNRPBindPrimitive("$settextface", setTextFace);
	BNRPBindPrimitive("$doeditaction",  doEditAction);
	BNRPBindPrimitive("$doreplace", doReplace);
	BNRPBindPrimitive("$doinsert", doInsert);
	BNRPBindPrimitive("$window_io_proc", window_io_proc);
	BNRPBindPrimitive("$listfonts", listFonts);
	BNRPBindPrimitive("$listsizes", listSizes);
	BNRPBindPrimitive("$fontinfo", fontInfo);
	BNRPBindPrimitive("texttoscrap",textToScrap);
	BNRPBindPrimitive("scraptotext",scrapToText);
	BNRPBindPrimitive("scrapcontents",scrapContents);
	BNRPBindPrimitive("$picttoscrap",pictToScrap);
	BNRPBindPrimitive("$scraptopict",scrapToPict);
	BNRPBindPrimitive("$charat",charAt);
	BNRPBindPrimitive("$getchar",getCharAt);

	XA_CLIPBOARD = XmInternAtom(display,"CLIPBOARD",FALSE);
	XA_TIMESTAMP = XmInternAtom(display,"TIMESTAMP",FALSE);
	
	/* Register the picture format for the clipboard. Try many times, to ensure clipboard
	   not busy.  */
	for (i=0; (i<MAX_CLIPBOARD_TRIES) &&
	          (XmClipboardRegisterFormat(display,"BNRP_PICT",8) != ClipboardSuccess); i++);

}

XmTextPosition SearchString(text, start, len, find, findLen, caseSense)
char *text;
XmTextPosition  start,len; 
char *find;
int  findLen;
Boolean  caseSense;
{
	/* uses BoyerStrother search algorithm */
	char	*pos;
	XmTextPosition	i,j;
	unsigned char	c,c1;
	XmTextPosition	lookup[256];

	for (i=0;i<256;i++)
		lookup[i] = findLen;

	if (len >= 0) {	/* Forward searching */
		for (i=0;i<findLen-1;i++) {
			if (caseSense)
				j = find[i];
			else {
				j = tolower(find[i]);
				find[i] = (char) j;
			}
			lookup[j] = findLen-i-1;
		}
		if (!caseSense)
			find[findLen-1] = tolower(find[findLen-1]);
		i = findLen - 1;
		while (i<len) {
			pos = text + start + i;
			if (caseSense)
				c = *pos;
			else
				c = tolower(*pos);
			if (c == find[findLen-1]) {
				for (j=1;j<findLen;j++) {
					pos = text + start + i - j;
					if (caseSense)
						c1 = *pos;
					else
						c1 = tolower(*pos);
					if (c1 != find[findLen-j-1])
						j = findLen;
				}
				if (j == findLen) {
					return (start + i - findLen + 1);
				}
			}
			/* not what we're looking for, move on */
			i += lookup[c];
		}
		return (start + len + 1); /* not found */
	}
	else { /* backward search */
		for (i=1;i<findLen;i++) {
			if (caseSense)
				j = find[i];
			else {
				j = tolower(find[i]);
				find[i] = j;
			}
			if (lookup[j] == findLen)
				lookup[j] = i;
		}
		if (!caseSense)
			find[0] = tolower(find[0]);
		i = -findLen;
		while (i > len) {
			pos = text + start + i;
			if (caseSense)
				c = *pos;
			else
				c = tolower(*pos);
			if (c == find[0]) {
				for (j=1;j<findLen;j++) {
					pos = text + start + i + j;
					if (caseSense)
						c1 = *pos;
					else
						c1 = tolower(*pos);
					if (c1 != find[j])
						j = findLen;
				}
				if (j == findLen) {
					return start + i;
				}
			}
			/* not what we're looking for, move on */
			i -= lookup[c];
		}
		return start + len - 1;
	}
}

        
/* ScrapContentsCB - Callback which returns the current scrap contents for the TIMESTAMP
   atom. When this changes, a Prolog scrapchanged event is generated. */

void ScrapContentsCB (w,data,selection,type,value,length,format)
	Widget 		w;
	XtPointer	data;
	Atom		*selection;
	Atom		*type;
	Time		*value;
	unsigned long	*length;
	int		*format;
{
#ifdef DEBUG
	if (DebugTrace) {
		if ((*type == XA_TIMESTAMP) && (*value != LastScrapChangedTime))
			printf
			("In ScrapContentsCB: data %d,selection %s,type %s,value %d,length %d,format %d.\n",
			data,XGetAtomName(display,*selection),*type==0 ? 0:XGetAtomName(display,*type),
			value==NULL ? 0:*value,*length,*format);
		}
#endif
	if ((*type == XA_TIMESTAMP) && (*value != LastScrapChangedTime)) {
		/* return Prolog scrap changed event */
		PScrapChangedEvent *se = (PScrapChangedEvent *) PrologEvent;
#ifdef DEBUG
		if (DebugTrace) printf("Scrapchanged event\n");
#endif
		se->type = scrapchanged;
		/* remember the time scrap changed */
		LastScrapChangedTime = *value;
		}

	ScrapReqOutstanding = FALSE;
	XtFree((char *)value);
}


/* PollScrapContents - Retrieve the current scrap contents to see if it has
   changed. Only one request may be outstanding at a time to prevent congestion. */ 

void PollScrapContents()

{	Widget		w;

	if (!ScrapReqOutstanding) {
		if ((w = FindValidWidgetId()) != NULL) {
			/* REMOVED Mar. 95 XtGetSelectionValue(w,XA_CLIPBOARD,
                                XA_TIMESTAMP,ScrapContentsCB,NULL,
                                XtLastTimestampProcessed(display)); */
      /* NEW */         XtGetSelectionValue(w,XA_CLIPBOARD,XA_TIMESTAMP,
                                (XtSelectionCallbackProc)ScrapContentsCB,NULL,
                                XtLastTimestampProcessed(display));
			ScrapReqOutstanding = TRUE;
			}
		}

}


