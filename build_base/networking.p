/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/networking.p,v 1.23 1998/06/10 02:25:28 csavage Exp $
 *
 * $Log: networking.p,v $
 * Revision 1.23  1998/06/10  02:25:28  csavage
 * Changed networking (TCP and UDP) code to handle multiple
 * null-terminated messages in the receive buffer.  Old behaviour
 * was to keep first message, discard rest of buffer.
 *
 * Revision 1.22  1998/03/31  11:16:18  csavage
 * created send/receive TCP/UDP bytes primitives
 *
 * Revision 1.21  1997/09/08  11:22:00  harrisj
 * $checkUDPresult wasn't unifying the return error code properly when message successfully decoded
 *
 * Revision 1.20  1996/07/10  10:27:38  yanzhou
 * $addSocket() is now reverted back to version 1.17,
 * where a newly accepted socket always inherits all
 * the TCP socket options from the listening socket.
 *
 * In version 1.18, $addSocket() was changed to set
 * the buffer sizes of the new socket to the current
 * networkconfig setting, which might fail on HP-UX,
 * because SO_RCVBUF and SO_SNDBUF cannot be reduced
 * in size once a socket is connected on HP-UX.
 *
 * Revision 1.19  1996/07/05  10:55:33  yanzhou
 * Rather than changing the new socket buffer size to
 * the networkconfig default, $addSocket was incorrectly
 * calling $opensocket.  Now fixed.
 *
 * The logic in $resolveName was incorrect.  Now fixed.
 *
 * Revision 1.18  1996/05/20  16:50:32  neilj
 * Added new predicates sendTCPterm, sendUDPterm, receiveTCPterm, and receiveUDPterm.
 * Fixed a bug in acceptconnection to use the default buffer size for the
 * new socket (instead of the passive socket's buffer size).
 *
 * Revision 1.17  1996/05/16  14:04:57  yanzhou
 * $resolveName/2 optimized (with the argument positions swapped).
 *
 * Revision 1.16  1995/11/17  17:08:23  yanzhou
 * Removed unnecessary ! (cut) from acceptconnection.
 *
 * Revision 1.15  1995/11/17  17:03:46  yanzhou
 * 1) makeconnection now only works on `active' sockets.
 * 2) acceptconnection now only works on `passive' sockets.
 * 3) on NAV88K, receiveTCP() was not working properly on an accepted socket,
 *    the cause was that getsockopt(socket,SOL_SOCKET,SO_RCVBUF) always
 *    returns 0 (instead of valid values like 8192) on a newly opened/accepted
 *    socket.
 *    FIX: to call setsockopt() explicitly on all newly opened/accepted sockets
 *         at Prolog level.
 *
 * Revision 1.14  1995/11/14  10:34:33  yanzhou
 * Changed acceptconnection() to inherit options from the listening socket.
 *
 * Revision 1.13  1995/11/13  16:23:28  yanzhou
 * Speed-up: $notMyself is no longer used to check sockets in send/recieve/connect predicates.
 *
 * Revision 1.12  1995/11/08  09:49:44  yanzhou
 * Modified: opensocket() to make opensocket(_,_,_,_) work again.
 *
 * Revision 1.11  1995/11/02  11:26:56  harrisja
 * Removed a setsocketopt clause that reset the socket opt to the default as it caused functionality conflicts
 *
 * Revision 1.10  1995/10/25  11:59:57  yanzhou
 * Fixed: $updateSocket to always succeed.
 * Removed: unnecessary networkconfig choice points.
 *
 * Revision 1.9  1995/10/24  09:40:17  yanzhou
 * querysocketopts added.  setsocketopt is no longer a generator.
 *
 * Revision 1.8  1995/10/23  18:29:20  yanzhou
 * opensocket/setsocketopt fixed.
 *
 * Revision 1.7  1995/10/23  16:04:37  yanzhou
 * To support configurable socket buffer sizes.
 *
 * Revision 1.6  1995/10/20  10:12:56  harrisja
 * added querysockets calls to send and receive predicates
 *
 * Revision 1.5  1995/10/19  17:28:05  harrisja
 * *** empty log message ***
 *
 * Revision 1.4  1995/10/19  17:20:48  harrisja
 * change socket status to disconnected when error ENOTCONN (235) is returned
 *
 * Revision 1.3  1995/10/19  14:26:52  harrisja
 * Added support for sending and receiving files.
 * Fix to resolveName so that it does not verify non loopback IP addresses.
 *
 * Revision 1.2  1995/10/17  10:59:36  harrisja
 * Revamped to use new networking primitives
 *
 * Revision 1.1  95/09/22  11:25:29  11:25:29  harrisja (Jason Harris)
 * Initial version.
 *
 *
 */



