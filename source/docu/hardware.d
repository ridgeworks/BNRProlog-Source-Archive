#if 0
----------------------------------------------------------------------
> Global Function: BNRP_getMaxFP ;
  $ fpBNRP_getMaxFP ()
> Purpose:
  | This function returns the largest floating point number that Prolog can handle.
> Calling Context:
  | 
> Return Value:
  | fp - largest floating point number that Prolog can handle.
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
> Global Function: matherr ;
  $ intmatherr (exception*)
> Purpose:
  | This function is the math error handler.  This is called whenever the math libraries detect an erro condition.  It essentially specifies what actions are to be performed under what conditions.
> Calling Context:
  | 
> Return Value:
  | int - 0 when default handler is to handle the problem, otherwise 1.
> Parameters:
  = exception* x - Pointer to an exception structure.
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
> Global Function: BNRP_getUserTime ;
  $ unsigned longBNRP_getUserTime (BNRP_Boolean, fp*)
> Purpose:
  | Returns the process time in seconds.
> Calling Context:
  | 
> Return Value:
  | unsigned long
> Parameters:
  = BNRP_Boolean delay - Macintosh only.  Specifies if using a timer
  = fp* adjustment - XXXXX_G_PAR
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
> Global Function: BNRP_getElapsedTime ;
  $ unsigned longBNRP_getElapsedTime (void)
> Purpose:
  | Returns the number of milliseconds since the Epoch accounting for daylight savings time.
> Calling Context:
  | 
> Return Value:
  | unsigned long - milliseconds since the Epoch. 
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
> Global Function: BNRP_truncateFile ;
  $ BNRP_BooleanBNRP_truncateFile (FILE*, long)
> Purpose:
  | This function truncates a file to a specified length.  This operation is not supported on all platforms.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success.  FALSE on failure or on platforms not supporting it.
> Parameters:
  = FILE* f - FILE pointer of the file to be truncated.
  = long len - length in bytes to truncate to.
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
> Global Function: BNRP_setConfig ;
  $ BNRP_BooleanBNRP_setConfig (char*)
> Purpose:
  | This function writes a string to the configuration file.  It will overwrite whatever data is already there.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success otherwise FALSE
> Parameters:
  = char* s - Pointer to the new configuration data to be written.
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
> Global Function: BNRP_getConfig ;
  $ char*BNRP_getConfig ()
> Purpose:
  | This function gets the configuration data from the BNR Prolog configuration file.
> Calling Context:
  | 
> Return Value:
  | char* - Pointer to a char string containing the configuration data from the BNR Prolog configuration file
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
> Global Function: pStrcat ;
  $ unsigned char*pStrcat (unsigned char*, unsigned char*)
> Purpose:
  | This is for the Macintosh implementation only and is used to concatenate two P-strings.  It concatenates src to the end of dest.
> Calling Context:
  | 
> Return Value:
  | unsigned char* - Pointer to the new P-string
> Parameters:
  = unsigned char* dest - Pointer to a P-string
  = unsigned char* src - Pointer to a P-string
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
> Global Function: pStrcpy ;
  $ unsigned char*pStrcpy (unsigned char*, unsigned char*)
> Purpose:
  | This is for the Macintosh implementation only and is used to copy a P-string
> Calling Context:
  | 
> Return Value:
  | unsigned char* - Pointer to new string
> Parameters:
  = unsigned char* dest - Pointer to destination
  = unsigned char* src - Pointer to P-string being copied.
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
> Global Function: PathNameFromDirID ;
  $ char*PathNameFromDirID (long, short, char*)
> Purpose:
  | This is only for the Macintosh implementation and returns the path name from a directory ID and refnum.
> Calling Context:
  | 
> Return Value:
  | char* - Full Path associated with the given directory ID and refnum.
> Parameters:
  = long DirID - directory ID of the directory
  = short vRefNum - vRefNum of the directory
  = char* s - Pointer to the buffer into which the full path name can be placed.
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
> Global Function: PathNameFromWD ;
  $ char*PathNameFromWD (long, char*)
> Purpose:
  | Given the working directory number, translate it into a char string path name.  This is only for the Macintosh implementation.
> Calling Context:
  | 
> Return Value:
  | char* - Char string containing the full path to the working directory.
