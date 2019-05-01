#if 0
----------------------------------------------------------------------
> Global Function: BNRP_dumpHex ;
  $ voidBNRP_dumpHex (void*, void*)
> Purpose:
  | Performs a hex dump of memory to stdin from <start> to <last>.  This is used for debugging purposes.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void* start
  = void* last
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC  | 
> Concurrency:  | 
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: deref ;
  $ voidderef (long, long*, TAG*, long*, ptr*)
> Purpose:
  | Dereferences <reg> and instatiates <taggedValue> to be the dereferenced term, <tag> to be the tag of the term, <value> to be the value of the term (if applicable.  eg. integers) and <ptr> to be the address of the term.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long reg - Prolog term
  = long* taggedValue - dereferenced term
  = TAG* tag - tag value of the term
  = long* value - value of the term if applicable
  = ptr* lastAddr - address of the term
> Exceptions:
  | Throws no exceptions, passes all exceptions through  | .
> Concurrency:  | 
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: derefTV ;
  $ voidderefTV (long*, long*, TAG*, long*, ptr*)
> Purpose:
  | This works similarly to deref(), but it first chases down any tail variables in <p>, and then calls deref().
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long* p - Prolog term
  = long* taggedValue - dereferenced term
  = TAG* tag - tag value of the term
  = long* value - value of the term, if applicable
  = ptr* lastAddr - address of the term
> Exceptions:
  | Throws no exceptions, passes all exceptions through.  | 
> Concurrency:  | 
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: getVarName ;
  $ voidgetVarName (TCB*, long, char*<T>)
> Purpose:
  | Looks up the name of a variable <result> and puts it in <name>
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long result - Variable term
  = char* name - Name of the variable
> Exceptions:
  | Throws no exceptions, passes all exceptions through. 
> Concurrency:  | 
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_dumpArgInternal ;
  $ voidBNRP_dumpArgInternal (TCB*, long, long, long)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb
  = long value
  = long nesting
  = long prec - XXXXX_G_PAR
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
> Global Function: BNRP_dumpArg ;
  $ voidBNRP_dumpArg (TCB*, long)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb
  = long value - XXXXX_G_PAR
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
> Global Function: checkArg ;
  $ TAGcheckArg (long, long*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | TAG
> Parameters:
  = long reg
  = long* value - XXXXX_G_PAR
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
> Global Function: getusage ;
  $ BNRP_Booleangetusage (TCB*)
> Purpose:
  | 
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
> Global Function: profile ;
  $ BNRP_Booleanprofile (TCB*)
> Purpose:
  | 
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
> Global Function: BNRP_loadBase ;
  $ intBNRP_loadBase (int, char**, char*<T>)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = int argc
  = char** argv
  = char* defaultbase - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing0 ;
  $ voidBNRP_bindRing0 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing1 ;
  $ voidBNRP_bindRing1 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing2 ;
  $ voidBNRP_bindRing2 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing3 ;
  $ voidBNRP_bindRing3 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing4 ;
  $ voidBNRP_bindRing4 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
> Global Function: BNRP_bindRing5 ;
  $ voidBNRP_bindRing5 (void)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  - XXXXX_G_PAR
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
