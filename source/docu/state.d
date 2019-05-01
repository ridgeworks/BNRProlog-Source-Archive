#if 0
----------------------------------------------------------------------
> Struct:
  | freeRecord
  $ struct freeRecord
> Purpose:
  | This is the header for an unused section of memory in a stateSpace structure
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long bytesize - size of this unused section of memory
  = freeRecord* next - Pointer to the next unused section of memory in this stateSpace structure.
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
> Struct:
  | stateSpace
  $ struct stateSpace
> Purpose:
  | This is a chunk of memory inside of a state space.  This is below the stateHeader.  stateSpace structures are chained together.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = stateHeader* state - state we belong to
  = stateSpace* next - next chunk allocated in this state space
  = long size - size of this allocation
  = freeRecord* freep - first free space in this chunk
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
> Struct:
  | stateHeader
  $ struct stateHeader
> Purpose:
  | This is the header for a state space.  It is right below the tStateInfo structure.  it holds pointers to the array of rings and the first allocated chunk of memory that the state space has.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = ringHeader*[SMODULUS] hshtab - array of ringHeader entries organized by hash value
  = long tot_size - total size of the state space
  = stateSpace* firstSpace - first chunk of memory for the state space
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
> Struct:
  | spaceHeader
  $ struct spaceHeader
> Purpose:
  | Structure that heads a chunk of memory in the state space
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = stateSpace* space - stateSpace structure that this heads
  = long size - Size of the chunk of memory
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
> Struct:
  | ringHeader
  $ struct ringHeader
> Purpose:
  | This is used as a convenient way to organize strings with the same hash value.  They are stored inside of stateSpace structures.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = short tag - tag of the structure
  = short hash - hash of the ring.
  = ringHeader* next - next item in the ring
  = ringHeader* prev - previous item in the ring
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
> Struct:
  | stateString
  $ struct stateString
> Purpose:
  | These are placed in ringHeader structures, but they are allocated inside of stateSpace structures.  Typically they are the functor names of structure terms found in stateObjects.  They are organized in rings based on the hhash value of 'sym'
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = ringHeader link - ring that this stateString is in.
  = long refCount - number of things that reference this stateString
  = BNRP_term origContext - name of the context that 'sym' is associated with
  = symbolEntry sym - symbol containing the name of the stateString
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
> Struct:
  | stateObject
  $ struct stateObject
> Purpose:
  | These objects are placed in stateSpace structures.  These typically hold clauses associated with a stateString 'father'.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = short tag - Tag value of the object (always ObjT)
  = short filler - unused used as filler to make up a long with 'tag'
  = stateString* father - state string representing functor name of object
  = stateClauseEntry* cl - clause of object
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
> Struct:
  | stateClauseEntry
  $ struct stateClauseEntry
> Purpose:
  | Holds the clause information for the state space object
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = stateObject* obj - back pointer to the stateObject associated with this stateClauseEntry.
  = long xxfiller - used as a filler to align cl on a 8-byte boundary
  = clauseEntry cl - clause entry for the clause.
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
> Struct:
  | tStateInfo
  $ struct tStateInfo
> Purpose:
  | This structure holds details about a state space.  This is the top level structure of the state space structure heirarchy
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = BNRP_term stateSpaceName - symbolic term representing the name of the state space
  = stateHeader* stateSpaceMemory - Pointer to the allocated state space memory.
  = long contextGeneration - context that this state space is associated with
  = short stateSpaceSize - size of the state space
  = BNRP_Boolean Changed - TRUE if the state space has been modified.
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
> Global Function: nilOut ;
  $ voidnilOut (tStateInfo*)
> Purpose:
  | This function nils out a tStateInfo structure 's'.  This denotes an unused (but still allocated) tStateInfo record.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = tStateInfo* s - XXXXX_G_PAR
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
> Global Function: ComputeIndex ;
  $ BNRP_BooleanComputeIndex (BNRP_term, short*, BNRP_Boolean)
> Purpose:
  | This function finds the index of the state space that has the name 'ss'.  If the 'AddState flag is TRUE, then if it can't find the state space then it tries to create it.  It first searches for free spots in the StateInfo array.  If there isn't one, it allocates a new entry at the end of the array.  If 'AddState' is FALSE and the state space isn't found, FALSE is returned
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_term ss - name of the state space to find
  = short* Index - Index of the state space filled in by the function
  = BNRP_Boolean AddState - TRUE to add the state if not found
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
> Global Function: LocateStateSpace ;
  $ voidLocateStateSpace (short, BNRP_Boolean)
