#if 0
----------------------------------------------------------------------
> Struct:
  | arith
  $ struct arith
> Purpose:
  | This structure is used to hold an arithmetic operation.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = lf value - value of the operation
  = long type - Type of operation being performed
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: abortHandler ;
  $ voidabortHandler (int)
> Purpose:
  | This is the standard interrupt handler which sets a flag indicating that an interrupt has occured for processing within BNRP_RESUME.  It also flushes stdin.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int sig - signal that occured (usually SIGINT)
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
> Global Function: arithHandler ;
  $ voidarithHandler (int)
> Purpose:
  | This is the standard floating point exception handler.  It generates an ARITHERROR in BNRP_RESUME().
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int sig - signal that occured (usually SIGFPE)
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
> Global Function: traceit ;
  $ voidtraceit (char*, ...)
> Purpose:
  | This copies a tracing message into BNRP_trace.  It takes a variable number of arguements, the first being the format into which to print the rest of the arguements into.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* format - format to print the rest of the arguements into
  = ... ellipsis - a variable number of variables to be printed
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
> Global Function: BNRP_error ;
  $ voidBNRP_error (long)
> Purpose:
  | This generates error err in BNRP_RESUME.  If BNRPerrorHandler() is not NULL, then it is executed before jumping into the error/termination section of BNRP_RESUME.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long err - Prolog error code
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
> Global Function: BNRP_quit ;
  $ BNRP_BooleanBNRP_quit (TCB*)
> Purpose:
  | This is the quit primitive for BNR Prolog.  It jumps back into the error/termination handling section of BNRP_RESUME()
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - task control block
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
> Global Function: BNRP_CheckAlignment ;
  $ longBNRP_CheckAlignment ()
> Purpose:
  | This function is only applicable if the assembler core for Macintosh is being used.  shell.c calls this for the Macintosh.
> Calling Context:
  | 
> Return Value:
  | long - returns 0.
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
> Global Function: resetCritical ;
  $ voidresetCritical (TCB*)
> Purpose:
  | This resets the criticalenv and criticalhp pointers to be either the heapbase and envbase if there aren't any choicepoints or to the last choicepoint's heap pointer and critical env pointer.  It also cleans up the trail.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Task control block
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
> Global Function: corebind ;
  $ voidcorebind (long, long)
> Purpose:
  | Binds two terms together and pushes any of val's constraints onto the heap and fires them.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long val - term
  = long newval - term that val will be bound to.
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
> Global Function: corebindtohp ;
  $ longcorebindtohp (long, long)
> Purpose:
  | Binds a term to the end of the heap.  If the term is constrained, then the constraints are fired prior to binding the term to the heap.
> Calling Context:
  | 
> Return Value:
  | long - Returns the term
> Parameters:
  = long val - term to be bound to the end of the heap
  = long tags - tag of the term
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
> Global Function: corebindVV ;
  $ voidcorebindVV (long, long)
> Purpose:
  | Binds two variables together.  If the variables are constrained then the constraint lists are concatenated.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long var1
  = long var2 - XXXXX_G_PAR
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
> Global Function: corebindTVTV ;
  $ voidcorebindTVTV (long, long)
> Purpose:
  | Binds two tail variables together.  If the variables are constrained then 
  | the constraint lists are concatenated.  The constraints belonging to the
  | newer term (higher on the heap) will be at the start of the new list.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long var1 - tail variable term to be bound
  = long var2 - tail variable term to be bound
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
> Global Function: coreUnifyList ;
  $ BNRP_BooleancoreUnifyList (long, long)
> Purpose:
  | Unifies two lists on the heap.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = long list1 - first term of a list
  = long list2 - first term of a list
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
> Global Function: coreUnify ;
  $ BNRP_BooleancoreUnify (long, long)
> Purpose:
  | Unifies two arbitrary terms, t1 and t2, on the heap.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = long t1 - a term
  = long t2 - a term
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
> Global Function: makeSafe ;
  $ longmakeSafe (long*, long)
