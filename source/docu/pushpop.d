#if 0
----------------------------------------------------------------------
> Struct:
  | amStruct
  $ struct amStruct
> Purpose:
  | This structure isused to hold an AM record in the AM stack
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long key1 - first key of the record
  = long key2 - second key of the record
  = long dat - data associated with the record
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
> Global Function: BNRP_freeAM ;
  $ voidBNRP_freeAM (void)
> Purpose:
  | This function deallocates the space associated with the AM stack.  The BNRP_amBottom and BNRP_amTop pointers are not reset however.
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
> Global Function: pushAM ;
  $ voidpushAM (long, long, long)
> Purpose:
  | This function adds a new record to the top of the AM stack (the unprocessed section of the stack).  If the stack is full, an attempt to allocate more space is made.  if this attempt fails an OUTOFAMSPACE error is generated in BNRP_RESUME().
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long k1 - first key of the new AM record
  = long k2 - second key of the AM record
  = long d - data of the new AM record.
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
> Global Function: findAM ;
  $ BNRP_BooleanfindAM (long, long, long*)
> Purpose:
  | This function attempts to find an AM record in the "processed" section of the AM stack (a processed record is below BNRP_amBottom. Done by calls to nextAM).
  | It uses the 2 keys passed in to find the record.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = long k1 - first search key for the AM record
  = long k2 - second search key for the AM record
  = long* d - Data associated with the record if found.  Filled in by function.
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
> Global Function: searchAM ;
  $ BNRP_BooleansearchAM (long, long, long*)
> Purpose:
  | This function searches the entire AM stack (processed and unprocessed areas) for a record whose keys match 'k1' and 'k2'
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = long k1 - first key to search for
  = long k2 - second key to search for
  = long* d - Data of record found.  Filled in by function.
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
> Global Function: pullAM ;
  $ BNRP_BooleanpullAM (long*, long*, long*)
> Purpose:
  | The function fixes up the stack by moving all the objects it finds in the unprocessed section that have equivalents in the processed section, to the processed section of the stack.  This is done until the first record which doesn't have an equivalent is found.  This record is returned.  FALSE is returned if there isn't anything left on the unprocessed section of the stack
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE
> Parameters:
  = long* k1 - first key of AM record filled in by function
  = long* k2 - second key of AM record filled in by function
  = long* d - data of AM record filled in by function.
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
> Global Function: nextAM ;
  $ BNRP_BooleannextAM (long*, long*, long*)
> Purpose:
  | This function returns the next AM record from BNRP_amBottom.  The bottom of the AM stack is moved up hence decreasing the amount of unprocessed data in the AM stack.  The function fails if there is nothing in the unprocessed section of the AM stack.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE
> Parameters:
  = long* k1 - first key of the AM record filled in by function
  = long* k2 - second key into the AM record filled in by function
  = long* d - data of the record filled in by function
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
> Global Function: topAM ;
  $ BNRP_BooleantopAM (long*, long*, long*)
> Purpose:
  | This function returns the next AM record from BNRP_amBottom.  The bottom of the AM stack is not moved up.  The function fails if there is nothing in the unprocessed section of the AM stack.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = long* k1 - first key of the AM record filled in by function
  = long* k2 - second key of the AM record filled in by function
  = long* d - data of the record filled in by function
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
> Global Function: locateAM ;
  $ longlocateAM (long, long, long*)
> Purpose:
  | This function locates an AM record with a register that can be re-used.  It first searches through the processed section of the AM stack looking for a record with a first key of 'k1'.  If it finds one and key2 is not 0 (hence record is locked), it then checks to see if the record has been reused.  If so, it continues the search, if not then it returns the data of this AM record.  If the record isn't locked, it locks the record and returns the data of the record if the data is nonzero (still in a register).  Otherwise it allocates a new register (new, locked AM record of the smae key) using ++*newReg.  The negative of this data value is then returned.
  | If a record with 'k1' isn't found in the "processed records", the unprocessed records are then searched.  If a record isn't found, then one is created and the negative of the data is returned.  If it is found, then it's data is returned and the record is locked.
> Calling Context:
  | 
> Return Value:
  | long - register to use.  Negative value if it's a "new" register.
> Parameters:
  = long k1 - first key of object to locate
  = long k2 - second key of object to locate
  = long* newReg - register to use
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
> Global Function: main ;
  $ main ()
> Purpose:
  | This is only available if 'test' is defined.  It is used to test the AM functions.
> Calling Context:
  | 
> Return Value:
  | No return value...
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
> Data Item: BNRP_am
  $ amStruct* BNRP_am
> Purpose:
  | A pointer to an array of amStruct structures.  This is the AM stack.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_amTop
  $ long BNRP_amTop
> Purpose:
  | Index to the top pf the AM stack.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_amBottom
  $ long BNRP_amBottom
> Purpose:
  | Index to the bottom of the AM stack.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_amMax
  $ long BNRP_amMax
> Purpose:
  | The maximum number of amStruct's that BNRP_am can currently hold.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trace
  $ #define trace
> Purpose:
  | This is set if 'test' is defined.  Allows tracing information to be printed out.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_pushpop
  $ #define _H_pushpop
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: clearAM
  $ #define clearAM ()
> Purpose:
  | Clears both indices into BNRP_am.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: resetAM
  $ #define resetAM ()
> Purpose:
  | Resets the bottom index of BNRP_am.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: discardLastAM
  $ #define discardLastAM ()
> Purpose:
  | Discards the last item put onto BNRP_am.  Prevents further AM operations on it.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: discardTopAM
  $ #define discardTopAM ()
> Purpose:
  | Discards the top item on BNRP_am.  Prevents further AM operations on it.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: freeAM
  $ #define freeAM ()
> Purpose:
  | If there are more than 200 items on BNRP_am then deallocate BNRP_am
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
