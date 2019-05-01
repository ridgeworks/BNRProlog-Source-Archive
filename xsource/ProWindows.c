/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProWindows.c,v 1.7 1998/01/20 16:46:19 thawker Exp $
*
*  $Log: ProWindows.c,v $
 * Revision 1.7  1998/01/20  16:46:19  thawker
 * Cast NULL to an int each time it is compared to an int, to remove
 * warnings this caused on solaris
 *
 * Revision 1.6  1997/02/28  09:26:30  harrisj
 * renamewindow() was only updating the XmNtitle resource when it should have been
 * updating XmNiconName as well.
 *
 * Revision 1.5  1996/02/12  08:03:39  yanzhou
 * Minor changes to text windows:
 *   1) XmNautoShowCursorPosition is once again set to FALSE
 *   2) in handleWindowIO, XmTextShowPosition is called to force the cursor
 *      to be visible
 *   3) handleWindowIO now uses an on-stack local buffer if it is large
 *      enough to hold an output string.  Was calling XtMalloc().
 *
 * Revision 1.4  1996/01/03  14:15:06  yanzhou
 * XmNautoShowCursorPosition is now reverted to TRUE for text (editor) widgets.
 *
 * Revision 1.3  1995/10/20  12:10:28  yanzhou
 * Modified:
 *   To terminate the editbabs eventLoop() correctly.
 *
 * Revision 1.2  1995/10/06  16:38:48  harrisja
 * *** empty log message ***
 *
 * Revision 1.1  1995/09/22  11:27:05  harrisja
 * Initial version.
 *
*
*/

/* include files */

#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#else
#include <strings.h>
#endif

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/keysym.h>
#include <X11/Shell.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/cursorfont.h>

#include <Xm/Xm.h>
#include <Xm/Protocols.h>
#include <Xm/AtomMgr.h>
#include <Xm/CascadeB.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/MainW.h>
#include <Xm/BulletinB.h>
#include <Xm/MwmUtil.h>
#include <Xm/RowColumn.h>
#include <Xm/Text.h>
#include <Xm/DialogS.h>
#include <Xm/FileSB.h>
#include <Xm/MessageB.h>
#include <Xm/Label.h>
#include <Xm/SelectioB.h>
#include <Xm/CutPaste.h>
#include <Xm/DrawingA.h>

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProMenus.h"
#include "ProText.h"
#include "ProWindows.h"
#include "ProGraf.h"
#include "ProEvents.h"
#include "Prolog.h"

#include "icon.h"

#define  INCRNUMWINDOWS  10        /* increment on number of windows */
PWindow  *windowtab;               /* array of open window definitions */

PWindow  *focus_window = NULL;    /* pointer to focus window in windowtab */

int	defaultHeight,defaultWidth;
enum WindowDefnType {documentproc,dboxproc,plaindbox,altdboxproc,namedboxproc,nogrowdocproc,
                     rdocproc,zoomdocproc,zoomnogrow};

void SelectionChangeCB();
void FocusChangeCB();
void CloseWindowCB();
void ExposeCB();
void ButtonChangeCB();
void FileChangedCB();
void StructureNotifyCB();
void ButtonActionCB();

/*-------------------------------------------------------------
**      CloseAnyWindow
**              Close the specified window. 
*/
void CloseAnyWindow(window)
      PAnyWindow *window;

{
    /* Destroy the window. Note the file has already been saved, if required. */

    String geometry;
    Arg args[1];
    int n = 0;
    
    XtSetArg(args[n],XmNgeometry,&geometry); n++;
    XtGetValues(window->app_shell,args,n);
    XtFree(geometry);

    if (window->type == ptext)
      { /* free the file name */
        if (((PTextWindow *)window)->filename != NULL) 
           { XtFree(((PTextWindow *) window)->filename);
             ((PTextWindow *) window)->filename = NULL;
           }
	XtFree(((PTextWindow *)window)->fontInfo.name); /* JH */
       }
    else /* graf window */
       { /* free the graf data structures */
         TerminateGrafWindow((PGrafWindow *)window);
       }

	XtFree(window->windowname);
	XtPopdown(window->app_shell);
	XtDestroyWidget(window->app_shell);

    /* Mark windowtab entry as free */
    window->type = unused;
    if(window->menu_bar)	/* New 24/05/95 */
    {
    	XtFree((char *)window->menu_bar);
	window->menu_bar = NULL;	/* New 24/05/95 */
    }
}


/* CreateText - creates the text widget for the editor */

Widget CreateText (w,VScroll,HScroll)
   PTextWindow		*w;
   Boolean              VScroll;
   Boolean              HScroll;

{  Arg      args[11];	/* Changed 06/95 was: args[10] */
   register int n;	
   Widget   text;
   XmFontList	fontList;

   /* Create the text area */
   n = 0;
   XtSetArg(args[n],XmNrows,24); n++;
   XtSetArg(args[n],XmNcolumns,80); n++;
   XtSetArg(args[n],XmNresizeWidth,FALSE); n++;
   XtSetArg(args[n],XmNresizeHeight,FALSE); n++;
   XtSetArg(args[n],XmNscrollVertical,VScroll); n++;
   XtSetArg(args[n],XmNscrollHorizontal,HScroll); n++;
   XtSetArg(args[n],XmNeditMode,XmMULTI_LINE_EDIT); n++;
   XtSetArg(args[n],XmNverifyBell,FALSE); n++;
   XtSetArg(args[n],XmNfontList,fontList=XmFontListCreate(sys_font,charset)); n++;
   XtSetArg(args[n],XmNautoShowCursorPosition, FALSE); n++;
   text = XmCreateScrolledText(w->main_window,"text",args,n);
   XmFontListFree(fontList);

   /* Add value changed callback */
   XtAddCallback(text,XmNmodifyVerifyCallback,FileChangedCB,(void *) w);
   XtAddCallback(text,XmNgainPrimaryCallback,SelectionChangeCB,(void *) w);
   XtAddCallback(text,XmNlosePrimaryCallback,SelectionChangeCB,(void *) w);

   /* Register for key and button press events */
   XtAddEventHandler(text,KeyPressMask,FALSE,KeyPressCB,(void *) w);
   XtAddEventHandler(text,ButtonPressMask|ButtonReleaseMask,FALSE,ButtonActionCB,(void *) w);

   return(text);
}


/* AllocWindowTab - allocate and initialize a block of window table entries */

PWindow *AllocWindowTab()

{ PWindow *new, *next;
  int        i;

#ifdef DEBUG
   if (DebugTrace) printf("Allocating %d window entries.\n",INCRNUMWINDOWS);
#endif

   /* allocate another block of entries */
   new = (PWindow *)XtMalloc(INCRNUMWINDOWS*sizeof(PWindow));
   for (i = 0; i < INCRNUMWINDOWS; i++)
       { /* initialize entries */
         new[i].type = unused;
         next = new+i+1;
         new[i].anywindow.next_window = (PAnyWindow *)next;
       }
   new[INCRNUMWINDOWS-1].anywindow.next_window = NULL;
   return new;
}


/* AllocWindow - allocate a free window table entry */

PWindow *AllocWindow()

{  PAnyWindow *w,*prev;
 
   /* Any free entries? */
   for (w = (PAnyWindow *)windowtab,prev = NULL; w != NULL; prev = w,w = w->next_window) 
       { if (w->type == unused)
            return (PWindow *)w;
       }
  
   /* no free window table entries - get another block and link to last block */ 
   prev->next_window = (PAnyWindow *)AllocWindowTab();

   /* return first entry from new block */
   return (PWindow *)(prev->next_window);

}


