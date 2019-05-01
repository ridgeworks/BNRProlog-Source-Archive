/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/slee_listener.p,v 1.7 1998/07/28 00:04:07 csavage Exp $
*
*  $Log: slee_listener.p,v $
 * Revision 1.7  1998/07/28  00:04:07  csavage
 * *** empty log message ***
 *
 * Revision 1.6  1998/06/05  05:59:52  csavage
 * Changed file name of BNR Prolog Console to
 * remove spaces.. BNRPrologConsole
 *
 * Revision 1.5  1996/07/05  11:09:21  yanzhou
 * Now defines a "userupidle" clause to override the default
 * behaviour of sleeping for 0.1 seconds, which is undesirable
 * in applications with embedded Prolog engines.
 *
 * Revision 1.4  1996/07/04  10:43:22  yanzhou
 * Removed the word "Alpa" from the BNRProlog version message.
 *
 * Revision 1.3  1995/10/27  11:53:27  harrisja
 * Remove write statements in listener_msg.  Oops!!
 *
 * Revision 1.2  1995/10/27  11:34:47  harrisja
 * re-enable tracing when leaving listener_msg to allow injected goals to be debugged
 *
 * Revision 1.1  1995/09/22  11:28:38  harrisja
 * Initial version.
 *
*
*/

%%%%
%%%%	Message driven listener for SMT framework use
%%%%

%
%  overload uses standard pde_init in base to get started
%   pde_init normally calls listener to "get interactive"
%   this one just initializes listener context and gets driven
%   by injecting "listener_msg" calls.
% 
listener:-  % normal listener call does initialization...
	!,  % cut out base definition.
	enable_trace(X),
	enable_trace(0),					% debugger must be off
% RWW	$listener_version(1),  % was V, only permit one listener
	$listener_banner(V),
	$listen_convience_prompt,	% post initial prompt
	!,
	% create history control flag and listener buffer only once
	recall(histctrl(_,_),$local) ; remember(histctrl(1,20),$local),
	recall(listener_buffer(_),$local) ; remember(listener_buffer(''),$local),
        forget_all(listener_context(_..),$local),
	new_obj(debugflag(X),DF,$local),	% create initial debugger status flag
	open(Pipe, listener, read_write_pipe, 0),
        remember(listener_context(Pipe,DF),$local).
/*** this drives loop, but slee will just save some state and return...
	!,
	$listener_shell(Pipe, DF),			% once it succeeds, we're out of here
	dispose_obj(DF,$local),				% delete flags on exit
	$listener_close(V),
	close(Pipe, _),
	!,
	fail.
***/

$termination:-  % cleans up after listener
        recall(listener_context(Pipe,DF),$local),
	close(Pipe,_). % esiting context will take care of state space

/* Publicly accessable function to terminate slee when loaded as a lower
   context in the stack. */
   
slee_termination :- $termination.

/*   this stuff is removed in message driven scheme... 
$listener_shell(Pipe, DF) :- 
	%% done in a block to catch the failexit(listener) from continue
	block(listener, $listener_loop(Pipe, DF)).
$listener_shell(_, _).						% always succeed


$listener_loop(Pipe, DF) :-
	repeat,
	capsule($listener(Pipe, DF),
			$listener_error),
	fail.
	
listen :-
	new_obj(debugflag(0),DF,$local),	% create initial debugger status flag
	open(Pipe, listen, read_write_pipe, 0),
	capsule($listener(Pipe, DF),
			$listener_error),
	dispose_obj(DF,$local),				% delete flags on exit
	close(Pipe, _),
	!.


$listener(Pipe, Op) :-
	$cleanup,							% cleanup any base garbage left from previous query
	$listener_read(Pipe, Term, Echo, Op),
	$listener_execute(Op, Term, Echo),
	!.
********/

/*
 *    Message driven listener - called to see if interface needs driving..
 */
listener_loop:-   % for simulation purposes
	$listen_convience_prompt, % post prompt
	repeat,
	listener_msg,
	fail.

listener_msg:-
	 enable_trace(0),	% make sure debugger is disabled on entry
	recall(listener_context(Pipe,DF),$local),cut,
	capsule($listener(Pipe, DF),$listener_error),
	fail.    % fail to clean everything up, next clause always succeeds

