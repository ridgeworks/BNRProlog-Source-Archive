#if 0
----------------------------------------------------------------------
> Union:
  | longandshort
  $ union longandshort
> Purpose:
  | This union is useful for converting between a long a two shorts.
> Base Classes:
  = No baseclasses... - 
> Important Members:
  = No methods... - 
  = long l - long integer
  = class  i - Structure containing 2 shorts (a and b)
  = No enumerations defined... - 
  = No typedefs defined... - 
> Concurrency:
  | Multithread safe. XXXXX_U_CON
  | _Not_ multithread safe. XXXXX_U_CON
> Other Considerations:
  | XXXXX_U_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Union:
  | lf
  $ union lf
> Purpose:
  | This union is used to copy fp numbers quickly
> Base Classes:
  = No baseclasses... - XXXXX_U_BAS
> Important Members:
  = No methods... - XXXXX_U_MET
  = long l - long representation of a float
  = fp f - floating point number
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
> Struct:
  | runHeader
  $ struct runHeader
> Purpose:
  | The runHeader structure contains the registers required to support a Prolog task
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = TCB* prevTask - Pointer to the previous TCB in the task chain
  = long validation - Proof of a valid task is stored here
  = BNRP_term taskName - Symbolic name of the task
  = long smsgVal - The term the task was sent (only used if multi-tasking)
  = long rmsgVal - Stores BNRP_flags when in the "wait" state
  = TCB* invoker - The task that invoked this one
  = TCB* invokee - The task that this task invoked,
  = long space - Start of allocated global space
  = long freePtr - Pointer to free space in global allocation
  = long ASTbase - start of AST
  = long heapbase - start of heap
  = long trailbase - start of trail (backwards)
  = long envbase - start of environment records
  = long cpbase - start of choicepoints (backwards)
  = long spbase - start of push down stack
  = long spend - end of push down stack
  = long emptyList - 
  = long ppsw - misc control information (flags(8) | mode(8) | result(16))
  = long te - top of trail
  = long lcp - last choicepoint
  = long cutb - cut point register
  = long svsp - original stack pointer
  = long hp - top of heap
  = long ppc - prolog program counter
  = long ce - current environment
  = long cp - continuation pointer
  = long stp - stack pointer in case we interrupt head codes
  = long glbctx - to global environment
  = long constraintHead - start of constraint queue
  = long constraintTail - end of constraint queue
  = long procname - Name of current call
  = long[MAXREGS] args - Arguements passed in with call
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
  | unnamed_enum
  $ enum unnamed_enum {FALSE, TRUE}
> Purpose:
  = This is used to indicate success and failure from primitives
> Tags:
  = FALSE
  = TRUE - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | li
  $ typedef longandshort li
> Purpose:
  | Type definition for longandshort union
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | lf
  $ typedef lf lf
> Purpose:
  | Type definition for lf union
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | BYTE
  $ typedef unsigned char BYTE
> Purpose:
  | This type definition is used for dealing with byte codes
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | ptr
  $ typedef long* ptr
> Purpose:
  | This is a convenient manner of dealing with pointers
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | TCB
  $ typedef runHeader TCB
> Purpose:
  | This is the type definition for the runHeader structure
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_base
  $ #define _H_base
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring0
  $ #define ring0
> Purpose:
  | This is defined to enable ring0 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring1
  $ #define ring1
> Purpose:
  | This is defined to enable ring1 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring2
  $ #define ring2
> Purpose:
  | This is defined to enable ring2 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring3
  $ #define ring3
> Purpose:
  | This is defined to enable ring3 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring4
  $ #define ring4
> Purpose:
  | This is defined to enable ring4 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring5
  $ #define ring5
> Purpose:
  | This is defined to enable ring5 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ring6
  $ #define ring6
> Purpose:
  | This is defined to enable ring6 primitives and functionality.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: mdelta
  $ #define mdelta
> Purpose:
  | This is defined if the platform we are on is the Delta Workstation m68k Unix platform
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fp
  $ #define fp
> Purpose:
  | This is the platform dependant definition of a floating point number
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: constantAlignment
  $ #define constantAlignment
> Purpose:
  | Platform dependant memory alignment for constant terms.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: headerAlignment
  $ #define headerAlignment
> Purpose:
  | Platform dependant memory alignment for structure and list headers
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fpAlignment
  $ #define fpAlignment
> Purpose:
  | Platform dependant memory alignment for floating point numbers
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: allocationSize
  $ #define allocationSize
> Purpose:
  | Used for allocating space within a context.  Typically this is 4 pages of memory.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nav
  $ #define nav
> Purpose:
  | Thisis defined for the m88k SysV Unix platform
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: supportNetworking
  $ #define supportNetworking
> Purpose:
  | This is defined for platforms that can support BNRProlog's networking primitives.  If this is not defined, then networking is not enabled.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: labs
  $ #define labs (x)
> Purpose:
  | Platform dependant macro to get the absolute value of x.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _POSIX_SOURCE
  $ #define _POSIX_SOURCE
> Purpose:
  | This is defined if POSIX source is to be used
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: adjustMemory
  $ #define adjustMemory
> Purpose:
  | This gets defined for platforms that use memory offsets
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: solaris
  $ #define solaris
> Purpose:
  | This is defined for platforms using the Solaris SVR4 OS
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: sunBSD
  $ #define sunBSD