/* CreateApplication - create main text window */

PTextWindow *CreateApplication(parent,newwindowname,newfilename,VScroll,HScroll,Read_write,Menus, dummyMenuPtr)

   	Widget parent;   /* top level shell widget */
   	char   *newwindowname;
   	char   *newfilename;
   	Boolean VScroll,HScroll;
	Boolean Read_write;
	Boolean Menus;
	MenuPtr *dummyMenuPtr;

{ 
	PTextWindow   *new_window;
   	int           n;
   	Arg           args[10];

        /* Allocate a window entry */
        new_window = (PTextWindow *)AllocWindow();
   	new_window->type = ptext;
   	new_window->app_shell = parent;
   	new_window->file_saved = TRUE;
	new_window->contents = NULL;
   	new_window->filename = newfilename;
   	new_window->windowname = newwindowname;
   	new_window->caseSense = FALSE;
   	new_window->scanForward = TRUE;
	new_window->invalidrect = FALSE;
   	new_window->selStart = 0;
   	new_window->selEnd = 0;
	new_window->read_write = Read_write;
	new_window->menu_bar = NULL;

   	/* Set window title */
   	n = 0;
   	XtSetArg(args[n],XmNtitle,newwindowname); n++;
   	XtSetValues(new_window->app_shell,args,n);

   	/* Create main window */
   	n = 0;
   	XtSetArg(args[n],XmNshadowThickness,0); n++;
   	new_window->main_window = XmCreateMainWindow(parent,"main1",args,n);
   	XtManageChild(new_window->main_window);
	
   	/* Create MenuBar in MainWindow.  */

   	if(Menus) {
   		new_window->menu_bar = CreateMenuBar(new_window, dummyMenuPtr);
   		XtManageChild(new_window->menu_bar->w);
   		}

   	/* Create Text.  */
   	new_window->text = CreateText(new_window,VScroll,HScroll);
   	XtManageChild (new_window->text);

   	XmAddTabGroup(new_window->text);
   	XtSetSensitive(new_window->text,TRUE);

   	/* Set main window areas up */
   	if(Menus)
   		XmMainWindowSetAreas(new_window->main_window,new_window->menu_bar->w,NULL,NULL,NULL,XtParent(new_window->text)); 
	else
	   	XmMainWindowSetAreas(new_window->main_window,NULL,NULL,NULL,NULL,XtParent(new_window->text)); 

   	/* Register for Focus In events so can determine when the active input
   	   window, and hence text widgets changes */
   	XtAddEventHandler(new_window->app_shell,FocusChangeMask,FALSE,FocusChangeCB,(void *)new_window);

   	/* Register for Configure notify events */
   	XtAddEventHandler(new_window->app_shell,StructureNotifyMask,FALSE,StructureNotifyCB,(void *)new_window);

   	return(new_window);
}  


/* CreateApplicationWindow - Set up an application popup text window */

PTextWindow *CreateApplicationWindow(wname,fname,windowargs,numwindowargs,
                                     VScroll,HScroll,Read_write,Menus, dummyMenuPtr)

  char    *wname;
  char    *fname;
  Arg     *windowargs;
  int     numwindowargs;
  Boolean VScroll;
  Boolean HScroll;
  Boolean Read_write;
  Boolean Menus;
  MenuPtr *dummyMenuPtr;

{ Atom   wm_delete_window;
  Widget popupshell;
  PTextWindow *new_window;

   popupshell = 
     XtCreatePopupShell(wname,topLevelShellWidgetClass,toplevel_app_shell,
         windowargs,numwindowargs);

   /* Create application text window. */
   new_window = CreateApplication(popupshell,wname,fname,VScroll,HScroll,Read_write,Menus,dummyMenuPtr);
	if (!new_window) {
		XtDestroyWidget(popupshell);
		destroyMenu((*dummyMenuPtr));
		return NULL;
	}	

   /* Set up the window manager protocol so shell is notified when application
      window deleted. This will ensure the system is finalized before quitting. */
   wm_delete_window = 
	 XmInternAtom(XtDisplay(popupshell),"WM_DELETE_WINDOW",FALSE);
   XmAddWMProtocols(popupshell,&wm_delete_window,1);
   XmAddWMProtocolCallback(popupshell,wm_delete_window,CloseWindowCB,(void *) new_window); 
   
   return(new_window);
}

getWindowConfig(w)
PAnyWindow	*w;
{
	XWindowAttributes	attr;
	Window	wind,root,parent,grand_parent,*children;
	unsigned int		nchildren;

	grand_parent = parent = XtWindow(w->app_shell);
	if (parent == (int)NULL) return;
	do {
		wind = parent;
		parent = grand_parent;
		XQueryTree(display,parent,&root,&grand_parent,&children,&nchildren);
		XFree((caddr_t) children);
	}
	while (grand_parent != root);
	XGetWindowAttributes(display,wind,&attr);
	w->width = attr.width;
	w->height = attr.height;
	w->offsetX = attr.x;
	w->offsetY = attr.y;
	XGetWindowAttributes(display,parent,&attr);
	w->leftedge = attr.x;
	w->topedge = attr.y;
#ifdef DEBUG
    if (DebugTrace) 
        {printf("getWindowConfig - Width %d, Height %d, LeftEdge %d, TopEdge %d, offsetX %d, offsetY %d.\n",
                w->width,w->height,w->leftedge,w->topedge,w->offsetX,w->offsetY);
    }
#endif
	setWindowGeometry(w);
}

setWindowGeometry(w)
PAnyWindow	*w;
{
	char	geometry[64];
	String newGeometry;
	Arg		args[3];
	int		n;

	sprintf(geometry,"%dx%d+%d+%d",w->width,w->height,w->leftedge,w->topedge);
	n = 0;
	XtSetArg(args[n],XmNgeometry,&newGeometry); n++;
	XtGetValues(w->app_shell,args, n);
	XtFree(newGeometry);
	n = 0;
	XtSetArg(args[n],XmNgeometry,XtNewString(geometry));n++;
	XtSetValues(w->app_shell, args, n);
}

/* StructureNotifyCB - the callback for configure (resize,reposition, etc.) events 
       on application shell windows */

void StructureNotifyCB(w,window,event)

   Widget     w;
   PAnyWindow *window;
   XAnyEvent  *event;

{   PAnyEvent        *pe = (PAnyEvent *) PrologEvent;
    Dimension        oldWidth,oldHeight;
    Position         oldLeftEdge,oldTopEdge;

#ifdef lint
	if (w) ;
#endif

#ifdef DEBUG
  if (DebugTrace ) printf("In StructureNotifyCB.\n");
#endif

   if (event->type == ConfigureNotify)
      {/* Retrieve size and position info from window */
		oldWidth = window->width;
		oldHeight = window->height;
		oldLeftEdge = window->leftedge;
		oldTopEdge = window->topedge;
		getWindowConfig(window);
         if ((oldWidth != window->width) || (oldHeight != window->height))
            { /* return Prolog resize event */
              PUserResizeEvent *re = (PUserResizeEvent *) PrologEvent;
              re->type = userresize;
              re->width = window->width;
              re->height = window->height;
            }
         else
            if ((oldLeftEdge != window->leftedge) || (oldTopEdge != window->topedge))
               {/* return Prolog reposition event */
                PUserRepositionEvent *re = (PUserRepositionEvent *) PrologEvent;
                re->type = userreposition;
                re->topedge = window->topedge;
                re->leftedge = window->leftedge;
               }
         if (pe->type != unknown)
            { /* fill in common event fields */
             pe->window = window;
             /* get modifier keys, etc. for lasteventdata */
             GetModifierInfo();
            }
      }
}


