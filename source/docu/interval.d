#if 0
----------------------------------------------------------------------
> Union:
  | fpoverlay
  $ union fpoverlay
> Purpose:
  | This union facilitates the conversion of a fp into two longs.  One long represents the sign and exponent part of the float while the other represents the mantissa.
> Base Classes:
  = No baseclasses... - XXXXX_U_BAS
> Important Members:
  = No methods... - XXXXX_U_MET
  = long[] l - array of size two which is the same size as an fp.
  = fp f - floating point number.
  = No enumerations defined... - XXXXX_U_ENU
  = No typedefs defined... - XXXXX_U_TYP
> Concurrency:
  | Multithread safe. XXXXX_U_CON
  | _Not_ multithread safe. XXXXX_U_CON
> Other Considerations:
  | XXXXX_U_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: upperbd3 ;
  $ 1. voidupperbd3 (int_fp, int_fp*)  
  $ 2. voidupperbd3 (long double, long double*)
> Purpose:
  | This is used on some Macintosh platforms to calculate the upper bound of x and to put in the location pointed to by y.  Rounding is set upwards.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = 1. int_fp x - float whose upper bound we wish to find
  = int_fp* y - Pointer to where to put the upper bound of x
  = 2. long double x - double whose upper bound we wish to find
  = long double* y - Pointer to where to put the upper bound of x.
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
> Global Function: lowerbd3 ;
  $ 1. voidlowerbd3 (int_fp, int_fp*)  
  $ 2. voidlowerbd3 (long double, long double*)
> Purpose:
  | This is used on some Macintosh platforms to calculate the lower bound of x and to put in the location pointed to by y.  Rounding is set downwards.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = 1. int_fp x - float whose lower bound we want to find
  = int_fp* y - Pointer to where to put the lower bound of x
  = 2. long double x - double whose lower bound we want to find
  = long double* y - Pointer to where to put the lower bound of x
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
> Global Function: displaymsg ;
  $ 1. voiddisplaymsg (char*, fp, fp)  
  $ 2. voiddisplaymsg (char*, int_fp, int_fp)
> Purpose:
  | This function displays a message and prints out the floats xl and xh.  
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = 1. char* m - Message to be printed
  = fp xl - lower bound of interval
  = fp xh - upper bound of interval
  = 2. char* m - Message to be printed
  = int_fp xl - lower bound to be printed
  = int_fp xh - upper bound to be printed
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
> Global Function: BNRP_fuzz ;
  $ BNRP_BooleanBNRP_fuzz (TCB*)
> Purpose:
  | This primitive has 3 arguements.  The first is the float to be "fuzzed" and the second and third are filled in by the primitive with the the previous and next floating point numbers to the first arguement.
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
> Global Function: BNRP_iterate ;
  $ BNRP_BooleanBNRP_iterate (TCB*)
