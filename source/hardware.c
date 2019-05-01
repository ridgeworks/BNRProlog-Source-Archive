/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/hardware.c,v 1.6 1997/05/12 13:27:01 harrisj Exp $
*
*  $Log: hardware.c,v $
 * Revision 1.6  1997/05/12  13:27:01  harrisj
 * Modified date using functions to output year using 4 digits
 * instead of 2
 *
 * Revision 1.5  1997/02/27  17:18:52  harrisj
 * HPUX 10.10 has the getwd() and realpath() functions.
 *
 * Revision 1.4  1995/12/12  18:14:24  yanzhou
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
 * Revision 1.5  1995/12/12  17:53:44  yanzhou
 * SA_RESTARTSYSCALL was not set properly in BNRP_initSighandler().
 * Now fixed.
 *
 * Revision 1.4  1995/12/12  14:21:42  yanzhou
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
 * Revision 1.3  1995/12/04  00:10:14  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.2  1995/11/13  11:34:19  yanzhou
 * Now uses `sigaction' on SunOS (sunBSD).  Was using `segvect'.
 *
 * Revision 1.1  1995/09/22  11:24:30  harrisja
 * Initial version.
 *
*
*/
/*************************************************************************

	This file supports the machine dependent parts of the interpreter.
	Currently the following variables and routines are implemented:
	
		long BNRP_getMaxLong
			- the maximum long int.
			
		fp BNRP_getMaxFP
			- the maximum floating point number for the type fp.
			  
		short BNRP_getFPPrecision
			- the estimated precsion of a fp.
			
		void getUserTime(long *current, BNRP_Boolean delay, float *adjustment)
			- returns the current user time in ms. If delay is TRUE
			  then current the time in ms at the next clock tick, and
			  adjustment is the estimated time since the routine was
			  called.
			  
*************************************************************************/

#include "BNRProlog.h"
#include "base.h"
#include "hardware.h"
#include <stdio.h>
#include <string.h>
#include <limits.h>			/* for LONG_MAX */
#if defined(unix)
#ifndef hpux_10				/* Not required for HPUX 10.10 */
#include <values.h>			/* for MAXDOUBLE (DBL_MAX) */
#endif
#include <sys/types.h>		/* for times, stat */
#include <sys/param.h>		/* for times, getwd */
#include <sys/stat.h>		/* for stat */
#include <unistd.h>			/* for access */
#include <sys/file.h>		/* for F_OK, not always in unistd.h */
#if defined(mdelta) || defined(_AIX)
#include <time.h>
#else
#include <sys/time.h>		/* for getrusage, gettimeofday, setitimer */
#endif
#include <dirent.h>			/* for opendir, readdir */
#include <signal.h>			/* for signal, SIGALRM */
#include <math.h>			/* for modf() */
#include <errno.h>			/* for errno */
#include <sys/errno.h>		/* for errno codes */
#if defined(hpux) || defined(AUX) || defined(solaris) || defined(mdelta) || defined(nav) || defined(_AIX)
#include <sys/times.h>		/* for times */
#else
#include <sys/resource.h>	/* for getrusage */
#endif
#endif

#ifdef Macintosh
#include <float.h>			/* for DBL_MAX */
#include <time.h>			/* for cputime */
#include <files.h>			/* for FSMakeFSSpec() */
#include <aliases.h>		/* for ResolveAliasFile() */
#endif
#ifdef __mpw
#include <OSUtils.h>
#include <IOCtl.h>
#include <memory.h>			/* for StripAddress */
#include <resources.h>
#include <files.h>
#endif


long BNRPMaxLong = LONG_MAX;
#ifdef THINK_C
#include <SANE.H>
short BNRPFPPrecision = 15;		/* uses 18 since double == long double */
#else
#ifdef __MWERKS__
short BNRPFPPrecision = 15;		/* won't compile DBL_DIG */
#else
short BNRPFPPrecision = DBL_DIG;
#endif
#endif

fp BNRP_getMaxFP()
{
#ifdef THINK_C
	long double maxfp = DBL_MAX, negmaxfp = -DBL_MAX;
	extended _maxfp, _negmaxfp;
	x96tox80(&maxfp, &_maxfp);
	x96tox80(&negmaxfp, &_negmaxfp);
	_maxfp = nextdouble(_maxfp, _negmaxfp);
	x80tox96(&_maxfp, &maxfp);
	return(maxfp);
#else
	return(DBL_MAX);
#endif
	}

