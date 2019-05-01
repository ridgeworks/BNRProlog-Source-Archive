/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/network.c,v 1.18 1998/03/26 15:54:38 csavage Exp $
*
*  $Log: network.c,v $
 * Revision 1.18  1998/03/26  15:54:38  csavage
 * Updated typedefs for changes in AIX 4.2.1
 *
 * Revision 1.17  1998/01/20  15:26:01  thawker
 * Changed calls to get/setsockopts to cast using (optValT *), which
 * is defined in network.h according to platform
 * Changed calls to select to cast using (fd_setT *), which is defined
 * in network.h according to platform
 *
 * Revision 1.16  1997/02/27  17:17:52  harrisj
 * On HPUX 10.10 the select() call requires fd_set * instead of int *.
 * Conditionally compile to use the former if hpux_10 is defined
 *
 * Revision 1.15  1996/07/05  10:52:06  yanzhou
 * Bug fix in BNRP_netname:
 *   the variable "result" was referenced without
 *   being initialized.
 *
 * Revision 1.14  1996/05/20  16:46:58  neilj
 * Added the following utility routines:
 *   BNRP_GetNetScratchBuffer
 *   BNRP_GetSocketBuffer
 * These are used to implement sendTCPterm and receiveTCPterm.
 * Also modified BNRP_setsocketopt to change internal socket buffer size.
 * Also modified closesocket to free internal socket buffer.
 *
 * Revision 1.13  1995/12/12  14:21:46  yanzhou
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
 * Revision 1.12  1995/12/04  00:10:18  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.11  1995/11/16  14:26:17  yanzhou
 * BNRP_closesocket() changed to take care of EINTR.
 *
 * Revision 1.10  1995/11/10  14:22:15  yanzhou
 * Added definition for INADDR_NONE, which is not defined on SunOS 4.1.3.
 *
 * Revision 1.9  1995/10/25  15:59:58  yanzhou
 * #include <math.h> for modf().
 *
 * Revision 1.8  1995/10/25  11:57:24  yanzhou
 * negative read_timer/connect_timer values now cause read/connect to be blocking.
 *
 * Revision 1.7  1995/10/23  16:41:33  harrisja
 * Fix to BNRP_setsocketopt() to return errno
 *
 * Revision 1.6  1995/10/23  16:04:34  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.5  1995/10/19  15:50:30  harrisja
 * networkConfiguration() bug -- was looking for 5 arguements instead of 3!
 *
 * Revision 1.4  1995/10/19  14:28:57  harrisja
 * Revamped to support UDP and to remove internal message buffering.
 * File now contains the generic networking primitives and support functions
 *
 * Revision 1.3  1995/10/06  17:14:31  harrisja
 * *** empty log message ***
 *
 * Revision 1.2  1995/10/06  10:36:37  harrisja
 * Use BNRP_sigStruct for SIGALRM handling.
 *
 * Revision 1.1  1995/09/22  11:25:25  harrisja
 * Initial version.
 *
