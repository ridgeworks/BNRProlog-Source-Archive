/*
 * $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/xwollongong.c,v 1.2 1995/11/09 13:28:52 yanzhou Exp $
 *
 * $Log: xwollongong.c,v $
 * Revision 1.2  1995/11/09  13:28:52  yanzhou
 * Unnecessary include files removed.
 *
 * Revision 1.1  1995/11/07  10:44:32  yanzhou
 * New files xwollongong.[hc] created.
 *
 *
 */

#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#else
#include <strings.h>
#endif
#include <memory.h>
#include <signal.h>

#include <X11/Xlib.h>
#include "xwollongong.h"

extern Display *display;

/*
 * X connection number, -1 for error
 *   on POSIX systems, X connection number is a file descriptor
 */
int BNRP_getXConnectionNumber()
{
    if (display)
        return XConnectionNumber(display);
    return -1;
}

/* End */