/* intercept arithmetic errors if we can, simply set errno */
/* and return a non-zero result to avoid default handler   */
long BNRP_handleIntervalErrors = 0;

#ifdef unix
#ifndef sgi

int matherr(struct exception *x)
{
	if (BNRP_handleIntervalErrors) {
		/* we only use exp, log, sqrt, sin, cos, tan, asin, acos, atan */
		switch (x->type) {
			case DOMAIN:
						break;
			case SING:
						break;
			case OVERFLOW:
						/* should only be exp */
						errno = 0;
						x->retval = DBL_MAX;
						return(1);
			case UNDERFLOW:
						errno = 0;
						x->retval = 0.0;
						return(1);
#if defined(hpux)
			case TLOSS:
						errno = 0;
						x->retval = 0.0;
						return(1);
			case PLOSS:
						/* let default handler take care of it */
						return(0);
#endif
			}
		}
	errno = ((x->type EQ DOMAIN) || (x->type EQ SING)) ? EDOM : ERANGE;
	x->retval = 0.0;
	return(1);
	}
#endif
#endif

unsigned long BNRP_getUserTime(BNRP_Boolean delay, fp *adjustment)
{
#if defined(hpux) || defined(AUX) || defined(solaris) || defined(mdelta) || defined(nav) || defined(_AIX)
	struct tms t;
	
	times(&t);
	*adjustment = 0.0;
	return((1000.0/HZ)*t.tms_utime);
#else
#if defined(sunBSD) || defined(sgi)
	struct rusage t;

	getrusage(RUSAGE_SELF, &t);
	*adjustment = 0.0;
	return((t.ru_utime.tv_sec * 1000) + (t.ru_utime.tv_usec / 1000.0));
#else
#ifdef Macintosh
	clock_t startTime, t;
	long remaining = 0, maxRemaining = 0;
	double f;
	
	startTime = clock();
	if (delay) {
		while(startTime EQ (t = clock())) ++remaining;
		/* calibrate the clock so we can see exactly what portion of a tick expired */
		while (t == clock()) ++maxRemaining;
		if (maxRemaining < remaining) maxRemaining = remaining;
		f = maxRemaining;
		f = (f - remaining) / f;
		t = clock();
		/* f is the time when called to next tick in terms of a tick. */
		/* adjustment needs the value in ms from when called to the clock */
		/* value returned.  I assume that the value returned will be t + 1 */
		/* so that the adjustment is f + (t + 1) - (startTime + 1) */
		*adjustment = ((t - startTime) + f) * (1000.0 / CLOCKS_PER_SEC);
		/* wait for the next tick to start */
		while (t == (startTime = clock()));
		}
	else
		*adjustment = 0.0;
	return((1000.0 / CLOCKS_PER_SEC) * startTime);
#else
	*adjustment = 0.0;
	return(0);
#endif
#endif
#endif
	}

unsigned long BNRP_getElapsedTime(void)
{
#ifdef Macintosh
	return((1000.0 / CLOCKS_PER_SEC) * clock());
#else
	struct timeval tp;
#ifdef nav
	if (gettimeofday(&tp) EQ -1) return(0);
#else
	struct timezone tzp;
	if (gettimeofday(&tp, &tzp) EQ -1) return(0);
#endif
	return(tp.tv_sec * 1000 + tp.tv_usec / 1000);
#endif
	}

	
BNRP_Boolean BNRP_truncateFile(FILE *f, long len)
{
#if defined(mdelta)	/* No truncate function available */
	return(FALSE);
#else
#ifdef unix
	return(ftruncate(fileno(f), len) EQ 0);
#else
#ifdef __mpw
	return(ioctl(fileno(f), FIOSETEOF, (long *)len) EQ 0);
#else
#ifdef THINK_C
	return(SetEOF(f->refnum, len) EQ noErr);
#else
	return(FALSE);
#endif
#endif
#endif
#endif
	}
	
