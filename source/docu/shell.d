#if 0
----------------------------------------------------------------------
> Global Function: getSetup ;
  $ voidgetSetup ()
> Purpose:
  | This function reads configuration data and sets HEAPSIZE and ENVSIZE.
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
> Global Function: initialTest ;
  $ BNRP_BooleaninitialTest (TCB*)
> Purpose:
  | This function is used to determine if the stack is long word aligned.  If it is not long word aligned, it may affect performance
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
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
> Global Function: main ;
  $ intmain (int, char**)
> Purpose:
  | This is the main line function for the BNR Prolog development environment.  It sets up the application to run and executes the initial predicate to start the BNRProlog engine.  Once BNRP_RESUME returns, it prints out some statistics and if the engine exited with an error, it prints out the error and a trace of the call stack.  The argc and argv arguements are sent to BNRP_initializeRing5() for processing.
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = int argc
  = char** argv - XXXXX_G_PAR
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
> Data Item: progname
  $ char* progname
> Purpose:
  | This is set to base.a and is used by Macintosh's using THINK C.  It specifies the file containing the base context.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: HEAPSIZE
  $ long HEAPSIZE
> Purpose:
  | This is the default size of the heap in Kb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ENVSIZE
  $ long ENVSIZE
> Purpose:
  | This is the default size of the environment stack in Kb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: tcb
  $ TCB tcb
> Purpose:
  | This is the initial Task control block used to execute the initial predicate.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
