#if 0
----------------------------------------------------------------------
> Struct:
  | pipePiece
  $ struct pipePiece
> Purpose:
  | This structure defines a Prolog pipe which is a chain of pipePieces.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = pipePiece* nextPiece - Next pipePiece in the chain.
  = short nextChar - current position in 'c'
  = short lastChar - Index of the last character in 'c'
  = char[PIPEBUFFER] c - contents of pipe section
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
  | pipeHeader
  $ struct pipeHeader
> Purpose:
  | This structure defines the header of a BNR Prolog pipe.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = pipePiece* firstPiece - First pipePiece in the chain
  = pipePiece* lastPiece - Last pipePiece in the chain.
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
> Global Function: handleFileIO ;
  $ BNRP_BooleanhandleFileIO (short, long, ...)
> Purpose:
  | This is the I/O handler for doing I/O with files.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = short selector - I/O directive to perform
  = long printFile - File descriptor to perform I/O on
  = ... ellipsis - Depends on 'selector'.
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
> Global Function: handleCharOutput ;
  $ BNRP_BooleanhandleCharOutput (short, long, ...)
> Purpose:
  | I/O handler for doing character output.  The only directives supported are: OUTPUTSTRING, GETERROR and FLUSHFILE.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = short selector - I/O directive to perform
  = long ignored - not used
  = ... ellipsis - Depends on directive.
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
> Global Function: handleCharInput ;
  $ BNRP_BooleanhandleCharInput (short, long, ...)
> Purpose:
  | I/O handler for character input.  The only directives supported are READCHAR, RETURNCHAR, GETERROR and FLUSHFILE.  'selector' is the I/O directive to perform, and ignored is unused.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = short selector - I/O directive to perform
  = long ignored - unused
  = ... ellipsis - Depends on the value of 'selector', could be a char * if doing READCHAR or RETURNCHAR.  If doing GETERROR is short *.
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
> Global Function: handlePipeIO ;
  $ BNRP_BooleanhandlePipeIO (short, long, ...)
> Purpose:
  | This is the I/O handler for pipes.  'selector is the I/O functionto perform and 'pipe' is the address of the pipe to perform the I/O operation on.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success otherwise FALSE.
> Parameters:
  = short selector - I/O directive to perform
  = long pipe - Address of Pipe to perform I/O on.
  = ... ellipsis - variable arguements depending on I/O directive.  Examples are: string to be outputted, address to put read character in.
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
> Global Function: BNRP_needsQuotes ;
  $ BNRP_BooleanBNRP_needsQuotes (char*)
> Purpose:
  | This function determines if a string 's' will need quotation marks around it in order to be printed out properly.  (ie. s starts with a capital letter, etc..)
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE if the string 's' will need quotes around it.
> Parameters:
  = char* s - XXXXX_G_PAR
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
> Global Function: BNRP_outputWithQuotes ;
  $ voidBNRP_outputWithQuotes (char*)
> Purpose:
  | This function outputs a string 's' with quotation marks around it to BNRP_fileIndex using BNRP_printProc.  It handles special characters like '\n' as well.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* s - XXXXX_G_PAR
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
> Global Function: BNRP_dumpWithQuotes ;
  $ voidBNRP_dumpWithQuotes (FILE*, char*)
> Purpose:
  | Outputs a string 's' with quotation marks around it to a file 'f' using the handleFileIO() handler.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = FILE* f - File descriptor to write the output to.
  = char* s - string to be written with quotation marks around it.
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
> Global Function: displayValue ;
  $ voiddisplayValue (long, long, long)
> Purpose:
  | This function prints out a term 'value' using BNRP_printProc().  The nesting arguement indicates the current nesting level.  The maximum amount of nesting is 20 whereupon "...." is printed out.  'prec' indicates the current precedence.  This is used when operators are encountered to print out brackets properly.  When starting off 'nesting' is 0 and 'prec' is 3000 (nothing has a higher precedence value than that).
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = long value - term to be printed out.
  = long nesting - current nesting level (0 to start off)
  = long prec - current precedence of term (3000 to start off).
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
> Global Function: BNRP_checkSymbol ;
  $ BNRP_BooleanBNRP_checkSymbol (TCB*, int)