/* FocusChangeCB - the callback for focus change events on application shell
       windows */

void FocusChangeCB(w,window,event)

   Widget     w;
   PAnyWindow  *window;
   XFocusChangeEvent  *event;

{   PUserActivateEvent *pe = (PUserActivateEvent *) PrologEvent;

#ifdef DEBUG
    if (DebugTrace) 
      {printf("In FocusChangeCB. ");
       if (event->type == FocusIn) {printf("FocusIn.");}
       else {printf("FocusOut.");}
       printf(" Widget = %d.\n",w);
      }
#endif

    if (w != window->app_shell) {
	printf("ERROR: FocusChangeCB has wrong window pointer\n");
	exit(1);
    }

    pe->window = window;
    if (event->type == FocusIn) {
	TextSwapSelection((PTextWindow *) focus_window, (PTextWindow *) window);
        pe->type = useractivate;
	focus_window = (PWindow *) window;
    }
    else {/* FocusOut */
        pe->type = userdeactivate;
    }

    /* Get event time,modifier keys and button info */
    GetModifierInfo();
    return;
}


/* FileChangedCB - callback for the value changing in the text widget */

void FileChangedCB(w,tw,call_data)

Widget     w;              /* widget id */
PTextWindow *tw;          /* data from application */
XmTextVerifyPtr    call_data;      /* data from widget class */

{ 
#ifdef DEBUG
	if(DebugTrace)
		printf("\nIn FileChangedCB\n");
#endif
    /* Set the file_saved flag to indicate that the file has been modified and the 
       user should be notified before exiting. Beware - this callback is called directly
       from XmTextSetString so the focus_window is not always the right one to use. */

    if (tw->text == w) {
		if (tw->contents) {
			XtFree(tw->contents); 
			tw->contents = NULL;
		}
        tw->file_saved = FALSE;

	if ((call_data->event) && (call_data->event->type == KeyPress))
		call_data->doit = FALSE;
    	if(call_data->text->length == 0)
		call_data->text->ptr = NULL; 
        return;
    }
    printf("Error - Unable to find changed file.\n");
}


/* SelectionChangeCB - callback for the selection value changing in the text widget */

void SelectionChangeCB(w,client_data,call_data)

Widget     w;              /* widget id */
caddr_t    client_data;    /* data from application */
XmAnyCallbackStruct *call_data;      /* data from widget class */

{  char reasonstring[10];

#ifdef lint
	if (w) ;
	if (client_data) ;
#endif

#ifdef DEBUG
   if (DebugTrace)
      {if ((call_data->reason) == XmCR_GAIN_PRIMARY) 
          {strcpy(reasonstring,"GAIN");}
       else
          {strcpy(reasonstring,"LOSE");}
       printf("In SelectionChangeCB. Reason is %s.\n", reasonstring);
      }
#endif
}


/* CloseWindowCB - callback for popup shell destruction. Called when close item
   on window frame selected. Userclose event returned to Prolog. */

void CloseWindowCB(w,window,call_data)

Widget     w;              /* widget id */
PAnyWindow *window;        /* data from application */
caddr_t    call_data;      /* data from widget class */

{ PUserCloseEvent *pe = (PUserCloseEvent *) PrologEvent;

#ifdef lint
	if (call_data) ;
#endif

#ifdef DEBUG
  if (DebugTrace) {printf("In CloseWindowCB, w is %d.\n",w);}
#endif

  /* return Prolog event */
  pe->type = userclose;
  pe->window = window;
  /* get modifier keys, etc. for lasteventdata */
  GetModifierInfo();
} 


/* Prolog primitive: $openwindow(+Name,+Type,-Id,?LeftEdge,?TopEdge,
                                ?Width,?Height,+Options,+Fname, -DummyMenuPtr)
     - opens a window */

BNRP_Boolean openwindow(tcb)

   BNRP_TCB *tcb;