BNRP_Boolean BNRP_setConfig(char *s)
{
#ifdef THINK_C
	Handle h;
	
	if ((h = GetResource('CONF', 400)) NE NULL) RmveResource(h);
	h = NewHandle(strlen(s)+1);
	if (h EQ NULL) return(FALSE);
	strcpy((char *)(*h), s);
	AddResource(h, 'CONF', 400, "\pBNRProlog 4.0 Configuration");
	if (ResError() NE noErr) 
		{ DisposHandle(h); return(FALSE); }
	WriteResource(h);
	if (ResError() NE noErr) 
		{ DisposHandle(h); return(FALSE); }
	ReleaseResource(h);
	return(ResError() EQ noErr);
#else
	FILE *f;
	char *home, *getenv(), fullname[MAXPATHLEN];
#ifdef __mpw
	char *file = "bnrprolog.config";	/* file names can't begin with . on mac */
#else
	char *file = ".bnrprologrc";
#endif
	
	if ((home = getenv("HOME")) NE NULL) {
		strcpy(fullname, home);
		strcat(fullname, "/");
		strcat(fullname, file);
		file = fullname;
		}
	if ((f = fopen(file, "w")) EQ NULL) return(FALSE);
	fputs(s, f);
	fclose(f);
	return(TRUE);
#endif
	}

char *BNRP_getConfig()
{
	static char fullname[MAXPATHLEN];
#ifdef THINK_C
	Handle h;
	
	h = GetResource('CONF', 400);
	if (h EQ NULL) return(NULL);
	strcpy(fullname, (char *)(*h));
#else
	FILE *f;
	char *home, *getenv();
#ifdef __mpw
	char *file = "bnrprolog.config";
#else
	char *file = ".bnrprologrc";
#endif
	
	if ((home = getenv("HOME")) NE NULL) {
		strcpy(fullname, home);
		strcat(fullname, "/");
		strcat(fullname, file);
		file = fullname;
		}
	if ((f = fopen(file, "r")) EQ NULL) return(NULL);
	fgets(fullname, MAXPATHLEN-10, f);
	fclose(f);
#endif
	return(fullname);
	}

/* mimic getwd and chdir on systems that don't have them.				*/
/* getwd fills a buffer with the current pathname, which must be at		*/
/*       least MAXPATHLEN chars big.  It returns NULL if unsuccessful.	*/
/* chdir sets the current working directory to path specified.			*/
/*       It returns 0 if successful, non zero otherwise.				*/
#ifdef Macintosh

/* these routines from Apple Technote #238: "Getting a Full Pathname" */
/** pStrcat / pStrCpy *********************************************************/
/*
/*    A couple of utility routines. C is thoughtless enough to not really 
/*    support P-strings. In order to perform string copies and concatenations,
/*    these routines are provided.
/*
/******************************************************************************/

#define MIN(a,b) (((a)<(b))?(a):(b))

unsigned char *pStrcat(unsigned char *dest, unsigned char *src)
{
    long sLen = MIN(*src, 255 - *dest);
    BlockMove(src + 1, dest + *dest + 1, sLen);
    *dest += sLen;
    return (dest);
	}

unsigned char *pStrcpy(unsigned char *dest, unsigned char *src)
{
    BlockMove(src, dest, (long) *src + 1); 
    return (dest);
	}

char *PathNameFromDirID(long DirID, short vRefNum, char *s)
{
    CInfoPBRec block;
    Str255 directoryName;
	OSErr err;

    *s = 0;
    block.dirInfo.ioNamePtr = directoryName;
    block.dirInfo.ioDrParID = DirID;

    do {
        block.dirInfo.ioVRefNum = vRefNum;
        block.dirInfo.ioFDirIndex = -1;
        block.dirInfo.ioDrDirID = block.dirInfo.ioDrParID;
            if (PBGetCatInfo(&block,false) NE noErr) return(NULL);
        err = PBGetCatInfo(&block,false);
		/* Append a Macintosh style colon (':') */
		pStrcat(directoryName,"\p:");
        pStrcat(directoryName,(unsigned char *)s);
        pStrcpy((unsigned char *)s,directoryName);
    	} while (block.dirInfo.ioDrDirID != fsRtDirID);

    return(s);
	}


char *PathNameFromWD(long vRefNum, char *s)
{
    WDPBRec myBlock;

    myBlock.ioNamePtr = nil;
    myBlock.ioVRefNum = vRefNum;
    myBlock.ioWDIndex = 0;
    myBlock.ioWDProcID = 0;

    /* Change the Working Directory number in vRefnum into a real vRefnum */
    /* and DirID. The real vRefnum is returned in ioVRefnum, and the real */
    /* DirID is returned in ioWDDirID. */

    PBGetWDInfo(&myBlock,false);

    return(PathNameFromDirID(myBlock.ioWDDirID,myBlock.ioWDVRefNum,s));
	}

