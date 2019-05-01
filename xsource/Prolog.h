/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/Prolog.h,v 1.1 1995/09/22 11:26:50 harrisja Exp $
*
*  $Log: Prolog.h,v $
 * Revision 1.1  1995/09/22  11:26:50  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_Prolog
#define _H_Prolog

#ifdef DEBUG
extern Boolean DebugTrace;
extern Boolean XEventTrace;
extern Boolean PrologEventTrace;
extern Boolean PrologIdleTrace;
#endif
extern XmStringCharSet charset;
extern XtAppContext app_context;
extern Widget toplevel_app_shell;
extern Display	*display;

#endif
