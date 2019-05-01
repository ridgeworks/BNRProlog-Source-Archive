#if 0
----------------------------------------------------------------------
> Global Function: BNRP_opensocketUDP ;
  $ BNRP_BooleanBNRP_opensocketUDP (TCB*)
> Purpose:
  | This primitive creates and binds a UDP socket.  It has two arguements.  The first is the port number to bind to and the second is the socket descriptor.  The second arguement is instantiated by the primitive if it successfull. If the port number has not been instantiated, then the primitive tries to bind to
  | a port number greater than or equal to BNRPlowest_port.  It tries each port number until it finds one it can bind to.  If the port number is instantiated, then it makes one attempt to bind to that port.  If it can't then FALSE is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_receivemessageUDP ;
  $ BNRP_BooleanBNRP_receivemessageUDP (TCB*)
> Purpose:
  | This primitive sends a message on a UDP socket.  It has 5 parameters which are: socket descriptor, foreign host IP, foreign host port number, message and error.  Error and foreign host address are instantiated by the primitive.  If the message is an integer it is presumed to be a FILE pointer and the incoming message is read into the file.  Before a read is attempted, a selectSocket is done with a timeout value of BNRPread_timer.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_sendmessageUDP ;
  $ BNRP_sendmessageUDP (TCB*)
> Purpose:
  | This primitive sends a message on a UDP socket to a nominated destination.  It takes 5 parameters which are: socket descriptor, foreign host IP, foreign host port number, message and error.  The erro parameter is filled in by the primitive.  Foreign host IP and port number is the destination of the message.  If the message parameter is an integer it is presumed to be a FILE pointer.  In this case, the file is read and chunks sent (equal to the size of the socket's send buffer) until an error reading the file occurs or until we reach EOF.
> Calling Context:
  | 
> Return Value:
  | No return value...
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
