#if 0
----------------------------------------------------------------------
> Global Function: BNRP_systemCall ;
  $ BNRP_BooleanBNRP_systemCall (TCB*)
> Purpose:
  | This primitive is used to execute shell commands.  It takes between 1 and 3 arguements.  If it has a single arguement, then it is presumed to be a shell command to be executed.  The primitive is successful if the shell command can be executed without an error.  If the primitive is given two arguements, then the second is unified with the erro code resulting from executing the shell command.  If it has 3 arguements then the third is unified with the output to stdout that the shell command produced.  On some platforms, system calls can get interupted by signals, so for these platforms, SIGALRM is ignored while the shell command is being executed.
  | SIGPIPE is also ignored during the execution of the shell command, as on some
  | systems (eg, nav88k sysVr4) SIGPIPE can be generated when popen() terminates.
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
> Global Function: BNRP_getenv ;
  $ BNRP_BooleanBNRP_getenv (TCB*)
> Purpose:
  | This primitive is used to get environment variables and their values.  It has two arguements the first being the symbolic name of the env variable (eg. "PATH") and the second is unified with that env variable's value.
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
> Global Function: BNRP_defaultDir ;
  $ BNRP_BooleanBNRP_defaultDir (TCB*)
> Purpose:
  | This primitive either sets or queries the current directory.  It has a single arguement which is either a symbol or a variable.  If it is a symbol then the primitive changes to that directory (if it can't then FALSE is returned).  If it is a variable, it returns the full path of the current working directory.
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
> Global Function: BNRP_isFile ;
  $ BNRP_BooleanBNRP_isFile (TCB*)
> Purpose:
  | This primitive returns information about a file.  It has 21 arguements.  The first being the name of the file (or path to the file and file name), and the rest are as follows:
  | - File creator - symbol
  | - File type - symbol
  | - If the file is open - integer
  | - File size (bytes) - integer
  | - RFOpen - integer (0 on Unix platforms)
  | - RFSize - integer (0 on Unix platforms)
  | - Year created - integer
  | - Month created - integer
  | - Day created - integer
  | - Hour created - integer
  | - Minute created - integer
  | - Second created - integer
  | - Day of week created - integer
  | - Year last modified - integer
  | - Month last modified - integer
  | - Day last modified - integer
  | - Hour last modified - integer
  | - Minute last modified - integer
  | - Second last modified - integer
  | - Day of week last modified - integer
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
> Global Function: BNRP_fullFileName ;
  $ BNRP_BooleanBNRP_fullFileName (TCB*)
> Purpose:
  | This primitive converts between a filename and the full path and name of the file.  The first arguement is the name of the file or a variable.  The second is the full path and name of the file or a variable.  If the first arguement is a symbol, it returns the full path and name of the file.  Otherwise, the second arguement must be a symbol which it uses to find the file's name (without path information).
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
> Global Function: BNRP_timeAndDate ;
  $ BNRP_BooleanBNRP_timeAndDate (TCB*)
> Purpose:
  | This primitive returns the current time and date.  It has two arguements, the first is the time in the format "HH:MM" and the second is the date in the format "YY MM DD".
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
> Global Function: listdirfiles ;
  $ BNRP_Booleanlistdirfiles (TCB*, BNRP_Boolean)
> Purpose:
  | This function creates a list containing either the directories or files contained in the directory specified by tcb->args[1].  This list is then unified with tcb->args[2].  If 'directory' is TRUE then it only lists the directories, otherwise only the files are listed.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success otherwise FALSE
> Parameters:
  = TCB* tcb - task control block pointer
  = BNRP_Boolean directory - TRUE if listing directories, FALSE for files
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
> Global Function: BNRP_listfiles ;
  $ BNRP_BooleanBNRP_listfiles (TCB*)
> Purpose:
  | This primitive takes two argugments, the second being a list of files contained in the directory specified by the first arguement.
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
> Global Function: BNRP_listdirectories ;
  $ BNRP_BooleanBNRP_listdirectories (TCB*)
> Purpose:
  | This primitive takes two arguements.  The first is the directory to list from, and trhe second is a list containing the directories in the directory specified in the first arguement.
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
> Global Function: BNRP_listvolumes ;
  $ BNRP_BooleanBNRP_listvolumes (TCB*)
> Purpose:
  | This primitive is for upwards compatibility and lists the file systems that are available in a list of symbols.  Now it only returns the '/' volume.
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
> Global Function: BNRP_removeFile ;
  $ BNRP_BooleanBNRP_removeFile (TCB*)
> Purpose:
  | This primitive takes a single arguement which is the name of (and possibly the path to) the file to be removed.
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
> Global Function: BNRP_createDir ;
  $ BNRP_BooleanBNRP_createDir (TCB*)
> Purpose:
  | This primitive creates a directory.  It has a single arguement which is the name (and possible full path) of the directory to create.  The directory is created with a mode of 0777.
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
> Global Function: BNRP_removeDir ;
  $ BNRP_BooleanBNRP_removeDir (TCB*)
> Purpose:
  | This primitive has a single arguement which is the name (and possible path) to a directory to be removed.
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
> Global Function: BNRP_findfile ;
  $ voidBNRP_findfile (char*, char*)
> Purpose:
  | This function finds the full path to a file first searching the current directory and then all the directories in the PATH env variable until it finds the file.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char* name - Name of the file to find
  = char* fullname - full path and name of the file (filled in by function).
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
> Global Function: BNRP_setupFiles ;
  $ voidBNRP_setupFiles (int, char**)
> Purpose:
  | This function takes the command line arguements and stores them away into BNRP_argc and BNRP_argv.  It also sets the BNRP_appdirname string to be the path to the directory from which Prolog was executed.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int argc - number of command line arguements
  = char** argv - Array of command line arguements
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
> Global Function: BNRP_getappfiles ;
  $ BNRP_BooleanBNRP_getappfiles (TCB*)
> Purpose:
  | This primitive takes a single arguement which gets unified with a list containing the symbolic forms of the command line arguements passed in to Prolog.
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
> Global Function: BNRP_appdir ;
  $ BNRP_BooleanBNRP_appdir (TCB*)
> Purpose:
  | This primitive has a single arguement which gets unified with the path to the directory where Prolog was called from.
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
> Data Item: BNRP_argv
  $ char** BNRP_argv
> Purpose:
  | This holds the command line arguements that were passed in to Prolog.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_argc
  $ int BNRP_argc
> Purpose:
  | This holds the number of command line arguements passed in.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_appdirname
  $ char[MAXPATHLEN] BNRP_appdirname
> Purpose:
  | This holds the path to the directory where Prolog was called from.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _SIZE_T
  $ #define _SIZE_T
> Purpose:
  | This gets defined on the Delta workstation as it is lacking from the system include files.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