{  BNRP_result p;
   BNRP_term   curr_term;
   BNRP_tag    tag;
   Boolean     textwindowflag;
   PAnyWindow  *new_window;
   char        *name;
   char        *newGeometry;
   int         n;
   Arg         windowargs[12];
   MenuPtr      dummyMenuPtr = NULL;
   Boolean     VScroll;
   Boolean     HScroll;
   Boolean     Menus = TRUE;
   Boolean     Menus_specified = FALSE;
   enum WindowDefnType WindowDefn;
   Boolean     Visible = TRUE;
   Boolean     closeBox_specified = FALSE;
   Boolean     closeBox;
   Boolean     Front = TRUE;
   Boolean     Read_write = TRUE;
   Pixmap      PrologIcon;
	int			x,y,h,w;
	char	geometry[64];
	char		pos_str[32];
 
#ifdef DEBUG
   if (DebugTrace) printf("In $openwindow.\n");
#endif

   if  (tcb->numargs != 10) return(FALSE);

   /* Pick up window name */
   if (BNRP_getValue(tcb->args[1],&p) != BNRP_symbol) return FALSE;
	name = XtNewString(p.sym.sval);

   /* Text or graf? */
   if (BNRP_getValue(tcb->args[2],&p) != BNRP_symbol) {
		XtFree(name);
		return FALSE;
	}
   textwindowflag = (strcmp(p.sym.sval,"text") == 0);

   /* Get the position and size info */
   n = 0;
	x = y = h = w = 0;
	pos_str[0] = '\0';
   if (BNRP_getValue(tcb->args[4],&p) == BNRP_integer)
      { 
		x = p.ival;
   		if (BNRP_getValue(tcb->args[5],&p) != BNRP_integer) {
			XtFree(name);
			return FALSE;
		}
		y = p.ival;
		sprintf(pos_str,"+%d+%d",x,y);	
#ifdef DEBUG
        if (DebugTrace) printf("LeftEdge %d. ",p.ival);
        if (DebugTrace) printf("TopEdge %d. ",p.ival);
#endif
       }

   if (BNRP_getValue(tcb->args[6],&p) == BNRP_integer)
      { 
		w = p.ival;
   		if (BNRP_getValue(tcb->args[7],&p) != BNRP_integer) {
			XtFree(name);
			return FALSE;
		}
		h = p.ival;
       }
	else {
		w = defaultWidth;
		h = defaultHeight;
	}

#ifdef DEBUG
    if (DebugTrace) printf("Width %d. ",p.ival);
    if (DebugTrace) printf("Height %d. ",p.ival);
#endif
	sprintf(geometry,"%dx%d%s",w,h,pos_str);
    XtSetArg(windowargs[n],XmNgeometry,(newGeometry = XtNewString(geometry))); n++;

   /* Set up defaults for windows before processing options */
   if (textwindowflag)
      { VScroll = TRUE;
        HScroll = TRUE;
        WindowDefn = zoomdocproc;
      }
   else
      { VScroll = FALSE;
        HScroll = FALSE;
        WindowDefn = rdocproc;
      }

   /* Options */
   if (BNRP_getValue(tcb->args[8],&p) == BNRP_list)
     {/* find each list element  - ignore invalid stuff for now */ 
       curr_term = p.term.first;
       while ((tag = BNRP_getNextValue(&curr_term,&p)) != BNRP_end)
          { if (tag == BNRP_symbol)
               { if (strcmp(p.sym.sval,"novscroll") == 0)
                    VScroll = FALSE;
                 else if (strcmp(p.sym.sval,"nohscroll") == 0)
                         HScroll = FALSE;
                 else if (strcmp(p.sym.sval,"dboxproc") == 0)
                         WindowDefn = dboxproc;
                 else if (strcmp(p.sym.sval,"plaindbox") == 0)
                         WindowDefn = plaindbox;
                 else if (strcmp(p.sym.sval,"altdboxproc") == 0)
                         WindowDefn = altdboxproc;
                 else if (strcmp(p.sym.sval,"nogrowdocproc") == 0)
                         WindowDefn = nogrowdocproc;
                 else if (strcmp(p.sym.sval,"rdocproc") == 0)
                         WindowDefn = nogrowdocproc;
                 else if (strcmp(p.sym.sval,"zoomdocproc") == 0)
                         WindowDefn = zoomdocproc;
                 else if (strcmp(p.sym.sval,"zoomnogrow") == 0)
                         WindowDefn = zoomnogrow;
                 else if (strcmp(p.sym.sval,"documentproc") == 0)
                         WindowDefn = documentproc;
                 else if (strcmp(p.sym.sval,"namedboxproc") == 0)
                 	 WindowDefn = namedboxproc;
                 else if (strcmp(p.sym.sval,"hidden") == 0)
                         Visible = FALSE;
                 else if (strcmp(p.sym.sval,"noclosebox") == 0)
                         {closeBox = FALSE;
                          closeBox_specified = TRUE;}
                 else if (strcmp(p.sym.sval,"closebox") == 0)
                         closeBox = closeBox_specified = TRUE;
		 else if (strcmp(p.sym.sval,"back") == 0)
			 Front = FALSE;
		 else if (strcmp(p.sym.sval,"read_only") == 0)
			 Read_write = FALSE;
	 	 else if (strcmp(p.sym.sval,"menubar") == 0)
	 	 	 {Menus = TRUE;
	 	 	 Menus_specified = TRUE;}
	 	 else if (strcmp(p.sym.sval,"nomenubar") == 0)
	 	 	 Menus = FALSE;
               }
          }
     }

   /* Set up the closebox specification. If not specified, false for
      dialog boxes, true for the others. */
   if (!closeBox_specified)
      switch (WindowDefn) {
      case dboxproc:
      case namedboxproc:
      case plaindbox:
      case altdboxproc:
          closeBox = FALSE;
          break;
      default:
          closeBox = TRUE;
          break;
      }

#ifdef DEBUG
   if (DebugTrace)
	 printf("VScroll %d,HScroll %d,closeBox %d,Front %d,Visible %d,R/W %d.\n",
                           VScroll,HScroll,closeBox,Front,Visible,Read_write);
#endif
           
/* Set up window borders and functionality. Allow all, except dboxproc, to be iconified. */

	if (XmIsMotifWMRunning(toplevel_app_shell)) {
	 /* make sure MWM is running - window types not supported under other WM's */

   		switch (WindowDefn) {
   		case namedboxproc:
   		case dboxproc:
      		XtSetArg(windowargs[n],XmNmwmDecorations,MWM_DECOR_BORDER+MWM_DECOR_TITLE+
           		     (closeBox?MWM_DECOR_MENU:0)); n++;
      		XtSetArg(windowargs[n],XmNmwmFunctions,MWM_FUNC_MOVE+
           		     (closeBox?MWM_FUNC_CLOSE:0)); n++;
      		break;
   		case plaindbox:
   		case altdboxproc:
      		XtSetArg(windowargs[n],XmNmwmDecorations,MWM_DECOR_BORDER+MWM_DECOR_MINIMIZE+
           		     (closeBox?MWM_DECOR_MENU:0)); n++;
      		XtSetArg(windowargs[n],XmNmwmFunctions,MWM_FUNC_MOVE+MWM_FUNC_MINIMIZE+
           		     (closeBox?MWM_FUNC_CLOSE:0)); n++;
      		break;
   		case rdocproc:
   		case nogrowdocproc:
      		XtSetArg(windowargs[n],XmNmwmDecorations,MWM_DECOR_TITLE+MWM_DECOR_MENU+
          		     MWM_DECOR_BORDER+MWM_DECOR_MINIMIZE); n++;
      		XtSetArg(windowargs[n],XmNmwmFunctions,(closeBox?MWM_FUNC_CLOSE:0)+
           		    MWM_FUNC_MOVE+MWM_FUNC_MINIMIZE); n++;
      		break;
   		case zoomdocproc:
      		if (!closeBox)
      		   { XtSetArg(windowargs[n],XmNmwmFunctions,MWM_FUNC_ALL+MWM_FUNC_CLOSE); n++;
         		}
      		break;
   		case zoomnogrow:
      		XtSetArg(windowargs[n],XmNmwmDecorations,MWM_DECOR_ALL+MWM_DECOR_RESIZEH); n++;
      		XtSetArg(windowargs[n],XmNmwmFunctions,MWM_FUNC_ALL+MWM_FUNC_RESIZE+
           		    (closeBox?0:MWM_FUNC_CLOSE)); n++;
      		break;
   		case documentproc:
      		XtSetArg(windowargs[n],XmNmwmDecorations,MWM_DECOR_ALL+MWM_DECOR_MAXIMIZE); n++;
      		XtSetArg(windowargs[n],XmNmwmFunctions,MWM_FUNC_ALL+MWM_FUNC_MAXIMIZE+ 
           		    (closeBox?0:MWM_FUNC_CLOSE)); n++;
      		break;
   		default: 
      		break;
   		}
	}

	PrologIcon = XCreateBitmapFromData(display, DefaultRootWindow(display),
										icon_bits, icon_width, icon_height );
    XtSetArg(windowargs[n],XmNiconPixmap,PrologIcon); n++;

   /* open the specified window */
   if (textwindowflag) 
           { /* open a new window */
   		PTextWindow *tw;
   		char        *fname;
   		struct stat statbuf;		/* Information on a file. */
            if (BNRP_getValue(tcb->args[9],&p) != BNRP_symbol) {
				XtFree(name);
				return FALSE;
			}
            fname = XtNewString(p.sym.sval);
   	    tw = CreateApplicationWindow(name,fname,windowargs,n,VScroll,HScroll,Read_write,Menus,&dummyMenuPtr);
            if (!tw) {
				XtFree(name);
				XtFree(fname);
				destroyMenu(dummyMenuPtr);
				return FALSE;
			}
   	    /* Open file, if any, and pop up associated text window */
   	    if (stat(fname, &statbuf) == 0) 
               { if (! OpenFile(tw)) 
                   { /* Unable to open existing file */
                     printf("Warning: unable to open file\n");
                     destroyMenu(dummyMenuPtr);
                     XtDestroyWidget(tw->app_shell);
                     tw->type = unused;
					XtFree(name);
					XtFree(fname);
                     return(FALSE);
                    }
             	}
            tw->fontInfo.name = XtNewString("systemfont");
            tw->fontInfo.size = sys_font_info.size;
            tw->fontInfo.weight = sys_font_info.weight;
            tw->fontInfo.slant = sys_font_info.slant;
            tw->font = sys_font;
             new_window = (PAnyWindow *)tw;
           }
    else 
           {/* graphics window */
            PGrafWindow *gw;
            if(!Menus_specified)
            	Menus = FALSE;
     	    gw = CreateGrafWindow(name,windowargs,n,VScroll,HScroll,Menus, &dummyMenuPtr);
            if (!gw) {
				XtFree(name);
				destroyMenu(dummyMenuPtr);	/* NEW 31/05/95 */
				return FALSE;
			}
       	    PrologColors(gw);
       	    new_window = (PAnyWindow *)gw;
           }
   if (Menus) {
    	Dimension height;
     	n = 0;
     	XtSetArg(windowargs[n],XmNheight, &height); n++;
     	XtGetValues(new_window->menu_bar->w, windowargs, n);
	h += (long int)height; /* JH */
     	sprintf(geometry,"%dx%d%s",w,h,pos_str);
     	n = 0;
     	XtFree(newGeometry);
     	XtSetArg(windowargs[n],XmNgeometry, XtNewString(geometry)); n ++;
     	XtSetValues(new_window->app_shell, windowargs, n);
     	}
     	
    if (Visible) XtPopup(new_window->app_shell,XtGrabNone);

	new_window->leftedge = x;
	new_window->topedge = y;
	new_window->width = w;
	new_window->height = h;
	new_window->offsetX = 0;
	new_window->offsetY = 0;
   /* Retrieve size and position info from window */
	getWindowConfig(new_window);
   
   /* Remove window title from dialog boxes */
   switch (WindowDefn) {
   case dboxproc:
   case plaindbox:
   case altdboxproc:
      n = 0;
      XtSetArg(windowargs[n],XmNtitle,"\n"); n++;
      XtSetValues(new_window->app_shell,windowargs,n);
      break;
   default:
      break;
   }

#ifdef DEBUG
   if (DebugTrace) 
      printf("LeftEdge %d, TopEdge %d, Width %d, Height %d.\n",
              new_window->leftedge,new_window->topedge,new_window->width,
              new_window->height);
#endif

   /* Lower window if back specified. Only works if keyboard focus is pointer */
   if (Visible && (!Front))
      XLowerWindow(display,XtWindow(new_window->app_shell));

   return(BNRP_unify(tcb,tcb->args[3],
                     BNRP_makeInteger(tcb,(long int)new_window)) &&
          BNRP_unify(tcb,tcb->args[10],
          	     BNRP_makeInteger(tcb,(long int)dummyMenuPtr)));
}


