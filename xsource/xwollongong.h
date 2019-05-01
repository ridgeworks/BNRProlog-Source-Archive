/*
 *
 *  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/xwollongong.h,v 1.1 1995/11/07 10:44:33 yanzhou Exp $
 *
 *  $Log: xwollongong.h,v $
 * Revision 1.1  1995/11/07  10:44:33  yanzhou
 * New files xwollongong.[hc] created.
 *
 *
 *
 */

/*
 *  This header file contains the prototypes of the add-on functions
 *  available in xwollongong.c.  To use these functions, this file
 *  must be included in the application along with BNRProlog.h
 *
 */

#ifndef XWOLLONGONG_H
#define XWOLLONGONG_H

#ifdef __cplusplus
extern "C" {
#endif

/* getXConnectionNumber, returns -1 on error */
int BNRP_getXConnectionNumber();
	
#ifdef __cplusplus
}
#endif

#endif
