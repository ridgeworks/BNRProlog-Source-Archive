/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/editmenu.p,v 1.1 1995/09/22 11:24:02 harrisja Exp $
*
*  $Log: editmenu.p,v $
 * Revision 1.1  1995/09/22  11:24:02  harrisja
 * Initial version.
 *
*
*/

installmenu(W,'Edit') :-
	addmenu(W, 'Edit', 'Edit', 0),
	additem(W,'Undo', [command('Z'),disable], 'Edit', end_of_menu, _),
	additem(W,'Cut', [command('X')], 'Edit', end_of_menu, _),
	additem(W,'Copy', [command('C')], 'Edit', end_of_menu, _),
	additem(W,'Paste', [command('V')], 'Edit', end_of_menu, _),
	additem(W,'Delete', [], 'Edit', end_of_menu, _),
	additem(W,'Format...', [command('Y')], 'Edit', end_of_menu, _).

menuselect(W,'Edit','Copy') :- 
	dotext(W, edit(copy)).

/*
too be able to undo you
-----------------------
x) recall last-text-op if key repeats are to be handled properly
x) recall last-buffer-number
x) preserve window-name
x) preserve sel-start
x) preserve sel-text
x) execute text-op
x) preserve sel-end
x) update undo-menu-item with 'Undo text-op'
x) remember last-buffer-number, window-name, sel-start, sel-end, text-op

to undo you
-----------
x) recall last-buffer-number
x) recall window-name
x) recall last-sel-start
x) recall last-sel-end
x) set selection in window window-name to (last-sel_start, last-sel-end)
x) open new-buffer-number
x) preserve sel-text into new-buffer-number
x) insert last-sel-text out of last-buffer-number deleting selection in the process
x) close last-buffer-number
x) recall last-text-op
x) update undo-menu-item with 'Undo Undo last-text-op' or 'Undo last-text-op' if undoing an undo
x) remember new-buffer-number, window-name, last-sel-start, sel-end, last-text-op
*/

%% command delete 
%% delete to start of file
userkey(Window, '\b', [Cntrl, Option, Caps, 0, 1, Mouseup]) :-
	dotext(Window, [inq(selectcabs(_,E)), selectcabs(0,E)]),
	$undoabletext(Window, 0, edit(clear), 'delete to sof').

%% command shift delete
%% delete to end of file
userkey(Window, '\b', [Cntrl, Option, Caps, 1, 1, Mouseup]) :-
	inqtext(Window, [selectcabs(S,_), do(selectcabs(S, end_of_file))]),
	$undoabletext(Window, S, edit(clear), 'clear to eof').

%% shift delete
%% clear succeeding character .. do a speed optimized, non-undoable, variation
userkey(Window, '\b', [Cntrl, Option, Caps, 1, 0, Mouseup]) :-
    % if no selection then don't bother making this operation 
    % undoable, just pass the delete through. Only one char gets deleted!
    dotext(Window, [inq(selectcabs(S,S)), selectcrel(0,1), edit(clear)]).
%% clear selection
userkey(Window, '\b', [Cntrl, Option, Caps, 1, 0, Mouseup]) :-
    % a selection exists so do an undoable operation
    inqtext(Window, selectcabs(Start,_)),
    $undoabletext(Window, Start, edit(clear), 'clear').

%% plain delete
%% delete preceding character .. do a speed optimized, non-undoable, variation
userkey(Window, '\b', _) :-
    % if no selection then don't bother making this operation 
    % undoable, just pass the delete through. Only one char gets deleted!
    dotext(Window, [inq(selectcabs(S,S)), selectcrel(-1,0), edit(clear)]).
%% delete selection
userkey(Window, '\b', _) :-
    % a selection exists so do an undoable operation
    inqtext(Window, selectcabs(Start,_)),
    $undoabletext(Window, Start, edit(clear), 'delete').

