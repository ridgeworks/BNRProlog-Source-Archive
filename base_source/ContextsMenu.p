/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/ContextsMenu.p,v 1.1 1995/09/22 11:23:39 harrisja Exp $
*
*  $Log: ContextsMenu.p,v $
 * Revision 1.1  1995/09/22  11:23:39  harrisja
 * Initial version.
 *
*
*/

/*
 *   ContextsMenu - Context menu handlers
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

menuselect(_, 'Contexts', 'Load File...') :-               % Load some file
   lastmenudata(_, 1), !,                         	   % selected load file, not a context called 'load fileÉ'
   stringlistresource(loadfile, [Msg]),
   selectafile('TEXT', Msg, Fn),                           % Fn is the selected file
   fullfilename(Cx, Fn),                                   % Given Fn, Get Cx
   $menuload_fn_as_cx(Fn, Cx).                             % Load Fn as context Cx

menuselect(_, 'Load Context', Cx) :-                       % Reload existing context
   $find_selected_context(170, 0, Cx, Fn),                 % Get Cx and Fn of selected context
   $menuload_fn_as_cx(Fn, Cx).                             % Load Fn as context Cx  

menuselect(_, 'Exit Context', Cx) :-                       % Exit existing context
   $find_selected_context(171, 0, Cx, Fn),                 % Get Cx and Fn of selected context
   capsule($messageexitcontext(Cx), []),                   % Inform user if possible
   $remove_context(Cx, Fn),                                % Pop it (and those above, if any)
   $listen_convience_prompt().                           

$messageexitcontext(Cx) :-
   $position_console_to_newline,
   stringlistresource(exitcontext, [Msg1, Msg2]),          % Inform user if possible
   swrite(1, Msg1, Cx, Msg2, '\n').

menuselect(_, 'Contexts', Cx) :-                           % Listing of context
   $find_selected_context('Contexts', 4, Cx, Fn),          % Get _Cx and _Fn of selected context
   stringlistresource(listfile, [List]),
   $select_predicates(List, Cx, Fn, Ps),  
   $position_console_to_newline,
   $listing_of_list(Ps),
   $listen_convience_prompt().                           


% Installing Context menu 

installmenu(W,'Contexts') :- 
    findall(Cx, context(Cx, Fn), Cxs),                     % Collect all contexts 
    $get_context_items(Cxs, Items1, Items2), 
    $install_contexts_menus(W,Items1),
    $installmenu(W,'Contexts', 'Contexts', 0,
                 'Load File...', [command('L')],
                 'Load Context', [menu(170)],
                 'Exit Context', [menu(171)],
                 '-', [disable],
                 Items2..).

$install_contexts_menus(W,Items) :-
    $console(W),
    $installmenu(W,'Load Context', 170, -1, Items..),
    $installmenu(W,'Exit Context', 171, -1, Items..).
$install_contexts_menus(W,_).

load_context(_, Fn ,Cx) :-
	$menuload_fn_as_cx_aux(Fn,Cx) -> true,
	$listen_convience_prompt.

/******************************* LOW LEVEL PRIMITIVES ******************************************/

$menuload_fn_as_cx(Fn, Cx) :-                           % Case: existing context
   $position_console_to_newline,
   postevent(load_context, _, Fn, Cx).                  % will eventually call next clause

$menuload_fn_as_cx_aux(Fn, _) :-                        % Case: existing context (Checked)
   $context(Cx, Fn),                                    % An existing context
   !,                                                   % Commit, in case of failure
   $reload_message(Fn, Cx),                             % Output reload message
   $reload_file_as_context(Fn, Cx).                     % Do a reload

$menuload_fn_as_cx_aux(Fn, Cx) :-                       % Case: new context (Assumed)
   $load_message(Fn, Cx),                               % Output load message
   $load_file_as_context(Fn, Cx).                       % Do a load


$find_selected_context(Menuid, Afterid, Cx, Fn) :-      % Menuid, Afterid and Cx are bound
      lastmenudata(Menuid, Itemid),                     % Get id of the selected item
      (N is (Itemid - Afterid)),                        % Assume id greater than Afterid
      nth_solution(context(_, Fn), N).                  % Find Fn of Nth context
  

% NOTE: Below we use findset to sort the list of predicates. We could use sort(Ps1, Ps2)
% but it requires substantially more memory, and is roughly a factor of two slower. 
% An exception to this is when Ps1 is ordered;  sort is a factor of 10 faster. 

