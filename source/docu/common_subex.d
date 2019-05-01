#if 0
----------------------------------------------------------------------
> Global Function: BNRP_findCommonSubex ;
  $ BNRP_BooleanBNRP_findCommonSubex (TCB*)
> Purpose:
  | Used for finding common subexpressions in constraint lists.  This is used so that we don't have to recalculate an expression if we have already calculated it.  Searches the constraint lists associated with a node for the node.
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
> Macro: trail
  $ #define trail (te, addr)
> Purpose:
  | Pushes addr onto te.  te is typically the trail pointer
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: simplebind
  $ #define simplebind (val, newval)
> Purpose:
  | Binds a new term to a term and trails the old value in case of backtracking.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nextArg
  $ #define nextArg (p, x)
> Purpose:
  | Unwinds tailvariables and dereferences variables to get the next term in a stucture or list.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: compareSimple
  $ #define compareSimple (p, ap)
> Purpose:  | 
  | 	p and ap are numeric terms.  compareSimple() returns true if a and ap are
  | 	equal.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getConstraintList
  $ #define getConstraintList (x,y)
> Purpose:
  | Gets the constraint list of either x or y.  If x is a variable, it gets it's constraint list.  If y is a variable it gets it's constraint list, otherwise returns false.  It puts the constraint list into the x ## constraints variable
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: searchList
  $ #define searchList (x,y)
> Purpose:
  | Searches either the x or y list of constaints for a node.  It compares the functor and the bound terms of the node looking to bind the third term.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