*
*/
/*  Networking code for BNR Prolog  

Notes:  Currently not ported to Mac, Solaris, and Delta Worksation

Log:

Originally written by Jason Harris July-Aug 1994

Feb. 1995 - save old signal handlers before enstating our own and
            reinstate the old handler when done.
          - no longer use alarm() to prevent blocking on reads and
            connects.  Alarm() was clobbering the timer used by
            sleep/delay.  Save the old timer values and reinstate
            them when done.  If the current timer value is less
            than our value, then execute the old SIGALRM handler
            once.
          - Maximum message length is increased to 8K.  This is 
            defined in the header file and can be modified.  The
            send and receive buffers of the sockets are set to this
            value.  If this can't be allocated then report it to the 
            user and fail.
          - values passed in by openport/1 are checked to make sure
            they are less than the maximum value of unsigned short.
            The minimum port value passed in by networkconfig/5 is
            also checked.

Mar. 1995 - use signal() instead of sigvector() on HP for SIGALRM.  System
            calls wake up for signals on HP.
          - add support for NAV m88k.
          - if a read() or a write() get interupted before they read/write any data 
            then restart then unless the interupt is due to a SIGALRM.
          - BNRP_receivemessage could lose messages, so instead of turning off our
            handler and re-establishing it after we are done, we now block the
            signal temporarily.
          - Use sigaction() with SIGIO so that the other SIGIO's that occur during
            execution of the handler will be blocked.  With signal() the default 
            handler (which is SIG_IGN) would be re-established, hence we would
            ignore incoming messages that occured while handling a previous one.
          - TCP/IP does not guarantee atomic reads so keep on reading from a port
            until we receive a complete message or we time out, which ever comes
            first

Aug. 1995 - Added support for raw messages.  A raw message is defined as a message
            that does not use the BNRPmessage format.  We do a single read on the
            port and whatever bytes we receive is the message that we report to 
            Prolog.  To support this, openport, and closeport were modified.  
            In addition a version of sendmessage and netsendTCP were made
            specifically for raw messages.
          - Can now have both a Prolog port and a raw port opened.  Receivemessage
            was modified to distinguish between raw messages and Prolog messages
            in the queue.  sigHandler was modified to call the correct message
            processing function.
 Oct. 1995 - Wasn't reseting SIGALRM properly which caused conflicts with enable_timer
	  Now using BNRP_sigStruct. 
	  - Major overhaul of networking code and paradigm.  No longer buffering
	  messages internally.  UDP support has been added.  Support for sending
	  Prolog terms has been removed.  It is now up to the application to convert
	  the symbol into a term if need be.  Added predicates for establishing
	  connections and listening for connections.  Allowed to have multiple
	  ports opened.  A lot of error checking has been removed from returned
	  system calls such as write, and read.   The error codes are returned to
	  the application so that it can decide what to do.      

 Dec. 1995 - yanzhou@bnr.ca: Was using SIGALRM to handle connect()
      time-outs. Now changed to use non-blocking I/O (O_NONBLOCK) and
      select().
       
*/

#include "BNRProlog.h"
#include "base.h"
 
#ifdef supportNetworking /* set in base.h */
#include "core.h"
#include "hardware.h"
#include "network.h"

#include <sys/time.h>    /* timeval structure */
#include <sys/socket.h>
#include <netinet/in.h>  /* inet_ntoa() */
#ifndef INADDR_NONE      /* not defined on SunOS 4.1.3 */
#define INADDR_NONE ((unsigned long) 0xFFFFFFFF)
#endif
#include <netdb.h>       /* gethostbyname(), gethostbyaddr() */
#include <errno.h>       /* errno */
#include <string.h>      /* strcat(), strncpy */
#include <sys/param.h>   /* MAXHOSTNAMELEN definition */
#include <limits.h>      /* USHRT_MAX */
#include <math.h>        /* for modf() */
#include <fcntl.h>       /* for fcntl() */
#include <stdlib.h>

/* #define DEBUG			/* Enable debug messages */


static struct itimerval oldItimer;
fd_set                  BNRPfds, BNRPconnectedFds;
fp                      BNRPread_timer = 5.0, BNRPconnect_timer = 5.0;
int                     BNRPfdCount = 0;
BNRP_Boolean            BNRPnetworkUseable;
unsigned short          BNRPlowestPort = 1050;

#include "network.h"

void sigPipeHandler(int signo) /* SIGPIPE handler used when writing to a socket */
{
#ifdef DEBUG
	printf("\nsigPipeHandler(): Received SIGPIPE\n");
#endif
}

/*
    ensureBufferSize
    ----------------
    Make sure the specified buffer can hold a message of at least the
    specified size. It retains the contents of any previous buffer.
*/
static BNRP_Boolean ensureBufferSize(TSBuffer** bufferP, size_t size)
{
    TSBuffer*	newBufferP;

    if (*bufferP == 0 || (*bufferP)->bufferSize < size) {
	/* realloc works like malloc if old ptr is NULL */
	newBufferP = (TSBuffer*) BNRP_realloc(*bufferP, sizeof(TSBuffer) + size);
	if (newBufferP == 0)
	    return FALSE;
	if (*bufferP == 0)
	    newBufferP->dataSize = 0;	/* init this for new buffers */
	*bufferP = newBufferP;
	(*bufferP)->bufferSize = size;
    }
    return TRUE;
}


