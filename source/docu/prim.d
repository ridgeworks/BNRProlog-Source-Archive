#if 0
----------------------------------------------------------------------
> Global Function: BNRPBindPrimitive ;
  $ BNRP_BooleanBNRPBindPrimitive (char*, BNRP_Boolean(*)())
> Purpose:
  | This function binds a C primitive function to a name.  It first changes name into a symbol and then adds a clause using 'address' and the symbol form of 'name'
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = char* name - Name of symbol to be associated with the function
  = BNRP_Boolean(*)() address - a primitive function
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
> Global Function: BNRP_eCut ;
  $ BNRP_BooleanBNRP_eCut (TCB*)
> Purpose:
  | This primitive handles edinburgh cuts when they are meta-interpreted.  It skips '->' and ';' calls as well as any calls used by the meta-interpreter when searching through the environments.
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
> Global Function: BNRP_fixCutb ;
  $ BNRP_BooleanBNRP_fixCutb (TCB*)
> Purpose:
  | This primitive fixes the cutb register when a 'cut' or a failexit is performed.  It looks for the first indirectAtom in the environment blocks and sets the cutb register to be the one stored in that environment block.  Also sets the current environment cutb to be this as well.
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
> Global Function: BNRP_errorTraceback ;
  $ voidBNRP_errorTraceback (TCB*)
> Purpose:
  | This function is only used in the assembly version of BNRP_RESUME as the C version does this inline.  When an error occurs it prints out the traceback of the calls into BNRP_lastErrorTraceback.
> Calling Context:
  | 
> Return Value:
  | void
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
> Global Function: BNRP_traceback ;
  $ voidBNRP_traceback (TCB*, long)
> Purpose:
  | This function prints out the names of the top numItems calls on the environment stack.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long numItems - Number of environment blocks to go through
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
> Global Function: BNRP_choicepoints ;
  $ voidBNRP_choicepoints (TCB*, long)
> Purpose:
  | This function prints out the names of the top numItems of the choicepoint stack
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - task control block pointer
  = long numItems - number of choicepoints to print out.
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
> Global Function: BNRP_goal ;
  $ BNRP_BooleanBNRP_goal (TCB*)
> Purpose:
  | This primitive returns the ancestor of the given goal.  It takes 3 arguements which are:
  | 		- Pointer into environment stack (0 for current environment)
  | 		- Name of the ancestor goal (filled in by predicate)
  | 		- Pointer to the ancestor goal (filled in by predicate)
  | If the first arguement is zero, then the ancestor of this primitive is returned.
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
> Global Function: BNRP_doGetErrorCode ;
  $ BNRP_BooleanBNRP_doGetErrorCode (TCB*)
> Purpose:
  | This primitive returns the last error generated as the first arguement and the associated traceback string as the second arguement.  If this call is made with a single arguement, only the error number is returned.
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
> Global Function: BNRP_doError ;
  $ BNRP_BooleanBNRP_doError (TCB*)
> Purpose:
  | This primitive takes a single arguement which is the error to be generated.  This error is then generated in BNRP_RESUME().
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
> Global Function: getCPUTime ;
  $ longgetCPUTime ()
> Purpose:
  | This predicate returns the amount of cpu time that the application has used.
> Calling Context:
  | 
> Return Value:
  | long - amount of cpu time used by the application.
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
> Global Function: BNRP_getAddress ;
  $ BNRP_BooleanBNRP_getAddress (TCB*)
> Purpose:
  | This primitive takes the name and address of a clause and returns the address of the next associated clause as the third arguement.  The first arguement is the clauses symbolic name which the primitive uses to get the clause chain associated with that symbol.  It then searches for the address (second arguement) in that chain returning the next clause.
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
> Global Function: BNRP_getArity ;
  $ BNRP_BooleanBNRP_getArity (TCB*)
> Purpose:
  | This primitive returns the arity of a clause.  The first arguement is an integer which is presumed to be a pointer to a clauseEntry.  The second arguement gets bound to the arity of the clause.
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
> Global Function: BNRP_newCounter ;
  $ BNRP_BooleanBNRP_newCounter (TCB*)
> Purpose:
  | This primitive creates a new counter on the heap.  The first arguement is the initial value of the counter while the second is a variable which gets unified with $counter($counter(INTEGER)) where integer is the first arguement.
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
> Global Function: BNRP_incrCounter ;
  $ BNRP_BooleanBNRP_incrCounter (TCB*)
