#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initMemory ;
  $ voidBNRP_initMemory ()
> Purpose:
  | This function sets up BNRP_baseOffset for those platforms that need to have their memory allocation adjusted.
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
> Global Function: BNRP_allocMemory ;
  $ intBNRP_allocMemory (TCB*, long, long)
> Purpose:
  | This allocates the heap/trail and environment/choice point stacks for a task control block.  Both heapAndTrail and envAndCP are in bytes.  This function also makes sure that the top three bits aren't set on free allocated addresses.  The top three bits are used by Prolog to store tag values.  This function also sets up the pointers associated with the ends starts and current positions of the heap, trail, environment, choicepoint stacks.
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = TCB* tcb
  = long heapAndTrail
  = long envAndCP - XXXXX_G_PAR
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
> Global Function: BNRP_disposeMemory ;
  $ voidBNRP_disposeMemory (TCB*)
> Purpose:
  | This function disposes of the memory allocated by BNRP_initMemory() and resets some of the TCB variables associated with this allocated memory.
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
> Data Item: BNRP_baseOffset
  $ long BNRP_baseOffset
> Purpose:
  | This is the offset associated with memory addresses.  This is used by the addrof and maketerm macros.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_adjusted
  $ int BNRP_adjusted
> Purpose:
  | This is set if there is an offset specified in BNRP_baseOffset.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
