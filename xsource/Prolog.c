/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/Prolog.c,v 1.1 1995/09/22 11:26:47 harrisja Exp $
*
*  $Log: Prolog.c,v $
 * Revision 1.1  1995/09/22  11:26:47  harrisja
 * Initial version.
 *
*
*/

/**********************************************************************************


 File: prolog.c
 
 Project: Prolog

 Description:  This file is a main line program which embeds a Prolog system 
               within an OSF Motif based user interface.


                         Larry Brunet 
                         Jean Jervis
            Computing Research Lab, Bell-Northern Research,
                         January 1991
 
 Copyright (c) 1991 Bell-Northern Research Ltd.

************************************************************************************/

/* include files */

#include <stdio.h>
#include <errno.h>

#include <X11/Intrinsic.h>   /* X and Motif libraries */
#include <X11/Xlib.h>

#include "BNRProlog.h"


BNRP_TCB  tcb;

/* Prolog related data */

#define ENVIRONSIZE  100000
#define CHOICEPTSIZE 100000

/* Callback definitions */

int  myErrorHandler(); /* Handle non-fatal X errors */

/* main - main logic for driver for Prolog system. */

main(argc,argv)

   unsigned int argc;
   char *argv[];

{  
   register int  i;
	Arg		args[2];
	int		n = 0;

   /* Initialize toolkit */
   XtToolkitInitialize();

   XSetErrorHandler(myErrorHandler);
   
   /* Initialize the Prolog system */
   return InitProlog(argc,argv);

   /* Control now passes to the Prolog system. The main event loop is encoded 
      in the userevent primitive */ 
}

int myErrorHandler(display, err)
Display *display;
XErrorEvent *err;
{
#ifdef DEBUG
	char msg[80];
	XGetErrorText(display, err->error_code, msg, 80);
	printf("Error code %s, Request code %d\n", msg, err->request_code);
#endif
}

/* InitProlog - Initialize the embedded Prolog system */

int InitProlog(argc,argv)
unsigned int argc;
char **argv;
{   BNRP_term a;
	char	*conf;
	long int heapSize = 0;
	long int envSize = 0;
	extern char *BNRP_getConfig();
	extern char BNRP_lastErrorTraceback[];
	int result = 0;

	if ((conf = BNRP_getConfig()) != NULL)
		sscanf(conf,"configuration(%*ld, %ld, %ld", &heapSize, &envSize);
	heapSize = (heapSize <= 0) ? CHOICEPTSIZE : heapSize * 1024;
	envSize = (envSize <= 0) ? ENVIRONSIZE : envSize * 1024;
    
    if (BNRP_initializeTCB(&tcb,"main",envSize,heapSize)) {
    	fprintf(stderr,"Insufficient memory\n");
		return -1;
    }

	/* if (result=BNRP_initializeAllRings(argc,argv))
		return result; */ /* Modified Jason Harris Feb. 95 */

    if (result=BNRP_initializeAllRings(argc,argv)) {
                if (result != -2)
                        fprintf(stderr,"BNR Prolog - can't load base file, exiting...\n");
                return result;
	      };


	a = BNRP_makeSymbol(&tcb, "pde_init");
	if (!(result = BNRP_execute(&tcb, a))) 
		printf("listener successful\n");
	else {
		printf("listener fails\n");
		printf("return code = %d\n",result);
		printf("%s\n",BNRP_lastErrorTraceback); 
	}
	return result;
}