/*
 *      Networking - Prolog code for network support
 *
 *      BNR Prolog
*/



% Opening and closing sockets
opensocket(Port,Type,Socket) :-			% opensocket/3
    opensocket(Port,Type,BufSiz,Socket),
    !.

opensocket(Port,Type,BufSiz,Socket) :-		% opensocket/4 query
    integer(Port),
    querysockets(Socket,Port,Type,_),
    setsocketopt(Socket,so_sndbuf, BufSiz),
    setsocketopt(Socket,so_rcvbuf, BufSiz),
    !.

opensocket(Port,Type,BufSiz,Socket) :-		% opensocket/4 new socket, default bufsiz
    var(BufSiz),
    !,
    networkconfig(_,_,_,BufSiz),
    $opensocket(Port,Type,Socket),
    $setsockbufsiz(Socket, BufSiz),		% close on fail
    !.

opensocket(Port,Type,BufSiz,Socket) :-		% opensocket/4 new socket
    $opensocket(Port,Type,Socket),
    $setsockbufsiz(Socket, BufSiz),		% close on fail
    !.

$opensocket(Port,tcp,Socket) :-			% form 1 - tcp
    $opensocketTCP(Port,Socket),
    remember(netsocket(Socket,Port,tcp,active),$local),
    !.

$opensocket(Port,udp,Socket) :-			% form 2 - udp
    $opensocketUDP(Port,Socket),
    remember(netsocket(Socket,Port,udp,active),$local),
    !.

closesocket(Socket) :-
    integer(Socket),
    recall(netsocket(Socket,_,_,_),$local),
    forget_all(netmessage(Socket,_,_,_,_),$local),
    forget(netsocket(Socket,_,_,_),$local),
    forget_all(netsocketopt(Socket,_,_),$local),
    $closesocket(Socket),
    !.

$setsockbufsiz(Socket,BufSiz) :-
    setsocketopt(Socket, so_rcvbuf, BufSiz),
    setsocketopt(Socket, so_sndbuf, BufSiz),
    !.

$setsockbufsiz(Socket,_) :-
    closesocket(Socket),
    !,fail.

% setsocketopt
querysocketopts(Socket, Option, Value) :-
    recall(netsocketopt(Socket, Option, Value), $local).

setsocketopt(Socket, Option, Value) :-		% form 1 - query
    querysocketopts(Socket, Option, Value),
    !.

setsocketopt(Socket, Option, Value) :-		% form 2 - set
    $setsocketopt(0, Socket, Option, Value),
    forget_all(netsocketopt(Socket, Option, _), $local),
    remember(netsocketopt(Socket, Option, Value), $local),
    !.

% TCP Connections
listensocket(Socket,Error) :-
    querysockets(Socket,_,tcp,passive),
    !,
    Error = 0.

listensocket(Socket,Error) :-
    recall(netsocket(Socket,Port,tcp,active),$local),
    !,
    $listensocket(Socket,Error),
    forget(netsocket(Socket,Port,tcp,active),$local),
    remember(netsocket(Socket,Port,tcp,passive),$local),
    !.