char *getwd(char *buff)
{
	Str255 s;
	
	if (PathNameFromDirID(0, 0, (char *)s) NE NULL) {
		s[*s+1] = '\0';		/* put 0 at end */
		strcpy(buff, (char *)&s[1]);
		return(buff);
		}
	return(NULL);
	}

int chdir(char *path)
{
#pragma unused(path)
	return(-1);
	}
#endif

/* mimic realpath on systems that don't have them.							*/
/* realpath takes a partial path and returns a full path to the same file.	*/
/* For simplicity, we just prepend wd to names not beginning with /			*/
#if defined(Macintosh)
char *realpath(char *path, char *resolvedpath)
{
	int len, dirlen;
	char *p, *q;
	
	len = strlen(path);
	q = strchr(path, ':');
	if ((q NE NULL) && (q NE path)) {
		/* contains a : that's not at the beginning, therefore must be a full path already */
		if (len GE MAXPATHLEN) return(NULL);
		strcpy(resolvedpath, path);
		}
	else if (getwd(resolvedpath) EQ NULL) {
		/* no working directory */
		if (len GE MAXPATHLEN) return(NULL);
		strcpy(resolvedpath, path);
		}
	else {
		dirlen = strlen(resolvedpath);
		if (len + dirlen GE MAXPATHLEN) return(NULL);
		if (resolvedpath[dirlen-1] NE ':') {
			if (*path NE ':') strcat(resolvedpath, ":");
			}
		else 
			if (*path EQ ':') resolvedpath[dirlen-1] = '\0';
		strcat(resolvedpath, path);
		}
	/* resolved path now has full pathname, remove :: if possible */
startOver:
	p = resolvedpath;
	while (*p EQ ':') ++p;
	p = strchr(&p[1], ':');
	while (p NE NULL) {
		if (p[1] EQ ':') {			/* have :: */
			*p = '\0';
			q = strrchr(resolvedpath, ':');
			if (q EQ NULL)
				*p = ':';
			else {
				++p;
				while (*q++ = *p++) ;
				goto startOver;
				}
			}
		p = strchr(&p[1], ':');
		}
	return(resolvedpath);
	}
#endif
#if (defined(hpux) && !defined(hpux_10)) || defined(AUX) || defined(ultrix) || defined(mdelta) || defined(sgi)
char *realpath(char *path, char *resolvedpath)
{
	int len, dirlen;
	char *p, *q, *r;
	
	len = strlen(path);
	if (*path EQ '/') {
		if (len GE MAXPATHLEN) return(NULL);
		strcpy(resolvedpath, path);
		return(resolvedpath);
		}
	if (getwd(resolvedpath) EQ NULL) {		/* no working directory */
		strcpy(resolvedpath, path);
		return(resolvedpath);
		}
	dirlen = strlen(resolvedpath);
	if (len + dirlen + 1 GE MAXPATHLEN) return(NULL);
	if (resolvedpath[dirlen-1] NE '/') strcat(resolvedpath, "/");
	strcat(resolvedpath, path);
	/* find first '/' */
	p = strchr(resolvedpath, '/');
	while ((p NE NULL) && ((q = strchr(&p[1], '/')) NE NULL)) {
		len = (int)(q - p);
		if ((len EQ 2) && (strncmp(p, "/.", 2) EQ 0)) {
			/* found /./, so just remove /. */
			strcpy(p, q);
			}
		else if ((len EQ 3) && (strncmp(p, "/..", 3) EQ 0)) {
			/* found /../, so remove it and directory before */
			*p = '\0';
			if ((r = strrchr(resolvedpath, '/')) NE NULL)
				strcpy(r, q);
			else
				strcpy(resolvedpath, q);
			p = strchr(resolvedpath, '/');
			}
		else
			p = q;
		}
	return(resolvedpath);
	}
#endif

int exists(char *filename)
{
#ifdef unix
	return(access(filename, F_OK));
#else
	FILE *f;
	
	if ((f = fopen(filename, "r")) EQ NULL) return(-1);
	fclose(f);
	return(0);
#endif
	}