> Purpose:
  | This primitive evaluates a single interval arithmetic node, or a list of nodes.
  | It takes either one or two arguements.  The first is a structure of the form:
  | 		functor(Z,X,Y) which is desribed in interval.c
  | The first arguement can also be a list of these structures.  If there is a second arguement (doesn't matter what type it is) then it indicates to link the first node on the queue into the constraint network if the operation on the node is successful.
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
> Data Item: _maxfp
  $ extended _maxfp
> Purpose:
  | Maximum positive floating point value on the Macintosh Think-C platform.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: _maxnegfp
  $ extended _maxnegfp
> Purpose:
  | Maximum negative floating point value on the Macintosh Think-C platform.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_SANE_default_environment
  $ Environment BNRP_SANE_default_environment
> Purpose:
  | Used on Macintosh platforms to save and restore the FPU environment settings.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_oldRM
  $ int BNRP_oldRM
> Purpose:
  | This is used on the Ultrix and SGI platforms to store the previous FPU mode so that we can restore it later.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: booleanInput
  $ long booleanInput
> Purpose:
  | This encodes the input to a boolean operation.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: booleanOutput
  $ long booleanOutput
> Purpose:
  | This is the encoding for the output of a boolean operation
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
  | fpoverlay
  $ typedef fpoverlay fpoverlay
> Purpose:
  | This is the type definition for the fpoverlay union.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FIRST
  $ #define FIRST
> Purpose:
  | This flag is used to get the first 4 bytes of a float (sign + exponent)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SECOND
  $ #define SECOND
> Purpose:
  | This flag is used to get the second 4 bytes of a float (mantissa).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: __ieeenext
  $ #define __ieeenext (x)
> Purpose:
  | Caculates the next floating point number greater than x using IEEE floats.  'x' is replaced with this number.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: __ieeeprev
  $ #define __ieeeprev (x)
> Purpose:
  | Calculates the previous floating point number to x using IEEE floats.  'x' is replaced with this number.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: int_fp
  $ #define int_fp
> Purpose:
  | This is the type of an interval floating point number.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: iszero
  $ #define iszero (x)
> Purpose:
  | This determines whether or not x is zero.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: next
  $ #define next (x)
> Purpose:
  | This replaces x with the nearest floating point number greater than x.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: prev
  $ #define prev (x)
> Purpose:
  | This replaces x with the nearest previous floating point number to x.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: roundnearest
  $ #define roundnearest (x)
> Purpose:
  | This function rounds the number x to an integer.  The rounding mode is set to nearest.  'x' is replaced with the new value.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: upperbd
  $ #define upperbd (y, x)
> Purpose:
  | Calculates the upper bound of y and puts it into x. Rounding is set in the positive direction.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: lowerbd
  $ #define lowerbd (y, x)
> Purpose:
  | Calculates the lower bound of y and puts it into x.  Rounding is set in the negative direction.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: upperbd2
  $ #define upperbd2 (y, x)
> Purpose:
  | Calculates the upper bound of y and puts it into x.  Rounding is set to nearest.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: lowerbd2
  $ #define lowerbd2 (y, x)
> Purpose:
  | Calculates the lower bound of y and puts it into x.  Rounding is set to nearest.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: initfpu
  $ #define initfpu ()
> Purpose:
  | Initializes the FPU for usage by the interval arithmetic.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: resetfpu
  $ #define resetfpu ()
> Purpose:
  | Resets the FPU.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: dumpmemory
  $ #define dumpmemory (x)
> Purpose:
  | This macro is for Macintosh mpw systems not including powerpc's.  It's used to dump the memory contents of an object x.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fpu
  $ #define fpu (a,b,c)
> Purpose:
  | This macro is for sunBSD systems and it sets some of the fpu characteristics. 'a' is the operation to perform, while 'b' and 'c' are arguements.  All three are strings.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: booleanZero
  $ #define booleanZero
> Purpose:
  | Encodes the boolean value 0.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: booleanOne
  $ #define booleanOne
> Purpose:
  | Encodes the boolean value 1
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: booleanError
  $ #define booleanError
> Purpose:
  | Mask indicating that an erro occured while evaluating the boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: booleanFail
  $ #define booleanFail
> Purpose:
  | Mask indicating that the boolean interval operation failed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: booleanDisable
  $ #define booleanDisable
> Purpose:
  | Mask indicating that the boolean interval node should be disabled.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_ydef
  $ #define boolean_ydef
> Purpose:
  | Mask indicating that y is defined in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_ychg
  $ #define boolean_ychg
> Purpose:
  | Mask indicating that y has chanegd in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_y
  $ #define boolean_y
> Purpose:
  | Mask for the y value of a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_xdef
  $ #define boolean_xdef
> Purpose:
  | Mask indicating that x is defined in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_xchg
  $ #define boolean_xchg
> Purpose:
  | Mask indicating that x has changed in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_x
  $ #define boolean_x
> Purpose:
  | Mask for the x value of a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_zdef
  $ #define boolean_zdef
> Purpose:
  | Mask indicating that z is defined in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_zchg
  $ #define boolean_zchg
> Purpose:
  | Mask indicating that z has changed in a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: boolean_z
  $ #define boolean_z
> Purpose:
  | Mask for the z value of a boolean interval node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trail
  $ #define trail (te, addr)
> Purpose:
  | Pushes the contents of address 'addr' and 'addr' onto the trail 'te'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: simplebind
  $ #define simplebind (v, new)
> Purpose:
  | Binds the term 'v' to 'new' and trails the old value of 'v'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | Makes sure there is space on the heap for n terms.  If there isn't then a HEAPOVERFLOW error is generated in BNRP_RESUME().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: swap
  $ #define swap (x)
> Purpose:
  | Swaps the h and l values of an interval x and changes their signs.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getSimple
  $ #define getSimple (p, v)
> Purpose:
  | Takes the term p and returns it's value in 'v'.  If 'p' is a symbol, then v is zero, otherwise 'p' has to be some kind of a number term.  If 'p' is not a number term, then a jump to 'failure' is made in BNRP_iterate.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nextArg
  $ #define nextArg (p, x)
> Purpose:
  | Gets the next term of 'p' and puts it into 'x'.  'p' is incremented.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nextAddr
  $ #define nextAddr (p, x, a)
> Purpose:
  | Gets the next term of p and put it into x.  It then puts the address of 'x' into 'a' and increments 'p'
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getValues
  $ #define getValues (x)
> Purpose:
  | Fills in the xtype, xconstraints, xladdr, xhaddr, xl, xh values from the address of an interval x (xaddr)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getBooleanValues
  $ #define getBooleanValues (x)
> Purpose:
  | Fills in the xtype, and xconstraints values for a boolean constraint 'x' using the address (xaddr) if it is a variable.  If it is a point the boolean_x flag is set in booleanInput as well as the boolean_x_def flag.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: updateBoolean
  $ #define updateBoolean (x)
> Purpose:
  | This macro is used to update boolean interval nodes.  This operation always narrows the boolean interval 'x' to a point.  Adds 'x' constraints to the queue of interval nodes.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xflip
  $ #define xflip
> Purpose:
  | Status bit indicating that the x interval's l and h values need to be exchanged.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xlchange
  $ #define xlchange
> Purpose:
  | Status bit indicating that the xl value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xhchange
  $ #define xhchange
> Purpose:
  | Status bit indicating that the xh value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yflip
  $ #define yflip
> Purpose:
  | Status bit indicating that the 'y' interval's l and h values need to exchanged.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ylchange
  $ #define ylchange
> Purpose:
  | Status bit indicating that the yl value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yhchange
  $ #define yhchange
> Purpose:
  | Status bit indicating that the yh value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zflip
  $ #define zflip
> Purpose:
  | Status bit indicating that the z interval's h and l values need to be exchanged.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zlchange
  $ #define zlchange
> Purpose:
  | Status bit indicating that the zl value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zhchange
  $ #define zhchange
> Purpose:
  | Status bit indicating that the zh value has changed.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: redonode
  $ #define redonode
> Purpose:
  | Status bit indicating that the node needs to be re-evaluated.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: link
  $ #define link
> Purpose:
  | Status bit indicating that the top of the queue needs to be linked to the node.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: unflip
  $ #define unflip (x)
> Purpose:
  | Unflips an interval 'x'.  Exchanges the xl and xh values and exchanges the xlchange and xhchange bits in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: updatehalf
  $ #define updatehalf (x, b, m)
> Purpose:
  | Updates half of an interval.  'x' is either: 'x', 'y' or 'z'.  'b' is either 'l' or 'h'  (creating for example 'xl') and 'm' is either 'lowerbd' or 'upperbd'.  It rounds the number either outwards or inwards and binds the
  | new value in.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: update
  $ #define update (x)
> Purpose:
  | This macro is used to update a node 'x' that has changed due to an interval operation.  It updates the bounds of the interval, sets a 'redo' flag if necessary (to re-evaluate the node due to a change update() made) and adds the node's constraints to the queue of nodes that needs evaluating.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: linknode
  $ #define linknode (x)
> Purpose:
  | Links the node at the top of the queue (qhead) to the constraint list of 'x' if 'x' is valid and unbound.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: flushqueue
  $ #define flushqueue ()
> Purpose:
  | Flushes the queue of interval nodes that need to be evaluated.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: interval_op
  $ #define interval_op (f)
> Purpose:
  | Denotes the start of an interval operator definition.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: end_op
  $ #define end_op (f)
> Purpose:
  | Denotes the end of an interval operator definition
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: success
  $ #define success ()
> Purpose:
  | Breaks from the case statement of interval operators.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fail
  $ #define fail ()
> Purpose:
  | Goes to the failure section of BNRP_iterate().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: iaerror
  $ #define iaerror ()
> Purpose:
  | Goes to the error code section of BNRP_iterate().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: schedy
  $ #define schedy ()
> Purpose:
  | Unknown.  UNUSED
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: pi
  $ #define pi ()
> Purpose:
  | Returns the value of pi.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ln
  $ #define ln (x)
> Purpose:
  | Returns the natural logarithm of x
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ceiling
  $ #define ceiling (x)
> Purpose:
  | Returns the ceiling of x.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_add
  $ #define case_add
> Purpose:
  | 'addition' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_begin_tog
  $ #define case_begin_tog
> Purpose:
  | 'begin tog' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_cos
  $ #define case_cos
> Purpose:
  | 'cos' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_equal
  $ #define case_equal
> Purpose:
  | 'equal' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_finish_tog
  $ #define case_finish_tog
> Purpose:
  | 'finish_tog' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_greatereq
  $ #define case_greatereq
> Purpose:
  | '>=' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_higher
  $ #define case_higher
> Purpose:
  | 'higher' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_inf
  $ #define case_inf
> Purpose:
  | 'inf' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_j_less
  $ #define case_j_less
> Purpose:
  | 'less than' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_k_equal
  $ #define case_k_equal
> Purpose:
  | 'k_equal' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_lub
  $ #define case_lub
> Purpose:
  | 'lower and upper bound' operators on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_mul
  $ #define case_mul
> Purpose:
  | 'multiplication' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_narrower
  $ #define case_narrower
> Purpose:
  | 'narrower' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_or
  $ #define case_or
> Purpose:
  | 'or' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_pow_odd
  $ #define case_pow_odd
> Purpose:
  | 'pow_odd' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_qpow_even
  $ #define case_qpow_even
> Purpose:
  | 'qpow_even' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_rootsquare
  $ #define case_rootsquare
> Purpose:
  | 'sqrt' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_sin
  $ #define case_sin
> Purpose:
  | 'sin' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_tan
  $ #define case_tan
> Purpose:
  | 'tan' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_unequal
  $ #define case_unequal
> Purpose:
  | 'unequal' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_vabs
  $ #define case_vabs
> Purpose:
  | 'vabs' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_wrap
  $ #define case_wrap
> Purpose:
  | 'wrap' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_xp
  $ #define case_xp
> Purpose:
  | 'exp' operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: case_ydelta
  $ #define case_ydelta
> Purpose:
  | ydelta operator on an interval.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_nand
  $ #define do_nand
> Purpose:
  | 'nand' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_nor
  $ #define do_nor
> Purpose:
  | 'nor' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_and
  $ #define do_and
> Purpose:
  | 'and' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_or
  $ #define do_or
> Purpose:
  | 'or' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_xor
  $ #define do_xor
> Purpose:
  | 'xor' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_not
  $ #define do_not
> Purpose:
  | 'not' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: do_cond
  $ #define do_cond
> Purpose:
  | 'Conditional' operator on Boolean intervals.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xlchng
  $ #define xlchng ()
> Purpose:
  | Sets the xlchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xhchng
  $ #define xhchng ()
> Purpose:
  | Sets the xhchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ylchng
  $ #define ylchng ()
> Purpose:
  | Sets the ylchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yhchng
  $ #define yhchng ()
> Purpose:
  | Sets the yhchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zlchng
  $ #define zlchng ()
> Purpose:
  | Sets the zlchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zhchng
  $ #define zhchng ()
> Purpose:
  | Sets the zhchange bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: xflipped
  $ #define xflipped ()
> Purpose:
  | Sets the xflip bit in 'status'.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: yflipped
  $ #define yflipped ()
> Purpose:
  | Sets the yflip bit in 'status'
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: zflipped
  $ #define zflipped ()
> Purpose:
  | Sets the zflip bit in 'status' 
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: deact
  $ #define deact ()
> Purpose:
  | Deactivates the current node.  (ie. The node has become bound)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: dump
  $ #define dump (m, x)
> Purpose:
  | Prints out the values of x (an interval variable eg x, y, z) with a message m.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: HEX
  $ #define HEX (x)
> Purpose:
  | Returns the fpoverlay equivalents of x
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
