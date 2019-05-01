#if 0
----------------------------------------------------------------------
> Macro: _H_interpreter
  $ #define _H_interpreter
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LASTAST
  $ #define LASTAST
> Purpose:
  | Unknown.  Unused.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: makeint ;
  $ BNRP_termmakeint (long*, long)
> Purpose:
  | This function returns an integer term using address as the address where to put the integer term and value as the integer term's value.  To optimize space, it checks to see if value can be encoded as a short.  If it can then it's encoded in a 4 byte value (top 3 bits used as tag value), otherwise it has to be encoded in a "more expensive" structure term.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - Newly created integer term
> Parameters:
  = long* address - Poiner to where the new term can be placed.
  = long value - integer to be encoded.
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
> Global Function: makefloat ;
  $ BNRP_termmakefloat (long*, fp*)
> Purpose:
  | This function encodes a floating point number and returns the new term.  Floats are encoded as structures with a FLOATID.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - newly created float term
> Parameters:
  = long* address - pointer to where to put the new float term
  = fp* value - float to be encoded
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
> Global Function: BNRP_freespace ;
  $ voidBNRP_freespace (TCB*, long*, long*, long*, long*)
> Purpose:
  | This function returns the amount of environment, choicepoint, heap, and trail stacks are currently being used
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long* s1 - Pointer to a variable that gets filled in with env used
  = long* e1 - Pointer to a variable that gets filled in with cp used
  = long* s2 - Pointer to a variable that gets filled in with heap used
  = long* e2 - Pointer to a variable that gets filled in with trail used.
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
> Global Function: computeKey ;
  $ longcomputeKey (long)
> Purpose:
  | This function is used to compute a unique key for a term.  For unbound variables and tail variables, a key of zero is returned.  For other terms a combination of the term's value and address is used.  This is useful for comparing clauses.
> Calling Context:
  | 
> Return Value:
  | long - Key of the term
> Parameters:
  = long arg - prolog term
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
> Global Function: initializeTCB ;
  $ intinitializeTCB (TCB*, long, long)
> Purpose:
  | This function is used to initialize a task control block.  It allocates space for the heap/trail and env/cp stacks and sets up the various registers inside of the tcb.  This function has been replaced by BNRP_initializeTCB in external.c.
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long heapAndTrail - Size of heap/trail stack in bytes
  = long envAndCP - Size of env/cp stack in bytes
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
> Global Function: initialGoal ;
  $ voidinitialGoal (TCB*, BNRP_term, int)
> Purpose:
  | This is used during task initialization to set up a task's start-up goal.  it sets up program counters, pushes the goal into the execution stack and creates 'arity' variables on the heap and in the tcb's registers
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Initialized task control block
  = BNRP_term a - Goal to be executed
  = int arity - Arity of the goal being executed.
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
> Global Function: findUnused ;
  $ longfindUnused (long, long)
> Purpose:
  | This function returns the amount of used space in a stack given a start and an end point.  It does this by looking for "clean" memory (ie. still in the newly
  | initialized state).
> Calling Context:
  | 
> Return Value:
  | long - Amount of stack that hasn't been used in bytes
> Parameters:
  = long start - start of the stack to be scanned
  = long limit - Point in the stack to stop scanning.
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
> Global Function: BNRP_stackSpaceUsed ;
  $ voidBNRP_stackSpaceUsed (BNRP_TCB*, long*, long*, long*, long*)
> Purpose:
  | This function returns the amount of heap, trail, environment and choicepoint stacks that have been used.  It scans each of the stacks to determine "high
  | water" marks.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = BNRP_TCB* tcb - Pointer to a task control block
  = long* heap - Pointer to a variable that gets filled in by heap used
  = long* trail - Pointer to a variable that gets filled in by trail use
  = long* env - Pointer to a variable that gets filled in by env. use
  = long* cp - Pointer to a variable that gets filled in by cp use.
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
> Global Function: BNRP_stackSpaceCurrent ;
  $ voidBNRP_stackSpaceCurrent (BNRP_TCB*, long*, long*, long*, long*)
> Purpose:
  | This function returns the amount of the heap, trail, environment and choicepoint stacks that are currently in use.  It uses the different stack bases and the top of stack pointers (eg. te and hp).  NOT USED
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = BNRP_TCB* tcb - Pointer to a task control block.
  = long* heap - Pointer to a variable that gets filled in with heap use
  = long* trail - Pointer to a variable that gets filled in with trail use
  = long* env - Pointer to a variable that gets filled in with env. use
  = long* cp - Pointer to a variable that gets filled in with cp stack use.
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
> Global Function: bind ;
  $ voidbind (TCB*, long, long)
> Purpose:
  | This function binds 'val' to 'newval' and fires val's constraints.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long val - term being bound
  = long newval - term being bound to
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
> Global Function: bindtohp ;
  $ voidbindtohp (TCB*, long, long)
