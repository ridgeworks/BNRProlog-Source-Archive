/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/check.p,v 1.3 1998/06/05 06:07:47 csavage Exp $
 *
 * $Log: check.p,v $
 * Revision 1.3  1998/06/05  06:07:47  csavage
 * Addition of a stripQuotes primitive to allow the toggling
 * of how quotes are handled when capsAsVars is false.  The
 * default is to remove quotes - this allows quotes to be kept
 * for check utility.
 *
 * Revision 1.2  1998/03/13  09:01:23  csavage
 * Removed pre-processing call in $process
 *
 * Revision 1.1  1998/03/10  08:59:29  csavage
 * Added Check utility
 *
 *
 *
 */
% Check
%	
%			version 1.0 Beta	
%
%	A Lint debugger for BNR Prolog versions 5.0.2 and above.
%
%		    Copyright (c) Nortel, 1989 - 98
%
% This program will not detect all anomalies in Prolog code.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These first predicates are high level predicates to control   %
% the flow of the program                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check can be invoked in one of two ways:
% 1> With no arguments, it will check the context stack *above* check
% 2> With arguments (the names of files to be checked) it will check these
% ***** Check *cannot* be called with arguments when there are contexts loaded 
%       above it ******


check(InFiles..) :-                                          %%% 
	$startrun,                                           % initalisation procedures
	predicate($this_is_where_check_is, Here),            % find name of THIS context
	findall(CName, context(CName), ContextList),         % get context stack - names only
	findall(LName, context(_,LName), ContextLocations),  % get context stack - /location/name
	nth_solution($lmember(CName, ContextList), CurNum),  % find number of THIS context
		CName = Here,                                 %   in stack
	findall(Context,                                     % locations of contexts above THIS one
		[nth_solution(
		 $lmember(Context, ContextLocations), Num),
		 Num < CurNum
		],
		AboveLocations),
 
        %%% 4 possable execution cases
	[AboveLocations = [], InFiles = []] ->            		% called with no args, and no contexts - error
		[
		 $log_string("*** No contexts above check \n",
		             "*** Cannot perform check without contexts ",
		             "or input arguments.\n\n"),
		 failexit(check)
		],
		
	[AboveLocations \= [], InFiles \= []] ->           		% called with args AND contexts - error
		[
		 $log_string("*** There exist contexts above check ***\n",
		            "*** Cannot perform check with contexts ",
		            "and input arguments.\n\n"),
		 failexit(check)
		],
		
	[AboveLocations \= [], InFiles = []] ->					% called with contexts.
		[
		 $rev(AboveLocations, TempList),             % reverse names to check in context order
		 [FirstLocation, _..] = TempList,
		 remember(abovelocations(TempList), $local),
		 fullfilename(First, FirstLocation),
		 exit_context(First); exit_context(FirstLocation),	                        %  exit all contexts above check
		 forget(abovelocations(TestingList), $local),
		 foreach($lmember(FLocation, TestingList) do
			[load_context(FLocation),
		 	 write("\nProcessing local predicates.\n"),
			 fullfilename(FName, FLocation),
		 	 findset(GlobalHead,                    % create list of $whatever(...), without $
		 	 [definition(PredHead :- _, FLocation),
		 	  put_term(String, PredHead, 0),
		 	  name(String, [36, Rest..]),
		 	  name(GlobalName, [Rest..]),
		 	  swrite(HeadName, GlobalName, ". "),
		 	  get_term(HeadName, GlobalHead, 0)
                         ],
		 	 HeadList),
		         remember(locals(FName, HeadList), $local),
		         findset(PredName,
		 	 	predicate(PredName, FLocation),        % create list of all predicates.
		 	 	NameList),
		 	 	$delete(op, NameList, ShortNList),
		 		remember(preds(FName, ShortNList), $local)
			]),
		!
		],
		
	[InFiles \= [], AboveList = []] ->					% called with list
	[
		defaultdir(DefDir),
		foreach($lmember(File, InFiles) do
			[
			 name(File, [47, _..]) ->
			 	FLocation = File;
			 	swrite(FLocation, DefDir, "/",File),
			 load_context(FLocation) ->
		 	 	[
		 	 	 write("\nProcessing local predicates.\n"),
		 	 	 fullfilename(FName, FLocation),
				 findset(GlobalHead,              % create list of $whatever(...), without $
		 	 	 [definition(PredHead :- _, FLocation),
		 	  	  put_term(String, PredHead, 0),
		 	  	  name(String, [36, Rest..]),
		 	  	  name(GlobalName, [Rest..]),
		 	  	  swrite(HeadName, GlobalName, ". "),
		 	  	  get_term(HeadName, GlobalHead, 0)
                         	 ],
		 	 	 HeadList),
		         	 remember(locals(FName, HeadList), $local),
		         	 findset(PredName,
		 	 	 	predicate(PredName, FLocation),        % create list of all predicates.
		 	 	 	NameList),
		 	 	 $delete(op, NameList, ShortNList),
		 		 remember(preds(FName, ShortNList), $local)
				];
	     		 	$log_string("*** File \"", File,
		        		    "\" not checked - could not be loaded. ***\n\n")
			]),
		findall(Cname, context(Cname), Contextlist),         % get context stack - names only
		findall(Lname, context(_,Lname), Contextlocations),  % get context stack - /location/name
		nth_solution($lmember(Cname, Contextlist), Curnum),  % find number of THIS context
			Cname = Here,                                %   in stack
		findall(Contexts,                                     % locations of contexts above THIS one
			[nth_solution(
		 	 $lmember(Contexts, Contextlocations), Num),
		 	 Num < Curnum
			],
			Abovelocations),
		$rev(Abovelocations, TestingList),             % reverse names to check in context order
	!
	],
	foreach($lmember(CheckThis, TestingList) do
		[swrite(OFileName, CheckThis, ".report"),
		 $setup(CheckThis, OFileName),
		 fullfilename(CheckMe, CheckThis),
		 $doit(CheckMe, CheckThis, OFileName),
		 $cleanup]),
	
	foreach($lmember(File, InFiles) do
		[name(File, [47, _..]) ->
		 FLocation = File;
		 swrite(FLocation, DefDir, "/",File),
		 exit_context(FLocation)
		]),

	$endrun(TestingList).
		
