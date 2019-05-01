/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/networkTCP.c,v 1.21 1999/04/07 07:11:48 csavage Exp $
*
*  $Log: networkTCP.c,v $
 * Revision 1.21  1999/04/07  07:11:48  csavage
 * Fixed send[TCP/UDP] to send null terminated strings.
 *
 * Revision 1.20  1998/06/10  02:25:30  csavage
 * Changed networking (TCP and UDP) code to handle multiple
 * null-terminated messages in the receive buffer.  Old behaviour
 * was to keep first message, discard rest of buffer.
 *
 * Revision 1.19  1998/03/31  11:16:56  csavage
 * created send/receive TCPbytes primitives
 *
 * Revision 1.18  98/03/26  15:54:02  15:54:02  csavage (Christopher Savage)
 * Fixed problem with two client connections to server failing
 * when on same client.  Now let system assign a port when annon. 
 * specified.
 * Updated typedefs for AIX 4.2.1
 * 
 * Revision 1.17  1998/01/20  15:41:44  thawker
 * Changed calls to get/setsockopts() to cast using (optValT *), which
 * is defined in network.h according to platform
 * <sys/filio.h> is now #included on both nav and solaris
 *
 * Revision 1.16  1997/05/14  10:31:53  harrisj
 * Enabled the SO_REUSEADDR option when binding sockets
 *
 * Revision 1.15  1996/07/05  14:15:18  yanzhou
 * Added <sys/filio.h> to compile on NAV 88K.
 *
 * Revision 1.14  1996/05/20  16:51:28  neilj
 * Added implementations of BNRP_receiveTCPterm and BNRP_sendTCPterm.
 * These are used to implement the new predicates sendTCPterm and receiveTCPterm.
 *
 * Revision 1.13  1995/12/18  09:45:20  yanzhou
 * Minor changes in BNRP_makeCon() to return consistent error codes.
 *
 * Revision 1.12  1995/12/13  17:04:44  yanzhou
 * Added #include <arpa/inet.h> for the function prototype
 * of inet_ntoa().
 *
 * Revision 1.11  95/12/13  13:49:04  13:49:04  yanzhou (Yan Zhou)
 * BNRP_makeCon() modified to treat EINVAL as ECONNREFUSED on
 * sockets in non-blocking I/O mode.
 * 
 * Revision 1.10  1995/12/13  11:45:00  yanzhou
 * In BNRP_makeCon(), errno EISCONN (socket already connected)
 * is now treated as a success (was an error), as a connect()
 * operation on the socket may have already been initiated in one
 * of the previous connect() calls.
 *
 * Revision 1.9  1995/12/12  18:10:56  yanzhou
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
 * Revision 1.10  95/12/12  17:17:39  17:17:39  yanzhou (Yan Zhou)
 * Minor changes in BNRP_makeCon.
 * 
 * Revision 1.9  1995/12/12  14:21:50  yanzhou
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
 * Revision 1.8  1995/12/04  00:10:20  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.7  1995/11/20  11:46:32  yanzhou
 * To be more careful with getsockopt() SO_SNDBUF and SO_RCVBUF.
 *
 * Revision 1.6  1995/11/17  16:51:25  yanzhou
 * Added debug statements to check the SO_RCVBUF size immediately after opensocket/acceptconnection.
 *
 * Revision 1.5  1995/11/10  14:22:19  yanzhou
 * Added definition for INADDR_NONE, which is not defined on SunOS 4.1.3.
 *
 * Revision 1.4  1995/11/02  10:15:35  yanzhou
 * Was using malloc and free.  Now uses BNRP_malloc and BNRP_free.
 *
 * Revision 1.3  1995/10/25  12:03:13  yanzhou
 * sendmessage and receivemessage (both UDP and TCP) now check
 * the SO_SNDBUF and SO_RCVBUF options to decide the maximum message size
 * they can handle.
 *
 * Revision 1.2  1995/10/23  16:04:38  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.1  1995/10/19  14:25:23  harrisja
 * Initial version
 *
*
*/

#include "BNRProlog.h"
#include "base.h"

#ifdef supportNetworking /* set in base.h */
#include "core.h"
#include "hardware.h"
#include "network.h"

#include <sys/types.h>
#include <sys/socket.h>  /* socket types, flags, address families, socket structure, protocol families SOMAXCONN*/
#include <netinet/in.h>  /* sockaddr_in */
#include <arpa/inet.h>   /* inet_ntoa() */
#include <sys/ioctl.h>   /* for ioctl() */
#if defined nav || defined solaris
#include <sys/filio.h>   /* for FIONREAD */
#endif
#ifndef INADDR_NONE      /* not defined on SunOS 4.1.3 */
#define INADDR_NONE ((unsigned long) 0xFFFFFFFF)
#endif
#include <netinet/tcp.h> /* TCP_NODELAY definition */
#include <errno.h>       /* errno */
#include <limits.h>      /* USHRT_MAX */
#include <stdio.h>       /* FILE, fwrite(), fread() */
#define heapcheck(n)    if ((tcb->heapend - tcb->hp) LE (n * sizeof(long))) \
                                 BNRP_error(HEAPOVERFLOW)
                                 
