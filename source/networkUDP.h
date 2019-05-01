/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/networkUDP.h,v 1.2 1998/03/31 11:19:06 csavage Exp $
*
*  $Log: networkUDP.h,v $
 * Revision 1.2  1998/03/31  11:19:06  csavage
 * created interfaces for BNRP_ send/receive UDPbytes
 *
 * Revision 1.1  1995/10/19  14:24:55  harrisja
 * Initial version
 *
*
*/

#ifdef unix
#ifndef _H_networkUDP
#define _H_networkUDP

BNRP_Boolean BNRP_opensocketUDP(TCB *tcb);
BNRP_Boolean BNRP_sendmessageUDP(TCB *tcb);
BNRP_Boolean BNRP_receivemessageUDP(TCB *tcb);
BNRP_Boolean BNRP_sendUDPbytes(TCB *tcb);
BNRP_Boolean BNRP_receiveUDPbytes(TCB *tcb);

#endif
#endif