> Purpose:
  | This function sets the SSContext to be the contextGeneration of the stateSpace associated with the index 'Index'.  It also sets the currState variable to be the state space at 'Index'.  If 'changing' is TRUE, then the Changed field of the state space is set to TRUE.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = short Index - Index of the state space
  = BNRP_Boolean changing - TRUE to indicate that the state space will be changing.
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
> Global Function: RemoveStateSpace ;
  $ voidRemoveStateSpace (short)
> Purpose:
  | This funtion removes the state space at index 'Index' from the StateInfo array.
  | It also nil's out that record, and sets CurrentId to NilID and CurrentIndex to -1.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = short Index - XXXXX_G_PAR
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
> Global Function: BNRP_removeStateSpaces ;
  $ voidBNRP_removeStateSpaces (long)
> Purpose:
  | This function removes all state spaces down to generation 'generation'.  If 'generation' is 0 then the global state space is removed as well.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long generation - context generation to remove state spaces to.
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
> Global Function: allocSpaceInStateSpace ;
  $ void*allocSpaceInStateSpace (size_t)
> Purpose:
  | This function allocates a chunk of memory of size 'size' in the state space.  It first scans the free list of the current context for a freeRecord large enough.  If one with an exact fit is found it is converted into a spaceHeader.  If a freeRecord is found which is larger then 'size', then the freeRecord is modified to reflect it's reduced size.  If a freeRecord of the proper size couldn't be found, then we allocate a larger stateSpace.
> Calling Context:
  | 
> Return Value:
  | void* - Pointer to a chunk of state space memory of size 'size'
> Parameters:
  = size_t size - size in bytes of memory to allocate
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
> Global Function: deallocSpaceInStateSpace ;
  $ voiddeallocSpaceInStateSpace (void*)
> Purpose:
  | This function frees a section of memory in the current state space and adds it to the free list.  If there are neighbouring freeRecord's, it gets added to them to create a larger freeRecord.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void* it - Pointer to the object to be removed.
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
> Global Function: BNRP_NewStatespace ;
  $ BNRP_BooleanBNRP_NewStatespace (long, BNRP_term)
> Purpose:
  | This function creates a new state space with the name 'CheckID'.  If the state space already exists, then the function returns TRUE if 'size' matches the size of the state space.  f the sizes don't match, FALSE is returned.  If the state space doesn't exist then it is created and initialized.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean TRUE on success
> Parameters:
  = long size - Size of state space in Kb.
  = BNRP_term CheckID - Name of the state space
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
> Global Function: newRing ;
  $ ringHeader*newRing (short)
> Purpose:
  | This function allocates and initializes a new ring in the current state.  It is put in the hashtable of the current state at position 'hash'.  'hash' is typically the 'hash' value from a symbol.
> Calling Context:
  | 
> Return Value:
  | ringHeader* - Newly created ring in current context
> Parameters:
  = short hash - hash value of the new ring.
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
> Global Function: linkRing ;
  $ voidlinkRing (ringHeader*, ringHeader*)
> Purpose:
  | Links a new item 'it' to the ring associated with 'q'.  'it' is linked in after 'q'.  'it' must not have any links associated with it or a STATESPACEBADRING error will be generated in BNRP_RESUME().
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = ringHeader* q - item to add 'it' after
  = ringHeader* it - new item to be added to the ring associated with 'q'.
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
> Global Function: unlinkRing ;
  $ voidunlinkRing (ringHeader*)
> Purpose:
  | Unlinks the item 'it' from the ring.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = ringHeader* it - item to unlink from ring
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
> Global Function: stateSpaceFind ;
  $ stateString*stateSpaceFind (BNRP_term)
> Purpose:
  | Searches for the symbol term 't' in the current state space and returns the associated stateString if it is found.  If it isn't found NULL is returned.
> Calling Context:
  | 
> Return Value:
  | stateString* - stateString associated with 't'.
> Parameters:
  = BNRP_term t - symbol term to search for
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
> Global Function: stateSpaceLookup ;
  $ stateString*stateSpaceLookup (BNRP_term)
> Purpose:
  | This function looks up a symbol 't' in the current state space and returns the associated stateString.  If the symbol doesn't exist in the state space, then a new stateString is created and linked to a ring (or a new ring is created for the symbol's hash value) and the new stateString is returned.
> Calling Context:
  | 
> Return Value:
  | stateString* - stateString associated with 't'
