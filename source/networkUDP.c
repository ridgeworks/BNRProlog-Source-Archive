/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/networkUDP.c,v 1.15 1999/04/07 07:11:49 csavage Exp $
*
*  $Log: networkUDP.c,v $
 * Revision 1.15  1999/04/07  07:11:49  csavage
 * Fixed send[TCP/UDP] to send null terminated strings.
 *
 * Revision 1.14  1998/06/10  02:25:32  csavage
 * Changed networking (TCP and UDP) code to handle multiple
 * null-terminated messages in the receive buffer.  Old behaviour
 * was to keep first message, discard rest of buffer.
 *
 * Revision 1.13  1998/03/31  11:17:33  csavage
 * created send/receive UDPbytes primitives
 *
 * Revision 1.12  98/03/26  16:43:34  16:43:34  csavage (Christopher Savage)
 * Changed for system to open socket when
 * no port is specified and removing REUSEADDR
 * from VART case in opensocket.
 * 
 * Revision 1.11  1998/01/20  16:40:04  thawker
 * Changed calls to get/setsockopts() to cast using (optValT *), which
 * is defined in network.h according to platform
 *
 * Revision 1.10  1997/05/14  10:31:57  harrisj
 * Enabled the SO_REUSEADDR option when binding sockets
 *
 * Revision 1.9  1996/08/26  15:08:31  harrisj
 * BNRP_opensocketUDP() was not incrementing BNRPfdCount
 *
 * Revision 1.8  1995/12/12  14:21:52  yanzhou
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
 * Revision 1.7  1995/12/04  00:10:21  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.6  1995/11/20  11:46:38  yanzhou
 * To be more careful with getsockopt() SO_SNDBUF and SO_RCVBUF.
 *
 * Revision 1.5  1995/11/10  14:22:22  yanzhou
 * Added definition for INADDR_NONE, which is not defined on SunOS 4.1.3.
 *
 * Revision 1.4  1995/11/02  10:15:38  yanzhou
 * Was using malloc and free.  Now uses BNRP_malloc and BNRP_free.
 *
 * Revision 1.3  1995/10/25  12:03:21  yanzhou
 * sendmessage and receivemessage (both UDP and TCP) now check
 * the SO_SNDBUF and SO_RCVBUF options to decide the maximum message size
 * they can handle.
 *
 * Revision 1.2  1995/10/23  16:04:39  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.1  1995/10/19  14:25:08  harrisja
 * Initial version
 *
*
*/

#include "BNRProlog.h"
#include "base.h"

#ifdef supportNetworking /* set in base.h */
#include "core.h"
#include "network.h"
#include "hardware.h"    /* for  BNRP_malloc/free */

#include <sys/types.h>
#include <sys/socket.h>  /* socket types, flags, address families,
                          * socket structure, protocol families SOMAXCONN
                          */
#include <netinet/in.h>  /* inet_ntoa() */
#ifndef INADDR_NONE      /* not defined on SunOS 4.1.3 */
#define INADDR_NONE ((unsigned long) 0xFFFFFFFF)
#endif
#include <signal.h>
#include <errno.h>       /* errno */
#include <limits.h>      /* USHRT_MAX */
#include <stdio.h>       /* FILE, fwrite(), fread() */

#define heapcheck(n)    if ((tcb->heapend - tcb->hp) LE (n * sizeof(long))) \
                                 BNRP_error(HEAPOVERFLOW)
/* #define debugUDP		/* Enables debugging of UDP predicates */