> Purpose:
  | This primitive increments a counter.  It takes a single arguement which is a structure that looks like $counter($counter(INTEGER)).  The primitive increments INTEGER.
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
> Global Function: BNRP_freeze ;
  $ BNRP_BooleanBNRP_freeze (TCB*)
> Purpose:
  | This primitive takes two arguements.  The first is the variable or a tail variable that the freeze constraint is to be put on, and the second is the goal to be executed when the variable becomes bound.  If the first arguement contains is bound then the constraints are fired immediately, otherwise they are added to the variables list of constraints.
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
> Global Function: BNRP_joinVar ;
  $ BNRP_BooleanBNRP_joinVar (TCB*)
> Purpose:
  | This primitive binds two variables together, and associates a list of constraints with the newly created variable.  The first two arguements are the variables to be joined and the third arguement is the list of constraints to be associated with the new variable.  If the third arguement is a variable, then FALSE is returned.
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
> Global Function: BNRP_name ;
  $ BNRP_BooleanBNRP_name (TCB*)
> Purpose:
  | This primitve takes two arguements the first being a string/variable and the second being a list of integers or a variable.  If the firt arguement is a symbol, then it is translated to it's ASCII encoding as a list of integers (one integer per character).  If the first arguement is a variable and the second is a list of integers, then it is translated into a symbol.
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
> Global Function: BNRP_concat ;
  $ BNRP_BooleanBNRP_concat (TCB*)
> Purpose:
  | This primitive concatenates 2 strings together.  It concatenates the second arguement onto the first and returns it as the third arguement.
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
> Global Function: BNRP_substring ;
  $ BNRP_BooleanBNRP_substring (TCB*)
> Purpose:
  | This primitive returns a substring of a string.  It has 4 arguements:
  | - string to get substring from
  | - Index into string where substring starts
  | - How many characters from Index make up the substring
  | - the substring (filled in by primitive)
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
> Global Function: BNRP_lowercase ;
  $ BNRP_BooleanBNRP_lowercase (TCB*)
> Purpose:
  | This primtive translates a string (first arguement) into all lower case characters (second arguement)
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
> Global Function: BNRP_uppercase ;
  $ BNRP_BooleanBNRP_uppercase (TCB*)
> Purpose:
  | This primitive translates a string (first arguement) into all upper case characters (second arguement)
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
> Global Function: BNRP_namelength ;
  $ BNRP_BooleanBNRP_namelength (TCB*)
> Purpose:
  | This primitive takes a symbol as it's first arguement and returns it's length as the second arguement.
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
> Global Function: BNRP_gensym ;
  $ BNRP_BooleanBNRP_gensym (TCB*)
> Purpose:
  | This primitive takes a symbol as a first arguement, and using that symbol generates a unique symbol name which is returned in the second arguement.
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
> Global Function: BNRP_getConstraint ;
  $ BNRP_BooleanBNRP_getConstraint (TCB*)
> Purpose:
  | This primitive gets the constraint list for a variable or for a tail variable.  The first arguement is a variable or a tail variable (in a list).  The second argement gets unified with the list of constraints associated with the first arguement.  If there aren't any cnstraints, FALSE is returned.
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
> Global Function: BNRP_defineOperator ;
  $ BNRP_BooleanBNRP_defineOperator (TCB*)
> Purpose:
  | This primitive adds a new operator definition.  It has three arguements: the operator name, the precedence and how the operator works (ie. postfix, non-associative, etc).
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
> Global Function: BNRP_retract ;
  $ BNRP_BooleanBNRP_retract (TCB*)
> Purpose:
  | This primitive takes two arguements.  The first is a symbol (predicate name) and the second is an integer (pointer to a clauseEntry).  What this does is to remove a clause from the clause chain.
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
> Global Function: BNRP_configuration ;
  $ BNRP_BooleanBNRP_configuration (TCB*)
> Purpose:
  | This primtive takes a single symbolic/variable arguement.  If it is a variable, it returns the configuration string from the configuration file.  Otherwise it writes the symbol into the configuration file erasing the previous contents of the file.
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
> Global Function: BNRP_regularStatus ;
  $ BNRP_BooleanBNRP_regularStatus (TCB*)
> Purpose:
  | This primitive returns a number of the counter values.  It it is called with 0 arguements, then these counters get reset, otherwise they are unified with the following:
  | - Number of logical inferences
  | - Number of primitive calls
  | - Number of interval operations
  | - Number of interval iterations
  | - Elapsed user time
  | - Number of garbage collections
  | - Elapsed cpu time
  | The primitive takes either 5, 6, or 7 arguements.  An X arguement call returns the first X of the values described above.
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
> Global Function: BNRP_memoryStatus ;
  $ BNRP_BooleanBNRP_memoryStatus (TCB*)
