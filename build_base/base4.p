/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base4.p,v 1.8 1998/03/26 15:59:34 csavage Exp $
*
*  $Log: base4.p,v $
 * Revision 1.8  1998/03/26  15:59:34  csavage
 * Added not(not( around context call in
 * definition to correct fault with
 * definition(_,_) call.
 *
 * Revision 1.7  1998/03/13  02:58:54  wcorebld
 * Removed cut from definition/2
 *
 * Revision 1.6  1998/03/12  16:31:46  csavage
 * Adjusted definition predicate to avoid seg
 * fault on AIX machines for 5.0.2 release.
 *
 * Revision 1.5  1997/05/12  12:51:07  harrisj
 * assert will fail if the clause to be asserted has
 * a variable as a functor.  Compilation will also fail
 * if this occurs.
 *
 * Revision 1.4  1996/08/28  11:04:34  harrisj
 * Modified to allow stderr stream
 *
 * Revision 1.3  1996/01/24  09:35:01  yanzhou
 * $handleanevent changed to ignore `userupidle' events, so
 * that load/compile performance in xBNRProlog can be
 * improved.
 *
 * Revision 1.2  1995/10/13  15:14:01  yanzhou
 * Added: support for read_only_binary file
 *        and read_write_binary file.
 *
 * Revision 1.1  1995/09/22  11:21:25  harrisja
 * Initial version.
 *
*
*/

/*
 *  Ring 4 of BASE
 */

$base(4).

$istextwindow(_,_,_) :- fail.
% Fix for debugger on Motorola SysV version 3.  This doesn't work
% properly if $istextwindow is undefined

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Binary stream support (October 1995, yanzhou@bnr.ca)
%
%  Two binary file modes are added:
%     1) read_only_binary
%     2) read_write_binary
%  There is no binary support for windows or pipes.
%
%  WARNING:
%    As most of the predicates here were designed for Text
%    I/O, they probably will not work properly with the
%    binary files on non-UNIX operating systems.
%  
%  Modification tag: "% BINARY-STREAM"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
%%%   IO_Primitives (support for streams only, symbols handled in R2)
%%%

%%%% open(?Stream, +Filename, +Mode, ?IOResult)
open(Stream, Filename, Mode, IOResult) :- 
    symbol(Filename,Mode),                % Make sure parameters defined
	var(Stream),
	$openfile(Mode, Filename, FileP, IORes),
	$opencheck(IORes, IOResult, FileP, Stream, Filename, Mode).


$openfile(read_only,Filename,[FileP, FileProc],0):-
	fullfilename(Filename, FFilename),
	$istextwindow(_, FFilename, FileP),
	$window_io_proc(FileProc),
	!.
$openfile(read_only,Filename,[FileP, FileProc],IOResult):-
	$fopen(FileP,Filename,r,IOResult,FileProc).	

$openfile(read_write,Filename,[FileP, FileProc],0):-
	fullfilename(Filename, FFilename),
	$istextwindow(_, FFilename, FileP),
	$window_io_proc(FileProc),
	!.
$openfile(read_write,Filename,[FileP, FileProc],0):-
	$fopen(FileP,Filename,'r+',0,FileProc),!.		% if file exists, open read_write
$openfile(read_write,Filename,[FileP, FileProc],IOResult):-
	$fopen(FileP,Filename,'w+',IOResult,FileProc).	% open read_write failed, try write_read

$openfile(read_write_pipe,Name,[Pipe,PipeProc],IOResult):-
	$fopen(Pipe,PipeProc,IOResult).

% BINARY-STREAM: $openfile
% read_only_binary: file mode "rb"
$openfile(read_only_binary, Filename, [FileP, FileProc], IOResult) :-
	$fopen(FileP, Filename, "rb", IOResult, FileProc).

% read_write_binary: 1st attempt: file mode "r+b"
$openfile(read_write_binary, Filename, [FileP, FileProc], 0) :-
	$fopen(FileP, Filename, "r+b", 0, FileProc), !.

% read_write_binary: 2st attempt: file mode "w+b"
$openfile(read_write_binary, Filename, [FileP, FileProc], IOResult) :-
	$fopen(FileP, Filename, "w+b", IOResult, FileProc).

$opencheck(0, 0, FileP, Stream, Filename, read_write_pipe) :-
	new_obj(stream$(_,FileP,Filename,read_write_pipe,Filename),Stream,$local),
	put_obj(Stream,stream$(Stream,FileP,Filename,read_write_pipe,Filename),$local),
	!.
$opencheck(0, 0, FileP, Stream, Filename, Mode) :-
	fullfilename(Filename, FFilename),
	new_obj(stream$(_,FileP,Filename,Mode,FFilename),Stream,$local),
	put_obj(Stream,stream$(Stream,FileP,Filename,Mode,FFilename),$local),
	!,
    $openseek(Stream).
$opencheck(0, 9999, FileP, _, Filename, Mode) :-	% something went wrong
	$fclose(FileP,_) -> true,						% close the file if possible
	forget(stream$(_, FileP, Filename, Mode, _), $local) -> true,
	!.
$opencheck(Err, Err, _, _, _, _).
 
$openseek(S) :- seek(S, 0), !.
$openseek(_).


%%%% close(+Stream,?Error)
close(0,9998):-!.	% can't close console, set IO error code
close(1,9998):-!.
close(2,9998):-!.
close(Stream, IOResult) :-
	integer(Stream),
	get_obj(Obj,stream$(Stream,FileP,_..),$local),!,
	dispose_obj(Obj,$local),
    $fclose(FileP,IOResult).
close(Stream,9997):-  	% can't find stream, set IOR to unknown Prolog stream
	integer(Stream).	% must be integer, but not 0 or 1 or 2.


%%%% stream(?Stream, ?FileName, ?Mode) 
stream(Stream,Filename,Mode):-
    stream(Stream,Filename,Mode,_).            % stream. Call stream/4
 
%%%% stream(?Stream, ?FileName, ?Mode, ?FullFileName)
stream(0, stdin, Mode, WindowName) :-
	$consolemode(Mode, read_write_pipe, read_only, stdin, WindowName).
stream(1, stdout, Mode, WindowName) :-
	$consolemode(Mode, read_write_file_window, write_only, stdout, WindowName).
stream(2, stderr, Mode, WindowName) :-
	$consolemode(Mode, read_write_file_window, write_only, stderr, WindowName).
stream(Stream, Filename, Mode, FFilename) :- 
	recall(stream$(Stream,_,Filename,IMode,FFilename),$local),	% recall from state space
    $getmode(IMode, FFilename, Mode).
	
$consolemode(Mode, Mode, _, _, WindowName) :-
	$console(Console),
	iswindow(Console, text, _, WindowName),
	!.
$consolemode(Mode, _, Mode, WindowName, WindowName).

$getmode(IMode, FFileName, Mode) :-
	iswindow(_, text, _, FFileName),
	!,
	$getwinmode(IMode, Mode).
$getmode(read_only,         _, read_only_file).
$getmode(read_write,        _, read_write_file).
$getmode(read_window,       _, read_only_file).
$getmode(read_write_window, _, read_write_file).
$getmode(read_write_pipe,   _, read_write_pipe).

% BINARY-STREAM: $getmode
$getmode(read_only_binary,  _, read_only_binary_file).
$getmode(read_write_binary, _, read_write_binary_file).

$getwinmode(read_only,         read_only_file_window).
$getwinmode(read_write,        read_write_file_window).
$getwinmode(read_window,       read_only_file_window).
$getwinmode(read_write_window, read_write_file_window).
$getwinmode(read_write_pipe,   _) :- fail.		% not allowed


% check for valid stream and convert to file pointer (Stream must be instantiated)
$validstream(Stream, FileP) :-
	nonvar(Stream),
	$streamid(Stream, FileP).
	
$streamid(0, [FileP, FileProc]) :- 
	$console(Name),
	$istextwindow(Name, _, FileP),
	!,
	$window_io_proc(FileProc).
$streamid(0, 0) :- !.
$streamid(1, [FileP, FileProc]) :-
	$console(Name),
	$istextwindow(Name, _, FileP),
	!,
	$window_io_proc(FileProc).
$streamid(1, 1) :- !.
$streamid(2, [FileP, FileProc]) :-
	$console(Name),
	$istextwindow(Name, _, FileP),
	!,
	$window_io_proc(FileProc).
$streamid(2, 2) :- !.
$streamid(Stream, FileP) :-
	recall(stream$(Stream,FileP,_..),$local), !.

%%%% at(+Stream,?Pointer)
at(Stream,Pointer):-
	$validstream(Stream,FileP),
	$at(FileP,Pointer).

%%%% seek(+Stream,+Pointer)
seek(Stream,Pointer):-
	$validstream(Stream,FileP),
	$seek(FileP,Pointer).

%%%% set_end_of_file(+Stream)
set_end_of_file(Stream):-
	$validstream(Stream,FileP),
	$set_end_of_file(FileP).


%%%% readfile(FileName, Term)
readfile(FileName, Term) :-                     % Read a term from file FileName
    open(Stream, FileName, read_only, 0),       % Attempt to open FileName for reading. Must succeed.
	$validstream(Stream,FileP),
    repeat,                                     % Infinite choice pointloop
	$readfile(FileP, Term, Stream),
	true.
	
$readfile(FileP, Term, _) :-
    $fread(FileP,T,0,0),                        % IF the read is successful
	!,
    $coerce_term(T, Term).                      % THEN attempt to unify Term and T
$readfile(_, _, Stream) :-                      % ELSE assume eof encountered, 
    close(Stream, _),                           %     attempt to close Stream
    failexit(readfile).                         %     fail out.


%%%% read(Terms..)                              
read(X..) :-                                    % A (possibly) variadic read from 
   sread(0, X..).                               % StdIn

%%%% sread(Stream, Terms..)                      First clause does the checking 
% ?- sread(3).                                  % Same as true if 3 is a stream.
% ?- sread(3, X).                               % Read one item
% ?- sread(3, X..).                             % Read entire remainder of stream
% ?- sread(3, X1, X..).                         % Interpreted as ?- sread(3, X1), sread(3, X..).

%% adds to clauses in R2
sread(Stream, Terms..) :-
	$validstream(Stream,FileP),
    $sread_aux([Terms..],FileP).                % cannot support One or more terms to read

%%%% $sread_aux(Stream, Term, Terms..)
% Suppose that we have the goal $sread_aux(N, X..) and that this goal unifies
% with the head of the 1st clause below. Further suppose that the $fread 
% attempt either encounters a partial term (IOResult = 2) or end of file 
% (IOResult = -39).  The call to $read_ok simply fails, thus permitting the goal 
% (i.e., $sread_aux(N, X..)) to ripple down and attempt head unification with
% the 2nd clause. The only case where this head unification will succeed is
% when X.. is a tailvar. In short, successful termination occurs for indefinite
% reads upon encountering a partial term or end of file.

$sread_aux([Term, Terms..], FileP) :-          	% CASE: One or more terms to read
    $fread(FileP, T, IOResult, 1),             	% 1 = output error message
    $read_ok(IOResult), !,                      % So far so good.
    $coerce_term(T, Term),                      % coerce result to whats expected
    $sread_aux([Terms..], FileP).              	% Recur to read the remainder.
$sread_aux([],_).                         		% CASE:  All done.

$read_ok(0).                                    % CASE: IOResult = 0. Successful read.
$read_ok(2) :-                                  % CASE: IOResult = 2. Partial read.
    !, fail.                                    % Fail into second clause of $sread_aux
$read_ok(-39) :-                                % CASE: IOResult = -39. EOF
    !, fail.                                    % Fail into second clause of $sread_aux
$read_ok(_) :-                                  % Otherwise
    failexit($sread_aux).                       % Fail $sread_aux.

%%%% write(Xs..)
write(Xs..) :-                                             % Output to stdout
	$outstream(1,FileP),
    $fwrite(FileP,0,0,[Xs..],0,_).

%%%% writeq(Xs..)
writeq(Xs..) :-                                            % Output to stdout
	$outstream(1,FileP),
    $fwrite(FileP,16,0,[Xs..],0,_).      

%%%% nl
nl :-
	!,											% remove choicepoint
    nl(1).

%%%% nl(Stream)
nl(Stream) :-
	$validstream(Stream,FileP),
    $fwrite(FileP,0,0,['\n'],0,_).

%%%% readln(Line)/readln(Stream, Line)/readln(Stream, Line, IOResult)  
readln(Line) :-                                 % Readln from stdin
    !,                                          % Commit to remove choice point.
    $readln(0, Line, 0, 1).                     % IOResult = 0, error messages if required
  
readln(Stream, Line) :-                         % Readln from any stream
    !,                                          % Commit to remove choice point.
    $readln(Stream, Line, 0, 1).               	% IOResult = 0, error messages if required

readln(Stream, Line, IOResult) :-               % Readln from any stream with IOResult
    $readln(Stream, Line, IOResult, 0).        	% 0 = no error messages.

$readln(0, Line, 0, _) :-
	predicate($userevent),
	!,
	repeat,
	userevent(Ev, W, D1, D2, noblock),
	$readln_dispatch(Ev, W, D1, D2, Line),
	!.	
$readln(Stream, Line, IOResult, Err) :-
	$instream(Stream, FileP),
	$freadln(FileP, Line, IOResult, Err).

$readln_dispatch(userkey, W, '\03', D2, Line) :-			% ENTER key
	!,
	$readln_dispatch(userkey, W, enter, D2, Line).
$readln_dispatch(userkey, W, enter, D2, Line) :-			% ENTER key
	$console(W),											% in console window only
    inqtext(W, selectcabs(S,S)),							% no selection
    !,
	$readln_echo(W, S, S1, D2),
    dotext(W, selectlrel(0,1)),								% select the whole line
    dotext(W, selectcrel(0,-1)),							% remove the <cr> from line
    inqtext(W, selection(Line)),							% get the line
	dotext(W, selectcabs(S1,S1)),							% reset selection to cursor
	!.
$readln_dispatch(userkey, W, enter, _, Line) :-				% ENTER key
	$console(W),											% in console window only
    inqtext(W, selection(Line)),							% selection
	!.
$readln_dispatch(Event, W, D1, D2, _) :- 
	once(Event(W, D1, D2)),
	fail.	

$readln_echo(W, S, S1, D2) :-
    inqtext(W, csize(S)),									% is cursor at end of window
	userkey(W, '\n', D2),									% yes, so echo a <cr>
    dotext(W, selectcabs(S,S)),								% put us back at end of previous line
	S1 is S + 1,
	!.
$readln_echo(_, S, S, _).									% no, so simply succeed

%%%% get_char(?Char)/get_char(+Stream, ?Char)/get_char(+Stream, ?Char, ?IOResult)
get_char(Char) :-                               % Read next char from stdin.
    !,                                          % Commit to remove choice point.
    $get_char(0, Char, 0, 1).                   % IOResult = 0, error messages if required

get_char(Stream, Char) :-                       % Read a char from any stream
    !,                                          % Commit to remove choice point.
    $get_char(Stream, Char, 0, 1).              % IOResult = 0, error messages if required

get_char(Stream, Char, IOResult) :-             % Read a char from any stream with IOResult
    $get_char(Stream, Char, IOResult, 0).       % 0 = no error messages.

$get_char(0, Char, 0, _) :-
	predicate($userevent),
	!,
	repeat,
	userevent(Ev, W, D1, D2, noblock),
	$char_dispatch(Ev, W, D1, D2, Char),
	!.
$get_char(Stream, Char, IOResult, Err) :-
	$instream(Stream, FileP),
    $freadchar(FileP, Char, IOResult, Err).
	
$char_dispatch(userkey, W, Char, D2, Char) :-
	$console(W),
	userkey(W, Char, D2) -> true,
	!.
$char_dispatch(Event, W, D1, D2, _) :- 
	once(Event(W, D1, D2)),
	fail.	


%%%% put_char(+Char) and put_char(+Stream, +Char)
put_char(Char) :- 
    !,                                                     % Commit to remove choice point.
    put_char(1, Char).                                     % Recur with put_char to stdout
  
put_char(Stream,Char) :- 
    namelength(Char,1),                                    % ensure Char is just that,    
	$outstream(Stream,FileP),
    $fwrite(FileP,0,0,[Char],IOResult,_).             	   % a single char, and do it.


%%%% clause - generates/verifies clause definitions
clause(Cl) :-                                  % Observe: Packaged as a call to definition which
     definition(Cl, _).                        % discards the context


%%%% clause_head/1 - generates/verifies clause head definitions
clause_head(P(As..)) :-                        % Return the heads of all clauses
    !,                                         % Commit to remove cp
    $predicate(P),
	$internal_clause(P(As..) :- _, _).

%%%% clause_head/2 - generates/verifies clause head definitions in a context
clause_head(P(As..), Cx) :-
    $predicate(P),                             % Generator/Confirmation
    $internal_clause((P(As..) :- _), Ptr),     % Get clause, ignore body
    $ord_in(Ptr, Cx, _).                       % Get context of clause found

%%%% definition - generates/verfies visible clause definitions in a context
definition( (P(As..) :- Body), Cx) :-          % Explicit check that argument in cononical form.
    not(not($context(Cx, _))),		       % Ensure that context exists not(not())) ensurex that Cx remains a var if it was one.
    $predicate(P),                             % Confirm or generate a predicate
    $visible(P),                               % Only non-hidden (i.e., thus no locals in low cx)
    $internal_clause((P(As..) :- Body), Ptr),  % Get a clause and its pointer
    $ord_in(Ptr, Cx, _).


%
%   Support for definition, clause and clause_head
%   Note that args 2 and 3 of clause$$ must be vars for easier implementation
%   Using $unify to avoid debugger traps on =

$internal_clause(P(As..) :- Body, 0) :-        % special case for primitives
    $primitive(P),
    !,
    $unify([As..], []),
    $unify(Body, []).
$internal_clause(P(As..) :- Body, Addr) :-
    $address(P, 0, Addr),
	clause$$(Addr, [Args..], Body1),
	$unify([As..], [Args..]),
	$unify(Body, Body1).

$unify(X, X).

$address(Proc, Addr, Addr) :- 
    Addr <> 0.
$address(Proc, Addr, Result) :-
    $$address(Proc, Addr, Next),
    $address(Proc, Next, Result).

%%%
%%% assert and retract
%%%

%%%% assert, asserta, assertz
assert(C) :- $assert(C, 1).
asserta(C) :- $assert(C, 1).
assertz(C) :- $assert(C, 0).

% clauses with variable functor's are illegal
$assert(Functor(X..),_) :-
	var(Functor),
	!,
	fail.

$assert(op(Precedence, Type, Name), End) :-
	nonvar(Precedence, Type, Name),
	$convert_type(Type, NT), !,
	$define_op(Name, Precedence, NT),      % as per Jason Harris' fix, Feb. '95
	$assert_clause(End, op, 3, Precedence, [get_cons(Precedence,1),
						get_cons(Type,2),
						get_cons(Name,3),
						neckcon(0), proceed]).

$assert(op(Precedence, Type, Name) :- [], End) :-
	!,
	$assert(op(Precedence, Type, Name), End).

$assert(C, End) :- 
	compile_clause(C, Func(Arity, FirstArg), WAM),
	$assert_clause(End, Func, Arity, FirstArg, WAM).

$convert_type(xf, 0).
$convert_type(yf, 1).
$convert_type(fy, 2).
$convert_type(fx, 3).
$convert_type(yfx, 4).
$convert_type(xfy, 5).
$convert_type(xfx, 6).


%%%% retract                                     NOTE: On backtracking, retract re-starts at the   
                                               % beginning of clause chain and searches forward.
retract((H :- B)) :-                           % Retraction of a Clause with head and body.
    !,                                         % Commit, to remove cp
    repeat,                                    % Infinite cp
    $retract_aux((H :- B)),                    % Attempt a retract.
    true.                                      % Avoid LCO
retract(H) :-                                  % Retraction of a fact (High Runner). Note ':-' closed
    repeat,                                    % so need not check here that H \= ':-'(_..)
    $retract_aux((H :- [])),                   % Attempt a retract. 
    true.                                      % Avoid LCO

$retract_aux(H :- B) :-                        % Enforce argument to be in cononical form.
	$retractmaphead(H, P(As..)),
    $predicate_symbol(P),                      % P must be predicate a symbol.
    $visible(P),                               % P must be visible.
    not($closed(P)),                           % P must open.
	$retractmapbody(B, NewB),
    $internal_clause((P(As..) :- NewB), Ptr),  % Find a unifiable clause, starting with topmost Cx,
    cut,                                       % snip to prevent backtracking,
    $retract(P, Ptr),                          % and retract it. (May fail if Cl in low Cx)
    !.                                         % On success, commit, so we backtrack into the repeat
$retract_aux(_) :-                             % No unifiable or retractable clauses (e.g. clause
    failexit(retract).                         % found not in topmost context) so FAIL EXIT OUT !

$retractmaphead(H, H) :- structure(H), !.
$retractmaphead(H, H()) :- symbol(H).

$retractmapbody(L, L) :- list(L), !.
$retractmapbody(L, L) :- var(L), !.
$retractmapbody(L, [L]).                       % L is probably a symbol or structure, which need to be in a list

%%%% retractall
retractall(H) :-                               % Retract all clauses in topmost context having 
      retract((H :- _)),                       % head H; don't care about body. 
      fail.                                    % Fail to force backtracking
retractall(_).                                 % Always succeeds


%%%
%%% Contexts (extra clauses to allow compiling into memory)
%%%

reload_context(Cx1) :-
    symbol(Cx1),                            % Accept only symbols
	$reload(Cx1),
	!.

$reload(Cx) :-
	$resolve_context(Cx, RealCx, Fn),		% IF there is a Cx and a Fn corresponding to Cx1
	!,
	$reload_file_as_context(Fn, RealCx).	% THEN reload Fn as context RealCx (original name).
$reload(Cx) :-
	load_context(Cx).						% ELSE do a load_context (Cx does not exists)


reconsult(Fn) :-
	$resolve_filename(Fn, Fn1),				% get file name that we will load
	$generatenames(Fn1, Source, Binary),	% get source and binary names
	$removepredicates(Fn1, Source, Binary),	% retract all existing predicates			
    $loadfile(Fn1).							% load the file

$removepredicates(Source, Source, _) :-		% reconsult source file, easy to do
    readfile(Source, C),					% get a clause in source file
	$clause_pred(C, P),						% determine predicate name
	retractall(P(_..)),						% retract all such predicates
	fail.
$removepredicates(Binary, _, Binary) :-		% reconsult binary file, bit more complicated
	$readline(Binary, Line),				% read a line
	substring(Line, 1, 4, First4),			% get first 4 characters as an index
	$reconsultcheck(First4, Line, P),		% parse the line
	retractall(P(_..)),						% retract all such predicates
	fail.									% try next line
$removepredicates(_, _, _).					% for when above clauses fail out

$clause_pred((P(_..) :- _), P) :- !.
$clause_pred(P(_..), P) :- !.
$clause_pred(P, P).

$readline(FileName, Line) :-				% Read a line from file FileName
    open(Stream, FileName, read_only, 0),	% Attempt to open FileName for reading. Must succeed.
	$validstream(Stream,FileP),
    repeat,									% Infinite choice pointloop
	$$readline(FileP, Line, Stream),
	true.
	
$$readline(FileP, Line, _) :-
	$freadln(FileP, Line, 0, 0),			% IF the read is successful
	!.										% THEN commit
$$readline(_, _, Stream) :-					% ELSE assume eof encountered, 
    close(Stream, _),						%     attempt to close Stream
    failexit($readline).					%     fail out.

$reconsultcheck("proc", L, _) :-			% is it a procedure definition line ??
	substring(L, 6, 4, P),					% get the symbol reference
	remember(retract(P), $local),			% save it for future use
	!, fail.								% fail out since we don't have a symbol to retract
$reconsultcheck(" sym", L, Sym) :-			% is it a symbol definition line ??
	substring(L, 6, 4, P),					% yes, so get the symbol reference
	forget(retract(P), $local),				% was there a clause with this ref ??
	% make sure that it is really a symbol (not an int, ...), and extract the symbol contents
	name(L, [_,S,Y,M,_,A,B,C,D,0':,0's,0'y,0'm,0'=,Q,R..]),
	$reconsultsym(Q, R, Sym),				% make a symbol out of the contents
	!.

$reconsultsym(0'", [R..], Sym) :-			% symbol begin with " ??
	$lastchar(R, 0'"),						% must end in " as well
	!,
	name(A, [0'", R..]),					% make a symbol out of "..."
	swrite(B, A, " .  "),					% put a period space at end
	get_term(B, Sym, 0).					% read the symbol (removing quotes and special chars)
$reconsultsym(0'', [R..], Sym) :-			% symbol begin with ' ??
	$lastchar(R, 0''),						% must end in ' as well
	!,
	name(A, [0'', R..]),					% make a symbol out of '...'
	swrite(B, A, " .  "),					% put a period space at end
	get_term(B, Sym, 0).					% read the symbol (removing quotes and special chars)
$reconsultsym(Q, [R..], Sym) :-				% nothing special in symbol
	name(Sym, [Q, R..]).					% simply convert it

$lastchar([X], X) :- !.
$lastchar([_, R..], X) :- 
	$lastchar(R, X).


%%% Clause for $loadfile in base2 for binary files
$loadfile(Fn) :-							% Fn must be a source file
	new_counter(0, Count),					% counter for dots
	$determinelinesize(LineSize),
	swrite(1, 'Compiling ', Fn, ' into memory...\n'),
	forget_all(error(_), $local),
    $mreadfile(Fn, Term),					% get a term from Fn
	$compileit(Term),
    $beeble(Count, LineSize),				% print out dots
	fail.
$loadfile(_) :- 
	nl,
	recall(error(_), $local),				% fails if no errors
	!,
	forget_all(error(_), $local),
	fail.
$loadfile(_).
	

$mreadfile(Fn, Term) :-
	open(Stream, Fn, read_only, IO_Open),
	$open_check( IO_Open, Fn, Stream),
	$validstream(Stream, FileP),
	repeat,
	$at(FileP, Pos),
    $fread(FileP,T,IOresult,0),             	% Do the read, no error message if error
    $coerce_term(T, Term),                      % coerce result to whats expected
	$iocheck(IOresult,Fn,Stream,Pos),
	$handleanevent.

$handleanevent :-
	userevent(E, W, D1, D2, noblock),			% may not be implemented
	E \= userupidle,		% 24/01/96:yanzhou@bnr.ca: ignore userupidle
	E(W, D1, D2),								% may fail
	!.											% simply succeed
$handleanevent.									% always succeed

$compileit(Term) :-
	$assert(Term, 0), !.						% assertz
$compileit(Term) :-
	swrite(1, 'Unable to compile clause ', Term), nl,
	remember(error(1), $local).

$open_check(0, _, _).							% open ok
$open_check(IO, Fn, _) :- 
	IO <> 0,
    write('I/O error ', IO, ' opening file ', Fn), 
    fail. 
$open_check(0, _, Strm) :- 
	close(Strm,_),
	fail.   

$iocheck(0, _, _, _) :- !.
$iocheck(IOErr, Fn, Stream, Spos) :- 
	IOErr > 0,
	!,
	nl, 
	remember(error(2), $local),
	error_string( syntax, IOErr, S) ; S = '',
	write('Syntax error ', IOErr,': ',S, ' in file ',Fn),
	nl,
	at(Stream, Epos),
	seek(Stream,Spos),
    lastparsererrorposition(ErrPos) ; ErrPos = unknown,
	repeat,
		get_char(Stream, C) -> put_char(1, C),
		at(Stream, Pos),
		Pos = ErrPos -> write('<<== HERE !! '),
		Pos = Epos,
		!,
		fail.
$iocheck(IOErr, _, Stream, _) :- 
	IOErr < 0,
    close(Stream, _), 
    failexit($mreadfile).

$beeble(Count, LineSize):-
    write('.'),
    Count,
    counter_value(Count,Val),
    $wraparound(Val,LineSize). 

$wraparound(Val, LineSize):- 0 is Val mod LineSize, nl.
$wraparound(_, _).

$determinelinesize(LineWidth) :- $pplength(1, LineWidth, _).
/*
$determinelinesize(LineWidth) :-
    stream(1, _, _, FFname),                        % IF Stream 1 is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, textwidth('.', W0)),            %   AND we can get the size of a .
	W0 > 0,                                         %   AND it's a valid size
    sizewindow(Window, Width, _),                   %   AND we can get window width
    mbarheight(Menu),                               %   AND we get an approx scroll bar width
	!,                                              % THEN
    LineWidth is ((Width - Menu) // W0) - 1.        %   determine number of *'s in line
$determinelinesize(LineWidth) :-
	system("test `uname` = SunOS", 0),				% only works on Suns
	system("exit `stty size | awk '{print $2}'`", R),
	LineWidth is R // 256,
	LineWidth > 20,
	!.
$determinelinesize(70).
*/

$reload_file_as_context('', base) :-		% To reload context base, simply reload userbase
	$reload_file_as_context('::', userbase),
	!.

$reload_file_as_context(Fn, Cx) :-          % Cx & Fn an existing context
    forget_all(cxfn(_, _), $local),         % Clean (historical) house  
    $context(TCx,TFn),                      % generate context pairs
    ($name(TFn, [58, 58, _..]) ->           % IF TFn is user created context
        write('Can\'t reload context', TCx, '\n') ;	% THEN warning that it is about to disappear
        remembera(cxfn(TCx, TFn), $local)),	% ELSE save, LIFO - copy semantics   
    (Cx = TCx),                             % Repeat until selected context 
    (Fn = TFn),                             % reached.
    $remove_context(Cx, Fn),                % Pop Cx/Fn 
    !,                                      % Commit 
	$reload().								% reload each context we just popped

$reload() :-
	forget(cxfn(Cx, Fn), $local),				% get context name for just popped context
	$generatenames(Fn, Source, Binary),			% generate names for source and binary
	$determinefile(Source, Binary, Fn1),		% decide which one to use
	$load_file_as_context(Fn1, Cx),
	fail.
$reload().


%%%
%%% File system predicates
%%%

listdirectories(DirList) :-
    defaultdir(Dir),
    $listdirectories(Dir,L),
    DirList = L.                % unify retrieved list with parameter 

listvolumes(VolList) :-			% for upwards compatibility only!!
    $listvolumes(L),
    VolList = L.                % unify retrieved list with parameter 

isdirectory(Dir) :-
	var(Dir),
	!,
    listdirectories(DirList),
    $member(Dir, DirList).
isdirectory(Dir) :-
    $resolvedirname(Dir, New),
	listdirectories(DirList),
    $member(New, DirList),
	!.

$resolvedirname(Dir, New) :-
	concat(New, '/', Dir), !.
$resolvedirname(Dir, Dir).

homedir(D) :- applicationdir(D).

isvolume(Vol) :-
    $listvolumes(L),
    $member(Vol, L).

listfiles(FileList) :-
    defaultdir(Dir),
    $listfiles(Dir,L),
    FileList = L.

isfile(Name, Rest..) :-
	var(Name),
	!,
    defaultdir(Dir),
    $listfiles(Dir, L),
	$member(Name, L),
	isfile(Name, Rest..).
	
isfile(Name, Creator, Type) :-
	symbol(Name),
	!,
	$isfile(Name, Creator, Type, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _).

isfile(Name, Creator, Type, [DFOpen, DFSize], [RFOpen, RFSize],
	   [CreatedYear, CreatedMonth, CreatedDay, CreatedHour, CreatedMin, CreatedSec, CreatedWDay],
	   [ModifiedYear, ModifiedMonth, ModifiedDay, ModifiedHour, ModifiedMin, ModifiedSec, ModifiedWDay]) :-
	symbol(Name),
	!,
	$isfile(Name, Creator, Type, DFOpen, DFSize, RFOpen, RFSize, 
			CreatedYear, CreatedMonth, CreatedDay, CreatedHour, CreatedMin, CreatedSec, CreatedWDay,
			ModifiedYear, ModifiedMonth, ModifiedDay, ModifiedHour, ModifiedMin, ModifiedSec, ModifiedWDay).
