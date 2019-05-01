/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/network.h,v 1.9 1998/03/26 15:55:20 csavage Exp $
*
*  $Log: network.h,v $
 * Revision 1.9  1998/03/26  15:55:20  csavage
 * Updated and added typedefs for changes in AIX 4.2.1
 *
 * Revision 1.8  1998/01/20  15:34:08  thawker
 * Defined fd_setT type, used to cast arguments in calls to select(),
 * which requires fd_set* on hpux 10 and solaris, int* otherwise.
 * Defined optValT type, used to cast arguments in calls to
 * get/setsockopts(), which require char* on solaris, void* otherwise.
 * Variables should not be declared as either of these types.
 *
 * Revision 1.7  1996/05/20  16:48:27  neilj
 * Added interfaces for BNRP_GetSocketBuffer and BNRP_GetNetScratchBuffer.
 * Also added data type for Term Stream buffers (TSBuffer), along with
 * some macros for manipulating the buffer header.
 *
 * Revision 1.6  1995/12/12  14:21:48  yanzhou
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
 * Revision 1.5  1995/12/04  00:10:19  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.4  1995/10/25  16:00:33  yanzhou
 * Function prototype for selectSocket().
 *
 * Revision 1.3  1995/10/23  16:04:36  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.2  1995/10/19  14:28:06  harrisja
 * Overhaul of networking primitives to support UDP and to remove internal message buffering.
 * Now contains the generic networking predicates and support
 *
 * Revision 1.1  1995/09/22  11:25:27  harrisja
 * Initial version.
 *
*
*/
#ifdef unix
#ifndef _H_network
#define _H_network

#define	 MAX_MSG_SIZE	8192
#include <sys/types.h>
#ifdef _AIX
#include <sys/select.h>
#endif
extern fd_set BNRPfds, BNRPconnectedFds;
extern fp     BNRPread_timer, BNRPconnect_timer;
extern int    BNRPfdCount;
extern BNRP_Boolean   BNRPnetworkUseable;
extern unsigned short BNRPlowestPort;

void sigPipeHandler(int signo);
int selectSocket(int socket, fp timeout);
int selectSocketForWrite(int socket, fp timeout);

BNRP_Boolean BNRP_closesocket(TCB *tcb);
BNRP_Boolean BNRP_netname(TCB *tcb);
BNRP_Boolean BNRP_networkConfiguration(TCB *tcb);
BNRP_Boolean BNRP_setsocketopt(TCB *tcb);

int enableNONBLOCK(int fd);
int disableNONBLOCK(int fd);

/*
    Prolog terms over TCP support routines and types.
*/

typedef unsigned long TSHeader;			/* Header for Term streams message (4 bytes) */

#if defined hpux_10 || defined solaris || defined OS_AIX_4_2
typedef fd_set fd_setT;				/* (fd_setT *) cast is made in calls to select  */
#else
typedef int fd_setT;
#endif

#ifdef solaris
typedef char optValT;				/* (optValT *) cast is made in calls to get/setsockopt */
#else
typedef long optValT;
#endif

#ifdef OS_AIX_4_2				/* (optValSizeT *) cast is made in calls to get/setsockopt */
typedef unsigned long optValSizeT;
#else
typedef int optValSizeT;
#endif

struct TSBuffer {
    size_t	bufferSize;			/* The total size of the header + data array */
    size_t	dataSize;			/* The number of bytes read so far */
    TSHeader	header;				/* The TS header bytes */
    char	data[4];			/* The actual data bytes */
};
typedef struct TSBuffer TSBuffer;

/* Term Stream protocol header manipulation macros */
#include <netinet/in.h>
#define TS_ENCODING		0x01000000	/* Currently supported encoding */
#define TS_ENCODING_MASK	0xFF000000	/* Mask for the encoding */
#define TS_LENGTH_MASK		0x00FFFFFF
#define BuildTSHeader(buffer) ((buffer)->header = htonl((buffer)->dataSize) + TS_ENCODING)
#define GetTSEncoding(buffer) (ntohl((buffer)->header) & TS_ENCODING_MASK)
#define GetTSLength(buffer) (ntohl((buffer)->header) & TS_LENGTH_MASK)

/* Routines for getting buffers */
TSBuffer* BNRP_GetSocketBuffer(int socket);
TSBuffer* BNRP_GetNetScratchBuffer(size_t size);

#endif
#endif