> Purpose:
  | This primitive takes 9 arguements that indicate the following:
  | - total space a context has
  | - current space used in the context
  | - high water mark of space used in context
  | - total heap/trail space allocated
  | - current heap/trail space used
  | - high water mark of space used on heap/trail
  | - total env/cp space allocated
  | - current env/cp space used
  | - high water mark of space used on env/cp
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
> Global Function: BNRP_set_gc ;
  $ BNRP_BooleanBNRP_set_gc (TCB*)
> Purpose:
  | This primitive takes a sinlge integer/variable arguement.  If it is an integer, it specifies how many terms build up on the heap till a garbage collection can be performed.  Otherwise it is unified with the current value of BNRP_gcFlag.
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
> Global Function: BNRP_dumplowlevel ;
  $ voidBNRP_dumplowlevel (TAG, BNRP_result)
> Purpose:
  | This function is used to print out terms for debugging purposes.  It's only available if testinterface is defined.  The first arguement is the tag of the term and the second is an instantiated BNRP_result structure.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TAG tag
  = BNRP_result r - XXXXX_G_PAR
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
> Global Function: BNRP_testlowlevel ;
  $ BNRP_BooleanBNRP_testlowlevel (BNRP_TCB*)
> Purpose:
  | This is a test primitive that gets bound in during the call to BNRP_initializeGlobals() only when testinterface is defined.  The first arguement is either a list, a structure ora variable.  If it is a list or a struct, it gets taken apart and printed out.  If it is a variable then it gets unified with a list of various terms.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: BNRP_setTrace ;
  $ BNRP_BooleanBNRP_setTrace (TCB*)
> Purpose:
  | This predicate has two arguements.  The first is the predicate name whose tracing flag needs to be changed.  The second is the value to change the flag to.  If it is avariable it is unified with the current trace flag of the predicate specified.
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
> Global Function: BNRP_setTraceAll ;
  $ BNRP_BooleanBNRP_setTraceAll (TCB*)
> Purpose:
  | This primitive takes three arguements: an 'and' mask, an 'or' mask and a list of predicates not to allow tracing on.  What this does is to use the and an or masks to enable tracing on all predicates except local ones and those specified in the list.  The masks specify which trace bits get set or cleared according
  | to the predicate's current trace flags.
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
> Global Function: BNRP_setUnknown ;
  $ BNRP_BooleanBNRP_setUnknown (TCB*)
> Purpose:
  | This primitive takes a single integer or variable arguement.  If it is non-zero then unknown predicates will be traced, otherwise unknown predicates will fail.  If it is a variable, it unifies it with the current status of the unknown flag.
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
> Global Function: BNRP_enableTrace ;
  $ BNRP_BooleanBNRP_enableTrace (TCB*)
> Purpose:
  | This primitive takes a single integer or variable arguement.  If it is non-zero it enables the tracing flag, otherwise it disables it.  If it is a variable, it unifies it with the current status of the tracing flag (0 if disabled otherwise 1).
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
> Global Function: BNRP_delay ;
  $ BNRP_BooleanBNRP_delay (TCB*)
> Purpose:
  | This primitve has 2 arguements.  The first indicates how much time to delay for (float or int) and the second indicates which mode to do it in.  If the second argement is zero then 'sleep' mode is requested in which ticks are not woken up for.  If it is 1, then 'delay' mode is requested whereupon it will 'wake up' when a tick occurs.  Unfortunatly for some bizarre reason this works exactly the opposite as described.
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
> Global Function: handleTick ;
  $ voidhandleTick ()
> Purpose:
  | This function is the tick handler that gets executed every time a tick occurs.  It checks to see if it can execute and if it can sets a flag indicating to the engine to inject the tick goal and sets a flag to indicate that a tick is being performed.  This last flag gets cleared by BNRP_reEnableTimer.
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
> Global Function: BNRP_enableTimer ;
  $ BNRP_BooleanBNRP_enableTimer (TCB*)
> Purpose:
  | This primitive sets up a timer that goes off every X seconds and performs the 'tick' goal.  It takes one arguement being a time value in seconds.  This can be either a float or an integer.  
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
> Global Function: BNRP_reEnableTimer ;
  $ BNRP_BooleanBNRP_reEnableTimer (TCB*)
