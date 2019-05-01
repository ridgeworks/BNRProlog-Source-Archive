#if 0
----------------------------------------------------------------------
> Global Function: main ;
  $ main (unsigned int, char*[])
> Purpose:
  | This is the main function for the X version of BNRProlog.  It initializes the Xt Toolkit, sets up the X error handler, and initializes the Prolog Engine and start it.
> Calling Context:
  | 
> Return Value:
  | No return value...
> Parameters:
  = unsigned int argc
  = char*[] argv - XXXXX_G_PAR
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
> Global Function: myErrorHandler ;
  $ intmyErrorHandler (Display*, XErrorEvent*)
> Purpose:
  | This is the error handler that is used when an X error occurs.  If DEBUG is defined, then this will print out some debug information about the error that occured.  If DEBUG isn't defined, then this function does nothing.
> Calling Context:
  | 
> Return Value:
  | int - doesn't return anything.
> Parameters:
  = Display* display - Display that the error occured on
  = XErrorEvent* err - Error that occured
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
> Global Function: InitProlog ;
  $ intInitProlog (unsigned int, char**)
> Purpose:
  | This reads the configuration data and initializes the Task Control Block to be used.  It then intializes the rings and loads base.a.  It then executes the goal 'pde_init' which sets up the Prolog development environment.  this function does not return until an unrecoverable error occurs inside of Prolog or the user executes the 'quit' goal (or failexit(listener)).
> Calling Context:
  | 
> Return Value:
  | int - return value of BNRP_execute().  (See External Interface Guide)
> Parameters:
  = unsigned int argc - number of command line arguements
  = char** argv - array of command line arguements.
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
> Data Item: tcb
  $ BNRP_TCB tcb
> Purpose:
  | Task control block to be used in main().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENVIRONSIZE
  $ #define ENVIRONSIZE
> Purpose:
  | This is the default size of the env/trail stack if the one specified in .bnrprologrc is less than zero or the file is non-existant.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CHOICEPTSIZE
  $ #define CHOICEPTSIZE
> Purpose:
  | This is the default size of the heap/cp stack if the one specified in .bnrprologrc is less than zero or the file is non-existant.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