/* CreateGrafWindow - creates a graphics window */

PGrafWindow *CreateGrafWindow(name,windowargs,numwindowargs,VScroll,HScroll,Menus, dummyMenuPtr)

  char    *name;
  Arg     *windowargs;
  int     numwindowargs;
  Boolean VScroll;
  Boolean HScroll;
  Boolean Menus;
  MenuPtr *dummyMenuPtr;

{ Atom   wm_delete_window;
  Widget popupshell;
  Arg    args[10];
  PGrafWindow *w;
  int    n;

   /* Find window table entry for new graphics window. */
   w = (PGrafWindow *)AllocWindow();

   /* Create popup graphics shell */
   popupshell = 
     XtCreatePopupShell(name,topLevelShellWidgetClass,toplevel_app_shell,
         windowargs,numwindowargs);
#ifdef DEBUG
   if (DebugTrace) printf("Graf widget is %d.\n",popupshell);
#endif

   /* Set up the window manager protocol so shell is notified when application
   window deleted. This will ensure that the system is finalized before quitting. */
   wm_delete_window = 
	 XmInternAtom(XtDisplay(popupshell),"WM_DELETE_WINDOW",FALSE);
   XmAddWMProtocols(popupshell,&wm_delete_window,1);
   XmAddWMProtocolCallback(popupshell,wm_delete_window,(XtCallbackProc)CloseWindowCB,(void *) w);

   w->type = pgraf;
   w->app_shell = popupshell;
   w->windowname = name;      /* for now! */
   w->invalidrect = FALSE;
   w->menu_bar = NULL;

   /* Set window title */
   n = 0;
   XtSetArg(args[n],XmNtitle,name); n++;
   XtSetValues(popupshell,args,n);
   
   /* Create main window */
   n = 0;
   XtSetArg(args[n],XmNshadowThickness,0); n++;
   w->main_window = XmCreateMainWindow(popupshell,"main2",args,n);
   XtManageChild(w->main_window);
   
   if(Menus) {
   	w->menu_bar = CreateMenuBar(w,dummyMenuPtr);
   	XtManageChild(w->menu_bar->w);
   	}

   /* Set up the drawing area */
   n = 0;
   XtSetArg(args[n], XmNresizePolicy, XmRESIZE_NONE); n++;
   XtSetArg(args[n], XmNheight, CANVASHEIGHT); n++;
   XtSetArg(args[n], XmNwidth, CANVASWIDTH); n++; 
   XtSetArg(args[n], XmNmarginHeight, 0); n++;
   XtSetArg(args[n], XmNmarginWidth, 0); n++;
   
   w->canvas = XmCreateDrawingArea(w->main_window,"canvas",args,n);
   XtManageChild(w->canvas);

   if(Menus)
	XmMainWindowSetAreas(w->main_window,w->menu_bar->w,NULL,NULL,NULL,w->canvas);
   else
   	XmMainWindowSetAreas(w->main_window,NULL,NULL,NULL,NULL,w->canvas);

   /* Initialize the graphics environment. */
   InitGrafWindow(w);

   w->first_expose = TRUE;	/* waiting for first expose */

   /* Register for FocusIn events to determine when the active input window changes */
   XtAddEventHandler(w->app_shell,FocusChangeMask,FALSE,(XtEventHandler)FocusChangeCB,(void *)w);
   
   /* Register for keypress events */
   XtAddEventHandler(w->canvas,KeyPressMask,FALSE,(XtEventHandler)KeyPressCB,(void *)w);
   /* Register for move/resize events */
   XtAddEventHandler(w->app_shell,StructureNotifyMask,FALSE,(XtEventHandler)StructureNotifyCB, (void *)w);
   /* Register for button press events */
   XtAddEventHandler(w->canvas,ButtonPressMask|ButtonReleaseMask,FALSE,(XtEventHandler)ButtonActionCB,(void *) w);

   /* Register for expose callbacks */
   XtAddCallback(w->canvas,XmNexposeCallback,(XtCallbackProc)ExposeCB,(void *) w);

   return(w);
}