> Purpose:
  | Makes a permanent environment term safe. If the term is a variable, it makes a
  | new variable on the heap and binds the two together, returning the new heap variable.  If the environment term is not a variable, then it is already safe and it is returned.  If it is a variable, we check that it is not below the
  | address limit.
> Calling Context:
  | 
> Return Value:
  | long
> Parameters:
  = long* value - environment term to be made safe.
  = long limit - address to not check below.
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
> Global Function: pushUnsafe ;
  $ voidpushUnsafe (long)
> Purpose:
  | Pushes an unsafe permanent term from the environment onto the heap and binds the two together if the term is a variable.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long value - term from the environment to be pushed onto the heap.
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
> Global Function: NextClause ;
  $ clauseEntry*NextClause (clauseEntry*, long, long)
> Purpose:
  | This returns the next cause entry ofthe same key and arity.
> Calling Context:
  | 
> Return Value:
  | clauseEntry* - Next clause of matching arity and key.
> Parameters:
  = clauseEntry* p - the current clause being used.
  = long key - the key ofthe current clause
  = long arity - the arity of the current clause
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
> Global Function: BNRP_RESUME ;
  $ longBNRP_RESUME (TCB*)
> Purpose:
  | This is the BNR Prolog engine.  It is based on Warren Abstract Machine with some extensions to provide more specialized functionality.  On success it returns 0.  If the predicate failed then -1 is returned, otherwise a Prolog error code is returned.
> Calling Context:
  | 
> Return Value:
  | long
> Parameters:
  = TCB* tcb - a task control block into which  goal has been embedded.
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
> Data Item: ppc
  $ long ppc
> Purpose:
  | Stores the current Prolog program counter of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ce
  $ long ce
> Purpose:
  | Stores the pointer to the current environment in the environment stack.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: envbase
  $ long envbase
> Purpose:
  | Stores the pointer to the base of the environment stack.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cp
  $ long cp
> Purpose:
  | Stores the continuation pointer of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: hp
  $ long hp
> Purpose:
  | Stores the current position of a tcb's heap pointer.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: heapbase
  $ long heapbase
> Purpose:
  | Stores the heap base pointer of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: stp
  $ long stp
> Purpose:
  | Stores the stack pointer of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: te
  $ long te
> Purpose:
  | Stores the trail end of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cutb
  $ choicepoint* cutb
> Purpose:
  | Stores the cutback choicepoint of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: lcp
  $ choicepoint* lcp
> Purpose:
  | Stores the last choicepoint of the tcb.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: criticalenv
  $ long criticalenv
> Purpose:
  | Stores the critical environment pointer.  This is either the env pointer of the last choicepoint, or the env base if there aren't any choicepoints.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: criticalhp
  $ long criticalhp
> Purpose:
  | Used to store the critical heap pointer.  This is either the heap pointer of the last choicepoint, or the heapbase if there aren't any choicepoints.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: emptyList
  $ long emptyList
> Purpose:
  | Used to store the tcb's emptyList.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: regs
  $ long* regs
> Purpose:
  | Used to store the tcb's arguement list.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: specialError
  $ long specialError
> Purpose:
  | Holds the Prolog level error that occured.  Used in BNRP_RESUME().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPconstraintHeader
  $ long BNRPconstraintHeader
> Purpose:
  | Marks the start of the constaint queue.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPconstraintEnd
  $ long BNRPconstraintEnd
> Purpose:
  | This marks the end of the constraint queue
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ar
  $ arith[MAX_ARITH] ar
> Purpose:
  | This arith structure is the stack of pending arithmetic operations.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: jumpbuf
  $ jmp_buf jumpbuf
> Purpose:
  | This jump buffer is used to jump back into BNRP_RESUME when an error occurs.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: oldSigIntHandler
  $ void(*)() oldSigIntHandler
