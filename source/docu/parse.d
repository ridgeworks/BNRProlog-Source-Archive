#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initializeParser ;
  $ voidBNRP_initializeParser ()
> Purpose:
  | This function initializes the charClass, stt, and sat tables for parsing.  This must be done before the parsing begins in BNRP_parse().  (BNRP_parse does this in the first few lines of code)
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
> Global Function: BNRP_stringToLong ;
  $ BNRP_BooleanBNRP_stringToLong (char*, long*)
> Purpose:
  | This function converts a string to a long integer.  It is presumed that 's' will not contain a minus sign.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = char* s - stringto be converted
  = long* res - long integer form of 's' filled in by function
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
> Global Function: lookupVariable ;
  $ longlookupVariable (variableEntry*, long*)
> Purpose:
  | This function is used to look up variables using 's'.  If the name found in 's' is "_" then an anonymous variable term is created on the heap and returned.  If not, it then searches 'varChain' for the variable comparing the hashes and the names of the variables.  If it is found, the variable term is returned.  If it isn't found, 's' is fully instantiated, added to varChain, and the variable term is returned.
> Calling Context:
  | 
> Return Value:
  | long - variable term
> Parameters:
  = variableEntry* s - Pointer to a variableEntry with the 'name' field instantiated.
  = long* hp - Pointer to the heap pointer.
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
> Global Function: lookupTailVariable ;
  $ longlookupTailVariable (variableEntry*, long*)
> Purpose:
  | This function is used to look up tail variables using 's'.  It searches 'varChain' for the tail variable comparing the hashes and the names of the variables.  If it is found, the tail variable term is returned.  If it is found, but the item found isn't a tail variable,then it is converted into one. If it isn't found, 's' is fully instantiated, added to varChain, and the tail variable term is returned.
> Calling Context:
  | 
> Return Value:
  | long - tail variable term
> Parameters:
  = variableEntry* s - Pointer to a variableEntry with the name field instantiated.
  = long* hp - pointer to the heap pointer.
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
> Global Function: convertToTailVariable ;
  $ voidconvertToTailVariable (long, long*)
> Purpose:
  | This function converts a variable at address 'varAddress' to a tail variable.  If the variable isn't already a tail variable, then 'hp' is used to create a new tail variable.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long varAddress - address of the variable to be converted
  = long* hp - Pointer to the heap pointer
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
> Global Function: removeSpecial ;
  $ intremoveSpecial (variableEntry*)
> Purpose:
  | This function handles special characters in the names of variableEntries.  (ie. changes '\\' 'n' to the character '\n').  It also converts pairs of hex-digits into a single character.
> Calling Context:
  | 
> Return Value:
  | int - 0 on success otherwise 1.
> Parameters:
  = variableEntry* s - Pointer to a variableEntry whoe name is to be checked.
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
> Global Function: isNumber ;
  $ BNRP_BooleanisNumber (long, TAG*, long*)
> Purpose:
  | This function determines if the term 'n' is a number and fills in 'tag' with the term's tag value, and fills in 'l' with the value of the number.  If the term is a flat, then l is filled in with the address of the float.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the term 'n' is a number
> Parameters:
  = long n - term to be checked.
  = TAG* tag - tag value of 'n' filled in by function
  = long* l - value of 'n' filled in by function
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
> Global Function: BNRP_parse ;
  $ BNRP_BooleanBNRP_parse (TCB*, overloadIOProcedure, long, long*, long*)
> Purpose:
  | This function parses the contents of fileIndex into a term which is placed in 'result'.  it uses 'fileProc' to perform I/O on 'fileIndex'.  Any error that occurs is placed in 'ioresult' (0 if none).  If not already done, it initializes itself before starting to parse.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - pointer to a task control block
  = overloadIOProcedure fileProc - I/O handling procedure to use
  = long fileIndex - file index whose contents will be parsed.
  = long* result - term that was created from contents of 'fileIndex'
  = long* ioresult - Error code generated (if any)
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
> Global Function: BNRP_parseError ;
  $ BNRP_BooleanBNRP_parseError (TCB*)
> Purpose:
  | This primitive has a single arguement which is unified with the position in the file where the last parser error took place.
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
> Data Item: stt
  $ char*[MAXSTATES] stt
> Purpose:
  | This table is used to get the next state to switch into with respect to the current state and the current charClasses value.  Used as newstate = stt[state][charClassValue] - '0'.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: sat
  $ char*[MAXSTATES] sat
> Purpose:
  | This table is used to get the next action to perform with respect to the current state and the current charClasses value.  Used as newaction = sat[state][charClassValue].
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_lastParseErrorPosition
  $ long BNRP_lastParseErrorPosition
> Purpose:
  | This is the position in the parse stream where the last error took place.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: charClass
  $ charClasses[] charClass
> Purpose:
  | This is used to map character values to charClasses values (see enum charClasses).  The characters are used as indices into charClass to get the charClasses values. 
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_parserInitialized
  $ long BNRP_parserInitialized
> Purpose:
  | This indicates whether or not the parser has been initialized.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: varChain
  $ variableEntry* varChain
> Purpose:
  | This holds the chain of variables created during parsing.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: newSymbolChain
  $ variableEntry* newSymbolChain
> Purpose:
  | Unknown and UNUSED!
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ULONG_MAX
  $ #define ULONG_MAX