int getFileInfo(char *path, fileInfo *info)
{
#ifdef Macintosh
	int len;
	OSErr FSError;
	ParamBlockRec p;
	Str255 name;
	DateTimeRec d;
	
	len = strlen(path);
	if (len GT sizeof(Str255)-1) return(-1);
	sprintf((char *)name, "%c%s", len, path);
	p.fileParam.ioNamePtr = name;
	p.fileParam.ioVRefNum = 0;
	p.fileParam.ioFVersNum = 0;
	p.fileParam.ioFDirIndex = 0;
	FSError = PBGetFInfo(&p, FALSE); 
	if (FSError NE noErr) return(FSError); 
	
	strcpy(info->fileCreator, "xxxx");
	memcpy(info->fileCreator, &p.fileParam.ioFlFndrInfo.fdCreator, 4);
	strcpy(info->fileType, "xxxx");
	memcpy(info->fileType, &p.fileParam.ioFlFndrInfo.fdType, 4);
	info->DFOpen = p.fileParam.ioFlAttrib & 0x08;
	info->DSize = p.fileParam.ioFlLgLen;
	info->RFOpen = p.fileParam.ioFlAttrib & 0x04;
	info->RSize = p.fileParam.ioFlRLgLen;
	Secs2Date(p.fileParam.ioFlCrDat, &d);
	info->created.year = d.year-1900;
	info->created.month = d.month;
	info->created.day = d.day;
	info->created.hour = d.hour;
	info->created.minute = d.minute;
	info->created.second = d.second;
	info->created.dayOfWeek = d.dayOfWeek;
	Secs2Date(p.fileParam.ioFlMdDat, &d);
	info->modified.year = d.year-1900;
	info->modified.month = d.month;
	info->modified.day = d.day;
	info->modified.hour = d.hour;
	info->modified.minute = d.minute;
	info->modified.second = d.second;
	info->modified.dayOfWeek = d.dayOfWeek;
	return(0);
#else
	struct stat buf;
	struct tm *timer;
	
	if (stat(path, &buf) NE 0) return(-1);
	if (S_ISDIR(buf.st_mode)) return(-1);		/* skip directories */
	strcpy(info->fileCreator, "unix");
	strcpy(info->fileType, "unix");
	info->DFOpen = FALSE;
	info->DSize = buf.st_size;
	info->RFOpen = FALSE;
	info->RSize = 0;
	timer = localtime(&buf.st_ctime);
	info->created.year = 1900+timer->tm_year;
	info->created.month = timer->tm_mon;
	info->created.day = timer->tm_mday;
	info->created.hour = timer->tm_hour;
	info->created.minute = timer->tm_min;
	info->created.second = timer->tm_sec;
	info->created.dayOfWeek = timer->tm_wday;
	timer = localtime(&buf.st_mtime);
	info->modified.year = 1900+timer->tm_year;
	info->modified.month = timer->tm_mon;
	info->modified.day = timer->tm_mday;
	info->modified.hour = timer->tm_hour;
	info->modified.minute = timer->tm_min;
	info->modified.second = timer->tm_sec;
	info->modified.dayOfWeek = timer->tm_wday;
	return(0);
#endif
	}

#ifdef Macintosh
#else
char BNRP_currentOpenDir[MAXPATHLEN];
DIR *BNRP_dp;
BNRP_Boolean BNRP_volFirstCall = FALSE;
#endif

BNRP_Boolean BNRP_opendir(char *name)
{
#ifdef Macintosh
#pragma unused(name)
	return(FALSE);
#else
	struct stat sbuf;

	strcpy(BNRP_currentOpenDir, name); 
	return((stat(name, &sbuf) EQ 0) && 
		   ((sbuf.st_mode & S_IFMT) EQ S_IFDIR) &&
		   ((BNRP_dp = opendir(name)) NE NULL));
#endif
	}

void BNRP_closedir(void)
{
#ifdef Macintosh
	return;
#else
	(void)closedir(BNRP_dp);
	BNRP_dp = NULL;
	BNRP_currentOpenDir[0] = '\0';
#endif
	}