/* #define debugTCP 		/* Enables debugging of TCP predicates */


/*
    netRead
    -------
    This routine is just like the Unix read(2) function, but ensures the read is completed as much as possible.
*/
static ssize_t netRead(int socket, const char* buffer, size_t length)
{
    ssize_t bytesRead;
    size_t totalRead = 0;
    
    do {
	bytesRead = 0;
	do {
	buffer += bytesRead; length -= bytesRead;
	    bytesRead = read(socket, buffer, length);
	    if (bytesRead > 0)
		totalRead += bytesRead;
	} while (bytesRead != length && bytesRead > 0);
    } while ((bytesRead == -1) && (errno == EINTR));
    
    return bytesRead == -1 ? -1 : totalRead;
}

/*
    netWrite
    --------
    This routine is just like the Unix write(2) function, but ensures the write finishes as long as errors
    aren't occurring.
*/
static ssize_t netWrite(int socket, const char* buffer, size_t length)
{
    ssize_t written;
    size_t result = 0;
    
    do {
	written = 0;
	do {
	    buffer += written; length -= written; result += written;
	    written = write(socket, buffer, length);
	} while (written != length && written > 0);
    } while ((written EQ -1) && (errno EQ EINTR));
    return written == -1 ? -1 : result;
}


BNRP_Boolean BNRP_opensocketTCP(TCB *tcb)	/* Creates an AF_INET SOCK_STREAM socket that will listen on all of the host's network interfaces (INADDR_ANY)*/
{
	long port_number;
	int on = 1, id = getpid();
	int so_optval = 1, receiveSocket = 0;
	struct sockaddr_in receiveAddr;
	int length = sizeof(struct sockaddr_in); /* for getsockname call */

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
        if((receiveSocket = socket(PF_INET,SOCK_STREAM,0)) EQ -1) /*create the socket */
        {
#ifdef debugTCP
            perror("\nopensocketTCP() case INTT: socket()");
#endif
            return(FALSE);
        }

	 /* Allow address reuse */
	if(setsockopt(receiveSocket, SOL_SOCKET, SO_REUSEADDR, (optValT *)&so_optval, sizeof(so_optval)) NE 0)
	{
#ifdef debugTCP
		perror("\nopenportTCP()");
#endif
		close(receiveSocket);
		return(FALSE);
	}


        receiveAddr.sin_family = AF_INET;
        receiveAddr.sin_addr.s_addr = htonl(INADDR_ANY);
        receiveAddr.sin_port = htons(port_number);	/*sin_port is in network byte order */	
        if(bind(receiveSocket,(struct sockaddr *)&receiveAddr,sizeof(struct sockaddr_in)) EQ -1)
        {/*Bind the socket */
#ifdef debugTCP
            perror("\nopensocketTCP() case INTT: bind()");
#endif
            close(receiveSocket);
            return(FALSE);
        }
        break;
        
    case VART:
        if((receiveSocket = socket(PF_INET,SOCK_STREAM,0)) EQ -1)
        {
#ifdef debugTCP
            perror("\nopensocketTCP() case VART: socket()");
#endif
            return(FALSE);
        }

        receiveAddr.sin_family = AF_INET;
        receiveAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	receiveAddr.sin_port = htons(0);  /* let system assign a port */
	
	if(bind(receiveSocket,(struct sockaddr *)&receiveAddr,sizeof(struct sockaddr_in)) EQ -1)
	{	/*If error indicates that failure is not due to the port being in use, fail.  Don't want to recurse endlessly due to unforseen errors */
#ifdef debugTCP
                perror("\nopensocketTCP() case VART: bind()");
#endif
		close(receiveSocket);
                return(FALSE);
	}

        if(getsockname(receiveSocket, (struct sockaddr *)&receiveAddr, (optValSizeT *)&length) NE 0)
        {
#ifdef debugTCP
	    perror("\nopensocketTCP() case VART: getsockname()");
#endif
	    close(receiveSocket);
	    return(FALSE);
	}        
        break;
        
    default:
        return(FALSE);
	}

#ifdef debugTCP
    {
        long bufsiz; int optlen = sizeof(bufsiz);
        
        
        if (getsockopt(receiveSocket, SOL_SOCKET, SO_RCVBUF, (optValT *)&bufsiz, &optlen) EQ 0)
            fprintf(stderr, "\nSO_RCVBUF of socket %d is %ld", receiveSocket, bufsiz);
        else
            fprintf(stderr, "\ngetsockopt(%d) failed.", receiveSocket);
    }
#endif

	so_optval = 1;
	if(setsockopt(receiveSocket, IPPROTO_TCP, TCP_NODELAY, (optValT *)&so_optval, sizeof(so_optval)) NE 0)
	{
#ifdef debugTCP
		perror("\nopenportTCP()");
#endif
		close(receiveSocket);
		return(FALSE);
	}

	BNRPnetworkUseable = TRUE;
	BNRPfdCount ++;

	FD_SET(receiveSocket,&BNRPfds);

#ifdef debugTCP
      {
	printf("\nopensocketTCP(): Socket # %d\n",receiveSocket);
	printf("\nopensocketTCP(): Socket Port %ld\n",(long)ntohs(receiveAddr.sin_port));
      }
