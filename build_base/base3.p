/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base3.p,v 1.1 1995/09/22 11:21:22 harrisja Exp $
*
*  $Log: base3.p,v $
 * Revision 1.1  1995/09/22  11:21:22  harrisja
 * Initial version.
 *
*
*/

/*
 *  Ring 3 of BASE
 */

$base(3).

%%%
%%%  Contexts (only from .a files)
%%%

context(Cx) :-                              % Generate/Confirm context name(s)
    $context(Cx, _).                        % Ignore the Fn

context(Cx, Fn) :-                          % Generate/Confirm Cx and/or Fn name(s)
    $context(Cx, Fn).                       % Do it.


with_context(Cx, Code) :- 
    enter_context(Cx),                      % Enter the context
    (not(Code) ->                           % IF Code fails (exports no bindings) 
          [exit_context(Cx),fail]),         % THEN exit the context, and FAIL
    exit_context(Cx),                       % ELSE exit the context
	true.

enter_context(Cx) :-                        % A user context - no associated file
    symbol(Cx),                             % Require Cx to be a symbol (See bug fix above)
    gensym('::', Fn),                       % Recognizable and unique id serves as Fn
    $create_context(Cx, Fn).                % Create (enter) the new context 


exit_context(Cx) :-
    symbol(Cx),                             % Permit only symbols. Confirm some context 
    $context(Cx, Fn),                       % has name Cx. (More than one context may.)
    !,                                      % Commit - entitled to pop exactly one context.
    $remove_context(Cx, Fn),                % Pop TOPMOST context having name Cx.
	true.


load_context(Cx) :-                         % Cx bound; find associated file.
    symbol(Cx),                             % Accept only symbols
    $resolve_filename(Cx, Fn),              % Get file name, Fn, for context Cx.
    $load_file_as_context(Fn, Cx),          % load Fn as context Cx.
    !.                                      % Commit


consult(Fn) :-
	$resolve_filename(Fn,Fn1),
	$loadfile(Fn1).


$create_context(Cx, Fn) :-
    $tryto($enter_context(Cx, Fn),			% try to create context
		   'Unable to enter context ',		% message if we fail
		   Cx:Fn),
	$add_context_to_menus(Cx) -> true.


$remove_context(base, base) :-              % To remove context base, simply remove 
    $remove_context(userbase, '::'),        % context userbase.
    !.                                      % Commit.     

$remove_context(Cx, Fn) :-                  % Cx must be bound, not fussy about Fn; if a var,
    symbol(Cx),                             % 1st context with  name Cx is popped. 
    $context(Cx, Fn),                       % CHOICE POINT. Topmost context unifiable with Cx and Fn
    $context(Cx1, Fn1),                     % The first/very topmost context is Cx/Fn.
	$cleanup_context(Cx1, Fn1),
    $exit_context(Cx1, Fn1),                % Pop top context and
    (Cx = Cx1),                             % Repeat until selected context
    (Fn = Fn1),                             % reached.
    (([Cx, Fn] = [userbase, '::']) ->       % IF selected context is userbase
        $create_context(userbase, '::')),   % THEN recreate the context (after purging contents)
    !.                                      % Commit