BNRP_dirEntry *BNRP_readdir(void)
{
#ifdef Macintosh
	return(NULL);
#else
	size_t len; 
	static struct dirent *dir;
	static BNRP_dirEntry d;
	char newname[MAXPATHLEN];
	struct stat sbuf;

	len = strlen(BNRP_currentOpenDir);
	while (TRUE) {
		if ((dir = readdir(BNRP_dp)) EQ NULL) return(NULL);
		/* skip removed files */
		if (dir->d_ino EQ 0) continue;
		d.name = dir->d_name;
		BNRP_currentOpenDir[len] = '/';
		BNRP_currentOpenDir[len+1] = '\0';
		strcat(BNRP_currentOpenDir, dir->d_name);
		stat(BNRP_currentOpenDir,&sbuf);
		BNRP_currentOpenDir[len] = '\0';
		/* ??? Why does this get symbolic links as well as dirs??? */
		d.isDir = ((sbuf.st_mode & S_IFMT) == S_IFDIR);
		return(&d);
		}
#endif
	}

BNRP_Boolean BNRP_openvols(void)
{
#ifdef Macintosh
	return(FALSE);
#else
	BNRP_volFirstCall = TRUE;
	return(TRUE);
#endif
	}

BNRP_dirEntry *BNRP_readvol(void)
{
#ifdef Macintosh
	return(NULL);
#else
	static BNRP_dirEntry d;
	static char name[2] = "/";

	if (!BNRP_volFirstCall) return(NULL);
	d.isDir = TRUE;
	d.name = name;
	BNRP_volFirstCall = FALSE;
	return(&d);
#endif
	}

#ifdef Macintosh
void *BNRP_malloc(unsigned long size)
{
	Handle orig;
	Ptr adjusted;
	
	size += headerAlignment;
	ResrvMem(size);				/* near bottom of heap */
	if ((orig = NewHandle(size)) EQ NULL) return(NULL);
	HLock(orig);
	adjusted = (Ptr)StripAddress(*orig);
	headerLWA(adjusted);
	return((void *)adjusted);
	}
#endif

#ifdef Macintosh
void *BNRP_realloc(void *p, unsigned long size)
{
	Handle h;
	Ptr adjusted;
	long diff;
	Size origsize;
	
	h = RecoverHandle((Ptr)p);
	adjusted = (Ptr)StripAddress(*h);
	diff = (long)adjusted - (long)p;
	origsize = GetHandleSize(h);
	HUnlock(h);
	SetHandleSize(h, size + headerAlignment);
	if (MemError() EQ noErr) {
		HLock(h);
		adjusted = (Ptr)StripAddress(*h);
		headerLWA(adjusted);
		if (diff NE ((long)adjusted - (long)(*h)))
			BlockMove((void *)((long)(*h) + diff), (void *)adjusted, origsize);
		}
	else {		/* SetHandleSize failed, so allocate new block */
		if ((adjusted = BNRP_malloc(size)) EQ NULL) {
			DisposHandle(h);
			return(NULL);
			}
		BlockMove((void *)*h, (void *)adjusted, origsize);
		DisposHandle(h);
		}
	return((void *)adjusted);
	}
#endif

#ifdef Macintosh
void BNRP_free(void *p)
{
	Handle h = RecoverHandle((Ptr)p);
	DisposHandle(h);
	}
#endif

#ifdef Macintosh
int BNRP_mkdir(char *path)
{
#pragma unused(path)
	return(-1);
	}

int BNRP_rmdir(char *path)
{
#pragma unused(path)
	return(-1);
	}
#endif

void (*BNRP_timerFunc)() = NULL;

#ifdef unix

/****************************************************************/
/*                    SIGNAL HANDLING                           */
/****************************************************************/

BNRP_sighandler BNRP_initSighandler(void (* handler)(int))
{
    BNRP_sighandler sh;

#ifdef USE_SIGACTION
    sigemptyset(&sh.sa_mask);                   /* empty mask */
    sh.sa_flags   = 0;                          /* flags      */
#   ifdef SA_RESTARTSYSCALL
    sh.sa_flags  |= SA_RESTARTSYSCALL;          /* restart syscall */
#   endif
    sh.sa_handler = handler;                    /* handler    */
    return sh;
#endif

#ifdef USE_SIGSET
    return handler;
#endif

#ifdef USE_SIGVECTOR
    sh.sv_handler = handler;
    sh.sv_mask    = 0;
    sh.sv_flags   = 0;
    return sh;
#endif
}