> Purpose:
  | This primitive takes zero arguements and allows subsequent ticks to be executed.  This is typically called by the tick handling code after the tick has been performed.
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
> Global Function: BNRP_dpprim ;
  $ BNRP_BooleanBNRP_dpprim (TCB*)
> Purpose:
  | Not used.
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
> Global Function: BNRP_examinefp ;
  $ BNRP_BooleanBNRP_examinefp (TCB*)
> Purpose:
  | This primitive translates a float to a string and vice-versa.  It has two arguements, the first is a float and the second is a symbol.
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
> Global Function: BNRP_setintervalconstraints ;
  $ BNRP_BooleanBNRP_setintervalconstraints (TCB*)
> Purpose:
  | This primitive sets or retrives a number of interval arithmetic configuration parameters.  It has 3 arguements: maximum allocation of ops permitted on each entry into BNRP_iterate(),  amount added to opcount for each new node visited, and the amount subtracted from opcount for each node revisited.  If any of the arguements are variables, then the current value is returned, otherwise the value is set to what was passed in.
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
> Global Function: BNRP_replaceFloat ;
  $ BNRP_BooleanBNRP_replaceFloat (TCB*)
> Purpose:
  | This primitive takes two floating point arguements and replaces the first arguement with the second.
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
> Global Function: BNRP_initializeGlobals ;
  $ voidBNRP_initializeGlobals ()
> Purpose:
  | This function initializes memory and the parser.  it also allocates a large number of global symbols into the permanent symbol tables.  These are symbols tht get used quite frequently.  Putting them into the symbol table allows us to compare term addresses instead of doing strcmp's on the symbol names themselves.
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
> Data Item: curlyAtom
  $ BNRP_term curlyAtom
> Purpose:
  | This atom indicates a '{}' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: commaAtom
  $ BNRP_term commaAtom
> Purpose:
  | This atom indicates a ',' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cutAtom
  $ BNRP_term cutAtom
> Purpose:
  | This atom indicates a '!' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cutcutAtom
  $ BNRP_term cutcutAtom
> Purpose:
  | This atom indicates a 'cut' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.R
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cutFailAtom
  $ BNRP_term cutFailAtom
> Purpose:
  | This atom indicates a 'failexit' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: recoveryUnitAtom
  $ BNRP_term recoveryUnitAtom
> Purpose:
  | This atom indicates a 'recovery_unit' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: isAtom
  $ BNRP_term isAtom
> Purpose:
  | This atom indicates an 'is' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: plusAtom
  $ BNRP_term plusAtom
> Purpose:
  | This atom indicates a '+' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: minusAtom
  $ BNRP_term minusAtom
> Purpose:
  | This atom indicates a '-' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: starAtom
  $ BNRP_term starAtom
> Purpose:
  | This atom indicates a '*' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: slashAtom
  $ BNRP_term slashAtom
> Purpose:
  | This atom indicates a '/' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: slashslashAtom
  $ BNRP_term slashslashAtom
> Purpose:
  | This atom indicates a '//' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: modAtom
  $ BNRP_term modAtom
> Purpose:
  | This atom indicates a 'mod' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: starstarAtom
  $ BNRP_term starstarAtom
> Purpose:
  | This atom indicates a '**' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: intAtom
  $ BNRP_term intAtom
> Purpose:
  | This atom indicates an 'integer' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: floatAtom
  $ BNRP_term floatAtom
> Purpose:
  | This atom indicates a 'float' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: floorAtom
  $ BNRP_term floorAtom
> Purpose:
  | This atom indicates a 'floor' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ceilAtom
  $ BNRP_term ceilAtom
> Purpose:
  | This atom indicates a 'ceiling' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: roundAtom
  $ BNRP_term roundAtom
> Purpose:
  | This atom indicates a 'round' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: maxAtom
  $ BNRP_term maxAtom
> Purpose:
  | This atom indicates a 'max' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: minAtom
  $ BNRP_term minAtom
> Purpose:
  | This atom indicates a 'min' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: sqrtAtom
  $ BNRP_term sqrtAtom
> Purpose:
  | This atom indicates a 'sqrt' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: absAtom
  $ BNRP_term absAtom
> Purpose:
  | This atom indicates an 'abs' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: expAtom
  $ BNRP_term expAtom
> Purpose:
  | This atom indicates a 'exp' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: lnAtom
  $ BNRP_term lnAtom
> Purpose:
  | This atom indicates a 'ln' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: sinAtom
  $ BNRP_term sinAtom