> Purpose:
  | Holds the interupt signal handler that existed prior to the BNRP handler being installed in BNRP_RESUME.  This is re-established when we leave BNRP_RESUME.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: oldSigFpeHandler
  $ void(*)() oldSigFpeHandler
> Purpose:
  | Holds the floating point exception signal handler that existed prior to the BNRP handler being installed in BNRP_RESUME.  This is re-established when we leave BNRP_RESUME.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_trace
  $ char[TRACESIZE] BNRP_trace
> Purpose:
  | This string carries a tracing message to be printed out.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DEBUGSTR
  $ #define DEBUGSTR (s)
> Purpose:
  | Macro for Mac MPW to print out a debug string s.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DEBUGSTR
  $ #define DEBUGSTR (s)
> Purpose:
  | Macro for Mac MPW to print out a debug string s.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: gc_proceed
  $ #define gc_proceed
> Purpose:
  | Flag to allow garbage collection on proceeds and cutexec calls
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: cutordebug
  $ #define cutordebug
> Purpose:
  | Debug flag for cuts.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: callordebug
  $ #define callordebug
> Purpose:
  | Debug flag for calls.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: cutordebug
  $ #define cutordebug
> Purpose:
  | Debug flag for cuts.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: callordebug
  $ #define callordebug
> Purpose:
  | Debug flag for calls.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: executiontrace
  $ #define executiontrace
> Purpose:
  | Debug flag for tracingthe execution of code.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NOOP
  $ #define NOOP
> Purpose:
  | Macro specifying the noop opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ERROR
  $ #define ERROR (err)
> Purpose:
  | Macro that jumps into the error handling area of BNRP_RESUME with error err.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ERROREXIT
  $ #define ERROREXIT
> Purpose:
  | Error code specifying a user error
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: QUIT
  $ #define QUIT
> Purpose:
  | Error code specifying that the quite primitive was called.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trail
  $ #define trail (te, addr)
> Purpose:
  | Pushes an item onto the trail.  addr is the address of a term and te is the trail end
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: untrail
  $ #define untrail (te, addr)
> Purpose:
  | Removes an item (addr - address of a term) from the trail queue (te - trail end).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: e
  $ #define e (P)
> Purpose:
  | Gets the current environment contents at offset P.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: bind
  $ #define bind (val, newval)
> Purpose:
  | This macro binds one term to another in the heap or the environment depending on where the terms are.  val is stored on the trail.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | This macro checks to make sure there is room for n items on the heap.  If not, it reports a HEAPOVERFLOW error.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TRACESIZE
  $ #define TRACESIZE
> Purpose:
  | Maximum size of the tracing string.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LoadRegisters
  $ #define LoadRegisters ()
> Purpose:
  | Load some of the control variables of tcb into BNRP_RESUME's local variables.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SaveRegisters
  $ #define SaveRegisters (arity)
> Purpose:
  | Save a variety of the control variables in BNRP_RESUME back into tcb.  arity is the arity of the predicate contained in args.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: popresult
  $ #define popresult (val)
> Purpose:
  | This is the debug version of popresult which prints out the result of an arithmetic operation as well as the standard popresult functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: popresult
  $ #define popresult (val)
> Purpose:
  | Put the term representing the result of an arithmetic operation onto the heap and return it in val.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: binaryoplfff
  $ #define binaryoplfff (op)
> Purpose:
  | Perform a binary arithmetic operation (eg. plus).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: unaryopfloat
  $ #define unaryopfloat (op)
> Purpose:
  | Perform a unary arithmetic operation (eg. tan) on floats.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: unaryopint
  $ #define unaryopint (op)
> Purpose:
  | Perform a unary arithmetic operation (eg tan) on integers.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: compareop
  $ #define compareop (op)
> Purpose:
  | Perform a comparative arithmetic operation
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: unaryarithop
  $ #define unaryarithop (a)