BNRP_sighandler BNRP_installSighandler(int signo, BNRP_sighandler handler)
{
    BNRP_sighandler oldHandler;

#ifdef USE_SIGACTION
    sigaction(signo, &handler, &oldHandler);
#endif
#ifdef USE_SIGSET
    oldHandler = sigset(signo, handler);
#endif
#ifdef USE_SIGVECTOR
    sigvector(signo, &handler, &oldHandler);
#endif

    return oldHandler;
}

void BNRP_callSighandler(BNRP_sighandler handler, int signo)
{
    void (*func)(int);

#ifdef USE_SIGACTION
    func = handler.sa_handler;
#endif
#ifdef USE_SIGSET
    func = handler;
#endif
#ifdef USE_SIGVECTOR
    func = handler.sv_handler;
#endif

    /* can we call the handler directly? */
    if (func &&
        (func NE SIG_DFL) &&
        (func NE SIG_IGN) &&
        (func NE SIG_HOLD) )
    {
        (*func)(signo);
    }
}

/*
 * compares 2 signal handlers, returns 0 if they are the same, 1 otherwise
 */
int BNRP_compareSighandler(BNRP_sighandler handler1, BNRP_sighandler handler2)
{
#ifdef USE_SIGACTION
    return (handler1.sa_handler NE handler2.sa_handler);
#endif
#ifdef USE_SIGSET
    return ( handler1 NE handler2);
#endif
#ifdef USE_SIGVECTOR
    return ( handler1.sv_handler NE handler2.sv_handler);
#endif
}

void BNRP_blockSignal(int signo)
{
#ifdef USE_SIGACTION
    sigset_t newset;
    sigset_t oldset;

    sigemptyset(&newset);
    sigaddset(&newset, signo);
    sigprocmask(SIG_BLOCK, &newset, &oldset);
#endif

#ifdef USE_SIGSET
    sighold(signo);
#endif

#ifdef USE_SIGVECTOR
    sigblock(sigmask(signo));
#endif
}

void BNRP_unblockSignal(int signo)
{
#ifdef USE_SIGACTION
    sigset_t newset;
    sigset_t oldset;

    sigemptyset(&newset);
    sigaddset(&newset, signo);
    sigprocmask(SIG_UNBLOCK, &newset, &oldset);
#endif

#ifdef USE_SIGSET
    sigrelse(signo);
#endif

#ifdef USE_SIGVECTOR
    long currmask = sigblock(0);                /* query */
    currmask &= ~sigmask(signo);
    sigsetmask(currmask);
#endif
}

void BNRP_waitforSignal(int signo)
{
#ifdef USE_SIGACTION
    sigset_t emptyset;
    sigset_t currset;

    sigemptyset(&emptyset);
    sigprocmask(SIG_BLOCK, &emptyset, &currset); /* query */

    sigdelset(&currset, signo);
    sigsuspend(&currset);
#endif

#ifdef USE_SIGSET
    sigpause(signo);
#endif

#ifdef USE_SIGVECTOR
    long currmask = sigblock(0);                /* query */
    currmask &= ~sigmask(signo);
    sigpause(currmask);
#endif
}


static void tickHandler(int signo)
{
	if (BNRP_timerFunc) {
        (*BNRP_timerFunc)();    /* call out to indicate a tick */
    }
}

/* New from Oz 04/95 */
void BNRP_setTimer(fp *time, void (*func)())
{
    static BNRP_sighandler oldAlarmHandler;
    static int             oldAlarmHandlerInvalid = 1;
    BNRP_sighandler        oldHandler;
    BNRP_sighandler        tickAlarmHandler;

    double secs, usec;
    struct itimerval rttimer, old_rttimer;
	
    BNRP_timerFunc = func;
    usec = modf(*time, &secs);
    rttimer.it_value.tv_sec = rttimer.it_interval.tv_sec = (long)secs;
    rttimer.it_value.tv_usec = rttimer.it_interval.tv_usec = (long)(usec * 1000000.0);
    /* establish our handler */
    if (*time NE 0.0) {/* NEW Save old handler only if it isn't tickHandler */
        tickAlarmHandler = BNRP_initSighandler(tickHandler);
        oldHandler = BNRP_installSighandler(SIGALRM, tickAlarmHandler);
        if (BNRP_compareSighandler(oldHandler, tickAlarmHandler)) {
            /* the sighandlers are different, so save the old one */
            oldAlarmHandler = oldHandler;
            oldAlarmHandlerInvalid = 0;
        }
    }
    setitimer(ITIMER_REAL, &rttimer, &old_rttimer);
    getitimer(ITIMER_REAL, &old_rttimer);
    if(*time EQ 0.0) { /* NEW Done with it, so re-establish old handler */
        if (! oldAlarmHandlerInvalid)
            BNRP_installSighandler(SIGALRM, oldAlarmHandler);
    }
    *time = (fp)rttimer.it_value.tv_sec + (rttimer.it_value.tv_usec / 1000000.0);
}