%% *************************************************************************
%% handler for all other non-command keys. ie. regular printable ascii
%% if there is no current selection then just pass the key through
userkey(Window, Key, [Control, Option, Capslock, Shift, 0, Mouseup]) :- 
	namelength(Key,1),
    dotext(Window, [inq(selectcabs(S,S)), replace(Key)]).
%% if there is a current selection then make the replace undoable
userkey(Window, Key, [Control, Option, Capslock, Shift, 0, Mouseup]) :- 
	namelength(Key,1),
    inqtext(Window, selectcabs(Start,_)),
    $undoabletext(Window, Start, [], replace),
    dotext(Window, replace(Key)). % keep this key out of the undo state. Since we 
    % don't make any successive keys strokes undoable, don't do make this one either!

%% *************************************************************************
%% handlers for undoable Edit menu operations cut, paste and clear.
%% move selection to clipboard
menuselect(Window, 'Edit', 'Cut') :- 
    inqtext(Window, selectcabs(S,E)),
    % if no selection then do nothing
    S \= E -> $undoabletext(Window, S, edit(cut), 'cut').

%% replace selection with clipboard contents
menuselect(Window, 'Edit', 'Paste') :- 
    inqtext(Window, selectcabs(S,_)),
    $undoabletext(Window, S, edit(paste), 'paste').

%% clear selection 
menuselect(Window, 'Edit', 'Delete') :- 
    inqtext(Window, selectcabs(S,E)),
    % if no selection then do nothing
    S \= E -> $undoabletext(Window, S, edit(clear), 'delete').

%% *************************************************************************
%% routine to implement undoable text operations
$undoabletext(Window, Start, TextOp, FuncToUndo) :-
    forget(undo(Window, _..), $local) -> true,
    inqtext(Window, [selection(Text),                   % save the text
        do(TextOp), selectcabs(End,_)]),                % do text-op and get end
    swrite(UndoFunc, 'Undo ', FuncToUndo),
    remember(undo(Window, Text, Start, End, FuncToUndo), $local),
    menuitem(Window, 'Edit', 1, UndoFunc, [enable]) -> true.             % in case the menu is not there

%% *************************************************************************
% the actual undo function
menuselect(Window, 'Edit', OldUndoFunc) :- 
    concat('Undo ',Func,OldUndoFunc),
    $undo(Window, OldUndoFunc).
$undo(Window, OldUndoFunc) :- 
	get_obj(Op, undo(Window, OldText, S, End, FuncToUndo), $local),
    inqtext(Window, [do(selectcabs(S,End)), selection(NewText),% set selection and save the text
%%      implement the replace as a (clear + insert) since its much faster for CR's
        do([edit(clear), insert(OldText)]), selectcabs(E,_), % restore the old text and get the end
        do(selectcabs(S,E))]),                                  % reselect previous selection
    concat('Undo Undo ', _, OldUndoFunc) ->                 % we're undoing an UNDO
        swrite(UndoFunc, 'Undo ', FuncToUndo)               % relabel with the original item
    ; swrite(UndoFunc, 'Undo ', OldUndoFunc),   
    menuitem(Window, 'Edit', 1, UndoFunc, [enable]),
    put_obj(Op, undo(Window, NewText, S, E, FuncToUndo), $local).
$undo(Window, OldUndoFunc) :- 
    menuitem(Window, 'Edit', 1, 'Undo', [disable]),
    forget(undo(Window, _..), $local)->true.

menuselect(Window, 'Edit', 'Format...') :-
	inqtext(Window, [textfont(F), textsize(S)]),
	queryformat([F,S,8], [NF,NS,_], TC),
	$postifchanged(Window, F, S, NF, NS),
	nonvar(TC) -> postevent($converttabs, Window, TC, _).

$postifchanged(Window, F, S, F, S) :- !.
$postifchanged(Window, _, _, NF, NS) :-
	postevent($twoParmEvent, Window, dotext,
		[[textfont(NF),textsize(NS)]]).

$twoParmEvent(W, F, [P..]) :- F(W, P..).

$converttabs(Window, TC, _..) :-
	beep,
	message('Tab conversion is not supported').