#endif
	return(unify(tcb,tcb->args[1],makeint(&tcb->hp,(long)ntohs(receiveAddr.sin_port)))
           && unify(tcb,tcb->args[2],makeint(&tcb->hp,receiveSocket)));
}


BNRP_Boolean BNRP_listenSocket(TCB *tcb)
{
	long socket;

	if(tcb->numargs NE 2) return(FALSE);
	
	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	
	if(socket LT 1) return(FALSE);
	
	if(!FD_ISSET(socket,&BNRPfds)) return(FALSE);
	
	errno = 0;
	listen(socket,SOMAXCONN);
	return(unify(tcb,tcb->args[2],makeint(&tcb->hp,errno)));
}


BNRP_Boolean BNRP_acceptCon(TCB *tcb)
{
	long socket;
	struct sockaddr_in sock_addr;
	int rcv_socket, size = sizeof(sock_addr);
	
	if(tcb->numargs NE 5) return(FALSE);
	
	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	if(socket LT 1) return(FALSE);
	if(!FD_ISSET(socket,&BNRPfds))
		return(unify(tcb,tcb->args[5],makeint(&tcb->hp,ENOTSOCK)));
	if(FD_ISSET(socket,&BNRPconnectedFds)) 
		return(unify(tcb,tcb->args[5],makeint(&tcb->hp,EISCONN)));

	errno = 0;	
#ifdef debugTCP
	printf("\nacceptCon(): Check for pending connection");
#endif	
	if(selectSocket(socket,BNRPconnect_timer))
	{
#ifdef debugTCP
		printf("\nacceptCon(): Accept pending connection");
#endif			
		if((rcv_socket = accept(socket,(struct sockaddr *)&sock_addr,(optValSizeT *)&size)) EQ -1)
		{
#ifdef debugTCP
			perror("\nacceptCon()");
#endif
			return(unify(tcb,tcb->args[5],makeint(&tcb->hp,errno)));
		}
		FD_SET(rcv_socket,&BNRPconnectedFds);
		FD_SET(rcv_socket,&BNRPfds);
		BNRPfdCount++;
#ifdef debugTCP
		printf("\nacceptCon(): Connection accepted");
#endif

	}
	else
	{
#ifdef debugTCP
		printf("\nacceptCon(): No pending connections");
#endif
		return(unify(tcb,tcb->args[5],makeint(&tcb->hp,ETIMEDOUT)));
	}

#ifdef debugTCP
    {
        long bufsiz; int optlen = sizeof(bufsiz);
        if (getsockopt(rcv_socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&bufsiz, &optlen) EQ 0)
            fprintf(stderr, "\nSO_RCVBUF of socket %d is %ld", rcv_socket, bufsiz);
        else
            fprintf(stderr, "\ngetsockopt(%d) failed.", rcv_socket);
    }
#endif

	return(unify(tcb,tcb->args[2],BNRPLookupTempSymbol(tcb,inet_ntoa(sock_addr.sin_addr)))
		&& unify(tcb,tcb->args[3],makeint(&tcb->hp,sock_addr.sin_port))
		&& unify(tcb,tcb->args[4],makeint(&tcb->hp,rcv_socket))
		&& unify(tcb,tcb->args[5],makeint(&tcb->hp,0)));
}
	
BNRP_Boolean BNRP_receivemessageTCP(TCB *tcb)
{  /* socket, message, error. */
    long   socket;
    char * buffer;
    char * smallbuffer;
    long   buffersize;
    int    optlen;
    long   readsize  = 0;
    long   filefd;
    int    errorcode = 0;
    int    retval    = TRUE;
    int    current, currentStart;
    size_t bytes;
    long result;
	
	if(tcb->numargs NE 3) return(FALSE);
	if(!BNRPnetworkUseable) return(FALSE);
	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	if(socket LT 1) return(FALSE);
	
	if(!FD_ISSET(socket,&BNRPfds))              /* socket not open      */
		return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTSOCK)));
	
	if(!FD_ISSET(socket,&BNRPconnectedFds))     /* socket not connected */
		return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTCONN)));

#ifdef debugTCP
	printf("\nreceivemessageTCP():Check for incoming message");