/*
    BNRP_GetNetScratchBuffer
    ------------------------
    Returns the scratch buffer, ensuring it is at least the specified size.
*/
TSBuffer* BNRP_GetNetScratchBuffer(size_t requiredSize)
{
    static TSBuffer *scratchBuffer = 0;	/* The scratch buffer */

    if (ensureBufferSize(&scratchBuffer, requiredSize)) {
	scratchBuffer->dataSize = 0;
	return scratchBuffer;
    } else
	return 0;
}

/* The following static vars are used to contain the list of TSBuffers
    that are available for reading term streams.
*/
#define kBufferSlop 30		/* number of extras to allocate */
static int pHighTSBufferNumber = 0;
static TSBuffer** pTSBuffers = 0;


/*
    getSocketBufferP
    ----------------
    Returns a pointer to the slot where the specified socket's buffer pointer
    should live.
*/
static TSBuffer** getSocketBufferP(int socket)
{
    int newHigh;
    TSBuffer** newBuffers;
    int i;

    /* Ensure there is at least a pointer for this one. */
    if (socket > pHighTSBufferNumber) {
	newHigh = socket + kBufferSlop;
	newBuffers = (TSBuffer **) BNRP_realloc(pTSBuffers, sizeof(TSBuffer*) * newHigh);
	if (newBuffers == 0)
	    return 0;
	pTSBuffers = newBuffers;
	for (i = pHighTSBufferNumber; i < newHigh; i++)
	    pTSBuffers[i] = 0;
	pHighTSBufferNumber = newHigh;
    }
    return &(pTSBuffers[socket - 1]);
}


/*
    resizeSocketBuffer
    ------------------
    This routine changes the size of a socket buffer to the size of
    the current send buffer. The current contents are retained.
*/
static void resizeSocketBuffer(int socket, TSBuffer** bufferP)
{
    long    buffersize;                         /* buffer size      */
    int     optlen;

    /* allocate a buffer of size SO_SNDBUF  */
    optlen = sizeof(buffersize);
    if (getsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&buffersize, (optValSizeT *)&optlen) NE 0)
	buffersize = MAX_MSG_SIZE;          /* default buffer size           */
    if (buffersize LE 0)
	buffersize = MAX_MSG_SIZE;
    buffersize += 100;  		/* 100 is slop needed in BNRP_termToString */
    ensureBufferSize(bufferP, buffersize);
}


/*
    BNRP_GetSocketBuffer
    --------------------
    Returns the buffer associated with the specified socket.
*/
TSBuffer* BNRP_GetSocketBuffer(int socket)
{
    TSBuffer** bufferP = getSocketBufferP(socket);
    
    if (bufferP == 0)
	return 0;
    if (*bufferP == 0)
	resizeSocketBuffer(socket, bufferP);
    return *bufferP;
}




BNRP_Boolean BNRP_closesocket(TCB *tcb)
{
    long fd;

    if(tcb->numargs NE 1) return(FALSE);
    if(checkArg(tcb->args[1],&fd) NE INTT) return(FALSE);
	if(!FD_ISSET(fd,&BNRPfds)) return(FALSE);
	if(fd LT 1) return(FALSE);

    /* close the socket */
    do {
    } while ((close(fd) EQ -1) && (errno EQ EINTR));

	FD_CLR(fd,&BNRPfds);
	FD_CLR(fd,&BNRPconnectedFds);
    BNRPfdCount --;

    if (BNRPfdCount LE 0) {
        BNRPfdCount = 0;
        BNRPnetworkUseable = FALSE;
    }

    /* Free the socket buffer if it exists. */
    if (fd <= pHighTSBufferNumber) {
	TSBuffer** bufferP = getSocketBufferP(fd);
	if (*bufferP) {
	    BNRP_free(*bufferP);
	    *bufferP = 0;
	}
    }

    return(TRUE);
}

/*
 * $setsocketopt(-Error, +Socket, +Option, +Value)
 *   examples:
 *     $setsocketopt(Error, 3, so_sndbuf, 16384)
 *     $setsocketopt(Error, 3, so_rcvbuf, 16384)
 */