BNRP_Boolean BNRP_opensocketUDP(TCB *tcb)
{
	long               port_number;
	int                receiveSocket = 0;
	int		   so_optval=1;
	int 		   length = sizeof(struct sockaddr_in); /* used in getsockname call */
	
	struct sockaddr_in receiveAddr;

	if(tcb->numargs NE 2) return(FALSE);

	if(!BNRPnetworkUseable)
	{
		FD_ZERO(&BNRPfds);
		FD_ZERO(&BNRPconnectedFds);
	}
	
	switch(checkArg(tcb->args[1],&port_number))
	{
    case INTT:				/*User specified a port number*/
        /*Must be GE lowest assignable port number and lower than the max value allowed by ushort */
        if((port_number LT BNRPlowestPort) || (port_number GT USHRT_MAX))return(FALSE);
        if((receiveSocket = socket(PF_INET,SOCK_DGRAM,0)) EQ -1) /*create the socket */
        {
#ifdef debugUDP
            perror("\nopensocketUDP() case INTT: socket()");
#endif
            return(FALSE);
        }

	 /* Allow address reuse */
	if(setsockopt(receiveSocket, SOL_SOCKET, SO_REUSEADDR, (optValT *)&so_optval, sizeof(so_optval)) NE 0)
	{
#ifdef debugUDP
		perror("\nopenportUDP()");
#endif
		close(receiveSocket);
		return(FALSE);
	} 
        receiveAddr.sin_family = AF_INET;
        receiveAddr.sin_addr.s_addr = htonl(INADDR_ANY);
        receiveAddr.sin_port = htons(port_number);	/*sin_port is in network byte order */	
        if(bind(receiveSocket,(struct sockaddr *)&receiveAddr,sizeof(receiveAddr)) EQ -1)
        {/*Bind the socket */
#ifdef debugUDP
            perror("\nopensocketUDP() case INTT: bind()");
#endif
            close(receiveSocket);
            return(FALSE);
        }
        break;
        
    case VART:
        if((receiveSocket = socket(PF_INET,SOCK_DGRAM,0)) EQ -1)
        {
#ifdef debugUDP
            perror("\nopensocketUDP() case VART: socket()");
#endif
            return(FALSE);
        }

        receiveAddr.sin_family = AF_INET;
        receiveAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	receiveAddr.sin_port = htons(0);  /* Let system find a port */
	
	if(bind(receiveSocket,(struct sockaddr *)&receiveAddr,sizeof(receiveAddr)) EQ -1)
	{	/*If error indicates that failure is not due to the port being in use, fail.  Don't want to recurse endlessly due to unforseen errors */
#ifdef debugUDP
	    perror("\nopensocketUDP() case VART: bind()");
#endif
	    close(receiveSocket);
	    return(FALSE);
	}
	
        if(getsockname(receiveSocket, (struct sockaddr *)&receiveAddr, (optValSizeT *)&length) NE 0)
        {
#ifdef debugUDP
	    perror("\nopensocketUDP() case VART: getsockname()");
#endif
	    close(receiveSocket);
	    return(FALSE);
	}
        break;

    default:
        return(FALSE);
	}

	BNRPnetworkUseable = TRUE;
	BNRPfdCount ++;

	FD_SET(receiveSocket,&BNRPfds);

#ifdef debugUDP
   {
	printf("\nopensocketUDP(): Socket # %d\n",receiveSocket);
	printf("\nopensocketUDP(): Socket Port %ld\n",(long)ntohs(receiveAddr.sin_port));
   }
#endif

	return(unify(tcb,tcb->args[1],makeint(&tcb->hp,(long)ntohs(receiveAddr.sin_port)))
           && unify(tcb,tcb->args[2],makeint(&tcb->hp,receiveSocket)));
}


