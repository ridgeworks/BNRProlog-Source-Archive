#if 0
----------------------------------------------------------------------
> Global Function: checkHash ;
  $ voidcheckHash ()
> Purpose:
  | This function is used to check the hash table for duplicate values.  Used only to verify the correctness of the table.
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
> Global Function: hashString ;
  $ inthashString (char*)
> Purpose:
  | This function uses Peter K. Pearson's algorithm for fast hashing of variable length text strings as described in "Communictaions of the ACM" June 1990 Volume 33 Number 6.
> Calling Context:
  | 
> Return Value:
  | int - hash value of the string
> Parameters:
  = char* s - string to be hashed
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
> Data Item: hashTable
  $ int[] hashTable
> Purpose:
  | This is the hash table used by hashString().
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