#endif
    
    /* allocate a buffer of size SO_RCVBUF      */
    optlen = sizeof(buffersize);
    if (getsockopt(socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
        buffersize = MAX_MSG_SIZE;              /* default buffer size  */

    if (buffersize LE 0)                        /* yanzhou@bnr.ca:20/11/95 */
        buffersize = MAX_MSG_SIZE;

#ifdef debugTCP
    printf("\nreceivemessageTCP(): buffersize = %ld", buffersize);
#endif
    buffer = (char *)BNRP_malloc(buffersize+1);
    smallbuffer = (char *)BNRP_malloc(buffersize+1);
    if (buffer EQ 0 || smallbuffer EQ 0)
        return unify(tcb, tcb->args[3], makeint(&tcb->hp, ENOMEM));

    /* is the socket readable ?                 */
	if(selectSocket(socket,BNRPread_timer))
	{
#ifdef debugTCP
		printf("\nreceivemessageTCP(): Starting to read message");
#endif
        do {
            errno = 0;
            readsize = read(socket, buffer, buffersize);
        } while ((readsize EQ -1) && (errno EQ EINTR));

		if(readsize EQ -1)                      /* Error           */
		{
#ifdef debugTCP
			perror("\nreceivemessageTCP()");
#endif
            errorcode = errno;
		}

		if(readsize EQ 0)                       /* Read nothing    */
		{
#ifdef debugTCP
			printf("\nreceivemessageTCP(): read returned 0");
#endif
			errorcode = ENOTCONN;
		}
    } else {
#ifdef debugTCP
		printf("\nreceivemessageTCP(): Nothing to be read");
#endif
        errorcode = ETIMEDOUT;                  /* select time out */
    }

#ifdef debugTCP
    printf("\nreceivemessageTCP(): Read %d bytes", readsize);
#endif

    if (!errorcode) {                           /* receive succeeded */
        if (checkArg(tcb->args[2],&filefd) EQ INTT) {
            /*
             * Write the message to a STREAM
             */
            do {
                errno = 0;
                bytes = fwrite(buffer, sizeof(char), readsize, (FILE *)filefd);
            } while ((bytes EQ -1) && (errno EQ EINTR));
            fflush((FILE *)filefd);
#ifdef debugTCP
            printf("\nWrote to file %d of %d",bytes,readsize);
#endif
            if (bytes LE 0)
                errorcode = errno;
            if (!errorcode && ferror((FILE *)filefd))
                errorcode = EIO;
        } else {
            /* 
             * convert the received message to a Prolog symbol
             */
             
            /* This part now looks for nulls in the receive buffer, and places
	       each of the strings between the nulls in a list to be returned
	       to the calling function. */ 
	       
	    BNRP_term symTerm;
	     
	    heapcheck(readsize+1); /* have we got enough space? */
	    result = maketerm(LISTTAG, tcb->hp);
		  
            buffer[readsize] = '\0';
             
            current = 0;   /* current points to the current byte in the receive buffer. */
	    currentStart = 0; /* currentStart is the start of the current message .. ie
				 immediately after the last null. */
	    
	    while (current LE readsize) {
	        
	        /* copy the current character into the smallbuffer */
	        smallbuffer[current - currentStart] = buffer[current];
	        
	        if ( buffer[current] == '\0' ){
		   /* have reached the end of the current message
		      place it on the stack */
		      
		  if ( current != 0 && buffer[current-1] != '\0' ) {
		      symTerm = BNRPLookupTempSymbol(tcb,smallbuffer);
		      push(BNRP_term, tcb->hp, symTerm);
		  }
		   /* set currentStart to next character */
		   currentStart = current + 1;
		}
		current++; /* move to next character */
	    }  
	    
	    push(long,tcb->hp,0);
		 
            retval = unify(tcb, tcb->args[2], result);
        }            
    }
    
    BNRP_free(buffer);
    BNRP_free(smallbuffer);
    return retval && unify(tcb, tcb->args[3], makeint(&tcb->hp, errorcode));
}


BNRP_Boolean BNRP_makeCon(TCB *tcb)
{
	long socket, ip_term, ip, port;
	struct sockaddr_in destination;
    int  err;
    int  errno_connect;
    int  errorcode = 0;

	if(tcb->numargs NE 4) return(FALSE);
	if(!BNRPnetworkUseable) return(FALSE);

	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	if(checkArg(tcb->args[2],&ip_term) NE SYMBOLT) return(FALSE);
	if(checkArg(tcb->args[3],&port) NE INTT) return(FALSE);

	if(!FD_ISSET(socket,&BNRPfds))
		return(unify(tcb,tcb->args[4],makeint(&tcb->hp,ENOTSOCK)));

	if((ip = inet_addr(nameof(ip_term))) EQ INADDR_NONE) return(FALSE);

	if(FD_ISSET(socket,&BNRPconnectedFds))
		return(unify(tcb,tcb->args[4],makeint(&tcb->hp,EISCONN)));

	destination.sin_family = AF_INET;
	destination.sin_port = htons(port);
	memcpy((char *)&destination.sin_addr,(char *)&ip,sizeof(long));


#ifdef debugTCP
    printf("\nBNRP_makeCon(): Attempt to connect");
#endif

    enableNONBLOCK(socket);                     /* make the socket non-blocking */
    do {
        /* initiate the connect() */
        errno = 0;
        err = connect(socket,(struct sockaddr *)&destination, sizeof(destination));
    } while ((err EQ -1) && (errno EQ EINTR));
    errno_connect = errno;
    disableNONBLOCK(socket);                    /* make the socket blocking */

    if (err EQ -1) {
        if ( 0
#ifdef EINPROGRESS
             || (errno_connect EQ EINPROGRESS)
#endif
#ifdef EWOULDBLOCK
             || (errno_connect EQ EWOULDBLOCK)
#endif
#ifdef EAGAIN
             || (errno_connect EQ EAGAIN)
#endif
#ifdef EALREADY
             || (errno_connect EQ EALREADY)     /* already in progress      */
#endif
            ) {                                 /* if */
#ifdef debugTCP
            printf("\nBNRP_makeCon: select(socket) for write ...");
#endif
            /*
             * connect() in progress,
             * select(socket) for writing to wait for its completion.
             */
            errno = 0;
            err = selectSocketForWrite(socket, BNRPconnect_timer);
            if (err EQ -1) {
#ifdef debugTCP
                perror("\nBNRP_makeCon(), selectSocketForWrite()");
#endif
                errorcode = errno;
            }
            else if (err) {
                /* select() successful, which means that the
                 * non-blocking connect() has completed.
                 */
                do {
                    errno = 0;
                    err = connect(socket,(struct sockaddr *)&destination,sizeof(destination));
                } while ((err EQ -1) && (errno EQ EINTR));

                if (err EQ -1) {
                    switch (errno) {
                    case EISCONN: errorcode = 0; break;            /* connected */
                    case ETIMEDOUT:
                    case EINVAL:  errorcode = ECONNREFUSED; break; /* rejected  */
                    default:      errorcode = errno;
#ifdef debugTCP
                        perror("\nBNRP_makeCon()");
#endif                    
                    }
                } 
                else
                    errorcode = 0;              /* fine                            */
            }
            else
                errorcode = ETIMEDOUT;          /* select timed-out                */
        }
        else {
            switch (errno_connect) {
            case EISCONN: errorcode = 0; break;            /* connected */
            case ETIMEDOUT:
            case EINVAL:  errorcode = ECONNREFUSED; break; /* rejected  */
            default:      errorcode = errno;
#ifdef debugTCP
                perror("\nBNRP_makeCon()");
#endif                    
            }
        }
    }

    if (! errorcode) {
#ifdef debugTCP
        printf("\nBNRP_makeCon(): Connected");
#endif
        FD_SET(socket,&BNRPconnectedFds);
    }

	return unify(tcb,tcb->args[4],makeint(&tcb->hp, errorcode));
}

			
BNRP_sendmessageTCP(TCB *tcb)
{
	long    socket, message;
    FILE   *filep;
	struct  sockaddr_in destination;
    BNRP_sighandler oldSigPipeHandler;
    char   *buffer;                             /* message buffer   */
    long    buffersize;                         /* buffer size      */
    int     readbytes;                          /* bytes read       */
    int     writebytes;                         /* bytes written    */
    int     errorcode;                          /* error code       */
    int     optlen;
#ifdef debugTCP
    long    totalsize = 0;
    long    totalbytes= 0;
#endif

	if(tcb->numargs NE 3) return(FALSE);
	if(!BNRPnetworkUseable) return(FALSE);
		
	if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
	if(!FD_ISSET(socket,&BNRPfds))              /* not opened yet ? */
		return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTSOCK)));
    if(!FD_ISSET(socket,&BNRPconnectedFds))     /* not connected ?  */
		return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTCONN)));

    errorcode = 0;

    oldSigPipeHandler = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(sigPipeHandler));

    switch (checkArg(tcb->args[2],&message)) {
    case SYMBOLT:
        /*
         * the message is a Prolog symbol
         */
#ifdef debugTCP
		printf("\nsendmessageTCP(): Start sending message");
#endif
        
        errno  = 0;
        buffer = nameof(message);
        buffersize = strlen(buffer) + 1;	/* + 1 for null */
        do {
            writebytes = write(socket, buffer, buffersize);
        } while ((writebytes EQ -1) && (errno EQ EINTR));
        
        if(writebytes EQ -1)                    /* write failure */
        {
#ifdef debugTCP
            perror("\nsendmessageTCP()");
#endif
            errorcode = errno;
            break;
        }
#ifdef debugTCP
        printf("\nsendmessageTCP(): Writing Message.  Wrote %d bytes of %d",
               writebytes, buffersize);
#endif
        break;

    case INTT:
        /*
         * the message is in a STREAM
         */
#ifdef debugTCP
		printf("\nsendmessageTCP(): Start sending file");
#endif
        /* allocate a buffer of size SO_SNDBUF  */
        optlen = sizeof(buffersize);
        if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
            buffersize = MAX_MSG_SIZE;          /* default buffer size           */
 
        if (buffersize LE 0)                    /* yanzhou@bnr.ca:20/11/95       */
            buffersize = MAX_MSG_SIZE;

#ifdef debugTCP
        printf("\nsendmessageTCP(): buffersize = %ld", buffersize);
#endif
        
        buffer = (char *)BNRP_malloc(buffersize); /* allocate buffer             */
        if (buffer EQ 0) {                      /* not enough memory             */
            errorcode = ENOMEM;
            break;
        }

        filep = (FILE *)message;                /* STREAM FILE pointer           */
		clearerr(filep);                        /* clear existing errors         */

        /*
         * loop till EOF to read data from the file and write the data to the socket
         */
		while (!feof(filep) && !ferror(filep) && !errorcode)
		{
            errno = 0;
            do {
                readbytes = fread((void *)buffer,sizeof(char),buffersize, filep);
            } while ((readbytes EQ -1) && (errno EQ EINTR));

            if (readbytes GT 0) {
#ifdef debugTCP
                printf("\nAbout to write %d bytes from file", readbytes);
#endif
                errno = 0;
                do {
                    writebytes = write(socket,(char *)buffer, readbytes);
                } while ((writebytes EQ -1) && (errno EQ EINTR));
                    
                if (writebytes NE readbytes) {  /* failure     */
#ifdef debugTCP
                    perror("\nsendmessageTCP()");
#endif
                    errorcode = errno;
                    break;
                }
#ifdef debugTCP
                totalsize  += readbytes;
                totalbytes += writebytes;
#endif
            }
		} /* while */

		if(!errorcode && ferror(filep))
            errorcode = EIO;

        BNRP_free(buffer);                      /* free the allocated buffer */

#ifdef debugTCP
		printf("\nError code:  %d  %d", ferror(filep),feof(filep));
        printf("\nsendmessageTCP(): Wrote from file. Wrote %d bytes of %d",totalbytes,totalsize);
#endif
        break;

    default:
        BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
        return FALSE;
    }		
    
	BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
	return unify(tcb,tcb->args[3],makeint(&tcb->hp, errorcode));
}


