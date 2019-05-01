#if 0
----------------------------------------------------------------------
> Global Function: returnint ;
  $ BNRP_termreturnint (long)
> Purpose:
  | This function is used only when 'test' is defined.  It creates an integer with thevalue 'value' on the dummy heap 'buffp' and returns the new integer term.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - new integer term
> Parameters:
  = long value - value of the new integer term
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
> Struct:
  | procRecord
  $ struct procRecord
> Purpose:
  | This structure is used to hold all the information required to execute a procedure.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = BNRP_term name - Prolog name for the procedure
  = BNRP_procedure proc - Address for the code of the procedure
  = int arity - arity of the procedure
  = int[MAXPARMS] parmtypes - Types of the procedure parameters
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
> Global Function: lookatarg ;
  $ TAGlookatarg (BNRP_term, long*)
> Purpose:
  | This is only used when 'test' is defined.  It takes the term 't' and puts the address of it in 'res' and returns the tag value.
> Calling Context:
  | 
> Return Value:
  | TAG - tag of the term 't'
> Parameters:
  = BNRP_term t - term to be looked at.
  = long* res - Pointer to the address of the term (filled in by function)
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
> Global Function: returnfloat ;
  $ BNRP_termreturnfloat (fp)
> Purpose:
  | This function is used only when 'test' is defined.  It creates a float with the value 'value' on the dummy heap 'buffp' and returns the new float term.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - new float term
> Parameters:
  = fp value - value of new float term.
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
> Global Function: returnsym ;
  $ BNRP_termreturnsym (char*)
> Purpose:
  | This function is used only when 'test' is defined.  It creates a symbol with the name 'p' on the dummy heap 'buffp' and returns the new symbol.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - symbol term with name 'p'
> Parameters:
  = char* p - Name of new symbol.
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
> Global Function: BNRP_handleArg ;
  $ BNRP_BooleanBNRP_handleArg (TCB*, int, int)
> Purpose:
  | This function processes the arguements held in the task control block and pushes them into BNRP_procPtr.  When it reaches the end of the list, the procedure is executed, and then the results get bound back into the TCB.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = int index - index into BNRP_procs indicating which procedure to use
  = int arg - index into arguement list to indicate which arguement to process next.
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
> Global Function: BNRP_handleProcedure ;
  $ BNRP_BooleanBNRP_handleProcedure (TCB*)
> Purpose:
  | This function is called each time a user tries to execute a "procedure".  It reads the 'procname' from 'tcb' and then searches for it in the BNRP_procs array.  If it can't be found FALSE is returned.  If it is found, then the arguements from 'tcb' are parsed and the procedure is executed and results bound back into the tcb and the procedure returns.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - Pointer to a task control block
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
> Global Function: BNRP_bindProcedure ;
  $ intBNRP_bindProcedure (char*, void(*)(), int, ...)
> Purpose:
  | This function binds a procedure into the system.  It has a variable number of arguements which is bound by the 'arity' arguement.  The arity arguement indicates the number of arguements after it.  Allocates a new entry in the BNRP_procs array and transfers the information about the new procedure into it. Adds a new clause to the system with the name 'name' and the clause code is in BNRP_handleProcedure().
> Calling Context:
  | 
> Return Value:
  | int - 0 on success, -1 on failure
> Parameters:
  = char* name - name by which Prolog will call the procedure 
  = void(*)() procedure - address of the procedure to be called
  = int arity - Number of arguements the procedure takes
  = ... ellipsis - type of each arguement in order (left -> right)
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
> Global Function: newproc ;
  $ newproc (int, )
> Purpose:
  | This function is for test purposes only ('test' has to be defined).  It makes use of the newproc macro to define itself.
> Calling Context:
  | 
> Return Value:
  | No return value...
> Parameters:
  = int 
  = - XXXXX_G_PAR
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
> Data Item: BNRP_maxProcs
  $ int BNRP_maxProcs
> Purpose:
  | This is the number of procedures that BNRP_procs contains.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_procBuffer
  $ int[BUFFSIZE] BNRP_procBuffer
> Purpose:
  | Used to hold the arguements of a procedure when being called.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_procPtr
  $ void* BNRP_procPtr
> Purpose:
  | This is used as a pointer into BNRP_procBuffer.  It gets incremented when new items are pushed onto it.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_procs
  $ procRecord* BNRP_procs
> Purpose:
  | Pointer to an array of procRecords.  Used to get and execute a procedure.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_procs
  $ procRecord[] BNRP_procs
> Purpose:
  | This is the array of procRecords used when 'test' is defined.  Only two procRecords are allowed in this case.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: buffp
  $ long buffp
> Purpose:
  | Used as an imaginary heap on which terms are created when 'test' is defined.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | extended
  $ typedef long double extended
> Purpose:
  | type definition for an extended number.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | procRecord
  $ typedef procRecord procRecord
