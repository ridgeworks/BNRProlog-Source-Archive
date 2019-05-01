/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/XProlog.c,v 1.2 1996/01/03 14:16:16 yanzhou Exp $
*
*  $Log: XProlog.c,v $
 * Revision 1.2  1996/01/03  14:16:16  yanzhou
 * Resource names changed.
 *
 * Revision 1.1  1995/09/22  11:29:24  harrisja
 * Initial version.
 *
*
*/

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
#include <string.h>

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/keysym.h>
#include <X11/Shell.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>

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

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProGraf.h"
#include "ProText.h"
#include "ProMenus.h"
#include "ProWindows.h"
#include "ProEvents.h"
#include "Prolog.h"

/* constant definitions */

#define TRUE               1
#define FALSE              0

XmStringCharSet charset = (XmStringCharSet) XmSTRING_DEFAULT_CHARSET;
				/* used to set up XmStrings */

#ifdef DEBUG
Boolean    DebugTrace = FALSE;
Boolean    PrologEventTrace = FALSE;
Boolean    PrologIdleTrace = FALSE;
Boolean    XEventTrace = FALSE;
#endif

Widget     toplevel_app_shell;           /* Shell widget */
XtAppContext app_context;
Display    *display;

/* Prolog related data */

#define ENVIRONSIZE  1000000
#define CHOICEPTSIZE 500000

/* Prolog related procedures */

void InitProlog();
void InitMotifPrims();

/* XtAppWarningMsgHandler for debug use only */

#ifdef DEBUG
void myWarn(name,type,class,defaultp,params,num_params) 
	String name;
	String type;
	String class;
	String defaultp;
	String *params;
	Cardinal *num_params; 
{ 
	if (strcmp(defaultp,"Attempt to remove nonexistent passive grab")==0)
		return;
	fprintf(stderr,"BNR Prolog: ");
	fprintf(stderr,"name: %s,type: %s,class: %s,defaultp: %s.\n",name,type,class,defaultp);
	if (DebugTrace) abort(); 
}
#endif

/* InitMotifPrims - initialize the Motif specific Prolog primitives */

void InitMotifPrims()
{
	BindPEventPrimitives();
	BindPWindowPrimitives();
	BindPGrafPrimitives();
	BindPTextPrimitives();
	BindPMenuPrimitives();
}

/* InitProlog - Initialize the embedded Prolog system */

int BNRP_initializeAllRings(argc,argv)
int argc;
char **argv;
{   
	Arg		args[3];
	int		i,n=0;
	/* REMOVED Mar. 95 int             result; */
	typedef struct {
		XFontStruct *sys_font,*appl_font;
		int	w,h;
	} ValueRec;
	ValueRec values;
	static String fallback_resources[] = {
		"*font: -*-courier-medium-r-*-*-12-*-75-75-*-*-iso8859-*",
		"*applFont: -*-new century schoolbook-medium-r-*-*-12-*-75-75-*-*-iso8859-*",
        "*windowHeight: 400",
        "*windowWidth:  600",
		NULL
	};
	static XtResource resources[] = {
		{
		XtNfont,
		XtCFont,
		XtRFontStruct, sizeof(XFontStruct *),
		XtOffsetOf(ValueRec,sys_font), 
		XtRString, "XtDefaultFont"
		},
		{
		"applFont",
		XtCFont,
		XtRFontStruct, sizeof(XFontStruct *),
		XtOffsetOf(ValueRec,appl_font), 
		XtRString, "XtDefaultFont"
		},
		{
        "windowHeight",
		XtCHeight,
		XtRInt, sizeof(int),
		XtOffsetOf(ValueRec, h),
		XtRInt, "400"
		},
		{
        "windowWidth",
		XtCWidth,
		XtRInt, sizeof(int),
		XtOffsetOf(ValueRec, w),
		XtRInt, "600"
		}
	};
	

   /* Allocate and initialize the window table to empty */
   windowtab = AllocWindowTab();

   app_context = XtCreateApplicationContext();
   XtAppSetFallbackResources(app_context, fallback_resources);

   display = XtOpenDisplay(app_context,NULL,NULL,"XProlog",NULL,0,&argc,argv);
   if (!display) {
       XtWarning("BNR Prolog - can't open display, exiting...");
       return(-2);  
       /*Was -1 but loadBase might generate a -1 error code.  -2 is unused Jason Harris Feb. 95*/
	}

   /* Create application shell */
   XtSetArg(args[n], XmNiconName, "BNR Prolog"); n++;
   toplevel_app_shell=XtAppCreateShell(NULL,"XProlog",applicationShellWidgetClass,display,args,n);

   XtGetApplicationResources(toplevel_app_shell, &values, (XtResourceList) &resources, 4, NULL, 0);

   sys_font = values.sys_font;
   appl_font = values.appl_font;
   defaultWidth = values.w;
   defaultHeight = values.h;
   GetFontInfo(sys_font, &sys_font_info);
   GetFontInfo(appl_font, &appl_font_info);

   /* Process argv for options */
#ifdef DEBUG
	for (n=1;n<argc;n++) {
		if ((argc > 1) && (DebugTrace = (strcmp(argv[n],"-debug") == 0))) {
			argc--;
			for (i=n;i<argc;i++)
				argv[i] = argv[i+1];
			printf("Debug trace on ...\n");
			XEventTrace = TRUE;
        	PrologEventTrace = TRUE;
        	PrologIdleTrace = TRUE;
		}
		else if ((argc > 1) && (argv[n][0] == '+')) {
			printf("Debug trace on ...\n");
			DebugTrace = (strchr(argv[n],'d') != NULL);
			XEventTrace = (strchr(argv[n],'x') != NULL);
			PrologEventTrace = (strchr(argv[n],'p') != NULL);
			PrologIdleTrace = (strchr(argv[n],'i') != NULL);
			argc--;
			for (i=n;i<argc;i++)
				argv[i] = argv[i+1];
		}
		XSynchronize(display,XEventTrace);
	}
   XtAppSetWarningMsgHandler(app_context,myWarn);
#endif

	BNRP_initializeAllLowerRings(argc,argv);
    /* Initialize Motif specific primitives */
    InitMotifPrims();        
/* Now it is the caller of BNRP_initializeAllRings responsibility to
   report that the base could not be loaded.  Changed because if you
   embed your own base the warning would still be given.

   result = BNRP_loadBase(argc, argv, "base.a");
   if (result != 0) 
	XtWarning("BNR Prolog - can't load base file, exiting...");
   return result;
*/
 return(BNRP_loadBase(argc, argv, "base.a"));
}