> Purpose:
  | This function sets the BNRP_fileIndex, BNRP_printPos, and BNRP_printProc procedures if the first arguement of 'tcb' is a variable or a symbol.  If the mode is READONLY, then the first arguement of 'tcb' must be a symbol.  if the mode is WRITEONLY, then it can be either a symbol or a variable.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = TCB* tcb - Pointer to a task control block.
  = int mode - File mode (one of READONLY, READWRITE, WRITEONLY)
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
> Global Function: BNRP_checkFile ;
  $ BNRP_BooleanBNRP_checkFile (TCB*, int)
> Purpose:
  | This function sets up the BNRP_fileIndex and BNRP_printProc values for the file.  The first arguement of the tcb is expected to be one of: integer, symbol, list, variable. If it is an integer then it is presumed to be a file descriptor.  If it's a symbol, then we set up to read/write to/from the tcb.  If it's a list, then the first item in the list sets BNRP_fileIndex and the second sets BNRP_printProc.  'mode' is checked if the stdin or stdout file descriptors occur (ie. If using STDIN, then don't allow write modes, If first arguement is a variable, then can't have READONLY mode)
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success.
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = int mode - Mode to open file (one of READONLY, READWRITE, WRITEONLY)
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
> Global Function: BNRP_openFile ;
  $ BNRP_BooleanBNRP_openFile (TCB*)
> Purpose:
  | This primitive opens a file or a pipe in the mode specified.  It can have between 3 and 5 arguements.  If it has 3 arguements, then a pipe is opened.  The first arguement is filled in with the pipe identifier, the second with the pipe I/O handler address and the third with the error.  If it has 4 arguements, then a file is opened.  The first arguement is filled in with the file descriptor, the second is the name of the file to be opened (plus optional path information), the third is the mode to open the file with.  The mode can be any legal fopen() mode.  The fourth arguement is unified with any error (0 if none) that is created.  The form with 5 arguements is the same as the one with 4 arguements with the addition of the file I/O handler being unified with the fifth arguement.
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
> Global Function: BNRP_closeFile ;
  $ BNRP_BooleanBNRP_closeFile (TCB*)
> Purpose:
  | This primitive closes a file.  It has two arguements which are the file descriptor to close and the resulting error (0 if none).
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
> Global Function: BNRP_getChar ;
  $ BNRP_BooleanBNRP_getChar (TCB*)
> Purpose:
  | This primitive reads a character from a symbol or from a file.  The first arguement is a symbol or a file descriptor.  The second arguement gets unified with the character read and the third with the I/O error (0 if none).  The fourth arguement determines if error messages should be printed out (always 0).
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
> Global Function: BNRP_readlnFile ;
  $ BNRP_BooleanBNRP_readlnFile (TCB*)
> Purpose:
  | This primitive reads a line from a file.  The first arguement is a file descriptor or a symbol.  If it is a symbol,then the read is done from the symbol.  Otherwise it's done from a file (including stdin and stdout).  The second arguement is unified with the result of the read and the third is unified with the IO error that occured () if none).  The fourth arguement indicates whether or not error messages should be printed out (always 0).
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
> Global Function: BNRP_readFileSymbol ;
  $ BNRP_BooleanBNRP_readFileSymbol (TCB*)
> Purpose:
  | See BNRP_readFile().
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block.
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
> Global Function: BNRP_makeTermFromString ;
  $ BNRP_termBNRP_makeTermFromString (TCB*, char*)
> Purpose:
  | This function converts a string into the appropriate term and returns the term.
> Calling Context:
  | 
> Return Value:
  | BNRP_term - Term created from 's'
> Parameters:
  = TCB* tcb - Pointer to a task control block
  = char* s - string to be converted to a term.
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
> Global Function: BNRP_readFile ;
  $ BNRP_BooleanBNRP_readFile (TCB*)
> Purpose:
  | This primitive reads from a file descriptor or a symbol.  The first arguement is either an integer, or a symbol.  If it is an integer, it is a file descriptor from which the read is done.  If it is a symbol, it is the symbol to be read.  The second arguement is the result of reading from the file/symbol and the third arguement is the I/O error that occured (0 if none).  Finally, the fourth arguement indicates whether or not error messages should be printed out.  (always 0).
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
> Global Function: BNRP_finishWrite ;
  $ BNRP_BooleanBNRP_finishWrite (TCB*)