void ButtonActionCB(w, window, ev, continue_flag)
Widget		w;
PAnyWindow	*window;
XButtonEvent	*ev;
Boolean		*continue_flag;
{
	PUserMouseEvent *pe = (PUserMouseEvent *) PrologEvent;
#ifdef DEBUG
	if (DebugTrace) {printf("In ButtonActionCB. ");}
#endif

#ifdef lint
	if (w);
#endif
	*continue_flag = TRUE;

	if (((ev->type == ButtonPress) || (ev->type == ButtonRelease)) &&
		 (ev->button == Button1)) {
		pe->type = (ev->type == ButtonPress) ? usermousedown : usermouseup;
		pe->window = window;
#ifdef DEBUG
	   if (DebugTrace) {
			printf((ev->type==ButtonPress)?"usermousedown":"usermouseup");
			printf(" window %s\n",window->windowname);
		}
#endif
        pe->when = ev->time;
        pe->modifiers_valid = ev->same_screen;
        pe->mousegx = ev->x_root;  
        pe->mousegy = ev->y_root;  
        pe->control = (ControlMask & ev->state) == ControlMask; 
        pe->shift = (ShiftMask & ev->state) == ShiftMask; 
        pe->capslock = (LockMask & ev->state) == LockMask; 
        pe->mouseup = ev->type == ButtonRelease; 
        pe->command = FALSE;
        pe->option = FALSE;
        pe->mouselx = ev->x;  
        pe->mousely = ev->y;  
		*continue_flag = FALSE;
	}

#if 0
    /*
     * disabled by yanzhou@bnr.ca 20/10/95
     * reason: better textEditState handling available in `eventLoop'
     */

    /* If in a text editing state, check for non text edit events, i.e.
       button press outside the editbox window. */
   if (textEditState &&
       (ev->type == ButtonPress) && (ev->window != XtWindow(editbox))) {
	  editSelStart = editSelEnd = 0;		/* LB/JR - possible problem in editbabs */
      textEditState = FALSE;
	  }
#ifdef DEBUG
   if (DebugTrace) {printf(" textEditState %d.\n",textEditState);}
#endif
#endif
}

/* ExposeCB - callback for exposure events on graf windows. */

void ExposeCB(w,window,call_data)
Widget     w;              /* widget id */
PGrafWindow *window;       /* data from application */
XmDrawingAreaCallbackStruct *call_data;      /* data from widget class */

{ PUserUpdateEvent *pe = (PUserUpdateEvent *) PrologEvent;
  XExposeEvent     *ev = (XExposeEvent *) call_data->event;

#ifdef lint
	if (w) ;
#endif

#ifdef DEBUG
  if (DebugTrace) {printf("In ExposeCB. Window %s, count=%d\n",window->windowname,ev->count);}
#endif

	if (window->first_expose) {
        XSetWindowAttributes	setwinattr;
		window->first_expose = FALSE;
		window->graf->draw = XtWindow(window->canvas);
        setwinattr.backing_store = Always;
        XChangeWindowAttributes(display,XtWindow(window->canvas),CWBackingStore,&setwinattr);
	}

  /* accumulate clip region for the window */
  XtAddExposureToRegion((XEvent *)ev,window->graf->accum_expose_region);

  if (ev->count == 0)
     { /* last contiguous expose event in group, set update region for 
          window. Dograf will use this to set clip region as required. */

       StartGrafUpdate(window);
       
       /* return Prolog event */
       pe->type = userupdate;
       pe->window = (PAnyWindow *) window;
       /* get modifier keys, etc. for lasteventdata */
       GetModifierInfo();
     }
}


/* Prolog primitive: $closewindow(+Id)
     - closes a window */

BNRP_Boolean closewindow(tcb)

   BNRP_TCB *tcb;

{  BNRP_result p;
   PAnyWindow  *close_window;
 
#ifdef DEBUG
   if (DebugTrace) printf("In $closewindow");
#endif

   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   close_window = (PAnyWindow *)p.ival;
   CloseAnyWindow(close_window);
   
#ifdef DEBUG
   if (DebugTrace) printf("window %s.\n",close_window->windowname);
#endif

   /* if closed window is focus window, set it to null */
   if (focus_window == (PWindow *) close_window)
      focus_window = NULL;

   return(TRUE);
}

/* Prolog primitive: $hidewindow(+Id)
     - hides a window */

BNRP_Boolean hidewindow(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PAnyWindow  *hide_window;
 
#ifdef DEBUG
   if (DebugTrace) printf("In $hidewindow.\n");
#endif

   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   hide_window = (PAnyWindow *)p.ival;
   XtPopdown(hide_window->app_shell);

   return(TRUE);
}


/* Prolog primitive: $showwindow(+Id)
     - shows a window */

BNRP_Boolean showwindow(tcb)
BNRP_TCB *tcb;
{  
	BNRP_result p;
	PAnyWindow  *show_window;
 
#ifdef DEBUG
	if (DebugTrace) printf("In $showwindow.\n");
#endif

	if (tcb->numargs != 1) return(FALSE);

	if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
	show_window = (PAnyWindow *)p.ival;
	XtPopup(show_window->app_shell,XtGrabNone);

	return(TRUE);
}

/* Prolog primitive: $positionwindow(+Id,?LeftEdge,?TopEdge)
     - positions a window */

BNRP_Boolean positionwindow(tcb)
BNRP_TCB *tcb;
{  
	BNRP_result p;
	PAnyWindow  *position_window;
	Boolean     reposition = FALSE;
	Arg		args[3];
	int		n = 0;
 
#ifdef DEBUG
   if (DebugTrace) printf("In $positionwindow.");
#endif

   if (tcb->numargs != 3) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   position_window = (PAnyWindow *)p.ival;

   if (BNRP_getValue(tcb->args[2],&p) == BNRP_integer)
      { position_window->leftedge = (short) p.ival;
        reposition = TRUE;
      }

   if (BNRP_getValue(tcb->args[3],&p) == BNRP_integer)
      { position_window->topedge = (short) p.ival;
        reposition = TRUE;
      }

#ifdef DEBUG
   if (DebugTrace) 
      {printf("LeftEdge %d(+%d), TopEdge %d(+%d).\n",position_window->leftedge,position_window->offsetX,
              position_window->topedge,position_window->offsetY);
      }
#endif
   /* reposition window, if necessary */
   if (reposition && (XtWindow(position_window->app_shell) != (int)NULL))
      { /* one or both of LeftEdge, TopEdge specified */
		XtSetArg(args[n], XmNx, position_window->leftedge+position_window->offsetX); n++;
		XtSetArg(args[n], XmNy, position_window->topedge+position_window->offsetY); n++;
		XtSetValues(position_window->app_shell,args,n);
      }
   
   return(BNRP_unify(tcb,tcb->args[2],
                     BNRP_makeInteger(tcb,(long int)position_window->leftedge)) &&
          BNRP_unify(tcb,tcb->args[3],
                     BNRP_makeInteger(tcb,(long int)position_window->topedge)));
}


/* Prolog primitive: $sizewindow(+Id,?Width,?Height)
     - size a window */

BNRP_Boolean sizewindow(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PAnyWindow  *size_window;
   Boolean     resize = FALSE;
	Arg		args[3];
	int		n = 0;
 
#ifdef DEBUG
   if (DebugTrace) printf("In $sizewindow.");
#endif

   if (tcb->numargs != 3) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   size_window = (PAnyWindow *)p.ival;

   if (BNRP_getValue(tcb->args[2],&p) == BNRP_integer)
      { size_window->width = (short) p.ival;
        resize = TRUE;
      }

   if (BNRP_getValue(tcb->args[3],&p) == BNRP_integer)
      { size_window->height = (short) p.ival;
        resize = TRUE;
      }

   /* resize window, if necessary */
   if (resize && (XtWindow(size_window->app_shell) != (int)NULL))
      { /* one or both of Height, Width specified */
		XtSetArg(args[n], XmNheight, size_window->height); n++;
		XtSetArg(args[n], XmNwidth, size_window->width); n++;
		XtSetValues(size_window->app_shell,args,n);
      }
   
   return(BNRP_unify(tcb,tcb->args[2],
                     BNRP_makeInteger(tcb,(long int)size_window->width)) &&
          BNRP_unify(tcb,tcb->args[3],
                     BNRP_makeInteger(tcb,(long int)size_window->height)));
}