BNRP_Boolean BNRP_setsocketopt(TCB *tcb)
{
    long socket;
    long option;
    long value;
    long error = 0;

    /* $setsocketopt/4 */
    if(tcb->numargs NE 4) return(FALSE);

    /* +Socket         */
    if(checkArg(tcb->args[2],&socket) NE INTT) return(FALSE);
	if(!FD_ISSET(socket,&BNRPfds)) return(FALSE);
	if(socket LT 1) return(FALSE);

    /* +Option         */
    if (checkArg(tcb->args[3], &option) NE SYMBOLT) return (FALSE);

    /* so_sndbuf       */
    if (strcmp(nameof(option), "so_sndbuf") == 0) {
        if (checkArg(tcb->args[4], &value) NE INTT) return (FALSE);
        if (value LE 0) return (FALSE);

	errno = 0;
	error = setsockopt(socket, SOL_SOCKET, SO_SNDBUF, (optValT *)&value, sizeof(value));
    }
    else
    /* so_rcvbuf       */
    if (strcmp(nameof(option), "so_rcvbuf") == 0) {
        if (checkArg(tcb->args[4], &value) NE INTT) return (FALSE);
        if (value LE 0) return (FALSE);

	errno = 0;
	error = setsockopt(socket, SOL_SOCKET, SO_RCVBUF, (optValT *)&value, sizeof(value));
        if (error != -1) {
	    /* Resize the socket receive buffer if necessary. */
	    if (socket <= pHighTSBufferNumber) {
		TSBuffer** bufferP = getSocketBufferP(socket);
		if (*bufferP) { /* only resize if already exists */
		    /* Ignore the buffer size change if it fails */
		    ensureBufferSize(bufferP, value + 100);
		}
	    }
	}
    }
    else
        return FALSE;

    return unify(tcb, tcb->args[1], makeint(&tcb->hp, errno));
}


BNRP_Boolean BNRP_netname(TCB *tcb)
{
    long name, ipaddress;
    char * machine, * chaddr;
    struct hostent * hostentry;
    struct sockaddr_in address;

    if(tcb->numargs NE 2) return(FALSE);

    switch(checkArg(tcb->args[1],&name))
    {
    case SYMBOLT:
    {
        struct in_addr * addr;
        machine = nameof(name);
        hostentry = gethostbyname(machine);     /* Lookup host name */
        if(hostentry EQ NULL) return(FALSE);
        switch(checkArg(tcb->args[2],&ipaddress))
        {
        case SYMBOLT:
            machine = nameof(ipaddress);
            if(inet_addr(machine) EQ INADDR_NONE) return(FALSE);    /* If not an IP address fail */
            while((addr = (struct in_addr *)*hostentry->h_addr_list++) NE NULL)
            {
                chaddr = (char *)inet_ntoa(*addr);
                if(strcmp(chaddr,machine) EQ 0) return(TRUE);
            }
            return(FALSE);
        case VART:
            chaddr = (char *)inet_ntoa(*(struct in_addr *)hostentry->h_addr);
            return(unify(tcb,tcb->args[2],BNRPLookupTempSymbol(tcb,chaddr)));
        default:
            return(FALSE);
        }
    }
    case VART:
    {
        BNRP_Boolean result = TRUE;
        switch(checkArg(tcb->args[2],&ipaddress))
        {
        case SYMBOLT:
            address.sin_addr.s_addr = inet_addr(nameof(ipaddress));
            if(address.sin_addr.s_addr EQ INADDR_NONE) return(FALSE);  /*If not an IP address fail */
            hostentry = gethostbyaddr((char *)&address.sin_addr,sizeof(address.sin_addr),AF_INET);
            if(hostentry EQ NULL) return(FALSE);

            break;
        case VART:
            machine = (char *)BNRP_malloc(MAXHOSTNAMELEN + 1);
            gethostname(machine,MAXHOSTNAMELEN);
            hostentry = gethostbyname(machine);     /* Lookup host name */
            BNRP_free(machine);
            if(hostentry EQ NULL) return(FALSE);
            chaddr = (char *)inet_ntoa(*(struct in_addr *)hostentry->h_addr);
            result = unify(tcb,tcb->args[2],BNRPLookupTempSymbol(tcb,chaddr));
            break;
        default:
            return(FALSE);
        }
        return(result && unify(tcb,tcb->args[1],BNRPLookupTempSymbol(tcb,hostentry->h_name)));
    }
    default:
        return(FALSE);
    }
}

