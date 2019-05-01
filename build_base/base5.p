/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base5.p,v 1.4 1998/02/25 08:15:23 csavage Exp $
*
*  $Log: base5.p,v $
 * Revision 1.4  1998/02/25  08:15:23  csavage
 * Error 42 changed to give "too many arguments"
 * at 126 rather than 256
 *
 * Revision 1.3  1995/11/20  11:42:54  yanzhou
 * iswindow(_..) now defined as `fail' by default.
 *
 * Revision 1.2  1995/11/07  17:27:43  yanzhou
 * Added: predicate pae_init.
 *
 * Revision 1.1  1995/09/22  11:21:31  harrisja
 * Initial version.
 *
*
*/
/*
 *	 Ring 5+ of BASE
 */

%%%% Error Handling Facilities

attention_handler :-        % 1st clause failed (no listener, no console, ..)
    error(13).              % generate run time error 13: 'User aborted execution'

%%%
%%%  Syntax and Run Time Error Strings
%%%
%%% These may be removed to save space (don't remove the last one)

error_string(Class,N,S) :-
	$error_string(Class,N,S),
	!.
error_string(Class,N,S) :-
	integer(N),swrite(S,N).


$error_string(syntax,-39,'End of input').	% same as IO Error code
$error_string(syntax,  2,'Incomplete term').
$error_string(syntax,  4,'Missing operand').
$error_string(syntax, 16,'Bad character in this symbol').
$error_string(syntax, 17,'.. does not follow a variable').
$error_string(syntax, 20,'Operator expected').
$error_string(syntax, 24,'Mismatch of bracket types').
$error_string(syntax, 30,'Invalid operator combination').
$error_string(syntax, 33,'Invalid character in token').
$error_string(syntax, 34,'Incomplete expression').
$error_string(syntax, 35,'Abandoned parsing').
$error_string(syntax, 36,'Unexpected parsing action').
$error_string(syntax, 42,'Too many arguments (limit 125)').
$error_string(syntax, 43,'Extra closing bracket ), ], or }').
$error_string(syntax, 44,'Invalid integer format').
$error_string(syntax, 45,'| not in a list').
$error_string(syntax, 46,'Invalid operator definition').
$error_string(syntax, 47,'/* comment not terminated').

$error_string(run_time,   1,'Dangling reference to a term that no longer exists').
$error_string(run_time,  13,'User abort').
$error_string(run_time,  16,'Non-executable term').
$error_string(run_time, 100,'Out of free memory').
$error_string(run_time, 101,'Global stack (heap/trail) overflow').
$error_string(run_time, 102,'Local stack (env/cp) overflow').
$error_string(run_time, 103,'Name in cut/failexit not found').
$error_string(run_time, 104,'Divide by zero').
$error_string(run_time, 105,'Arithmetic error').
$error_string(run_time, 107,'State space corruption').
$error_string(run_time, 108,'Unable to copy looped structure to state space').
$error_string(run_time, 109,'Internal error').
$error_string(run_time, 110,'Structure too big to be copied into state space').
$error_string(run_time, 111,'Unable to load clause since predicate closed').
$error_string(run_time,  -1,'Initial goal failure').

$error_string(IO, 9999,'Unknown').
$error_string(IO, 9998,'Invalid operation on console').
$error_string(IO, 9997,'Invalid Prolog stream').
$error_string(IO, 9996,'File not found').



%%%
%%%  Debugger support
%%%
%%%  enable_trace(X) either queries or sets trace status
%%%  set_trace(P, X) either queries or sets the trace byte for a predicate
%%%  unknown(X) either queries or sets the unknown flags
%%%


set_trace(P, X) :-
	symbol(P),
	$debugable(P, X),
	!.

$debugable(enable_trace, X) :- !, X = 0.
$debugable(tracer, X) :- !, X = 0.
$debugable(set_trace, X) :- !, X = 0.
$debugable(set_trace_all, X) :- !, X = 0.
$debugable(unknown, X) :- !, X = 0.
$debugable(P, X) :-
	name(P, [36, _..]), 				% name begins with $
	$predicate_aux(P, Cx, Fn),			% get context of it
	Cx = base,							% fail to next clause if not in base
	Fn = base,
	!,
	X = 0.								% trace bits can only be 0
$debugable(P, X) :- $set_trace(P, X).

set_trace_all(AndMask, OrMask, [Clear..]) :-
	$set_trace_all(AndMask, OrMask, [enable_trace, 
                                     tracer, 
									 set_trace, 
									 set_trace_all, 
									 unknown, 
									 Clear..]).

unknown(V) :- 
    $unknown(X),			% get current setting
	$$unknown(X, V),		% see if it matches
    !.						% yes, so succeed
unknown(trace) :-
    $unknown(1).
unknown(fail) :-
    $unknown(0).

$$unknown(0, fail).
$$unknown(1, trace).


%%%
%%%  goal, caller, and grand_caller
%%%

goal(Ptr, Goal, NPtr) :- !, $goal(Ptr, Goal, NPtr).

goal(Goal) :-
    $goal(0, _, Ptr),               % get Ptr to caller of Goal
    $next_goal(Ptr, Gn),            % start generating solutions at our caller
    Goal = Gn.

$next_goal(Ptr, Goal) :-
    $goal(Ptr, Goal, _).
$next_goal(Ptr, Goal) :-
    $goal(Ptr, _, NPtr), 
    $next_goal(NPtr, Goal).


caller(Goal) :-                     % *** Can't use grand_caller because of LCO
    $goal(0, _, Ptr1),              % first goal is caller
    $goal(Ptr1, Goal, _).           % next goal is who called us

grand_caller(Goal) :-               % For users when they decide to play "write a debugger"
    $goal(0, _, Ptr1),              % first goal is grand_caller
    $goal(Ptr1, _, Ptr2),           % next goal is who called us
    $goal(Ptr2, Goal, _).           % finally, the goal that called our caller


%%%
%%%  traceback/[0,1]
%%%  changed to output to a specified stream
%%%
traceback :-
	$outstream(1, FileP),
	!,
	$traceback(FileP, 16).
traceback(N) :-
	$outstream(1, FileP),
	!,
	$traceback(FileP, N).


%%%
%%%  break
%%%  start up a new copy of the listener
%%%
break :-
	enable_trace(X),				% get current state
	enable_trace(0),				% make sure debugging is off
	$break,							% call a listener
	enable_trace(X).				% turn debugging back to previous state
	
$break :-
	once(listener),					% execute the listener, most likely fails from continue
	fail.							% force failure to recover space
$break.								% always succeed


%%%
%%%  continue
%%%  exit listener, resume where break called
%%%
continue :- 
	$count_listeners(N),
	N > 1 -> failexit(listener),	% bye,bye listener
	!.								% only 1 listener, do nothing


%%%
%%%  configuration/4
%%%  first number not used, but left for compatibility
%%%
configuration(Unused, HeapSize, EnvSize, InitialGoal) :-
    var(Unused, HeapSize, EnvSize, InitialGoal),
    !,
    $getconfig(Unused, HeapSize, EnvSize, InitialGoal).

configuration(Unused, HeapSize, EnvSize, InitialGoal) :-
    $getconfig(U, HS, ES, IG),
    $confignumber(Unused, U),
    $confignumber(HeapSize, HS),
    $confignumber(EnvSize, ES),
    $configmatch(InitialGoal, IG),
    put_term(Y, configuration(Unused, HeapSize, EnvSize, InitialGoal), 0),
    $configuration(Y).

$getconfig(U, HS, ES, IG) :-
    $configuration(X),
    get_term(X, configuration(U, HS, ES, IG), 0),
    !.
$getconfig(0, 0, 0, []).

$confignumber(User, _) :- 
    integer(User), !.
$confignumber(Curr, Curr) :-
    integer(Curr).

$configmatch(User, _) :-
    symbol(User), !.
$configmatch(User, _) :-
    compound(User), !.
$configmatch(Curr, Curr) :-
    symbol(Curr), !.
$configmatch(Curr, Curr) :-
    compound(Curr).


%%%
%%% Default code to start up Prolog without the listener
%%%

pae_init :-
	gc(1000),
    getappfiles(Files),
	$checkuserbase(Files),
	$create_context(userbase, '::'),
	fail.

pae_init :-
    getappfiles(Files),
	$checkfiles(Files),
	fail.

pae_init :-
	$getconfig(_, _, _, InitialGoal),
	$tryto(InitialGoal, "Initial Goal ", InitialGoal, " failed"),
	fail.

pae_init :-
	!.

%%%
%%% Default code to start up our listener
%%%

pde_init :-
	gc(1000),					% turn gc on by default
	once($openconsolewindow),
	fail.
	
pde_init :-
	pae_init,
	fail.

pde_init :-
	listener.


$checkuserbase([]).
$checkuserbase(['-nouserbase', _..]) :-
	!,
	fail.
$checkuserbase([_, Ps..]) :-
	$checkuserbase([Ps..]).

$checkfiles(['-execute', P, Ps..]) :-
	!,
	$checkexecute(P),
	$checkfiles([Ps..]).
$checkfiles(['-load', P, Ps..]) :-
	!,
	$checkfiles([Ps..]).
$checkfiles([P, Ps..]) :-				% skip things that begin with -
	substring(P, 1, 1, '-'),
	!,
	$checkfiles([Ps..]).
$checkfiles([P, Ps..]) :-
	open(_, P, read_write_window, _) -> true,
	$checkfiles([Ps..]).

$checkexecute(P) :-
	swrite(N, P, '. '),
	sread(N, T),
	$tryto(once(T), "-execute predicate ", P, " failed"),
	fail.
$checkexecute(_).

% yanzhou@bnr.ca:20/11/95:
% get iswindow(_..) defined as `fail' here to satisfy the debugger

iswindow(_..) :- fail.

% end