$select_predicates(Msg, Cx, Fn, Ps) :-            
	$context(TopCx,_),
	cut,
	$visible_predicates(Cx,TopCx,Predicates) ->			% IF predicates can be retrieved and sorted
        true ;                                          % THEN proceed
        [$mu_error(nomemforpredicates, Cx),             % ELSE output message
         failexit($select_predicates)],					%      and FAIL !!!!
    (Predicates @\= []) ->								% IF there are predicates
        select(Msg, Predicates, Ps) ;                   % THEN select those for listing
        [$mu_error(nopredicates, Cx),                   % ELSE output message 
         failexit($select_predicates)],					%      and FAIL !!!!
	true.												% defeat LCO

$visible_predicates(Cx,Cx,Predicates) :-
	!,
	findset(P,predicate(P,Cx),Predicates).
$visible_predicates(Cx,_,Predicates) :-	
	findset(P,[predicate(P,Cx),
			   not(name(P,[0'$,_..]))],Predicates).		% keep only non-local predicates
 
$listing_of_list([]).                                   % All done, no more predicates
$listing_of_list([P, Ps..]) :-                          % One or more predicates.
   (listing(P) -> true),                                % List 1st one (always succeeds)
   $listing_of_list(Ps).                                % and recur with remaining


$installmenu(W, Name, Id, After, Items..) :- 
    addmenu(W, Id, Name, After),
    $installitems(W, Id, Items..).

$installitems(W, Id).
$installitems(W, Id, Item, Att, Items..) :- 
    additem(W, Item, Att, Id, end_of_menu, _),
    $installitems(W, Id, Items..).


$get_context_items([base], [], [base, []]) :- !.       % Unifable with 2nd clause
$get_context_items([Cx, Cxs..], [Cx, [], L1..], [Cx, [], L2..]) :-
    $get_context_items(Cxs, L1, L2).


$disable_context_menu_items(W) :- 
    $able_context_menu_items(W,[disable]).          % disable using '('

$enable_context_menu_items(W) :-              
    $able_context_menu_items(W,[enable]).          % enable using ')'

$able_context_menu_items(W,Able) :-           % Always succeeds
    menuitem(W,'Contexts', 1, _, Able),       % 1 is Load_File
    menuitem(W,'Contexts', 2, _, Able),       % 2 is Load_Context
    menuitem(W,'Contexts', 3, _, Able),       % 3 is Exit_Context
    fail.                                   % Fail - ripple to 2nd clause
$able_context_menu_items(W,[enable]) :-            % If we are enabling things, see if item 1 needs changing
    useractivate(W, _, _),             		% Pretend to activate it
    !.                                      % succeed and remove choicepoints
$able_context_menu_items(_,_).              % In case Context menu disappears
 
      
% Called by base

$add_context_to_menus(Cx) :-                % Always succeeds
    additem(Cx, '', 'Contexts', 4, _),      % As Itemid 1
    additem(Cx, '', 170, 0, _),             % As Itemid 2
    additem(Cx, '', 171, 0, _),             % As Itemid 3
    fail.                                   % Fail - ripple to 2nd clause
$add_context_to_menus(_).                   % In case Context menu disappears

$rem_context_from_menus() :-                % Always succeeds
    deleteitem('Contexts', 5),              % Delete from "context" menu
    deleteitem(170, 1),                     % Delete from "load context"
    deleteitem(171, 1),                     % Delete from "exit context"
    fail.                                   % Fail - ripple to 2nd clause
$rem_context_from_menus().                  % In case Context menu disappears

$mu_error(Res, Cx) :-
     stringlistresource(Res, [Msg1, Msg2]),
     swrite(Msg, Msg1, Cx, Msg2),
     message(Msg). 

$load_message(Fn, Cx) :-
    name(Fn, L),                                        % convert filename to ascii codes
    stringlistresource(loadingcontext, [_, Msg1, Msg2, Msg3, Msg4]),
    L = [58, 58, _..] ->                                % is this a system generated name ??
        swrite(1, Msg1, Cx, Msg4, '\n') ;               % yes, so simple message
        ([Cx = Fn, not($member(58, L))] ->              % if no : in Fn,
            swrite(1, Msg1, Cx, Msg2, '\n') ;           % then must come from application
            swrite(1, Msg1, Cx, Msg3, Fn, Msg4, '\n')), % else just from regular file
    !.


$reload_message(Fn, Cx) :- 
    stringlistresource(loadingcontext, [Msg, _..]),
    swrite(1, Msg), 
    $load_message(Fn, Cx).