BNRP_Boolean BNRP_receivemessageUDP(TCB *tcb)
{
    char *msgbuf = 0;
    char *smallbuffer = 0;
    long  rcvbufsiz;
    int   optlen = sizeof(rcvbufsiz);
    int   msglen;
	long  socket;
    long  filefd;
    int   bytes;
    int   retval    = TRUE;
    int   errorcode = 0;
    int current, currentStart;
    FILE *filep;
    long result;
    
	struct sockaddr_in recv_addr;
	int                recv_addr_len = sizeof(recv_addr);
	
	if(tcb->numargs NE 5) return(FALSE);
	if(!BNRPnetworkUseable) return(FALSE);
	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	if(!FD_ISSET(socket,&BNRPfds))
		return(unify(tcb,tcb->args[5],makeint(&tcb->hp,ENOTSOCK)));

	if(socket LT 1) return(FALSE);

    /* get the SO_RCVBUF size of the socket */
    if (getsockopt(socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&rcvbufsiz, (optValSizeT *)&optlen))
        rcvbufsiz = MAX_MSG_SIZE;

    if (rcvbufsiz LE 0)                         /* yanzhou@bnr.ca:20/11/95 */
        rcvbufsiz = MAX_MSG_SIZE;

#ifdef debugUDP
	printf("\nreceivemessageUDP(): Check for incoming message");
#endif	
	if(selectSocket(socket,BNRPread_timer))
	{
#ifdef debugUDP
		printf("\nreceivemessageUDP(): Starting to read message");
#endif
        /* allocate a message buffer of size SO_RCVBUF */
        msgbuf = (char *)BNRP_malloc(rcvbufsiz+1);  /* +1 for the terminating NUL */
        smallbuffer = (char *)BNRP_malloc(rcvbufsiz+1);  /* +1 for the terminating NUL */
        if (msgbuf EQ 0 || smallbuffer EQ 0)                            /* not enough memory          */
            return unify(tcb,tcb->args[5],makeint(&tcb->hp, ENOMEM));

        do {
            errno = 0;
            msglen = recvfrom(socket, msgbuf, rcvbufsiz, 0,
                              (struct sockaddr *)&recv_addr,(optValSizeT *)&recv_addr_len);
        } while ((msglen EQ -1) && (errno EQ EINTR));

#ifdef debugUDP
        printf("\nreceivemessageUDP(): Read %d bytes", msglen);
#endif

        if(msglen EQ -1)
            errorcode = errno;
        else
            msgbuf[msglen] = '\0';              /* NUL-terminated message     */
    } else {
        /*
         * selectSocket timed out
         */
#ifdef debugUDP
        printf("\nreceivemessageUDP(): Nothing to be read");
#endif
        errorcode = ETIMEDOUT;
    }

    if (!errorcode) {                           /* recvfrom was successful    */
        retval = unify(tcb,tcb->args[2],BNRPLookupTempSymbol(tcb,inet_ntoa(recv_addr.sin_addr)))
            && unify(tcb,tcb->args[3],makeint(&tcb->hp,recv_addr.sin_port));

        if(checkArg(tcb->args[4],&filefd) EQ INTT)
        {
            /*
             * Write the message to a stream
             */
            filep = (FILE *)filefd;
            do {
                errno = 0;
                bytes = fwrite(msgbuf, sizeof(char), msglen, filep);
            } while ((bytes EQ -1) && (errno EQ EINTR));
            fflush(filep);

#ifdef debugUDP
            printf("\nWrote to file %d of %d",bytes,msglen);
#endif
            /* write error */
            if (bytes EQ -1)             errorcode = errno;
            if (!bytes && ferror(filep)) errorcode = EIO;
        } else {
        
        BNRP_term symTerm;
            /*
             * Convert the message to a Prolog symbol
             */
             /* This part now looks for nulls in the receive buffer, and places
	       each of the strings between the nulls in a list to be returned
	       to the calling function. */ 
	       
	       
	    heapcheck(msglen+1); /* have we got enough space? */
	    result = maketerm(LISTTAG, tcb->hp);
		  
            msgbuf[msglen] = '\0';
             
            current = 0;   /* current points to the current byte in the receive buffer. */
	    currentStart = 0; /* currentStart is the start of the current message .. ie
				 immediately after the last null. */
	    
	    while (current LE msglen) {
	        
	        /* copy the current character into the smallbuffer */
	        smallbuffer[current - currentStart] = msgbuf[current];
	        
	        if ( msgbuf[current] == '\0' ){
		   /* have reached the end of the current message
		      place it on the stack */
		  if ( current != 0 && msgbuf[current-1] != '\0' ) {
		      symTerm = BNRPLookupTempSymbol(tcb,smallbuffer);
		      push(BNRP_term, tcb->hp, symTerm);
		  }
		   /* set currentStart to next character */
		   currentStart = current + 1;
		}
		current++; /* move to next character */
	    }  
	    
	    push(long,tcb->hp,0); 
             
            retval = retval && unify(tcb, tcb->args[4], result);
        }
    }

    if (msgbuf) { BNRP_free(msgbuf);    BNRP_free(smallbuffer); }          /* free the allocated message buffer */
    return retval && unify(tcb, tcb->args[5], makeint(&tcb->hp, errorcode));
}


