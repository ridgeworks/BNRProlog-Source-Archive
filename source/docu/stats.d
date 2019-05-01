#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initStats ;
  $ voidBNRP_initStats ()
> Purpose:
  | Initializes the headCount, bodyCount, and escapeCount arrays and the BNRPprimitiveCalls variable.
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
> Global Function: countUpHead ;
  $ longcountUpHead (int, int)
> Purpose:
  | Counts up and returns the total number of head opcodes executed between head opcode 'a' and 'b'.
> Calling Context:
  | 
> Return Value:
  | long
> Parameters:
  = int a - head opcode to start at
  = int b - head opcode to end at
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
> Global Function: countUpBody ;
  $ longcountUpBody (int, int)
> Purpose:
  | Counts up and returns the total number of body codes executed between body opcode 'a' and body opcode 'b'.
> Calling Context:
  | 
> Return Value:
  | long - T
> Parameters:
  = int a - body opcode to start
  = int b - body opcode to end at.
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
> Global Function: countUpEscape ;
  $ longcountUpEscape (int, int)
> Purpose:
  | Counts up the number of escape bytes executed between escape bytes 'a' and 'b'
  | inclusive.
> Calling Context:
  | 
> Return Value:
  | long
> Parameters:
  = int a - escape byte to start at
  = int b - escape byte to end at.
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
> Global Function: BNRP_getLIPS ;
  $ longBNRP_getLIPS ()
> Purpose:
  | Counts the number of logical inferences and primitive calls that the system has made.
> Calling Context:
  | 
> Return Value:
  | long
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
> Global Function: BNRP_printStats ;
  $ voidBNRP_printStats ()
> Purpose:
  | This function prints out the numbers of times each of the body opcodes, head opcodes and escape bytes have been called by the core engine.
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
> Data Item: headCount
  $ long[] headCount
> Purpose:
  | Stores the number of each different type of head WAM opcode that was called in the core.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: bodyCount
  $ long[][] bodyCount
> Purpose:
  | Stores the number of each different type of body WAM opcode that was called in the core.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: escapeCount
  $ long[][] escapeCount
> Purpose:
  | Stores the number of each different escape byte executed in the core.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPprimitiveCalls
  $ long BNRPprimitiveCalls
> Purpose:
  | Stores the number of primitive calls executed in the core.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
