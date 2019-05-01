/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/compile.p,v 1.9 1997/05/12 12:51:10 harrisj Exp $
 *
 * $Log: compile.p,v $
 * Revision 1.9  1997/05/12  12:51:10  harrisj
 * assert will fail if the clause to be asserted has
 * a variable as a functor.  Compilation will also fail
 * if this occurs.
 *
 * Revision 1.8  1996/02/13  04:18:30  yanzhou
 * The version numbers of the compiler and the code generator are increased:
 *     compiler from version 25 to version 26,
 *     code generator from time stamp Oct/31/1991 to Feb/15/1996.
 *
 * Revision 1.7  1996/02/08  05:03:04  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.7  1996/02/08  04:59:05  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   core.h             - new BOOLEANREQUIRED run-time error
 *   base5.p            - new $error_string() clause for the BOOLEANREQUIRED
 *                        run-time error
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.6  1996/02/06  04:38:29  yanzhou
 * unsaf-related code segments are now removed:
 *
 *    Removed OpCode  Mode           Code
 *    --------------  --------  ---------
 *    unif_unsaft     HEAD      0x18-0x1F
 *    unif_unsafp     HEAD           0x91
 *    push_unsafp     BODY      0x18-0x1F
 *    push_unsaft     BODY ESC  0x88-0x8F
 *    putunsaf        BODY ESC  0x38-0x3F
 *
 * Revision 1.5  1996/02/01  03:32:32  yanzhou
 * $handleanevent() modified to ignore userupidle events,
 * so that load/compile performance can be improved in xBNRProlog.
 *
 * Revision 1.4  1996/02/01  03:29:43  yanzhou
 * New bit-wise operators added:
 *
 *  OPERATOR   TYPE   PRIORITY   WAM ESC CODE   HASH
 *  ------------------------------------------------
 *  butnot      yfx        600             CF    122
 *  bitshift    yfx        600             DF     94
 *  bitand      yfx        600             ED    119
 *  bitor       yfx        600             EE    197
 *  biteq       yfx        600             EF     59
 *
 *  Modified files are:
 *  base0.p            - new op() and eval() clauses.
 *  cmp_arithmetic.p   - new $func2() clauses.
 *  compile.p          - new $esc() entries.
 *  core.c             - new CF/DF/ED/EE/EF entries
 *                         in escape and in-clause modes.
 *  loader.c           - new hash entries in scanList(),
 *                         and -80 entries in remEscBytes[].
 *  prim.[hc]          - new atoms
 *
 * Revision 1.3  1995/11/24  19:19:57  yanzhou
 * COLUMNS is getenv("COLUMNS") - 4.
 *
 * Revision 1.2  1995/11/24  19:01:54  yanzhou
 * Was using system("stty size"). Now uses getenv("COLUMNS") to determine the width of the tty.
 *
 * Revision 1.1  1995/09/22  11:23:31  harrisja
 * Initial version.
 *
 *
 */
%
%           mainline
%
% imports    compile_clause( Clause, Label, Code )
% exports    compile( File_or_Group.. )
%            compiletoc( File_or_Group.. )
%
% compile is variadic; its arguments are of the following form:
%	file               -> compiles file to file.a/file.c
%	[file1, file2]     -> compiles file1 and file2 to file1.a/file1.c
%	file(file1, file2) -> compiles file1 and file2 to file.a/file.c
%

$bcversion('Feb/15/96').
$fileformat(1).				% file format of C code

% code_only removed 92/12/11 JR
% in it's place add a clause annotate_code to see expanded code.
% code_only. %        :- fail.       %(to see symbolic representation also)

compile(Files..):-
    with_context(compiling, $compile($doclause, Files..)).

compiletoc(Files..):-
    with_context(compiling, [assert(comment_code :- fail), $compile($doclause_c, Files..)]).

compiletocc(Files..):-
    with_context(compiling, [assert(comment_code :- true), $compile($doclause_c, Files..)]).

compiletor(Files..):-
    with_context(compiling, $compile($doclause_r, Files..)).

$compile(_).
$compile(G, Filegroup, Rest..) :-
    $get_filename( Filegroup, Filename, Filelist),
	$checkfiles(Filelist),
    $clear_symbol_table,
    $headers(G, Filename, Out, Filelist),
	new_counter(0,Count),
	new_counter(0,BytePosition),
	$determinelinesize(LineSize),
    T1 is cputime,
    $compile_file( Filelist, Out, Count, LineSize, G, BytePosition),
	$checkforerrors(Out),
    $dump_symbol_table(G, Out, Count, LineSize),
    T2 is cputime, 
	DT is T2 - T1, 
    nl, write( time = DT), nl,
    set_end_of_file(Out),
	$rewrite_header(G, Out),
    close(Out,0),
	!,
    $compile(G, Rest..).