acceptconnection(Socket,Host,Port,NewSocket,Error) :-
    querysockets(Socket,_,tcp,passive),
    $acceptconnection(Socket,Ip,NewPort,NewSocket,Error),
    $rightConnection(NewSocket,Ip,Host,NewPort,Port),
    $addSocket(Error,Socket,NewSocket),
    !.

$rightConnection(Socket,Ip,Host,Port,Port) :-	% NewPort has to match Port
    $resolveName(Host, Ip),			% Ip      has to match Host
    !.

$rightConnection(Socket,_,_,_,_) :-		% Disconnect unexpected connections
    $closesocket(Socket),
    !,
    failexit(acceptconnection).

$addSocket(0,Socket,NewSocket) :-
    remember(netsocket(NewSocket,0,tcp,connected),$local),
    foreach(recall(netsocketopt(Socket,Option,Value),$local)
		do setsocketopt(NewSocket,Option,Value)),
    !.
$addSocket(Err,Sock,NewSock) :- !.		% nop
 
makeconnection(Socket,Host,Port,Error) :-
    querysockets(Socket,MyPort,tcp,active),
    $resolveName(Host, Ip),
%	netname(_,MyIp),
%	$notMyself(MyIp,Ip,MyPort,Port),
    $makeconnection(Socket,Ip,Port,Error),
    $updateSocket(Socket,connected,Error),
    !.

% $notMyself(MyIp,Ip,MyPort,Port) :-
%	integer(Ip, Port), 
%	MyIp = Ip,
%	MyPort = Port,
%	!,
%	fail.
%	
% $notMyself(MyIp,Ip,MyPort,Port) :- !.

$updateSocket(Socket,State,0) :-
    forget(netsocket(Socket,Port,Type,_),$local),
    remember(netsocket(Socket,Port,Type,State),$local),
    !.

$updateSocket(_,_,_) :-
    !.

%	Send Primitives

sendTCP(Socket,Stream,Error) :-
    integer(Stream),
    querysockets(Socket,_,tcp,connected),
    !,
    get_obj(Stream,stream$(Stream,[FileDesc,_],_,_,_),$local),
    $sendmessageTCP(Socket,FileDesc,Error).

sendTCP(Socket,Message,Error) :-
    querysockets(Socket,_,tcp,connected),
    $sendmessageTCP(Socket,Message,Error),
    !.

sendTCPterm(Socket, Message, Error) :-
    integer(Socket),
    querysockets(Socket, _, tcp, connected),
    !,
    $sendTCPterm(Socket, Message, Error).
    
sendTCPbytes(Socket, Count, IntegerList, Error) :-
    integer(Socket),
    querysockets(Socket, _, tcp, connected),
    !,
    $sendTCPbytes(Socket, Count, IntegerList, Error).    

sendUDP(Socket,Host,Port,Stream,Error) :-
    integer(Stream),
    querysockets(Socket,MyPort,udp,_),
    !,
    get_obj(Stream,stream$(Stream,[FileDesc,_],_,_,_),$local),
    $resolveName(Host, Ip),
%	netname(_,MyIp),
%	$notMyself(MyIp,Ip,MyPort,Port),
    $sendmessageUDP(Socket,Ip,Port,FileDesc,Error).

sendUDP(Socket,Host,Port,Message,Error) :-
    querysockets(Socket,MyPort,udp,_),
%	netname(_,MyIp),
    $resolveName(Host, Ip),
%	$notMyself(MyIp,Ip,MyPort,Port),
    $sendmessageUDP(Socket,Ip,Port,Message,Error),
    !.

sendUDPbytes(Socket,Host,Port,ListLen, List, Error) :-
    querysockets(Socket,MyPort,udp,_),
    $resolveName(Host, Ip),
    $sendUDPbytes(Socket, Ip, Port, ListLen, List, Error),
    !.

sendUDPterm(Socket, Host, Port, Message, Error) :-
    integer(Socket),
    symbol(Host),
    integer(Port),
    put_term(StrMsg, Message, 0),
    sendUDP(Socket, Host, Port, StrMsg, Error).
 
 
