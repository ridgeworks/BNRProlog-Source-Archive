/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/tasking.p,v 1.1 1995/09/22 11:28:58 harrisja Exp $
*
*  $Log: tasking.p,v $
 * Revision 1.1  1995/09/22  11:28:58  harrisja
 * Initial version.
 *
*
*/
/*
 *	Tasks - Prolog code for task support
 *
 *	BNR Prolog
*/

initiate(GSize, CSize, Pred, Taskname):-	  %task initiation
	$init_task($task,GSize,CSize, Taskname, Id), %initial pred must be varfree list/function
	$task_switch(Id,0),			  % start up new task, let it get to wait/2
	send(Id, Pred).				  %pass initial predicate to shell

%   Generate task ids
$task_generator(T, T).
$task_generator(S, T):-
	$next_task(S, T1),
	$task_generator(T1, T).


$taskmap(T,Tn) :- 
		symbol(Tn),!,
		task_name(T,Tn).

$taskmap(T,T) :-
		task(T).
			
%   Public test/generate taskids
	
task(T) :-
	$test_task(T).
task(T) :-
	var(T),
	$next_task(_, T1),
	$task_generator(T1, T).

%   Send primitive
send(T, M) :-
	selfID(X),
	new_obj(msg(X,M),Pointer,$local),!,
	$sending(T,M,Pointer),
	dispose_obj(Pointer,$local).

$sending(T, M, Pointer) :-
	$taskmap(T1,T),
	task_tracer(send(T, M)),
	$task_switch(T1,Pointer),
	get_obj(Pointer,Msg,$local),
	msg(T1,M) = Msg,
	!.

$sending([H,P], M, Pointer) :-		% Used to send a message over a network
	task_tracer(networksend([H,P], M)),
	networktasksend(H,P,M),
	!.

$sending(T, M, Pointer) :-
	dispose_obj(Pointer,$local),
	fail.

wait(T,M) :-
	not(self(main)),
	task_tracer(wait(T, M)),
	selfID(X),
	remember(waiting(X,M),$local),!,
	repeat,
	$task_switch(T, Pointer),
	get_obj(Pointer,msg(T2,M2),$local),
	task_tracer(received(T2,M2)),
	$taskmap(T1,T),
	T1 = T2, M = M2,
	task_tracer(accepted(T, M)),
	!,
	forget(waiting(X,_),$local),
	put_obj(Pointer,msg(X,M),$local),
	$reply.

wait([H,P],M) :-			% Used to wait for a message over a network
	self(main),
	task_tracer(networkwait([H,P], M)),
	networktaskwait(H,P,M),
	task_tracer(accepted([H,P], M)).

$task :-
	task_tracer(newtask),
	cut,
	capsule($task2,error_in_task),fail.
$task :-
	task_tracer(endtask),
	failexit($task).

$task2 :- 
	wait(X,M),block(task,M).

error_in_task :-
	self(T),
	get_error_code(C),
	nl,
	write('Error ',C,' in task ',T),
	fail.

task_status(T, Invoker, Invokee, Receive, Name) :-
	task(T),
	$task_status(T, Invoker, Invokee, Receive2, Name),
	[recall(waiting(T,Receive),$local) ; Receive is Receive2, cut].

task_name(Task, Name) :-
	task_status(Task,_,_,_,Name).

task_tracer(Msg) :-
	task_tracing,
	self(Self),
	nl,
	swrite(1, Self, ': ', Msg),
	cut,
	fail.

task_tracer(_).

task_tracing :- fail.

terminate :-
	not(self(main)),
	failexit(task).

terminate(T) :-
	not(var(T)),
	self(T),self(X),X \= main,
	forget_all(waiting(T,_),$local),
	!,
	terminate.

terminate(T) :-
	not(var(T)),
	$taskmap(Id,T),
	$end_task(Id),!,
	task_tracer(endtask(T)),
	forget_all(waiting(Id,_),$local),
	!.


	