$cleanup_context(Cx, Fn) :-
	swrite(Finish, $termination),			% Local to current context
    $predicate(Finish),				        % IF user has defined clauses for it
	cut,									% (in case Finish fails, don't look for more clauses)
    $tryto(Finish, 							% THEN call Finish and output msg if it fails 
    	   '$termination failed in context ', Cx:Fn),
	cut,									% only execute Finish once
	fail.									% to remove $termination symbol
$cleanup_context(Cx, Fn) :-                 % remove from menu if possible
	$rem_context_from_menus(),
	!.
$cleanup_context(_, _).						% always succeed

$load_file_as_context(Fn, _) :-				% succeed if file already loaded
    $context(_, Fn),
    !.
$load_file_as_context(Fn, Cx) :-			% succeed if context loaded, possibly
    $context(Cx, FFn),						% under different file name (with
	$generatenames(FFn, Source, Binary),	% or without .a)
	Fn = Source ; Fn = Binary,
    !.
$load_file_as_context(Fn, Cx) :-            % given _Cx and fullfilename _Fn 
    $create_context(Cx, Fn),                % create context _Cx
    $loadfile(Fn),                          % load file _Fn
	$execute_$init(Cx, Fn),					% execute $initialization if it exists
    !.                                      % Commit
$load_file_as_context(Fn, Cx) :-            % previous consult failed
    $remove_context(Cx, Fn),                % remove context,
    write('\nUnable to load file ', Fn:Cx), % output message (may fail), and
    fail.                                   % fail

$execute_$init(Cx, Fn) :-
    swrite(Init, $initialization),  		% Local to current context
    $predicate(Init),					    % IF user has defined clauses for it
	cut,
    $tryto(Init, 							% THEN call Init and output msg if it fails 
		   '$initialization failed in context ', Cx:Fn),
	cut,
	fail.
$execute_$init(_, _).

$loadfile(Fn) :-
	concat(_, '.a', Fn),					% file ends in .a
	!,
	write('Loading ', Fn, ' into memory...\n') -> true,
	$consult(Fn).							% load binary file
%%% Clause for $loadfile in R4 for text files


$context(Cx, Fn) :-							% Confirm/Generate contexts
    $context_list(L),                       	% Get list of existing contexts (includes base)
    $member2(Cx, Fn, L).                    	% Find Cx/Fn in list


$resolve_filename(base, '') :- !.				% CASE 1: Cx is "base" and it has no Fn.
$resolve_filename(userbase, '::') :- !.			% CASE 2: Cx is "userbase" and it has no Fn.
$resolve_filename(Cx, Fn) :-					% CASE 3: there is a Fn associated with Cx.
    fullfilename(Cx, Fn1),						% Get the full file name Fn of Cx, know source exists.
	!,
	$generatenames(Fn1, Source, Binary),		% generate names for source and binary
	$determinefile(Source, Binary, Fn).			% decide which one to use
$resolve_filename(Cx, Fn) :-					% CASE 4: there is a Fn.a associated with Cx.
	concat(Cx, '.a', NCx),						% generate name with .a
	$test_existance(NCx, Fn),
	!.
	
$test_existance(Fn, FFn) :-
	primitive(fullfilename),					% fullfilename loaded (R4) ??
	!,											% commit to result of fullfilename
    fullfilename(Fn, FFn).
$test_existance(Fn, Fn).						% just assume it exists, only in R3

$resolve_context(Cx, Cx, Fn) :-					% CASE 1: Cx is an existing context having
    $context(Cx, Fn),							% associated file Fn.
    !.
$resolve_context(Cx1, Cx, Fn) :-				% CASE 2: Cx1 is partial or full filename of existing 
    fullfilename(Cx1, Fn1),						% context. Get full filename, Fn1, corresponding to Cx1.
	$generatenames(Fn1, Source, Binary),		% get matching file names
	$resolve_fn(Fn, Source, Binary),			% try options for Fn
    $context(Cx, Fn),							% Get Cx name under which Fn is loaded.
    !.

$resolve_fn(Fn, Fn, _).
$resolve_fn(Fn, _, Fn).

$generatenames(Fn, Source, Fn) :-				% if Fn ends in .a use as binary name,
	concat(Source, '.a', Fn), !.				% make source name without .a
$generatenames(Fn, Fn, Binary) :-				% Fn doesn't end in .a,
	concat(Fn, '.a', Binary).					% so append .a to produce binary name

$determinefile(Source, _, Source) :-
	fullfilename(Source, FFname),               % get full file name of Fn
	iswindow(Window, text, _, FFname),          % does an open window exist ??
	changedtext(Window),                        % has the window been changed ??
	!.                                          % if so, then use the source file
$determinefile(Source, Binary, Source) :-
	isfile(Source, _, _, _, _, _, SDate),		% source file exists, may fail in lower rings
	$checkbinary(Binary, SDate),				% compare with binary
	!.											% remove cp
$determinefile(_, Binary, Binary).				% source doesn't exist or no good, use binary

$checkbinary(Binary, SDate) :-
	isfile(Binary, _, _, _, _, _, BDate),		% binary exists
	!,
	breadth_first_compare(BDate, SDate, '@<').	% use source only if binary later date
$checkbinary(_,_).								% no binary, use source

$tryto(Goal, _..) :- 
    Goal, 
    !.                    						% prune other $tryto choicepoints
$tryto(_, ErrNum..) :- 
    swrite(1, ErrNum..),						% fails in R3 since we don't support streams
    fail.

$member2(X, Y, [X, Y, _..]).
$member2(X, Y, [_, _, Xs..]) :- $member2(X, Y, [Xs..]).  


%%%
%%%  Predicates for querying clause space
%%%

%%%% symbol_name - generates or verifies names of existing symbols
symbol_name(Sym) :-                            % Case where Sym is bound
     nonvar(Sym),                              % Check Sym is a nonvar,
     !,                                        % commit, and
     symbol(Sym).                              % confirm Sym is a symbol
symbol_name(Sym) :-                            % Case where Sym is generated
     $prev_symbol(A),                          % Get 1st symbol in symbol table, and
     $symbol_aux(A, Sym).                      % go get a Sym

$symbol_aux(Sym, Sym).                         % Pass back Sym
$symbol_aux(A, Sym) :-                         % advance to next symbol
     $prev_symbol(A, A1),                      % in symbol table
     $symbol_aux(A1, Sym).                     % and recur


%%%% predicate/1 - generates/verifies predicate functor names
predicate(P) :-                                % Confirm or generate a predicate symbol
     !,                                        % Remove cp
     $predicate(P).                            % Do it

$predicate(P) :- 
     nonvar(P),                                % When P is a nonvar 
     !,                                        % commit to remove cp (avoid confirming twice), and
     $predicate_symbol(P).                     % confirm P is a predicate symbol

$predicate(P) :-                               % Otherwise P is a var and P generation desired
     $prev_pred(P1),                           % So, get the 1st predicate symbol in table, and
     $predicateaux(P1, P).                     % go get a predicate Sym

$predicateaux(P, P).                           % Pass back Sym
$predicateaux(A, P) :-
     $prev_pred(A, A1),                        % advance to next predicate
     $predicateaux(A1, P).                     % and recur

%%%% predicate/2 - generates/verifies predicate functor names in a context
predicate(P, Cx) :-                            % Predicate P defined in context Cx
	context(Cx),							   % test/generate contexts
    $predicate(P),                             % Generator/Confirmation
    $predicate_aux(P, Cx, _).                  % Do it

$predicate_aux(P, base, base) :-               % Case: P a primitive 
    $primitive(P), !.                          % So Cx is base (can't overload primitives)
$predicate_aux(P, Cx, Fn) :-                   % Case: P is defined 
    $address(P, 0, Addr),
    $ord_in(Addr, Cx, Fn),!.				   % cut since $address will succeed for each clause


%%%% primitive - generates/verifies primitive functor names
primitive(P) :-                                % A predicate defined in pascal or assembler
     $predicate(P),                            % P is a predicate symbol table entry (generator)
     $primitive(P).                            % which is a primitive predicate


%%%% contents/3 - generate a list of predicates in a given context
contents(Cx,Fn,Plist):-
	symbol(Cx,Fn),
	$prev_pred(P),
	$collect_contents(Cx,Fn,P,Plist).

$collect_contents(Cx, Fn, P, [P,Ps..]) :-
	$predicate_aux(P, Cx, Fn),	% in named context
	swrite(P,P),				% fails if P is local except for top context 
    !,
	$next_pred(Cx, Fn, P, [Ps..]).
$collect_contents(Cx, Fn, P, [Ps..]) :-
	$next_pred(Cx, Fn, P, [Ps..]).

$next_pred(Cx, Fn, P, [Ps..]) :-
	$prev_pred(P, P1), !,
	$collect_contents(Cx, Fn, P1, [Ps..]).
$next_pred(_, _, _, []).
	

%%%
%%% closing and hiding predicates
%%%
 
%%%% close_definition - close a predicate
close_definition(P) :-                         % Close the definition for predicate P
    $predicate_symbol(P),                      % Verification that P is a predicate and a symbol. 
    $close_definition(P).                      % Confirm that P closed, or close P. 

%%%% closed_definition - generate/verify closed predicates
closed_definition(P) :-
    $predicate(P),                             % Generation or verification of P. 
    $closed(P).                                % Confirm that P has been explicitly closed. 

%%%% hide - hide a predicate definition
hide(P) :-                                     % Hide the definition for predicate P
    $predicate_symbol(P),                      % Verification that P is a predicate and a symbol. 
    $hide(P).                                  % Confirm P hidden, or hide P. 

%%%% visible - generate/verify hidden predicates
visible(P) :-
    $predicate(P),                             % Generation or verification of P. 
    $visible(P).                               % Confirm P is visible

