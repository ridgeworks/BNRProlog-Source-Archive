/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/base.h,v 1.6 1998/02/25 08:13:22 csavage Exp $
*
*  $Log: base.h,v $
 * Revision 1.6  1998/02/25  08:13:22  csavage
 * Error 42 adjusted to give "too many variables"
 * at 126 rather than 256.
 *
 * Revision 1.5  1998/01/20  14:53:55  thawker
 * 1. Added solaris networking support definition
 * 2. Undefined labs(x) for solaris, it is defined by system
 *
 * Revision 1.4  1997/12/22  17:00:52  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.3  1997/08/12  17:34:39  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.2  1995/12/03  23:50:24  yanzhou
 * 1. Now supports IBM Power/RS6000 AIX4.1
 * 2. Switched to use bit and/or operations in macros tagof/addrof/makevarterm/etc.
 *
 * Revision 1.1  1995/09/22  11:21:09  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_base
#define _H_base

/* if no ring defined when compiling, compile all rings */
#ifndef ring0
#ifndef ring1
#ifndef ring2
#ifndef ring3
#ifndef ring4
#ifndef ring5
#ifndef ring6
#define ring0
#define ring1
#define ring2
#define ring3
#define ring4
#define ring5
#define ring6
#endif
#endif
#endif
#endif
#endif
#endif
#endif

#include "BNRProlog.h"

#ifdef unix
#ifdef m68k                                                             /* Motorola 68000 SysV3 */
#define mdelta
enum {FALSE, TRUE};
#define fp                      double
#define constantAlignment       sizeof(long)
#define headerAlignment         sizeof(fp)
#define fpAlignment             sizeof(fp)
#define allocationSize          (16 * 1024)
#endif
#endif

#ifdef unix
#ifdef _AIX                     /* IBM Power/RS6000 AIX 4.1 */
#define fp                      double
#define constantAlignment       sizeof(long)
#define headerAlignment         sizeof(double)
#define fpAlignment             sizeof(double)
#define allocationSize          (16 * 1024)
#define adjustMemory
#define supportNetworking
#endif

#ifdef m88k                     /* Motorola 88000 SysV4 - NAV */
#define nav
enum {FALSE, TRUE};
#define fp                      double
#define constantAlignment       sizeof(long)
#define headerAlignment         sizeof(fp)
#define fpAlignment             sizeof(fp)
#define allocationSize          (16 * 1024)
#define supportNetworking
#endif
#endif

#ifdef AUX									/* AUX 2.0 GCC */
enum {FALSE, TRUE};
#define fp					double
#define labs(x)				abs(x)
#define headerAlignment		sizeof(long)
#define allocationSize		(16 * 1024)
#define _POSIX_SOURCE
#endif

#ifdef hpux									/* HP 300/400/700/800 GCC */
enum {FALSE, TRUE};
#define fp					double
#ifndef hppa
#define headerAlignment		sizeof(long)
#else										/* HP 700/800 only */
#define constantAlignment	sizeof(long)
#define headerAlignment		sizeof(fp)
#define fpAlignment			sizeof(fp)
#define adjustMemory
#endif
#define allocationSize		(16 * 1024)
#define supportNetworking
#endif

#ifdef sun									/* Sun GCC */
enum {FALSE, TRUE};
#define fp					double
#define labs(x)				abs(x)
#ifdef sparc								/* SUN SparcStation */
#define constantAlignment	sizeof(long)
#define headerAlignment		sizeof(double)
#define fpAlignment			sizeof(double)
#endif
#ifdef mc68000								/* SUN 2, 3 */
#define headerAlignment		sizeof(long)
#endif
#ifdef __svr4__								/* SOLARIS */
#define solaris
#define supportNetworking
#undef labs(x)
#define allocationSize		(sysconf(_SC_PAGESIZE) * 4)
#else
#define sunBSD								/* SunOS prior to Solaris */
#define allocationSize		(getpagesize() * 4)
#define supportNetworking
#endif
#endif

#ifdef sgi									/* Silicon Graphics GCC */
enum {FALSE, TRUE};
#define fp					double
#define labs(x)				abs(x)
#define constantAlignment	sizeof(long)
#define headerAlignment		sizeof(double)
#define fpAlignment			sizeof(double)
#define allocationSize		(getpagesize() * 4)
#endif

