#if 0
----------------------------------------------------------------------
> Global Function: BNRP_opensocketTCP ;
  $ BNRP_BooleanBNRP_opensocketTCP (TCB*)
> Purpose:
  | This primitive opens a TCP socket and binds it to a port.  It takes two arguments: port number and the socket descriptor.  The second arguement is instantiated by the system.  If the port number is a variable, the system allocates one, by scanning from BNRPlowest_port upwards for a port number it can bind to.  This primitive sets TCP_NODELAY on the socket as well.  If this is the first socket being opened, it zeros out the BNRPfds and BNRPconnectedFds file descriptor sets.
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
> Global Function: BNRP_listenSocket ;
  $ BNRP_BooleanBNRP_listenSocket (TCB*)
> Purpose:
  | This primitive has two arguments.  The first is the socket descriptor onto which a listen() is to be performed.  The second is instantiated to the errno value returned from listen().
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
> Global Function: BNRP_acceptCon ;
  $ BNRP_BooleanBNRP_acceptCon (TCB*)
> Purpose:
  | This primitive accepts a connection on a passive TCP socket.  It has 5 arguments: socket descriptor, foreign host IP, foreign host port number, new socket descriptor associated with the newly established connection and the error value returned from the accept call.  Everything except for the first argument is filled in by the primitive.  The primitive first uses selectSocket() BNRPconnect_timer as the default value. If it times out before a connection request arrives, only the error number arguement gets instantiated.
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
> Global Function: BNRP_receivemessageTCP ;
  $ BNRP_BooleanBNRP_receivemessageTCP (TCB*)
> Purpose:
  | This primitive attemps to read a message from a TCP connection.  It has 3 arguements: socket descriptor, message and error.  It first checks to see if the socket descriptor is connected and then performs a selectSocket with a timeout value of BNRPread_timer to see if the socket is ready to be read.  If it is, then the message is read and unified with the second argument and the third is set to zero.  If an error occurs or if the socket is not ready to be read, then then error is instantiated to be an errno value.  If the second argumeent is an integer, then it is presumed to be a FILE pointer and the message is read into that file.
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
> Global Function: BNRP_makeCon ;
  $ BNRP_BooleanBNRP_makeCon (TCB*)
> Purpose:
  | This primitive attempts to make a connection to a foreign passive TCP socket.  It has four arguments: socket descriptor, foreign host IP, foreign host port number, and an error value.  The error value is unified with zero on success otherwise it is an errno from errno.h.  Ifthe socket is already connected an EISCONN error is returned.
  | 
  | The make-connection operation is carried out in 4 steps:
  |   1.   put the socket to non-blocking I/O mode.
  |   2.   issue a connect() operation on the socket, which tells the OS to start the connection       operation.
  |   3.   put the socket back to blocking I/O mode
  |   4.   select the socket for writing while the connect() is in progress.
  | 
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
> Global Function: BNRP_sendmessageTCP ;
  $ BNRP_sendmessageTCP (TCB*)
> Purpose:
  | This primitive sends a message on a TCP connection.  It has three arguments which are: socket descriptor, message, and error.  Error is instantiated by the primitive.  The second arguement is either the message to be sent or a FILE pointer.  If it is a FILE pointer, the file is read and sent in chunks equal to the size of the send socket's buffer.  The write operation is restarted if it interupted.
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
#if 0
----------------------------------------------------------------------
> Macro: INADDR_NONE
  $ #define INADDR_NONE
> Purpose
  | [Purpose]
----------------------------------------------------------------------
#endif
