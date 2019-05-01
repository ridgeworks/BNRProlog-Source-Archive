/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProWindows.h,v 1.1 1995/09/22 11:27:33 harrisja Exp $
*
*  $Log: ProWindows.h,v $
 * Revision 1.1  1995/09/22  11:27:33  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_ProWindows
#define _H_ProWindows

#include	"ProMenus.h"
#include	"ProText.h"


/* Window information */

enum PrologWindowType {unused,ptext,pgraf};

typedef struct  _pany   /* any window */
   { enum PrologWindowType       type;
     struct _pany   *next_window;
     Widget    app_shell;
     char      *windowname;
     Dimension width,height;
     Position  leftedge,topedge;
     int  		offsetX,offsetY;
     MenuBarPtr	menu_bar;
     Boolean   invalidrect;
   } PAnyWindow;

typedef struct    /* ptext */
   { enum PrologWindowType     type;
     struct _pany   *next_window;
     Widget  app_shell;     /* 0 is app_shell, 1..n are popups */
     char    *windowname;   /* window name */
     Dimension width,height;
     Position leftedge,topedge;
     int  		offsetX,offsetY;
     MenuBarPtr	menu_bar;
     Boolean   invalidrect;
     Widget  main_window;
     Widget  text;
     Boolean file_saved;     /* file is saved? */
     char    *filename;      /* string containing file name */
     Boolean read_write;
     Boolean caseSense;
     Boolean scanForward;
     XmTextPosition selStart,selEnd;
	 short	 err;
	 XFontStruct	*font;
	 FontInfo	fontInfo;
	 char		*contents;	/* cache of contents of window */
   } PTextWindow;

typedef struct _pgraf
   { enum PrologWindowType      type;
     struct _pany   *next_window;
     Widget   app_shell;     /* popup shell */
     char     *windowname;   /* window name */
     Dimension width,height;
     Position leftedge,topedge;
     int  		offsetX,offsetY;
     MenuBarPtr	menu_bar;
     Boolean   invalidrect;
     Widget   main_window;
     Widget   canvas;        /* drawing area */
     Boolean  first_expose;  /* TRUE if waiting for first expose event */
     struct _grafStruct *graf;
   } PGrafWindow;

typedef union _PWindow
   {enum PrologWindowType         type;
    PAnyWindow  anywindow;
    PTextWindow textwindow;
    PGrafWindow grafwindow;
   } PWindow;

#define CANVASHEIGHT 500
#define CANVASWIDTH  500

extern PWindow  *windowtab;       /* array of open window definitions */

extern PWindow  *focus_window;    /* pointer to focus window in windowtab */

extern PTextWindow *CreateApplication ();
extern PTextWindow *CreateApplicationWindow();
extern PGrafWindow *CreateGrafWindow();

extern int defaultWidth,defaultHeight;

extern BNRP_Boolean openwindow();
extern void BindPWindowPrimitives();
extern PWindow *AllocWindowTab();

#endif
