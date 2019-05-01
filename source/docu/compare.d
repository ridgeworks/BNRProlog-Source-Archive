#if 0
----------------------------------------------------------------------
> Global Function: compareTerm ;
  $ BNRP_BooleancompareTerm (TCB*, BNRP_term*, BNRP_term*, BNRP_Boolean*, BNRP_Boolean*)
> Purpose:
  | This function compares two terms.  'recurse' is TRUE if the terms are lists or structures.  'less' is true if 'left' < 'right' in standard order.  For structures a comparison between the two arities is done to determine the value of 'less'.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the two terms are equivalent
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = BNRP_term* left - Pointer to a term to be compared
  = BNRP_term* right - Pointer to a term to be compared
  = BNRP_Boolean* recurse - BNRP_Boolean pointer filled in by system
  = BNRP_Boolean* less - BNRP_Boolean pointer filled in by system
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
> Global Function: BNRP_breadth_first_compare ;
  $ BNRP_BooleanBNRP_breadth_first_compare (TCB*)
> Purpose:
  | This primitive performs a breadth first comparison of two terms in standard order.  It takes three arguements.  The first two are the terms to be compared while the third is unified with one of the following symbols:
  | 		'@=' - terms are identical
  | 		'@<' - first term is before the second term in standard order
  | 		'@>' - second term is before the first term in standard order
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
> Global Function: BNRP_first_var ;
  $ BNRP_BooleanBNRP_first_var (TCB*)
> Purpose:
  | This primitive returns the first variable in a term.  The first arguement is a term and the second gets unified with the first variable in the first arguement.
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
> Global Function: BNRP_var_list ;
  $ BNRP_BooleanBNRP_var_list (TCB*)
> Purpose:
  | This primitive returns a list of all the variables in a term and a list of all the tailvariables as well.  These lists will include any duplicates that have been encountered.  It has three arguements.  The first is the term whose variables and tail variables we want to find.  The second arguement is unified with a list of the variables encountered, while the third is unified with a list of tail variables found.
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
> Global Function: spanningtree ;
  $ BNRP_Booleanspanningtree (TCB*, BNRP_Boolean)
> Purpose:
  | This function decomposes cyclic terms returning a term that will become the cyclic term using the returned maximal or minimal list of required unifications.  If the 'simplify' flag is set, then the minimal set of unifications will be retruned, otherwise the maximal set will be returned.  It's expected that the tcb has three arguements which are:
  | 		- cyclic term to be decomposed
  | 		- term that will become the first arguement if the third is executed
  | 		- list of unifications that will allow the 2nd arguement to become the first.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb
  = BNRP_Boolean simplify - XXXXX_G_PAR
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
> Global Function: BNRP_spanning_tree ;
  $ BNRP_BooleanBNRP_spanning_tree (TCB*)
> Purpose:
  | This primitive returns as a third arguement a maximal set of unifications required to turn the second arguement (filled in by primitive) into the first arguement.  The first arguement is typically a cyclic structure.
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
> Global Function: BNRP_decompose ;
  $ BNRP_BooleanBNRP_decompose (TCB*)
> Purpose:
  | This primitive returns as a third arguement a minimal set of unifications required to turn the second arguement (filled in by primitive) into the first arguement.  The first arguement is typically a cyclic structure.
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
> Global Function: checkAcyclic ;
  $ BNRP_BooleancheckAcyclic (long)
> Purpose:
  | This function determines if the given term is acyclic or not.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if acyclic
> Parameters:
  = long val - Term to be checked.
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
> Global Function: BNRP_acyclic ;
  $ BNRP_BooleanBNRP_acyclic (TCB*)
> Purpose:
  | This primitive has a single arguement which is the term to be checked for cycles.  If it is acyclic, then TRUE is returned, otherwise false.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - True if the given term is acyclic.
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
> Global Function: BNRP_ground ;
  $ BNRP_BooleanBNRP_ground (TCB*)
> Purpose:
  | This primitive determines if a given term has unbound variables or tail variables. It has a single arguement which is the term to be checked for variables
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the term does not contain unbound variables or tail variables.
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
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | Determines if there is room for n terms on the heap.  If there isn't a HEAPOVERFLOW error is generated in BNRP_RESUME().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