listener_msg:-		% selectively re-enable debugger on exit
	 get_obj(Op, debugflag(DebugFlag), $local),
	 enable_trace(DebugFlag).

$listener(Pipe,Op):-
	$listener_read(Pipe, Term, Echo, Op),
	$listener_execute(Op, Term, Echo),
	$listen_convience_prompt. % if something executed post prompt again..


%%%%%
%%%%% $listener_read for stream based system:
%%%%% simply read lines until a term is entered or error encountered
%%%%%

$listener_read(Pipe, Term, $echo_prompt, _) :-
	get_obj(P, listener_buffer(Raw), $local),
	Raw \= '',							% something left over ??
	$read_query(Pipe, '', Term),		% try to make a real term out of it
	!.									% got a good term, return it

$listener_read(Pipe, Term, Echo, Op) :-
	new_counter(0, C),
%%% RWW don't do this each time??	$listen_convience_prompt,			% display the prompt
%%% RWW no loop for message driven system	repeat,
	C,
	$listener_get(Raw, Echo, C, Op),	% two step process to catch aborts inside
	$read_query(Pipe, Raw, Term),		%    $listener block
	!.


$read_query(Pipe, Raw, Query) :-	
	seek(Pipe, end_of_file),			% clear out pipe
	get_obj(P, listener_buffer(B), $local),
	swrite(Pipe, B),					% dump previous text into pipe
	swrite(Pipe, Raw),					% dump text into pipe
	get_term(Pipe, Query, Err),
	$history_record(Err, Query),
	$check_error(Pipe, B, Raw, Err, P).


$listener_get(Line, Echo, _, Op) :-
	predicate(userevent),  % RWW was $userevent
	!,
%%% RWW no loop for message driven system...   repeat,
	userevent(Ev, W, D1, D2, noblock),
	$listener_dispatch(Ev, W, D1, D2, Line, Echo, Op),
	!.
$listener_get(Line, $noecho_prompt, C, _) :-
	readln(0, Raw, 0),
	name(Raw, ListOfChar),
	$history_convert(Raw, ListOfChar, Line, C),
	!.
	
$history_convert(Raw, [0'!, 0'!, _..], Line, _) :-
	% line begins with !! which implies recall last command
	!,
	recall(histctrl(Current, _), $local),
	Last is Current-1,
	recall(history(Last, Query), $local),
	put_term(Line, Query, 0),
	write(Line, '\n').