/* Prolog primitive: $renamewindow(+Id,+NewName)
     - rename a window */

BNRP_Boolean renamewindow(tcb)
	BNRP_TCB *tcb;
{
	BNRP_result p;
	PAnyWindow  *window;
	int         n;
	Arg         args[2];
 
#ifdef DEBUG
	if (DebugTrace) printf("In $renamewindow.");
#endif

	if (tcb->numargs != 2) return(FALSE);

	if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
	window = (PAnyWindow *)p.ival;
	if (BNRP_getValue(tcb->args[2],&p) != BNRP_symbol) return FALSE;

	/* Set window title */
	n = 0;
	XtSetArg(args[n],XmNtitle,p.sym.sval); n++;
	XtSetArg(args[n],XmNiconName,p.sym.sval); n++;
	XtSetValues(window->app_shell,args,n);
	if (window->windowname != NULL)
		XtFree(window->windowname);
	window->windowname = XtNewString(p.sym.sval);
   
	return TRUE;
}


/* Prolog primitive: $activewindow(?Id)
     - make window active */

BNRP_Boolean activewindow(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PAnyWindow  *active_window;
   XWindowAttributes window_attr;

 
#ifdef DEBUG
   if (DebugTrace) printf("In $activewindow.\n");
#endif

   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) == BNRP_integer)
      { /* make the specified window the active one */
       active_window = (PAnyWindow *)p.ival;
       if (active_window != (PAnyWindow *)focus_window)
          {/* make this the active window - check it is viewable, else will get warning.
              This happens when XtPopup has just been called in showwindow. */
          if ((XGetWindowAttributes(display,XtWindow(active_window->app_shell),&window_attr) != 0) &&
              (window_attr.map_state == IsViewable))

              XSetInputFocus(display,XtWindow(active_window->app_shell),RevertToPointerRoot, CurrentTime);
          }
       /* Raise the window to the top of the stack. Useful when keyboard focus
          policy is pointer */
       XRaiseWindow(display,XtWindow(active_window->app_shell));
      }
   else
      { /* query, so return the current active window */
       active_window = (PAnyWindow *)focus_window;
      }

   return(BNRP_unify(tcb,tcb->args[1],
                     BNRP_makeInteger(tcb, (long int)active_window)));
}


/* Prolog primitive: $getgc(+WId,-GCId)
     - returns the graf context associated with a window */

BNRP_Boolean getgc(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PGrafWindow  *gw;
 
#ifdef DEBUG
   if (DebugTrace) printf("In $getgc.\n");
#endif

   if (tcb->numargs != 2) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   gw = (PGrafWindow *)p.ival;

   return(BNRP_unify(tcb,tcb->args[2],
                     BNRP_makeInteger(tcb,(long int)gw->graf)));
}


/* Prolog primitive: $changedtext(+WId)
     - succeeds if the contents of the window has been changed since last saved */ 

BNRP_Boolean changedtext(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PTextWindow  *tw;
 
   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   tw = (PTextWindow *)p.ival;

   return(!tw->file_saved);
}

/* Prolog primitive: $savetext(+WId)
     - save the contents of the window */ 

BNRP_Boolean savetext(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PTextWindow  *tw;
 
#ifdef DEBUG
	if (DebugTrace) printf("In savetext.\n");
#endif

   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   tw = (PTextWindow *)p.ival;

   return((tw->read_write) && (SaveFile(tw,tw->filename)));
}

/* Prolog primitive: $reloadtext(+WId)
     - reload the contents of the window from disk */ 

BNRP_Boolean reloadtext(tcb)

   BNRP_TCB *tcb;
 
{  BNRP_result p;
   PTextWindow  *tw;
 
   if (tcb->numargs != 1) 
      /* syntax error - version problems? */
      return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   tw = (PTextWindow *)p.ival;

   return(tw->file_saved || OpenFile(tw));
}

/* Prolog primitive: $retargettext(+WId,+FileName)
     - retargets the contents of the window from disk */ 
BNRP_Boolean retargettext(tcb)
BNRP_TCB *tcb;
{
	BNRP_result p;
	PTextWindow  *tw;
 
#ifdef DEBUG
	if (DebugTrace) printf("In retargettext.\n");
#endif
	if (tcb->numargs != 2) return(FALSE);

	if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
	tw = (PTextWindow *)p.ival;

	if (BNRP_getValue(tcb->args[2],&p) != BNRP_symbol) return FALSE;

	if (tw->filename != NULL)
		XtFree(tw->filename);
	tw->filename = XtNewString(p.sym.sval);

	return TRUE;
}

/* Prolog primitive - localglobal(Windowname,Xlocal,Ylocal,Xglobal,Yglobal)
   - translates between global and local coordinates */

BNRP_Boolean	localglobal(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	px,py;
	int			ix,iy;
	Position	x,y;
	PGrafWindow	*gw;
	Window		root, parent, *children, child;
	unsigned int	nchildren;
	
	if (tcb->numargs != 5)	return FALSE;

	if (BNRP_getValue(tcb->args[1], &px) != BNRP_integer)	return FALSE;
	gw = (PGrafWindow *) px.ival;

	if ((BNRP_getValue(tcb->args[2], &px) == BNRP_integer) &&
		(BNRP_getValue(tcb->args[3], &py) == BNRP_integer)) {
		XtTranslateCoords(gw->canvas, px.ival, py.ival, &x, &y);
#ifdef xDEBUG
	if (DebugTrace)
		printf("localglobal(%d,%d,%d,%d).\n",px.ival,py.ival,x,y);
#endif
		return BNRP_unify(tcb, tcb->args[4], BNRP_makeInteger(tcb, (long int)x)) 
			&& BNRP_unify(tcb, tcb->args[5], BNRP_makeInteger(tcb, (long int)y));
	} else if ((BNRP_getValue(tcb->args[4], &px) == BNRP_integer) &&
				(BNRP_getValue(tcb->args[5], &py) == BNRP_integer) &&
				XtIsRealized(gw->canvas)) {
		XQueryTree(display, XtWindow(gw->canvas), &root, &parent, &children, &nchildren);
		XFree((caddr_t) children);
		XTranslateCoordinates(display, root, XtWindow(gw->canvas), px.ival, py.ival, &ix, &iy, &child);
#ifdef xDEBUG
	if (DebugTrace)
		printf("localglobal(%d,%d,%d,%d).\n",ix,iy,px.ival,py.ival);
#endif
		return BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, (long int)ix)) 
			&& BNRP_unify(tcb, tcb->args[3], BNRP_makeInteger(tcb, (long int)iy));
	} else return FALSE;
}

/* Prolog primitive - scrndimensions(?Width,?Height)
   - generates the dimensions of the display. */

BNRP_Boolean	scrndimensions(tcb)
BNRP_TCB	*tcb;
{
	unsigned int	h,w;
	
	if (tcb->numargs != 2)	return FALSE;

	w = DisplayWidth(display, 0);
	h = DisplayHeight(display, 0);

	return BNRP_unify(tcb, tcb->args[1], BNRP_makeInteger(tcb, (long int)w)) 
		&& BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, (long int)h));
}