/*
   BNRP_sendTCPterm
   ----------------
   Primitive to send a term over a TCP connection.  See /bnr/woll-docs doc 515.
*/
BNRP_Boolean BNRP_sendTCPterm(TCB *tcb)
{
    long    socket;
    BNRP_sighandler oldSigPipeHandler;
    TSBuffer *buffer;                          /* message buffer   */
    long    buffersize;                         /* buffer size      */
    int     optlen;
    int	   errorcode;

    if(tcb->numargs NE 3) return(FALSE);
    if(!BNRPnetworkUseable) return(FALSE);

    /* Get and validate the socket number */	
    if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
    if(!FD_ISSET(socket,&BNRPfds))              /* not opened yet ? */
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTSOCK)));
    if(!FD_ISSET(socket,&BNRPconnectedFds))     /* not connected ?  */
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTCONN)));


    /* allocate a buffer of size SO_SNDBUF  */
    optlen = sizeof(buffersize);
    if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
	buffersize = MAX_MSG_SIZE;          /* default buffer size           */
    if (buffersize LE 0)
	buffersize = MAX_MSG_SIZE;
    buffersize += 100;			/* slop needed in BNRP_termToString */
    buffer = BNRP_GetNetScratchBuffer(buffersize + 100);
    if (buffer == 0)
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOMEM)));

    /* Convert the term to a string. */
    if (!BNRP_termToString((BNRP_TCB*) tcb, tcb->args[2], buffer->data, buffersize))
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp, -1)));
            
    oldSigPipeHandler = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(sigPipeHandler));

    /* Write the buffer out. */
    buffer->dataSize = strlen(buffer->data) + 1 + sizeof(TSHeader);	/* + 1 for NUL byte */
    BuildTSHeader(buffer);
    errorcode = 0;
    if (netWrite(socket, (void*) &(buffer->header), buffer->dataSize) == -1)
	errorcode = errno;

    BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
    return unify(tcb,tcb->args[3],makeint(&tcb->hp, errorcode));
}