static int BNRP_gotAlarm;

static void alarmHandler(int sig)
{
	BNRP_gotAlarm = 1;
}
	
void BNRP_sleep(fp time, int ignoreTicks)
{
	double secs, usec;
	struct itimerval rttimer, old_rttimer;
    BNRP_sighandler sigAlarmHandler;
    BNRP_sighandler oldAlarmHandler;

	/* stop the current timer and gets it's current value */
	timerclear(&rttimer.it_value);
	timerclear(&rttimer.it_interval);
	setitimer(ITIMER_REAL, &rttimer, &old_rttimer);
	
	/* block the signal, and get old handler */
    sigAlarmHandler = BNRP_initSighandler(alarmHandler);
    BNRP_blockSignal(SIGALRM);
    oldAlarmHandler = BNRP_installSighandler(SIGALRM, sigAlarmHandler);

	/* compute the time we need in seconds and microseconds, no repeat */
	usec = modf(time, &secs);
	rttimer.it_value.tv_sec = (long)secs;
	rttimer.it_value.tv_usec = (long)(usec * 1000000.0);
	rttimer.it_interval.tv_sec = 0;
	rttimer.it_interval.tv_usec = 0;
	
	if (timercmp(&rttimer.it_value, &old_rttimer.it_value, LT)) {
		/* our timer is less than the time remaining, 
		   so adjust old to reflect the time past when it is reset later */
		old_rttimer.it_value.tv_sec -= rttimer.it_value.tv_sec;
		old_rttimer.it_value.tv_usec -= rttimer.it_value.tv_usec;
		if (old_rttimer.it_value.tv_usec LT 0) {
			old_rttimer.it_value.tv_usec += 1000000;
			old_rttimer.it_value.tv_sec -= 1;
			}
		}
	else if (timerisset(&old_rttimer.it_value)) {
		/* a tick will occur, so do action now */
        BNRP_callSighandler(oldAlarmHandler, SIGALRM);
		/* since oldhandler may change handler, so reset it */
		BNRP_installSighandler(SIGALRM,sigAlarmHandler);
		if (ignoreTicks EQ 0) {
			/* we can't wait past tick time, so just go until tick time */
			rttimer.it_value.tv_sec = old_rttimer.it_interval.tv_sec;
			rttimer.it_value.tv_usec = old_rttimer.it_interval.tv_usec;
			}
		/* reset tick timer to start a new cycle when reenabled */
		old_rttimer.it_value.tv_sec = old_rttimer.it_interval.tv_sec;
		old_rttimer.it_value.tv_usec = old_rttimer.it_interval.tv_usec;
		}
	/* else old_rttimer not set, so we simply reset it to 0 later */

	BNRP_gotAlarm = 0;
	
	/* start the timer */
	setitimer(ITIMER_REAL, &rttimer, (struct itimerval *)0);
	
	/* pause until it goes off */
    while (!BNRP_gotAlarm) {
        BNRP_waitforSignal(SIGALRM);
    }

	/* reset the handler, timer, and allowable signals */
	BNRP_installSighandler(SIGALRM, oldAlarmHandler);
	setitimer(ITIMER_REAL, &old_rttimer, (struct itimerval *)0);
    BNRP_unblockSignal(SIGALRM);
}

#else
void BNRP_setTimer(fp *time, void (*func)())
{
	BNRP_timerFunc = func;
	*time = 0.0;
	}

void BNRP_sleep(fp time, int ignoreTicks)
{
#pragma unused(ignoreTicks)
	clock_t t = clock() + (clock_t)(time * CLOCKS_PER_SEC);
	while (clock() LT t) ;
	}
#endif
