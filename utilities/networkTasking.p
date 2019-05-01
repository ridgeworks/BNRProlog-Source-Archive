/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/networkTasking.p,v 1.1 1995/09/22 11:25:31 harrisja Exp $
*
*  $Log: networkTasking.p,v $
 * Revision 1.1  1995/09/22  11:25:31  harrisja
 * Initial version.
 *
*
*/

% Tasking send a wait predicates over a network


% The tasking code in base expects that the network tasking predicates be structured as such:
%		networktasksend([Host,Port],message)
%		networktaskwait([Host,Port],message)
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

networktaskwait2(Host,Port,Message) :-	% This version receives a message, sends the reply then comes out of the wait
   self(main),			% Only the main task can do a wait
   $resolveName(Ip,Host),
   repeat,
   receivemessage(Ip,Port,Message),!,
   sendmessage(Ip,Port,Message,block).

networktaskwait(Host,Port,Message) :-	% This version receives a message, processes it then sends the reply, the next time it does a wait
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

$resolveName(Name,Name) :-
    var(Name),!.

$resolveName(Ip,'127.0.0.1') :-
    netname(_,Ip),!.

$resolveName(Ip,localhost) :-
    netname(_,Ip),!.

$resolveName(Ip,Ip) :-
    netname(_,Ip),!.

$resolveName(Ip,Name) :-
    netname(Name,Ip),!.