$history_convert(Raw, [0'?, 0'-, 0' , 0'!, 0'!, _..], Line, _) :-
	% line begins with ?- !! which implies recall last command
	!,
	recall(histctrl(Current, _), $local),
	Last is Current-1,
	recall(history(Last, Query), $local),
	put_term(Line, Query, 0),
	write(Line, '\n').
$history_convert(Raw, [0'!, Rest..], Line, _) :-
	% first char = '!', strip it off, rest of line is pattern
	!,
	name(Raw1, [Rest..]),
	namelength(Raw1, RLen),
	substring(Raw1, RLen, 1, '.') 
		-> Raw2 = Raw1 
		; concat(Raw1, '.', Raw2),
	get_term(Raw2, Indx, 0) ; Indx = Raw1,	% try parsing it, if that fails use directly	
	!,
	$history_retrieve(Indx, Line).
$history_convert(Raw, [0'?, 0'-, 0' , 0'!, Rest..], Line, _) :-
	% line is ?- !..., strip it off, rest of line is pattern
	!,
	name(Raw1, [Rest..]),
	namelength(Raw1, RLen),
	substring(Raw1, RLen, 1, '.') 
		-> Raw2 = Raw1 
		; concat(Raw1, '.', Raw2),
	get_term(Raw2, Indx, 0) ; Indx = Raw1,	% try parsing it, if that fails use directly	
	!,
	$history_retrieve(Indx, Line).
$history_convert(Raw, [Char, _..], Line, C) :-
	% non empty line
	counter_value(C, 1),				% and this is the first line
    substring(Raw, 1, 2, X),			% and the line doesn't start with ?-
	X \= '?-',
	!,
	swrite(Line, '?- ', Raw).			% return a line with ?-
$history_convert(Line, _, Line, C).		% not a history command, just return the line

	
$history_retrieve(0, '?- history.') :-	% special case 0: dump history
	write('?- history.\n').
$history_retrieve(Indx, Line):-			% integer index
	integer(Indx),
	recall(history(Indx, Query), $local),
	put_term(Line, Query, 0),
	write(Line, '\n').
$history_retrieve(Indx, Line):-			% search string
	swrite(Match, Indx),				% make sure its a symbol
	swrite(Match2, '?- ', Match),
	recall(history(_, Query), $local),
	put_term(Line, Query, 0),
	substring(Line, 1, _, Match) ; substring(Line, 1, _, Match2),
	!,
	write(Line, '\n').
$history_retrieve(Indx, _) :-
	write('No match for ', Indx, '\n'),
	failexit($listener).

$history_record(0, Query) :-
	get_obj(Op, histctrl(Current, Size), $local),
	remember(history(Current, Query), $local),
	Next is Current + 1,
	put_obj(Op, histctrl(Next, Size), $local),
	Del is Current - Size,
	Del > 0 -> forget(history(Del, _), $local),
	!.
$history_record(_, _).

$check_error(Pipe, _, _, 0, P) :-
	$listener_flush(Pipe, '', Rest),
	put_obj(P, listener_buffer(Rest), $local),
	!.
$check_error(Pipe, Raw1, Raw2, 2, P) :-
	swrite(Raw, Raw1, '\n', Raw2),      % add newline 93/04/22
	put_obj(P, listener_buffer(Raw), $local),
	!,
	fail.								% wait for next line to be entered
$check_error(_, '', '', -39, _) :-		% possible empty line
	!,
	fail.								% wait for next line to be entered
$check_error(_, Raw1, Raw2, Err, P):-
	once(error_string(syntax,Err,S)),	% map error code to a string
	write('Syntax Error: ',S,'\n Input: ', Raw1, Raw2),
	put_obj(P, listener_buffer(''), $local),
	failexit($listener).				% failexit $listener to get new ?-


$listener_flush(Pipe, First, Rest) :-
	readln(Pipe, Some),							% fails if nothing to read
	$listener_concat(First, Some, SomeMore),	% combine the pieces
	!,
	$listener_flush(Pipe, SomeMore, Rest).		% recurse to read some more
$listener_flush(_, Rest, Rest).					% read failed, return what we have


$listener_concat('', Rest, Rest).				% ignore blank lines
$listener_concat(First, Some, SomeMore) :-		% otherwise concat with a nl
	swrite(SomeMore, First, '\n', Some).			% in the middle


$listener_dispatch(userkey, W, '\03', _, Line, Echo, Op) :-	% ENTER key
	!,
	$listener_dispatch(userkey, W, enter, _, Line, Echo, Op).
$listener_dispatch(userkey, W, enter, _, Line, Echo, _) :-	% ENTER key
    inqtext(W, selectcabs(S,S)),							% no selection
    !,
    dotext(W, selectlrel(0,1)),								% select the whole line
    inqtext(W, selection(Line)),							% get the line
	dotext(W, selectcabs(S,S)),								% reset selection to cursor
	$listener_input(Line),
	$echo_required(W, Echo),
	$position_console_to_newline(1).
$listener_dispatch(userkey, W, enter, _, Line, Echo, _) :-	% ENTER key
    inqtext(W, selection(Line)),							% selection
	!,
    $listener_input(Line),
	$echo_required(W, Echo).
$listener_dispatch(Event, W, D1, D2, _, _, Op) :- 
	$listener_evaluate(Op, Event(W, D1, D2), _),
	!,
	fail.	
$listener_dispatch(_, _, _, _, _, _, Op) :- % here if event fails
    enable_trace(Y),						% get new tracing value
    enable_trace(0),						% clear it
    put_obj(Op, debugflag(Y), $local),		% remember new value for next attempt
	fail.

$listener_input('?- ') :-
    !,
    dotext(W, replace('\n?- ')),
	fail.
$listener_input(_).


$echo_required(W, $noecho_prompt) :-
    $console(W),
    inqtext(W, [lsize(NumLines), selectlabs(NumLines,NumLines),
                csize(NumChars), selectcabs(Start, End)]),
    (End = NumChars) ; (Start = End),
    !.
$echo_required(_, $echo_prompt).


%%%%%
%%%%% listener_execute(Term)
%%%%% execute Term properly
%%%%%
$listener_execute(Op, Cmd, EchoCmd) :-
    $cmd_interpretation(Cmd, Interpretation, Term),
    EchoCmd(Interpretation, Term),
    Interpretation(Op, Term),
    !.

$cmd_interpretation(F(Term1,X..), $eval_query, Term) :-
    (F(X..) @= '?-'()),
    $query_directive_coerce(Term1, Term),
    !.
$cmd_interpretation(F(Term1,X..), $eval_directive, Term) :-
    (F(X..) @= ':-'()),
    $query_directive_coerce(Term1, Term),
    !.
$cmd_interpretation(Term1, $eval_assertion, Term) :-
    $clause_coerce(Term1,Term),
    !.
$cmd_interpretation([F(Term1), X..], Cmd, Term) :-
    ((F @= '?-') ; (F @= ':-')),
    $cmd_intepretation(F([Term1, X..]), Cmd, Term).

$query_directive_coerce(Term, Term()) :-
    symbol(Term).
$query_directive_coerce(Term, Term).

$clause_coerce(P, (P() :- [])) :-
    symbol(P),
    !.
$clause_coerce(P(As..), (P(As..) :- [])) :-
    (P @\= ':-'),
    !.
$clause_coerce(':-'(A,B..), (H :- [B..])) :-
    tailvar(B..),
    $clause_coerce_head(A, H),
    !.
$clause_coerce(':-'(A, X, Y..), (H :- B)) :-
    [Y..] @= [],
    $clause_coerce_head(A, H),
    $clause_coerce_body(X, B),
    !.

$clause_coerce_head(P, P()) :-
    symbol(P).
$clause_coerce_head(P, P) :- 
    structure(P).

$clause_coerce_body(L, L) :-
    list(L).
$clause_coerce_body(P, [P]).


$noecho_prompt(_,_) :-
    $position_console_to_newline(0).

$echo_prompt(Interp, Term) :-
	$position_console_to_newline(1),
	$echo(Interp, Term).

$echo($eval_query, Term) :-
	$outputwithindent(Term, '?- ', '.\n'),
	!.
$echo($eval_directive, Term) :-
	$outputwithindent(Term, ':- ', '.\n'),
	!.
$echo(_, Term) :-
	$outputwithindent(Term, '', '.\n'),
	!.

$eval_query(Op, Term) :-                % a query
	new_counter(0, NumSolns),	% counter for number of solutions
	$mult_soln(Op, Term, NumSolns),	% leaves no choice pts
	counter_value(NumSolns, N),
	$echo_response(N),		% output YES or NO on a new line depending on # solns
	!.

$eval_directive(Op, Term) :-            % a directive
	$eval_it(Op, Term, 1, 0).

$eval_assertion(Op, Term) :-           	% an assertion
	$eval_it(Op, assertz(Term), -1, -2).

$eval_it(Op, Term, Yes, No) :-
    $listener_evaluate(Op, Term, _),	% IF TERM succeeds
	!,
    $echo_response(Yes).				% 	say OK
$eval_it(Op, Term, Yes, No) :-			% ELSE
    enable_trace(Y),					% get new tracing value
    enable_trace(0),					% clear it
    put_obj(Op, debugflag(Y), $local),	% remember new value for next attempt
    $echo_response(No).              	% 	say NOT OK

$echo_response(0) :-
    $position_console_to_newline(1),
    write('NO\n').
$echo_response(-1) :-
    $position_console_to_newline(1),
    write('OK\n').
$echo_response(-2) :-
    $position_console_to_newline(1),
    write('NOT OK\n').
$echo_response(_) :-
    $position_console_to_newline(1),
    write('YES\n').

$mult_soln(Op, Term, SolnCntr) :-
    $$mult_soln(Op, Term, SolnCntr),
    !.
$mult_soln(Op, _, _) :-         		% Alternative solutions to Term exhausted.
    enable_trace(Y),				% get new tracing value
    enable_trace(0),				% clear it
    put_obj(Op, debugflag(Y), $local).		% remember new value for next attempt

/*** RWW this mode not supported...
$$mult_soln(Op, Term, SolnCntr) :-
    recall(variablesubstitutions(on), $local),
	!,
    $var_list(Term, Vs, TVs),
    $rm_dup(Vs, V),				% Remove any duplicates in the var and 
    $rm_dup(TVs, TV),				% tailvar list
    $setvars(V, TV, NV, NTV),
	new_counter(0, ContFlag),		% create counter for continuation flag
	!,
	$listener_evaluate(Op, Term, X),	% do Query, if Query succeeds,
	SolnCntr,             			% increment solution counter
	once($writevars(NV, V, 0, Output1)),	% Output computed answer substitutions
	once($writevars(NTV, TV, Output1, Output)),
	enable_trace(X),			% set flag in case more_cp's fails
	inline$(more_choicepoints),			% FAILS if there are no remaining choice pts
	enable_trace(0),
	$alternate_soln(Output, ContFlag, ' ;\n\n').	% Determine Mode for next soln 
***/

$$mult_soln(Op, Term, SolnCntr) :-
	new_counter(0, ContFlag),		% create counter for continuation flag
	$listener_evaluate(Op, Term, X),	% do Query, if Query succeeds,
	SolnCntr,				% increment solution counter
	$output_cas(Term),			% output computed answer substitutions
	enable_trace(X),			% set flag in case more_cp's fails
	!,fail.   % no funny backtracking for message driven system, one solution only
/*** RWW
	inline$(more_choicepoints),		% FAILS if there are no remaining choice pts
	enable_trace(0),
	$alternate_soln(1, ContFlag, '\n').	% Determine Mode for next soln 
***/

$output_cas(Term) :-
	$outputwithindent(Term, '    ?- ', '. ').
	
$outputwithindent(Term, Leading, Trailing) :-
	swrite(1, Leading),
/*** RWW have to use global pretty printer
	$ppindent(1, '', Leading, NextLineIndent),
	$pplength(1, MaxWidth, _),
	$pretty_print(1, Term, NextLineIndent, MaxWidth, 0),
***/	print(Term),
	write(Trailing),
	!.

$setvars(V, TV, _, _) :-
    bind_vars(V),                    % bind vars to names
    remember(vars$(V)),              % and put them in state space
    bind_vars(TV),                   % ditto for tailvars
    remember(tvars$(TV)),
    fail.                            % fail to unbind original vars

$setvars(_, _, Names, TVNames) :-
    forget(vars$(Names)),            % picks up names from state space
    forget(tvars$(TVNames)).

$writevars(['_', Names..], [_, Vars..], C0, C) :- % ignore anonymous vars
    $writevars(Names, Vars, C0, C).

$writevars(['[_..]', Names..],[_, Vars..], C0, C) :- % ignore anonymous tailvars
    $writevars(Names, Vars, C0, C).

$writevars([Name, Names..],[Var, Vars..], C0, C):- % output variable bindings
    C0 @= 0 
    ->  $position_console_to_newline(1)
    ;   swrite(1, ',\n'),
    swrite(Indent, '    ', Name, ' = '),
	$outputwithindent(Var, Indent, '. '),
    successor(C0,C1),
    $writevars(Names, Vars, C1, C).

$writevars([], [], C, C).

$listener_evaluate(Op, Term, NewDebugFlag) :- 
    get_obj(Op, debugflag(OldDebugFlag), $local),
    enable_trace(OldDebugFlag),						% set tracing as predetermined
    Term,
    enable_trace(NewDebugFlag),						% get new tracing value
    enable_trace(0),								% clear it
    put_obj(Op, debugflag(NewDebugFlag), $local).	% remember new value for next attempt

/*  this modal stuff can't be supported in message driven system...
$alternate_soln(0, _, _).		% simply succeed since there was no output
												% so more answers pointless
$alternate_soln(_, Cntr, Msg) :-
	counter_value(Cntr, N),		% get flag value
	N > 0,				% non-zero means <cr> pressed
	write(Msg),
	!, fail.			% fail to get next solution
$alternate_soln(_, Cntr, _) :-
	predicate($userevent),
    repeat,
    userevent(Event, Window, D1, D2, noblock),
    $alternate_soln_aux(Event, Window, D1, D2, Cntr, 1),
    !.
$alternate_soln(_, Cntr, _) :-
	readln(Response),
    $alternate_soln_aux(userkey, _, Response, _, Cntr, 0),
	!.

$alternate_soln_aux(userkey, _, '\r', _, Cntr, Echo) :-	% user hit return
	$position_console_to_newline(0),
    !,
	Cntr,
    failexit($alternate_soln).
$alternate_soln_aux(userkey, _, '', _, Cntr, Echo) :-	% user hit return in console mode
	$position_console_to_newline(0),
    !,
	Cntr,
    failexit($alternate_soln).
$alternate_soln_aux(userkey, _, ';', _, _, Echo) :-	% user hit ';', get next answer
	Echo = 1 -> write(';\n'),
    !,
    failexit($alternate_soln).
$alternate_soln_aux(userkey, _, '~', _, _, Echo) :-	% user hit '~', list remaining choicepoints
	Echo = 1 -> write('~\n'),							% added Feb 24/93
    !,
	traceback(choicepoints),
    failexit($alternate_soln).
$alternate_soln_aux(userkey, _, _, _, _, _) :-		% any other key is terminate
	$position_console_to_newline(0).
$alternate_soln_aux(Event, Window, D1, D2, Op, _) :-
    once(Event(Window, D1, D2)),
    failexit($alternate_soln_aux).
***/


%%%% Error Handling Facilities

%%%% On a <command .>,   the attention_handler() is called.
% 1st clause provides the user with the option of a stack dump.
% 2nd assumes no listener (i.e., failexit[listener] failed!!). Note error[13] dumps stack.

attention_handler :-  % RWW simplified handler for message driven system
	traceback,			% want to be in attention_handler for this
	failexit(listener_loop).	% return to main listener loop

/* RWW standard version
attention_handler :-
	$attention_handler(R),
	!,
	R = 'NO' -> failexit($listener),
	R = 'CANCEL' -> failexit,
	write('User abort:\n'),
	traceback,			% want to be in attention_handler for this
	failexit($listener).		% return to listener loop

$attention_handler(R) :-
	confirm('User abort:\nDo you want a traceback?', 'YES', 'YES', R).
$attention_handler('CANCEL') :-
	predicate($openwindow).		% user selected cancel if confirm came up
$attention_handler('YES') :-
	write('User abort:\nEnter \'y\' if you want a traceback:'),
	readln(Line),
	lowercase(Line,'y').
$attention_handler('NO').
****/
	
$listener_error:-
	get_error_code(C, TB),				% get error number and traceback
	C \= 0,								% ignore errors of 0
	error_string(run_time, C, S),		% map to a string
	swrite(Msg, 'Run Time Error: ', S, '\n'),
	$listener_tb(Msg, TB),
	!.									% no longer in the scope of $execute

$listener_tb(Msg, TB) :-
/* RWW always output traceback..
	swrite(S, Msg, 'Do you want a traceback?'),
	confirm(S, 'NO', 'YES', R),*/
	write(Msg),
	$listener_display_tb(R, TB),
	!.
$listener_tb(Msg, TB) :-
	write(Msg),
	write('Enter \'y\' if you want a traceback:'),
	readln(Line),
	lowercase(Line,'y'),
	$listener_display_tb('YES', TB),
	!.
$listener_tb(_,_).

$listener_display_tb('YES', TB) :-
	write(TB), 
	nl.
$listener_display_tb(_, _).

%%%
%%%  history command for listener
%%%

op(250,fx,history).	% define operator for cshell-like syntax

history():-
	recall(histctrl(Current,Size),$local),
	!,
	$history(Size,Current).

history N:-
	recall(histctrl(Current,_),$local),
	!,
	$history(N,Current).

$history(N,_) :- 
	N<1, 
	!.
$history(N,Current):-
	Indx is Current-N,
	recall(history(Indx,Query),$local)->
	   [$indxpad(Indx,Pad),write(Pad,Indx,'  '),writeq(Query),write('.\n')],
	N1 is N-1,
	$history(N1,Current).

$indxpad(Indx,'     '):-Indx<10,!.	%    0=<Indx=<9
$indxpad(Indx,'    '):-Indx<100,!.	%   10=<Indx=<99
$indxpad(Indx,'   '):-Indx<1000,!.	%  100=<Indx=<999
$indxpad(Indx,'  ').				% 1000=<Indx

/* RWW no nested listeners in message driven system...
$listener_version(V) :-
	$count_listeners(V).
$listener_version(1).

$count_listeners(N) :-
	new_counter(0, C),
	goal(0, _, Ptr),
	$count_them(Ptr, C),
	counter_value(C, N).

$count_them(Ptr, C) :-
    goal(Ptr, listener, Ptr1),		% if we see listener followed by
    goal(Ptr1, listener, Ptr2),		% another listener, then count as one
	!,
	C,
	$count_them(Ptr2, C).
$count_them(Ptr, C) :-				% not a listener pair, simply recurse
    $goal(Ptr, Goal, Ptr1), 
	Goal = listener -> C,			% if the goal is listener, then count it
	!,
    $count_them(Ptr1, C).
$count_them(_, _).					% no more goals
*/
	
$listener_banner(_) :-				% try to activate the console if possible
	$console(Console),
	iswindow(Console, _..),			% may fail if no windows present
	activewindow(Console, text),	% make console visible
	fail.							% now go print the banner
$listener_banner(1) :-
	!,
	version([A,B,C]),
	write('\nBNR Prolog Version ',A,'.',B,'.',C,' (message driven)\n'),
	write('This listener does not support nested listeners or\n'),
	write(' interactive mode for generating multiple answers to a query.\n'),
	write(' Use findall to output multiple answers.\n').
/**** RWW never have nested listeners and never close them ...
$listener_banner(V) :-
	V > 1,
	V1 is V - 1,
	write('\nBreak (level ', V1, ')\n').
$listener_close(1) :- !.
$listener_close(V) :-
	V > 1,
	V1 is V - 1,
	write('\nExit Break (level ', V1, ')\n').
****/
	
$position_console_to_newline :-
	!,
	$position_console_to_newline(1).
$position_console_to_newline(_) :-
	$console(W),
	dotext(W, [selectcabs(end_of_file,end_of_file), selectlrel(0,1)]),
	inqtext(W, selection(Sel)), 
	$listen_position_aux(W,Sel),
	!.
$position_console_to_newline(1) :-		% if all else fails just output a newline, if required
	!, nl.
$position_console_to_newline(_).		% always succeed

$listen_position_aux(W,'').
$listen_position_aux(W,'?- ') :-
	dotext(W, edit(clear)).
$listen_position_aux(W,_) :-
	dotext(W, [selectcabs(end_of_file,end_of_file), replace('\n')]).


$listen_convience_prompt :-
	$console(W),
	dotext(W, [selectcabs(end_of_file,end_of_file), selectlrel(0, 1)]),
	inqtext(W, selection(Sel)),
	dotext(W, selectcabs(end_of_file,end_of_file)),
	$issue_convience_prompt_aux(Sel, W),
	!.
$listen_convience_prompt :-
	nl,
	write('?- ').

$issue_convience_prompt_aux('', W) :-			% on blank line
	dotext(W, replace('?- ')),
	!.
$issue_convience_prompt_aux('?- ', W) :- !.		% already there
$issue_convience_prompt_aux(_, W) :-
	dotext(W,replace('\n?- ')).



%%% last $cleanup clause to ensure success
$cleanup.

$console('BNRPrologConsole').

% yanzhou@bnr.ca:04/07/96
% Override the default userupidle behaviour
% Begin patch
userupidle(_,_,_) :- !.
% End patch