> Purpose:
  | Sets up for a unary meta arithmetic operation such as tan.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: binaryarithop
  $ #define binaryarithop (a)
> Purpose:
  | Sets up for a binary meta arithmetic operation (ie. addition)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: comparearithop
  $ #define comparearithop (a)
> Purpose:
  | Sets up for a comparative meta arithmetic operation (ie. < ).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: constantarithop
  $ #define constantarithop (a)
> Purpose:
  | Sets up for a constant meta arithmetic operation
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: T
  $ #define T
> Purpose:
  | Used as a notational index into temporary terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: P
  $ #define P
> Purpose:
  | Used as a notational index into permanent terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | clauseEntry
  $ struct clauseEntry
> Purpose:
  | This structure holds the information related to clauses
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long key - A key value used for fast comparing of clauses
  = clauseEntry* nextClause - next clause in the clause chain
  = clauseEntry* nextSameKeyClause - next clause in chain of clauses of the 	same key (clauses of the same name)
  = long arity - number of arguements that the clause has.
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | symbolEntry
  $ struct symbolEntry
> Purpose:
  | This structure is used to hold all of a symbol's information.  It is stored inside the various symbol tables.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = clauseEntry* firstClause - start of the clause chain associated with the 				symbol (if any)
  = symbolEntry* chain - next symbol in the chain of symbols
  = symbolEntry* self - pointer to self
  = short opType - operator type associated with the symbol (ie. xf, etc)
  = short opPrecedence - The precedence of the symbol if it is an operator
  = unsigned char locked - This is set if the symbol is related to a clause
  = and it's in the locked state.
  = unsigned char closed - This is set if the symbol is related to a clause 		and it's in the closed state
  = short debug - This is set if the symbol is related to a clause and if it is being traced.
  = unsigned char inuse - Holds the usage information of the symbol entry.
  = unsigned char hash - hash value of the symbol.  Used for cheaper lookups
  = char[] name - name of the symbol
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | choicepoint
  $ struct choicepoint
> Purpose:
  | This structure holds all the information needed to implement the concept of choicepoints and backtracking.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long clp - points to the next clause that could be executed
  = long key - key for the next clause acess
  = long critical - end of previous environment which is used for trailing
  = long hp - heap pointer
  = choicepoint* lcp - previous choicepoint.  Used for chaining choicepoints.
  = long te - trail end.
  = long bce - start of previous environment
  = long bcp - continuation
  = long procname - name of procedure to restore
  = long[] args - The procedure's arguements.  args[0] holds number of args.  See numRegs.
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Enumeration:
  | TAG
  $ enum TAG {ENDT, VART, TAILVART, INTT, FLOATT, SYMBOLT, LISTT, STRUCTT}
> Purpose:
  = This is used to hold the more abstract version of the tag values of the various terms.  It's also used for compares.
> Tags:
  = ENDT - End of list/structure
  = VART - variable tag
  = TAILVART - tail variable tag
  = INTT - integer tag
  = FLOATT - floating point number tag
  = SYMBOLT - symbol tag
  = LISTT - list tag
  = STRUCTT - structure tag
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | clauseEntry
  $ typedef clauseEntry clauseEntry
> Purpose:
  | Type definition of the clauseEntry structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | symbolEntry
  $ typedef symbolEntry symbolEntry
> Purpose:
  | Type defintion of the symbolEntry definition.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Typedef:
  | hoicepoint
  $ typedef choicepoint choicepoint
> Purpose:
  | Type definition of the choicepoint structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Typedef:
  | AG
  $ typedef TAG TAG
> Purpose:
  | This type is used to hold the more abstract definition of a term's tag value.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_core
  $ #define _H_core
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VARMASK
  $ #define VARMASK
> Purpose:
  | Mask used to identify variable terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VARTAG
  $ #define VARTAG
> Purpose:
  | Tag used for variable terms.  Maps to VARMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TAILVARMASK
  $ #define TAILVARMASK