> Parameters:
  = BNRP_term t - symbol term to find in the current state space.
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
> Global Function: incref ;
  $ voidincref (stateString*)
> Purpose:
  | This function increments the reference count for the stateString 's'.  If the ring associated with 's' does not have a string tag, then a STATESPACEBADTAG error is generated in BNRP_RESUME()
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = stateString* s - XXXXX_G_PAR
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
> Global Function: unref ;
  $ voidunref (stateString*)
> Purpose:
  | This function decrements the reference count on strings, and when it becomes zero it removes and deallocates itself from the ring.  Ifthe ring becomes empty, it is removed from the current state space and deallocated.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = stateString* s - XXXXX_G_PAR
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
> Global Function: removeClauseReferences ;
  $ voidremoveClauseReferences (stateClauseEntry*)
> Purpose:
  | This function scans 'cl' looking for stateStrings.  If it finds one, it decrements the reference count of the stateString. This is typically used when 'cl' is to be removed.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = stateClauseEntry* cl - stateClauseEntry to search for stateStrings
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
> Global Function: copyToStateSpace ;
  $ BNRP_BooleancopyToStateSpace (TCB*, BNRP_term, stateString**, stateClauseEntry**)
> Purpose:
  | This function copies a structure term x to the current state space.  The function puts the name of the structure into 'functor' and the clause entry for the structure into 'cl'.  The clause is compiled to WAM opcodes.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - Pointer to the task control block
  = BNRP_term x
  = stateString** functor
  = stateClauseEntry** cl - XXXXX_G_PAR
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
> Global Function: BNRP_lookupStateSpace ;
  $ BNRP_termBNRP_lookupStateSpace (long*, long*, long*)
> Purpose:
  | This function looks up a state space term at the address 'ppc'.  The first byte of 'ppc' is one of: opSymbolTag, opIntTag, or opFloatTag.  Following this is an encoding of the term (pointer to a stateString, a long, pointer to an fp).  The appropriate term is constructed and returned.  'ppc' is incremented to just past the term.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - term in the state space
> Parameters:
  = long* ppc - Pointer to the Prolog program counter
  = long* hp - pointer to the heap pointer
  = long* te - pointer to the end of the trail
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
> Global Function: checkClauseChain ;
  $ voidcheckClauseChain (clauseEntry*, char*)
> Purpose:
  | This function is only available if 'silly' is defined.  This function verifies that the clause chain starting at 'first' is correct.  Prints out 'msg' with each error that occurs.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = clauseEntry* first - start of the clause chain to verify.
  = char* msg - message to print out when errors occur
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
> Global Function: insertClauseBefore ;
  $ voidinsertClauseBefore (stateString*, clauseEntry*, clauseEntry*)
> Purpose:
  | This function inserts a clause 'object' in the clause chain associated with 'functor' before the clause 'nextCl'.  If 'nextCl' is NULL, then 'object' is added to the end of the clause chain of 'functor'.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = stateString* functor - functor whose clause chain is to be added to.
  = clauseEntry* object - clause to add to 'functor' clause chain
  = clauseEntry* nextCl - clause to add 'object' before.
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
> Global Function: unlinkClause ;
  $ voidunlinkClause (stateString*, clauseEntry*)
> Purpose:
  | This function unlinks the clause 'object' from the clause chains associated with 'functor'.  It does not deallocate the space associated with 'object'.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = stateString* functor - functor whose clause chains will be searched
  = clauseEntry* object - clauseEntry to be removed from 'functor' clause chains.
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
> Global Function: Remember ;
  $ BNRP_BooleanRemember (TCB*, BNRP_term, long*, BNRP_Boolean)
> Purpose:
  | This function stores a structure 'x' in the current state space.  If 'front' is true then it is added at the front of the clause chain for this functor.  Otherwise it's added to the end of the clause chain.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = BNRP_term x - structure term to be added
  = long* index - index of the new state space object filled in by function
  = BNRP_Boolean front - TRUE to add to front of chain, FALSE to add to end.
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
> Global Function: Replace ;
  $ BNRP_BooleanReplace (TCB*, long, BNRP_term)
> Purpose:
  | This function replaces an object with an address of 'l' with the structure term 'x' in the current state space.  The new term is copied into state space using the tcb.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise false.
> Parameters:
  = TCB* tcb - pointer to a task control block
  = long l - address of a state object
  = BNRP_term x - stucture term replacement.
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
> Global Function: Forget ;
  $ BNRP_BooleanForget (long)