$determinelinesize(LineWidth) :-
    stream(1, _, _, FFname),                        % IF Stream 1 is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, textwidth('*', W0)),            %   AND we can get the size of a *
	W0 > 0,                                         %   AND it's a valid size
    sizewindow(Window, Width, _),                   %   AND we can get window width
    mbarheight(Menu),                               %   AND we get an approx scroll bar width
	!,                                              % THEN
    LineWidth is ((Width - Menu) // W0) - 1.        %   determine number of *'s in line
$determinelinesize(LineWidth) :-
	$getCOLUMNS(LineWidth),
%   system("exit `stty size 2>> /dev/null | awk '{print $2}'`", R),
%	system("test `uname` = SunOS", 0),				% only works on Suns
%   system("exit `stty size | awk '{print $2}'`", R),
%	LineWidth is R // 256,
	LineWidth > 20,
	!.
$determinelinesize(70).

$getCOLUMNS(COLUMNS) :-							    % getenv("COLUMNS")
	getenv("COLUMNS", ENVCOLUMNS),
    concat(ENVCOLUMNS, ". ", S),
	sread(S, COLUMNS),
	integer(COLUMNS),
	COLUMNS is COLUMNS - 4,
	COLUMNS > 0,
	!.

$checkforerrors(Out) :-
	recall(error(Out), $local),			% did we get an error ??
	!,
	forget_all(error(_), $local),		% forget about the errors
	stream(Out, _, _, FFname),
	close(Out, 0),						% close output file
	deletefile(FFname),
	failexit($compile).
$checkforerrors(_).

$get_filename( Fname,		   Fname, Fname) :- symbol(Fname), !.
$get_filename( [Fname,Rest..], Fname, [Fname,Rest..]) :- symbol(Fname), !.
$get_filename( Fname(Rest..),  Fname, [Rest..]) :- symbol(Fname), !.

$checkfiles(Fname) :- 
	symbol(Fname), 
	!,
	$checkit(Fname).
$checkfiles([]) :- 
	!.
$checkfiles([Fname, Rest..]) :- 
	symbol(Fname), 
	!, 
	$checkit(Fname), 
	$checkfiles([Rest..]).

$checkit(Fname) :-
	fullfilename(Fname, FFname),
	iswindow(Window, text, _, FFname),
	changedtext(Window),
	write('Unable to compile ', Fname, ' since it is unsaved\n'),
	!,
	fail.
$checkit(Fname) :-
	isfile(Fname, _, _),
	!.
$checkit(Fname) :-
	write('Unable to compile ', Fname, ' since it does not exist\n'),
	!,
	fail.
	
$headers($doclause_c, Filename, Out, Filelist) :-
    concat(Filename, '.c', Outfile),
	$testfile(Outfile),
    open(Out, Outfile, read_write, IO),
    $open_check(IO,Filename,Out),
	$c_line1(Line1),
	$c_line2(Line2),
	swrite(Out, Line1, '\n', Line2, '\n'),
    cwamversion(V1),
	swrite(Out, '     Compiler Version ', V1, '\n'),
    $bcversion(V2),
	swrite(Out, '     Code Generator Version ', V2, '\n'),
	timedate(T, D),
	swrite(Out, '     Compiled: ', D, ' ', T, '\n'),
	$outputfilelist(Filelist, Out, '     Created from: '),
	swrite(Out, '***************************************************/\n\n#include "BNRProlog.h"\n\n'),
	$makename(Filename, DataName),
	gensym(DataName, ArrayName),
	remember(dataname(DataName, ArrayName), $local),
	swrite(Out, 'long ', ArrayName, '[] = {\n    0x').

$outputfilelist(Fname, Out, Banner) :-
	symbol(Fname),
	!,
	fullfilename(Fname, FFname),
	swrite(Out, Banner, FFname, '\n').
$outputfilelist([], _, _) :-
	!.
$outputfilelist([Fname, Fnames..], Out, Banner) :-
	$outputfilelist(Fname, Out, Banner),
	$outputfilelist([Fnames..], Out, '                   ').


$testfile(Filename) :-
	isfile(Filename, _, _),
    open(Out, Filename, read_only, 0),
	readln(Out, Line1),
	readln(Out, Line2),
	close(Out, 0),
	!,
	$testlines(Filename, Line1, Line2).
$testfile(_).

$testlines(_, Line1, Line2) :-
	$c_line1(Line1),
	$c_line2(Line2),
	!.
$testlines(_, Line1, Line2) :-
	$r_line1(Line1),
	$r_line2(Line2),
	!.
$testlines(Filename, _, _) :-
	write(Filename, ' appears to be created by a program other than Prolog\n'),
	write('Please check and delete it so that a new one can be created\n'),
	fail.

$c_line1('/***************************************************').
$c_line2('     BNR Prolog generated C').
$r_line1('/***************************************************').
$r_line2('     BNR Prolog generated resource file').

$makename(FileName, DataName) :-
	name(FileName, L),
	$process(L, [Y..] / [Y..], NewL),
	name(DataName, NewL),
	!.

$process([], L / [], L).
$process([58, Rest..], _, A) :-					% discard everything before :
	$process(Rest, [L..] / [L..], A).
$process([47, Rest..], _, A) :-					% discard everything before /
	$process(Rest, [L..] / [L..], A).
$process([C, Rest..], L / [C, K..], A) :-		% copy lowercase letters
	C @>= 0'a, C @=< 0'z, !,
	$process(Rest, L / K, A).
$process([C, Rest..], L / [C, K..], A) :-		% copy uppercase letters
	C @>= 0'A, C @=< 0'Z, !,
	$process(Rest, L / K, A).
$process([C, Rest..], L / [C, K..], A) :-		% copy digits
	C @>= 0'0, C @=< 0'9, !,
	$process(Rest, L / K, A).
$process([0'_, Rest..], L / [0'_, K..], A) :-	% copy _
	!,
	$process(Rest, L / K, A).
$process([C, Rest..], L / K, A) :-				% discard other characters
	$process(Rest, L / K, A).


$headers($doclause_r, Filename, Out, Filelist) :-
    concat(Filename, '.r', Outfile),
	$testfile(Outfile),
    open(Out, Outfile, read_write, IO),
    $open_check(IO,Filename,Out),
	$r_line1(Line1),
	$r_line2(Line2),
	swrite(Out, Line1, '\n', Line2, '\n'),
    cwamversion(V1),
	swrite(Out, '     Compiler Version ', V1, '\n'),
    $bcversion(V2),
	swrite(Out, '     Code Generator Version ', V2, '\n'),
	timedate(T, D),
	swrite(Out, '     Compiled: ', D, ' ', T, '\n'),
	$outputfilelist(Filelist, Out, '     Created from: '),
	swrite(Out, '***************************************************/\n\n'),
	$makename(Filename, DataName),
	gensym(DataName, ArrayName),
	remember(dataname(DataName, ArrayName), $local),
	swrite(Out, '#define OPTIONS\t\t, preload, purgeable\n\n',
				'type \'CNTX\' {\n\twide array stuff {\n\t\tlongint;\n\t};\n};\n',
				'type \'INTG\' {\n\twide array stuff {\n\t\tlongint;\n\t};\n};\n',
				'type \'FLOT\' {\n\twide array stuff {\n\t\tlongint;\n\t};\n};\n',
				'type \'SMBL\' {\n\twide array stuff {\n\t\tlongint;\n\t};\n};\n',
				'type \'CLAS\' {\n\twide array stuff {\n\t\tlongint;\n\t\tlongint;\n\t\tlongint;\n\t};\n};\n',
				'type \'OPER\' {\n\tlongint;\n\tcstring;\n};\n',
				'delete \'CNTX\';\n',
				'delete \'INTG\';\n',
				'delete \'FLOT\';\n',
				'delete \'SMBL\';\n',
				'delete \'CLAS\';\n',
				'delete \'OPER\';\n\n\n'),
	$quoteit(ArrayName, A),
	swrite(Out, 'resource \'CNTX\' (128, ', A, ', preload) {{\n\t').


$headers($doclause, Filename, Out, _):-
    concat(Filename,'.a',Outfile),
    tr-> [nl, write( 'Output in ',Outfile)],
    open(Out, Outfile, read_write,IO),
    $open_check(IO,Filename,Out),
    $output_headers(Out).

$output_headers(Outfile):-
    nl(Outfile),
    nl(Outfile),
    swrite(Outfile,';         Compiler Version          version 0   '),
    $bcversion(V2),
    nl(Outfile),
    swrite(Outfile,';         Code Generator Version    ',V2),
    nl(Outfile),
    nl(Outfile),
    set_end_of_file(Outfile).

$rewrite_header($doclause_c, _) :- !.
$rewrite_header($doclause_r, _) :- !.
$rewrite_header($doclause, Out) :-
	seek(Out, 0),
    nl(Out),
    nl(Out),
    cwamversion(V1),
    swrite(Out,';         Compiler Version          ', V1).


$compile_file([], _, _, _, _, _).
$compile_file(Filename, Out, Count, LineSize, G, C) :- 
	symbol(Filename),
    !,    
    counter_value(Count,OVal),
    foreach( $mreadfile(Filename,Term) do G(Term,Out,Count,C,LineSize)),
    counter_value(Count,Val),
	Val = OVal -> write('WARNING: Possible empty file ', Filename, '\n').
$compile_file([Filename,Filenames..], Out, Count, LineSize, G, C):-
    $compile_file(Filename, Out, Count, LineSize, G, C),
    !,
    $compile_file(Filenames, Out, Count, LineSize, G, C).

$mreadfile(Filename, Term) :- !,   % modified to provide IO checking
     open(Stream, Filename, read_only, IO_Open),
     $open_check( IO_Open, Filename, Stream),
     seek(Stream, 0),                                       % make sure we start at beginning
     repeat,
     at(Stream,Pos),
     get_term(Stream, Term, IOresult),
     $iocheck(IOresult,Filename,Stream,Pos),                % must be a call
     $handleanevent.

$open_check(0,_,_).   % open ok
$open_check(IO_err,Filename,_):- IO_err<>0,
    write('I/O error ', IO_err, ' opening file ', Filename), 
    fail. 
$open_check(0,_,Strm):- close(Strm,_), fail.   
    % downstream error, commit partial output for debugging purposes

$iocheck(0,_,_,_):-!.
$iocheck(IOErr,Filename,Stream,Spos):- 
	IOErr>0,!,
	nl, 
	remember(error(Strm), $local),
	error_string( syntax, IOErr,S) -> true,
	write('Syntax error ', IOErr,': ',S, ' in file ',Filename),
	nl,
	at(Stream, Epos),
	seek(Stream,Spos),
    lastparsererrorposition(ErrPos) ; ErrPos = unknown,
	repeat,
		get_char(Stream,C) -> put_char(1,C),
		at(Stream, Pos),
		Pos = ErrPos -> write('<<== HERE !! '),
		Pos = Epos,
		!,
		fail.
$iocheck(IOErr,_,Stream,_):- IOErr < 0,
    close(Stream, _), 
    failexit($mreadfile).

$handleanevent :-
	userevent(E, W, D1, D2, noblock),			% may not be implemented
	E \= userupidle,							% ignore userupidle events
	E(W, D1, D2),								% may fail
	!.											% simply succeed
$handleanevent.									% always succeed

$cc(F,Strm):-
    once($opcheck(F)),                      % if op def, assert it to keep parser updated
    compile_clause(F,Label,C), !,
    $emit_code(Strm,  Label,C), !.

$cc(F,Strm):-        % error
	remember(error(Strm), $local),
    nl, write(F).

$cc_c(F,Strm,Count):-
    once($opcheck(F)),                      % if op def, assert it to keep parser updated
    compile_clause(F,Label,C), !,
    $emit_code_c(Strm, Label, C, Count, F), !.

$cc_c(F,Strm, _):-        % error
	remember(error(Strm), $local),
    nl, write(F).

$cc_r(F,Strm,Count):-
    once($opcheck(F)),                      % if op def, assert it to keep parser updated
    compile_clause(F,Label,C), !,
    $emit_code_c(Strm, Label, C, Count, F), !.

$cc_r(F,Strm, _):-        % error
	remember(error(Strm), $local),
    nl, write(F).


$doclause(Term, Out, Count, _, LineSize):-
    $cc(Term,Out), 
    $beeble(Count, LineSize).

$doclause_c(Term, Out, Count, C, LineSize):-
    $cc_c(Term,Out,C), 
    $beeble(Count, LineSize).

$doclause_r(Term, Out, Count, C, LineSize):-
    $cc_r(Term,Out,C), 
    $beeble(Count, LineSize).

$beeble(Count, LineSize):-
    write('*'),
    Count,
    counter_value(Count,Val),
    $wraparound(Val,LineSize). 

$beeble$(Count, LineSize):-
    write('$'),
    Count,
    counter_value(Count,Val),
    $wraparound(Val,LineSize). 

$wraparound(Val, LineSize):- 0 is Val mod LineSize, nl.
$wraparound(_, _).




%  need to look for any operator definitions 
$opcheck(Functor(X..)) :- var(Functor),!,fail.	% catch clauses with variable functors
$opcheck( op(A,B,C)):- !,$op(A,B,C).
$opcheck( (op(A,B,C):-[])):- !,$op(A,B,C).
$opcheck( X).   


%  need to assert any operator definitions (if possible)
$op(A,B,C):- op(A,B,C),!, $newop(C,A,B)->true.
$op(A,B,C):- assert( op(A,B,C):-[]), !, $newop(C,A,B)->true.
$op(A,B,C):- write('Conflicting operator definition: '),fail.



%
%
%          ASCII Hex  ByteCode Generator for BNR Prolog
%
%
% provides:
%           $clear_symbol_table :- initializes symbol table 
%           $emit_code( Stream, Label, Code)  :- emits code for one clause
%                   where Label= Pfunc(Arity,First_Arg)
%           $newop(Symbol, Precedence,Type) :- installs new operator for subsequent parsing
%           $dump_symbol_table( Stream)     :- post processing
%
%
%
%           opcode organization   -entries indicate opcode type and format
%                blank - one byte short instructions
%                *  - one byte opcode followed by data  (short/long)
%                2  - one byte + one byte extension
%                3  - one byte plus 2 bytes extension
%                ?  - variable
%
% Change History:
%   Mar 29 90
%           swapped  put_val and put_var codings
%           replace  put_strucb with  unsafe
%           use escape codes for alloc and dealloc
%           add cuts and noop (in case of alignment problems)
%           add version
%           fixed field size problem with call and exec
%   May 5 90
%           add pushunsaf(P) opcode
%           add put_void(R) ==> put_vart(R,R)
%           add representation of []='0000'  (e.g. in unif_cons([]))
%   June 4 90
%           restrict explicit arities of structures to be 255
%           use escape code for put_vart(T,R) 
%           use previous put_vart(T,R) opcode for put_void(R)
%   July  9 90
%           alloc at opcode 06 (instead 0701)
%           unify_nil= unif_cons([]) at opcode 07
%           body code 05 is noop
%           putunsafe at 0738-073f
%           unif_unsafe at 18-1f
%   July  18 90
%           arithmetic opcodes added
%   Aug    7 90
%           inc/dec and dcut operators added
%   Sept  12 90
%           moved dealloc to body 06 from escape 05
%           added call/exec indirect
%           added call clause$$ opcode
%           fixed code for get_struct
%   Oct 5    90
%           environment size added to arithmetic relations (incl is)
%           ( no longer followed by escape )
%   Oct 23   90
%           add codes for fail and filters
%   Nov 12   output all operator defs
%
%   Nov 27   - add =/=  equiv to <>
%           add codes for ccut, cdcut, ccutfail, cdcutfail, cdcutreturn, cut(name), failexit(name)
%   Dec 10  V.9  - code for neckcon
%   Dec 17         -add envsize/dealloc to neckcon
%   Mar 6 91 V.10   - add unif_unsaft, push_unsaft
%   May 116 91      - fix encoding of put_vart
%   Sept 27 91  - env_size added to : ecut (0701) , ccut (0731) , ccut/1 (0735) 
%   Sept 30 91  - added ccutsp (0798) to do ccut without invoking gc
%   Oct  30 91 -  add gcalloc and cutexec opcodes

%                                     Head
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    |   .   misc.   .*l .   .   .   |2* | * .  get_cons . * . * .   |
%      1    |2*b|   get_struc(short).   .   |2  |   .   .   .   .   .   .   |
%      2    |2  |   get_list.   .   .   .   |2  |   .  get_nil  .   .   .   |
%      3   _|3  | 2 get_valt    2   2   2   |3  |   2  get_valp 2   2   2   |
%      4    |2  |   unify_vart  .   .   .   |2  |   .  unify_varp   .   .   |
%      5    |2  |   unify_valt  .   .   .   |2  |   .  unify_valp   .   .   |
%  n   6    |2  |   tunify_vart .   .   .   |2  |   .  tunify_varp  .   .   |
%  i   7   _|2  |   tunify_valt _   _   _   |2  |   _  tunify_valp  _   _   |
%  b   8    |3  |2  .2  .2  .2  .2  .2  .2  |3  |2  .2  .2  .2  .2  .2  .2  |
%  b   9    |2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%  l   A    |2  |   .#  .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%  e   B   _|2  |   .   .&  .   .   .   .   |2  |   .   .   .   .   .   .   |
%  1   C    |2  |   get_vart.$  .   .   .   |2  |   .   .get_varp   .   .   |
%      D    |2  |   .   .   .   .@  .   .   |2  |   .   .   .   .   .   .   |
%      E    |2  |   .   .   .   .   .gc .   |2  |   .   .   .   .   .   .   |
%      F   _|2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%
%      *  -
%      &  -
%      $  -
%      @  -
%      gc - gcalloc  ( like alloc, but may create a dummy choicepoint)
%      Corresponding table for body codes is  similar 
%      if  put is substituted for get, push for unify, tpush for tunify,
%       except   get_val become put_vars and vice-versa
%
%                                     Body
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    |   .   misc.   .   .   .   .???|2* | * .  put_cons . * . * .   |
%      1    |2  |   put_struc   .   .   .   |2  |   .   .   .   .   .   .   |
%      2    |2  |   put_list.   .   .   .   |2  |   .  put_nil  .   .   .   |
%      3   _|2  |   put_void    .   .   .   |3  |   2  put_varp 2   2   2   |
%      4    |2  |   push_vart   .   .   .   |2  |   .  push_varp    .   .   |
%      5    |2  |   push_valt   .   .   .   |2  |   .  push_valp    .   .   |
%  n   6    |2  |   tpush_vart  .   .   .   |2  |   .  tpush_varp   .   .   |
%  i   7   _|2  |   tpush _valt _   _   _   |2  |   _  tpush_valp   _   _   |
%  b   8    |3  |2  .2  .2  .2  .2  .2  .2  |3  |2  .2  .2  .2  .2  .2  .2  |
%  b   9    |2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%  l   A    |2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%  e   B   _|2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%  1   C    |2  |   .   put_valt.   .   .   |2  |   .   .put_valp   .   .   |
%      D    |2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%      E    |2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%      F   _|2  |   .   .   .   .   .   .   |2  |   .   .   .   .   .   .   |
%
%    escape codes used for put_vart, dealloc, unify_nil
%
%      The first rows in more detail are:
%
%                       head                    body            body escape
%       00      |   neck                 |  proceed             | 
%       01      |   unif_void            |  push_void           |  ecut
%       02      |   tunif_void           |  tpush_void          |  dcut
%       03      |   end__seq             |  push_end            |  push_nil
%       04      |   unif_cons(C)         |  push_cons(C)        |  eval_cons
%       05      |   noop                 |  noop                |  noop
%       06      |   alloc                |  call/exec           |  dealloc
%       07      |   unify_int            |  escape              |  escape (back)
%
%       31                                                      | ccut
%       32                                                      | cdcut
%       33                                                      | ccutfail
%       34                                                      | cdcutfail
%       35                                                      | cut(Name)
%       36                                                      | failexit(Name)
%
% Note:    data movement as follows:
%          get..       temp => temp or perm           (read mode)
%          unify...    from memory => temp or perm    (read mode)
%          put..       temp or perm or constant => temp
%          push        temp or perm or constant => memory (heap)
%   ( in write mode, the unify instructions are the same as push )
%
%                                     Body Escape
%               
%    nibble2: 0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
%      0    |   . ! .   .   . * . * . * . * |   |ci . c .ei . e .cls.   fail|
%      1    |2  |   .   vart.   .   .   .   |2  |   .   .varp   .   .   .   |
%      2    |2  |   .   tvart   .   .   .   |2  |   .   .tvarp  .   .   .   |
%      3   _|   |(**cut stuff**)    .   .   |2  |   .   .   .   .   .   .   |
%      4    |2  |   .   test.   .   .   .   |   |   .   .testp  .   .   .   |
%      5    |2  |   .   popvalt .   .   .   |2  |   .   .popvalp.   .   .   |
%  n   6    |2  |   .   evalt   .   .   .   |2  |   .   .evalp  .   .   .   |
%  i   7   _|2  |   .   popvart .   .   .   |2  |   .   .popvarp.   .   .   |
%  b   8    |3  |2  .2  .2  .2  .2  .2  .2  |3  |   .   .   .   .   .   .   |
%  b   9    |2  |   .   .   .   .   .   .   |   | + . - . * .// . / .mod.** |
%  l   A    |2  |   .   .   .   .   .   .   |   |int.flt.flr.cei.rnd.max.min|
%  e   B   _|2  |   .   .   .   .   .   .   |   |srt.abs.exp. ln.inc.dec.neg|
%  1   C    |2  |   .   put_valt.   .   .   |   |sin.cos.tan.asn.acs.atn. bn|
%      D    |2  |   .   .   .   .   .   .   |   |== .=< . >=. < . > .<> . bs|
%      E    |2  |   .   .   .   .   .cex.   |   |mxi.mxr. pi.cpu. ba. bo. be|
%      F   _|2  |   .   .   .   .   .   .   |   |   .   .   .   .   .   .   |
%
%   bn - butnot, bs - bitshift, ba - bitand, bo - bitor, be - biteq
%
%   cex - cutexec  ( equiv to dcut, exec)
%
%                           Instruction Formats
%
%                               note: "dst" and "sr"c as in read mode
%   
%   single register  one & two byte instructions
%           [ AAAA| B | REG ],
%  2        [ AAAA| B | 000 ] [ dst ext]
%   double register   two byte instructions
%  2        [ AAAA| B | SRC ] [ dst ext]
%   double register one to three byte (*_var) instructions
%           [ F| SRC | P | DST ],
%  2        [ F| 000 | P | DST ],[src ext]
%  2        [ F| SRC | P | 000 ],[dst ext]
%  3        [ F| 000 | P | 000 ],[src ext],[dst ext]
%
%  *****NOTE: fmt 3  changed from document to new format:  [ 1 src PT dst ] ********************
%       .
%  calls:
%   Call:    06 NN PPPP EE
%   Exec:    06 NN PPPP
%   Cutexec: E6 NN PPPP
%    where    
%             N  is arity  
%             PPPP is predicate symbol
%             EE  is environment size  (possibly used by callee during alloc )
%

%
%          File  Output
%
$emit_code(Strm, Label, Code):-
    $cond_nl(Strm),
    $outlab(Label,Strm),
    $all_nnout(Code,Strm),!,
    $cond_nl(Strm).
  

$cond_nl(Strm):- predicate(annotate_code), !, nl(Strm).
$cond_nl(Strm).


$all_nnout( [], F).
$all_nnout( [X,Xs..],F):- $nnout(X,F),!,$all_nnout(Xs,F).

$nnout(X,F):-not(not( $out(X,F))).

$out( [], F) :- !.
$out( [Xs..] ,F) :- !, $all_nnout(Xs,F).

$out( hcomment(C),F) :- predicate(annotate_code), !, swrite(F,'   ;'), swriteq(F,C), swrite(F,':-  ').
$out( hcomment(C),F) :- !.
$out( comment(C), F) :- predicate(annotate_code), !, nl(F), $tab(c,T), swrite(F,T,'; '), swriteq(F,C).
$out( comment(C), F) :- !.
$out( X, F) :- predicate(annotate_code), !, $gencode(X,S), !, $$out(S,F,X).
$out( X, F) :- $gencode(X,S), !, swrite(F,S).

$$out( S,F,X):- $quotable(X), !, nl(F), swrite(F,S),$putq(X,F).
$$out( S,F,X):- nl(F), swrite(F,S),$putf(X,F).


$quotable(F(_..)):-$quote(F).
$quote( unif_cons).
$quote( push_cons).
$quote( put_cons).
$quote( get_cons).

$putf( Op(A),F):-swrite(F,Op,'\t',A).
$putf( Op(A,B),F):-swrite(F,Op,'\t',A,',\t',B).
$putf( Op,F):-swrite(F,Op).

$putq( Op(A),F):-swrite(F,Op,'\t'), swriteq(F,A).
$putq( Op(A,B),F):-swrite(F,Op,'\t'), swriteq(F,A), swrite(F,',\t'), swriteq(F,B).
$putq( Op,F):-swrite(F,Op).

$tab(_,'       ').

%
%
%      descriptive language
%          X + Y     catenation of nibbles,bytes, words, etc.
%          b * R     set bit b into high order of register descriptor R
%          $addr(A)  find symbol table "address" of symbol A 
%          w(N)      word (4 hex digits)
%        ( converts small numbers (1  byte ) to hex strings )
%

$seval( S,  S):- symbol(S),!.
$seval( N,  S):- integer(N),!, $hexbyte(N,S).        % byte ints only
$seval( w(N),S):- integer(N),!, $wordhex(N,S).
$seval( B*N,S):- $reg(B,N,D,E),$cat(D,E,S),!.        % see below
$seval( $addr(A),S):- !, $ref( A,S). % depends on tagging & symbol table
$seval(X + Y,S):- $seval(X,SX), $seval(Y,SY), $cat(SX,SY,S),!.
%$seval( Unknown, S):-swrite(S,Unknown).  

%
%     Symbol Table
%
$clear_symbol_table(_,_):- $clear_symbol_table.
$clear_symbol_table :-
	new_state(0,$local),
	new_state(20,$local),
	remember(st([],0,'0000'),$local),
	remember(next(0),$local).

$newop(Symbol,Precedence,Type):- remember( newop(Symbol,Precedence,Type),$local).

$ref(Atom, Ref):- recall(st(Atom, _, Ref), $local), !.
$ref(Atom, Ref):- atomic(Atom), $newref(Atom, Ref).
$ref([], '0000').      % ???  is this really needed

$newref(A, Ref) :-
	get_obj(Index, next(N), $local),
	successor(N, N1),
	N2 is -N1,
	$wordhex(N2, Ref),
	!,
	remember(st(A, N1, Ref), $local),
	put_obj(Index, next(N1), $local).

$type(A, int):-integer(A).
$type(X, flt):-float(X).
$type(S, X(P,T,U)):- op( P,T,S),cut, op(P, U, S), T \= U, !,
                        recall(newop(S,_,_),$local) -> X=newop; X=op.
$type(S, X(P,T)):- op( P,T,S),!, recall(newop(S,_,_),$local) -> X=newop; X=op.
$type(S, newop(P,T,U)):- recall(newop(S,P,T),$local),cut,
                         op(P,U,S); recall( newop(S,P,U),$local), T\=U,!.
$type(S, newop(P,T)):-  recall( newop(S,P,T),$local),!.
$type(S, sym):-symbol(S).

 
$dump_symbol_table($doclause, Out, _, _):-
    foreach( recall( st(Atom,N,Ref), $local) do
    [ $type(Atom,T),nl(Out),swrite(Out,' sym ',Ref,':',T,'='),swriteq(Out,Atom)]),
    nl(Out).
              
%
%       Register assumptions and coding
%
%    - temporary register labeled 1-255      (0 reserved for escape)
%      permanent registers labeled 1-255     (0 reserved for escape)
%    - first 7 registers of either type may be short addressed
%    - arguments are passed in first  temporary registers 1..64
%    - note that this is intended specifically for 7 hardware register implementation
%      since most machines do not usually allow registers to be addressed as memory
%
$argreg0( R,  S):- $hexdig(R,S).
$argreg1( R,  S):- R1 is 8 + R,$hexdig(R1,S).
$extension( 0,'0').   % register extension codes
$extension( 1,'8').

$rg(R,R,''):- R>0, R=<7,!.
$rg(R,0,S):- R>0,$hexbyte(R,S).
 
$reg( B, 0,  Esc,''):- !,$extension(B,Esc).
$reg( B, R,  S,  ''):-  R>0,R=<7,!,B@=1 -> $argreg1(R,S);$argreg0(R,S).
$reg( B, R,  Esc,Ext):- $extension(B,Esc), $hexbyte(R,Ext).
%
%
%   noops 
$encode( get_valt(X,X), ''):-!.
$encode( put_valt(X,X), ''):-!.
$encode( get_vart(X,X), ''):-!.
$encode( put_vart(X,X), ''):-!,fail.  % shouldn't be generated
%
%

%
%                      Head  
%
%
$encode( neck,             '00').
$encode( neckcon(0),       '050006'):-!.                % neckcon + dealloc
$encode( neckcon(Size),    '05' + Size + '05').       % neckcon + nop
$encode( neckproceed,      '0500').  % second zero is actually a body code
$encode( unif_void,        '01').
$encode( tunif_void,       '02').
$encode( end_seq,          '03').
$encode( unif_cons([]),    '07').    %equiv to unif_nil
$encode( unif_cons(C),     '04' + $addr(C)).
$encode( noop        ,     '05').
$encode( alloc       ,     '06').
$encode( gcalloc     ,     'E6').
$encode( unif_nil ,        '07').
%
%
%
%       get instructions
% 
$encode(  get_cons(C,R) ,   '0' + 1* R + $addr(C)):-R>0.
$encode(  get_struc(N,R),   '1' + 0* R + N  ):-R>0.
%     var instructions
$encode(  get_valp(P,R),    '3' + 1*R + P ):-R>0. 
$encode(  get_valt(T,R),    '3' + 0*R + T ):-R>0.
$encode(  get_varp(P,R),   1*S + 1*D + SExt + DExt)  :- $rg(R,S,SExt),$rg(P,D,DExt).
$encode(  get_vart(P,R),   1*S + 0*D + SExt + DExt)  :- $rg(R,S,SExt),$rg(P,D,DExt).
%    head  unification & lists
$encode(  Unif(Reg),       Op + B*Reg )  :- $opcode(Unif,Op,B).
%    where : 
$opcode( get_list,       '2', 0).
$opcode( get_nil,        '2', 1).
$opcode( unif_vart,      '4', 0).
$opcode( unif_varp,      '4', 1).
$opcode( unif_valt,      '5', 0).
$opcode( unif_valp,      '5', 1).
$opcode( tunif_vart,     '6', 0).
$opcode( tunif_varp,     '6', 1).
$opcode( tunif_valt,     '7', 0).
$opcode( tunif_valp,     '7', 1).
%
%
%                      Body  
%
%
%       miscellaneous instructions
%
$encode( proceed,          '00').
$encode( push_void ,       '01').
$encode( tpush_void,       '02').
$encode( push_end,         '03').
$encode( push_cons([]),    '0703').
$encode( push_cons(C),     '04' + $addr(C)).
$encode( noop,             '05').       
$encode( dealloc,          '06').
$encode( call( call_i/1, Size),     '0709' + Size).
$encode( call( clause$$/3, Size),   '070D' + Size).
$encode( call( cut/1, Size),        '0735' + Size).
$encode( call( failexit/1,Size),    '0736' ).
$encode( call( F/N,Size),           '070A' + N + $addr(F) + Size).
$encode( exec( exec$$/2),           '070E').
$encode( exec( call_i/1),           '070B').
$encode( exec( F/N) ,               '070C' + N + $addr(F)   ).
$encode( cutexec( F/N) ,            '07E6' + N + $addr(F)   ).
$encode( escape ,          '07').  % for adding new opcodes
$encode( push_nil,         '0703'). %
%      special instructions using escape
%
$encode(  cutreturn,       '070200').
$encode(  ecut(Size),      '0701' + Size).
$encode(  dcut,            '0702').
$encode(  fail,            '070F').

$encode(  ccut(Size),           '0731' + Size).
$encode(  ccutsp,           	'0798').
$encode(  cdcut,                '0732').
$encode(  cdcutreturn,          '073200').
$encode(  ccutfail,             '0733').
$encode(  cdcutfail,            '0734').
$encode(  label_env,            '0737').
$encode(  more_choicepoints,    '0730').
%                                                     
%
%       put instructions
% 
$encode(  put_cons(C,R) ,   '0' + 1*R + $addr(C)).
$encode(  put_struc(N,R),   '1' + 0*R + N  ).
%
%     var instructions
%
$encode(  put_valp(P,R),   1*S + 1*D + SExt + DExt)  :- $rg(R,S,SExt),$rg(P,D,DExt).
$encode(  put_valt(T,R),   1*S + 0*D + SExt + DExt)  :- $rg(R,S,SExt),$rg(T,D,DExt).
$encode(  put_varp(P,R),   '3' + 1*R + P ). 
$encode(  put_vart(T,R),   '07' + 1*S + 0*D + SExt + DExt) :- % note escape !!
                $rg(R,S,SExt), $rg(T,D,DExt).
$encode(  put_void(R),     '3' + 0*R ).    
%
%    head  unification & lists
%
$encode(  Push(Reg),        Op + B*Reg )  :- $opcode( Push,Op,B).
    % where 
$opcode( put_list,       '2', 0).
$opcode( put_nil,        '2', 1).
$opcode( push_vart,      '4', 0).
$opcode( push_varp,      '4', 1).
$opcode( push_valt,      '5', 0).
$opcode( push_valp,      '5', 1).
$opcode( tpush_vart,     '6', 0).
$opcode( tpush_varp,     '6', 1).
$opcode( tpush_valt,     '7', 0).
$opcode( tpush_valp,     '7', 1).

$encode( VFilter(Reg),     '07' + Op + B*Reg) :- $vfilter( VFilter, Op,B).
    % where
$vfilter( vart, '1', 0).
$vfilter( varp, '1', 1).
$vfilter( tvart, '2', 0).
$vfilter( tvarp, '2', 1).

$encode( Filter(Reg, Mask),     '07' + Op + B*Reg + M) :- 
    $filter( Filter, Op,B),  $mask(Mask,M).

$filter( testt, '4', 0).
$filter( testp, '4', 1).

% mask - bits arranged as :   [_, _, _, flt, int, sym, str, list]
$mask( float,        '10').
$mask( integer,      '08').
$mask( symbol,       '04').
$mask( structure,    '02').
$mask( list,         '01').
$mask( compound,     '03').
$mask( numeric,      '18').
$mask( number,       '18').
$mask( nonvar,       '1F').

$mask( noninteger,   '17').		% added Oct 21
$mask( nonsymbol,    '1B').
$mask( nonfloat,     '0F').
$mask( nonnumeric,   '07').
$mask( nonnumber,    '07').
$mask( nonstructure, '1D').
$mask( nonlist,      '1E').
$mask( noncompound,  '1C').
%
%            arithmetic
%
$encode(X,Y):-$esc(X,Y),!.
% $encode( escape( X ),  [escape, EX] ):-  write( escape(X..)), $escseq( X, EX).
% $escseq([],[]):-!.
% $escseq([X,Xs..],[EX,EXs..]):- $esc(X,EX),!, $escseq(Xs,EXs).
% $esc( [X..], Y) :-!, $escseq(X,Y).

$esc(  eval_cons(C), '04' + $addr(C)). 
$esc(  pop_valp(V,Size),  '5' + 1*V + Size):- $ref(is,_).
$esc(  eval_valp(V), '6' + 1*V ).
$esc(  pop_varp(V,Size),  '7' + 1*V + Size):- $ref(is,_).
$esc(  pop_valt(V,Size),  '5' + 0*V + Size):- $ref(is,_).
$esc(  eval_valt(V), '6' + 0*V ).
$esc(  pop_vart(V,Size),  '7' + 0*V + Size):- $ref(is,_).
$esc(  eval_sym(maxint),    'E9').
$esc(  eval_sym(maxreal),   'EA').
$esc(  eval_sym(pi),        'EB').
%%% $esc(  eval_sym(¹),         'EB').
$esc(  eval_sym(cputime),   'EC').
%   $esc(  eval_varp(V), _).  These correspond to meaningless constructs.
%   $esc(  eval_vart(V), _).



$esc( '=='(Size),  'D9' + Size):- $ref('==',_).
$esc( '=<'(Size),  'DA' + Size):- $ref('=<',_).
$esc( '>='(Size),  'DB' + Size):- $ref('>=',_).
$esc( '<'(Size) ,  'DC' + Size):- $ref('<',_).
$esc( '>'(Size) ,  'DD' + Size):- $ref('>',_).
$esc( '<>'(Size)  ,'DE' + Size):- $ref('<>',_).
$esc( '=/='(Size) ,'DE' + Size):- $ref('=/=',_).


$esc( '+',  '99'):- $ref('+',_).
$esc( '-',  '9A'):- $ref('-',_).
$esc( '*',  '9B'):- $ref('*',_).
$esc( '//', '9C'):- $ref('//',_).
$esc( '/',  '9D'):- $ref('/',_).
$esc( 'mod','9E'):- $ref('mod',_).
$esc( '**', '9F'):- $ref('**',_).

$esc( neg,     'BF').
$esc( integer, 'A9').
$esc( float  , 'AA').
$esc( floor  , 'AB').
$esc( ceiling, 'AC').
$esc( round  , 'AD').
$esc( max    , 'AE').
$esc( min    , 'AF').

$esc( sqrt   , 'B9').
$esc( abs    , 'BA').
$esc( exp    , 'BB').
$esc( ln     , 'BC').
$esc( inc    , 'BD').
$esc( dec    , 'BE').
$esc( neg    , 'BF'):-$ref('-',_).

$esc( sin    , 'C9').
$esc( cos    , 'CA').
$esc( tan    , 'CB').
$esc( asin   , 'CC').
$esc( acos   , 'CD').
$esc( atan   , 'CE').

% bit-wise operators, Jan 1996 by yanzhou@bnr.ca
$esc( butnot   , 'CF') :- $ref(butnot,_).
$esc( bitshift , 'DF') :- $ref(bitshift,_).
$esc( bitand   , 'ED') :- $ref(bitand,_).
$esc( bitor    , 'EE') :- $ref(bitor,_).
$esc( biteq    , 'EF') :- $ref(biteq,_).

% boolean operators, Feb 1996 by yanzhou@bnr.ca
$esc( '~'      , 'F8')   :- $ref('~',_).
$esc( and      , 'F9')   :- $ref(and,_).
$esc( or       , 'FA')   :- $ref(or ,_).
$esc( xor      , 'FB')   :- $ref(xor,_).
$esc( nand     , 'F9F8') :- $ref(nand,_).
$esc( nor      , 'FAF8') :- $ref(nor ,_).
$esc( ->       , 'FC')   :- $ref(->,_).
$esc( ==       , 'FD')   :- $ref(==,_).
$esc( =:=      , 'FD')   :- $ref(=:=,_).
$esc( <>       , 'FDF8') :- $ref(<>,_).
$esc( =\=      , 'FDF8') :- $ref(=\=,_).
$esc( >        , 'FE')   :- $ref(>,_).
$esc( =<       , 'FEF8') :- $ref(=<,_).
$esc( <        , 'FF')   :- $ref(<,_).
$esc( >=       , 'FFF8') :- $ref(>=,_).

$encode(Op, _) :- nl, nl, swrite(1, '***** Nothing defined for ', Op, ' ******'), nl, nl, fail.

$outlab( F(Arity,Hash), Stream):-        % note output is:   Func + Hash + Arity
	symbol(F),
    nl(Stream),
    $seval($addr(F),Func),
    $hash(Hash,Hsh),
    $hexbyte(Arity,Ar),
    swrite(Stream,'proc ',Func,Hsh,Ar),!.
$outlab( Label,Stream):-nl(Stream),swrite(Stream,Label,': ').   % in case of error

$hash(V, '0000') :- var(V).
$hash([V..], '0000') :- tailvar(V..).
$hash([], '0888').
$hash([_..], '0AAA').
$hash(F(_..), Hash) :- nonvar(F), $seval($addr(F), Hash).
$hash(X, Hash) :- $seval($addr(X), Hash).
$hash(_,'0000').

$gencode(Instruction, Bytesequence):- 
    $encode(Instruction, Fmt), $seval(Fmt,Ins),
    $pad(Ins,Bytesequence),!.
$gencode( _,'          ') :- predicate(annotate_code).      % in case of error 

/*
codegen( []).
codegen( [In,Ins..]):- $encode(In,Exp),$seval(Exp,Out);swrite(Exp,Out),!,
                       nl, write(Out),!,
                       codegen(Ins).
*/
%
%             Utilities 
%
$pad( Str, Pstr):-
    namelength(Str,N), 
    $pad1(N,Ps),!, $cat(Str,Ps,Pstr).

$cat(X,Y,XY):- swrite(XY,X,Y).

$hexint( N, HN, 0) :- $hexbyte(N,HN),!.
$hexint( N, HN, 1) :- $wordhex(N,HN).
$wordhex(N,S):-  N>=0,
            M is N // 256,  M<256, R is N mod 256, 
            $hexbyte(R,HR),
            $hexbyte(M,HM), 
            $cat(HM,HR,S).
$wordhex(N,S):- N<0, MN is 65536 + N, $wordhex(MN,S).
%
%
$hexbyte( N, H):- N>=0,N<256,!, M is N // 16, R is N mod 16,
                 $hexdig(M,HM), $hexdig(R,HR), $cat(HM,HR,H). 
$hexbyte( N,H):-N<0,!, MN is 256 + N, $hexbyte(MN,H). 
$hexbyte( N, H):- $cat(HM,HR,H),not( HM@=''),not(HR@=''),!,
                 $hexdig(M,HM), $hexdig(R,HR),  N is R + 16*M.  
              

$hexdig( 0,'0').
$hexdig( 1,'1').
$hexdig( 2,'2').
$hexdig( 3,'3').
$hexdig( 4,'4').
$hexdig( 5,'5').
$hexdig( 6,'6').
$hexdig( 7,'7').
$hexdig( 8,'8').
$hexdig( 9,'9').
$hexdig(10,'A').
$hexdig(11,'B').
$hexdig(12,'C').
$hexdig(13,'D').
$hexdig(14,'E').
$hexdig(15,'F').

$pad1(_,''):- not(predicate(annotate_code)),!.
$pad1(0,'            ;').
$pad1(1,'           ;').
$pad1(2,'          ;').
$pad1(3,'         ;').
$pad1(4,'        ;').
$pad1(5,'       ;').
$pad1(6,'      ;').
$pad1(7,'     ;').
$pad1(8,'    ;').
$pad1(9,'   ;').
$pad1(_,'   ;').


$emit_code_c(Stream, Label(Arity, Hash), Code, BytePosition, Clause):-
	%% swrite(Stream, '\n\n', Label, '\n'),
	$outputfiller(Stream, 0, BytePosition),			% line up on 4 byte boundary
	comment_code ->
		[ swrite(Stream, '0, 0x0, 0x0,  /* ', Label, '/', Arity, ' */\n'),
          portray_with_indent(Stream, '/*  ', Clause, 0),
		  swrite(Stream, '.  */\n    0x0, 0x0, 0x0,\n    0x') ] ;
		swrite(Stream, '0, 0x0, 0x0,\n    0x0, 0x0, 0x0,\n    0x'),
	counter_value(BytePosition, B),
	C is B // 4,
	remember(clause(Label, Arity, Hash, C), $local),
	$lookuphash1(Hash, H) -> rememberz(needs(H, C), $local),
	BytePosition, BytePosition, BytePosition, BytePosition,
	BytePosition, BytePosition, BytePosition, BytePosition,
	BytePosition, BytePosition, BytePosition, BytePosition,
	BytePosition, BytePosition, BytePosition, BytePosition,
	BytePosition, BytePosition, BytePosition, BytePosition,
	BytePosition, BytePosition, BytePosition, BytePosition,
    $all_nnout_c(Code, Stream, BytePosition),
	$outputfiller(Stream, 0, BytePosition).			% line up on 4 byte boundary
  

$all_nnout_c([], F, _).
$all_nnout_c([X, Xs..], F, BytePosition) :- 
	$nnout_c(X, F, BytePosition),
	!,
	$all_nnout_c(Xs, F, BytePosition).

$nnout_c(X, F, BytePosition) :- not(not($out_c(X, F, BytePosition))).

$out_c([], _, _) :- !.
$out_c([Xs..], Stream, BytePosition) :- !, $all_nnout_c(Xs, Stream, BytePosition).
$out_c(hcomment(C), _, _) :- !.
$out_c(comment(C), _, _) :- !.
$out_c(Instruction, Stream, BytePosition) :- 
	$encode(Instruction, Fmt),
	$seval_c(Fmt, InsSeq, SymbolRef),
	!,
	comment_code -> rememberz(ins(Instruction), $local),
	$output_test(SymbolRef, Stream, InsSeq, BytePosition).

$output_test(SymbolRef, Stream, InsSeq, BytePosition) :-
	var(SymbolRef),
	!,
	name(InsSeq, L),
	$output_code(L, Stream, BytePosition).
$output_test(SymbolRef, Stream, InsSeq, BytePosition) :-
	% SymbolRef is used, special handling
	name(InsSeq, L),
	$scanopcodes(L, First, Last, 0, Position),	% position indicates necessary starting position
	P is (8 - Position) mod 4,					% in case more than 4 opcodes before
	$outputfiller(Stream, P, BytePosition),
	$output_code(First, Stream, BytePosition),
	counter_value(BytePosition, B),
	C is B // 4,
	rememberz(needs(SymbolRef, C), $local),
	$output_code([0'0, 0'0, 0'0, 0'0, 0'0, 0'0, 0'0, 0'0], Stream, BytePosition),
	$output_code(Last, Stream, BytePosition).

$outputfiller(Stream, Position, BytePosition) :-
	counter_value(BytePosition, X),
	Position is (X mod 4),
	!.
$outputfiller(Stream, Position, BytePosition) :-
	$output_code([0'f, 0'7], Stream, BytePosition),
	$outputfiller(Stream, Position, BytePosition).

$scanopcodes([0'x, 0'x, Rest..], _, [Rest..], Length, Length) :- !.
$scanopcodes([C1, C2, Rest..], [C1, C2, New..], Last, Length, Pos) :- 
	Length1 is Length + 1,
	$scanopcodes([Rest..], [New..], Last, Length1, Pos).

$output_code([], Stream, BytePosition) :- !.
$output_code([C1, C2, Cs..], Stream, BytePosition) :-
	name(X, [C1, C2]),
	swrite(Stream, X),
	BytePosition,
	$checkposition(Stream, BytePosition),
	$output_code([Cs..], Stream, BytePosition).

$checkposition(Stream, BytePosition) :-
	counter_value(BytePosition, X),
	0 is (X mod 4),
	comment_code ->
		[swrite(Stream, ',        /*'), $doopcodes(Stream, ' '), swrite(Stream, ' */\n    0x')] ;
		swrite(Stream, ',\n    0x'),
	!.
$checkposition(_, _).	

$doopcodes(Stream, Before) :-
	forget(ins(X), $local),
	!,
	swrite(Stream, Before, X),
	$doopcodes(Stream, ', ').
$doopcodes(_, _).


$seval_c(S, S, _) :- 
	symbol(S),
	!.
$seval_c(N, S, _) :- 		        % byte ints only
	integer(N),
	!,
	$hexbyte(N,S).
$seval_c(w(N), S, _) :- 
	integer(N),
	!,
	$wordhex(N,S).
$seval_c(B*N, S, _) :- 
	$reg(B,N,D,E),
	$cat(D,E,S),
	!.
$seval_c($addr(A), 'xx', A) :-
	$ref(A,S),					% depends on tagging & symbol table
	!.
$seval_c(X + Y, S, A) :-
	$seval_c(X, SX, A),
	$seval_c(Y, SY, A),
	$cat(SX,SY,S),
	!.

$dump_symbol_table($doclause_c, Stream, BeebleCount, LineSize) :-
	swrite(Stream, '0'),
	recall(dataname(DataName, ArrayName), $local),
	new_counter(0, C),
	$dumpneeds(Stream, ArrayName, DataName, C, 10000, BeebleCount, LineSize),
	$dumpclauses(Stream, ArrayName, DataName, C, BeebleCount, LineSize),
	swrite(Stream, '    };\n\n'),
	swrite(Stream, 'BNRP_embedContext_', DataName, '()\n{\n'),
    $fileformat(V2),
	$quoteit(DataName, Sym),
	swrite(Stream, '    BNRP_embedContext(', Sym, ', ', V2, ');\n'),
	counter_value(C, N),
	$dumpcalls(Stream, DataName, N),
	$dumpops(Stream),
	swrite(Stream, '    }\n').

$dumpcalls(Stream, DataName, N) :-
	integer_range(I, 1, N),
	swrite(Stream, '    BNRP_embedContext_', DataName, '_', I, '();\n'),
	fail.
$dumpcalls(_, _, _).

$dumpneeds(Stream, ArrayName, DataName, Index, Count, BeebleCount, LineSize) :-
	forget(needs(SymbolRef, C), $local),
	!,
	$tryheader(Stream, DataName, Index, Count, Count1, "\n    long t;", BeebleCount, LineSize),
	swrite(Stream, '    t = '),
	$dumpfilter(SymbolRef, Stream),
	swrite(Stream, '    ', ArrayName, '[', C, '] = t;\n'),
	new_counter(0, X),
	foreach(forget(needs(SymbolRef, D), $local) do
			[swrite(Stream, '    ', ArrayName, '[', D, '] = t;\n'), X]),
	counter_value(X, X1),
	Count2 is Count1 + 2 + X1,
	$dumpneeds(Stream, ArrayName, DataName, Index, Count2, BeebleCount, LineSize).
$dumpneeds(_, _, _, _, _, _, _).

$dumpfilter(SymbolRef, Stream) :-
	integer(SymbolRef),
	!,
	swrite(Stream, 'BNRP_embedInt(', SymbolRef, ');\n').
$dumpfilter(SymbolRef, Stream) :-
	float(SymbolRef),
	!,
	swrite(Stream, 'BNRP_embedFloat(', SymbolRef, ');\n').
$dumpfilter(SymbolRef, Stream) :-
	symbol(SymbolRef),
	!,
	$quoteit(SymbolRef, Sym),
	swrite(Stream, 'BNRP_embedSymbol(', Sym, ');\n'),
	!.
$dumpfilter(SymbolRef, _) :-
	write('Unable to determine type of ', SymbolRef, '\n').

% Modified as per RWorkman's June Bug report

$quoteit(SymbolRef, Sym) :-
	   swriteq(PSym, SymbolRef),
    name(PSym,[34,PChars..]),  % is it a quoted symbol
    $sym_c(PChars,CChars),     % if so scan for hex escape sequences
    name(Sym,[34,CChars..]),   % and convert syntax
    !.

$quoteit(SymbolRef, Sym) :-
	   swrite(Sym, '"', SymbolRef, '"').

$sym_c([],[]).   % end of the road
$sym_c([0'\,0'\,PChars..],[0'\,0'\,CChars..]):-
    !, % '\\' passes straight through
    $sym_c(PChars,CChars).
$sym_c([0'\,H1,H2,PChars..],[0'\,0'x,H1,H2,0'",0' ,0'",CChars..]):-
    $hex_digit(H1),
    $hex_digit(H2),!,
    $sym_c(PChars,CChars).
$sym_c([C,PChars..],[C,CChars..]):-
    $sym_c(PChars,CChars).

$hex_digit(C):-C>=0'0,C=<0'9.
$hex_digit(C):-C>=0'A,C=<0'F. % Note: uppercase only

/*
$quoteit(SymbolRef, Sym) :-
           swriteq(PSym, SymbolRef),
    name(PSym,[34,PChars..]),  % is it a quoted symbol
    $sym_c(PChars,CChars),     % if so scan for hex escape sequences
    name(Sym,[34,CChars..]),   % and convert syntax

$quoteit(SymbolRef, Sym) :-
           swrite(Sym, '"', SymbolRef, '"').
*/
/*Before $sym_c fix $quoteit looke like this:
     $quoteit(SymbolRef, Sym) :-
	     swriteq(Sym, SymbolRef),
	     substring(Sym, 1, 1, '"'),
	     !.
     $quoteit(SymbolRef, Sym) :-
	     swrite(Sym, '"', SymbolRef, '"').
*/
/*
$sym_c([],[]).   % end of the road
$sym_c([0'\,0'\,PChars..],[0'\,0'\,CChars..]):-
    !, % '\\' passes straight through
    $sym_c(PChars,CChars).
$sym_c([0'\,H1,H2,PChars..],[0'\,0'x,H1,H2,0'",0' ,0'",CChars..]):-
    $hex_digit(H1),
    $hex_digit(H2),!,
    $sym_c(PChars,CChars).
$sym_c([C,PChars..],[C,CChars..]):-
    $sym_c(PChars,CChars).

$hex_digit(0'0).
$hex_digit(0'1).
$hex_digit(0'2).
$hex_digit(0'3).
$hex_digit(0'4).
$hex_digit(0'6).
$hex_digit(0'7).
$hex_digit(0'8).
$hex_digit(0'9).
$hex_digit(0'A).
$hex_digit(0'B).
$hex_digit(0'C).
$hex_digit(0'D).
$hex_digit(0'E).
$hex_digit(0'F).
*/
$dumpops(Stream) :-
    forget(st(Atom, _, _), $local),		% do only operators here
	op(_, _, Atom),
	$lookupop(Atom, P, Type),
	$quoteit(Atom, Sym),
	$quoteit(Type, T),
	swrite(Stream, '    BNRP_embedOperator(', Sym, ', ', P, ', ', T, ');\n'),
	fail.
$dumpops(_).

$lookupop(S, P, R) :-
	op(P, T, S),
	cut, 
	op(P, U, S),
	T \= U,
	$typeop(S, R1),
	!,
	swrite(R, R1, T, ' ', U).
$lookupop(S, P, R) :-
	op(P, T, S),
	$typeop(S, R1),
	!,
	swrite(R, R1, T).

$typeop(Op, 'new ') :-
    recall(newop(Op,_,_), $local).
$typeop(Op, '').

$dumpclauses(Stream, ArrayName, DataName, Index, BeebleCount, LineSize) :-
	new_counter(0, X),
	forget(clause(Label, Arity, Hash, C), $local),
	$lookuphash2(Hash, H),
	$quoteit(Label, L),
	counter_value(X, Y),
	Z is ((Y + 49) mod 50) + 1,
	$tryheader(Stream, DataName, Index, Z, _, "", BeebleCount, LineSize),
	swrite(Stream, '    BNRP_embedClause(', L, ', ', Arity, ', ', H, ', &', ArrayName, '[', C, ']);\n'), 
	X,
	fail.
$dumpclauses(Stream, ArrayName, DataName, Index, BeebleCount, LineSize).

$tryheader(Stream, DataName, Index, X, 0, Msg, BeebleCount, LineSize) :-
	X >= 50,
	Index,
	$beeble$(BeebleCount, LineSize),
	counter_value(Index, I),
	swrite(Stream, '    };\n\nBNRP_embedContext_', DataName, '_', I, '()\n{', Msg, '\n'),
	!.
$tryheader(_, _, _, X, X, _, _, _).

$lookuphash1(X, X) :- numeric(X), !.
$lookuphash1(X, X) :- symbol(X), !.
$lookuphash1(X, X) :- var(X), !, fail.
$lookuphash1(X(Args..), X) :- $lookuphash1(X, X), !.

$lookuphash2(Hash, -1) :- numeric(Hash), !.
$lookuphash2(Hash, -1) :- symbol(Hash), !.
$lookuphash2(Hash, 0) :- var(Hash), !.
$lookuphash2(L, 2184) :- L @= [], !.
%% following added 95/04/07 JR otherwise [X..] doesn't match up with []
$lookuphash2([], 0) :- !.			
$lookuphash2([X..], 2730) :- !.
$lookuphash2(F(X..), H) :- $lookuphash2(F, H), !.
$lookuphash2(_, 0).

$dump_symbol_table($doclause_r, Stream, BeebleCount, LineSize) :-
	swrite(Stream, '0\n}};\n\n'),
	new_counter(0, C),
	$dumpneeds_r(Stream, C),
	$dumpclauses_r(Stream, C),
	$dumpops_r(Stream, C).

$dumpneeds_r(Stream, Index) :-
	forget(needs(SymbolRef, C), $local),
	!,
	Index,
	counter_value(Index, I),
	$dumpfilter_r(SymbolRef, Stream, I),
	swrite(Stream, '\t', C),
	foreach(forget(needs(SymbolRef, D), $local) do
			swrite(Stream, ',\n\t', D)),
	swrite(Stream, '\n}};\n\n'),
	!,
	$dumpneeds_r(Stream, Index).
$dumpneeds_r(_, _).

$dumpfilter_r(SymbolRef, Stream, _) :-
	integer(SymbolRef),
	!,
	swrite(Stream, 'resource \'INTG\' (', SymbolRef, ' OPTIONS) {{\n').
$dumpfilter_r(SymbolRef, Stream, Index) :-
	float(SymbolRef),
	!,
	swrite(Stream, 'resource \'FLOT\' (', Index, ', \"', SymbolRef, '\" OPTIONS) {{\n').
$dumpfilter_r(SymbolRef, Stream, Index) :-
	symbol(SymbolRef),
	!,
	$quoteit(SymbolRef, Sym),
	swrite(Stream, 'resource \'SMBL\' (', Index, ', ', Sym, ' OPTIONS) {{\n'),
	!.
$dumpfilter_r(SymbolRef, _, _) :-
	write('Unable to determine type of ', SymbolRef, '\n').

$dumpclauses_r(Stream, Index) :-
	forget(clause(Label, Arity, Hash, C), $local),
	!,
	$quoteit(Label, L),
	$lookuphash2(Hash, H),
	Index,
	counter_value(Index, I),
	swrite(Stream, 'resource \'CLAS\' (', I, ', ', L, ' OPTIONS) {{\n\t', C, ', ', Arity, ', ', H),
	foreach(forget(clause(Label, Arity1, Hash1, D), $local) do
			[$lookuphash2(Hash1, H1), swrite(Stream, ',\n\t', D, ', ', Arity1, ', ', H1)]),
	swrite(Stream, '\n}};\n'),
	!,
	$dumpclauses_r(Stream, Index).
$dumpclauses_r(_, _).

$dumpops_r(Stream, Index) :-
    forget(st(Atom, _, _), $local),		% do only operators here
	op(_, _, Atom),
	$lookupop(Atom, P, Type),
	$quoteit(Atom, Sym),
	$quoteit(Type, T),
	Index,
	counter_value(Index, I),
	swrite(Stream, 'resource \'OPER\' (', I, ', ', Sym, ' OPTIONS) {\n\t', P, ',\n\t', T, '\n};\n'),
	fail.
$dumpops_r(_, _).