> Purpose:
  | This atom indicates a 'sin' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cosAtom
  $ BNRP_term cosAtom
> Purpose:
  | This atom indicates a 'cos' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: tanAtom
  $ BNRP_term tanAtom
> Purpose:
  | This atom indicates a 'tan' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: asinAtom
  $ BNRP_term asinAtom
> Purpose:
  | This atom indicates an 'asin' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: acosAtom
  $ BNRP_term acosAtom
> Purpose:
  | This atom indicates an 'acos' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: atanAtom
  $ BNRP_term atanAtom
> Purpose:
  | This atom indicates an 'atan' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: maxintAtom
  $ BNRP_term maxintAtom
> Purpose:
  | This atom indicates a 'maxint' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: maxfloatAtom
  $ BNRP_term maxfloatAtom
> Purpose:
  | This atom indicates a 'maxreal' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: piAtom
  $ BNRP_term piAtom
> Purpose:
  | This atom indicates a 'pi' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: cputimeAtom
  $ BNRP_term cputimeAtom
> Purpose:
  | This atom indicates a 'cputime' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: eqAtom
  $ BNRP_term eqAtom
> Purpose:
  | This atom indicates a '==' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: neAtom
  $ BNRP_term neAtom
> Purpose:
  | This atom indicates a '<>' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ltAtom
  $ BNRP_term ltAtom
> Purpose:
  | This atom indicates a '<' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: gtAtom
  $ BNRP_term gtAtom
> Purpose:
  | This atom indicates a '>' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: geAtom
  $ BNRP_term geAtom
> Purpose:
  | This atom indicates a '>=' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: leAtom
  $ BNRP_term leAtom
> Purpose:
  | This atom indicates a '=<' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: clauseAtom
  $ BNRP_term clauseAtom
> Purpose:
  | This atom indicates a 'clause$$' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: execAtom
  $ BNRP_term execAtom
> Purpose:
  | This atom indicates a '$$exec' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: failAtom
  $ BNRP_term failAtom
> Purpose:
  | This atom indicates a 'fail' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: varAtom
  $ BNRP_term varAtom
> Purpose:
  | This atom indicates a 'var' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: tailvarAtom
  $ BNRP_term tailvarAtom
> Purpose:
  | This atom indicates a 'tailvar' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_filterNames
  $ BNRP_term[] BNRP_filterNames
> Purpose:
  | This array holds atoms dealing with simple filters such as 'symbol' and 'noninteger'.  It is used for ease of identifiaction of such terms.  Saves a called to strcmp().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: numberAtom
  $ BNRP_term numberAtom
> Purpose:
  | This atom indicates a 'number' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: nonNumberAtom
  $ BNRP_term nonNumberAtom
> Purpose:
  | This atom indicates a 'nonnumber' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: attentionAtom
  $ BNRP_term attentionAtom
> Purpose:
  | This atom indicates an 'attention_handler' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ifAtom
  $ BNRP_term ifAtom
> Purpose:
  | This atom indicates a '->' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: orAtom
  $ BNRP_term orAtom
> Purpose:
  | This atom indicates a ';' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: indirectAtom
  $ BNRP_term indirectAtom
> Purpose:
  | This atom indicates a '$$callindirect' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: unificationAtom
  $ BNRP_term unificationAtom
> Purpose:
  | This atom indicates an '=' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: eofAtom
  $ BNRP_term eofAtom
> Purpose:
  | This atom indicates a 'end_of_file' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: tracerAtom
  $ BNRP_term tracerAtom
> Purpose:
  | This atom indicates a 'tracer' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: tickAtom
  $ BNRP_term tickAtom
> Purpose:
  | This atom indicates a '$tick' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ssAtom
  $ BNRP_term ssAtom
> Purpose:
  | This atom indicates a '$ss' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: intervalAtom
  $ BNRP_term intervalAtom
> Purpose:
  | This atom indicates a '$interval' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: integralAtom
  $ BNRP_term integralAtom
> Purpose:
  | This atom indicates a '$integral' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: booleanAtom
  $ BNRP_term booleanAtom
> Purpose:
  | This atom indicates a '$boolean' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: evalConstrainedAtom
  $ BNRP_term evalConstrainedAtom
> Purpose:
  | This atom indicates a '$evalconstrained' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: noopnodeAtom
  $ BNRP_term noopnodeAtom
> Purpose:
  | This atom indicates a '$noopnode' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPmarkAtom
  $ BNRP_term BNRPmarkAtom
