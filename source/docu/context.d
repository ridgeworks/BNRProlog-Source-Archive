#if 0
----------------------------------------------------------------------
> Struct:
  | freeRecord
  $ struct freeRecord
> Purpose:
  | This structure is the header for a free space in a contextSpace.  These freeRecords are used when we need to "allocate" more space in a context.  if there is a freeRecord big enough for the new object then it gets used.  Saves having to allocate new contextSpaces.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long size - size of the freeRecord space
  = freeRecord* next - The next freeRecord in the chain for a contextSpace.
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
  | undoRecord
  $ struct undoRecord
> Purpose:
  | This structure is used to restore values in contexts other than the current context when the current context is being removed.  This trailing is done when a change is made in the current context to an object that belongs in another context.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long addr - address of the value being trailed.
  = long mask - mask to isolate only the bits that changed
  = long oldvalue - original value of the thing that changed
  = undoRecord* next - Pointer to the next undoRecord in the chain
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
  | contextSpace
  $ struct contextSpace
> Purpose:
  | This structure heads a chunk of allocated space in a context.  It can be filled with a number of objects that have a spaceHeader header.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = contextHeader* context - context associated with this context Space
  = contextSpace* next - next contextSpace in the context
  = contextSpace* self - self reference
  = long size - size of this contextSpace allocation
  = freeRecord* freep - pointer to the first free space in this chunk
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
  | contextHeader
  $ struct contextHeader
> Purpose:
  | This is the standard header for a context.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long ident1 - symbol term representing the first name of the context
  = long ident2 - symbolterm representing the second name of the context
  = contextHeader* self - self reference
  = long generation - the generation number of the context
  = symbolEntry*[PERMTABLEMODULUS] permSymbols - permanent global symbol chain
  = symbolEntry* localSymbols - permanent local symbol chain
  = symbolEntry* tempPermSymbols - temporary global symbol chain
  = symbolEntry* tempLocalSymbols - temporary local symbol chain
  = contextSpace* firstSpace - Pointer to the first contextSpace structure of the context.
  = contextHeader* prevContext - Pointer to parent context in context chain
  = undoRecord* undoChain - Start of undo chain for the context.
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
  | This is the header of a chunk of memory in a contextSpace.  It is the header for all structures in the contextSpace. (ie. symbols, clauses, etc...)
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = contextSpace* space - pointer to the contextSpace that this spaceHeader is in
  = long size - Size of the object that the spaceHeader heads plus the size of spaceHeader.
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
> Global Function: allocSpaceInContext ;
  $ void*allocSpaceInContext (contextHeader*, size_t)
> Purpose:
  | This function allocates room for an object of 'size' in the context 'c'.  It first searches for a freeRecord that is big enough for the object.  If the freeRecord is too large, then the freeRecord is modified to be the free space left over.  If there isn't a freeRecord large enough, then incrementBase bytes are allocated for new contextSpace records.  This is then linked to 'c' and the new object is taken from this newly created space.
> Calling Context:
  | 
> Return Value:
  | void* - Pointer to the newly created space.
> Parameters:
  = contextHeader* c - Pointer to a contextHeader
  = size_t size - Amount of space to allocate.
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
> Global Function: deallocSpaceInContext ;
  $ voiddeallocSpaceInContext (void*)
> Purpose:
  | This function deallocates a block of memory associated with a pointer 'it'.  'it' typically points to a symbolEntry or a clauseEntry.  Deallocating this space creates a freeRecord.  If there are any adjacent freeRecord's, then this gets merged with them to form a single freeRecord.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void* it - Pointer to an object to be deallocated from the contexts.
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
> Global Function: BNRPMakePermInt ;
  $ BNRP_termBNRPMakePermInt (long)
> Purpose:
  | This function allocates an integer term in the current context.  If space can't be allocated then NULL is returned.  This function uses the optimal integer encoding depending on 'value'.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - integer term created in current context.
> Parameters:
  = long value - value of the integer to be turned into an integer term.
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
> Global Function: BNRPMakePermFloat ;
  $ BNRP_termBNRPMakePermFloat (fp*)
> Purpose:
  | This function allocates a float term in the current context.  If space can't be allocated then NULL is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - floating point term created.
