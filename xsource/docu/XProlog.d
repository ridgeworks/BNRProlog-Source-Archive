#if 0
----------------------------------------------------------------------
> Global Function: myWarn ;
  $ voidmyWarn ()
> Purpose:
  | This is the XtAppWarningMsgHandler that is only enabled if 'DEBUG' is defined.  It prints out some debug information about the X warning that occured.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: InitMotifPrims ;
  $ voidInitMotifPrims ()
> Purpose:
  | This function binds in all of the X/Motif Prolog primitives available.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initializeAllRings ;
  $ intBNRP_initializeAllRings (int, char**)
> Purpose:
  | This function initializes the X environment for Prolog and sets up the fallback resources for the application which include: fonts, window height and width.  It also allocates some window table entries for later use.  If 'DEBUG' is defined then argv is scanned for the -debug option whereupon some or all of the debug flags are set (DebugTrace, XEventTrace, PrologEventTrace, PrologIdleTrace).  It then initializes rings 0 - 5 and the X/Motif primitives before making an attempt to load "base.a".
> Calling Context:
  | 
> Return Value:
  | int - the result of loading base.a (0 on success) or -2 if a display could not be opened.
> Parameters:
  = int argc - number of command line arguements passed in
  = char** argv - array of command line arguements
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: charset
  $ XmStringCharSet charset
> Purpose:
  | Default character set to be used with XmStrings.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: DebugTrace
  $ Boolean DebugTrace
> Purpose:
  | If this is TRUE, then debug tracing is enabled.  Only available if 'DEBUG' is defined.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: PrologEventTrace
  $ Boolean PrologEventTrace
> Purpose:
  | If this is TRUE, then Prolog event tracing is enabled.  Only available if 'DEBUG' is defined.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: PrologIdleTrace
  $ Boolean PrologIdleTrace
> Purpose:
  | If this is TRUE, then idle event tracing is enabled.  Only available if 'DEBUG' is defined.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: XEventTrace
  $ Boolean XEventTrace
> Purpose:
  | If this is TRUE, then X event tracing is enabled.  Only available if 'DEBUG' is defined.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: toplevel_app_shell
  $ Widget toplevel_app_shell
> Purpose:
  | This is the top level widget for the application to which all other widgets (and heirarchies of widgets) are added.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: app_context
  $ XtAppContext app_context
> Purpose:
  | The application context associated with the application.  Fallback resources and such are set within the applicationContext
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: display
  $ Display* display
> Purpose:
  | This is the X Display that is associated with the application context.  Windows and other widgets are typically associated with a Display.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TRUE
  $ #define TRUE
> Purpose:
  | Convienience macro to define a success.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FALSE
  $ #define FALSE
> Purpose:
  | Convienience macro to define a failure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENVIRONSIZE
  $ #define ENVIRONSIZE
> Purpose:
  | Default size of env/trail stack.  UNUSED.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CHOICEPTSIZE
  $ #define CHOICEPTSIZE
> Purpose:
  | Default size of heap/cp stack.  UNUSED.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