/*
   BNRP_receiveTCPterm
   -------------------
   Primitive to receive a term over a TCP connection.  See /bnr/woll-docs doc 515.
*/
BNRP_Boolean BNRP_receiveTCPterm(TCB *tcb)
{
    long   socket;
    TSBuffer* buffer;
    ssize_t  readsize  = 0;
    int    errorcode = 0;
    long	  bytesAvail;			/* bytes available to be read from socket */
    size_t bytesToRead;
    BNRP_term term;
/*   int i = 0; */
	
    if(tcb->numargs NE 3) return(FALSE);
    if(!BNRPnetworkUseable) return(FALSE);
   
    /* Get the socket */
    if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
    if(socket LT 1) return(FALSE);
    if(!FD_ISSET(socket,&BNRPfds))              /* socket not open      */
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTSOCK)));
    if(!FD_ISSET(socket,&BNRPconnectedFds))     /* socket not connected */
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp,ENOTCONN)));

    /* Get the socket buffer */
    buffer = BNRP_GetSocketBuffer(socket);
    if (buffer == 0)
	return(unify(tcb,tcb->args[3],makeint(&tcb->hp, ENOMEM)));

    /* is the socket readable ? */
waitabit:
    if(selectSocket(socket,BNRPread_timer)) {

	/* Get the number of bytes available to be read */
	if (ioctl(socket, FIONREAD, &bytesAvail) < 0)
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, errno)));
	    
	if (bytesAvail == 0)
	    return(unify(tcb, tcb->args[3], makeint(&tcb->hp, ENOTCONN)));
	
	/* Read the header. */
	if (buffer->dataSize < sizeof(TSHeader) && bytesAvail >= 0) {
	    bytesToRead = sizeof(TSHeader) - buffer->dataSize;
	    if (bytesToRead > bytesAvail)
		bytesToRead = bytesAvail;
	    readsize = netRead(socket, (void*)&(buffer->header), bytesToRead);
	    if (readsize == -1)
		return(unify(tcb,tcb->args[3],makeint(&tcb->hp, errno)));
	    
	    buffer->dataSize = readsize;
	    bytesAvail -= readsize;

	    /* Check header if we have it all */
	    if (buffer->dataSize == sizeof(TSHeader)) {
		/* Check the encoding */
		if (GetTSEncoding(buffer) != TS_ENCODING)
		    return(unify(tcb,tcb->args[3],makeint(&tcb->hp,  -2)));   /* Unknown encoding -- msg malformed */
		/* See if message is too long */
		if (GetTSLength(buffer) > buffer->bufferSize - 100)
		    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, -1)));	/* Too long. */
	    }
	}
 
	/* We have the header and possibly some of the data. Read as much as needed for current msg. */
	if (bytesAvail == 0)
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, ETIMEDOUT)));	/* incomplete. */

	bytesToRead = GetTSLength(buffer) - buffer->dataSize;
	if (bytesToRead > bytesAvail)
	    bytesToRead = bytesAvail;
	readsize = netRead(socket, (char*)&(buffer->header) + buffer->dataSize, bytesToRead);
 