#ifdef ultrix								/* DECstation GCC */
enum {FALSE, TRUE};
#define fp					double
#define labs(x)				abs(x)
#define constantAlignment	sizeof(long)
#define headerAlignment		sizeof(long)
#define REVERSE_ENDIAN
#define allocationSize		(getpagesize() * 4)
#endif

#ifdef THINK_C								/* Macintosh THINK C */
#define Macintosh
#define headerAlignment		sizeof(long)
#define fp					short double
#define isascii(c)      	((unsigned)(c)<=0x7F)
#define allocationSize		(16 * 1024)
#define M_PI				3.14159265358979323846264338327950288
#endif

#ifdef __MWERKS__							/* Macintosh Metrowerks CodeWarrior */
#define Macintosh
enum {FALSE, TRUE};
#define headerAlignment		sizeof(long)
#define fp					double
#define isascii(c)      	((unsigned)(c)<=0x7F)
#define allocationSize		(16 * 1024)
#define M_PI				3.14159265358979323846264338327950288
#endif

#ifdef applec								/* Macintosh MPW, 68K only */
#define __mpw
#endif

#if defined(powerc) || defined (__powerc)	/* Macintosh PowerPC */
#ifndef __MWERKS__							/* both MPW and CodeWarrior declare this */
#define __mpw
#endif
#endif

#ifdef __mpw
#define Macintosh
#define debugMessages
#define headerAlignment		sizeof(long)
#include <types.h>
enum {FALSE, TRUE};
#define fp					double
#define allocationSize		(10 * 1024)
#define M_PI				3.14159265358979323846264338327950288
#endif

#ifdef MSDOS								/* IBM Microsoft C */
enum {FALSE, TRUE};
#define headerAlignment		sizeof(long)
#define fp					double
#define allocationSize		(10 * 1024)
#endif

#ifdef constantAlignment
#define constantLWA(a)		while ((long)(a) & (constantAlignment - 1)) ++(a)
#else
#define constantLWA(a)
#endif

#ifdef headerAlignment
#define headerLWA(a)		while ((long)(a) & (headerAlignment - 1)) ++(a)
#else
#define headerLWA(a)
#endif

/* NOTE: if fpAlignment not defined then assumed constantAlignment is OK */
#ifdef fpAlignment
#define fpLWA(a)			while ((long)(a) & (fpAlignment - 1)) ++(a)
#else
#define fpLWA(a)
#endif

#define TAGMASK  0xE0000000 /*  3-bit tag     */
#define ADDRMASK 0x1FFFFFFF /* 29-bit address */

#ifdef adjustMemory /* adjustMemory */
#define tagof(term)			((long)(term) & TAGMASK)
#define addrof(term)		(((long)(term) & ADDRMASK) | BNRP_baseOffset)
#ifdef __GNUC__
#define maketerm(tag, addr)	({ long __tag = (tag), __addr = (addr) - BNRP_baseOffset; \
							   if (__tag & ADDRMASK) fprintf(stderr, "Invalid tag in file " __FILE__ " line %d\n", __LINE__); \
							   if (__addr & TAGMASK) fprintf(stderr, "Invalid address in file " __FILE__ " line %d\n", __LINE__); \
							   (__tag | __addr); })
#else
#define maketerm(tag, addr)	((tag) | (((long)(addr)) & ADDRMASK))
#endif
#define derefVAR(v)			(*(long *)addrof(v))
extern long BNRP_baseOffset;
#else               /* adjustMemory */
#define tagof(term)			((long)(term) & TAGMASK)
#define addrof(term)		((long)(term) & ADDRMASK)
#ifdef __GNUC__
#define maketerm(tag, addr)	({ long __tag = (tag), __addr = (addr); \
							   if (__tag & ADDRMASK) fprintf(stderr, "Invalid tag in file " __FILE__ " line %d\n", __LINE__); \
							   if (__addr & TAGMASK) fprintf(stderr, "Invalid address in file " __FILE__ " line %d\n", __LINE__); \
							   (__tag | __addr); })
#else
#define maketerm(tag, addr)	((tag) | (addr))
#endif
#define derefVAR(v)			(*(long *)v)
#endif              /* adjustMemory */

#define makeintterm(i)		(INTTAG | ((long)(i) & ADDRMASK))

#ifdef adjustMemory
#define makevarterm(i)		(((long)(i)) & ADDRMASK)
#else
#define makevarterm(i)		((long)(i))
#endif

union longandshort {
	long l;
	struct {
#ifdef REVERSE_ENDIAN
		short b, a;
#else
		short a, b;
#endif
		} i;
	};
typedef union longandshort li;