/* Prolog primitive - doubletime(Deltatime)
   - queries or sets the mouse double click time. Time is given in milliseconds! */

BNRP_Boolean	doubletime(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	if (tcb->numargs != 1)	return FALSE;
	if (BNRP_getValue(tcb->args[1],&p) == BNRP_integer) {
		XtSetMultiClickTime(display,p.ival);
		return TRUE;
	}
	else
		return (BNRP_unify(tcb,tcb->args[1], BNRP_makeInteger(tcb,(long int)XtGetMultiClickTime(display))));
}

/* Prolog primitive - invalidrect(Windowname,Left,Top,Right,Bottom)
   - invalidates a rectangular region in a window */

BNRP_Boolean invalidrect(tcb)

   BNRP_TCB *tcb;

{ XEvent ExposeEvent;
  BNRP_result  p;
  PGrafWindow  *destwindow;

#ifdef DEBUG
   if (DebugTrace) printf("In invalidrect.");
#endif

   if (tcb->numargs != 5) return(FALSE);

   /* Format the information as an X event and send the event. The count is
      set to 1 to allow for compression inside the expose event handling. Thre
	  next userevent call will generate an expose event with a zero count to
	  terminate the compression, if an invalidrect has been called. */

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   destwindow = (PGrafWindow *)p.ival;
   if (destwindow->type != pgraf) return(FALSE);

   ExposeEvent.xexpose.type = Expose;
   ExposeEvent.xexpose.serial = 0;      /* set correctly later */
   ExposeEvent.xexpose.send_event = TRUE;
   ExposeEvent.xexpose.display = display;
   ExposeEvent.xexpose.window = XtWindow(destwindow->canvas);
   ExposeEvent.xexpose.count = 1;

   if (BNRP_getValue(tcb->args[2],&p) != BNRP_integer) return FALSE;
   ExposeEvent.xexpose.x = p.ival;

   if (BNRP_getValue(tcb->args[3],&p) != BNRP_integer) return FALSE;
   ExposeEvent.xexpose.y = p.ival;

   if (BNRP_getValue(tcb->args[4],&p) != BNRP_integer) return FALSE;
   ExposeEvent.xexpose.width = p.ival - ExposeEvent.xexpose.x;

   if (BNRP_getValue(tcb->args[5],&p) != BNRP_integer) return FALSE;
   ExposeEvent.xexpose.height = p.ival - ExposeEvent.xexpose.y;

#ifdef DEBUG
   if (DebugTrace) 
      printf("Window %s, x %d, y %d, width %d, height %d.\n",
            destwindow->windowname,ExposeEvent.xexpose.x,ExposeEvent.xexpose.y,ExposeEvent.xexpose.width,ExposeEvent.xexpose.height);
#endif

   InvalidrectGenerated = TRUE;	/* set flag for userevent call */
   destwindow->invalidrect = TRUE;
   return(
      XSendEvent(display,ExposeEvent.xexpose.window,TRUE,ExposureMask,
                 &ExposeEvent));
}

/* Prolog primitive - validrect(Windowname,Left,Top,Right,Bottom)
   - validates the rectangular region in a window. Only valid while
   an update operation is in progress */

BNRP_Boolean validrect(tcb)

   BNRP_TCB *tcb;
{
  BNRP_result  p;
  PGrafWindow  *destwindow;
  XRectangle   rectangle;

#ifdef DEBUG
   if (DebugTrace) printf("In validrect.");
#endif

   if (tcb->numargs != 5) return(FALSE);

   if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
   destwindow = (PGrafWindow *)p.ival;
   if ((destwindow->type != pgraf) || (!destwindow->graf->valid_update_region))
      /* no update operation on window */
       return(TRUE);

   if (BNRP_getValue(tcb->args[2],&p) != BNRP_integer) return FALSE;
   rectangle.x = (short) p.ival;
   
   if (BNRP_getValue(tcb->args[3],&p) != BNRP_integer) return FALSE;
   rectangle.y = (short) p.ival;

   if (BNRP_getValue(tcb->args[4],&p) != BNRP_integer) return FALSE;
   rectangle.width = (unsigned short) p.ival - rectangle.x;

   if (BNRP_getValue(tcb->args[5],&p) != BNRP_integer) return FALSE;
   rectangle.height = (unsigned short) p.ival - rectangle.y;

#ifdef DEBUG
   if (DebugTrace) 
      printf("Window %s, x %d, y %d, width %d, height %d.\n",
             destwindow->windowname,rectangle.x,rectangle.y,rectangle.width,rectangle.height);
#endif

   ModifyGrafUpdate(destwindow,&rectangle);

   return(TRUE);
}

BNRP_Boolean setcursor(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	PAnyWindow	*w;
	Window		window;
	unsigned	int	cursor;
	BNRP_tag	tag;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (PAnyWindow *) p.ival;
	if (w->type == pgraf)
		window = XtWindow(((PGrafWindow *) w)->canvas);
	else if (w->type == ptext)
		window = XtWindow(((PTextWindow *) w)->text);

	tag = BNRP_getValue(tcb->args[2], &p);
	if (tag == BNRP_symbol) {
		if (strcmp(p.sym.sval,"arrow") == 0)
			cursor = XC_left_ptr;
		else if (strcmp(p.sym.sval,"cross") == 0)
			cursor = XC_cross;
		else if (strcmp(p.sym.sval,"plus") == 0)
			cursor = XC_plus;
		else if (strcmp(p.sym.sval,"ibeam") == 0)
			cursor = XC_xterm;
		else if (strcmp(p.sym.sval,"watch") == 0)
			cursor = XC_watch;
		else 
			return FALSE;
	}
	else if (tag == BNRP_integer)
		cursor = p.ival;
	else
		return FALSE;
	XDefineCursor(display, window, XCreateFontCursor(display, cursor));

	return TRUE;
}

BNRP_Boolean Beep(tcb)
BNRP_TCB	*tcb;
{
	if (tcb->numargs != 0) return FALSE;
	XBell(display,0);
	return TRUE;
}

void BindPWindowPrimitives()
{
   /* window primitives */
   BNRPBindPrimitive("$openwindow",openwindow);
   BNRPBindPrimitive("$closewindow",closewindow);
   BNRPBindPrimitive("$hidewindow",hidewindow);
   BNRPBindPrimitive("$showwindow",showwindow);
   BNRPBindPrimitive("$positionwindow",positionwindow);
   BNRPBindPrimitive("$sizewindow",sizewindow);
   BNRPBindPrimitive("$renamewindow",renamewindow);
   BNRPBindPrimitive("$activewindow",activewindow);
   BNRPBindPrimitive("$getgc",getgc);
   BNRPBindPrimitive("$changedtext",changedtext);
   BNRPBindPrimitive("$savetext",savetext);
   BNRPBindPrimitive("$reloadtext",reloadtext);
   BNRPBindPrimitive("$retargettext",retargettext);
   BNRPBindPrimitive("$localglobal",localglobal);
   BNRPBindPrimitive("$scrndimensions",scrndimensions);
   BNRPBindPrimitive("doubletime",doubletime);
   BNRPBindPrimitive("$invalidrect",invalidrect);
   BNRPBindPrimitive("$validrect",validrect);
   BNRPBindPrimitive("$setcursor",setcursor);
	BNRPBindPrimitive("beep", Beep);
}
