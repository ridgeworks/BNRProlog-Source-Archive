#if 0
----------------------------------------------------------------------
> Global Function: BNRP_embedSymbol ;
  $ longBNRP_embedSymbol (char*)
> Purpose:
  | Embeds a symbol term into the current context.
> Calling Context:
  | 
> Return Value:
  | long - symbol term
> Parameters:
  = char* symbol - String that will be turned into a symbol
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
> Global Function: BNRP_embedInt ;
  $ longBNRP_embedInt (long)
> Purpose:
  | Embeds an integer into the current context
> Calling Context:
  | 
> Return Value:
  | long - integer term
> Parameters:
  = long i - integer to be embedded
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
> Global Function: BNRP_embedFloat ;
  $ longBNRP_embedFloat (double)
> Purpose:
  | Embeds a float into the current context.
> Calling Context:
  | 
> Return Value:
  | long - float term
> Parameters:
  = double f - float to be embedded.
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
> Global Function: BNRP_lookupOp ;
  $ BNRP_BooleanBNRP_lookupOp (char*, short*, BNRP_Boolean*)
> Purpose:
  | This string verifies an operator definition.  The 'p' arguement holds a string containing a type definition (eg "new xfx", "fx", "new fx xfx", etc).  The function translates 'p' into an integer type value (returned in ty) and a boolean (returned in 'new') which indicates if the new string was found or not.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if ty was a valid type definition
> Parameters:
  = char* p - operator type string to be translated
  = short* ty - integer type value filled in by function
  = BNRP_Boolean*  new - TRUE if "new" was contained in 'p'.
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
> Global Function: BNRP_embedOperator ;
  $ voidBNRP_embedOperator (char*, long, char*)
> Purpose:
  | Embeds an operator into the current context.  It also adds the operator defintion to the system.  If the operator is already defined, then it checks for type and precedence conflicts.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* operator - name of the operator
  = long precedence - precedence of the operator
  = char* type - type definition of the operator (eg "new fx xfx", "fx", etc)
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
> Global Function: BNRP_embedContext ;
  $ voidBNRP_embedContext (char*, long)
> Purpose:
  | Sets up to embed a context into the system.  If the BNRP_embedIgnoreContext flag is not set, then a new context is created with the name "sontextname".  otherwise we just create a $local symbol so that later on we can determine the context of a clause.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* contextname - Name of the context to be embedded
  = long version - must be 1 (not sure why...)
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
> Global Function: BNRP_embedClause ;
  $ voidBNRP_embedClause (char*, long, long, long*)
> Purpose:
  | Embeds a clause into the system. The clauseStart arguement points to the clauseEntry data.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* predicate - name of the clause to be inserted
  = long arity - number of arguements the clause has
  = long hash - hash of the clause.  If -1 then function determines a hash
  = long* clauseStart - Pointer to the start of the clauseEntry
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
> Data Item: BNRP_embedIgnoreContext
  $ int BNRP_embedIgnoreContext
> Purpose:
  | If this flag is not set then embedded contexts will be made into it's own context, otherwise it gets "consulted".
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_embedLastContext
  $ char[] BNRP_embedLastContext
> Purpose:
  | This string contains the name of the last embedded context.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