> Parameters:
  = long vRefNum - Refnum of the working directory
  = char* s - Buffer to put the full path of the working directory into.
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
> Global Function: getwd ;
  $ char*getwd (char*)
> Purpose:
  | This is the Macintosh implementation of the getwd function which returns the current working directory.
> Calling Context:
  | 
> Return Value:
  | char* - Pointer to string containing current working directory
> Parameters:
  = char* buff - Buffer that gets filled in by function with the current working directory.
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
> Global Function: chdir ;
  $ intchdir (char*)
> Purpose:
  | This is the MAcintosh implementation of chdir which always fails as the operation is not supported on the Macintosh implementation.
> Calling Context:
  | 
> Return Value:
  | int - always returns failure (-1)
> Parameters:
  = char* path - Full path to the directory to be changed to.
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
> Global Function: realpath ;
  $ 1. char*realpath (char*, char*)                   
  $ 2. char*realpath (char*, char*)
> Purpose:
  | There are two forms of this function: one for some Unix implementations (the ones that don't have a realpath built-in function) and one for Macintosh.  What this does is to take a partial path and translate it into a full path to the same file.
> Calling Context:
  | 
> Return Value:
  | char* - The full path to the file
> Parameters:
  = 1. char* path - Partial path to the file
  = char* resolvedpath - Full path to the file
  = 2. char* path - Same as above
  = char* resolvedpath - Same as above
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
> Global Function: exists ;
  $ intexists (char*)
> Purpose:
  | This determines if a file exists or not.
> Calling Context:
  | 
> Return Value:
  | int - 0 on success otherwise -1
> Parameters:
  = char* filename - Path and name of file whose existance is being determined.
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
> Global Function: getFileInfo ;
  $ intgetFileInfo (char*, fileInfo*)
> Purpose:
  | This gets a file's information as per the fileInfo structure.
> Calling Context:
  | 
> Return Value:
  | int - 0 on success otherwise -1.
> Parameters:
  = char* path - Full path and name of the file.
  = fileInfo* info - Pointer to a fileInfo structure whose contents gets filled in by the function.
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
> Global Function: BNRP_opendir ;
  $ BNRP_BooleanBNRP_opendir (char*)
> Purpose:
  | This function opens a directory as specified by 'name'.  It first checks to make sure that 'name' is a directory by a call to stat().  This just returns on Macintosh implementations.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - Indicates success or failure.  On Macintosh's, this is always FALSE.
> Parameters:
  = char* name - Name of the directory to be opened.
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
> Global Function: BNRP_closedir ;
  $ voidBNRP_closedir (void)
> Purpose:
  | This fucntion closes the currently opened directory.  On Macintosh implementations it does nothing.
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
> Global Function: BNRP_readdir ;
  $ BNRP_dirEntry*BNRP_readdir (void)
> Purpose:
  | Reads an entry from the current directory.  Disregards "empty" entries (ie. removed files)
> Calling Context:
  | 
> Return Value:
  | BNRP_dirEntry* - A pointer to a directory entry on Unix implementations otherwise NULL for Macintosh's.
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
> Global Function: BNRP_openvols ;
  $ BNRP_BooleanBNRP_openvols (void)
> Purpose:
  | This function is here for historical purposes and allows calls to BNRP_readvol() to succeed (not on the Macintosh though...).
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - Always returns TRUE except on MAcintosh's where FALSE is always returned.
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
> Global Function: BNRP_readvol ;
  $ BNRP_dirEntry*BNRP_readvol (void)
> Purpose:
  | This function is here for historical purposes and returns the directory entry for the root of the file system.
> Calling Context:
  | 
> Return Value:
  | BNRP_dirEntry* - Pointer to the directory entry of the root directory of the file system.  On Macintosh implementations, this is always NULL.
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
> Global Function: BNRP_malloc ;
  $ void*BNRP_malloc (unsigned long)
> Purpose:
  | This is the Macintosh implementation of BNRP_malloc which alocates a piece of memory.
> Calling Context:
  | 
> Return Value:
  | void* - Pointer to newly allocated memory.  NULL if an error occurs
> Parameters:
  = unsigned long size - Requested size in bytes to allocate.
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
> Global Function: BNRP_realloc ;
  $ void*BNRP_realloc (void*, unsigned long)
> Purpose:
  | This is the Macintosh implementation of BNRP_realloc which takes a piece of allocated memory and resizes it to 'size' bytes.
> Calling Context:
  | 
> Return Value:
  | void* - Pointer to newly reallocated memory.  NULL if an error occurs.
> Parameters:
  = void* p - Pointer to allocated memory that is to be resized
  = unsigned long size - Size in bytes to resize the chunk of memory to.
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
> Global Function: BNRP_free ;
  $ voidBNRP_free (void*)
> Purpose:
  | This is the Macintosh implementation of BNRP_free that dealocates a piece of allocated memory.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void* p - Pointer to an allocated piece of memory
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
> Global Function: BNRP_mkdir ;
  $ intBNRP_mkdir (char*)
> Purpose:
  | This function is the Macintosh version of mkdir.  This implementation always returns failure as this action is not allowed on the Macintosh implementation.
> Calling Context:
  | 
> Return Value:
  | int - Always returns failure (-1)
> Parameters:
  = char* path - Path of the directory to be created.
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
> Global Function: BNRP_rmdir ;
  $ intBNRP_rmdir (char*)
> Purpose:
  | This function is the Macintosh version of rmdir.  This implementation always returns failure as this action is not allowed on the Macintosh implementation.
> Calling Context:
  | 
> Return Value:
  | int - Always returns failure (-1)
> Parameters:
  = char* path - Path to the directory being removed.
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
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Global Function: BNRP_initializeSigStruct ;
  $ BNRP_sigStructBNRP_initializeSigStruct (void(*)(), int)
> Purpose:
  | This is a platform independant function that initializes a BNRP_sigStruct with a handler function and whatever flags get passed in.
> Calling Context:
  | 
> Return Value:
  | BNRP_sigStruct - an initialized BNRP_sigStruct
> Parameters:
  = void(*)() handler - the signal handling function
  = int flags - Flags to be passed in as per sigaction() or sigvec().
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
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Global Function: BNRP_setupSigHandler ;
  $ BNRP_sigStructBNRP_setupSigHandler (int, BNRP_sigStruct, int)
> Purpose:
  | This is a platform independant function to set up a signal handler.  It sets up the handler in one of two modes depending on the 'mode' parameter: signal and sigset.  It only uses the functionality of signal and sigset, but does not necessarily use the signal() and sigset() calls themselves.  The difference in the two modes is as follows.  In signal mode, when a signal is received, the signal handler is set to SIG_DFL prior to executing the handler.  In sigset mode, the signal is blocked until we exit the handler, whereupon the handler is re-established.
> Calling Context:
  | 
> Return Value:
  | BNRP_sigStruct - the BNRP_sigStruct associated with the signal prior to establishing the new one.
> Parameters:
  = int signalName - The name of the signal to handle as per signal.h
  = BNRP_sigStruct sigHandler - an intialized BNRP_sigStruct structure
  = int mode - Mode to establish the handler in (SIGNAL or SIGSET)
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
> Global Function: tickHandler ;
  $ voidtickHandler ()
> Purpose:
  | This is the SIGALRM handler used by BNRP_setTimer.  It gets executed every time the timer goes off.  All it does is to execute the function that was passed in to BNRP_setTimer().
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
> Global Function: BNRP_setTimer ;
  $ 1. voidBNRP_setTimer (fp*, void(*)())                   
  $ 2. voidBNRP_setTimer (fp*, void(*)())
> Purpose:
  | This function has two forms; one for Macintosh and another for Unix implementations.  This function sets up a timer that goes off every 'time' seconds and executes 'func'.  If 'time' is zero, then it stops the timer and re-establishes the old SIGALRM handler.  This function uses the real timer which generates SIGALRM's.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = 1. fp* time - time in seconds to set the timer to.
  = void(*)() func - function to execute every time the timer goes off.
  = 2. fp* time - same as above
  = void(*)() func - same as above
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
> Global Function: alarmHandler ;
  $ voidalarmHandler (int)
> Purpose:
  | This is the SIGALRM handler used by BNRP_sleep() on Unix implementations.  All it does is to set a flag indicating that a SIGALRM occured.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int sig - XXXXX_G_PAR
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
> Global Function: BNRP_sleep ;
  $ 1. voidBNRP_sleep (fp, int)                   
  $ 2. voidBNRP_sleep (fp, int)
> Purpose:
  | There are 2 forms of the BNRP_sleep() call. One is for Unix implementations while the other is for Macintosh's.  Thepurpose of this is to cause BNRP to
  | pause for a period of time.  It does this by setting up a real timer and
  | a SIGALRM handler.  It then does a pause on SIGALRM waiting for it to go off.
  | BNRP_sleep can behave in 2 fashions.  If ignoreTicks is true, then it will ignore any timers that are pending until it has finished.  If ignoreTicks is
  | false then BNRP_sleep() sets it's timer to go off just before the old timer was due to go off.  Hence "waking" for ticks.  For unknown reasons, this is the opposite of what seems to occur.  In addition if the old timer is less than 'time', then we execute the old timer's SIGALRM handler, re-establish our own and then "sleep".
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = 1. fp time - floating point number representing time to sleep.
  = int ignoreTicks - Boolean indicating to ignore ticks or not
  = 2. fp time - same as above
  = int ignoreTicks - not used
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
> Data Item: BNRPMaxLong
  $ long BNRPMaxLong
> Purpose:
  | Maximum size of a long.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPFPPrecision
  $ short BNRPFPPrecision
> Purpose:
  | This determines the floating point precision on Macintosh's using Think C.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPFPPrecision
  $ short BNRPFPPrecision
> Purpose:
  | This determines the floating point precision on Macintosh's using MetroWerks.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPFPPrecision
  $ short BNRPFPPrecision
> Purpose:
  | This determines the floating point precision.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_handleIntervalErrors
  $ long BNRP_handleIntervalErrors
> Purpose:
  | This is set when we want the matherr() function to handle interval arithmetic errors.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_currentOpenDir
  $ char[MAXPATHLEN] BNRP_currentOpenDir
> Purpose:
  | This string holds the full path name to the current open directory.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_dp
  $ DIR* BNRP_dp
> Purpose:
  | Holds the information relating to the currently opened directory.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_volFirstCall
  $ BNRP_Boolean BNRP_volFirstCall
> Purpose:
  | This is set after the first call to BNRP_readvol is made.  This is a historical item to deal with Macintosh volumes.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_timerFunc
  $ void(*)() BNRP_timerFunc
> Purpose:
  | This stores the function to be executed when tickHandler() is executed.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Data Item: oldTimerSigStruct
  $ BNRP_sigStruct oldTimerSigStruct
> Purpose:
  | This is used by BNRP_setTimer() to store (and restore) the SIGALRM handler that was established prior to it setting up it's own.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_gotAlarm
  $ int BNRP_gotAlarm
> Purpose:
  | This is set when alarmHandler() is executed.  It is used in BNRP_sleep to pause until alarmHandler() is executed.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MIN
  $ #define MIN (a,b)
> Purpose:
  | Returns the minimum of a and b, where a and b are numbers.  Used only on the Macintosh.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Struct:
  | BNRP_sigStruct
  $ struct BNRP_sigStruct
> Purpose:
  | This structure is used to implement platform independant signal handling.  For those platforms that support it, sigaction() is used, otherwise sigvec() or signal() and sigset() is used.  It is preferable to use sigaction over sigvec() and sigvec() over signal() and sigset().
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = sigaction handlerStruct - signal handling structure used on platforms supporting sigaction()
  = sigvec handlerStruct - signal handling structure used on platforms supporting sigvec()
  = void(*)() handlerStruct - signal handling structure used on platforms that support signal() and sigset()
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
  | fileDate
  $ struct fileDate
> Purpose:
  | This structure contains specific time and date information relevant to a file.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = int year - years since 1900
  = int month - month of year [0,11]
  = int day - day of the month [1,31]
  = int hour - hours [0,23]
  = int minute - minutes past the hour [0,59]
  = int second - seconds past the minute [0,61]
  = int dayOfWeek - days since Sunday [0,6]
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
  | fileInfo
  $ struct fileInfo
> Purpose:
  | This structure contains all the relevant information BNRProlog needs about a file.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = char[] fileCreator - Name of the user who created the file
  = char[] fileType - Type of file
  = BNRP_Boolean DFOpen - Only relevant to the Macintosh. FALSE for Unix
  = long DSize - File size in bytes
  = BNRP_Boolean RFOpen - Only relevant to the Macintosh. FALSE for Unix
  = long RSize - Only relevant to the Macintosh.  0 for Unix
  = fileDate created - Date the file was created
  = fileDate modified - Date the file was last modified
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
  | BNRP_dirEntry
  $ struct BNRP_dirEntry
> Purpose:
  | This structure contains all the relevant information to BNRProlog about a directory on a file system.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = char* name - Name of the directory
  = BNRP_Boolean isDir - TRUE if it is a directory - needed as sometimes symbolic links look suspiciously like directories.
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Typedef:
  | BNRP_sigStruct
  $ typedef BNRP_sigStruct BNRP_sigStruct
> Purpose:
  | Type definition for the BNRP_sigStruct structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | fileDate
  $ typedef fileDate fileDate
> Purpose:
  | Type definition for the fileDate structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | fileInfo
  $ typedef fileInfo fileInfo
> Purpose:
  | Type definition for the fileInfo structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | BNRP_dirEntry
  $ typedef BNRP_dirEntry BNRP_dirEntry
> Purpose:
  | Type definition for the BNRP_dirEntry structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_hardware
  $ #define _H_hardware
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DBL_DIG
  $ #define DBL_DIG
> Purpose:
  | Defines the maximum number of digits in a double.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: DBL_MAX
  $ #define DBL_MAX
> Purpose:
  | Maps MAXDOUBLE to DBL_MAX.  Some Unix platforms already have DBL_MAX defined, but some don't.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXPATHLEN
  $ #define MAXPATHLEN
> Purpose:
  | Maximum path length on the Delta Workstation
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: timercmp
  $ #define timercmp (tvp, uvp, cmp)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/time.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: timerclear
  $ #define timerclear (tvp)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/time.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFMT
  $ #define _S_IFMT
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFREG
  $ #define _S_IFREG
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFBLK
  $ #define _S_IFBLK
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFCHR
  $ #define _S_IFCHR
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFDIR
  $ #define _S_IFDIR
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _S_IFIFO
  $ #define _S_IFIFO
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: S_ISDIR
  $ #define S_ISDIR (_M)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: S_ISCHR
  $ #define S_ISCHR (_M)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: S_ISBLK
  $ #define S_ISBLK (_M)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: S_ISREG
  $ #define S_ISREG (_M)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: S_ISFIFO
  $ #define S_ISFIFO (_M)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/stat.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: sigmask
  $ #define sigmask (signo)
> Purpose:
  | Used on the Delta workstation as it wasn't defined in sys/signal.h.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_getMaxLong
  $ #define BNRP_getMaxLong ()
> Purpose:
  | A convenience macro that gets the largest long value.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_getFPPrecision
  $ #define BNRP_getFPPrecision ()
> Purpose:
  | A convenience macro that gets the floating point precision.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Macro: SIGSET
  $ #define SIGSET
> Purpose:
  | Specifies to use the sigset() functionality (But not necessarily the sigset() function itself!!) in setting of a signal handler.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Macro: SIGNAL
  $ #define SIGNAL
> Purpose:
  | Specifies to use the signal() functionality (But not necessarily the signal() function itself!!) in setting up a signal handler.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Macro: sig_handler
  $ #define sig_handler
> Purpose:
  | A platform independant pointer to the signal handler in the BNRP_sigStruct structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Macro: sig_handler
  $ #define sig_handler
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Macro: sig_handler
  $ #define sig_handler
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXPATHLEN
  $ #define MAXPATHLEN
> Purpose:
  | Maximum path length on a Macintosh.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getwd
  $ #define getwd (buff)
> Purpose:
  | On some Unix platforms there is a getcwd function available, so don't use the getwd function in hardware.c.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: mkdir
  $ #define mkdir (path, mode)
> Purpose:
  | This maps to BNRP_mkdir on the Macintosh as the Mac doesn't have a mkdir function.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: rmdir
  $ #define rmdir (path)
> Purpose:
  | This maps to BNRP_rmdir on the Macintosh as the Mac doesn't have a rmdir function.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: remove
  $ #define remove
> Purpose:
  | This macro maps to unlink on Unix platforms so as to create compatibility to the Mac's remove function.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_malloc
  $ #define BNRP_malloc (size)
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_malloc
  $ #define BNRP_malloc (size)
> Purpose:
  | Allocates a section of memory of size size bytes and returns the pointer to it.
  | This macro is applicable to Unix platforms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_realloc
  $ #define BNRP_realloc (p, size)
> Purpose:
  | Reallocates an allocated piece of memory pointed to by p to size bytes on Unix platforms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BNRP_free
  $ #define BNRP_free (p)
> Purpose:
  | Frees an allocated section of memory pointed to by p on Unix platforms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FS_SEPARATOR
  $ #define FS_SEPARATOR
> Purpose:
  | Thisis the file system separator used in path names on the Macintosh.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FS_SEPARATOR
  $ #define FS_SEPARATOR
> Purpose:
  | This is the file system separator used in path names on non-Macintosh platforms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TICK_INTERRUPTS_SYSTEM_CALLS
  $ #define TICK_INTERRUPTS_SYSTEM_CALLS
> Purpose:
  | This flag is set on platforms where the real-time timer can interrupt system calls.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initSighandler ;
  $ BNRP_sighandlerBNRP_initSighandler (void(*)(int))
> Purpose
  | _BNRP_initSighandler_ takes a function pointer (which points to a signal handler the old-style signal(2) would expect), initialises a BNRP_sighandler structure with the function pointer,
  | and returns the BNRP_sighandler to the caller.
> Return Value
  | Returns a BNRP_sighandler structure that has been properly initialised to the caller.
> Parameters
  | void(*)(int) _handler_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | If _SA_RESTARTSYSCALL_ is defined, it is automatically set in the initialised BNRP_sighandler structure.
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_installSighandler ;
  $ BNRP_sighandlerBNRP_installSighandler (int, BNRP_sighandler)
> Purpose
  | Installs a signal handler (of type BNRP_sighandler) to handle signal _signo._
> Return Value
  | Returns the old signal handler that was handling _signo_ before the installation.
> Parameters
  | int _signo_
  | BNRP_sighandler _handler_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_callSighandler ;
  $ voidBNRP_callSighandler (BNRP_sighandler, int)
> Purpose
  | _BNRP_callSighandler_ calls a signal handler specified by handler, and passes signo
  | as the only parameter to it.
> Return Value
  | void
> Parameters
  | BNRP_sighandler _handler_
  | int _signo_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_compareSighandler ;
  $ intBNRP_compareSighandler (BNRP_sighandler, BNRP_sighandler)
> Purpose
  | Compares two signal handlers (of type _BNRP_sighandler)._
> Return Value
  | Returns _1_ if the signal handlers are different from each other, 0 otherwise.
> Parameters
  | BNRP_sighandler _handler1_
  | BNRP_sighandler _handler2_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_blockSignal ;
  $ voidBNRP_blockSignal (int)
> Purpose
  | Given a signal _signo,_ BNRP_blockSignal adds signo to the set of signals currently being
  | blocked from delivery.
> Return Value
  | void
> Parameters
  | int _signo_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_unblockSignal ;
  $ voidBNRP_unblockSignal (int)
> Purpose
  | Given a signal _signo,_ BNRP_unblockSignal removes signo from the set signals that are
  | currently blocked from delivery.
> Return Value
  | void
> Parameters
  | int _signo_
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_waitforSignal ;
  $ voidBNRP_waitforSignal (int)
> Purpose
  | _BNRP_waitforSignal_ removes signal signo from the set of signals that are blocked from deliveries and blocks the execution of current process until a signal is delivered.
> Return Value
  | Will not return until a signal is delivered.
> Parameters
  | int signo  - the signal that is to be removed from the blocked set.
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPFPPrecision
  $ short BNRPFPPrecision
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial_value]
> Notes
  | [Other_information_eg_special_values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPFPPrecision
  $ short BNRPFPPrecision
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial_value]
> Notes
  | [Other_information_eg_special_values]
----------------------------------------------------------------------
#endif
