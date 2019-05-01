/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/loader.h,v 1.2 1997/08/12 17:35:09 harrisj Exp $
*
*  $Log: loader.h,v $
 * Revision 1.2  1997/08/12  17:35:09  harrisj
 * External interface now uses const char*
 * instead of char *
 *
 * Revision 1.1  1995/09/22  11:25:06  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_loader
#define _H_loader

#include "core.h"

int loadFile(const char *filename);
BNRP_Boolean BNRP_inCoreLoader(TCB *tcb);

#endif
