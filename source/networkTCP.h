/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/networkTCP.h,v 1.3 1998/03/31 11:18:28 csavage Exp $
*
*  $Log: networkTCP.h,v $
 * Revision 1.3  1998/03/31  11:18:28  csavage
 * created interfaces for BNRP_ send/receive TCPbytes
 *
 * Revision 1.2  1996/05/20  16:51:56  neilj
 * Added interfaces for BNRP_sendTCPterm and BNRP_receiveTCPterm.
 *
 * Revision 1.1  1995/10/19  14:25:25  harrisja
 * Initial version
 *
*
*/


#ifdef unix
#ifndef _H_networkTCP
#define _H_networkTCP

BNRP_Boolean BNRP_opensocketTCP(TCB *tcb);
BNRP_Boolean BNRP_acceptCon(TCB *tcb);
BNRP_Boolean BNRP_makeCon(TCB *tcb);
BNRP_Boolean BNRP_listenSocket(TCB *tcb);
BNRP_Boolean BNRP_sendmessageTCP(TCB *tcb);
BNRP_Boolean BNRP_receivemessageTCP(TCB *tcb);
BNRP_Boolean BNRP_sendTCPterm(TCB *tcb);
BNRP_Boolean BNRP_receiveTCPterm(TCB *tcb);
BNRP_Boolean BNRP_sendTCPbytes(TCB *tcb);
BNRP_Boolean BNRP_receiveTCPbytes(TCB *tcb);

#endif
#endif
