/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/hardware.h,v 1.6 1997/12/22 17:01:06 harrisj Exp $
*
*  $Log: hardware.h,v $
 * Revision 1.6  1997/12/22  17:01:06  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.5  1997/02/27  17:18:56  harrisj
 * HPUX 10.10 has the getwd() and realpath() functions.
 *
 * Revision 1.4  1995/12/12  14:21:44  yanzhou
 * 1) Signals, depending on the underlying OS, can now be handled
 * in one of the 3 ways listed below:
 *    USE_SIGACTION (POSIX) hpux9,ibm-aix4.1,nav88k-sysVr4,sunOS4.1
 *    USE_SIGSET    (SVID2) mdelta
 *    USE_SIGVECTOR (BSD)   sgi
 *
 * 2) Also changed is the way in which connect() timed-outs are
 * detected.  Was using SIGALRM to force a blocking connect() to
 * exit prematurally.  Now uses a combination of POSIX non-blocking
 * I/O mode (O_NONBLOCK) and select(), which handles the
 * situation more elegantly.
 *
 * 3) Now uses SA_RESTART if it is supported by the underlying OS.
 * This way, when a system call is interrupted by a signal, it is
 * transparently restarted on exit of the signal.
 * There is no need to define TICK_INTERRUPTS_SYSTEM_CALLS if
 * SA_RESTART is in effect.
 *
 * Revision 1.3  1995/12/04  00:10:16  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.2  1995/11/13  11:34:20  yanzhou
 * Now uses `sigaction' on SunOS (sunBSD).  Was using `segvect'.
 *
 * Revision 1.1  1995/09/22  11:24:33  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_hardware
#define _H_hardware

#include "base.h"
#include <stdio.h>
#include <signal.h>

#if defined(unix)
#ifndef mdelta                    /* Not defined on 68000 */
#define DBL_DIG			15
#if defined(ultrix) || defined(sgi) || defined(_AIX) || defined(hpux_10)
/* DBL_MAX already defined */
#else
#define DBL_MAX			MAXDOUBLE
#endif
#endif
#endif

#ifdef mdelta
#define MAXPATHLEN              256
/***** Doesn't have getwd either, fake it 
REMOVED by Oz 04/95 #define getwd(buff)             getcwd(buff, MAXPATHLEN)
******/

/*These two macros were expected in sys/time.h, but aren't there... */
#define timercmp(tvp, uvp, cmp) \
        ((tvp)->tv_sec cmp (uvp)->tv_sec || \
         (tvp)->tv_sec EQ (uvp)->tv_sec && (tvp)->tv_usec cmp (uvp)->tv_usec)
#define timerclear(tvp)         ((tvp)->tv_sec = (tvp)->tv_usec = 0)

/*All this stuff should have been in sys/stat.h, and wasn't */
#define _S_IFMT         0170000 /* type of file */
#define _S_IFREG        0100000 /* regular */
#define _S_IFBLK        0060000 /* block special */
#define _S_IFCHR        0020000 /* characteer special */
#define _S_IFDIR        0040000 /* directory */
#define _S_IFIFO        0010000 /* pipe or FIFO */

#define S_ISDIR(_M)     ((_M & _S_IFMT) EQ _S_IFDIR) /* test for directory */
#define S_ISCHR(_M)     ((_M & _S_IFMT) EQ _S_IFCHR) /* test for char special */
#define S_ISBLK(_M)     ((_M & _S_IFMT) EQ _S_IFBLK) /* test for block special */
#define S_ISREG(_M)     ((_M & _S_IFMT) EQ _S_IFREG) /* test for regular file */
#define S_ISFIFO(_M)    ((_M & _S_IFMT) EQ _S_IFIFO) /* test for pipe or FIFO */

/* This should have been in sys/signal.h and wasn't */
/* macro to find proper bit in a signal bit mask */
#define sigmask(signo)  (1L << (signo - 1))
#endif

extern long BNRPMaxLong;
extern short BNRPFPPrecision;
#define BNRP_getMaxLong()		BNRPMaxLong
fp BNRP_getMaxFP();
#define BNRP_getFPPrecision()	BNRPFPPrecision
unsigned long BNRP_getUserTime(BNRP_Boolean delay, fp *adjustment);
unsigned long BNRP_getElapsedTime(void);
BNRP_Boolean BNRP_truncateFile(FILE *f, long len);
BNRP_Boolean BNRP_setConfig(char *s);
char *BNRP_getConfig();

typedef struct fileDate {
	int year;
	int month;
	int day;
	int hour;
	int minute;
	int second;
	int dayOfWeek;
	} fileDate;
typedef struct fileInfo {
	char fileCreator[5];
	char fileType[5];
	BNRP_Boolean DFOpen;
	long DSize;
	BNRP_Boolean RFOpen;
	long RSize;
	fileDate created;
	fileDate modified;
	} fileInfo;
typedef struct BNRP_dirEntry {
	char *name;
	BNRP_Boolean isDir;
	} BNRP_dirEntry;
	
int getFileInfo(char *path, fileInfo *info);
int exists(char *filename);

#ifdef Macintosh
#define MAXPATHLEN			256
char *getwd(char *buff);
int chdir(char *path);
#else
#include <sys/param.h>		/* for MAXPATHLEN */
#endif

#ifndef _AIX /* getcwd/getwd/realpath are defined on AIX */
#ifndef hpux_10
#if defined(hpux) || defined(AUX) || defined(solaris) || defined(nav) || defined(mdelta)
/* char *getcwd(char *buff, size_t len); */
#define getwd(buff)			getcwd(buff, MAXPATHLEN)
#else
char *getwd(char *buff);
#endif