BNRP_sendmessageUDP(TCB *tcb)
{
    long               ip_term, ip, port, msg_term, socket;
	struct sockaddr_in destination;
	int                bytes;
    BNRP_sighandler    oldSigPipeHandler;
	TAG                tag;
    FILE              *filep;
    char              *msgbuf;
    int                msglen;
    long               sndbufsiz;
    int                optlen     = sizeof(sndbufsiz);
    int                errorcode  = 0;
#ifdef debugUDP
    long               totalsize  = 0;
    long               totalbytes = 0;
#endif

	if(tcb->numargs NE 5) return(FALSE);
	if(!BNRPnetworkUseable) return(FALSE);

	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);	
	if(checkArg(tcb->args[2],&ip_term) NE SYMBOLT) return(FALSE);
	if((ip = inet_addr(nameof(ip_term))) EQ INADDR_NONE) return(FALSE);
	
	if(checkArg(tcb->args[3],&port) NE INTT) return(FALSE);
	if(!FD_ISSET(socket,&BNRPfds))
		return(unify(tcb,tcb->args[5],makeint(&tcb->hp,ENOTSOCK)));

	destination.sin_family = AF_INET;
	destination.sin_port = htons(port);
	memcpy((char *)&destination.sin_addr,(char *)&ip,sizeof(ip));

#ifdef debugUDP
	printf("\nsendmessageUDP(): Start sending message");
#endif

    /* the socket SO_SNDBUF size */
    if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&sndbufsiz, (optValSizeT *)&optlen))
        sndbufsiz = MAX_MSG_SIZE;

    if (sndbufsiz LE 0)                         /* yanzhou@bnr.ca:20/11/95 */
        sndbufsiz = MAX_MSG_SIZE;

	oldSigPipeHandler = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(sigPipeHandler));

    switch (checkArg(tcb->args[4],&msg_term)) {

    case SYMBOLT:                               /* the message is a Prolog symbol */
        msgbuf = nameof(msg_term);
        msglen = strlen(msgbuf) + 1;	/* +1 for null */
        if (msglen > sndbufsiz) {
            errorcode = 1;                      /* message too large */
            break;
        }

        /* send the message */
        do {
            errno = 0;
            bytes = sendto(socket, msgbuf, msglen, 0,
                           (struct sockaddr *)&destination, sizeof(destination));
        } while ((bytes EQ -1) && (errno EQ EINTR));

        if (bytes EQ -1) {
#ifdef debugUDP
            perror("\nsendmessageUDP()");
#endif
            errorcode = errno;
        }
#ifdef debugUDP
        printf("\nsendmessageUDP(): Wrote %d bytes of %d",bytes,msglen);
#endif
        break;

    case INTT:                                  /* the message is in a STREAM          */
        filep = (FILE *)msg_term;               /* the message term is a FILE pointer  */
		msgbuf = (char *)BNRP_malloc(sndbufsiz);/* allocate a buffer of size SO_SNDBUF */
        if (msgbuf EQ 0) {
            errorcode = ENOMEM;                 /* the allocation failed               */
            break;
        }
#ifdef debugUDP
		printf("\nsendmessageUDP(): Start sending file");
#endif

		clearerr(filep);                        /* clear existing errors               */

        /*
         * loop till EOF
         */
		while(!feof(filep) && !ferror(filep) && !errorcode) 
		{
			errno = 0;
			msglen = fread(msgbuf, sizeof(char), sndbufsiz, filep);

            if (msglen GT 0)
			{
#ifdef debugUDP
				printf("\nAbout to write %d bytes from file", msglen);
#endif
                do {
                    errno = 0;
                    bytes = sendto(socket, msgbuf, msglen, 0,
                                   (struct sockaddr *)&destination, sizeof(destination));
                } while ((bytes EQ -1) && (errno EQ EINTR));

				if(bytes EQ -1)                 /* error */
				{
#ifdef debugUDP
					perror("\nsendmessageUDP()");
#endif
                    errorcode = errno;
                    break;
				}
#ifdef debugUDP
				totalsize  += msglen;
				totalbytes += bytes;
#endif
			}
		}
#ifdef debugUDP
		printf("\nError code:  %d  %d",ferror(filep),feof(filep));
        printf("\nsendmessageUDP(): Wrote from file. Wrote %d bytes of %d",totalbytes,totalsize);
#endif
		if (!errorcode && ferror(filep))
            errorcode = EIO;

        BNRP_free(msgbuf);
        break;

    default:
        BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
        return FALSE;
    }
	
    BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
	return unify(tcb,tcb->args[5], makeint(&tcb->hp,errorcode));
}

