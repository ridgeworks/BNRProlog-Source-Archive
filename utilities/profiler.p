/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/profiler.p,v 1.1 1995/09/22 11:26:21 harrisja Exp $
*
*  $Log: profiler.p,v $
 * Revision 1.1  1995/09/22  11:26:21  harrisja
 * Initial version.
 *
*
*/

/*
                     Statistical Profiler
                     --------------------

   This utility uses the 'tick' mechanism in BNR Prolog to gather
   statistics on program execution.  At each clock 'interrupt', the
   goal stack is examined and statistics updated for each visible
   predicate.  An exclusive count is incremented if it the first
   goal, otherwise the inclusive count is incremented.  To minimize
   'noise' in the output, 'not','once',';', and '->' are ignored.

   Interface:
      profiler(on)      : enable statistics gathering
      profiler(off)     : disable statistics gathering
      profiler(clear)   : clear statistics table
      profiler(dump)    : dump statistics summary to console

   These commands can be entered from the console or imbedded in user
   code.  They are also available through the 'Profiler' menu as
   'Enable', 'Disable', 'Clear', and 'Dump' respectively.

   The dump facility uses the 'pFormat' utility found in the 'Utilities'
   folder of the standard release package.  It must be loaded first,
   or be available in the same folder as this file.

   The 'tick' interval is currently set as fine as possible to maximize
   the number of samples and hence the accuracy of the tool.  However,
   this can result in significant reduction in performance due to 
   sampling overheads.  The sampling interval can be modified by changing
   the value in the 'enable_timer' call in the clause 'profiler(on)'

   Contact Rick Workman (3-3579) if you have any comments or questions.
*/

profiler(on):-
    $setmenuitem('Disable'),
    enable_timer(0.01).

profiler(off):-
    enable_timer(0),
    $setmenuitem('Enable').
 
profiler(clear):-
    new_state(0,$local),
    new_state(10,$local),
    remember(predicates(),$local).

tick:-
    new_counter(0,C),
    goal(G),
    $keeper(G,F),
    C,
    counter_value(C,V),
    $mark(V,F),
    fail.
tick.

$mark(1,_):-!.   % first goal is tick, ignore it
$mark(2,F):-     % next goal for exclusive count, existing record
    get_obj(P,F(E,I),$local),
    !,
    successor(E,E1),
    put_obj(P,F(E1,I),$local).
$mark(2,F):-     % next goal for exclusive count, create new record
    new_obj(F(1,0),_,$local),
    get_obj(Op,predicates(Ps..),$local),
    put_obj(Op,predicates(F,Ps..),$local),
    !.
$mark(C,F):-     % next goal for inclusive count, existing record
    % C>2,
    get_obj(P,F(E,I),$local),
    !,
    successor(I,I1),
    put_obj(P,F(E,I1),$local).
$mark(C,F):-     % next goal for inclusive count, create new record
    % C>2,
    new_obj(F(0,1),_,$local),
    get_obj(Op,predicates(Ps..),$local),
    put_obj(Op,predicates(F,Ps..),$local),
    !.

$keeper(F,F):-
    name(F,L),name(F1,L),F=F1,  % strip out local names execpt in top context
    $non_control(F),!.

$keeper(F(Args..),F):-
    name(F,L),name(F1,L),F=F1,  % strip out local names execpt in top context
    $non_control(F),
    acyclic(F(Args..)).

$non_control(not):-failexit($non_control).
$non_control(';'):-failexit($non_control).
$non_control('->'):-failexit($non_control).
$non_control(once):-failexit($non_control).
$non_control(_).

profiler(dump):-
    get_obj(_,predicates(Ps..),$local),
    findset([Ex,In,P],
            [$member(P,Ps),
             recall(P(Ex,I),$local),
             In is Ex+I],
            Data),
    $countsamples(Data,0,Total),
    once([pformat(Header,'Predicate':29,'Exclusive':17,'Inclusive'),
          write('\n',Header,'\n')]),
    once(
       [$revmember([E,I,P],Data),
        Epc is (E/Total)*100,
        Ipc is (I/Total)*100,
        pformat(Out,P:25,':',E:5,'(',Epc:6:2,'%)   ',I:5,'(',Ipc:6:2,'%)'),
        write('\n',Out),
        fail];
        true),
    write('\n\n      Total Samples= ',Total,'\n').

$countsamples([],Total,Total).
$countsamples([[V,_..],Rest..],Acc,Total):-
    NewAcc is Acc+V,
    $countsamples(Rest,NewAcc,Total).

$revmember(X,[_,Xs..]):-$revmember(X,Xs).
$revmember(X,[X,Xs..]).

$member(X,[X,Xs..]).
$member(X,[_,Xs..]):-$member(X,Xs).

%
% menu operations - always succeed in case no menu support loaded
%
$profiler_menu(12321).  % "Profiler" menu id
  
$createmenu:-
   $profiler_menu(Menuid),
   addmenu(Menuid,'Profiler',0), % initialize menus
   additem('Enable','',Menuid,0,1),
   additem('Dump','',Menuid,1,2),
   additem('Clear','',Menuid,2,3),
    !.
$createmenu.
 
$deletemenu:-
   $profiler_menu(Menuid),
   deletemenu(Menuid),
   !.
$deletemenu.

$setmenuitem(Label):-
    $profiler_menu(Menuid),
    menuitem(Menuid,1,Label,''),
    !.
$setmenuitem(Label).

%
% menu event handling
%
menuselect(_,'Profiler','Enable'):-
   profiler(on).
   
menuselect(_,'Profiler','Disable'):-
   profiler(off).
   
menuselect(_,'Profiler','Dump'):-
   % skip this for now - Unix stream name not same as window name cf. L.B.
   %stream(1,WN,_..),    % make console window active
   %activewindow(WN,text),
   profiler(dump).
   
menuselect(_,'Profiler','Clear'):-
   profiler(clear).

% initialization and termination code
 
$initialization:-
   $load(pFormat),
   $createmenu,
   profiler(clear).

$termination:-
   $deletemenu.

$load(C):-
   context(C),!.     % already loaded
$load(C):-
   context(Cx,Fn),   % this context
   concat(Dir,Cx,Fn),% directory component of file name
   concat(Dir,C,CFn),% assume required context in same directory
   load_context(CFn).