> Purpose:
  | Mask used to identify tail variable terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TAILVARTAG
  $ #define TAILVARTAG
> Purpose:
  | Tag used for tail variable terms.  Maps to TAILVARMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TVTAG
  $ #define TVTAG
> Purpose:
  | Tag used for tail variable terms.  Maps to TAILVARMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LISTMASK
  $ #define LISTMASK
> Purpose:
  | Mask used to identify list terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LISTTAG
  $ #define LISTTAG
> Purpose:
  | Tag used for list terms.  Maps to LISTMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STRUCTMASK
  $ #define STRUCTMASK
> Purpose:
  | Mask used to identify structure terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STRUCTTAG
  $ #define STRUCTTAG
> Purpose:
  | Tag used for structure terms.  Maps to STRUCTMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INTMASK
  $ #define INTMASK
> Purpose:
  | Mask used to identify integer terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INTTAG
  $ #define INTTAG
> Purpose:
  | Tag used for integer terms.  Maps to INTMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SYMBOLMASK
  $ #define SYMBOLMASK
> Purpose:
  | Mask used to identify symbol terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SYMBOLTAG
  $ #define SYMBOLTAG
> Purpose:
  | Tag used for symbol terms.  Maps to SYMBOLMASK.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isVAR
  $ #define isVAR (x)
> Purpose:
  | Determines if x is a variable.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isTV
  $ #define isTV (x)
> Purpose:
  | Determines if x is a tail variable.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STRUCTHEADER
  $ #define STRUCTHEADER
> Purpose:
  | Standard structure header.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNARYHEADER
  $ #define UNARYHEADER
> Purpose:
  | Structure header of a structure with a single component.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BINARYHEADER
  $ #define BINARYHEADER
> Purpose:
  | Structure header of a structure with 2 components.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FUNCID
  $ #define FUNCID
> Purpose:  | 
  | Maps to STRUCTHEADER and is used to identify structures of 0 arity.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FUNCIDshort
  $ #define FUNCIDshort
> Purpose:
  | Short form of the structure identifier.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NUMBERID
  $ #define NUMBERID
> Purpose:
  | This is put into the structure header of numbers for identification purposes.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NUMBERIDshort
  $ #define NUMBERIDshort
> Purpose:
  | Identifier for number when they are pushed into li structures (li.i.b).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INTIDshort
  $ #define INTIDshort
> Purpose:
  | Identifier for integers when they are pushed into li structures (li.i.b).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INTID
  $ #define INTID
> Purpose:
  | This is placed in the structure header of integers for identification purposes.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FLOATIDshort
  $ #define FLOATIDshort
> Purpose:
  | Identifier for floats when they are pushed into li structures (li.i.b).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FLOATID
  $ #define FLOATID
> Purpose:
  | This is placed in the structure header of floats to identify them later on.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CONSTRAINTMARK
  $ #define CONSTRAINTMARK
> Purpose:
  | Marks a constrained variable.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VARIABLEMARK
  $ #define VARIABLEMARK
> Purpose:
  | Mark used in varaible entries to specify a variable.  Useful if you aren't sure that the received structure is a variableEntry.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: notOp
  $ #define notOp
> Purpose:
  | An opType value used in symbol entries to specify a non-operator symbol.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xf
  $ #define xf
> Purpose:
  | Nonassociative postfix operator optype.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yf
  $ #define yf
> Purpose:
  | Right to left associative postfix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fy
  $ #define fy
> Purpose:
  | Left to right associative prefix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fx
  $ #define fx
> Purpose:
  | Nonassociative prefix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yfx
  $ #define yfx
> Purpose:
  | Left to right associative infix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xfy
  $ #define xfy
> Purpose:
  | Right to left associative infix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xfx
  $ #define xfx
> Purpose:
  | Nonassociative infix operator opType.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: bracket
  $ #define bracket