> Parameters:
  = fp* value - Pointer to fp to be turned into a term.
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
> Global Function: newSymbol ;
  $ symbolEntry*newSymbol (contextHeader*, char*, unsigned char)
> Purpose:
  | This function allocates and initializes a new symbolEntry in the context associated with 'c'.  If space can't be allocated then NULL is returned.
> Calling Context:
  | 
> Return Value:
  | symbolEntry* - Pointer to the newly created symbolEntry
> Parameters:
  = contextHeader* c - Context to add the symbol to.
  = char* s - name of the new symbol.
  = unsigned char h - hash value of 's'.
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
> Global Function: contextTrail ;
  $ voidcontextTrail (void*, long, contextHeader*)
> Purpose:
  | This is used when a change is made to something which doesn't belong to the current context.  This is done so that when the context is removed, the old values of things in other contexts can be restored.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void* addr - address of the item that will be changed
  = long mask - mask used to isolate the bits that changed
  = contextHeader* p - Pointer to the contextHeader of the context where the change is being made.
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
> Global Function: initializeContexts ;
  $ voidinitializeContexts ()
> Purpose:
  | This function sets the topContext, currContext and baseContext.self variables to the address of baseContext.  The members of baseContext are then initialized.
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
> Global Function: BNRPSetBaseFileName ;
  $ voidBNRPSetBaseFileName (char*)
> Purpose:
  | Sets the name of the base context to the symbolic form of 's'.  Turns 's' into a permanent global and sets the baseContext's ident2 member to this symbol.  Initializes the contexts if required.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* s - string to set the base context's second name to.
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
> Global Function: BNRP_setContext ;
  $ BNRP_BooleanBNRP_setContext (long, long)
> Purpose:
  | Sets the current context (currContext) to be the context with names 'name1' and 'name2'.  If it doesn't exist FALSE is returned.  Initializes the contexts if required.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = long name1 - symbolic term representing the first name of the context.
  = long name2 - symbolic term representing the second name of the context.
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
> Global Function: BNRPnewContext ;
  $ BNRP_BooleanBNRPnewContext (long, long)
> Purpose:
  | Creates a new context and links it to the end of the context chain.  Allocates and initializes all of the contextHeader members.  contextGeneration gets incremented.  'name1' and 'name2' get promoted to permanent global symbols.  If a context with names of 'name1' and 'name2' exists, then FALSE is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE
> Parameters:
  = long name1 - symbolic term representing the first name of the context
  = long name2 - symbolic term representing the second name of the context.
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
> Global Function: removeContext ;
  $ BNRP_BooleanremoveContext (TCB*, long, long)
> Purpose:
  | This function removes a context (denoted by name1 and name2) from the context chain.  Before doing this it checks the choicepoints for any dangling references that would be created after the removal of the context.  It also scans the environments for possible dangling references and removes any terms on the trail that are associated with the context.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = long name1 - symbolic term representing the first name of the context to be removed
  = long name2 - symbolic term representing the second name of the context to be removed.
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
> Global Function: BNRP_removeAllContexts ;
  $ voidBNRP_removeAllContexts (void)
> Purpose:
  | This function removes all of the contexts that have been allocated and free's the space associated with them.
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
> Global Function: BNRP_parentContext ;
  $ BNRP_BooleanBNRP_parentContext (long, long, long*, long*)
> Purpose:
  | Returns the names of the context that is the parent of the context with the names 'name1' and 'name2'.  FALSE will be returned if the context doesn't have a parent.  This function initializes the contexts if they haven't been initialized already.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, FALSE otherwise
> Parameters:
  = long name1 - symbolic term representing first name of context
  = long name2 - symbolic term representing second name of context
  = long* pname1 - symbolic name representing first name of parent context
  = long* pname2 - symbolic name representing second name of parent context
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
> Global Function: BNRP_addClause ;
  $ clauseEntry*BNRP_addClause (BNRP_term, long, long, long, void*, BNRP_Boolean)
> Purpose:
  | This function adds a clause or a primitive.  The current context must be the top context.  The 'addFront' option allows us to either add the newclause to the start or the end of the clause chain associated with 'pred'.  If 'arity', 'key' and 'size' are all zero, then the clause is added as a primitive.  The clause chain of 'pred' must be zero to define a primitive.  Attempts to redefine primitives will result in a return value of NULL.