> Purpose:
  | This atom indicates a 'BNRP_mark' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_combineVarAtom
  $ BNRP_term BNRP_combineVarAtom
> Purpose:
  | This atom indicates a '$combinevar' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_defaultTaskName
  $ BNRP_term BNRP_defaultTaskName
> Purpose:
  | This atom indicates the 'BNRP_defaultTaskName' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_taskswitch_primitive
  $ BNRP_term BNRP_taskswitch_primitive
> Purpose:
  | This atom indicates a '$task_switch' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: counterAtom
  $ BNRP_term counterAtom
> Purpose:
  | This atom indicates a '$counter' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: indirectListAtom
  $ BNRP_term indirectListAtom
> Purpose:
  | This atom indicates a '$$calllistindirect' symbol.  It is used for ease of identification of such things.  Saves from doing a strcmp.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_lastErrorTraceback
  $ char[tracebackStrLen] BNRP_lastErrorTraceback
> Purpose:
  | This is the traceback string generated by the last error.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: gensymIndex
  $ long gensymIndex
> Purpose:
  | This is used to generate unique symbol names.  It gets concatented to a symbol to generate a unique symbol.  It is initially set to zero but gets incremented each time a call to BNRP_gensym() is made.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_statStartTime
  $ long BNRP_statStartTime
> Purpose:
  | This records that applications user timer when a call to BNRP_regularStatus is made with 0 arguements in the tcb (stats\0).  When a subsequent call to stats is made (with arguements), this is used to determine the user time since stats\0 was called.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_statElapsedTime
  $ long BNRP_statElapsedTime
> Purpose:
  | This records the applications elapsed time when a call to BNRP_regularStatus is made with 0 arguements in the tcb (stats\0).  When a subsequent call to stats is made (with arguements), this is used to determine the elapsed time since stats\0 was called.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_intervalOperations
  $ long BNRP_intervalOperations
> Purpose:
  | This records the number of interval operations that have been performed inside of BNRP_iterate().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_intervalIterations
  $ long BNRP_intervalIterations
> Purpose:
  | This records the number of calls to BNRP_iterate().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_gcFlag
  $ long BNRP_gcFlag
> Purpose:
  | The number of terms that can be built onto the heap since the last choicepoint till garbage collection is done.  A zero value indicates to not do garbage collection.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPflags
  $ long BNRPflags
> Purpose:
  | This holds any flag values that the system needs.  The current flags are:
  | - 0x01 is the attention flag indicating a ctrl-C for example
  | - 0x02 indicates that a constraint has been fired
  | - 0x04 indicates that a tick from enabletimer needs to be injected into the goal stream
  | - 0x100000 indicates that debugging has been enabled
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPunknown
  $ long BNRPunknown
> Purpose:
  | This determines the action to be taken when an unknown predicate is found.  If is is set then the tracing is done, otherwise we fail.  This is only used for
  | debugging purposes (ie. debugging a user's Prolog code).
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_inTick
  $ BNRP_Boolean BNRP_inTick
> Purpose:
  | This is set when a tick from BNRP_enableTimer() is being processed.  After the tick has been executed a call to BNRP_reEnableTimer is made where BNRP_inTick is set to FALSE to allow the next tick to be executed.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_tickCount
  $ fp BNRP_tickCount
> Purpose:
  | This is the timer value for calls into BNRP_enableTimer().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_MaxOperations
  $ long BNRP_MaxOperations
> Purpose:
  | The maximum number of operations that can be performed on each entry to BNRP_iterate().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_IntervalIncrement
  $ long BNRP_IntervalIncrement
> Purpose:
  | Tha amount added to the opcount for each new node in the interval constraint network that has to be visited.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_IntervalDecrement
  $ long BNRP_IntervalDecrement
> Purpose:
  | The amount subtracted from the opcount for each node in the interval constraint network that has been revisited.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _SIZE_T
  $ #define _SIZE_T
> Purpose:
  | This is defined on Delta Workstations as it's not defined in in stddef.h as it should.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXSHORT
  $ #define MAXSHORT
> Purpose:
  | This is the maximum value of a short.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trail
  $ #define trail (te, addr)
> Purpose:
  | This macro places a term pointed to by addr onto the end of the trail denoted by te.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | This macro makes sure that there is room enough on the heap for n items.  If there is not enough room then a HEAPOVERFLOW erro is reported to BNRP_RESUME()
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_prim
  $ #define _H_prim
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: tracebackStrLen
  $ #define tracebackStrLen
> Purpose:
  | This is the maximum length of an error trace back string
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