#ifdef debugTCP 
 printf("\njust read %i bytes, looking for %i",(int) readsize, (int) bytesToRead);
 printf("\ndata: '");
 for (i=0; i <= readsize; ++i)
   printf("%c", buffer->data[i]);
 printf("'\n");
#endif 
 
	if (readsize == -1)
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, errno)));
	buffer->dataSize += readsize;
	
	/* If we still don't have everything, return ETIMEDOUT */
	if (buffer->dataSize != GetTSLength(buffer))
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, ETIMEDOUT)));

	/* Good stuff! The buffer contains exactly one message. Any follow-on
	   messages are still in the socket's buffers.
	   Now we check to ensure that the last byte is a NUL.  If not, then
	   the msg is badly formed. */
 
	if (buffer->data[buffer->dataSize - sizeof(TSHeader) - 1] != 0)
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, -2)));  /* NUL missing. malformed */
	    
	/* Convert the string to a term */
#ifdef debugTCP 
  printf("\n found null at end, buffer->term : buffer = >>%s<< ", buffer->data); 
#endif
	term = BNRP_makeTerm((BNRP_TCB*) tcb, buffer->data);	
	buffer->dataSize = 0;			/* Reset the buffer */
	if (term == 0)
	    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, -2)));  /* string not well-formed term */

	/* All done. Unify the term with argument 2 and zero with argument 3. */
	
	return unify(tcb, tcb->args[3], makeint(&tcb->hp, 0)) && unify(tcb, tcb->args[2], term);
	
    }    
    /* Select timed out. */
    return(unify(tcb,tcb->args[3],makeint(&tcb->hp, ETIMEDOUT)));

}


/*
   BNRP_sendTCPbytes
   ----------------
   Primitive to send a byte stream over a TCP connection.
   Args:
   1> Socket
   2> Length of list
   3> Integer_List
   4> Error  
*/
BNRP_Boolean BNRP_sendTCPbytes(TCB *tcb)
{
   long    socket, message, length;
   FILE   *filep;
   struct  sockaddr_in destination;
   BNRP_sighandler oldSigPipeHandler;
   char   *buffer;                             /* message buffer   */
   long    buffersize;                         /* buffer size      */
   int     readbytes;                          /* bytes read       */
   int     writebytes;                         /* bytes written    */
   int     errorcode;                          /* error code       */
   int     optlen;
   int	   index = 0;
   long    p, orig, result;
   ptr     addr;
   TAG     tag;
   
#ifdef debugTCP
   long    totalsize = 0;
   long    totalbytes= 0;
#endif

   if(tcb->numargs NE 4) return(FALSE);
   if(!BNRPnetworkUseable) return(FALSE);
		
   if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
   if(!FD_ISSET(socket,&BNRPfds))              /* not opened yet ? */
      return(unify(tcb,tcb->args[4],makeint(&tcb->hp,ENOTSOCK)));
   if(!FD_ISSET(socket,&BNRPconnectedFds))     /* not connected ?  */
      return(unify(tcb,tcb->args[4],makeint(&tcb->hp,ENOTCONN)));

   errorcode = 0;

   oldSigPipeHandler = BNRP_installSighandler(SIGPIPE, BNRP_initSighandler(sigPipeHandler));

   /* Is it a list? */
   if(checkArg(tcb->args[3],&message) NE LISTT)
      return(FALSE);
      
   /* Get length of list */
   if(checkArg(tcb->args[2],&length) NE INTT)
      return(FALSE);

#ifdef debugTCP
   printf("\nsendTCPbytes(): Start sending message");
#endif

   /* Check if the send buffer is big enough.  If not resize */
   if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
      buffersize = MAX_MSG_SIZE;          /* default buffer size           */
 
   if (buffersize LE 0)                    /* yanzhou@bnr.ca:20/11/95       */
      buffersize = MAX_MSG_SIZE;
   
   if(buffersize LT length)
   {
      buffersize = length;
      if(setsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT*)&buffersize, (optValSizeT )optlen) NE 0)
	 return unify(tcb, tcb->args[4], makeint(&tcb->hp, ENOMEM));
   }

   /* Alloc a buffer */
    buffer = (char *)BNRP_malloc(buffersize);
    if (buffer EQ 0)
        return unify(tcb, tcb->args[4], makeint(&tcb->hp, ENOMEM));
   
   /* Put bytes from list into buffer */ 
   p = addrof(message);
   derefTV(&p, &orig, &tag, &result, &addr);
   while((tag NE ENDT) && (index < buffersize))
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
      writebytes = write(socket, buffer, length);
   } while ((writebytes EQ -1) && (errno EQ EINTR));
        
   if(writebytes EQ -1)                    /* write failure */
   {
#ifdef debugTCP
      perror("\nsendTCPbytes()");
#endif
      errorcode = errno;
   }
