#if 0
----------------------------------------------------------------------
> Struct:
  | symRef
  $ struct symRef
> Purpose:
  | This structure is used to hold symbols when compiling in a file.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = BNRP_term ref - symbol reference
  = long key - key of the symbol
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
> Global Function: checkVersion ;
  $ intcheckVersion (FILE*)
> Purpose:
  | This function is used when after a compiled Prolog file has been opened to check the compiler version information at the top of the file.  If it matches what is expected (ie. COMPILERVERSION, CODEGENDAY, CODEGENYEAR, CODEGENMONTH match) then 0 is returned
> Calling Context:
  | 
> Return Value:
  | int - 0 if the version information is correct, otherwise 1
> Parameters:
  = FILE* f - File pointer to open file to be checked.
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
> Global Function: loadError ;
  $ voidloadError (long)
> Purpose:
  | This function generates an error 'err' inside of loadFile().
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long err - Error to be generated
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
> Global Function: getToken ;
  $ intgetToken (int, FILE*)
> Purpose:
  | Read 'maxLen' characters from a file associated with the file pointer 'f' into the buffer BNRP_buffSpace.  Spaces are ignored.  If 'maxLen' is negative, then tokens are read until a space is encountered.
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = int maxLen
  = FILE* f - XXXXX_G_PAR
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
> Global Function: skipToken ;
  $ voidskipToken (FILE*)
> Purpose:
  | Skips the next token in the file associated with the file pointer 'f'.  Spaces are not counted as tokens.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = FILE* f - XXXXX_G_PAR
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
> Global Function: convert ;
  $ intconvert (char)
> Purpose:
  | Converts a byte value into a nibble.  The character is presumed to be in: (0,9) or (a,f) or (A,F)
> Calling Context:
  | 
> Return Value:
  | int - nibble encoding of c.
> Parameters:
  = char c - character to be converted
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
> Global Function: getWord ;
  $ shortgetWord (char*)
> Purpose:
  | Converts a 4 byte value into a single word (2 bytes).  Only reads the first 4 bytes of 'c'
> Calling Context:
  | 
> Return Value:
  | short - word encoding of 'c'
> Parameters:
  = char* c - String to be converted.
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
> Global Function: getByte ;
  $ chargetByte (char*)
> Purpose:
  | Converts a 2 byte value into a single byte.  It uses the first two bytes of 'c'.
> Calling Context:
  | 
> Return Value:
  | char - byte representing 'c'
> Parameters:
  = char* c - character string to be converted (only converts c[0] and c[1]).
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
> Global Function: findOp ;
  $ BNRP_BooleanfindOp (char*, short*, short*, BNRP_term*)
> Purpose:
  | This function parses an operator definition from a compiled Prolog file. 'p' is of the form (prec,type)="opname".  It puts the precedence found into 'pr', the type into 'ty' and looks up the operator name in the symbol table and put it in 'a'.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success.
> Parameters:
  = char* p - Operator definition from a compiled Prolog file
  = short* pr -precedence of the operator filled in by function
  = short* ty - type of the operator filled in by function
  = BNRP_term* a - symbolic form of operator name filled in by function.
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
> Global Function: checkIndex ;
  $ voidcheckIndex (short)
> Purpose:
  | This function verifies that an index into BNRP_refs is valid.  If it is greater than BNRP_numRefs then BNRP_refs is grown and the new space in it is initialized.  If the index value passed is negative then a LOADTOOMANYSYMBOLS error is generated in loadFile().  This is typically used after a getWord operation to check the returned value.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = short index - Index into BNRP_refs.
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
> Global Function: loadFile ;
  $ intloadFile (char*)
> Purpose:
  | This function loads a compiled BNR Prolog file 'name' (plus any necessary path information) into the current context.  The version information in the top of the file is checked.
> Calling Context:
  | 
> Return Value:
  | int - I/O error that occured while attempting to load the file (0 on success)
> Parameters:
  = char* filename - Name of the file to load.
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
> Global Function: checkName ;
  $ voidcheckName (char*, char*)
> Purpose:
  | This is used for debug purposes to verify that the string 'a' is the same as the sting 'b'.  If debugMessages is not defined, then the macro version is used.  Prints out an error if they aren't the same.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* sp - string to compare
  = char* name - string to compare
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
> Global Function: scanList ;
  $ BNRP_BooleanscanList (BNRP_term)
> Purpose:
  | This function takes a list term which contains symbols, structures, and/or lists.  The function takes this list (which is presumed to be opcode instructions) and converts it into the appropriate byte sequence for execution (BNRP_freePtr).
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_term list - List of opcode instructions to encode into a byte sequence.
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
> Global Function: BNRP_inCoreLoader ;
  $ BNRP_BooleanBNRP_inCoreLoader (TCB*)