> Purpose:
  | This function removes an object with an ID of 'l' from the current state space and frees up the associated space in the state space for re-use.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = long l - XXXXX_G_PAR
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
> Global Function: BNRP_newState ;
  $ BNRP_BooleanBNRP_newState (TCB*)
> Purpose:
  | This primitive creates a new state space or gets the size of a state space.  The first arguement is either a variable or the size in Kb of the state space.  The second arguement is optional.  If it exists then it's the name of the state space.  If it doesn't exist the global state space is either created or queried.  If there is a state space with the name given, then it's size is unified with the first arguement..  If the first arguement is 0 then the state space is removed.
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
> Global Function: BNRP_changedState ;
  $ BNRP_BooleanBNRP_changedState (TCB*)
> Purpose:
  | This primitive determines if the state space has changed.  If given 1 arguement, this is the name of the state space to to check.  If there aren't any arguements, then the global state space is checked.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the state space has changed.
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
> Global Function: inStateSpace ;
  $ BNRP_BooleaninStateSpace (long)
> Purpose:
  | Given a pointer to an object this function determines if the object is in the current state space.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the object is in the statespace.
> Parameters:
  = long addr - address of the object to search for
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
> Global Function: BNRP_getStateSpaceAtom ;
  $ BNRP_BooleanBNRP_getStateSpaceAtom (TCB*)
> Purpose:
  | This primitive gets a structure term from state space.  The first arguement is the pointer to the structure in the state space or a variable.  If is is a variable then the second arguement which is the symbol representing the functor of the structure must be instantiated.  The third arguement gets unified with the symbol representing the functor of the structure.  This symbol can then be used to get the body of the structure.  The fourth arguement is optional.  If it is present, then it's the name of the state space to do the lookup in.  If there are only 3 arguements, then the global state space is searched.
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
> Global Function: BNRP_newObj ;
  $ BNRP_BooleanBNRP_newObj (TCB*)
> Purpose:
  | This primitive creates a new state space object at the beginning of the chain for the functor of the structure being placed in state space.  The first arguement is a structure term to be put into state space.  The second arguement gets unified with the index of the structure in state space.  The third arguement (if there is one) is the name of the state space to put the object in.  If there isn't a third arguement, then the object is put into the global state space.
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
> Global Function: BNRP_zNewObj ;
  $ BNRP_BooleanBNRP_zNewObj (TCB*)
> Purpose:
  | This primitive creates a new state space object at the end of the chain for the functor of the structure being placed in state space.  The first arguement is a structure term to be put into state space.  The second arguement gets unified with the index of the structure in state space.  The third arguement (if there is one) is the name of the state space to put the object in.  If there isn't a third arguement, then the object is put into the global state space.
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
> Global Function: BNRP_putObj ;
  $ BNRP_BooleanBNRP_putObj (TCB*)
> Purpose:
  | This primitive replaces an object pointed to by the first arguement (integer) with the structure term in the second arguement.  The third arguement (optional) is the name of the state space to work in.  If there isn't a third arguement, the global state space is used.  The functor of the new object must be the same as that of the item being replaced.
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
> Global Function: BNRP_forgetObj ;
  $ BNRP_BooleanBNRP_forgetObj (TCB*)
> Purpose:
  | This primitive removes a structure whose index is given in the first arguement from the state space.  If there is a second arguement, then this is the name of the state space to do the action in.  If there is only one arguement, then the global state space is used.
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
> Global Function: BNRP_hashList ;
  $ BNRP_BooleanBNRP_hashList (TCB*)
> Purpose:
  | This primitive returns an inventory of the state strings held in the hash table at an index passed in as the first arguement.  The second arguement gets unified wit ha list of the strings at that hash index.  The third arguement (if present) is the name of the state space to look at.  Ifthere isn't a third arguement, then the global state space is searched.
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
> Global Function: BNRP_stateSpaceStats ;
  $ BNRP_BooleanBNRP_stateSpaceStats (TCB*)
> Purpose:
  | This primitive returns state space usage statistics.  If it has three arguements, then the last is the name of the state space to get statistics on. If it has two arguements, then statistics are generated for the global state space.  The first arguement is unified with the amount of memory that has been allocated and the second with the amount of space currently used in the state space.
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
> Global Function: BNRP_dumpSS ;
  $ BNRP_BooleanBNRP_dumpSS (TCB*)