BNRP_Boolean BNRP_receiveUDPbytes(TCB *tcb)
{
/* Args : Socket, Host, Port, count, Stream, Error */
   char *msgbuf = 0;
   long  rcvbufsiz;
   int   optlen = sizeof(rcvbufsiz);
   int   msglen;
   long  socket;
   long  filefd;
   int   bytes;
   int   retval    = TRUE;
   int   errorcode = 0;
   FILE *filep;
   int index = 0;
   long length;
   long result;
   TAG 	tag = checkArg(tcb->args[4], &length);
    
   struct sockaddr_in recv_addr;
   int	recv_addr_len = sizeof(recv_addr);
	
   if(tcb->numargs NE 6) return(FALSE);
   if(!BNRPnetworkUseable) return(FALSE);
   if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
   if(!FD_ISSET(socket,&BNRPfds))
      return(unify(tcb,tcb->args[6],makeint(&tcb->hp,ENOTSOCK)));

   if(socket LT 1) return(FALSE);

    /* get the SO_RCVBUF size of the socket */
    if (getsockopt(socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&rcvbufsiz, (optValSizeT *)&optlen))
        rcvbufsiz = MAX_MSG_SIZE;

    if (rcvbufsiz LE 0)                         /* yanzhou@bnr.ca:20/11/95 */
        rcvbufsiz = MAX_MSG_SIZE;

   if((tag EQ INTT) && (length < rcvbufsiz))
      rcvbufsiz = length;

#ifdef debugUDP
	printf("\nreceivemessageUDP(): Check for incoming message");
#endif	
        /* allocate a message buffer of size SO_RCVBUF */
   msgbuf = (char *)BNRP_malloc(rcvbufsiz);
   if (msgbuf EQ 0)
   {
      BNRP_free(msgbuf);
      return unify(tcb, tcb->args[6], makeint(&tcb->hp, ENOMEM));
   }
       
   /* is the socket readable ?                 */
   if(selectSocket(socket,BNRPread_timer))
   {
#ifdef debugUDP
      printf("\nreceivemessageUDP(): Starting to read message");
#endif
        do {
            errno = 0;
            msglen = recvfrom(socket, msgbuf, rcvbufsiz, 0,
                              (struct sockaddr *)&recv_addr,(optValSizeT *)&recv_addr_len);
        } while ((msglen EQ -1) && (errno EQ EINTR));

#ifdef debugUDP
        printf("\nreceiveUDPbytes(): Read %d bytes", msglen);
#endif

        if(msglen EQ -1)
            errorcode = errno;
        else
            msgbuf[msglen] = '\0';              /* NUL-terminated message     */
    } else {
        /*
         * selectSocket timed out
         */
#ifdef debugUDP
        printf("\nreceivemessageUDP(): Nothing to be read");
#endif
        errorcode = ETIMEDOUT;
    }

    if (!errorcode) {                           /* recvfrom was successful    */

      heapcheck(msglen+1);
      result = maketerm(LISTTAG, tcb->hp);
      while(msglen > index)
      {
	 push(long,tcb->hp,makeintterm((unsigned char)msgbuf[index])); 
	 index++;
      }
      push(long,tcb->hp,0);      
   }
   else 
   {
   BNRP_free(msgbuf);
   return unify(tcb, tcb->args[6], makeint(&tcb->hp, errorcode));
   }

        retval = unify(tcb,tcb->args[2],BNRPLookupTempSymbol(tcb,inet_ntoa(recv_addr.sin_addr)))
            && unify(tcb,tcb->args[3],makeint(&tcb->hp,recv_addr.sin_port))
            && unify(tcb, tcb->args[5], result);

   if(tag EQ VART)
      retval = retval && unify(tcb,tcb->args[4],makeint(&tcb->hp,msglen));

    if (msgbuf) BNRP_free(msgbuf);              /* free the allocated message buffer */
	return retval && unify(tcb, tcb->args[6], makeint(&tcb->hp, errorcode));
}