> Purpose:
  | bracket operator opType.  This is used to help with precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNUSED
  $ #define UNUSED
> Purpose:
  | Mark for an unused symbol entry
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INUSE
  $ #define INUSE
> Purpose:
  | Mark for a used permanent global symbol entry
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INUSELOCAL
  $ #define INUSELOCAL
> Purpose:
  | Mark for a used permanent local symbol entry.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INUSETEMPGLOBAL
  $ #define INUSETEMPGLOBAL
> Purpose:
  | Mark for a used temporary global symbol entry.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INUSETEMPLOCAL
  $ #define INUSETEMPLOCAL
> Purpose:
  | Mark for a used temporary local symbol entry.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: symof
  $ #define symof (index)
> Purpose:
  | Returns the symbol value of an address index.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: checksym
  $ #define checksym (index, s)
> Purpose:
  | Puts the symbol value of an adress index into s and verifies the sanity of the symbol.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nameof
  $ #define nameof (index)
> Purpose:
  | Gets the character string name of a symbol.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: numRegs
  $ #define numRegs
> Purpose:
  | TCB macro to get the number of arguements of the procedure being restored in a choicepoint structure.  See choicepoint.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NAME
  $ #define NAME
> Purpose:
  | Environement name offset into the environment.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CUTB
  $ #define CUTB
> Purpose:
  | Cut point offset into the environment.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CE
  $ #define CE
> Purpose:
  | Current environment offset into the environment.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CP
  $ #define CP
> Purpose:
  | Choicepoint offset into the environment
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: env
  $ #define env (e, offset)
> Purpose:
  | This macro returns the contents of the environment e offset by "offset".
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTOFCHOICEPOINTS
  $ #define OUTOFCHOICEPOINTS
> Purpose:
  | Runtime error indicating that the system has run out of choicepoints and that the goal given the engine has failed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DANGLINGREFERENCE
  $ #define DANGLINGREFERENCE
> Purpose:
  | Runtime error indicatingthat there is a reference to a term that no longer exists.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNEXECUTABLETERM
  $ #define UNEXECUTABLETERM
> Purpose:
  | Runtime error indicating that the system has come across an unexecutable term.  This could be due to the fact that the term has too many arguements, or if it is of the wrong type, etc.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTOFMEMORY
  $ #define OUTOFMEMORY
> Purpose:
  | Runtime erro indicating an exhaustion of memory resources.  Is one of: STATESPACENOMEMORY, CONTEXTFULL, LOADNOSPACE, LOADTOOMANYSYMBOLS. LOADNOTEMPSPACE, OUTOFTEMPSPACE, or OUTOFAMSPACE.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACENOMEMORY
  $ #define STATESPACENOMEMORY
> Purpose:
  | Runtime error indicating that additional space in the statespace could not be allocated.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CONTEXTFULL
  $ #define CONTEXTFULL
> Purpose:
  | Runtime error indicating that additional space could not be alloated for the context.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOADNOSPACE
  $ #define LOADNOSPACE
> Purpose:
  | Unused runtime error that maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOADTOOMANYSYMBOLS
  $ #define LOADTOOMANYSYMBOLS
> Purpose:
  | Runtime error indicating that an attempt to load too many symbols was made or that an invalid symbol was found.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOADNOTEMPSPACE
  $ #define LOADNOTEMPSPACE
> Purpose:
  | Runtime error indicating that temporary space could not be allocated.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTOFTEMPSPACE
  $ #define OUTOFTEMPSPACE
> Purpose:
  | Runtime error indicating that temporary space could not be grown.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTOFAMSPACE
  $ #define OUTOFAMSPACE
> Purpose:
  | Runtime error indicating that more AM space could not be allocated.  Maps to OUTOFMEMORY.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GLOBALSTACKOVERFLOW
  $ #define GLOBALSTACKOVERFLOW
> Purpose:
  | Runtime error indicating that either a HEAPOVERFLOW or a TRAILOVERFLOW error has occured.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: HEAPOVERFLOW
  $ #define HEAPOVERFLOW
