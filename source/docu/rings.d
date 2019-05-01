#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initializeRing0 ;
  $ intBNRP_initializeRing0 (int, char**)
> Purpose:
  | This initializes and embeds ring 0 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base0.a is loaded.  If the "-load MyFile" command line arguement is passed in, then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguements
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
> Global Function: BNRP_initializeRing1 ;
  $ intBNRP_initializeRing1 (int, char**)
> Purpose:
  | This initializes and embeds ring 1 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base1.a is loaded.  If the "-load MyFile" command line arguement is specified then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguments
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
> Global Function: BNRP_initializeRing2 ;
  $ intBNRP_initializeRing2 (int, char**)
> Purpose:
  | This initializes and embeds ring 2 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base2.a is loaded.  If the "-load MyFile" command line arguement is specified then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguments
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
> Global Function: BNRP_initializeRing3 ;
  $ intBNRP_initializeRing3 (int, char**)
> Purpose:
  | This initializes and embeds ring 3 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base3.a is loaded.  If the "-load MyFile" command line arguement is specified then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguements
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
> Global Function: BNRP_initializeRing4 ;
  $ intBNRP_initializeRing4 (int, char**)
> Purpose:
  | This initializes and embeds ring 4 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base4.a is loaded.  If the "-load MyFile" command line arguement is specified then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguements
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
> Global Function: myTestProc ;
  $ voidmyTestProc (short, int, long*)
> Purpose:
  | This is used to test the binding of procedures.  It's called from BNRP_initializeRing5() if test is defined.  It adds a short to an integer.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = short a
  = int b
  = long* c - The result of adding a and b.
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
> Global Function: myTest2 ;
  $ voidmyTest2 (float, double, long double*)
> Purpose:
  | This is a test primitive to test the binding of procedures.  It's called from
  | BNRP_initializeRing5() if test is defined.  Adds a double to a float.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = float f - 
  = double d
  = long double* ld - The result of adding f and d.
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
> Global Function: BNRP_initializeRing5 ;
  $ intBNRP_initializeRing5 (int, char**)
> Purpose:
  | This initializes and embeds ring 5 of the Prolog primitives if it hasn't already been done.  If the rings are not being embedded (if noEmbed is defined) then base5.a is loaded.  If the "-load MyFile" command line arguement is specified then that file is loaded.
> Calling Context:
  | 
> Return Value:
  | int - Zero on success
> Parameters:
  = int argc - number of command line arguements
  = char** argv - array of command line arguements
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
> Global Function: BNRP_initializeAllLowerRings ;
  $ voidBNRP_initializeAllLowerRings (int, char**)
> Purpose:
  | This primitive binds in rings 0 through to 5.  It also processes the command line arguments.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int argc - Number of arguements
  = char** argv - Array of command line arguments.
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
> Data Item: BNRP_alreadyInited
  $ int BNRP_alreadyInited
> Purpose:
  | This indicates whether or not the rings have been intialized.  This is nonzero if the rings have been initialized
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: noEmbed
  $ #define noEmbed
> Purpose:
  | This is defined if the rings are not to be embedded.  If this is specified then the rings are loaded.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: checkInited
  $ #define checkInited ()
> Purpose:
  | This macro checks to see if the rings have been initializes already.  If so, then it reports an error.  Otherwise it sets the BNRPalreadyInited flag.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
