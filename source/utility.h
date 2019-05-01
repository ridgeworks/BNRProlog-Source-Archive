/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/utility.h,v 1.2 1997/12/22 17:01:48 harrisj Exp $
*
*  $Log: utility.h,v $
 * Revision 1.2  1997/12/22  17:01:48  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:29:08  harrisja
 * Initial version.
 *
*
*/
#ifndef _H_utility
#define _H_utility

#include "base.h"
#include "core.h"

void BNRP_dumpHex(FILE *file, void *start, void *last);
void deref(long reg, long *taggedValue, TAG *tag, long *value, ptr *lastAddr);
void derefTV(long *p, long *taggedValue, TAG *tag, long *value, ptr *lastAddr);
void BNRP_dumpArg(FILE *file, TCB *tcb, long value);
TAG checkArg(long reg, long *value);
void getVarName(TCB *tcb, long result, char *name);

int BNRP_loadBase(int argc, char **argv, char *defaultbase);
void BNRP_initializeAllLowerRings(int argc, char **argv);

#endif