> Purpose:
  | This is defined for platforms using SunOS prior to Solaris
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: REVERSE_ENDIAN
  $ #define REVERSE_ENDIAN
> Purpose:
  | Defined on platforms that are reverse endian
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: Macintosh
  $ #define Macintosh
> Purpose:
  | Defined on Macintosh platforms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isascii
  $ #define isascii (c)
> Purpose:
  | Platform dependant macro that returns whether or not c is an ascii value
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: M_PI
  $ #define M_PI
> Purpose:
  | pi value on some Macintosh platforms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: __mpw
  $ #define __mpw
> Purpose:
  | Defined on some Macintosh platforms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: debugMessages
  $ #define debugMessages
> Purpose:
  | Indicates whether or not to enable debugging on __mpw platforms
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: constantLWA
  $ #define constantLWA (a)
> Purpose:
  | Aligns 'a' to receive a constant
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: headerLWA
  $ #define headerLWA (a)
> Purpose:
  | Aligns 'a' to receive a structure or list header
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: fpLWA
  $ #define fpLWA (a)
> Purpose:
  | Aligns 'a 'to receive a floating point number
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: tagof
  $ #define tagof (term)
> Purpose:
  | Returns the tag of a term
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: addrof
  $ #define addrof (term)
> Purpose:
  | Returns the memory address of a term
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: maketerm
  $ #define maketerm (tag, addr)
> Purpose:
  | Given a tag and an address returns a term
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: derefVAR
  $ #define derefVAR (v)
> Purpose:
  | Dereferences the variable v
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: makeintterm
  $ #define makeintterm (i)
> Purpose:
  | Returns a simple integer term using i which is a short.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: makevarterm
  $ #define makevarterm (i)
> Purpose:
  | Constructs a variable term from address i
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: EQ
  $ #define EQ
> Purpose:
  | Convenience macro for ==
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NE
  $ #define NE
> Purpose:
  | Convenience macro for !=
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LT
  $ #define LT
> Purpose:
  | Convenience macro for <
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LE
  $ #define LE
> Purpose:
  | Convenience macro for <=
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GT
  $ #define GT
> Purpose:
  | Convenience macro for >
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GE
  $ #define GE
> Purpose:
  | Convenience macro for >=
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: AND
  $ #define AND
> Purpose:
  | Convenience macro for &&
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OR
  $ #define OR
> Purpose:
  | Convenience macro for ||
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: comparelong
  $ #define comparelong (a1, a2, fail)
> Purpose:
  | Compares two longs. If they are not equal then fail is performed.  a1 and a2 are pointers to longs.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: comparefp
  $ #define comparefp (a1, a2, fail)
> Purpose:
  | Compares 2 floating point numbers.  If they are not equal, then 'fail' is performed.  a1 and a2 are pointers to longs
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: push
  $ #define push (Type, Addr, Value)
> Purpose:
  | Pushes an item 'Value" of type 'Type' onto Addr.  Increments Addr by size of Type
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: rpush
  $ #define rpush (Type, Addr, Value)
> Purpose:
  | Pushes an item 'Value" of type 'Type' onto Addr.  Decrements Addr by size of Type.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: pop
  $ #define pop (Type, Addr, Value)
> Purpose:
  | Decrements Addr by 'Type' and then pops the top item of Addr off into Value
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: rpop
  $ #define rpop (Type, Addr, Value)
> Purpose:
  | Increments Addr by 'Type' and then pops the top item of Addr off into Value
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: get
  $ #define get (Type, Addr, Value)
> Purpose:
  | Takes the top item of size Type from Addr and puts it into Value.  Increments Addr.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXREGS
  $ #define MAXREGS
> Purpose:
  | Maximum number of registers a runHeader can hold for arguements.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapend
  $ #define heapend
> Purpose:
  | This is a convenience macro that holds a runHeader's end of heap pointer
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: trailend
  $ #define trailend
> Purpose:
  | This is a convenience macro that holds a runHeader's end of trail pointer
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: envend
  $ #define envend
> Purpose:
  | This is a convenience macro that holds a runHeader's end of environment pointer.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: cpend
  $ #define cpend
> Purpose:
  | This is a convenience macro that holds a runHeader's end of choicepoint pointer.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isolateResult
  $ #define isolateResult
> Purpose:
  | Result bits of a runHeader's ppsw
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isolateMode
  $ #define isolateMode
> Purpose:
  | Mode bits of a runHeader's ppsw
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: isolateFlags
  $ #define isolateFlags
> Purpose:
  | Flag bits of a runHeader's ppsw
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: headMode
  $ #define headMode
> Purpose:
  | ppsw mode for head mode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: headWriteMode
  $ #define headWriteMode
> Purpose:
  | ppsw mode for head write mode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: bodyMode
  $ #define bodyMode
> Purpose:
  | ppsw mode for body mode
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nargs
  $ #define nargs
> Purpose:
  | Convenience macro for the runHeader struct to get args[0] which is the number of arguements.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TEMPSYM
  $ #define TEMPSYM
> Purpose:
  | Convenience macro to indicate a temporary symbol
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: PERMSYM
  $ #define PERMSYM
> Purpose:
  | Convenience macro to indicate a permanent symbol
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GLOBAL
  $ #define GLOBAL
> Purpose:
  | Convenience macro to indicate a global symbol
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOCAL
  $ #define LOCAL
> Purpose:
  | Convenience macro to indicate a local symbol
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
