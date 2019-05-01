#if 0
----------------------------------------------------------------------
> Global Function: sigPipeHandler ;
  $ voidsigPipeHandler ()
> Purpose:
  | This is a signale handler for catching SIGPIPE's generated from writing to a broken connection.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Global Function: sigAlarmHandler ;
  $ voidsigAlarmHandler ()
> Purpose:
  | Used to catch SIGALRM signals generated due to timeouts set in setSigAlarmHandler().  Sets BNRPalarm to true.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
> Global Function: selectSocket ;
  $ intselectSocket (int, fp)
> Purpose:
  | This checks to see if socket is ready to be read from.  If timeout is zero, a polling action is performed.  If it is negative, then it blocks until there is something to be read from the socket.
> Calling Context:
  | 
> Return Value:
  | int - This is zero if the socket is not ready for reading, or one if it is ready to be read.
> Parameters:
  = int socket - socket descriptor
  = fp timeout -time out value in seconds.
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
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Global Function: setSigAlarmHandler ;
  $ intsetSigAlarmHandler (fp*)
> Purpose:
  | Sets up an alarm clock to go off after time seconds.  Saves the old timer information and SIGALRM handler to be restored later.
> Calling Context:
  | 
> Return Value:
  | int - Returns 0 on success
> Parameters:
  = fp* time - Number of seconds to set the timer to.
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
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Global Function: resetSigAlarmHandler ;
  $ voidresetSigAlarmHandler ()
> Purpose:
  | Resets the SIGALRM handler to be the SIGALRM handler that was installed prior to the call to setSigAlarmHandler.  It also resets the timer value to be the old timeout value (if a timer was previously installed).
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
> Global Function: BNRP_closesocket ;
  $ BNRP_BooleanBNRP_closesocket (TCB*)
> Purpose:
  | This primitive givan a socket descriptor, attempts to close the socket and removes the socket from the set of open sockets.  Fails if the socket descriptor is invalid or if an attempt to close the 0 socket descriptor is made.
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
> Global Function: BNRP_setsocketopt ;
  $ BNRP_BooleanBNRP_setsocketopt (TCB*)
> Purpose:
  | This primitive sets socket level options for a given socket.  It has three parameters: socket descriptor, option name, and value to set the option to.  At the moment it only supports the SO_RCVBUF and SO_SNDBUF options.
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
> Global Function: BNRP_netname ;
  $ BNRP_BooleanBNRP_netname (TCB*)
> Purpose:
  | This primitive looks up IP and host names.  The first parameter is the host name and the second is the IP address.  Both parameters are either symbols or variables.  If they are both variables, then the host name and address of the current host is returned.  Otherwise either the host name or address (whichever is instantiated) is looked up to get the other piece of information.
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
> Global Function: BNRP_networkConfiguration ;
  $ BNRP_BooleanBNRP_networkConfiguration (TCB*)
> Purpose:
  | This primitive sets the BNRPlowest_port, BNRPread_timer, and BNRPconnect_timer default values.  It takes three arguemtents: lowest port number, read_timer value in seconds and connect timer value in seconds.  If any of these are variables, thenthat value is queried and returned.
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
> Data Item: oldItimer
  $ itimerval oldItimer
> Purpose:
  | Structure to keep the old timer value.  Used by (re)setSigAlarmHandler() to save and reestablish old timer values.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Data Item: oldSigAlarmStruct
  $ BNRP_sigStruct oldSigAlarmStruct
> Purpose:
  | Structure to keep the old SIGALRM handler.  This is used by (re)setSigAlarmHandler() to save and reestablish old SIGALRM handlers.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPfds
  $ fd_set BNRPfds
> Purpose:
  | The fd_set of currently open socket descriptors.  This includes socket
  | descriptors created by an accept() call.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPconnectedFds
  $ fd_set BNRPconnectedFds
> Purpose:
  | The fd set of connected TCP socket descriptors.  Used in BNRP_receiveTCP() and BNRP_sendTCP() functions to determine if the given socket descriptor is connected.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPread_timer
  $ fp BNRPread_timer
> Purpose:
  | Default timeout value in seconds for an attempt to read from a socket.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPconnect_timer
  $ fp BNRPconnect_timer
> Purpose:
  | The default timeout value for connection attempts, whether they be attempts to accept a connection or make a connection.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPfdCount
  $ int BNRPfdCount
> Purpose:
  | The number of socket descriptors that the application has open.  This is used to determine whether or not the network is useable.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPnetworkUseable
  $ BNRP_Boolean BNRPnetworkUseable
> Purpose:
  | XXXXX_D_PUR
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#ifdef OBSOLETE_TEMPLATE
----------------------------------------------------------------------
> Data Item: BNRPalarm
  $ BNRP_Boolean BNRPalarm
> Purpose:
  | This is set when a SIGALRM is caught by sigAlarmHandler().  Used to indicate that a timeout occured.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPlowestPort
  $ unsigned short BNRPlowestPort
> Purpose:
  | Default value for the lowest port number that can be bound to.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_network
  $ #define _H_network
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_MSG_SIZE
  $ #define MAX_MSG_SIZE
> Purpose:
  | Maximum size in bytes of a message.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: selectSocketForWrite ;
  $ intselectSocketForWrite (int, fp)
> Purpose
  | Checks to see if a socket is ready for writing.  If _timeout_ > 0, this operation is timed-out within timeout seconds.  If timeout == 0, this operation becomes a polling action.  If timeout < 0, this operation is blocked until the socket becomes writeable.
> Return Value
  | Returns -1 for failure, in which case _errno_ gives the reason.
  | Returns 0 if timed-out.
  | Returns 1 if the socket becomes writable.
> Parameters
  | int socket   - socket descriptor
  | fp timeout   - timeout value in seconds
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: enableNONBLOCK ;
  $ intenableNONBLOCK (int)
> Purpose
  | Enables the non-blocking I/O mode on a given file descriptor.
> Return Value
  | Returns -1 if the operation fails, in which case _errno_ gives the reason for the failure.
> Parameters
  | int fd  - file descriptor
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | Currently, only POSIX O_NONBLOCK is supported by this function.
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: disableNONBLOCK ;
  $ intdisableNONBLOCK (int)
> Purpose
  | Disables the non-blocking I/O mode on a given file descriptor.
> Return Value
  | Returns -1 if the operation failes, in which case _errno_ gives the reason for the failure.  | 
> Exceptions
  | [Throws_no_exceptions,_passes_all_exceptions_through.]
  | [Throws_EXCEPTION_if_CONDITION]
> Notes
  | Currently, only POSIX O_NONBLOCK is supported by this function.
  | [Other_information_eg_special_conditions,_what_it_does/does_not_do]
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