> Purpose:
  | This is the largest unsigned long allowed.  It's defined here for systems that don't define it themselves.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXSTATES
  $ #define MAXSTATES
> Purpose:
  | Maximum number of states in the parser.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ERRORSTATE
  $ #define ERRORSTATE
> Purpose:
  | This defines the parser state for errors.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ERROR
  $ #define ERROR (err)
> Purpose:
  | Sets the ioresult of BNRP_parse() to 'err' and sets the BNRP_lastParseErrorPosition to be the current position in the parse stream.  Prints out the error generated.  This is only used when debug is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ERROR
  $ #define ERROR (err)
> Purpose:
  | Sets the ioresult of BNRP_parse() to 'err' and sets the BNRP_lastParseErrorPosition to be the current position in the parse stream.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPunary
  $ #define OPunary
> Purpose:
  | Denotes all of the unary operators.  Used to detect unary operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPbinary
  $ #define OPbinary
> Purpose:
  | Denotes all of the binary operators.  Used to detect binary operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPprefix
  $ #define OPprefix
> Purpose:
  | Denotes all of the prefix operators.  Used to detect prefix operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPpostfix
  $ #define OPpostfix
> Purpose:
  | Denotes all of the postfix operators.  Used to detect postfix operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPpre_y
  $ #define OPpre_y
> Purpose:
  | Denotes all of the prefix y operators.  Used to detect prefix y operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPpost_y
  $ #define OPpost_y
> Purpose:
  | Denotes all of the postfix y operators.  Used to detect postfix y operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPnot_postfix
  $ #define OPnot_postfix
> Purpose:
  | Denotes all of the non-postfix operators.  Used to detect non-postfix operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPnot_prefix
  $ #define OPnot_prefix
> Purpose:
  | Denotes all of the non-prefix operators.  Used to detect non-prefix operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STARTBRA
  $ #define STARTBRA
> Purpose:
  | Denotes the operator that indicates the opening of a bracket around an expression.  Used for precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENDBRA
  $ #define ENDBRA
> Purpose:
  | Denotes the operator that indicates the closing of the bracket around the expression.  Used for precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPENBRA
  $ #define OPENBRA
> Purpose:
  | Denotes the operator indicating the opening of a bracket.  Used for precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CLOSEBRA
  $ #define CLOSEBRA
> Purpose:
  | Denotes the operator indicating the closing of a bracket.  Used for precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: COMMA
  $ #define COMMA
> Purpose:
  | Denotes the ',' operator.  Used for precedence rules.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VERTICALLIST
  $ #define VERTICALLIST
> Purpose:
  | Denotes a vertical list (ie. '|' then '[' )
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STARTBRAMARKER
  $ #define STARTBRAMARKER
> Purpose:
  | Denotes the starting of an expression.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENDLIST
  $ #define ENDLIST
> Purpose:
  | Denotes the closing of a list bracket ']'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENDPAR
  $ #define ENDPAR
> Purpose:
  | Denotes a closing ')' paranthesis.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENDCON
  $ #define ENDCON
> Purpose:
  | Denotes a closing '}' constraint bracket.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ENDPUNC
  $ #define ENDPUNC
> Purpose:
  | Denotes the final '.' in an expression.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NewTempSymbol
  $ #define NewTempSymbol
> Purpose:
  | Creates a temporary symbol from the current heap pointer.  's' is made into a pointer to the variableEntry at 'hp', and 'p' is set to this variableEntry's name.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | Verifies that there is room enough for n terms on the heap.  If there isn't enough room then a HEAPOVERFLOW error is generated in BNRP_RESUME().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | variableEntry
  $ struct variableEntry
> Purpose:
  | These are used to store variables on the heap for parsing purposes.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = long reference - reference to an unbound variable term.
  = long mark - always VARIABLEMARK
  = variableEntry* link - pointer to the next variableEntry in the chain
  = unsigned char hash - hash value of 'name'
  = char[] name - Name of the variable
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
> Enumeration:
  | charClasses
  $ enum charClasses {r_blank, r_letter, r_Ereal, r_capital, r_Ecap, r_digit0, r_digit, r_bar, r_lpar, r_rpar, r_lbra, r_rbra, r_lcurly, r_rcurly, r_quote, r_dquote, r_plus, r_minus, r_star, r_percent, r_cr, r_vertical, r_slash, r_comma, r_dot, r_backslash, r_singleatom, r_special, r_invalid}
> Purpose:
  = This enumeration lists all the different types of characters that can appear in a file.  They are used for the state/action transitions in the parser.
> Tags:
  = r_blank
  = r_letter
  = r_Ereal
  = r_capital
  = r_Ecap
  = r_digit0
  = r_digit
  = r_bar
  = r_lpar
  = r_rpar
  = r_lbra
  = r_rbra
  = r_lcurly
  = r_rcurly
  = r_quote
  = r_dquote
  = r_plus
  = r_minus
  = r_star
  = r_percent
  = r_cr
  = r_vertical
  = r_slash
  = r_comma
  = r_dot
  = r_backslash
  = r_singleatom
  = r_special
  = r_invalid - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | variableEntry
  $ typedef variableEntry variableEntry
> Purpose:
  | Type definition for the variableEntry structure
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_parse
  $ #define _H_parse
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