$doit(FileName, FileLocation, OFileName) :-
	remember(warn(0), $local),                   % reset warning counters
	remember(strong(0), $local),
	remember(checked(0), $local),
	$tailops(save),
	$process(FileName, FileLocation) ->          % enter checking loop
		$report(success, FileName);
		$report(fatal, FileName),
	forget(pstream(PStream), $local),
	close(PStream, _),
	capitalsAsVariables(true),
	underscoreAsVariable(true),
	stripQuotes(false).

$process(Context, FileLocation) :-
	recall(sum_stream(SS), $local),

%	write("Pre-processing file \"", 
%	       Context, "\"...\n"),
%	$preprocess(Context, PStream),

% Replace following 3 lines with above 3 for pre-processing.

	open(PStream, FileLocation, read_only, 0),
	remember(pstream(PStream), $local),
	seek(PStream, 0),
	
	write("\nAnalysing context \"", 
	       Context, "\"...\n"),
	swrite(SS, "Analysing context \"", 
	       Context, "\"...\n"),	
	capitalsAsVariables(false),                  % allows variable name preservation
	underscoreAsVariable(false),
	stripQuotes(false),
	repeat,
		$tailops(true),
		at(PStream, Pos),
		get_term(PStream, Term, 0) ->
		[forget_all(variable(_..), $local),
		 $gotClause,
		 $cat_clause(Context, Term, PredName, PredNum),                     % finds and catalogues variables
		 $tailops(false),
		 nth_solution(                                                      % matches text clause with 
		 	definition(PredName(Args..) :- Body, Context), PredNum) ->  %   .. the PredNum'th clause in knowledge base
		 	true;	% fails for local pred.s if other contexts above
		 	[capitalsAsVariables(true), underscoreAsVariable(true),	 stripQuotes(false),   % retrieves locals from file
		 	 seek(PStream, Pos),
		 	 get_term(PStream, UTerm, 0),	%temp only
		 	 [[PredName(Args..) :- Body] = [UTerm]];
		 	 [[PredName :- Body] = [UTerm]];
		 	 [[PredName(Args..)] = [UTerm], Body = []],
		 	 capitalsAsVariables(false), underscoreAsVariable(false), stripQuotes(false)
		 	],
		 $check_clause(Context, PredNum, PredName(Args..), Body),           % checks head and goal sequence * debugger *
		 fail]; % scope limiting for variables found by $cat_clause
		 !,
	write("Finished checking context \"", 
	      Context, "\".\n"),
	swrite(SS, "Finished checking context \"", 
	       Context, "\"."),
	!.
	
