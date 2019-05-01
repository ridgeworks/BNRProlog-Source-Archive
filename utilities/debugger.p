/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/debugger.p,v 1.2 1997/03/20 17:09:45 harrisj Exp $
*
*  $Log: debugger.p,v $
 * Revision 1.2  1997/03/20  17:09:45  harrisj
 * Added support for spying on local predicates in a given context.
 * The new predicates are:
 * localspy(Predicate,Context)
 * localnospy(Predicate,Context)
 * localallspy(Context)
 * localallnospy(Context)
 * localspied(Predicate,Context)
 * localspied(Ports,Predicate,Context)
 *
 * Revision 1.1  1995/09/22  11:23:47  harrisja
 * Initial version.
 *
*
*/

/*
 *   Debugger
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% tracer(+Goal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tracer(Goal) :-                             % Goal being creeped or spyed was attempted
    enable_trace(0),                        % Disable tracing
	$istraceable(Goal, Depth, Callid),
    !,
	repeat,					% repeat so we can do retries
    $tracer(Goal, (Depth : Callid)),		% process
    $dummy(Goal).				% special call to force arg into e(1) so goal
						% can get argument for display.
$dummy(_).

$istraceable(P(Args..), -99, -99) :-
	$event(P),                              % do we have an event ??
	recall(eventflag(X), $local),           % see what we want to do
	$checkevent(X, P).                      % decide a course of action
$istraceable(_, Depth, Callid) :-
    $tracer_depth(Depth),                   % Get Depth and CallId with respect 
    $tracer_invocation_id(Callid).          % to ancestors

$checkevent(overload, P) :-                 % event must be overloaded
    definition(P(Args..) :- Body, Cx),      % get first clause for event
    !,                                      % succeed or fail if
    Cx = base.                              %    clause in base
$checkevent(never, _).                      % simply succeed so Goal is just executed
% $checkevent(always, _) :- fail.           % fail so we compute Depth and Callid

$tracer(Goal, (-99 : -99)) :-
	cut(tracer),
	enable_trace(0) ; [$enable_tracer, fail],
	Goal,
	$enable_tracer.

$tracer(P(Args..), CallNum) :-
    enable_trace(0),                        % Disable tracing
    $tracer_three_port(P(Args..), CallNum),
	true.

$tracer(P(Args..), CallNum) :-              % into this clause if call fails
    enable_trace(0),
    $tracer_do_port(CallNum, fail, $tracer, P(Args..), PortCmd),
    PortCmd, 
    failexit(tracer).						% failexit tracer since we have failed

$tracer_three_port(cut($$callindirect), CallNum) :-
    !,
    $tracer_cut(cut(), cut($$callindirect), CallNum).

$tracer_three_port(cut($tracer_visible), CallNum) :-
    !,
	$equal(P, !),
    $tracer_cut(P(), cut($tracer_visible), CallNum).

$tracer_three_port(failexit($$callindirect), CallNum) :-
    !,
	cut($$callindirect),
    $tracer_cut(failexit(), failexit, CallNum).

$tracer_three_port(P(Args..), CallNum) :-
    primitive(P),
    !,
    $tracer_invisible(P(Args..), CallNum).

$tracer_three_port(P(Args..), CallNum) :-
    $special(P),
    !,
    $tracer_invisible(P(Args..), CallNum).

$tracer_three_port(P(Args..), CallNum) :-
    visible(P),
    !,
    $tracer_visible(P(Args..), CallNum).
    
$tracer_three_port(P(Args..), CallNum) :-    % defined but not a primitive and not visible
    predicate(P),
    !,
    $tracer_invisible(P(Args..), CallNum).

$tracer_three_port(P(Args..), CallNum) :-    % an undefined predicate
    not(predicate(P)),
    !,
    $tracer_undefined(P(Args..), CallNum).

$tracer_invisible(P(Args..), CallNum) :-
    $tracer_do_port(CallNum, call, $tracer_invisible, P(Args..), PortCmd), 
    PortCmd,
    enable_trace(0),                         % have to call a primitive - don't trap again
    P(Args..),                               % do it, And in case we ever back into a primitive
    enable_trace(0),                         % and again come forward, turn tracing off again
    $tracer_two_port(CallNum, $tracer_invisible, P(Args..)),
	true.

$tracer_visible(P(Args..), CallNum) :-
    $tracer_do_port(CallNum, call, $tracer_visible, P(Args..), PortCmd),
    block(P,
            [PortCmd,                                         
             definition((P(Args..) :- Body), _),
             $$callindirect(Body)]),
    enable_trace(0),                         % make sure tracing off again
    $tracer_two_port(CallNum, $tracer_visible, P(Args..)),
	true.

$tracer_undefined(P(Args..), CallNum) :-
    $tracer_do_port(CallNum, call, $tracer_undefined, P(Args..), PortCmd), 
    PortCmd,
	fail.

$tracer_cut(P, RealGoal, CallNum) :-
    $tracer_do_port(CallNum, call, $tracer_cut, P, PortCmd), 
    PortCmd,
    enable_trace(0),						% have to call a primitive - don't trap again
    RealGoal,								% do it (cut or failexit)
    $tracer_two_port(CallNum, $tracer_cut, P),
	true.
$tracer_cut(_, _, _) :-						% only called if RealGoal was failexit
	$enable_tracer,
	fail.

$tracer_two_port(CallNum, Block, Goal) :-
    enable_trace(0),
    $tracer_do_port(CallNum, exit, Block, Goal, PortCmd),
    PortCmd.
$tracer_two_port(CallNum, Block, Goal) :-
    enable_trace(0),
    $tracer_do_port(CallNum, redo, Block, Goal, PortCmd),
    PortCmd,
    fail.

$tracer_do_port(CallNum, Port, Block, P(Args..), PortCmd) :-
    enable_trace(0),                         % make sure tracing is off
    $tracer_do_port_OK_to_continue(P),
	$tracer_do_port_flag(N),
    $tracer_do_port2(N, CallNum, Port, Block, P(Args..), PortCmd),
    !.
$tracer_do_port(_, _, _, _, true).

$tracer_do_port_flag(0).
$tracer_do_port_flag(1). 	                 % in case command removes spy point
$tracer_do_port_flag(1) :-                   % prompt for another command
	$tracer_do_port_flag(1).

$tracer_do_port_OK_to_continue(P) :-
	$is_creeping,                            % see everything in creep mode
	!.
$tracer_do_port_OK_to_continue(P) :-
	predicate(P),                            % is it a predicate
	!,
    $flag_is_on($debug_on).                  % trap only if debugger is on
$tracer_do_port_OK_to_continue(P) :-
    unknown(X),                              % make sure user wants to see unknowns
    X = trace,
	!,
    $flag_is_on($debug_on),                  % trap only if debugger is on
	$tracebit_is_disabled(P, unknown).		 % and we haven't been told to ignore it


$tracer_do_port2(_, CallNum, Port, Block, P(Args..), PortCmd) :-
    not(predicate(P)),                                          % functor does not exist
	$tracebit_is_disabled(P, unknown),
    !,
    $tracer_do_port3(CallNum, Port, Block, P(Args..), PortCmd, '??', 1).

$tracer_do_port2(_, CallNum, Port, Block, P(Args..), PortCmd) :-
    $tracebit_is_enabled(P, spy_enable),                        % must be spying this predicate
    !,
    $tracebit_is_enabled(P, Port) -> Prompt = 1 ; Prompt = 0,
    $tracer_do_port3(CallNum, Port, Block, P(Args..), PortCmd, '**', Prompt).

$tracer_do_port2(_, CallNum, Port, Block, P(Args..), PortCmd) :-
    $tracebit_is_enabled(P, creep_enable),                      % must be creeping this predicate
    !,
    $leashed_ports(Ports, _),
    $member(Port, Ports) -> Prompt = 1 ; Prompt = 0,
    $tracer_do_port3(CallNum, Port, Block, P(Args..), PortCmd, '  ', Prompt).

$tracer_do_port2(0, _, _, _, _, $enable_tracer) :- 
    % user has turned spy off on a previous port, so just continue on
    !.
$tracer_do_port2(_, CallNum, Port, Block, Goal, PortCmd) :-
    $tracer_do_port3(CallNum, Port, Block, Goal, PortCmd, '  ', 1).
% default action for second and subsequent commands when user 
% has just turned spy off in this port (with - command)

$tracer_do_port3((Depth : Callid), Port, Block, P(Args..), PortCmd, SP, Prompt) :-
	$tracer_maxterms(MaxTerms),
    repeat,
    swrite(Leadin, SP, ' (', Callid, ') ', Depth, ' ', Port, ': '),
	portray_with_indent(1, Leadin, P(Args..), MaxTerms),
    not(predicate(P)) -> swrite(1, ' ??undefined predicate?? '),
    $tracer_prompt_user(Prompt, Port, Block, P(Args..), PortCmd),
    !.

$tracer_maxterms(MaxTerms) :-
	recall($debugoption(maxterms, MaxTerms), $local),
	!.
$tracer_maxterms(0).

$tracer_prompt_user(0, _, _, _, $enable_tracer) :-
    nl. 
$tracer_prompt_user(_, Port, Block, Goal, PortCmd) :-
    swrite(1, ' ? '), 
    $tracer_get_cmd(Goal, Cmd),
    $tracer_cmd(Cmd, Port, Block, Goal, PortCmd).        % May FAIL!!!, results in return to repeat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% $tracer_get_cmd(Goal, Cmd)
% Assumes tracer is turned off, and event processing keeps it turned off: Only goal capable
% of turning it on is $debug. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$tracer_read(Response) :-
	stream(0, FileName, Mode, FFileName),
	iswindow(Console, text, Visible, FFileName), % there is a window attached to stdin - use it
	!,
	activewindow(Console,text),			% make sure its active
	repeat,
		userevent(Ev,W,X,Y),
		$handleevent(Ev,W,X,Y,Console,Response),
		!.
	
$tracer_read(Response) :-	% no window - read directly from stdin
	readln(0, Response).

$handleevent(userkey,Console,Response,_,Console,Response) :-
	!,
	swrite(1, Response),
	nl(1).
$handleevent(Ev,W,X,Y,_,_) :-
	Ev(W, X, Y),
	!,
	fail.

$tracer_get_cmd(Goal, Cmd) :-
	$tracer_read(Response),
	$tracer_convert(Response, Goal, FirstChar),
    $tracer_get_cmd_aux(FirstChar, Cmd),
	!.

$tracer_convert('', Goal, 'c') :-
	$tracer_lookup(Goal),
	!.
$tracer_convert('', _, 's') :- !.
$tracer_convert('\n', Goal, 'c') :-
	$tracer_lookup(Goal),
	!.
$tracer_convert('\n', _, 's') :- !.
$tracer_convert('\r', Goal, 'c') :-
	$tracer_lookup(Goal),
	!.
$tracer_convert('\r', _, 's') :- !.
$tracer_convert(enter, Goal, 'c') :-
	$tracer_lookup(Goal),
	!.
$tracer_convert(enter, _, 's') :- !.
$tracer_convert(Response, _, FirstChar) :-
	name(Response, [Char, _..]),
    name(FirstChar, [Char]).

$tracer_lookup(P(Args..)) :-
	definition(P(A..) :- Body, Cx),		% get first definition
	!,
	Cx \= 'base'.

$tracer_get_cmd_aux('a',   abort).
$tracer_get_cmd_aux('b',   break).
$tracer_get_cmd_aux('c',   creep).
$tracer_get_cmd_aux('f',   fail).
$tracer_get_cmd_aux('g',   ancestors).
$tracer_get_cmd_aux('h',   help).
$tracer_get_cmd_aux('l',   leap).
$tracer_get_cmd_aux('n',   nodebug).
$tracer_get_cmd_aux('p',   print).
$tracer_get_cmd_aux('r',   retry).
$tracer_get_cmd_aux('s',   skip).
$tracer_get_cmd_aux('w',   write).
$tracer_get_cmd_aux('+',   spy).
$tracer_get_cmd_aux('-',   nospy).
$tracer_get_cmd_aux('.',   listing).
$tracer_get_cmd_aux('@',   listen).
$tracer_get_cmd_aux('?',   help).
$tracer_get_cmd_aux(_,   help).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% $tracer_cmds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$tracer_cmd(abort, _, Block, _, [nodebug, error(0)]) :-
    swrite(1, '\nABORT\n').

$tracer_cmd(ancestors, _, _, Goal, _) :-
    swrite(1, '\nAncestor Goals : \n'),
	$tracer_maxterms(MaxTerms),
    portray_with_indent(1, '         Executing -> ', Goal, MaxTerms),
    nl, $self(T),
    T \= main -> swrite(1,' (task: ', T, ')'),
    $tracer_ancestor_goal_position(0, Ptr),
    $tracer_ancestor_goals(Ptr),
    nl,nl,
    failexit($tracer_cmd).

$tracer_ancestor_goal_position(Ptr0, Ptr2) :-
    goal(Ptr0, tracer(_), Ptr2),
    !.
$tracer_ancestor_goal_position(Ptr0, NewPtr) :-
    goal(Ptr0, _, Ptr1),
    $tracer_ancestor_goal_position(Ptr1, NewPtr).

$tracer_ancestor_goals(Ptr) :-
    goal(Ptr, X, Ptr1),
    goal(Ptr1, _, Ptr2),		% usually $tracer_visible, or it's like
    goal(Ptr2, _, Ptr3),		% usually $tracer
    goal(Ptr3, tracer(X(Args..)), NewPtr),
    !,
	$tracer_maxterms(MaxTerms),
    portray_with_indent(1, '         Called by -> ', X(Args..), MaxTerms), 
    nl, 
    $tracer_ancestor_goals(NewPtr).
$tracer_ancestor_goals(Ptr) :-
    goal(Ptr, X, Ptr1),
    goal(Ptr1, _, Ptr2),
    goal(Ptr2, tracer(X(Args..)), NewPtr),
    !,
	$tracer_maxterms(MaxTerms),
    portray_with_indent(1, '         Called by -> ', X(Args..), MaxTerms), 
    nl, 
    $tracer_ancestor_goals(NewPtr).
$tracer_ancestor_goals(Ptr) :-
    goal(Ptr, X, NewPtr),
	$tracer_ancestor_goal_check(X),
    $tracer_ancestor_goals(NewPtr).

$tracer_ancestor_goal_check($$callindirect) :- !.
$tracer_ancestor_goal_check($$calllistindirect) :- !.
$tracer_ancestor_goal_check(X) :-
    name(X, [0'$, 0'$, _..]),
    predicate(X, C),
    C = base,
    !.
$tracer_ancestor_goal_check(X) :-
    swrite(1, '         Called by -> ', X), nl.

$tracer_cmd(break, _, _, _, _) :-
    break, 
	failexit($tracer_cmd).

$tracer_cmd(creep, Port, Block, Goal, [$creep, $enable_tracer]).

$tracer_cmd(fail, Port, Block, Goal, failexit(Block)).

$tracer_cmd(help, _, _, _, _) :-
    $give_help, 
	failexit($tracer_cmd).
	
$tracer_cmd(leap, Port, Block, Goal, [$nocreep, $enable_tracer]).

$tracer_cmd(listen, _, _, _, _) :-
    listen, 
	failexit($tracer_cmd).

$tracer_cmd(listing, _, _, P(Args..), _) :- 
    predicate(P),
    listing(1, P(Args..), _),
    nl, 
    failexit($tracer_cmd).
$tracer_cmd(listing, _, _, P(Args..), _) :-
    swrite(1,'\nPredicate ', P, ' not defined\n'),
    nl, 
    failexit($tracer_cmd).

$tracer_cmd(nodebug, Port, Block, Goal, nodebug).

$tracer_cmd(nospy, Port, Block, P(Args..), _) :-
    % remove spy bits from this predicate, may fail if not a predicate
    $nospy([P]),
    failexit($tracer_do_port3).
$tracer_cmd(nospy, Port, Block, P(Args..), _) :-
    % spy bits not set, set unknown bit to skip it next time
    set_trace(P, X), 
    X = 0,
    $tracebyte_bit(unknown, _, Y),
    set_trace(P, Y),
    failexit($tracer_do_port3).

$tracer_cmd(print, Port, Block, Goal, _) :-
    nl,
    print(Goal),
    nl, nl,
    failexit($tracer_cmd).

$tracer_cmd(retry, Port, Block, Goal, failexit($tracer)).

$tracer_cmd(skip, call, Block, Goal, enable_trace(0)).
$tracer_cmd(skip, redo, Block, Goal, enable_trace(0)).
$tracer_cmd(skip, exit, Block, Goal, [$creep, $enable_tracer]).
$tracer_cmd(skip, fail, Block, Goal, [$creep, $enable_tracer]).

$tracer_cmd(spy, Port, Block, P(Args..), _) :-
    $spy(P),
    failexit($tracer_do_port3).

$tracer_cmd(write, Port, Block, Goal, _) :-
    nl,
    write(Goal),
    nl, nl,
    failexit($tracer_cmd).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  debug() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debug :-
    enable_trace(0),                                    % Disable tracing temporarily
    $debug('Debug turned on', debug),
	!.

$debug(Msg, Mode) :-
    $showconsole(Msg),                                  % Make the console the active window
    forget_all(debug_on(_), $local),                    % Clean up historial house
    remember(debug_on(Mode), $local),                   % Remember debugging mode
    $mode(Mode), 
	!,
    $set_flag($debug_on),
	nl,
    !,
    enable_trace(1).                                    % Debug now turned on
                                        

$mode(debug) :-                                         % disable all predicates "creep enabled"
    $nocreep.
$mode(trace) :-                                          
    set_trace($creeping_is_on_dummy, 0), 
    $creep.                                             % force $creep to redo every predicate


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  nodebug() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
nodebug :-
    enable_trace(0),                                    % Disable tracing   
    $nodebug('Debug turned off').
        
$nodebug(Msg) :-
    $reset_flag($debug_on),
    $nocreep,                                           % Disable all predicates "creep enabled" 
    forget_all(debug_on(_), $local),                    % Clean up historial house
    $showconsole(Msg),                                  % Make the console the active window
    nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  trace() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trace :-                                                % Same as calling "debug" but for
    enable_trace(0),                                    % Disable tracing   
    $debug('Debug turned on in creep mode', trace).     % the mode of "trace"

attention_handler :-
	enable_trace(0),
	$debug('Debugger turned on in creep mode', trace).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  notrace() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

notrace :-                                              % Same as calling "nodebug".
    enable_trace(0),                                    % Disable tracing   
    $nodebug('Debug turned off').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  spy(+Ps..) - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spy() :-                                            % If variadic or null, FAIL !!!
    enable_trace(0),                                % Disable tracing   
    failexit(spy).

spy(Ps..) :- 
    enable_trace(0),                                % Disable tracing   
    $do_safely($spy(Ps..)),
    !.

$spy(Ports, Ps..) :-                                % Leash SPECIFIC ports of predicates Ps
    list(Ports),                                    % Ensure 1st arg is a list
    !,                                              %
    $leash_ports_verify(Ports, PV),                 % Confirm Ports by computing port value PV
    $spy_aux(PV, Ps).                               % Do it

$spy(Ps..) :-                                       % Leash ALL ports of predicates Ps                                      % Spy predicates using default leashing
    $leashable_ports(_, PV),                        % Get default port value
    $spy_aux(PV, Ps).                               % Do it

$spy_aux(PV, Ps) :-                                 % Spy list of predicates Ps
    $tracebyte_bit(spy_enable, _, SEV),             % Get spy enable value
    (SpyV is (PV + SEV)),                           % Compute spy value. Each predicate in Ps 
    $predicates_able(Ps, SpyV),                 	% has there tracebyte set to SpyV.
    !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  localspy(+PredicateName, +Context) -  spy on a local predicate in a given context
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localspy(Name, Context) :-
    $dotoname(spy, Name, Context).

$dotoname(Predicate, Name, Context) :-
    name(Name, [36,_..]),          % make sure starts with $
    predicate(P, Context),
    swrite(Name, P),
    Predicate(P),
    !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  spyall() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spyall :-
    enable_trace(0),                                % Disable tracing   
    $do_safely($spyall),
    !.

$spyall :-
    $leashable_ports(_, PV),                        % Get default port value
    $tracebyte_bit(spy_enable, _, SEV),             % Get spy enable value
    (SpyV is (PV + SEV)),                           % Compute spy value
	$tracebyte_set_all(0, SpyV),                    % blast them all at once
	!.                                              % we're done
$spyall :-
    $leashable_ports(_, PV),                        % Get default port value
    $tracebyte_bit(spy_enable, _, SEV),             % Get spy enable value
    (SpyV is (PV + SEV)),                           % Compute spy value.
    predicate(Ps),
    $predicates_able2(Ps, SpyV),                     
    fail.                                           % Force backtracking
$spyall.                                            % Always succeeds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  localspyall(+Context) - spy on all local predicates in a given context
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localspyall(Context) :-
    symbol(Context),
    context(Context),
    !,
    $dotocontext(spy, Context).

$dotocontext(Op, Context) :-
    predicate(P, Context),
    name(P, [36,_..]),          % make sure starts with $
    Op(P),
    fail.
$dotocontext(Op, Context).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  nospy(+Ps..) - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nospy(Ps..) :-                                      % Disable tracing on specific predicates
    enable_trace(0),                                % Disable tracing   
    $do_safely($nospy(Ps)), 
    !.

$nospy(Ps) :-                                       % Callable as a port command
    $is_creeping ->                                 % Are we currently creeping
        $tracebyte_bit(creep_enable, _, X) ;        % Yes, so set bit back to creeping
        X = 0,                                      % No, disable all tracing
    $predicates_able(Ps, X),                    	% Zero trace byte of all P in Ps
    !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  localnospy(+PredicateName, Context) - not spyable or traceable for a local predicate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localnospy(Name, Context) :-
    $dotoname(nospy, Name, Context).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  nospyall() - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nospyall :-
    enable_trace(0),                                % Disable tracing   
    $do_safely($nospyall), 
    !.

$nospyall :-                                        % Disable tracing on all spied predicates
    $tracebyte_bit(spy_enable, _, CE),              % Value of spy enable
	$leashable_ports(_, SS),						% sum of possible spy settings
    Mask is -1 - CE - SS,                           % Compute mask so we only affect spy bit
	$tracebyte_set_all(Mask, 0),                    % blast them all at once
	!.                                              % we're done
$nospyall :-                                        % Disable tracing on all spied predicates
    predicate(P),                                   % Generate a predicate
    $tracebit_is_enabled(P, spy_enable),            % Confirm that P is spied
    $tracebyte_set(P, 0),                           % Disable spying on P 
    fail.                                           % Force backtracking
$nospyall.                                          % Always succeeds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  localnospyall(+Context) - not spyable or traceable, for local predicates in a given context
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localnospyall(Context) :-
    symbol(Context),
    context(Context),
    !,
    $dotocontext(nospy, Context).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  spied(?P) / spied(?Ports, ?P) - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spied(P) :-                                         % Confirm P is spied
    enable_trace(0),                                % Disable tracing   
    !,
    spied(_, P).

spied(Ports, P) :-                                  % Confirm P is spied with Ports leashed
    enable_trace(0),                                % Disable tracing   
    $do_safely($spied(Ports, P)). 

$spied(Ports, P) :-                                 % CASE: Ports is a list
    list(Ports),                                    % Confirm Ports is a list.
    $tracebyte_bit(spy_enable, _, SE),              % Get spy enable value (choicepoint)
    !,                                              % Commit. Now compute port value, observing
    $leash_ports_verify(Ports, PV),                 % failure occurs if args are not ports.
    (SpyV is (SE + PV)),                            % Compute spy value
    predicate(P),                                   % Generate/confirm P
    $tracebyte_query(P, SpyV).                      % Query P's tracebyte value

$spied(Ports, P) :-                                 % CASE: Ports is a var
    var(Ports),                                     % Confirm Ports is a var (for early failure)
    $leashable_ports(Pts, _),                       % All possible ports 
    predicate(P),                                   % Confirm/Generate a P.
    $tracebit_is_enabled(P, spy_enable),            % Verify P is spied
    $spied_aux(Pts, P, Ports).                      % Determine which ports are leashed.

$spied_aux([], _, []).
$spied_aux([Port, Pts..], P, [Port, Ports..]) :-
    $tracebit_is_enabled(P, Port),                  % Verify P's Port is leashed
    !,                                              % Remove CP
    $spied_aux(Pts, P, Ports).                      % Check remainder
$spied_aux([_, Pts..], P, Ports) :-                 % Port not leashed
    $spied_aux(Pts, P, Ports).                      % Check remainder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  localspied(+Predicate, +Context) / localspied(+Ports, +Predicate, +Context) - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

localspied(Name, Context) :-
	$dotoname(spied,Name, Context).

localspied(Ports,Name, Predicate) :-
    name(Name, [36,_..]),          % make sure starts with $
    predicate(P, Context),
    swrite(Name, P),
    spied(Ports, P),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  leash(+/-Ports) - not spyable or traceable, however debugging may be enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

leash(Ports) :-
    enable_trace(0),                                % Disable tracing   
    $do_safely($leash(Ports)), 
    !.

$leash(Ports) :-                                    % CASE: Ports is a var - Query
    var(Ports),                                     % Confirm Ports is a var
    !,                                              % Commit to remove CP
    $leashed_ports(Ports, _).                       % Get the currently leashed ports

$leash(Ports) :-                                    % CASE: Ports is a list - Set
    list(Ports),                                    % Confirm Ports is a list
    $leash_ports_verify(Ports, PV),                 % Verify Ports to be ok
    forget_all(leashed_ports(_, _), $local),        % Clean up historical house
    remember(leashed_ports(Ports, PV), $local).     % Save leashed ports + value


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $creep()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Don't know if tracing on or off when we get called
$creep :-
    $is_creeping,                                   % If we are already creeping fail into next clause
    !.
$creep :-                                           % Creep all non-spied, callable predicates
    $tracebyte_bit(creep_enable, _, CE),            % Value of creep enable
    $tracebyte_set($creeping_is_on_dummy, CE),      % Used as a internal flag (see $is_creeping)
    Mask is -1 - CE,                                % Compute mask so we only affect creep bit
	$tracebyte_set_all(Mask, CE),                   % blast them all at once
	!.                                              % we're done
$creep :-                                           % Creep all non-spied, callable predicates
    $tracebyte_bit(creep_enable, _, CE),            % Value of creep enable
    $tracebyte_set($creeping_is_on_dummy, CE),      % Used as a internal flag (see $is_creeping)
    predicate(P),
    $tracebit_is_disabled(P, spy_enable),           % Cannot be spied
    $tracebyte_set(P, CE),                          % Set trace byte of P
    fail.                                           % repeat for next predicate, then next context
$creep.

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $nocreep()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$nocreep :-                                         % Disable all creeped predicates
    $is_creeping,                                   % We must currently be creeping
    $tracebyte_bit(creep_enable, _, CE),            % Value of creep enable
    Mask is -1 - CE,                                % Compute mask so we only affect creep bit
	$tracebyte_set_all(Mask, 0),                    % blast them all at once
    set_trace($creeping_is_on_dummy, 0),            % indicate we're no longer creeping
	!.                                              % we're done
$nocreep :-                                         % Disable all creeped predicates
    $is_creeping,                                   % We must currently be creeping
    set_trace($creeping_is_on_dummy, 0),            % indicate we're no longer creeping
    predicate(P), 
    $tracebit_is_enabled(P, creep_enable),          % Predicate is being creeped
    set_trace(P, 0),                                % Disable creeping on P
    fail.                                           % Repeat for all predicates
$nocreep.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $leash_ports_verify(+Ports, ?PortsValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$leash_ports_verify([T..], _) :-
    tailvar(T..),
    !, 
    fail.

$leash_ports_verify([], 0).

$leash_ports_verify([Port, Ports..], PV) :-
    symbol(Port),
    $tracebyte_bit(port, Port, BE),
    not($member(Port, Ports)),          % see if current port occurs again in list
    $leash_ports_verify(Ports, BEs),
    !,
    (PV is (BE + BEs)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $leashed_ports(Ports, PV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$leashed_ports(Ports, PV) :-
    recall(leashed_ports(Ports, PV), $local),
    !.
$leashed_ports(Ports, PV) :-                        % default is to use full list of ports
    $leashable_ports(Ports, PV).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $is_creeping()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$is_creeping :-
    $tracebit_is_enabled($creeping_is_on_dummy, creep_enable).

$creeping_is_on_dummy.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $tracebit_is_enabled(+Predicate, +BitName)
%
% Confirms bit is set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$tracebit_is_enabled(P, BitName) :-
    set_trace(P, V),                            % query setting on predicate
    $tracebyte_bit(_, BitName, EV),             % verify bit name, get value
    (1 is ((V // EV) mod 2)).                   % bit must be set

$tracebit_is_disabled(P, BitName) :-
    set_trace(P, V),                            % query setting on predicate
    $tracebyte_bit(_, BitName, EV),             % verify bit name, get value
    (0 is ((V // EV) mod 2)).                   % bit must be clear


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $tracebyte_set(+P, +V)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$tracebyte_set_all(AndMask, OrMask) :-
	set_trace_all(AndMask, OrMask, 
				  [tracer, trace, debug, spy, spyall, spied, notrace, nodebug, 
				   nospy, nospyall, leash, definition, $dummy, $$callindirect,
				   $$calllistindirect, $equal]).

$tracebyte_set(P, _) :-             % ignore settings on predicates not debugable
    $$not_debugable(P),
    !.
$tracebyte_set(P, V) :-             % predicate is debugable, try to set bit
    set_trace(P, V),                % set it for real
    !.
$tracebyte_set(_, _).               % in case set_trace fails (P not a predicate??)

$tracebyte_query(P, V) :-
    set_trace(P, OldV),
    V is OldV - (OldV mod 4).

$$not_debugable(tracer).            %%%%% debugger predicates which are not debugable
$$not_debugable(trace).
$$not_debugable(debug).
$$not_debugable(spy).
$$not_debugable(spyall).
$$not_debugable(spied).
$$not_debugable(notrace).
$$not_debugable(nodebug).
$$not_debugable(nospy).
$$not_debugable(nospyall).
$$not_debugable(leash).
$$not_debugable(definition).
$$not_debugable($dummy).
$$not_debugable($$callindirect).
$$not_debugable($$calllistindirect).
$$not_debugable($equal).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $tracebyte_bit(?Type, ?BitName, ?BitValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$tracebyte_bit(spy_enable, spy_enable, 128).
$tracebyte_bit(creep_enable, creep_enable, 64).
$tracebyte_bit(port, call, 32).
$tracebyte_bit(port, exit, 16).
$tracebyte_bit(port, fail, 8).
$tracebyte_bit(port, redo, 4).
$tracebyte_bit(unknown, unknown, 2).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $leashable_ports(?Ports, ?PV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$leashable_ports( [call, exit, fail, redo], 60 ).   % 60 is the sum of $tracebyte_bit values


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $do_safely(+Goal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$do_safely(Goal) :-
    enable_trace(0),                                % disable tracing
    Goal,                                           % try the goal
    ($enable_tracer ; [enable_trace(0), fail]).      % turn debugger on or off as appropriate
                                                    % on backtracking, turn tracing off
$do_safely(_) :-                        % Goal fails, must still set trace bit if necessary
    $enable_tracer,
    fail.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $showconsole(+Message)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$showconsole(Msg) :-
    write('\n *** ', Msg, ' ***\n').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  $predicates_able(+ListOfPredicates, +NewTracebyteValue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$predicates_able([], _).
$predicates_able([P, Ps..], V) :-
    predicate(P),                                       % P is an existing predicate symbol.
    !,
    $predicates_able(Ps, V),                        	% Ensure remainder of Ps ok first.
    $tracebyte_set(P, V).                               % Then set trace byte of P to V

$predicates_able2(P, V) :-
    predicate(P),                                       % P is an existing predicate symbol.
    !,
    $tracebyte_set(P, V).                               % Then set trace byte of P to V

$member(X, [X|Ys]).
$member(X, [Y|Ys]):-
    $member(X,Ys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  flag operations (flag must be a $ symbol so debugger does not trace it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$set_flag(F) :- set_trace(F, 1).
$reset_flag(F) :- set_trace(F, 0).
$flag_is_on(F) :- set_trace(F, V), V \= 0.
$flag_is_off(F) :- set_trace(F, V), V = 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% $enable_tracer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$enable_tracer :-
    enable_trace(0),
    set_trace($debug_on, X),
    enable_trace(X).

$tracer_depth(Depth) :-
    count(goal(tracer(_)), Depth).

$tracer_invocation_id(Id) :-
    $self(main),                                           % are we the main task
    $findgoal(Level, listener), !,                         % find the current listener
    $$tracer_invocation_id(Level, Id),                     % get appropriate Id for this listener
    remember(invocation_identifier(Level, Id), $local).    % remember where we are

$$tracer_invocation_id(Level, Id) :-
    forget(invocation_identifier(Level, X), $local),       % forget any fact associated with it
    successor(X, Id).
$$tracer_invocation_id(_, 1).                              % no fact remembered for this, default 1

$self(main).
      
$findgoal(Addr, Goal) :- 
    goal(0, _, FirstAddr),
    $recurse(FirstAddr, Addr, Goal).

$recurse(Addr, Addr, Goal) :-
    goal(Addr, Goal, _).
$recurse(FirstAddr, Addr, Goal) :-
    goal(FirstAddr, _, NewAddr),
    $recurse(NewAddr, Addr, Goal).

$special(integer).
$special(compound).
$special(float).
$special(list).
$special(structure).
$special(var).
$special(tailvar).
$special(nonvar).
$special(number).
$special(numeric).
$special(symbol).
$special(atomic).
$special(ground).
$special(is).
$special('=').
$special('\\=').
$special(!).
$special(cut).
$special(fail).
$special(failexit).
$special('<').
$special('<>').
$special('=<').
$special('==').
$special('=\\=').
$special('>').
$special('>=').
$special(recall).			%% can't trace through these state space routines
$special(get_obj).			%% since they depend on putting PTR into e(1)
$special(forget).
$special(forget_all).
$special(inventory).

$give_help :-
    nl,
    swrite(1,'The valid commands are : \n'),
    swrite(1,'a -- abort\n'),
    swrite(1,'b -- break\n'),
    swrite(1,'c -- creep\n'),
    swrite(1,'f -- fail\n'),
    swrite(1,'g -- ancestors\n'),
    swrite(1,'h -- help\n'),
    swrite(1,'l -- leap\n'),
    swrite(1,'n -- nodebug\n'),
    swrite(1,'p -- print\n'),
    swrite(1,'r -- retry\n'),
    swrite(1,'s -- skip\n'),
    swrite(1,'w -- write\n'),
    swrite(1,'+ -- spy\n'),
    swrite(1,'- -- nospy\n'),
    swrite(1,'. -- listing\n'),
    swrite(1,'@ -- listener for one command\n'),
    swrite(1,'? -- help\n'),
    swrite(1,'<return> -- creep\n\n').

$initialization :-
    unknown(trace),
	remember(eventflag(overload), $local),
    $reset_flag($debug_on).

debugevents(X) :-
	get_obj(Op, eventflag(Y), $local),
	$debugevents(X, Y, Op).
$debugevents(X, X, _) :- !.
$debugevents(New, _, Op) :- 
	$$debugevents(New),
	put_obj(Op, eventflag(New), $local).

$$debugevents(overload).
$$debugevents(never).
$$debugevents(always).

%
%   $$callindirect is called to meta interpret a list
%	Used so that we can trap calls to cut and failexit and handle
%	temp properly.
%
$$callindirect(L) :-					% need additonal clause for name to cut
	list(L),
	!,
	$$calllistindirect(L),
	true.								% avoid L.C.O. for named 'cut' below
$$callindirect(X) :- X.					% in case not a list

$$calllistindirect([X..]):-				% X: a tailvar -> error: non-executable term
	tailvar(X..),
	error(16).
$$calllistindirect([]) :- !.			% empty list, terminate
$$calllistindirect([X,Xs..]) :-			% X: a var -> error: non-executable term
	var(X),
	error(16).
$$calllistindirect([cut, Xs..]) :-
	!,
    $equal(X, cut($$callindirect)),		% also cuts $$calllistindirect choices
	X,									% meta-interpret so we can see call to cut()
    $$calllistindirect([Xs..]).
$$calllistindirect([failexit, Xs..]) :-
	!,
    $equal(X, failexit($$callindirect)),
	X.									% meta-interpret so we can see call to failexit()
$$calllistindirect([!, Xs..]) :-
	!,
    $equal(X, cut($tracer_visible)),
	X,									% meta-interpret so we can see call to cut()
    $$calllistindirect([Xs..]).
$$calllistindirect([X, Xs..]) :-		% call $$callindirect again for lists
	list(X),
	!,
    $$callindirect(X),
    $$calllistindirect([Xs..]).
$$calllistindirect([X, Xs..]) :-		% execute X normally
    X,
    $$calllistindirect([Xs..]).

$equal(X, X).

$event(find).
$event(replace).
$event(replaceall).
$event(userkey).
$event(usermousedown).
$event(usermouseup).
$event(userdrag).
$event(usergrow).
$event(userzoom).
$event(userclose).
$event(menuselect).
$event(useractivate).
$event(userdeactivate).
$event(userupdate).
$event(userupidle).
$event(balloonidle).
$event(userdownidle).
$event(userswitch).
$event(scrapchanged).
$event(userresize).
$event(userreposition).
$event(userrename).