char *realpath(char *path, char *resolvedpath);
#endif
#endif

#if defined(Macintosh)
int BNRP_mkdir(char *path);
int BNRP_rmdir(char *path);
#define mkdir(path, mode)	BNRP_mkdir(path)
#define rmdir(path)			BNRP_rmdir(path)
#else
#define remove		unlink
/* #if defined(sun)		 Newer compiler's than gcc 2.2.2 don't need this 
int mkdir(char *path, int mode);
int rmdir(char *path);
#endif*/
#endif

BNRP_Boolean BNRP_opendir(char *name);
void BNRP_closedir(void);
BNRP_dirEntry *BNRP_readdir(void);
BNRP_Boolean BNRP_openvols(void);
BNRP_dirEntry *BNRP_readvol(void);
void BNRP_setTimer(fp *time, void (*func)());
void BNRP_sleep(fp time, int ignoreTicks);

#ifdef Macintosh
void *BNRP_malloc(unsigned long size);
void *BNRP_realloc(void *p, unsigned long size);
void BNRP_free(void *ptr);
#else
#ifdef sun
#define BNRP_malloc(size)		(void *)memalign(headerAlignment, size)
#else
#define BNRP_malloc(size)		(void *)malloc(size)
#endif
#define BNRP_realloc(p, size)	(void *)realloc(p, size)
#define BNRP_free(p)			free(p)
#endif

#ifdef Macintosh
#define FS_SEPARATOR		':'
#else
#define FS_SEPARATOR		'/'
#endif

/*
 * How to handle signals:
 *
 * USE_SIGACTION:  to use sigaction/sigprocmask/sigsuspend (POSIX)
 * USE_SIGSET:     to use sigset/sighold/sigpause/sigrelse (SVID2)
 * USE_SIGVECTOR:  to use sigvector/sigblock/sigsetmask    (BSD)
 *
 */
#if defined(hpux) || defined(nav) || defined(sunBSD) || defined(_AIX) || defined(solaris)
#  define USE_SIGACTION
#endif

#if defined(mdelta)
#  define USE_SIGSET
#endif

#if defined(sgi)
#  define USE_SIGVECTOR
#endif

#if !defined(USE_SIGACTION) && !defined(USE_SIGSET) && !defined(USE_SIGVECTOR)
#  define USE_SIGACTION                         /* default to use SIGACTION */
#endif

/* TICK_INTERRUPTS_SYSTEM_CALLS
 *    on System V implementations, real-time timer can interrupt
 *    system calls (reads from a terminal, wait, pause).  Set this
 *    flag to compile code that checks for it.  On BSD systems, the
 *    timer is queued until we return to user code, which is OK since
 *    the user only gets to see it at the next LIP.
 */
#if defined(USE_SIGSET)                         /* SIGSET is used by SysV machines */
#  define TICK_INTERRUPTS_SYSTEM_CALLS
#endif

/* If a system call is interrupted by a signal, some OS allows the
 * system call to be transparently restarted.  SA_RESTARTSYSCALL tells
 * how.
 */
#ifdef USE_SIGACTION
/* On NAV m88k SysVr4, SA_RESTART tells the system to restart
   interrupted system calls transparently */
#  ifdef nav
#    define SA_RESTARTSYSCALL SA_RESTART
#  endif
/* On SunOS Sparc 4.1.3 (sunBSD), interrupted system calls are always
   restarted unless disabled by SA_INTERRUPT */
#  ifdef sunBSD
#    define SA_RESTARTSYSCALL 0
#  endif
/* On IBM Power/RS6000 AIX 4.1.4, SA_RESTART tells the system to
   restart interrupted system calls transparently */
#  ifdef _AIX
#    define SA_RESTARTSYSCALL SA_RESTART
#  endif
/* HP-UX 9.x does not support SA_RESTART */
#  ifdef hpux
#  undef SA_RESTARTSYSCALL
#  endif
/* On Sun Sparc Solaris 2.x (SunOS 5.x), UNKNOWN */
#  ifdef solaris
#  undef SA_RESTARTSYSCALL
#  endif
/* If SA_RESTARTSYSCALL is not defined, then we assume that certain
 * system calls can get interrupted by SIGALRM.
 */
#  ifndef SA_RESTARTSYSCALL
#    define TICK_INTERRUPTS_SYSTEM_CALLS
#  endif
#endif /* USE_SIGACTION */

/* Signal handler */
#ifdef USE_SIGACTION
   typedef struct sigaction BNRP_sighandler;
#endif
#ifdef USE_SIGSET
   typedef void (* BNRP_sighandler)(int);
#endif
#ifdef USE_SIGVECTOR
   typedef struct sigvec BNRP_sighandler;
#endif

BNRP_sighandler BNRP_initSighandler(void (* handler)(int));
BNRP_sighandler BNRP_installSighandler(int signo, BNRP_sighandler handler);
void BNRP_callSighandler(BNRP_sighandler handler, int signo);
int  BNRP_compareSighandler(BNRP_sighandler handler1, BNRP_sighandler handler2);

void BNRP_blockSignal(int signo);
void BNRP_unblockSignal(int signo);
void BNRP_waitforSignal(int signo);

/* signal(2) should never be used in the code */
#define signal(s,x) printf("Panic (File %s, Line %d): old-style signal(2) is still being used.\n",\
                            __FILE__, __LINE__); exit(-1)

static BNRP_sighandler oldSigIntHandler;
static BNRP_sighandler oldSigFpeHandler;

#endif