> Purpose:
  | Type definition for the procRecord structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXPARMS
  $ #define MAXPARMS
> Purpose:
  | Maximum number of parameters that a procedure can have.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_endParm
  $ #define BNRP_endParm
> Purpose:
  | Used to denote the end of the parameters.  This is inserted into the parameters list by BNRP_bindProcedure().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promotedint
  $ #define promotedint
> Purpose:
  | Type definition of an integer for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promotedshort
  $ #define promotedshort
> Purpose:
  | Type definition of a short for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promotedlong
  $ #define promotedlong
> Purpose:
  | Type definition of a long for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promotedfloat
  $ #define promotedfloat
> Purpose:
  | Type definition of a float for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promoteddouble
  $ #define promoteddouble
> Purpose:
  | Type definition of a double for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: promotedlongdouble
  $ #define promotedlongdouble
> Purpose:
  | Type definition of a long double for purposes of stuffing items into BNRP_procPtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BUFFSIZE
  $ #define BUFFSIZE
> Purpose:
  | Size of the BNRP_procBuffer
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ALIGNMENT
  $ #define ALIGNMENT
> Purpose:
  | This is the memory alignment required by some platforms when copying items to BNRP_procPtr (copyval)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: makeint
  $ #define makeint (a, b)
> Purpose:
  | Creates an integer term using 'b' which is an integer.  Only used when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: makefloat
  $ #define makefloat (a, b)
> Purpose:
  | Creates a float term using 'b' which is a pointer to an fp.  Only used when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRPLookupSymbol
  $ #define BNRPLookupSymbol (a,b,c,d)
> Purpose:
  | Creates a symbol with the name 'b' and returns it.  This is used only when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: checkArg
  $ #define checkArg (a, b)
> Purpose:
  | Puts the address of the term 'a' into 'b' and returns the tag.  'a' is a BNRP_term and 'b' is a long *.  this is only used when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_malloc
  $ #define BNRP_malloc
> Purpose:
  | A convenience definition to allocate memory when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: unify
  $ #define unify (a, b, c)
> Purpose:
  | A simple "unification" which sets 'b' equal to 'c' for use when 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: copyval
  $ #define copyval (f, t)
> Purpose:
  | Copies a value 't' of size 'f' onto BNRP_procPtr and then increments BNRP_procPtr by 'f'.  It also takes into account ALIGNMENT if it is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: copyval
  $ #define copyval (f, t)
> Purpose:
  | Copies a value 't' of size 'f' onto BNRP_procPtr and then increments BNRP_procPtr by 'f'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: incr_procPtr
  $ #define incr_procPtr (s)
> Purpose:
  | This increments BNRP_procPtr by 's'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: handleint
  $ #define handleint (f, t)
> Purpose:
  | This macro handles an arguement of types BNRP_intParm, BNRP_longParm, and BNRP_shortParm that is in 'l'.  It puts the value of 'l' into 't' and then copies the value into BNRP_procPtr.  It then returns the result of BNRP_handleArg() on the next arguement (arg + 1).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: handlevarint
  $ #define handlevarint (f, t)
> Purpose:
  | This macro handles an arguement of types BNRP_varIntParm, BNRP_varLongParm, and BNRP_varShortParm that is in 'l'.  It pushes the address of the result onto BNRP_procPtr which gets cast as a 'f' **.  It also puts 'l' into 't'.  It then calls BNRP_handleArg() to process the next arguement.  When that returns t gets unified with the tcb->args[arg].
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: handlefp
  $ #define handlefp (f, t)
> Purpose:
  | This macro handles an arguement of types BNRP_floatParm, BNRP_doubleParm, and  BNRP_extendedParm that is in 'l'.  It puts the value of 'l' into 't' and then copies the value into BNRP_procPtr.  It then returns the result of BNRP_handleArg() on the next arguement (arg + 1).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: handlevarfp
  $ #define handlevarfp (f, t)
> Purpose:
  | This macro handles an arguement of types BNRP_varFloatParm, BNRP_varDoubleParm, and BNRP_varExtendedParm that is in 'l'.  It pushes the address of the result onto BNRP_procPtr which gets cast as a 'f' **.  It also puts 'l' into 't'.  It then calls BNRP_handleArg() to process the next arguement.  When that returns t gets unified with the tcb->args[arg] if the tag isn't an INTT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: notAllowed
  $ #define notAllowed (x)
> Purpose:
  | This macro is used on certain platforms to disallow certain parameter types (eg. BNRP_floatParm).  it checks to see if k is x, and if so, prints out a warning and returns -1.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: newproc
  $ #define newproc (t, f)
> Purpose:
  | Used to define a test procedure.  't' is a type, and 'f' is the format for the type (ie t = int  f = "%d".  Only defined if 'test' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