> Purpose:
  | Runtime error indicating that a heap stack overflow has occured.  This maps to GLOBALSTACKOVERFLOW.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TRAILOVERFLOW
  $ #define TRAILOVERFLOW
> Purpose:
  | Runtime error indicating that the trail stack has overflowed.  This maps to GLOBALSTACKOVERFLOW.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOCALSTACKOVERFLOW
  $ #define LOCALSTACKOVERFLOW
> Purpose:
  | Runtime error indicating that a local stack overflow has occured.  This is either an ENVOVERFLOW or a CPOVERFLOW.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENVOVERFLOW
  $ #define ENVOVERFLOW
> Purpose:
  | Runtime error indicating that an environment stack overflow has occured.  This maps to LOCALSTACKOVERFLOW.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CPOVERFLOW
  $ #define CPOVERFLOW
> Purpose:
  | Runtime error indicating that a choicepoint stack overflow has occured.  This maps to LOCALSTACKOVERFLOW.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NAMEDCUTNOTFOUND
  $ #define NAMEDCUTNOTFOUND
> Purpose:
  | Runtime error indicating that the name indicated in a cut was not found.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DIVIDEBY0
  $ #define DIVIDEBY0
> Purpose:
  | Runtime error indicating that an attempt to divide by zero was made.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ARITHERROR
  $ #define ARITHERROR
> Purpose:
  | Runtime error indicating that an arithmetic error has occured.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACECORRUPT
  $ #define STATESPACECORRUPT
> Purpose:
  | Runtime error indicating that one of the following state space corruptions occured: STATESPACEBADALLOC, STATESPACEBADFREELIST, STATESPACEBADRING, STATESPACEBADTAG, STATESPACENOSTRING, or STATESPACEBADOPCODE.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACEBADALLOC
  $ #define STATESPACEBADALLOC
> Purpose:
  | Unused runtime error that maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACEBADFREELIST
  $ #define STATESPACEBADFREELIST
> Purpose:
  | Unused runtime error that maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACEBADRING
  $ #define STATESPACEBADRING
> Purpose:
  | Runtime error indicating that there are lingering clauses to a symbol in a statespace ring or that the ring is corrupt.  Maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACEBADTAG
  $ #define STATESPACEBADTAG
> Purpose:
  | Runtime error indicating that a state space object has a bad tag value.  This error maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACENOSTRING
  $ #define STATESPACENOSTRING
> Purpose:
  | Runtime error indicating that the system could not allocate space in the state space for the string or that it could not find the string.  Maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACEBADOPCODE
  $ #define STATESPACEBADOPCODE
> Purpose:
  | Unused runtime error that maps to STATESPACECORRUPT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACELOOP
  $ #define STATESPACELOOP
> Purpose:
  | Runtime error indicating that there is a looped functor in state space.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INTERNALERROR
  $ #define INTERNALERROR
> Purpose:
  | Runtime error that specifies that one of the following error occured: INVALIDSYMBOLINCALL, BADSTATESPACEHEADER, or NOPROCEDUREDEFINED.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INVALIDSYMBOLINCALL
  $ #define INVALIDSYMBOLINCALL
> Purpose:
  | Runtime error indicating that a clause was defined for a non-symbol or that an invalid symbol reference occured.  This maps to INTERNALERROR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BADSTATESPACEHEADER
  $ #define BADSTATESPACEHEADER
> Purpose:
  | Unused runtime error that maps to INTERNALERROR.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NOPROCEDUREDEFINED
  $ #define NOPROCEDUREDEFINED
> Purpose:
  | Unused runtime error that maps to INTERNALERROR..
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATESPACETOOBIG
  $ #define STATESPACETOOBIG
> Purpose:
  | Runtime error indicating that the object being put into state space is too big.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CLOSEDCLAUSE
  $ #define CLOSEDCLAUSE