> Purpose:
  | This primitive adds a clause into the system.  It has either 5 or 6 arguements.  The first is an integer which indicates where to add the clause (0 for last and 1 for front of chain).  The second is a symbol which denotes the functor name of the clause.  The third is the arity of the clause, the fourth is the first arguement of the clause head, and the fifth is a list containing the opcode operations to perform.  If there are 6 arguements, the sixth is unified with the opcode sequence equivalent of the clause body.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE.
> Parameters:
  = TCB* tcb - Pointer to a task control block
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
> Data Item: BNRP_refs
  $ symRef* BNRP_refs
> Purpose:
  | An array of symRef's used to hold symbol references.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_numRefs
  $ int BNRP_numRefs
> Purpose:
  | Maximum number of unique symbols allowed in a file.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_freePtr
  $ char* BNRP_freePtr
> Purpose:
  | Holds the opcodes and byte sequences relating to the file being loaded.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_freeSpace
  $ char* BNRP_freeSpace
> Purpose:
  | Buffer used to hold clause definitions.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_buffSpace
  $ char* BNRP_buffSpace
> Purpose:
  | Buffer used to hold symbols read from a file.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_freeSize
  $ long BNRP_freeSize
> Purpose:
  | The current size ofthe buffer used to hold clauses.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_buffSize
  $ long BNRP_buffSize
> Purpose:
  | The current size of the buffer used to hold symbols read from a file.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: loadbuf
  $ jmp_buf loadbuf
> Purpose:
  | Jump buffer used to jump into loadFile() when a load error occurs.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: remHeadBytes
  $ int[] remHeadBytes
> Purpose:
  | Array indicating what size of tokens to read (and how many) with respect to head codes.  Indexing into the array with a head code shows what to do.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: remBodyBytes
  $ int[] remBodyBytes
> Purpose:
  | rray indicating what size of tokens to read (and how many) with respect to body codes.  Indexing into the array with a head code shows what to do.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: remEscBytes
  $ int[] remEscBytes
> Purpose:
  | rray indicating what size of tokens to read (and how many) with respect to escape codes.  Indexing into the array with a head code shows what to do.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STARTFREESPACE
  $ #define STARTFREESPACE
> Purpose:
  | The minimum amount of space to allocate for handling clauses.  Also used to increase the size of the buffer when required.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STARTBUFFSIZE
  $ #define STARTBUFFSIZE
> Purpose:
  | The minimum amount of space for the read buffer for symbols when loading a file.  It's also used to increase the size of the read buffer when required.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STARTNUMREFS
  $ #define STARTNUMREFS
> Purpose:
  | This is the maximum number of unique symbols that a file can have.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: COMPILERVERSION
  $ #define COMPILERVERSION
> Purpose:
  | This is the version ofthe compiler.  Used to check version information of a compiled file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CODEGENDAY
  $ #define CODEGENDAY
> Purpose:
  | This is the day the code generator was created.  Used to check version information of a compiled file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CODEGENYEAR
  $ #define CODEGENYEAR
> Purpose:
  | This is the year the code generator was created.  Used to check version information of a compiled file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CODGENMONTH
  $ #define CODGENMONTH
> Purpose:
  | This is the month the code generator was created.  Used to check version information of a compiled file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getachar
  $ #define getachar (f, ch)
> Purpose:
  | Reads a character into 'ch' from the file associated with the file descriptor 'f'.  In addition it handles cases where it gets interrupted due to ticks (On systems where TICK_INTERRUPTS_SYSTEM_CALLS is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getachar
  $ #define getachar (f, ch)
> Purpose:
  | Reads a character into 'ch' from the file associated with the file descriptor 'f'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addByte
  $ #define addByte (b)
> Purpose:
  | Adds and object 'c' which has the same size as a BYTE to BNRP_freePtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addWord
  $ #define addWord (w)
> Purpose:
  | Adds an object 'w' which has the same size as a short to BNRP_freePtr.  UNUSED.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addLong
  $ #define addLong (l)
> Purpose:
  | This adds an object 'l' which has the same size as a long to BNRP_freePtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: checkName
  $ #define checkName (a, b)
> Purpose:
  | This macro is used when debugMessages isn't defined.  It's defined to prevent the code from breaking due to an unknown function "checkName()".
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: emitCons
  $ #define emitCons (tag, t)
> Purpose:
  | Pushes a constant 't' with a tag value of 'tag' onto BNRP_freePtr.  'tag' is one of: INTT, FLOATT or SYMBOLT.  In addition, a debug message gets printed out if an incorrect tag gets passed in if debugMessages is defined.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: emitCons
  $ #define emitCons (tag, t)
> Purpose:
  | Pushes a constant 't' with a tag value of 'tag' onto BNRP_freePtr.  'tag' is one of: INTT, FLOATT or SYMBOLT.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addOpcode
  $ #define addOpcode (op, reg)
> Purpose:
  | Adds an opcode 'op' with an arguement 'reg' to BNRP_freePtr
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addDualOpcode
  $ #define addDualOpcode (op, r1, r2)
> Purpose:
  | This macro adds an opcode 'op' with arguements r1 and r2 to BNRP_freePtr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