#ifdef debugTCP
   printf("\nsendTCPbytes(): Writing Message.  Wrote %d bytes of %d",
	 writebytes, buffersize);
#endif
    
   BNRP_installSighandler(SIGPIPE, oldSigPipeHandler);
   BNRP_free(buffer);
   return unify(tcb,tcb->args[4],makeint(&tcb->hp, errorcode));
}


/*
   BNRP_receiveTCPbytes
   -------------------
   Primitive to receive a byte stream over a TCP connection.
   Args:
   1> Socket
   2> Count
   3> Integer List
   4> Error
*/
BNRP_Boolean BNRP_receiveTCPbytes(TCB *tcb)
{
   long   socket;
   char * buffer;
   long   buffersize;
   long	  length;
   int    optlen;
   long   readsize  = 0;
   long   filefd;
   int    errorcode = 0;
   long   index    = 0;
   BNRP_Boolean res = TRUE;
   long	  result;
   size_t bytes;
   TAG   tag;
	
   if(tcb->numargs NE 4) return(FALSE);
   if(!BNRPnetworkUseable) return(FALSE);
   if(checkArg(tcb->args[1],&socket) NE INTT) return(FALSE);
   if(socket LT 1) return(FALSE);
   tag = checkArg(tcb->args[2],&length);
   if((tag NE INTT) && (tag NE VART))
      return(FALSE);
   
   if(!FD_ISSET(socket,&BNRPfds))              /* socket not open      */
      return(unify(tcb,tcb->args[4],makeint(&tcb->hp,ENOTSOCK)));
	
   if(!FD_ISSET(socket,&BNRPconnectedFds))     /* socket not connected */
      return(unify(tcb,tcb->args[4],makeint(&tcb->hp,ENOTCONN)));

#ifdef debugTCP
   printf("\nreceivemessageTCP():Check for incoming message");
#endif
    
   /* allocate a buffer of size SO_RCVBUF      */
   optlen = sizeof(buffersize);
   if (getsockopt(socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
      buffersize = MAX_MSG_SIZE;              /* default buffer size  */

   if (buffersize LE 0)                        /* yanzhou@bnr.ca:20/11/95 */
      buffersize = MAX_MSG_SIZE;

   if((tag EQ INTT) && (length < buffersize))
      buffersize = length;

#ifdef debugTCP
   printf("\nreceivemessageTCP(): buffersize = %ld", buffersize);
#endif
   buffer = (char *)BNRP_malloc(buffersize);
   if (buffer EQ 0)
      return unify(tcb, tcb->args[3], makeint(&tcb->hp, ENOMEM));

   /* is the socket readable ?                 */
   if(selectSocket(socket,BNRPread_timer))
   {
#ifdef debugTCP
      printf("\nreceivemessageTCP(): Starting to read message");
#endif
      do {
	 errno = 0;
	 readsize = read(socket, buffer, buffersize);
      } while ((readsize EQ -1) && (errno EQ EINTR));

      if(readsize EQ -1)                      /* Error           */
      {
#ifdef debugTCP
	 perror("\nreceivemessageTCP()");
#endif
	 errorcode = errno;
      }

      if(readsize EQ 0)                       /* Read nothing    */
      {
#ifdef debugTCP
	 printf("\nreceivemessageTCP(): read returned 0");
#endif
	 errorcode = ENOTCONN;
      }
   } else {
#ifdef debugTCP
      printf("\nreceivemessageTCP(): Nothing to be read");
#endif
      errorcode = ETIMEDOUT;                  /* select time out */
   }

#ifdef debugTCP
    printf("\nreceivemessageTCP(): Read %d bytes", readsize);
#endif

   if (!errorcode) {                           /* receive succeeded */

      heapcheck(readsize+1);
      result = maketerm(LISTTAG, tcb->hp);
      while(readsize > index)
      {
	 push(long,tcb->hp,makeintterm((unsigned char)buffer[index])); 
	 index++;
      }
      push(long,tcb->hp,0);
      
   }
   else 
   {
      BNRP_free(buffer);
      return unify(tcb, tcb->args[4], makeint(&tcb->hp, errorcode));
   }      
      
   if(tag EQ VART)
      res = unify(tcb,tcb->args[2],makeint(&tcb->hp,readsize));
    
    BNRP_free(buffer);
    return res && unify(tcb,tcb->args[3],result) && unify(tcb, tcb->args[4], makeint(&tcb->hp, errorcode));
}








#endif