%	Receive Primitives

receiveTCP(Socket,Stream,Error) :-
    integer(Stream),
    querysockets(Socket,_,tcp,connected),
    !,
    get_obj(Stream,stream$(Stream,[FileDesc,_],_,_,_),$local),
    $receivemessageTCP(Socket,FileDesc,Error).

receiveTCP(Socket,Message,Error) :-
    querysockets(Socket,_,tcp,connected),
    $findmessage(tcp,Socket,_,_,Message,Error),
    !.

receiveTCPterm(Socket, Message, Error) :-
    integer(Socket),
    querysockets(Socket, _, tcp, connected),
    !,
    $receiveTCPterm(Socket, [Message], Error).

receiveTCPbytes(Socket, Count, IntegerList, Error) :-
    integer(Socket),
    querysockets(Socket, _, tcp, connected),
    !,
    $receiveTCPbytes(Socket, Count, IntegerList, Error).
 
receiveUDP(Socket,Host,Port,Stream,Error) :-
    integer(Stream),
    querysockets(Socket,MyPort,udp,_),
    !,
    get_obj(Stream,stream$(Stream,[FileDesc,_],_,_,_),$local),
%	netname(_,MyIp),
    $resolveName(Host, Ip),
%	$notMyself(MyIp,Ip,MyPort,Port),
    $receivemessageUDP(Socket,Ip,Port,FileDesc,Error).


receiveUDP(Socket,Host,Port,Message,Error) :-
    querysockets(Socket,MyPort,udp,_),
    $resolveName(Host, Ip),
%	netname(_,MyIp),
%	$notMyself(MyIp,Ip,MyPort,Port),
    $findmessage(udp,Socket,Ip,Port,Message,Error),
    !.
    
receiveUDPbytes(Socket, Host, Port, ListLen, List, Error) :-
    querysockets(Socket,MyPort,udp,_),
    !,
    $resolveName(Host, Ip),
    $receiveUDPbytes(Socket, Ip, Port, ListLen, List, Error).
    
receiveUDPterm(Socket, Host, Port, Message, Error) :-
    integer(Socket),
    receiveUDP(Socket, Host, Port, StrMsg, RcvErr),
    $checkUDPresult(RcvErr, StrMsg, Message, Error),
    !.
 
$checkUDPresult(0, StrMsg, Message, 0) :-
    get_term(StrMsg, Message, 0).
$checkUDPresult(0, _, _, -2).			% Malformed, return -2
$checkUDPresult(Error, _, _, Error).		% return a receive error
 
$findmessage(Type,Socket,Ip,Port,Message,Error) :-
    forget(netmessage(Socket,Ip,Port,Message,Error),$local).

$findmessage(Type,Socket,Ip,Port,Message,Error) :-
    repeat,
    $receiveMsg(Type,Socket,Ip2,Port2,Message2,Error),
    $processIncomingMessage(Socket,Ip,Ip2,Port,Port2,Message,Message2,Error),
    !.

$receiveMsg(tcp,Socket,_,_,Message,Error) :-
    $receivemessageTCP(Socket,Message,Error),
    !.

$receiveMsg(udp,Socket,Ip,Port,Message,Error) :-
    $receivemessageUDP(Socket,Ip,Port,Message,Error),
    !.
$receiveMsg(_,_,_,_,_,_) :-
    failexit($findmessage).	

/*
   $processIncomingMessage(_,Ip,Ip,Port,Port,Message,Message,_).
   $processIncomingMessage(Socket,Ip,SenderIp,MyPort,SenderPort,MyMsg,SenderMsg,Error) :-
      remember(netmessage(Socket,SenderIp,SenderPort,SenderMsg,Error),$local),
      !,
      fail.
*/

$processIncomingMessage(_,Ip,Ip,Port,Port,Message,[],_).
$processIncomingMessage(Socket,Ip,Ip,Port,Port,Message,[Message,Rest..],Error) :-
   $storeRest(Socket, Ip, Port, Rest, Error),
   !. 