> Purpose:
  | This primitive dumps the contents of a state space.  If it has zero arguements, then the global state space is dumped.  Otherwise, the first arguement is the name of the state space to dump.  The dump is done to stdout.  Structures in state space aren't dumped.
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
> Data Item: currState
  $ stateHeader* currState
> Purpose:
  | Pointer to the stateHeader of the current state.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: SSContext
  $ BNRP_term SSContext
> Purpose:
  | Index (generation) of the context containing the current state space.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: StateInfo
  $ tStateInfo* StateInfo
> Purpose:
  | This is the array of allocated state spaces.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: HiContext
  $ short HiContext
> Purpose:
  | This is the index of the last record in the StateInfo array.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: CurrentIndex
  $ short CurrentIndex
> Purpose:
  | This is the index into the StateInfo array for the state space that is currently in use.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: CurrentId
  $ BNRP_term CurrentId
> Purpose:
  | This is the name of the state space that is currently in use.
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
  | freeRecord
  $ typedef freeRecord freeRecord
> Purpose:
  | Type definition for the freeRecord structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | stateHeader
  $ typedef stateHeader stateHeader
> Purpose:
  | Type definition for the stateHeader structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | stateSpace
  $ typedef stateSpace stateSpace
> Purpose:
  | Type definition for the stateSpace structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | spaceHeader
  $ typedef spaceHeader spaceHeader
> Purpose:
  | Type definition for the spaceHeader structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | ringHeader
  $ typedef ringHeader ringHeader
> Purpose:
  | Type definition for the ringHeader structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | stateString
  $ typedef stateString stateString
> Purpose:
  | Type definition for the stateString structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | stateObject
  $ typedef stateObject stateObject
> Purpose:
  | Type definition for the stateObject structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | stateClauseEntry
  $ typedef stateClauseEntry stateClauseEntry
> Purpose:
  | Type definition for the stateClauseEntry structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | tStateInfo
  $ typedef tStateInfo tStateInfo
> Purpose:
  | Type definition for the tStateInfo structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: offsetof
  $ #define offsetof (TYPE, MEMBER)
> Purpose:
  | This macro determines the offset of an object MEMBER of type TYPE.  Only used if 'check' is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SMODULUS
  $ #define SMODULUS
> Purpose:
  | Number of ringHeader structures kept in the hshtab member of the stateHeader structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STATE_VERSION
  $ #define STATE_VERSION
> Purpose:
  | Unknown and UNUSED!
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: RingT
  $ #define RingT
> Purpose:
  | Used as a tag value to indicate an empty ringHeader.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ObjT
  $ #define ObjT
> Purpose:
  | Used as a tag value to indicate a structure term in a ringHeader
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: StrT
  $ #define StrT
> Purpose:
  | Used as a tag value to indicate a string in a ringHeader.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NilID
  $ #define NilID
> Purpose:
  | This is used to indicate that there isn't a current state space, or as values in a newly uninitialized state space.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GlobalId
  $ #define GlobalId
> Purpose:
  | This is the id of the global state space
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ReleaseStateSpace
  $ #define ReleaseStateSpace (x)
> Purpose:
  | This macro does nothing.  Why is it here?
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DefStateSize
  $ #define DefStateSize
> Purpose:
  | This is the minimum amount of memory that a state space can be increased by when new space needs to be allocated for it.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MaxPerCentIncr
  $ #define MaxPerCentIncr
> Purpose:
  | Maximum percentage increase in state space size when new space needs to be allocated for it.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opMaxReg
  $ #define opMaxReg
> Purpose:
  | Maximum number of registers that can be encoded with an opcode.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyAddr
  $ #define opUnifyAddr
> Purpose:
  | unif_address opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opNOP
  $ #define opNOP
> Purpose:
  | noop opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opAlloc
  $ #define opAlloc
> Purpose:
  | alloc opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opCopyTemp
  $ #define opCopyTemp
> Purpose:
  | copy_temp opcode to indicate that an item should be moved back into a register.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opGetStruct
  $ #define opGetStruct
> Purpose:
  | get_struct opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opGetList
  $ #define opGetList
> Purpose:
  | get_list opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opSSGetCons
  $ #define opSSGetCons
> Purpose:
  | get_cons_by_value opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opSSUnifyCons
  $ #define opSSUnifyCons
> Purpose:
  | unif_cons_by_value opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opSymbolTag
  $ #define opSymbolTag
> Purpose:
  | Indicates that a symbol appears next
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opIntTag
  $ #define opIntTag
