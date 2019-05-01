/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/fsysprim.h,v 1.4 1997/11/21 14:30:50 harrisj Exp $
*
*  $Log: fsysprim.h,v $
 * Revision 1.4  1997/11/21  14:30:50  harrisj
 * New primitive gmtime added to return GMT
 *
 * Revision 1.3  1996/04/19  01:29:14  yanzhou
 * Added new primitives random/1 and randomseed/1 to BNRProlog ring 5.
 *
 * Revision 1.2  1996/01/31  23:52:24  yanzhou
 * New time/date-related primitives:
 *   time, localtime and mktime.
 *
 * Revision 1.1  1995/09/22  11:24:28  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_fsysprim
#define _H_fsysprim

#include "core.h"

BNRP_Boolean BNRP_systemCall(TCB *tcb);
BNRP_Boolean BNRP_getenv(TCB *tcb);
BNRP_Boolean BNRP_defaultDir(TCB *tcb);
BNRP_Boolean BNRP_isFile(TCB *tcb);
BNRP_Boolean BNRP_fullFileName(TCB *tcb);
BNRP_Boolean BNRP_timeAndDate(TCB *tcb);
BNRP_Boolean BNRP_time(TCB *tcb);
BNRP_Boolean BNRP_localtime(TCB *tcb);
BNRP_Boolean BNRP_mktime(TCB *tcb);
BNRP_Boolean BNRP_gmtime(TCB *tcb);
BNRP_Boolean BNRP_random(TCB *tcb);
BNRP_Boolean BNRP_randomseed(TCB *tcb);
BNRP_Boolean BNRP_listfiles(TCB *tcb);
BNRP_Boolean BNRP_listdirectories(TCB *tcb);
BNRP_Boolean BNRP_listvolumes(TCB *tcb);
BNRP_Boolean BNRP_removeFile(TCB *tcb);
BNRP_Boolean BNRP_createDir(TCB *tcb);
BNRP_Boolean BNRP_removeDir(TCB *tcb);
void BNRP_findfile(char *name, char *fullname);
void BNRP_setupFiles(int argc, char **argv);
BNRP_Boolean BNRP_getappfiles(TCB *tcb);
BNRP_Boolean BNRP_appdir(TCB *tcb);

#endif
