/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/fsysprim.c,v 1.14 1998/01/21 21:17:09 wcorebld Exp $
*
*  $Log: fsysprim.c,v $
 * Revision 1.14  1998/01/21  21:17:09  wcorebld
 * Cleaned up some type casts that HPUX 10.20 complained about
 *
 * Revision 1.13  1997/11/21  14:30:46  harrisj
 * New primitive gmtime added to return GMT
 *
 * Revision 1.12  1997/05/12  13:26:55  harrisj
 * Modified date using functions to output year using 4 digits
 * instead of 2
 *
 * Revision 1.11  1996/06/16  14:24:15  yanzhou
 * Now compiles on sunBSD.
 *
 * Revision 1.10  1996/04/19  01:29:12  yanzhou
 * Added new primitives random/1 and randomseed/1 to BNRProlog ring 5.
 *
 * Revision 1.9  1996/04/11  11:34:41  yanzhou
 * Now compiles on m88k.
 *
 * Revision 1.8  1996/02/19  01:56:53  yanzhou
 * Primitive time() enhanced, it now takes the form of:
 *   time(-EpochSeconds, -MicroSeconds)
 *
 * Revision 1.7  1996/02/13  02:41:49  yanzhou
 * localtime() revised with its comments and number of arguments corrected.
 *
 * Revision 1.6  1996/01/31  23:52:20  yanzhou
 * New time/date-related primitives:
 *   time, localtime and mktime.
 *
 * Revision 1.5  1995/12/12  14:21:41  yanzhou
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
 * Revision 1.4  1995/12/04  00:06:36  yanzhou
 * Bug fix in BNRP_getenv(), where a NULL pointer was passed to BNRPLookupSymbol().
 *
 * Revision 1.3  1995/11/17  16:55:16  yanzhou
 * Changed BNRP_systemCall() to ignore SIGPIPE in popen().
 * The message of `Broken Pipe' was being printed out on NAV88K.
 *
 * Revision 1.2  1995/10/18  13:24:28  yanzhou
 * Modified: BNRP_systemCall to support system/3.
 *
 * Revision 1.1  1995/09/22  11:24:25  harrisja
 * Initial version.
 *
*
*/
#include "BNRProlog.h"
#include "base.h"
#include <stdio.h>

#ifdef mdelta
#define _SIZE_T                                 /* m68000 does not define _SIZE_T ? */
#endif

#include <stddef.h>
#include <stdlib.h>                             /* for system(), lrand48() and srand48() */

#if defined(hpux) || defined(solaris)           /* HP 300/400/700/800, SunSolaris */
#include <unistd.h>                             /* for getcwd */
#endif
#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#if defined(_AIX) || defined(m88k) || defined(sunBSD)
#include <sys/time.h>
#endif
#include <errno.h>                              /* for errnor yanzhou */
#include "core.h"
#include "interpreter.h"
#include "utility.h"
#include "hardware.h"
#include "fsysprim.h"

/* #define DEBUG /* */


#ifdef ring5
BNRP_Boolean BNRP_systemCall(TCB *tcb)
{
	long result;
	BNRP_Boolean res = FALSE;
#ifdef unix
    /*
     * system/3-specific variables, Oct 1995, yanzhou@bnr.ca
     */
    FILE *filep;                                /* popen return value */
    char buffer[4096];                          /* popen output       */
    int  datlen;
    int  errorcode;
#endif /* unix */ 
#ifdef SIGPIPE
    /*
     * yanzhou@bnr/ca:16/11/95: to ignore sigpipe during popen
     * yanzhou@bnr/ca:08/12/95: modified
     */
    BNRP_sighandler oldPipeHandler;
#endif
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
	BNRP_sighandler oldAlarmHandler;

	oldAlarmHandler = BNRP_installSighandler(SIGALRM, BNRP_initSighandler(SIG_IGN));
#endif
#ifdef SIGPIPE
    oldPipeHandler  = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(SIG_IGN));
#endif

	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &result) EQ SYMBOLT))
		res = (system(nameof(result)) EQ 0);
	else if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT))
		res = (unify(tcb, tcb->args[2], makeint(&tcb->hp, system(nameof(result)))));
#ifdef unix
    /*
     * system/3: system(+command, -ErrorCode, -StdOut).
     *   Converts the output of +command to a symbol,
     *   and unifies the symbol with -StdOut.
     *   Returns error code in -ErrorCode, in particular
     *     -2 means that the output has been truncated.
     *
     * this is a unix-specific feature (implemented in popen)
     *
     * October 1995, yanzhou@bnr.ca
     */ 
    else if ((tcb->numargs EQ 3) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
        filep = popen(nameof(result), "r");     /* open the pipe  */
        datlen = fread(buffer, 1, sizeof(buffer), filep);
        errorcode = pclose(filep);              /* read and close */

        if (datlen >= sizeof(buffer)) {         /* truncate ?     */
            datlen = sizeof(buffer)-1;          /* yes            */
            if (!errorcode)
                errorcode = -2;
        }

        /* get rid of the trailing NLs */
        while (datlen > 0 && buffer[datlen-1] == '\n')
            datlen --;
        /* NUL-terminating             */
        buffer[datlen] = '\0';
                
        res = unify(tcb, tcb->args[2], makeint(&tcb->hp, errorcode)) &&
            unify(tcb, tcb->args[3], BNRPLookupSymbol(tcb, buffer, TEMPSYM, GLOBAL));
    }
#endif /* unix */

#ifdef SIGPIPE
    BNRP_installSighandler(SIGPIPE,oldPipeHandler);
#endif
#ifdef TICK_INTERRUPTS_SYSTEM_CALLS
	BNRP_installSighandler(SIGALRM,oldAlarmHandler);
#endif
	return(res);
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_getenv(TCB *tcb)
{
	long result;
	char *getenv();
    char *value;
	
	if ((tcb->numargs EQ 2) && (checkArg(tcb->args[1], &result) EQ SYMBOLT)) {
        value = getenv(nameof(result));
        if (value)
            return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, value, TEMPSYM, GLOBAL)));
    }
	return(FALSE);
}
#endif

#ifdef ring4
BNRP_Boolean BNRP_defaultDir(TCB *tcb)
{
	TAG tag;
	BNRP_term l;
	char dir[MAXPATHLEN];
	
	if (tcb->numargs EQ 1) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ SYMBOLT) {
			return(strlen(nameof(l)) EQ 0 ? FALSE : chdir(nameof(l)) EQ 0);
			}
		else if (tag EQ VART) {
			if (getwd(dir) EQ NULL) return(FALSE);
			return(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, dir, TEMPSYM, GLOBAL)));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_isFile(TCB *tcb)
{
	BNRP_term l;
	fileInfo info;
	
	if (tcb->numargs NE 21) return(FALSE);
	if (checkArg(tcb->args[1], &l) NE SYMBOLT) return(FALSE);
	if (getFileInfo(nameof(l), &info) NE 0) return(FALSE);
	return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, info.fileCreator, TEMPSYM, GLOBAL)) &&
		   unify(tcb, tcb->args[3], BNRPLookupSymbol(tcb, info.fileType, TEMPSYM, GLOBAL)) &&
		   unify(tcb, tcb->args[4], makeint(&tcb->hp, info.DFOpen)) &&
		   unify(tcb, tcb->args[5], makeint(&tcb->hp, info.DSize)) &&
		   unify(tcb, tcb->args[6], makeint(&tcb->hp, info.RFOpen)) &&
		   unify(tcb, tcb->args[7], makeint(&tcb->hp, info.RSize)) &&
		   unify(tcb, tcb->args[8], makeint(&tcb->hp, info.created.year)) &&
		   unify(tcb, tcb->args[9], makeint(&tcb->hp, info.created.month)) &&
		   unify(tcb, tcb->args[10], makeint(&tcb->hp, info.created.day)) &&
		   unify(tcb, tcb->args[11], makeint(&tcb->hp, info.created.hour)) &&
		   unify(tcb, tcb->args[12], makeint(&tcb->hp, info.created.minute)) &&
		   unify(tcb, tcb->args[13], makeint(&tcb->hp, info.created.second)) &&
		   unify(tcb, tcb->args[14], makeint(&tcb->hp, info.created.dayOfWeek)) &&
		   unify(tcb, tcb->args[15], makeint(&tcb->hp, info.modified.year)) &&
		   unify(tcb, tcb->args[16], makeint(&tcb->hp, info.modified.month)) &&
		   unify(tcb, tcb->args[17], makeint(&tcb->hp, info.modified.day)) &&
		   unify(tcb, tcb->args[18], makeint(&tcb->hp, info.modified.hour)) &&
		   unify(tcb, tcb->args[19], makeint(&tcb->hp, info.modified.minute)) &&
		   unify(tcb, tcb->args[20], makeint(&tcb->hp, info.modified.second)) &&
		   unify(tcb, tcb->args[21], makeint(&tcb->hp, info.modified.dayOfWeek)));
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_fullFileName(TCB *tcb)
{
	TAG tag;
	BNRP_term l;
	char resolved[MAXPATHLEN], *last;
	
	if (tcb->numargs EQ 2) {
		if ((tag = checkArg(tcb->args[1], &l)) EQ SYMBOLT) {
			if (exists(nameof(l)) NE 0) return(FALSE);
			if (realpath(nameof(l), resolved) EQ NULL) return(FALSE);
			return(unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, resolved, TEMPSYM, GLOBAL)));
			}
		else if ((tag EQ VART) && (checkArg(tcb->args[2], &l) EQ SYMBOLT)) {
			if (exists(nameof(l)) NE 0) return(FALSE);
			last = strrchr(nameof(l), FS_SEPARATOR);
			if (last EQ NULL) return(FALSE);
			++last;
			return(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, last, TEMPSYM, GLOBAL)));
			}
		}
	return(FALSE);
	}
#endif

#ifdef ring5
BNRP_Boolean BNRP_timeAndDate(TCB *tcb)
{
	struct tm *tm;
	time_t t, tt;
	char ctime[6], cdate[9];
	
	if (tcb->numargs NE 2) return(FALSE);
	t = time(&tt);
	tm = localtime(&tt);
	sprintf(ctime, "%d:%02d", tm->tm_hour, tm->tm_min);
	sprintf(cdate, "%04d %02d %02d", (tm->tm_year+1900), tm->tm_mon+1, tm->tm_mday);
	return(unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, ctime, TEMPSYM, GLOBAL)) &&
		   unify(tcb, tcb->args[2], BNRPLookupSymbol(tcb, cdate, TEMPSYM, GLOBAL)));
	}
#endif

#ifdef ring5
/*
 * time(-EpochTime, -USeconds)
 *   get the system Epoch time (ie, seconds since Jan 1, 1970)
 */
BNRP_Boolean BNRP_time(TCB *tcb)
{
    BNRP_Boolean    retval;
    struct timeval  tv;
    struct timezone tz;

    if ((tcb->numargs NE 1) && (tcb->numargs NE 2)) return FALSE;

#ifdef m88k
    gettimeofday(&tv);
#else
    gettimeofday(&tv, &tz);
#endif

    retval = unify(tcb, tcb->args[1], makeint(&tcb->hp, tv.tv_sec));

    if (tcb->numargs EQ 2)
        retval = retval && unify(tcb, tcb->args[2], makeint(&tcb->hp, tv.tv_usec));

    return retval;
}
#endif

#ifdef ring5
/*
 * localtime(+EpochTime, -Year, -Month, -Day, -Hour, -Min, -Second, -DOW, -DOY)
 *   convert Epoch time to local time
 */
BNRP_Boolean BNRP_localtime(TCB *tcb)
{
    time_t epoch;
    struct tm *ptm;

    if (tcb->numargs NE 9) return FALSE;
    if(checkArg(tcb->args[1],(long *)&epoch) NE INTT) return FALSE;
    
    ptm = localtime(&epoch);

    return (
        unify(tcb, tcb->args[2], makeint(&tcb->hp, (long)ptm->tm_year+1900)) &&
        unify(tcb, tcb->args[3], makeint(&tcb->hp, (long)ptm->tm_mon+1)) &&
        unify(tcb, tcb->args[4], makeint(&tcb->hp, (long)ptm->tm_mday)) &&
        unify(tcb, tcb->args[5], makeint(&tcb->hp, (long)ptm->tm_hour)) &&
        unify(tcb, tcb->args[6], makeint(&tcb->hp, (long)ptm->tm_min)) &&
        unify(tcb, tcb->args[7], makeint(&tcb->hp, (long)ptm->tm_sec)) &&
        unify(tcb, tcb->args[8], makeint(&tcb->hp, (long)ptm->tm_wday)) &&
        unify(tcb, tcb->args[9], makeint(&tcb->hp, (long)ptm->tm_yday+1)));
}
#endif

#ifdef ring5
/*
 * mktime(-EpochTime, +Year, +Month, +Day, +Hour, +Min, +Second)
 *   convert local time to Epoch time.
 */
BNRP_Boolean BNRP_mktime(TCB *tcb)
{
    struct tm tmstruct;
    long      value;
    time_t    epoch;

    if (tcb->numargs NE 7) return FALSE;
    
    if (checkArg(tcb->args[2], &value) NE INTT) return FALSE;
    tmstruct.tm_year = value - 1900;

    if (checkArg(tcb->args[3], &value) NE INTT) return FALSE;
    tmstruct.tm_mon = value-1;

    if (checkArg(tcb->args[4], &value) NE INTT) return FALSE;
    tmstruct.tm_mday = value;

    if (checkArg(tcb->args[5], &value) NE INTT) return FALSE;
    tmstruct.tm_hour = value;

    if (checkArg(tcb->args[6], &value) NE INTT) return FALSE;
    tmstruct.tm_min = value;

    if (checkArg(tcb->args[7], &value) NE INTT) return FALSE;
    tmstruct.tm_sec = value;

    tmstruct.tm_isdst = -1;                     /* to be auto-detected */

    errno = 0;
    epoch = mktime(&tmstruct);
    if (errno && (epoch EQ (time_t)-1)
#ifdef EINTR
        && (errno NE EINTR)
#endif
        ) return FALSE;                         /* failed              */


    return unify(tcb, tcb->args[1], makeint(&tcb->hp, (long)epoch));
}
#endif

#ifdef ring5
/*
 * gmtime(-Year, -Month, -Day, -Hour, -Min, -Sec, -DayOfWeek, -DayOfYear)
 * gmtime(-Year, -Month, -Day, -Hour, -Min, -Sec, -DayOfWeek, -DayOfYear, +EpochTime)
*/
BNRP_Boolean BNRP_gmtime(TCB *tcb)
{
   struct tm* stdtime;
   time_t seconds;

   if (tcb->numargs EQ 8)
   {
      /* Get current GMT time */
      seconds = time(0);
      stdtime = gmtime(&seconds);
   }
   else if (tcb->numargs EQ 9)
   {
      /* Get GMT from seconds since Epoch */
      if (checkArg(tcb->args[9], (long *)&seconds) NE INTT) return FALSE;
      
      stdtime = gmtime(&seconds);
   }
   else
   {
      return FALSE;
   }

   return (
      unify(tcb, tcb->args[1], makeint(&tcb->hp, (long)stdtime->tm_year+1900)) &&
      unify(tcb, tcb->args[2], makeint(&tcb->hp, (long)stdtime->tm_mon+1)) &&
      unify(tcb, tcb->args[3], makeint(&tcb->hp, (long)stdtime->tm_mday)) &&
      unify(tcb, tcb->args[4], makeint(&tcb->hp, (long)stdtime->tm_hour)) &&
      unify(tcb, tcb->args[5], makeint(&tcb->hp, (long)stdtime->tm_min)) &&
      unify(tcb, tcb->args[6], makeint(&tcb->hp, (long)stdtime->tm_sec)) &&
      unify(tcb, tcb->args[7], makeint(&tcb->hp, (long)stdtime->tm_wday)) &&
      unify(tcb, tcb->args[8], makeint(&tcb->hp, (long)stdtime->tm_yday+1)));
}
#endif

#ifdef ring5
/*
 * random and randomseed
 */
BNRP_Boolean BNRP_random(TCB *tcb)
{
    if (tcb->numargs NE 1) return FALSE;
    return unify(tcb, tcb->args[1], makeint(&tcb->hp, lrand48()));
}

BNRP_Boolean BNRP_randomseed(TCB *tcb)
{
    long seed;

    if (tcb->numargs NE 1) return FALSE;
    if (checkArg(tcb->args[1], &seed) NE INTT) return FALSE;
    
    srand48(seed);
    return TRUE;
}
#endif

#ifdef ring4
static BNRP_Boolean listdirfiles(TCB *tcb, BNRP_Boolean directory)
{
	BNRP_result name;
	BNRP_term list;
	BNRP_dirEntry *dir;

	if (tcb->numargs NE 2) return(FALSE);
	
	/* Pick up directory name */
	if (BNRP_getValue(tcb->args[1],&name) NE BNRP_symbol) return(FALSE);
	
#ifdef DEBUG
	printf("In listdirectories/files(%s).\n",name.sym.sval);
#endif
   
	/* check the directory name is valid, then open the directory */
	if (BNRP_opendir(name.sym.sval)) {
		/* Generate the list of directories/files. */
		list = BNRP_startList((BNRP_TCB *)tcb);
		/* for each entry in the directory .. */
		while ((dir = BNRP_readdir()) NE NULL)
			if (dir->isDir EQ directory) 
				BNRP_addTerm((BNRP_TCB *)tcb,
							 list,
							 BNRPLookupSymbol(tcb,dir->name,TEMPSYM, (*dir->name NE '$')));
		/* unify the generated list and return */
		BNRP_closedir();
		return(unify(tcb,tcb->args[2],list));
		}
	else {			/* directory name invalid or can't open */
#ifdef DEBUG
		printf("Directory %s invalid or can't open.\n",name.sym.sval);
#endif
		return FALSE;
		}
	}

/* Prolog primitive: $listfiles(+Dir,-DirList)
    - returns a list of files in the specified directory. */

BNRP_Boolean BNRP_listfiles(TCB *tcb)
{
    return(listdirfiles(tcb,FALSE));
	}


/* Prolog primitive: $listdirectories(+Dir,-DirList)
   - returns a list of directories in the specified directory. */

BNRP_Boolean BNRP_listdirectories(TCB *tcb)
{
    return(listdirfiles(tcb,TRUE));
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_listvolumes(TCB *tcb)
{
	BNRP_term list;
	BNRP_dirEntry *dir;

	if (tcb->numargs NE 1) return(FALSE);
	if (!BNRP_openvols()) return(FALSE);
	/* Generate the list of directories/files. */
	list = BNRP_startList((BNRP_TCB *)tcb);
	/* for each entry in the directory .. */
	while ((dir = BNRP_readvol()) NE NULL)
		BNRP_addTerm((BNRP_TCB *)tcb,
					 list,
					 BNRPLookupSymbol(tcb,dir->name,TEMPSYM, (*dir->name NE '$')));
	/* unify the generated list and return */
	return(unify(tcb,tcb->args[1],list));
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_removeFile(TCB *tcb)
{
	long l;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &l) EQ SYMBOLT)) {
		return(remove(nameof(l)) EQ 0);
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_createDir(TCB *tcb)
{
	long l;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &l) EQ SYMBOLT)) {
		return(mkdir(nameof(l), 0777) EQ 0);
		}
	return(FALSE);
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_removeDir(TCB *tcb)
{
	long l;
	
	if ((tcb->numargs EQ 1) && (checkArg(tcb->args[1], &l) EQ SYMBOLT)) {
		return(rmdir(nameof(l)) EQ 0);
		}
	return(FALSE);
	}
#endif

#ifdef ring4
char **BNRP_argv;
int BNRP_argc = 0;
char BNRP_appdirname[MAXPATHLEN] = "";

void BNRP_findfile(char *name, char *fullname)
{
	FILE *f;
	char *path, *dir, *p, c, *getenv();

	if ((f = fopen(name, "r")) NE NULL) {
		fclose(f);
		realpath(name, fullname);
		return;
		}
	if ((strchr(name, FS_SEPARATOR) EQ NULL) && ((path = getenv("PATH")) NE NULL)) {
		c = 1;
		while (c) {
			dir = fullname;
			while ((c = *dir = *path++) NE ':') {
				if (c EQ 0) break;
				++dir;
				} 
			*dir++ = FS_SEPARATOR;
			p = name;
			while ((*dir++ = *p++)) ;
			if ((f = fopen(fullname, "r")) NE NULL) {
				fclose(f);
				return;
				}
			}
		}
	strcpy(fullname, name);			/* return original parameter */
	}

void BNRP_setupFiles(int argc, char **argv)
{
	char *p;
	
	BNRP_argc = argc;
	BNRP_argv = argv;
	BNRP_findfile(argv[0], BNRP_appdirname);
	p = strrchr(BNRP_appdirname, FS_SEPARATOR);
	if (p EQ NULL) 
		BNRP_appdirname[0] = '\0'; 
	else 
#ifdef Macintosh
		*++p = '\0';		/* need to keep trailing : as part of directory */
#else
		*p = '\0';
#endif
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_getappfiles(TCB *tcb)
{
	BNRP_term list;
	int i;
	char *s;
	
	if (tcb->numargs NE 1) return(FALSE);
	list = BNRP_startList((BNRP_TCB *)tcb);
	/* for each entry in argv .. */
	for (i = 1; i LT BNRP_argc; ++i) {
		s = BNRP_argv[i];
		BNRP_addTerm((BNRP_TCB *)tcb,
					 list,
					 BNRPLookupSymbol(tcb,s,TEMPSYM, (*s NE '$')));
		}
	return(unify(tcb,tcb->args[1],list));
	}
#endif

#ifdef ring4
BNRP_Boolean BNRP_appdir(TCB *tcb)
{
	return((tcb->numargs NE 1) ? FALSE :
		   unify(tcb, tcb->args[1], BNRPLookupSymbol(tcb, BNRP_appdirname, TEMPSYM, GLOBAL)));
	}
#endif