> Calling Context:
  | 
> Return Value:
  | clauseEntry* - Pointer to the new clause entry.
> Parameters:
  = BNRP_term pred - symbol term associated with the clause
  = long arity - arity of the clause
  = long key - key associated with the start of the clause
  = long size - size of the clause
  = void* data - pointer to the start of the clause
  = BNRP_Boolean addFront - TRUE to add at front of clause chain, FALSE to add to the end of the chain.
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
> Global Function: BNRP_insertClause ;
  $ BNRP_BooleanBNRP_insertClause (BNRP_term, long, long, void*)
> Purpose:
  | This function inserts a clause into the clause chain associated with the symbol 'pred'.  The current context must also be the top context.  Failure will be reported if an attempt to redefine a primitive is made.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_term pred - symbol term associated with the clause
  = long arity - arity of the clause
  = long key - key associated with 'data'
  = void* data - Pointer to the start of the clause.
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
> Global Function: BNRP_removeClause ;
  $ BNRP_BooleanBNRP_removeClause (BNRP_term, clauseEntry*)
> Purpose:
  | This function removes a clause from the top context which must also be the current context.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_term pred - a symbol term which is associated with a clause
  = clauseEntry* c - Pointer to the clause entry to be removed.
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
> Global Function: BNRP_contextOf ;
  $ longBNRP_contextOf (void*, long*, long*)
> Purpose:
  | This function takes a symbol and finds the context names associated with that symbol.  It also returns the context's generation.
> Calling Context:
  | 
> Return Value:
  | long - generation of the context
> Parameters:
  = void* clp - typically a pointer to a symbolEntry
  = long* name1 - first name of the context filled in by function.
  = long* name2 - second name of the context filled in by function.
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
> Global Function: chaseChain ;
  $ symbolEntry*chaseChain (symbolEntry*, char*, unsigned char)
> Purpose:
  | This function searches the local symbol chain associated with 'first' for a symbol with a hash value of 'h' and a name of 's'.
> Calling Context:
  | 
> Return Value:
  | symbolEntry* - Symbol associated with 's' and 'h'.  NULL if the symbol can't be found.
> Parameters:
  = symbolEntry* first - Pointer to a symbolEntry whose local chain will be searched.
  = char* s - string to search for
  = unsigned char h - hash value to search for.
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
> Global Function: chasePermChain ;
  $ symbolEntry*chasePermChain (symbolEntry*, char*)
> Purpose:
  | This function chases down a permanent symbol chain associated with 'first' for a symbol with the name 's'
> Calling Context:
  | 
> Return Value:
  | symbolEntry* - symbol entry associated with 's'.  NULL if it can't be found.
> Parameters:
  = symbolEntry* first - pointer to a permanent symbol entry whose chain will be searched.
  = char* s - string to search for.
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
> Global Function: chaseTempChain ;
  $ symbolEntry*chaseTempChain (symbolEntry**, char*, int)
> Purpose:
  | This function searches the temporary chain associated with a symbolEntry 'first' for a symbol whose name is 's' and whose hash value is 'h'.  As it does this, it removes any UNUSED entries that it encounters.
> Calling Context:
  | 
> Return Value:
  | symbolEntry* - Symbol entry on the chain 'first' with a name of 's' and hash 'h'.  NULL if it can't be found.
> Parameters:
  = symbolEntry** first - pointer to a pointer to a symbol entry
  = char* s - string to search for
  = int h - hash value to search for
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
> Global Function: BNRPMakeSymbol ;
  $ BNRP_termBNRPMakeSymbol (int, char*, BNRP_Boolean, BNRP_Boolean, long*, long)