> Purpose:
  | Indicates that an integer appears next.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opFloatTag
  $ #define opFloatTag
> Purpose:
  | Indicates that a float appears next
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opGetCons
  $ #define opGetCons
> Purpose:
  | get_cons opcode.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyCons
  $ #define opUnifyCons
> Purpose:
  | unify_cons opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opGetValt
  $ #define opGetValt
> Purpose:
  | get_valt opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opGetValp
  $ #define opGetValp
> Purpose:
  | get_valp opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyVart
  $ #define opUnifyVart
> Purpose:
  | unif_vart opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyVarp
  $ #define opUnifyVarp
> Purpose:
  | unif_varp opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyValt
  $ #define opUnifyValt
> Purpose:
  | unif_valt opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opUnifyValp
  $ #define opUnifyValp
> Purpose:
  | unif_valp opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opTUnifyVart
  $ #define opTUnifyVart
> Purpose:
  | tunif_vart opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opTUnifyVarp
  $ #define opTUnifyVarp
> Purpose:
  | tunif_varp opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opTUnifyValt
  $ #define opTUnifyValt
> Purpose:
  | tunif_valt opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opTUnifyValp
  $ #define opTUnifyValp
> Purpose:
  | tunif_valp opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opEndSeq
  $ #define opEndSeq
> Purpose:
  | end_seq opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opNeckCons1
  $ #define opNeckCons1
> Purpose:
  | neckcons opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opNeckCons2
  $ #define opNeckCons2
> Purpose:
  | neckcons opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opNeckCons3
  $ #define opNeckCons3
> Purpose:
  | neckcons opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opDealloc
  $ #define opDealloc
> Purpose:
  | dealloc opcode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: opProceed
  $ #define opProceed
> Purpose:
  | proceed opcode (neck)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addOpcode
  $ #define addOpcode (op)
> Purpose:
  | Pushes the value 'op' which is a byte code onto opptr. opptr is increased.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addOpcodeReg
  $ #define addOpcodeReg (op, r)
> Purpose:
  | This macro adds an opcode 'op' with a register 'r'.  If 'r' is less than opMaxReg, then the opcode and register are added with one call to addOpcode.  otherwise they are added separately (op first).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addENVRegister
  $ #define addENVRegister (r)
> Purpose:
  | This pushes an 'r' value onto opptr.  If r is less than twice the MAXREGS value, then it is reduced to a number between 1 and 256 and added.  Otherwise a zero oppcode is added and then r is added as an envExtension to opptr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addOpcodeEnv
  $ #define addOpcodeEnv (op, r)
> Purpose:
  | This macro adds an opcode to the environment.  'op' is typically opUnifyVal, opTUnifyVal, opTUnifyVar or opUnifyVar.  If 'r' is less than opMaxReg then a Vart opcode is added with 'r' in a single addOpcode call.  If it's less than MAXREGS, then a Vart opcode is added followed by the 'r' value.  If it's greater than this then a Varp opcode is added and the 'r' value is added by a call to addEnvRegister.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: validate
  $ #define validate (i, id)
> Purpose:
  | This macro gets the Id of the state space to use.  'i' is the maximum number of arguements that the tcb can have.  If there is i-1 arguements, then the Id of the global state space is put in 'id'.  Otherwise, if there aren't exactly i arguements, FALSE is returned.  If there are 'i' arguements then it gets the term at args[i] and puts it into 'id'.  This term must be a symbol or FALSE will be returned.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: findit
  $ #define findit (id, i, b)
> Purpose:
  | This macro finds the current index to the state space denoted by the symbol term 'id'.  If it is the currentID, then 'i' is set to CurrentIndex.  Otherwise, it searches the state space stack for the state with the name 'id'.  If it finds it, it's index is returned.  If it still isnt found, it adds a new state space and returns it's index if 'b' is TRUE.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: preamble
  $ #define preamble
> Purpose:
  | This is used to dump the arguements of a tcb with the name of the procedure.  It is used at the beginning of the primitives.  If executiontrace isn't defined, then this macro does nothing.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: alldone
  $ #define alldone (r)
> Purpose:
  | This is used to return a result 'r'.  If executiontrace is defined, then up to 5 tcb arguements are dumped with the name of the primitive.  If executiontrace isn't defined, then all this macro does is to return 'r'.  this is used when returning froma primitive.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: preamble
  $ #define preamble
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: alldone
  $ #define alldone (r)
> Purpose:
  | 
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
