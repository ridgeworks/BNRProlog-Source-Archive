/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/PostEvent.p,v 1.1 1995/09/22 11:26:05 harrisja Exp $
*
*  $Log: PostEvent.p,v $
 * Revision 1.1  1995/09/22  11:26:05  harrisja
 * Initial version.
 *
*
*/

/*
 *   PostEvent
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

%%%%% userevent (blocking)
userevent(Event, Window, D1, D2) :-
	forget(nextevent(Ev,W,V_D1,V_D2),$local),
	!,
	[Event,Window,D1,D2] = [Ev,W,V_D1,V_D2].
userevent(Event, Window, D1, D2) :-
    $userevent(V1_event, V1_window, V1_d1, V1_d2, noblock),
    $alternateevent(V1_event, V1_window, V1_d1, V1_d2, V2_event, V2_window, V2_d1, V2_d2),
    not($nonblocking(V2_event)),            % in case idle event gets through
    !,
    [Event, Window, D1, D2] = [V2_event, V2_window, V2_d1, V2_d2].
userevent(Event, Window, D1, D2) :-
    !,                                      % in case parms instantiated
    $userevent(Event, Window, D1, D2).

%%%%% userevent (non-blocking)
userevent(Event, Window, D1, D2, noblock) :-
	forget(nextevent(Ev,W,V_D1,V_D2),$local),
	!,
	[Event,Window,D1,D2] = [Ev,W,V_D1,V_D2].
userevent(Event, Window, D1, D2, noblock) :-
    $userevent(V1_event, V1_window, V1_d1, V1_d2, noblock),
    $alternateevent(V1_event, V1_window, V1_d1, V1_d2, V2_event, V2_window, V2_d1, V2_d2),
    !,
    [Event, Window, D1, D2] = [V2_event, V2_window, V2_d1, V2_d2].
userevent(Event, Window, D1, D2, noblock) :-
    $userevent(Event, Window, D1, D2, noblock).

%%%%% postevent - allows users to post their own events
postevent(Event, Window, D1, D2) :-
    symbol(Event),
    rememberz(userevent(Event, Window, D1, D2), $local).

%%%%% nextevent - allows users to post their own events - but event put at head of queue
nextevent(Event, Window, D1, D2) :-
    symbol(Event),
    remember(nextevent(Event, Window, D1, D2), $local).
nextevent(Event, Window, D1, D2) :-
	recall(nextevent(Event, Window, D1, D2), $local).

%%%%% lasteventdata - retrieves last data from real or posted event
lasteventdata(Event, Window, _, _, _) :-    % no mouse, ... so don't return anything
    recall(lastdata(Ev, W), $local),
	!,										% in case Event or Window instantiated
	[Event, Window] = [Ev, W].
lasteventdata(Event, Window, Mouse, When, Modifiers) :-
    $lasteventdata(Event, Window, Mouse, When, Modifiers).

reeventdata(1,Event,Mouse,When,Modifiers) :-
	$lasteventdata(Event, Window, Mouse, When, Modifiers).

% returns a user posted event if no real event exists.
% last 4 parms should be variables to ensure that the posted event does 
% get removed from the state space.
$alternateevent(OldEvent, _, _, _, Event, Window, D1, D2) :-
    $removelastdata,                        % remove data from any previous posted event
    $nonblocking(OldEvent),                 % must be a simple event to be replaced
    $getlastevent(Event, Window, D1, D2),
    !.                                      % don't ripple into next clause
$alternateevent(Event, Window, D1, D2, Event, Window, D1, D2).

$removelastdata :-                          % get rid of last data if it exists
    forget(lastdata(_..), $local),          % get rid of remembered data
    fail.                                   % repeat if more data exists (out of sync ??)
$removelastdata.                            % always succeed

$getlastevent(Event, Window, D1, D2) :-     % try to get a posted event
    forget(userevent(Event, Window, D1, D2), $local),
    remember(lastdata(Event, Window), $local).

%%%% events for which a posted event can preempt
$nonblocking(userdownidle).
$nonblocking(userupidle).
$nonblocking(balloonidle).