> Purpose:
  | This function looks up or creates a new symbol (if it doesn't exist) using the hash value 'h' which is associated with the string 's'.  'h' is ussually calculated by: hashString(S) & (PERMTABLEMODULUS - 1)
> Calling Context:
  | 
> Return Value:
  | BNRP_term - symbol term associated with 's'.
> Parameters:
  = int h - hash value associated with the string 's'
  = char* s - string to look up
  = BNRP_Boolean temp - TRUE if temporary, FALSE if permanent
  = BNRP_Boolean global - TRUE if global, FALSE if local
  = long* te - Pointer to the end of the trail (ie. &tcb->te)
  = long contextGeneration - which context to search for local symbols in.  0 for current context.
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
> Global Function: BNRPLookupSymbol ;
  $ BNRP_termBNRPLookupSymbol (TCB*, char*, BNRP_Boolean, BNRP_Boolean)
> Purpose:
  | This function either looks up or creates a symbol (if not found) on one of the chains specified by 'temp' and 'global'
> Calling Context:
  | 
> Return Value:
  | BNRP_term - a symbol term associated with 's'
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = char* s- string to look up
  = BNRP_Boolean temp - TRUE if temporary, FALSE if permanent
  = BNRP_Boolean global - TRUE if global, FALSE if local
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
> Global Function: BNRPLookupPermSymbol ;
  $ BNRP_termBNRPLookupPermSymbol (char*)
> Purpose:
  | This function returns a permanent symbol with the name 's'.  If 's' start with a '$' then a permanent local symbol is returned, otherwise a permanent global is returned.  The function first searches to see if the symbol is already defined and if so returns the symbol, otherwise it creates a new symbol to be associated with 's'.  This function also initializes the contexts if it hasn't already been done.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - permanent symbol term associated with 's'
> Parameters:
  = char* s - string to be turned into a permanent symbol
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
> Global Function: BNRPLookupTempSymbol ;
  $ BNRP_termBNRPLookupTempSymbol (TCB*, char*)
> Purpose:
  | This function returns a temporary symbol with the name 's'.  If 's' start with a '$' then a temporary local symbol is returned, otherwise a temporary global is returned.  The function first searches to see if the symbol is already defined and if so returns the symbol, otherwise it creates a new symbol to be associated with 's'.  This function also initializes the contexts if it hasn't been done already.  The 'tcb' is used to trail the fact that the symbol used to be "UNUSED", so that this state can be restored.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - term associated with 's'
> Parameters:
  = TCB* tcb - pointer to a task control block.
  = char* s - string to be turned into a symbol
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
> Global Function: BNRPFindSymbol ;
  $ BNRP_BooleanBNRPFindSymbol (char*, BNRP_Boolean, BNRP_term*)
> Purpose:
  | This function finds the symbol associated with a string 's' in either the global or local (current context) symbol chains.  If it can't find the symbol then NULL is returned and *atom is undefined.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the symbol 
> Parameters:
  = char* s - string to search symbol chains for
  = BNRP_Boolean global - TRUE to search in global chains, otherwise FALSE
  = BNRP_term* atom - Pointer to the symbol term filled in by the function. 
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
> Global Function: BNRP_cleanupTempSymbols ;
  $ voidBNRP_cleanupTempSymbols (void)
> Purpose:
  | This function cleans out all of the UNUSED symbol entries in the temporary global and temporary local symbol chains of the current context.
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
> Global Function: BNRP_setLocked ;
  $ BNRP_BooleanBNRP_setLocked (BNRP_term, BNRP_Boolean)
> Purpose:
  | This function sets the locked flag of a symbol 'symbol' to newval.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - FALSE if 'symbol' is not a symbol term
> Parameters:
  = BNRP_term symbol - a symbol term
  = BNRP_Boolean newval - value to set the locked flag to.
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
> Global Function: BNRP_setClosed ;
  $ BNRP_BooleanBNRP_setClosed (BNRP_term, BNRP_Boolean)
> Purpose:
  | This function sets the closed flag of a symbol 'symbol' to newval.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - FALSE is 'symbol' is not a symbol
> Parameters:
  = BNRP_term symbol - a symbol term
  = BNRP_Boolean newval - value to set the closed flag to.
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
> Global Function: BNRP_setDebug ;
  $ BNRP_BooleanBNRP_setDebug (BNRP_term, short)
> Purpose:
  | This functionsets the debug flags of the symbol 'symbol' to 'newval'.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - FALSE is 'symbo'l isn't a symbol term
> Parameters:
  = BNRP_term symbol - a symbol term
  = short newval - New value to set the symbol's debug flags to.
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
> Global Function: BNRP_queryLocked ;
  $ BNRP_BooleanBNRP_queryLocked (BNRP_term)
> Purpose:
  | This function determines if a symbol's definition is hidden.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the symbol's definition is hidden
> Parameters:
  = BNRP_term symbol - a symbol term.
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
> Global Function: BNRP_queryClosed ;
  $ BNRP_BooleanBNRP_queryClosed (BNRP_term)
> Purpose:
  | This function returns whether or not a symbol's definition is closed or not
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if symbol is closed.
> Parameters:
  = BNRP_term symbol - a symbol term
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
> Global Function: BNRP_queryDebug ;
  $ shortBNRP_queryDebug (BNRP_term)
> Purpose:
  | This function returns the debug flags of the symbol 'symbol'
> Calling Context:
  | 
> Return Value:
  | short
> Parameters:
  = BNRP_term symbol - a symbol term.
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
> Global Function: BNRP_addOperator ;
  $ BNRP_BooleanBNRP_addOperator (BNRP_term, int, int)
> Purpose:
  | Adds a new operator definition to a symbol.  This function makes sure that the new type does not conflict with the current operator types associated with the symbol.  It also makes sure that the precedences are the same.  If they aren't then FALSE is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_term symbol - operator symbol to add the definition to
  = int newType - operator type to add
  = int newPrecedence - precedence of the new operator.
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
> Global Function: BNRP_makeSymbolPermanent ;
  $ voidBNRP_makeSymbolPermanent (BNRP_term)
> Purpose:
  | This function makes a temporary symbol into a permanent one in the same context.  If the symbol is a temporary global, it is made into a permanent global.  If it is a temporary local, it's made into a permanent local symbol.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = BNRP_term symbol - temporary symbol to be made into a permanent symbol.
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
> Global Function: BNRP_contextSpaceUsed ;
  $ voidBNRP_contextSpaceUsed (long*, long*, long*)
> Purpose:
  | This function returns the amount of memory that has been allocated to the contexts, the amount of context space currently being used (over all the contexts) and the number of symbols that are being used. (Including the global permanent symbols).
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long* allocated - pointer to where space allocated gets filled in
  = long* used - pointer to where space used gets filled in
  = long* nsym - pointer to where number of symbols in use gets filled in
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
> Global Function: BNRP_enterContext ;
  $ BNRP_BooleanBNRP_enterContext (TCB*)
> Purpose:
  | This primitive creates a new context on top of the old ones using the two arguements passed in as the names for the context.
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
> Global Function: BNRP_exitContext ;
  $ BNRP_BooleanBNRP_exitContext (TCB*)
> Purpose:
  | This primitive removes the context specified in the arguements.  The primitive has two arguements which are the identifiers of the context.
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
> Global Function: BNRP_listContexts ;
  $ BNRP_BooleanBNRP_listContexts (TCB*)
> Purpose:
  | This primitive has a single arguement which is unified with a list of all the contexts (both names of each context is included).
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
> Global Function: BNRP_getNextSymbol ;
  $ symbolEntry*BNRP_getNextSymbol (symbolEntry*)
> Purpose:
  | This function gets the next INUSE symbol entry from 'p'.  If 'p' is NULL, then all the chains are searched for an INUSE entry.  If none is found then a NULL pointer is returned.  If 'p' is not NULL then the search starts on the chain that 'p' is on.
> Calling Context:
  | 
> Return Value:
  | symbolEntry* - Pointer to the next INUSE symbol entry.  NULL if none is found.
> Parameters:
  = symbolEntry* p - Symbol entry to start search from.  Can be NULL.
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
> Global Function: BNRP_setAllDebugBits ;
  $ voidBNRP_setAllDebugBits (long, long)
> Purpose:
  | This function sets the debug flags of the permanent symbols and local symbols in the top context according to the 'andmask' and 'ormask' masks passed in.  Local symbols in the base context are not touched if the top context isn't the base.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long andMask
  = long orMask - XXXXX_G_PAR
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
> Global Function: BNRP_isPrimitive ;
  $ BNRP_BooleanBNRP_isPrimitive (TCB*)
> Purpose:
  | This primitive determines if a symbol is associated with a primitive.  It has a single arguement which is the symbol to be checked.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the symbol is associated with a primitive.
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
> Global Function: BNRP_predicateSymbol ;
  $ BNRP_BooleanBNRP_predicateSymbol (TCB*)
> Purpose:
  | This primitive determines if a symbol is associated with a predicate. It has a single arguement which is the symbol to be checked.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the symbol is associated with a predicate.
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
> Global Function: BNRP_prevPredicate ;
  $ BNRP_BooleanBNRP_prevPredicate (TCB*)
> Purpose:
  | This primitive has the same functionality as BNRP_prevSymbol() except that a check is made to see if the symbol has a clasue associated with it as well.  If it doesn't then the search continues.
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
> Global Function: BNRP_prevSymbol ;
  $ BNRP_BooleanBNRP_prevSymbol (TCB*)
> Purpose:
  | This primitive finds a symbol.  It can either have one or two arguements.  If it has one arguement, it returns the first symbol it encounters while searching the following symbol chains in order: 
  | - context's permanent symbols
  | - context's local symbols
  | - context's temporary permanent symbols
  | - context's temporary local symbols.
  | If it has two arguements the first is a symbol, while the second is unified with the next symbol found from the symbol in the first arguement.  The symbol chains are searched as follows:
  | - chain of the symbol in the first arguement
  | - rest is as above.
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
> Global Function: BNRP_closeDefinition ;
  $ BNRP_BooleanBNRP_closeDefinition (TCB*)
> Purpose:
  | This primitive closes the definition of a symbol.  The single arguement is the symbol whose definition is to be closed.
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
> Global Function: BNRP_closedDefinition ;
  $ BNRP_BooleanBNRP_closedDefinition (TCB*)
> Purpose:
  | This primitive determines whether or not a symbol's definition is "closed".  It has one arguement which is the symbol whose definition we are checking to determine if it is closed.
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
> Global Function: BNRP_hideDefinition ;
  $ BNRP_BooleanBNRP_hideDefinition (TCB*)
> Purpose:
  | This primitive hides the definition of a symbol.  It has one arguement which is the symbol whose definition is to be hidden.
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
> Global Function: BNRP_notHiddenDefinition ;
  $ BNRP_BooleanBNRP_notHiddenDefinition (TCB*)
> Purpose:
  | This primitive has a single arguement which is a symbol.  The primitive returns whether or not the definition is hidden
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the symbol definition is not hidden.
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
> Global Function: BNRP_getContextOf ;
  $ BNRP_BooleanBNRP_getContextOf (TCB*)
> Purpose:
  | This primitive finds the context names associated with an identifier.  It has three arguements, the first being the context identifier and the second and third are symbols which are unified with the context's names.
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
> Data Item: baseContext
  $ contextHeader baseContext
> Purpose:
  | Points to the context header of the first context created (typically the "base" context).
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: topContext
  $ contextHeader* topContext
> Purpose:
  | Points to the contextHeader of the most recently created context (the top one...)
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: currContext
  $ contextHeader* currContext
> Purpose:
  | Points to the contextHeader of the current context.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: incrementBase
  $ size_t incrementBase
> Purpose:
  | This is the amount of memory to allocate when more space is required in a context.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: contextGeneration
  $ long contextGeneration
> Purpose:
  | Stores the number of contexts that are currently present.
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
  | undoRecord
  $ typedef undoRecord undoRecord
> Purpose:
  | Type definition for the undoRecord structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | contextSpace
  $ typedef contextSpace contextSpace
> Purpose:
  | Type definition for the contextSpace structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | contextHeader
  $ typedef contextHeader contextHeader
> Purpose:
  | Type definition of the contextHeader structure.
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
  | Type definition of the spaceHeader structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DEBUGSTR
  $ #define DEBUGSTR (s)
> Purpose:
  | This macro prints out a debug string 's' on Macintosh platforms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DEBUGSTR
  $ #define DEBUGSTR (s)
> Purpose:
  | Only applicable on Macintosh platforms.  See above.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_context
  $ #define _H_context
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: PERMTABLEMODULUS
  $ #define PERMTABLEMODULUS
> Purpose:
  | This is the maximal number of permanent variables allowed
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