BNRP_Boolean BNRP_networkConfiguration(TCB *tcb)
{
    long port, read_delay, connect_delay;
	fd_set tempfds = BNRPfds;

    if(tcb->numargs NE 3) return(FALSE);
    switch(checkArg(tcb->args[1],&port))
    {
    case INTT:
        /* Ports below 1024 are reserved.  Port can't be greater
           than the type for the port attribute of the socket address (u_short) 
           BUT as root, the user could access ports 1 .. 1023*/
        if((port LT 0) || (port GT USHRT_MAX)) return(FALSE);
        BNRPlowestPort = port;
        break;
    case VART:
        if(unify(tcb,tcb->args[1],makeint(&tcb->hp,BNRPlowestPort)) EQ FALSE) return(FALSE);
        break;
    default:
        return(FALSE);
    }
    switch(checkArg(tcb->args[2],&read_delay))
    {
    case INTT:
        /* yanzhou@bnr.ca:24/10/95: negative value now means blocking read */
        BNRPread_timer = read_delay;
        break;
    case FLOATT:
        /* yanzhou@bnr.ca:24/10/95: negative value now means blocking read */
        BNRPread_timer = *(fp *)read_delay;
        break;
    case VART:
        if(unify(tcb,tcb->args[2],makefloat(&tcb->hp,&BNRPread_timer)) EQ FALSE) return(FALSE);
        break;
    default:
        return(FALSE);
    }
    switch(checkArg(tcb->args[3],&connect_delay))
    {
    case INTT:
        /* yanzhou@bnr.ca:24/10/95: negative value now means blocking connect */
        BNRPconnect_timer = connect_delay;
        break;
    case FLOATT:
        /* yanzhou@bnr.ca:24/10/95: negative value now means blocking connect */
        BNRPconnect_timer = *(fp *)connect_delay;
        break;
    case VART:
        if(unify(tcb,tcb->args[3],makefloat(&tcb->hp,&BNRPconnect_timer)) EQ FALSE) return(FALSE);
        break;
    default:
        return(FALSE);
    }
			
    return(TRUE);
}

int selectSocket(int socket, fp timeout)
{
	fd_set readfd;
	fp secs,usecs;
	struct timeval tm;

	FD_ZERO(&readfd);
	FD_SET(socket, &readfd);
	
    /*
     * yanzhou@bnr.ca:24/10/95:
     * negative timeout value now means blocking select
     */
    if (timeout < 0.0) {
	return select(socket + 1, (fd_setT *)&readfd,
		 (fd_setT *)NULL, (fd_setT *)NULL, (struct timeval *)NULL);
    }

	usecs = modf(timeout,&secs);
	tm.tv_sec = (long)secs;
	tm.tv_usec = (long)(usecs * 1000000.0);

	return select(socket + 1, (fd_setT *)&readfd, 
		(fd_setT *)NULL, (fd_setT *)NULL, &tm);

}

int selectSocketForWrite(int socket, fp timeout)
{
	fd_set         writefd;
	fp             secs, usecs;
	struct timeval tm;

	FD_ZERO(&writefd);
	FD_SET(socket,&writefd);
	
    if (timeout < 0.0) {
        return select(socket + 1, (fd_setT *)NULL,
		     (fd_setT *)&writefd, (fd_setT *)NULL, (struct timeval *)NULL);
    }

	usecs = modf(timeout,&secs);
	tm.tv_sec = (long)secs;
	tm.tv_usec = (long)(usecs * 1000000.0);

       return select(socket + 1,
                   (fd_setT *)NULL, (fd_setT *)&writefd, (fd_setT *)NULL, &tm);
}

int enableNONBLOCK(int fd)
{
    int flags;

    flags = fcntl(fd, F_GETFL, 0);

    if (flags NE -1)
        return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
    else
        return -1;
}

int disableNONBLOCK(int fd)
{
    int flags;

    flags = fcntl(fd, F_GETFL, 0);

    if (flags NE -1)
        return fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);
    else 
        return -1;
}

#endif
 