union lf {					/* used for copying fp numbers quickly */
	long l;
	fp f;
	};
typedef union lf lf;

#define EQ	==
#define NE	!=
#define LT	<
#define LE	<=
#define GT	>
#define GE	>=
#define AND	&&
#define OR	||

typedef unsigned char BYTE;
typedef long *ptr;

/* for these comparisons, a1 and a2 are of type (long *) */
#define comparelong(a1, a2, fail)		if (*a1 NE *a2) fail
#define comparefp(a1, a2, fail)			if (sizeof(fp) LE 4) { \
											if (*a1++ NE *a2++) fail; \
											} \
										else if (sizeof(fp) LE 8) { \
											if (*a1++ NE *a2++) fail; \
											if (*a1++ NE *a2++) fail; \
											} \
										else { \
											if (*a1++ NE *a2++) fail; \
											if (*a1++ NE *a2++) fail; \
											if (*a1++ NE *a2++) fail; \
											}

#define push(Type, Addr, Value)			*(Type *)(Addr) = Value; \
										(Addr) += sizeof(Type)
#define rpush(Type, Addr, Value)		(Addr) -= sizeof(Type); \
										*(Type *)(Addr) = Value
										
#define pop(Type, Addr, Value)			(Addr) -= sizeof(Type); \
										Value = *(Type *)(Addr)
#define rpop(Type, Addr, Value)			Value = *(Type *)(Addr); \
										(Addr) += sizeof(Type)

#define get(Type, Addr, Value)			Value = *(Type *)(Addr); \
										(Addr) += sizeof(Type)


/***************************************************************************

	Memory allocation:
	Note that the heap must be at a lower address than environment stack.
	
	space ->		|	  |
					|     |
	ASTBase ->		|	  |
	
	heapbase ->		|     |
					|     |
	hp ->			|     |			heap pointer
					|     |
	te ->			|     |			trail end
					|     |
	trailbase ->	|     |

	envbase ->		|     |
					|     |
	ce ->			|     |			current environment
					|     |
	lcp ->			|     |			last choicepoint
					|     |
	cpbase ->		|     |
	
***************************************************************************/

#define MAXREGS			255
#define MAXARGS                 126

typedef struct runHeader TCB;
struct runHeader {
	TCB *prevTask;						/* task header */
	long validation;
	BNRP_term taskName;
	long smsgVal;
	long rmsgVal;
	TCB *invoker;
	TCB *invokee;
	long space;							/* global allocation */
	long freePtr;						/* pointer to free space in global allocation */
	long ASTbase;						/* start of AST */
	long heapbase;						/* start of heap */
#define heapend		te
	long trailbase;						/* start of trail (backwards) */
#define trailend	hp
	long envbase;						/* start of environment records */
#define envend		lcp
	long cpbase;						/* start of choicepoints (backwards) */
#define cpend		ce
	long spbase;						/* start of push down stack */
	long spend;							/* end of push down stack */
	long emptyList;
	long ppsw;							/* misc control information */
										/* defined as flags(8) | mode(8) | result(16) */
#define isolateResult	0x0000FFFF
#define isolateMode		0x00FF0000
#define isolateFlags	0xFF000000
#define headMode		0x00000000
#define headWriteMode	0x00010000
#define bodyMode		0x00800000
#define bodyEscape      0x00900000
#define bodyEscapeClause        0x00B00000
	long te;							/* top of trail */
	long lcp;							/* last choicepoint */
	long cutb;							/* cut point register */
	long svsp;							/* original stack pointer */
	long hp;							/* top of heap */
	long ppc;							/* prolog program counter */
	long ce;							/* current environment */
	long cp;							/* continuation pointer */
	long stp;							/* stack pointer in case we interrupt head codes */
	long glbctx;						/* to global environment */
	long constraintHead;				/* pointers used by constraints */
	long constraintTail;
	long procname;						/* name of current call */
#define nargs	args[0]
	long args[MAXREGS];
	};
	
BNRP_term BNRPLookupSymbol(TCB *tcb, const char *s, BNRP_Boolean temp, BNRP_Boolean global);
BNRP_Boolean BNRPFindSymbol(const char *s, BNRP_Boolean global, BNRP_term *atom);
#define TEMPSYM		TRUE
#define PERMSYM		FALSE
#define GLOBAL		TRUE
#define LOCAL		FALSE

BNRP_Boolean BNRPBindPrimitive(const char *name, BNRP_Boolean (*address)());

#endif