> Purpose:
  | This function prints out a list of terms to the output device given.  See BNRP_writeFile for description of TCB arguements.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
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
> Global Function: BNRP_writeFileSymbol ;
  $ BNRP_BooleanBNRP_writeFileSymbol (TCB*)
> Purpose:
  | See BNRP_writeFil().  Exact same functionality except this is in ring 2 and BNRP_writeFile() is in ring 3.
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
> Global Function: BNRP_writeFile ;
  $ BNRP_BooleanBNRP_writeFile (TCB*)
> Purpose:
  | This primitive writes to a file or to a symbol.  It takes 6 arguements which are as follows:
  | - File descriptor or a symbol/var.  If the later, then result gets unified with it.
  | - write options
  | 0x10 - print quotes around symbols that require it
  | 0x08 - print commas between terms
  | 0x04 - print blanks after commas
  | 0x02 - print intervals (UNUSED)
  | 0x01 - print a period at the end
  | - Maximum number of characters to write (negative to use default value)
  | - list of items to write
  | - Error code (filled in by primitive
  | - Number of characters written (filled in by primitive)
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
> Global Function: BNRP_atFile ;
  $ BNRP_BooleanBNRP_atFile (TCB*)
> Purpose:
  | This primitive returns the current position in the file.  The first arguement is a file descriptor and the second gets unified with the current file position (an integer) or the symbol 'end_of_file'.
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
> Global Function: BNRP_seekFile ;
  $ BNRP_BooleanBNRP_seekFile (TCB*)
> Purpose:
  | This primitive moves the pointer in the file to the position specified in the second arguement.  If this arguement is the 'end_of_file' symbol, then the file pointer is set to the end of the file.  The first arguement is a file descriptor.
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
> Global Function: BNRP_eofFile ;
  $ BNRP_BooleanBNRP_eofFile (TCB*)
> Purpose:
  | This primitive has a single arguement which is the file descriptor of the file in which EOF will be set.  This invokes the BNRP_printProc with the directive SETEOF at BNRP_fileIndex.
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
> Global Function: BNRP_consultFile ;
  $ BNRP_BooleanBNRP_consultFile (TCB*)
> Purpose:
  | This primitive loads a file into the current context.  It has a single arguement which is the name (plus possible path information) ofthe file to load.
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
> Global Function: BNRP_doTraceback ;
  $ BNRP_BooleanBNRP_doTraceback (TCB*)
> Purpose:
  | This primitive prints out a trace of the calls on the stack.  The first arguement is an integer which indicates where to print out the result (ie. a file descriptor) and the second is either an integer or a symbol.  If it is an integer it is how far back the trace should go.  If it is a symbol, then it is checked against the string "choicepoints".  If it matches then the choicepoints are dumped.  If an error occurs (ie. bad file descriptor, etc) then the traceback is printed to stdout.
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
> Data Item: BNRP_printProc
  $ overloadIOProcedure BNRP_printProc
> Purpose:
  | I/O handling procdure to use.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_fileIndex
  $ long BNRP_fileIndex
> Purpose:
  | Current index into a file.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printTCB
  $ TCB* BNRP_printTCB
> Purpose:
  | Pointer to the task control block where printing to the heap is being done.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printPos
  $ char* BNRP_printPos
> Purpose:
  | Current location in a string when doing character I/O.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printLen
  $ long BNRP_printLen
> Purpose:
  | Maximum number of characters that can be printed at one time.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printCount
  $ long BNRP_printCount
> Purpose:
  | Number of characters printed out.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printQuotes
  $ BNRP_Boolean BNRP_printQuotes
> Purpose:
  | If this is set then symbols that need quotations around them are printed with quotes.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printCommas
  $ BNRP_Boolean BNRP_printCommas
> Purpose:
  | If this is set, then commas are printed out between terms.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printBlanks
  $ BNRP_Boolean BNRP_printBlanks
> Purpose:
  | If this is set then a space is printed out after each comma character.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printIntervals
  $ BNRP_Boolean BNRP_printIntervals
> Purpose:
  | if this is set, intervals are printed.  This is not checked for in the source.  Possible leftover?
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printMsgs
  $ long BNRP_printMsgs
> Purpose:
  | If this is set, then error messages are printed out.  This is not checked for inthe source.  Possible leftover?
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_printEnv
  $ jmp_buf BNRP_printEnv
> Purpose:
  | Jump buffer for jumping back into an I/O handling procedure when an erro occurs.
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
  | pipePiece
  $ typedef pipePiece pipePiece
> Purpose:
  | Type definition for the pipPiece structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | pipeHeader
  $ typedef pipeHeader pipeHeader
> Purpose:
  | Type definition for the pipeHeader structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STDIN
  $ #define STDIN
> Purpose:
  | File descriptor for standard input
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STDOUT
  $ #define STDOUT
> Purpose:
  | File descriptor for standard output.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: READONLY
  $ #define READONLY
> Purpose:
  | Flag value of a file or pipe that is is open for reading only
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: WRITEONLY
  $ #define WRITEONLY
> Purpose:
  | Flag value of a file or pipe that is is open for writing.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: READWRITE
  $ #define READWRITE
> Purpose:
  | Flag value of a file or pipe that is is open for reading and writing.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TOOLONG
  $ #define TOOLONG
> Purpose:
  | Error generated if the object passed to an I/O procedure is too long to be outputted.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: PIPEBUFFER
  $ #define PIPEBUFFER
> Purpose:
  | This is the size in bytes of a pipe segment.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | overloadIOProcedure
  $ typedef BNRP_Boolean(*)(short,long,) overloadIOProcedure
> Purpose:
  | This is the type definition for an I/O handling procedure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ioprim
  $ #define _H_ioprim
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: USEHP
  $ #define USEHP
> Purpose:
  | If this is found in BNRP_fileIndex, then output is directed to the heap for unification with tcb->args[1].
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NONSTRING
  $ #define NONSTRING
> Purpose:
  | Denotes that the object being sent to OUTPUTSTRING is not a string.  Used primarily for I/O in the X interface.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STRING
  $ #define STRING
> Purpose:
  | Denotes that the object being sent to OUTPUTSTRING is a string.  Used primarily for I/O in the X interface.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: output
  $ #define output (s)
> Purpose:
  | Convenience macro to output a string 's' using BNRP_printProc.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: output2
  $ #define output2 (s, v)
> Purpose:
  | Convenience macro to output 'v' using a format 's'.  Uses BNRP_printProc to do the actual write.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: outputstr
  $ #define outputstr (v)
> Purpose:
  | Convenience macro to output a string using BNRP_printProc. 'v' is the string to be written.  Used primarily for writing to pipes
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: outputchar
  $ #define outputchar (v)
> Purpose:
  | Convenience macro to output a character using BNRP_printProc. 'v' is the character to be written.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTPUTSTRING
  $ #define OUTPUTSTRING
> Purpose:
  | I/O directive to write a string or character
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: READCHAR
  $ #define READCHAR
> Purpose:
  | I/O directive to read a character.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: RETURNCHAR
  $ #define RETURNCHAR
> Purpose:
  | I/O directive to handle return characters
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPENFILE
  $ #define OPENFILE
> Purpose:
  | I/O directive to open a file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CLOSEFILE
  $ #define CLOSEFILE
> Purpose:
  | I/O directive to close a file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GETPOSITION
  $ #define GETPOSITION
> Purpose:
  | I/O directive to get the current position in the I/O stream.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SETPOSITION
  $ #define SETPOSITION
> Purpose:
  | I/O directive to set the current position in the I/O stream.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SETEOF
  $ #define SETEOF
> Purpose:
  | I/O directive to set EOF at the current location in the I/O stream
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FLUSHFILE
  $ #define FLUSHFILE
> Purpose:
  | I/O directive to flush the contents of the buffers to the file.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GETERROR
  $ #define GETERROR
> Purpose:
  | This is the I/O directive to get an error code created due to an I/O operation.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