/*
%% This process for implementation if $get_term implemented..

$process(Context) :-
	recall(sum_stream(SS), $local),
	write("\nAnalysing context \"", 
	       Context, "\"...\n"),
	swrite(SS, "Analysing context \"", 
	       Context, "\"...\n"),	
	repeat,
		at(PStream, Pos),
		$get_term(PStream, Term, 0) ->
		[forget_all(variable(_..), $local),
		 $gotClause,
		 $cat_clause(Context, Term, PredName, PredNum), % finds and catalogues variables
*/ /*		 nth_solution(                                                    % matches text clause with 
		 	definition(PredName(Args..) :- Body, Context), PredNum) ->  %   .. the PredNum'th clause in knowledge base
		 	true;
		 	[capitalsAsVariables(true), underscoreAsVariable(true), stripQuotes(false),
		 	 seek(PStream, Pos),
		 	 get_term(PStream, UTerm, 0),	%temp only
		 	 [[PredName(Args..) :- Body] = [UTerm]];
		 	 [[PredName :- Body] = [UTerm]];
		 	 [[PredName(Args..)] = [UTerm], Body = []],
		 	 capitalsAsVariables(false), underscoreAsVariable(false), stripQuotes(false)
		 	],
*/ /*		 $check_clause(Context, PredNum, PredName(Args..), Body),  % checks head and goal sequence * debugger *
		 fail]; % scope limiting for variables found by $cat_clause
		 !,
	write("Finished checking context \"", 
	      Context, "\".\n"),
	swrite(SS, "Finished checking context \"", 
	       Context, "\"."),
	!.

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following predicates are initialisation and termination    %
%   routines for each run of the lint.                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$startrun :-                                     %%% performs initalisation
	new_state(0, $local),
	remember(warnTot(0), $local),            % reset all totals to zero
	remember(strongTot(0), $local),
	remember(checkTot(0), $local),
	remember(fatalTot(0), $local),
	open(SS, "summary.log", read_write, 0),  % open log file
	remember(sum_stream(SS), $local),        % store stream pointer
	write("\n*** BNRP Check ***\n\n").

$endrun(CheckList) :-
	remember(warn(0), $local),
	remember(strong(0), $local),
	remember(checked(0), $local),
	repeat,
		forget(preds(Context, NewPredList), $local) ->
		[foreach($lmember(Unused, NewPredList) do
			$warning(["Found no explicit calls to predicate \"",
				 Unused, "\" defined in context \"",
				 Context, "\"."])),
		 fail];
		!,
	forget(warn(WarnNum), $local),
	forget(warnTot(OldWarnTot), $local),
	WarnTot is (WarnNum + OldWarnTot),
	forget(strong(StrongNum), $local),
	forget(strongTot(OldStrongTot), $local),
	StrongTot is (StrongNum + OldStrongTot),
	forget(checked(CheckNum), $local),
	forget(checkTot(OldCheckTot), $local),
	CheckTot is (CheckNum + OldCheckTot),
	forget(fatalTot(FatalTot), $local),
	forget(sum_stream(SS), $local),
	swrite(Result,
	       "\n-------------------------------------------\n",
	       "  Summary Of Results : \n",
	       "===========================================\n",
	       "Files Checked: ", CheckList, "\n",
	        CheckTot, " clauses checked.\n",
	        WarnTot, " warnings detected (total).\n",
	        StrongTot, " strong warnings detected.\n",
	        FatalTot, " fatal errors detected.\n",
	       "-------------------------------------------\n"),
	write(Result, "\n"),
	swrite(SS, Result),
	set_end_of_file(SS),
	close(SS, _).
	
$setup(In, Out) :-                                   %%% prepare environment, check input data
	not(once(readfile(In, _))) ->
		[write("\n*** File \"", In, 
		       "\" could not be found or ",
		       "contains no terms.",
		       " No checks performed. ***\n"),
		 recall(sum_stream(SS), $local),
		 swrite(SS, "\n*** File \"", In, 
		        "\" contains no terms.",
		        " No checks performed. ***\n"),
		 fail],
	open(OutStream, Out, read_write, 0),
	seek(OutStream, 0),		             % goto head of output file
	remember(out_stream(OutStream), $local),
	write("\ninput file  : ", In, 
	      "\noutput file : ", Out, "\n\n").
	
$cleanup :-                                  %%% remove assertions and open files.
	forget(out_stream(_X), $local),      % get name of output stream
	set_end_of_file(_X),                 % add EOF
	close(_X, _),                        % close it
	capitalsAsVariables(true),           % reset prolog environment to default
	underscoreAsVariable(true),
	stripQuotes(false),
	forget_all(locals(_..), $local),
	forget_all(last_pred(_,_), $local),
	forget_all(pnum(_,_,_), $local).
%	forget_all(variable(_,_,_), $local).

$report(Status, Context) :-
	forget(warn(WarnNum), $local),
	forget(warnTot(OldWarnTot), $local),
	WarnTot is (WarnNum + OldWarnTot),
	remember(warnTot(WarnTot), $local),
	forget(strong(StrongNum), $local),
	forget(strongTot(OldStrongTot), $local),
	StrongTot is (StrongNum + OldStrongTot),
	remember(strongTot(StrongTot), $local),
	forget(checked(CheckNum), $local),
	forget(checkTot(OldCheckTot), $local),
	CheckTot is (CheckNum + OldCheckTot),
	remember(checkTot(CheckTot), $local),
	recall(sum_stream(SS), $local),
	recall(out_stream(OS), $local),
	stream(OS, OFileName, _),
	swrite(Result1,
	       "\n-------------------------------------------\n",
	       "  Results for \"", Context, "\" : \n",
	       "===========================================\n",
	        CheckNum, " clauses checked.\n",
	        WarnNum, " warnings detected (total).\n",
	        StrongNum, " strong warnings detected.\n"),
	write(Result1),
	swrite(SS, Result1),
	swrite(OS, Result1),
	Status = success ->
		[write("0 fatal errors encountered.\n"),
		 swrite(OS, "0 fatal errors encountered.\n")];
		[write("*** Fatal error detected, processing  of context \"",
		       Context, "\" halted. ***\n"),
		 swrite(OS, "*** Fatal error detected, processing of context \"",
		        Context, "\" halted. ***\n"),
		 swrite(SS, "*** Fatal error detected, processing of context \"",
		        Context, "\" halted. ***\n")],
	write("See output file \"", OFileName, "\" for details.\n",
	           "-------------------------------------------\n\n"),
	swrite(SS, "-------------------------------------------\n\n"),
	swrite(OS, "-------------------------------------------\n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following predicates are for             %
%   cataloging the variables in each clause    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$cat_clause(Context, Functor(Args..) :- Body, Functor, PredNum) :-   %%% finds and catalogues variables
	!,                                                           %   different handling for different clause formats
	$prednum(Context, Functor, PredNum),                         % num times this pred has occurred (so far)
	$decompose(Functor(Args..), 0, HeadVars),                    % reduces head to atoms and stores variables
	$decompose(Body, HeadVars, _).                               % reduces body to atoms and stores variables

$cat_clause(Context, Head :- Body, Head, PredNum) :-                 %%% finds and catalogues variables
	!,                                                           %   different handling for different clause formats
	$cat_clause(Context, Head() :- Body, Head, PredNum).

$cat_clause(Context, Functor(_..), Functor, PredNum) :-              %%% finds and catalogues variables
	!,                                                           %   different handling for different clause formats
	$prednum(Context, Functor, PredNum).
	
$cat_clause(Context, Head, Head, PredNum) :-                         %%% finds and catalogues variables
	!,                                                           %   different handling for different clause formats
	$prednum(Context, Head, PredNum).

%%% decompose reduces term to atoms and stores variables with index of their occurance.

$decompose([], NumVars, NumVars) :- !.
	
$decompose([Term, Rest..], NumVars, NewNumVars) :-
	!,
	$decompose(Term, NumVars, TempVars),
	$decompose([Rest..], TempVars, NewNumVars).

$decompose(".."(ShortName), NumVars, NewNumVars) :-
	!,
	swrite(RealName, ShortName, ".."),
	$cat_atom(RealName, NumVars, NewNumVars).

$decompose("|"(Before, ShortName), NumVars, NewNumVars) :-
	!,
	$decompose(Before, NumVars, TempVars),
	swrite(RealName, ShortName, ".."),
	$cat_atom(RealName, TempVars, NewNumVars).

$decompose(Functor(Args..), NumVars, NewNumVars) :-
	!,
	$cat_atom(Functor, NumVars, TempVars),
	$decompose([Args..], TempVars, NewNumVars).

$decompose(Atom, NumVars, NewNumVars) :-
	!,
	$cat_atom(Atom, NumVars, NewNumVars).
	
%%% cat_atom performs the cataloging of the variable just found by decompose

$cat_atom("_", NumVars, NewNumVars) :-                              %%% annon variable
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable("_", NewNumVars, anon), $local).         % store

$cat_atom("_..", NumVars, NewNumVars) :-                            %%% annon tail variable
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable("_..", NewNumVars, tail), $local).       % store 

$cat_atom(Atom, NumVars, NewNumVars) :-                             %%% check for non-annon tail var..
	recall(variable(Atom, _, tail), $local) ->                  % if already decided this is tail var
	[!,
	 successor(NumVars, NewNumVars),                            %   index + 1
	 rememberz(variable(Atom, NewNumVars, tail), $local)];      %   store
	[name(Atom, CharList),                                      % else check for ".."
	 $last(Last, CharList),                                     %   gets last element in list
	 Last = 46,                                                 %   id by trailing dot
	 !,
	 successor(NumVars, NewNumVars),                            %   index + 1
	 rememberz(variable(Atom, NewNumVars, tail), $local),       %   store
	 $delete(46, CharList, ShortList),                          %   remove dots (..)
	 name(ShortName, ShortList),                                %   generate var name without trailing ".."
	 foreach(forget(variable(ShortName, OthNum, _), $local) do  %   look to see if shortname already classified
		 rememberz(variable(Atom, OthNum, tail), $local))]. %   change to type tail-var

$cat_atom(Atom, NumVars, NewNumVars) :-                             %%% check for this being shortname of already classified tail
	swrite(LongName, Atom, ".."),                               % add ".."
	recall(variable(LongName, _, tail), $local),                % does tail of this name already exist?
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable(LongName, NewNumVars, tail), $local).    % store

$cat_atom(Atom, NumVars, NewNumVars) :-                             %%% check for this var already being multi
	recall(variable(Atom, _, multi), $local),                    
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable(Atom, NewNumVars, multi), $local).       % store

$cat_atom(Atom, NumVars, NewNumVars) :-                             %%% check if var already exists as single
	forget(variable(Atom, OthNum, single), $local),
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable(Atom, OthNum, multi), $local),           % change previous occurance to type milti
	rememberz(variable(Atom, NewNumVars, multi), $local).       % store this as type multi


$cat_atom(Atom, NumVars, NewNumVars) :-                             %%% first ocurance of atom, check for var
	name(Atom, [First, Rest..]),
	First = 95 ; [First >= 65, First =< 90],                    % starts with underscore or upper-case
	!,
	successor(NumVars, NewNumVars),                             % index + 1
	rememberz(variable(Atom, NewNumVars, single), $local).      % store it with type single

$cat_atom(Atom, NumVars, NumVars) :- !.                             %%% default case - not a variable

$gotClause :-	%updates count of clauses checked
	forget(checked(OldVal), $local) ->
		successor(OldVal, NewVal);
		NewVal = 1,
	remember(checked(NewVal), $local),
	!.
	
$tailops(save) :-
	repeat,
		retract(op(Precedence, Associativity, "..")) ->
		remember(op(Precedence, Associativity, ".."), $local);
		!,
	repeat,
		retract(op(Precedence, Associativity, "|")) ->
		remember(op(Precedence, Associativity, "|"), $local);
		!.

$tailops(true) :-
	retractall(op(_, _, "|")),
	retractall(op(_, _, "..")),
	assert(op(600, xf, "..")),	             
	assert(op(600, xfx, "|")),
	!.

$tailops(false) :-
	retract(op(600, xf, "..")),
	retract(op(600, xfx, "|")),
	repeat,
		recall(op(Precedence, Associativity, ".."), $local) ->
		assert(op(Precedence, Associativity, ".."));
		!,
	repeat,
		recall(op(Precedence, Associativity, "|"), $local) ->
		assert(op(Precedence, Associativity, "|"));
		!.

$tailops(none) :-	% don't think should be called
	retractall(op(_, _, "|")),
	retractall(op(_, _, "..")),
	!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following predicates are actually perform the                %
%   lint checking of each clause, after the environment has been   %
%   properly set up by the predicates above                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$check_clause(Context, PredOcc, op, Body) :-                              %%% null op definition
	$warning(["op fact with no arguments detected in context \"",
	         Context, "\"."]),
	!.

$check_clause(Context, PredOcc, op(), Body) :-                            %%% empty op definition
	$warning(["op fact with empty arguments detected in context \"",
	         Context, "\"."]),
	!.

$check_clause(Context, PredOcc, op(Precedence, Mechanism, Name), []) :-   %%% cvalid op definition
	integer(Precedence),
	Precedence >= 0,
	Precedence =< 1200,
	symbol(Name),
	symbol(Mechanism),
	$lmember(Mechanism, [xf, yf, xfx, yfx, xfy, fx, fy]), 
	!.                                                                % no further checks if successful to this point.

$check_clause(Context, PredOcc, op(One, Two, Three), Body) :-             %%% op/3 failed a check above
	$fatalError(["op/3 declaration \"", op(One, Two, Three),
	            "\" in Context \"", Context, 
	            "\" is invalid."]),
	!.

$check_clause(Context, PredOcc, op(Args..), Body) :-                      %%% op/n invalid for n \= 3
	$warning(["op declaration \"", op(Args..),
	         "\" in context \"", Context, "\" is not of arity 3."]),
	!.

$check_clause(Context, PredOcc, Head, Body) :-                            %%% checking on all non-op clauses
	[PredName(_..) = Head; PredName() = Head; PredName = Head],       % determine predicate name
	!,
	[nth_solution(definition(PredName(Args..) :- OthBody, Context), OthOcc),
	OthOcc > PredOcc,
	PredName(Args..) = Head,
	OthBody = Body] ->
	[$strong_warning(["Clauses ", PredOcc, " and ", OthOcc,
			" of predicate \"", PredName, "\" in context \"",
			Context, "\" unify (may be duplicates)."])],
	$check_head(Head, PredName, NumVars),
	$check_body(Head, Body, [Context, PredName, PredOcc], NumVars), !.

$check_clause(Context, PredOcc, Head, Body) :-                            %%% generic failure condition - all checks failed
	$fatalError(["could not check clause defined as \"",
	            Head, " :-\n", Body, ".\" in context \"",
	            Context, "\"."]),
	!.

$check_head(Head, PredName, NumVars) :-                                   %%% checks for head unification with base functor/head and counts variables
	$count_vars(NumVars, Head),                                       % need for correct indexing of body variables
	definition(Head :- _, "base") ->
		$strong_warning(["Clause head \"", Head,                  % if head (name + args) unifies
		                "\" conflicts with base ", 
		                "clause head of same name."]);
		[predicate(PredName, "base") ->
			$warning(["Functor name \"", PredName,            % if head (name only) unifies
			         "\" conflicts with base ",
			         "functor of same name."])].

$check_body(Head, Body, [Context, PredName, PredOcc], NumVars) :-         %%% warns for each single, non-anon var in body
	!,
	$done_head(HeadStr, Head); swrite(HeadStr, Head, " :-"),
	$check_goal(Body, [Context, PredName, PredOcc], NumVars, _, HeadStr, _, Body).   % then checks goal sequence

$check_goal(Goal, Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-            %%% a single variable goal
	var(Goal) ; symbol(Goal),
	!,
	$check_goal(Goal(), Info, NumVars, NewNumVars, Done, NewDone, ToDo).    % adds () and re-calls 

$check_goal([Goal, Rest..], Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-  %%% if Goal is a goal sequence
	!,
	$count_vars(ExtraVars, Goal),
	OthNumVars is (ExtraVars + NumVars),
	$make_u_str(RestStr, Rest, OthNumVars); swrite(RestStr, Rest),
	$check_goal(Goal, Info, NumVars, CurVars, Done, CurDone, RestStr),
	$check_goal(Rest, Info, CurVars, NewNumVars, CurDone, NewDone, "").

$check_goal(Goal, Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-            %%% Catches variable goals of form Var(_..)
	Goal = Functor(Args..),
	var(Functor),
	!,
	Info = [Context, PredName, PredOcc],
	$done_goal(NewDone, Done, Goal, NumVars); swrite(NewDone, Done, "\n\t", Goal, ", "),	   
	$checkSingles(Goal, Info, NumVars, NewDone, ToDo),
	ClauseOcc is (NumVars + 1),
	recall(variable(Name, ClauseOcc, Type), $local),                        % split depending on type of variable
	Type = single ->                                                        % a call of this type could never succeed
		$fatalError(["Singular named variable \"",
		            Name, "\" used as functor ",
		            "in occurence ", PredOcc,
		            " of predicate \"", PredName, 
		            "\" in context \"", Context, 
		            "\""], [NewDone], [ToDo]),
	Type = anon ->                                         %%% a call of this type could never succeed 
		$fatalError(["Anonymous variable used as ",
		            "functor in occurence ", PredOcc,
		            " of predicate \"", PredName,
			    "\" in context \"", Context, 
			    "\""], [NewDone], [ToDo]),
	Type = tail ->                                         %%% a call of this type could never succeed 
		$fatalError(["Tail variable \"", Name,
		            "\" used as functor in ",
		            "occurence ", PredOcc,
		            " of predicate \"", PredName, 
		            "\" in context \"", Context, 
		            "\""], [NewDone], [ToDo]),
	Type = multi ->                                        %%% usually intentional, but uncheckable without executing
		$warning(["Cannot check: variable \"", Name,  
			 "\" used as functor in occurrence ", 
			 PredOcc, " of predicate \"", PredName, 
			 "\" in context \"", Context, "\""], [NewDone], [ToDo]),
			 
	$count_vars(ExtraVars, Goal),
	NewNumVars is (ExtraVars + NumVars).

$check_goal(Goal, Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-             %%% checks for meta-predicates (defined by $pattern below...)
	$pattern(Goal, NewGoal, ExtraVars),
	!,
	CurVars is (NumVars + ExtraVars),
	$check_goal(NewGoal, Info, CurVars, NewNumVars, Done, NewDone, ToDo).

$check_goal(Goal, Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-             %%% Checks for executable (checkable) calls
	Goal = Functor(Args..),
	ground(Functor),
	name(Functor, [36, Rest..]),
	name(GlobEquiv, [Rest..]),
	!,
	Info = [Context, PredName, PredOcc],
	$done_goal(NewDone, Done, Goal, NumVars); swrite(NewDone, Done, "\n\t", Goal, ", "),
	$checkSingles(Goal, Info, NumVars, NewDone, ToDo),
	recall(preds(Context, PredList), $local),
	forget_all(preds(Context, _), $local),
	$sdelete(Functor, PredList, NewList),
	remember(preds(Context, NewList), $local),
	recall(locals(Context, LocalList), $local),
	$make_u_str(GoalStr, Goal, NumVars); swrite(GoalStr, Goal),
	$lmember(GlobEquiv(_..), LocalList) ->
	[
		$lmember(GlobEquiv(Args..), LocalList) ->
			true;
			$strong_warning(["Goal \"", GoalStr,  % otherwise, probably an error
			"\" in occurence ", PredOcc,
			" of predicate \"", PredName,
			"\" in context \"", Context,
			"\" unifies with functor but not parameters."], 
			[NewDone], [ToDo]);
	];
	$warning(["Goal \"", GoalStr,                         % if not calling a predicate known to lint
		 "\" in occurence ", PredOcc,
		 " of predicate \"", PredName,
		 "\" in context \"", Context,
		 "\" will not match any known clause."], 
		 [NewDone], [ToDo]),
	$count_vars(ExtraVars, Goal),
	NewNumVars is (ExtraVars + NumVars).

$check_goal(Goal, Info, NumVars, NewNumVars, Done, NewDone, ToDo) :-             %%% Checks for executable (checkable) calls
	Goal = Functor(Args..),
	ground(Functor),                                    % ie. non variable
	!,
	Info = [Context, PredName, PredOcc],                % facts about where we are in file
	$done_goal(NewDone, Done, Goal, NumVars)
		; swrite(NewDone, Done, "\n\t", Goal, ", "),
	$checkSingles(Goal, Info, NumVars, NewDone, ToDo),
	foreach(forget(preds(PredC, PredList), $local) do
		[$sdelete(Functor, PredList, NewPList),
		remember(preds(PredC, NewPList), $local)]
		),
	$make_u_str(GoalStr, Goal, NumVars); swrite(GoalStr, Goal),
	[predicate(Functor, PredC) ->                       % **test to see if checking for local names works
		[
		clause_head(Functor(Args..)) ->      
			fail;                               % found a match - drop out of further (->) checking
			[primitive(Functor) ->       
				fail;                       % found a match but primitive arguments won't unify drop out, not error
			 	$strong_warning(["Goal \"", GoalStr,  % otherwise, probably an error
			        		"\" in occurence ", PredOcc,
			        		" of predicate \"", PredName,
			        		"\" in context \"", Context,
						"\" unifies with functors but not clauses."], [NewDone], [ToDo]),!
			]
		];
		[
		$warning(["Goal \"", GoalStr,                   % if not calling a predicate known to lint
			 "\" in occurence ", PredOcc,
			 " of predicate \"", PredName,
			 "\" in context \"", Context,
			 "\" will not match any known clause."], [NewDone], [ToDo]),
		!]
	]; true,
	$count_vars(ExtraVars, Goal),
	NewNumVars is (ExtraVars + NumVars).


$check_goal([], _, NumVars, NumVars, Done, Done, _) :- !.                 %%% end condition - no more goals to check

$pattern(foreach(P do G), [P, G], 0).                      %%% meta-predicate handling ...
$pattern(P ; G, [P, G], 0).
$pattern(P -> G, [P, G], 0).
$pattern(not(P), [P], 0).
$pattern({P}, [P], 0).
$pattern(with_context(ExtraBit,B),[B], ExtraVars) :-
	$count_vars(ExtraVars, ExtraBit).
$pattern(once([P]),[P], 0).
$pattern(once(P), [P], 0).
$pattern(findall(ExtraBit1,P,ExtraBit2),[P, holdforcount(ExtraBit2)], ExtraVars) :-
	$count_vars(ExtraVars, ExtraBit1).
$pattern(findset(ExtraBit1,P,ExtraBit2),[P, holdforcount(ExtraBit2)], ExtraVars) :-
	$count_vars(ExtraVars, ExtraBit1).

holdforcount(_..).                                                %%% for keeping variable counts right

$checkSingles(Goal, Info, NumVars, Done, ToDo) :-
	Info = [Context, PredName, PredOcc],
	variables(Goal, NormList, TailList),
	termlength(NormList, NormNum, _),
	termlength(TailList, TailNum, _),
	NumTo is (NumVars + NormNum + TailNum),
	foreach([recall(variable(Name, NNV, single), $local),       
		NNV >= NumVars,
		NNV =< NumTo]
	do
		$warning(["single occurrence of variable \"", 
		         Name, "\" in occurrence ", PredOcc, 
		         " of predicate \"", PredName, 
		         "\" in context \"", Context, "\"."],[Done],[ToDo])
	        ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following predicates are for handling any warnings  %
% or errors generated whilst checking the context         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$fatalError(_..) :-
	forget(fatalTot(Prev), $local),
	successor(Prev, Curr),
	remember(fatalTot(Curr), $local),
	fail.  % updates total, then allows relevant $fatalerror to be called

$fatalError([Message..]) :-
	$make_message(Output, Message),
	$log_string("*** FATAL ERROR *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** FATAL ERROR *** ", Output, "\n"),
	failexit($process).

$fatalError([Message..], [Before..], [After..]) :-
	recall(out_stream(OS), $local),
	$make_message(Output, Message),
	$make_message(BefMess, Before),
	$make_message(AftMess, After),
	$log_string("*** FATAL ERROR *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** FATAL ERROR *** ", Output, ":\n",
		       BefMess, "<<== HERE !!\n\t", AftMess, "\n\n"),
	failexit($process).

$strong_warning(_..) :-
	forget(strong(Prev), $local),
	successor(Prev, Curr),
	remember(strong(Curr), $local),
	forget(warn(WPrev), $local),
	successor(WPrev, WCurr),
	remember(warn(WCurr), $local),
	fail.

$strong_warning([Message..]) :-
	$make_message(Output, Message),
	$log_string("*** STRONG WARNING *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** STRONG WARNING *** ", Output, "\n\n").

$strong_warning([Message..], [Before..], [After..]) :-
	$make_message(Output, Message),
	$make_message(BefMess, Before),
	$make_message(AftMess, After),
	$log_string("*** STRONG WARNING *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** STRONG WARNING *** ", Output, ":\n",
		       BefMess, "<<== HERE !!\n\t", AftMess, "\n\n").

$warning(_..) :-
	forget(warn(Prev), $local),
	successor(Prev, Curr),
	remember(warn(Curr), $local),
	fail.

$warning([Message..]) :-
	$make_message(Output, Message),
	$log_string("*** WARNING *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** WARNING *** ", Output, "\n\n").

$warning([Message..], [Before..], [After..]) :-
	$make_message(Output, Message),
	$make_message(BefMess, Before),
	$make_message(AftMess, After),
	$log_string("*** WARNING *** ", Output, "\n"),
	recall(out_stream(OS), $local) ->
		swrite(OS, "*** WARNING *** ", Output, ":\n",
		       BefMess, "<<== HERE !!\n\t", AftMess, "\n\n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following predicates are utility predicates, used in   %
% various places for simple and/or repetitive needs          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


$this_is_where_check_is :- !.

$log_string(Args..) :-
	$make_message(String, Args),
	recall(sum_stream(SS), $local),
	write(String),
	swrite(SS,String).

%%% this predicate generates sequential numbers by which
%   different clauses of the same predicate can be identified

$prednum(Context, PredName, PredOcc) :-  %have seen this pred in this context?
	forget(pnum(Context, PredName, LastNum), $local),
	!,
	successor(LastNum, PredOcc),
	remember(pnum(Context, PredName, PredOcc), $local),
	recall(last_pred(Context, LastName), $local),
	LastName \= PredName ->		% means last predicate encountered for first time was not this one
	[recall(split(Context, PredName), $local) ->
		true;
		[$warning(["Split definition of predicate \"",
			   PredName, "\" in context \"",
			   Context, "\"."]),
		 remember(split(Context, PredName), $local)]].

$prednum(Context, PredName, PredOcc) :- %have seen this context??
	recall(pnum(Context, _..), $local),
	!,
	PredOcc = 1,
	remember(pnum(Context, PredName, PredOcc), $local),
	forget_all(last_pred(_..), $local),
	remember(last_pred(Context, PredName), $local).

$prednum(Context, PredName, PredOcc) :- %first pred of context - forget last context's totals
	forget_all(pnum(_..), $local),
	forget_all(last_pred(_..), $local),
	forget_all(split(_..), $local),
	!,
	PredOcc = 1,
	remember(pnum(Context, PredName, PredOcc), $local),
	remember(last_pred(Context, PredName), $local).


%%% $count_vars simply reports the number of variables in a term passed to it

$count_vars(NumVars, Term) :-
	variables(Term, VarList, TailVarList),
	termlength(VarList, NumNTVars, _),
	termlength(TailVarList, NumTVars, _),
	NumVars is (NumNTVars + NumTVars).

$lmember(X, [X|Xs]).
$lmember(X, [Y|Ys]) :-
	$lmember(X, Ys).
	
$make_message("", []) :- !.
$make_message(Output, [Next, Rest..]) :-
	$make_message(NextOutput, [Rest..]),
	swrite(Output, Next, NextOutput).

$last(X, [X]).
$last(X, [_ | Y]) :- $last(X, Y).

$delete(_, [], []).
$delete(X, [X | L], M) :- 
	!, 
	$delete(X, L, M).
$delete(X, [Y | L1], [Y | L2]) :- $delete(X, L1, L2).                                           

$sdelete(_, [], []).
$sdelete(X, [XName | L], M) :- % local symbols with same string rep.s don't always unify
	name(XName, XNums),
	name(X, XNums),
	!,
	$sdelete(X, L, M).
$sdelete(X, [Y | L1], [Y | L2]) :- $sdelete(X, L1, L2).                                           

$rev(L1, L2) :- $revzap(L1, [], L2).
$revzap([X | L], L2, L3) :- $revzap(L, [X | L2], L3). 
$revzap([], L, L).

$determinelinesize(LineWidth) :-	% lifted out of base code
    stream(1, _, _, FFname),                        % IF Stream 1 is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, textwidth('.', W0)),            %   AND we can get the size of a .
	W0 > 0,                                         %   AND it's a valid size
    sizewindow(Window, Width, _),                   %   AND we can get window width
    mbarheight(Menu),                               %   AND we get an approx scroll bar width
	!,                                              % THEN
    LineWidth is ((Width - Menu) // W0) - 1.

$determinelinesize(COLUMNS) :-
	getenv("COLUMNS", ENVCOLUMNS),
	concat(ENVCOLUMNS, ". ", S),
	sread(S, COLUMNS),
	integer(COLUMNS),
	COLUMNS is COLUMNS - 1,
	COLUMNS > 0,
	!.
	
$determinelinesize(79).

normal :-
	capitalsAsVariables(true),
	underscoreAsVariable(true),
	stripQuotes(true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The following predicates are used for preprocessing the file, so %%%%
%%%% that variable cataloging does not grab things it shouldn't       %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$preprocess(FileName, PipeStream) :-
	open(TempStream, FileName, read_only, 0),
	open(PipeStream, checkTemp, read_write, 0),
	remember(pstream(PipeStream), $local),
	$transfer(TempStream, PipeStream),
	set_end_of_file(PipeStream),	%	These two only for file
	seek(PipeStream, 0),		%	Not for pipe
	close(TempStream, _).


$transfer(Stream, NewStream) :-
	new_counter(0, Counter),
	$determinelinesize(LineSize),
	repeat,
		Counter,
		counter_value(Counter, Value),
		0 is (Value mod 100) -> write("@"),
		0 is (Value mod (LineSize * 100)) -> nl,
		get_char(Stream, Char) ->
		[Char = "/" -> 
		 	[get_char(Stream, X),		% have '/', get next char
			 X = '*' -> 			% is next char '*' (making '/' then '*')
		 		$commentC(Stream);
		 		[put_char(NewStream, '/'), 	% if not, write '/' to output file 
		  		 at(Stream, Posi),		% get current position in file
		  		 successor(BackOne, Posi),	% calculate last position
		  		 seek(Stream, BackOne)],	% go back to last position
		 	];
		 Char = "%" -> $commentL(Stream);
		 [[Char = "\'" ; Char = "\""] ->
		 	at(Stream, Posi),
		 	successor(BackOne, Posi),
		 	successor(BackTwo, BackOne),
		 	seek(Stream, BackTwo),
		 	get_char(Stream, X),
		 	seek(Stream, Posi),
		 	name(X, [ASCII]),
		 	[[ASCII >= 48, ASCII =< 57];[X = "\'"]] ->
		 		true;
		 	$gobbleStr(Stream , NewStream, Char)];
		 put_char(NewStream, Char),
		 fail] ; !.

$commentC(Stream) :-		% in a C-style comment, read until '*' then '/'
	repeat,				% do the following actions until true
		get_char(Stream, C) -> 	%   read next char
	  	$commentC_x(Stream, C), %   call aux. function
	  	!,			% if so, discard comment
	fail.				% prevent original '/' from being output

$commentC_x(Stream, '*') :-			% look for end of comment
	get_char(Stream, Next),		% get the next char
	Next = '/'.			% if '/' -> end of 

$commentC_x(Stream, '/') :-			% look for nested comment
	get_char(Stream, X),			% have '/', get next char
	X = '*',			% is next char '*' (making '/' then '*')
	$commentC(Stream), 			% if so, discard nested comment
	fail.				% because not at end of 'parent' comment

$commentC_x(Stream, C) :- fail.			% else, continue processing comment

$commentL(Stream) :-
	repeat,
		get_char(Stream, C),
		name(C, [N]),
		[N < 31, N \= 9] -> !,
		fail.

$gobbleStr(Stream, NewStream, T) :- 			%%% in quoted string, read to MATCHING quote.
	repeat,				                % perform below until true.
		get_char(Stream, C) -> 		        %   get next character
	  	$gobbleStr_x(Stream, C, T),
		!,
	put_char(NewStream, T).
	

$gobbleStr_x(Stream, '\\', T) :-			%%% next character is formatted txt
	get_char(Stream, _),			        % ignore next char (formatted txt)
	fail.				                % continue 

$gobbleStr_x(Stream, C, C).	                        %%% write closing quote to file, exit true

$gobbleStr_x(Stream, C, T) :- fail.		        %%% continue repeat.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  The following predicates are for making strings out of terms, with     %%%%
%%%%  all variables replaced by their names, for output of warning positions %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$done_goal(NewString, String, Goal, NumVars) :-
	acyclic(Goal) ->
		[not(
		    [$var_dec(Goal, NumVars, _),
		     swrite(NewString, String, "\n\t", Goal, ", "),
		     remember(string(NewString), $local),
		     fail]),				% to undo variable bindings
		 forget(string(NewString), $local)
		];
		swrite(NewString, String, "\n\t", Goal, ", "),
	!.

$done_head(String, Head) :-
	acyclic(Head) ->
		[not(
		     [$var_dec(Head, 0, _),
		      swrite(String, Head, " :-"),
		      remember(string(String), $local),
		      fail]),				% to undo variable bindings
		 forget(string(String), $local)
		];
		swrite(String, Head, " :-"),
	!.

$make_u_str(String, Term, NumVars) :-
	acyclic(Term) ->
		[not(
		     [$var_dec(Term, NumVars, _),
		      put_term(String, Term, 0),
		      remember(string(String), $local),
		      fail]),				% to undo variable bindings
		 forget(string(String), $local)
		];
		put_term(String, Term, 0),
	!.

$var_dec(Atom, NumVars, NewNumVars) :-
	var(Atom),
	!,
	successor(NumVars, NewNumVars),
	recall(variable(Atom, NewNumVars, _), $local).

$var_dec([Atom..], NumVars, NewNumVars) :-
	tailvar(Atom..),
	!,
	successor(NumVars, NewNumVars),
	recall(variable(Name, NewNumVars, _), $local),
	[Atom..] = [Name].

$var_dec(Atom, NumVars, NewNumVars) :-
	ground(Atom),
	name(Atom, [First, Rest..]),
	First = 95 ; [First >= 65, First =< 90],                    % starts with underscore or upper-case
	!,
	successor(NumVars, NewNumVars).                             % index + 1	

$var_dec(Atom, NumVars, NumVars) :-
	ground(Atom),
	!.
	
$var_dec(Functor(Args..), NumVars, NewNumVars) :-
	!,
	$var_dec(Functor, NumVars, TempVars),
	$var_dec([Args..], TempVars, NewNumVars).

$var_dec([Term, Rest..], NumVars, NewNumVars) :-
	!,
	$var_dec(Term, NumVars, TempVars),
	termlength([Rest..], Len, _),
	Len \= 0 ->  % stops empty list propogating
	$var_dec([Rest..], TempVars, NewNumVars);
	NewNumVars = TempVars,
	!.

$var_dec([], NumVars, NumVars) :- !.

%% The following predicates will be used as processing on terms got
%% with caps as vars and underscore as vars false, before cataloging
%% once prolog keeps the quotes around things read in as quotes

/*
$rm_strs(FullTerm, Term) :-
%	capitalsAsVariables(true),
	put_term(String, FullTerm, 0),
	name(String, AsciiList),
	$gobbleStr(AsciiList, NewList),
	name(NewString, NewList),
%	capitalsAsVariables(false),
	get_term(NewString, Term, 0).

$gobbleStr([], []) :- !.

$gobbleStr([C, Rest..], [C, C, RestNew..]) :- 
	[C = 34 ; C = 96],
	$inString(C, Rest, Left),
	!,
	$gobbleStr(Left, RestNew).

$gobbleStr([S, D, D, Q, D, D, Q, OB, CB, Rest..], [D, D, RestNew..]) :-
	[S = 32, D = 46, Q = 34, OB = 40, CB = 41],
	$gobbleStr(Rest, RestNew).

$gobbleStr([C, Rest..], [C, RestNew..]) :- $gobbleStr(Rest, RestNew).		


$inString(Q, [92, _, Rest..], Left) :- $inString(Q, Rest, Left).

$inString(Q, [Q, Rest..], Rest) :- !.

$inString(Q, [C, Rest..], Left) :- $inString(Q, Rest, Left).
*/