> Purpose:
  | Runtime error indicating a failure to add a clause due to it being closed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: IOERROR
  $ #define IOERROR
> Purpose:
  | I/O error indicating that an unknown I/O error occured
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNABLETOCLOSESTREAM
  $ #define UNABLETOCLOSESTREAM
> Purpose:
  | I/O error indicating that the system was unable to close a stream.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STREAMNOTOPEN
  $ #define STREAMNOTOPEN
> Purpose:
  | I/O error indicating that the given stream is not open for reading or writing.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BADFILENAME
  $ #define BADFILENAME
> Purpose:
  | I/O error indicating that a bad file name was received.  Typically because it can't find the file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NOMORE
  $ #define NOMORE
> Purpose:
  | Prolog syntax error indicating that it was expecting more terms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNEXPECTEDEOF
  $ #define UNEXPECTEDEOF
> Purpose:
  | Prolog syntax error indicating an unexpected end-of-file
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MISSINGOPERAND
  $ #define MISSINGOPERAND
> Purpose:
  | Prolog syntax error indicating that an operand is missing
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BADCHARACTER
  $ #define BADCHARACTER
> Purpose:
  | Prolog syntax error indicating that the wrong type of character has turned up
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BADTAILVAR
  $ #define BADTAILVAR
> Purpose:
  | Prolog syntax error indicating that it was unable to convert the term to a tailvariable.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MISSINGOPERATOR
  $ #define MISSINGOPERATOR
> Purpose:
  | Prolog syntax error indicating that an operator is missing
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BRACKETMISMATCH
  $ #define BRACKETMISMATCH
> Purpose:
  | Prolog syntax error indicating a bracket mismatch.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NOMOREOPCHOICES
  $ #define NOMOREOPCHOICES
> Purpose:
  | Prolog syntax error indicating that there are no more type choices for an operator.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NOTPREFIXOP
  $ #define NOTPREFIXOP
> Purpose:
  | Prolog syntax error indicating that the specified operator is not a prefix operator.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: KILLED
  $ #define KILLED
> Purpose:
  | Prolog syntax error indicating that the parsing process has been killed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INCOMPLETE
  $ #define INCOMPLETE
> Purpose:
  | Prolog syntax error indicating that a bracketed expression is incomplete.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SYNTAX
  $ #define SYNTAX
> Purpose:
  | Prolog syntax error indicating that a syntax error occured...
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNEXPECTEDACTION
  $ #define UNEXPECTEDACTION
> Purpose:
  | Prolog syntax error indicating that an unexpected parsing action was specified.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TOOMANYARGS
  $ #define TOOMANYARGS
> Purpose:
  | Prolog syntax error indicating that a term has too many arguements
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MISMATCHEDBRACKETS
  $ #define MISMATCHEDBRACKETS
> Purpose:
  | Prolog syntax error indicating that there are mismatched brackets.  (too many open brackets or too many close brackets)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BADINTEGER
  $ #define BADINTEGER
> Purpose:
  | Prolog syntax error indicating that it could not convert a string to it's integer value.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VERTICALNOTINLIST
  $ #define VERTICALNOTINLIST
> Purpose:
  | Prolog syntax error indicating a bad Edinburgh list construction
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: UNRECOGNIZEDOPTYPE
  $ #define UNRECOGNIZEDOPTYPE
> Purpose:
  | Prolog syntax error indicating that the parser has come accross and unidentified operator type
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: COMMENTNOTCOMPLETE
  $ #define COMMENTNOTCOMPLETE
> Purpose:
  | Prolog syntax error indicating an incomplete comment statement
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: onerrorexecute
  $ #define onerrorexecute (p)
> Purpose:
  | Sets the error handler to be p.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: envExtension
  $ #define envExtension
> Purpose:
  | Size of an enviroment extension
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_ARITH
  $ #define MAX_ARITH
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