$processIncomingMessage(Socket,Ip,SenderIp,MyPort,SenderPort,MyMsg,[SenderMsg,Rest..],Error) :-
   remember(netmessage(Socket,SenderIp,SenderPort,SenderMsg,Error),$local),
   $processIncomingMessage(Socket,Ip,SenderIp,MyPort,SenderPort,MyMsg,Rest,Error),
   !,
   fail.

$storeRest(Socket,SenderIp,SenderPort,[],Error).

$storeRest(Socket,SenderIp,SenderPort,[SenderMsg, Rest..],Error) :-
   remember(netmessage(Socket,SenderIp,SenderPort,SenderMsg,Error),$local),
   $storeRest(Socket,SenderIp,SenderPort,Rest,Error), !.


/*
% Tasking send a wait predicates over a network

% The tasking code in base expects that the network tasking predicates be structured as such:
%               networktasksend([Host,Port],message)
%               networktaskwait([Host,Port],message)
% When a send/wait is performed, as a last resort (ie. everything else fails) the tasking code will attempt to do a
% networktasksend/networktaskwait.



%   Tasking send primitives
networktasksend(Host,Port,Message) :-
    $resolveName(Ip,Host),
    sendmessage(Ip,Port,Message,block),
    repeat,
    receivemessage(Ip,Port,Message),
    !.


%   Tasking wait primitives

networktaskwait2(Host,Port,Message) :-  % This version receives a message, sends the reply then comes out of the wait
    self(main),                  % Only the main task can do a wait
    $resolveName(Ip,Host),
    repeat,
    receivemessage(Ip,Port,Message),!,
    sendmessage(Ip,Port,Message,block).

networktaskwait(Host,Port,Message) :-   % This version receives a message, processes it then sends the reply, the next time it does a wait
    self(main),
    $resolveName(Ip,Host),
    $needSending,
    repeat,
    receivemessage(Ip,Port,Message),!,
    remember(receivedMsg(Ip,Port,Message),$local).

$needSending :-
    recall(receivedMsg(Ip,Port,Message),$local),
    sendmessage(Ip,Port,Message,block),
    forget(receivedMsg(Ip,Port,Message),$local),
    !.

$needSending.
*/



%  Misc.
querysockets(Socket,Port,Type,State) :-
    recall(netsocket(Socket,Port,Type,State),$local).

netname(HostName,IPaddress) :- 
    $netname(HostName,IPaddress).

% networkconfig
%   the first three arguments (LowestPort, Readtimer and Connecttimer)
%   are implemented in C-primitive $networkconfiguration (see network.c)
networkconfig(LowestPort,Readtimer,Connecttimer,Buffersize) :-
    $networkbuffersize(Buffersize),
    $networkconfiguration(LowestPort,Readtimer,Connecttimer),
    !.

networkconfig(LowestPort,Readtimer,Connecttimer) :-
    networkconfig(LowestPort,Readtimer,Connecttimer,_),
    !.

$networkbuffersize(BufSiz) :-
    recall(networkbuffersize(BufSiz), $local),
    !.

$networkbuffersize(8192) :-			% default = 8K
    forget_all(networkbuffersize(_), $local),
    !.

$networkbuffersize(BufSiz) :-
    forget_all(networkbuffersize(_), $local),
    remember(networkbuffersize(BufSiz), $local),
    !.

%
% $resolveName(Name, Ip)
%   modified 04/07/96 by yanzhou@bnr.ca
%
$resolveName(Name,Name) :-			% variables, unify them
    var(Name),!.
$resolveName(Name,Ip) :-			% netname lookup
    $netname(Name,Ip),!.
$resolveName(Ip,Ip) :- !.			% IP address
$resolveName(Name,"127.0.0.1") :-		% local host
    $netname(LocalHostName, LocalHostIp),
    Name=LocalHostName; Name=LocalHostIp,
    !.
% End