BNRP_sendUDPbytes(TCB *tcb)
{
/* Args : Socket, Host, Port, count, Stream, Error */
   long		ip_term, ip, port, msg_term, socket;
   struct sockaddr_in destination;
   int		bytes;
   BNRP_sighandler    oldSigPipeHandler;
   TAG		tag;
   char		*buffer;
   int		msglen;
   long		sndbufsiz;
   int		optlen     = sizeof(sndbufsiz);
   int		errorcode  = 0;
   long 	message, p, length, orig, result;
   ptr		addr;
   int index = 0;
#ifdef debugUDP
   long		totalsize  = 0;
   long		totalbytes = 0;
#endif

   if(tcb->numargs NE 6) return(FALSE);
   if(!BNRPnetworkUseable) return(FALSE);

   if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);	
   if(checkArg(tcb->args[2],&ip_term) NE SYMBOLT) return(FALSE);
   if((ip = inet_addr(nameof(ip_term))) EQ INADDR_NONE) return(FALSE);
	
   if(checkArg(tcb->args[3],&port) NE INTT) return(FALSE);
   if(!FD_ISSET(socket,&BNRPfds))
      return(unify(tcb,tcb->args[6],makeint(&tcb->hp,ENOTSOCK)));

   destination.sin_family = AF_INET;
   destination.sin_port = htons(port);
   memcpy((char *)&destination.sin_addr,(char *)&ip,sizeof(ip));

#ifdef debugUDP
   printf("\nsendmessageUDP(): Start sending message");
#endif

   oldSigPipeHandler = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(sigPipeHandler));

   /* Is it a list? */
   if(checkArg(tcb->args[5],&message) NE LISTT)
      return(FALSE);
      
   /* Get length of list */
   if(checkArg(tcb->args[4],&length) NE INTT)
      return(FALSE);


   /* Check if the send buffer is big enough.  If not resize */
   if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&sndbufsiz, (optValSizeT *)&optlen))
      sndbufsiz = MAX_MSG_SIZE;

   if (sndbufsiz LE 0)                         /* yanzhou@bnr.ca:20/11/95 */
      sndbufsiz = MAX_MSG_SIZE;

   if(sndbufsiz LT length)
   {
      sndbufsiz = length;
      setsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT*)&sndbufsiz, (optValSizeT )optlen);
   }
   
   /* Alloc a buffer */
   buffer = (char *)BNRP_malloc(sndbufsiz);
   if (buffer EQ 0)
   {
      BNRP_free(buffer);
      return unify(tcb, tcb->args[6], makeint(&tcb->hp, ENOMEM));
   }
   
   /* Put bytes from list into buffer */ 
   p = addrof(message);
   derefTV(&p, &orig, &tag, &result, &addr);
   while((tag NE ENDT) && (index < sndbufsiz))
   {
      /* Make sure we have a list of integers */
      if(tag NE INTT)
      {
	 BNRP_free(buffer);
	 return(FALSE);
      }
      
      /* Make sure it is a byte value */
      if((result LT 0) || (result GT 255))
      {
	 BNRP_free(buffer);
	 return(FALSE);
      }
      
      buffer[index] = (char) result; 
      derefTV(&p,&orig,&tag,&result,&addr);
      index++;
   }
      
   errno  = 0;

   do {
      bytes = sendto(socket, buffer, length, 0,
                           (struct sockaddr *)&destination, sizeof(destination));
   } while ((bytes EQ -1) && (errno EQ EINTR));
        
   if(bytes EQ -1)                    /* write failure */
   {
#ifdef debugUDP
      perror("\nsendUDPbytes()");
#endif
      errorcode = errno;
   }
#ifdef debugUDP
   printf("\nsendTCPbytes(): Writing Message.  Wrote %d bytes of %d",
      bytes, buffersize);
#endif
    
   BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
   BNRP_free(buffer);
   return unify(tcb,tcb->args[6],makeint(&tcb->hp, errorcode));
}

#endif