> Purpose:
  | This function binds a term and it's constraints into the heap using tags as the term's tag value
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long val - term being bound
  = long tags - Tag of term being bound
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
> Global Function: bindVV ;
  $ voidbindVV (TCB*, long, long)
> Purpose:
  | This function binds two variables together taking into account any related constraints involved.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long var1 - variable term being bound
  = long var2 - variable term being bound
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
> Global Function: bindTVTV ;
  $ voidbindTVTV (TCB*, long, long)
> Purpose:
  | This function binds two tail variables together taking into account any related constraints.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long var1 - tail variable being bound
  = long var2 - tail variable being bound
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
> Global Function: checkArity ;
  $ BNRP_BooleancheckArity (long, long)
> Purpose:
  | This function verifies that two arities are "arity" compatible.  Two arities are arity compatible if one of the following is true:
  | - they are equal
  | - they are both negative
  | - the sum of the two arities is greater than or equal to -1.
  | This is typically used when comparing lists or structures.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = long arity1
  = long arity2 - XXXXX_G_PAR
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
> Global Function: unifyList ;
  $ BNRP_BooleanunifyList (TCB*, long, long)
> Purpose:
  | This function unifies two lists together taking into account any constraints involved in the member terms.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long list1 - first term in the list being bound
  = long list2 - first term in the list being bound
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
> Global Function: unify ;
  $ BNRP_Booleanunify (TCB*, long, long)
> Purpose:
  | This function binds two terms together.  It will also handle any related lists of constraints that the terms have.  This is the usual unification process used inside of primitives.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long t1 - Term being bound.
  = long t2 - Term to bind to
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
> Global Function: unifyQuick ;
  $ voidunifyQuick (TCB*, long, long)
> Purpose:
  | This function is used to unify point intervals.  All that needs to be done is a simple binding of 'var' to 'val' and to "wake up" the constraints associated with 'var'.  'var' is typically a variable, while 'val' is a point interval.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long var - Variable term to be bound
  = long val - Point interval to bind to.
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
> Global Function: copytoRprime ;
  $ longcopytoRprime (long)
> Purpose:
  | This function is used during garbage collection and is used to copy a term from the "dirty" heap to the clean heap.
> Calling Context:
  | 
> Return Value:
  | long - the copied term in R'
> Parameters:
  = long val - term to be copied
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
> Global Function: BNRP_gc ;
  $ voidBNRP_gc (long, choicepoint*, long*, long, long)
> Purpose:
  | This function does garbage collection on the heap tip (lcp to top of heap), fixes the trail, and environement blocks
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long esize - Size of the environment
  = choicepoint* lcp - Pointer to the last choicepoint
  = long* hp - Pointer to the end of the heap
  = long ce - Current environment block
  = long te - End of the trail
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
> Global Function: BNRP_gc_proceed ;
  $ voidBNRP_gc_proceed (choicepoint*, long*, long, long*)
> Purpose:
  | This function does garbage collection on the heap tip (lcp to top of heap) fixes up trail references, and references in 'regs'.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = choicepoint* lcp - Pointer to the last choicepoint
  = long* hp - Pointer to the top of the heap
  = long te - Pointer to the end of the trail
  = long* regs - Pointer to a tcb's registers (ie. regs[])
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
> Data Item: BNRPerrorhandler
  $ void(*)() BNRPerrorhandler
> Purpose:
  | This is the handler that gets executed when BNRP_error() gets called.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_numGC
  $ long BNRP_numGC
> Purpose:
  | This denotes the number of times garbage collection has been done.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_Roffset
  $ long BNRP_Roffset
> Purpose:
  | This is the amount of space between the bottom of the dirty heap and the bottom of the "clean" heap.  Used to replace terms.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_R
  $ class  BNRP_R
> Purpose:
  | This structure is used to mark the top and the bottom of the heap which is elligible for cleaning by the garbage collector (lcp->hp to top of heap).  It has two members: 'top' and 'bottom' which are both longs
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_Rprime
  $ class  BNRP_Rprime
> Purpose:
  | This structure is used to mark the top and bottom of the "clean" heap area. (ie. The garbage free heap area).  It has two memebers: 'top' and 'bottom' which are both longs
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: check
  $ #define check
> Purpose:
  | This flag is used to print out various warnings in the garbage collection code.  Useful for debugging purposes.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trail
  $ #define trail (te, addr)
> Purpose:
  | This macro puts the address of a term 'addr' and it's contents onto the end of a trail stack 'te'
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: simplebind
  $ #define simplebind (val, newval)
> Purpose:
  | This macro trails 'val' and then binds it to 'newval'
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | This macro determines if there is room on the heap for n items.  If there isn't enough room then a HEAPOVERFLOW error is reported to BNRP_RESUME().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: inR
  $ #define inR (addr)
> Purpose:
  | Determines whether an address of a term is in the region of the heap where garbage collection is being done
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: inRprime
  $ #define inRprime (addr)
> Purpose:
  | Determines whether an address of a term is in the "garbage free" copy of the heap.  Used for garbage collection.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
