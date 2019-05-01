/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/project.p,v 1.1 1995/09/22 11:26:45 harrisja Exp $
*
*  $Log: project.p,v $
 * Revision 1.1  1995/09/22  11:26:45  harrisja
 * Initial version.
 *
*
*/

%%%
%%%    Project adds a LightSpeed-like environment to BNR Prolog,
%%%    accessed through the project menu.
%%%
%%%    To install project, load the context at any time.
%%%
%%%    To make project permanent, load the context with the initial
%%%    predicate (set by configuration/4).
%%%

$initialization :-
    addmenu(1000, 'Project', 0),
    additem('New Project...', ')', 1000, end_of_menu, _),
    additem('Open Project...', ')', 1000, end_of_menu, _),
    additem('-', '(', 1000, end_of_menu, _),
    additem('Add File...', '(', 1000, end_of_menu, _),
    additem('Remove File...', '(', 1000, end_of_menu, _),
    additem('-', '(', 1000, end_of_menu, _),
    additem('Save Project', '(', 1000, end_of_menu, _),
    additem('Close Project', '(', 1000, end_of_menu, _).

$termination :-
    deletemenu(1000).

'APPJ'(File) :-            %% called if user double clicks on our file (MAC only)
    openwindow(graf, Window, pos(100, 100), size(400, 50), options(dboxproc)),
    swrite(S, 'Loading project ', File),
    dograf(Window, textbabs(20, 18, 300, 40, S)),
    fullfilename(File, Fname),
    $load_project(Fname),
    closewindow(Window).

$menu_enable(NewOpen, SaveClose) :-         % toggle menu states together
    menuitem(1000, 1, _, NewOpen),
    menuitem(1000, 2, _, NewOpen),
    menuitem(1000, 4, _, SaveClose),
    recall(file(_), $local) -> menuitem(1000, 5, _, SaveClose) ; menuitem(1000, 5, _, '('),
    menuitem(1000, 7, _, SaveClose),
    menuitem(1000, 8, _, SaveClose).

menuselect(_, 'Project', 'New Project...') :-
    recall(project(Old), $local) -> $close_project(Old),
    nameafile('New', 'Project name:', 'Untitled', File),
    createfile(File, 'APPJ') -> true,
    $new_project(File),
    $menu_enable('(', ')').

menuselect(_, 'Project', 'Open Project...') :-
    recall(project(Old), $local) -> $close_project(Old),
    selectafile('APPJ', 'Open', File),
    $load_project(File).

menuselect(_, 'Project', 'Add File...') :-
    recall(project(_), $local),             % make sure project open
    selectafile('TEXT', 'Add', File),
    project_add_file(File).
    
menuselect(_, 'Project', 'Remove File...') :-
    recall(project(_), $local),             % make sure project open
    findall(S, [recall(file(F), $local), fullfilename(S, F)], L),
    selectone('File to remove from project ?', L, File),
    recall(file(Fname), $local),
    fullfilename(File, Fname),
    !,
    forget(file(Fname), $local),
    $menu_enable('(', ')'),
    integer_range(N, 9, 100),
    menuitem(1000, N, Item, _),
    Item = File,
    deleteitem(1000, N),
    !,
    recall(file(_), $local) -> true ; $remove_all_files_from_menu,
    !.
    
menuselect(_, 'Project', 'Save Project') :-
    recall(project(Old), $local),           % make sure project open
    $save_project(Old).

menuselect(_, 'File', 'Quit') :-
    recall(project(Old), $local),           % make sure project open
    $close_project(Old),
    cut,
    fail.                                   % ripple into real clause

menuselect(_, 'Project', 'Close Project') :-
    recall(project(Old), $local) -> $close_project(Old),
    $menu_enable(')', '(').

menuselect(_, 'Project', SFile) :-
    lastmenudata(_, I),
    I > 9,
    recall(file(Fname), $local),            % see if we can find it
    fullfilename(SF, Fname),
    SF = SFile,
    !,                                      % yes, so commit
    openwindow(text, Fname, _, _, _) ;      % try to open it
    activewindow(Fname, text),              % else try to activate it
    !.

$save_project(File) :-
    $build_commands(C),
    open(S, File, read_write, 0),
    put_term(S, C, 0),
    close(S, 0),
    !.

$close_project(File) :-
    $build_commands(C),                 %% see what we have
    open(S, File, read_write, 0),
    get_term(S, Goal, _),               %% get what is in the file
    C \= Goal -> [                      %% if different then
        fullfilename(SFile, File),
        swrite(Str, 'Do you want to save project ', SFile, ' first ?'),
        confirm(Str, 'NO', 'YES', Ans),
        Ans = 'YES' -> [seek(S, 0), put_term(S, C, 0) ] ],
    close(S, 0),
    $close_files,                       %% close any files for this project
    $remove_all_files_from_menu,
    $remove_contexts,
    new_state(0, $local),               %% discard all saved data
    !.

$close_files :-
    iswindow(Name, text, _), 
    fullfilename(Name, FName),
    recall(file(FName), $local),
    changedtext(Name) -> [
        stringlistresource(closefile, [Msg1, Msg2..]),
        swrite(Prompt, Msg1, Name, Msg2..),
        confirm(Prompt, 'YES', 'YES', Response),
        Response = 'YES' -> [
            savetext(Name) -> true ; [ 
                stringlistresource(cannotsave, [M1, M2..]),
                swrite(P2, M1, Name, M2..),
                beep,
                message(P2) ] ] ],
    closewindow(Name),
    fail.
$close_files.

$remove_all_files_from_menu :-
    deleteitem(1000, 9),
    $remove_all_files_from_menu.
$remove_all_files_from_menu.

$remove_contexts :-
    findall(exit_context(Cx), 
            [context(Cx, Fn), Cx \= base, Cx\= userbase, Cx \= project], 
            List),
    List.

$load_project(File) :-
    open(S, File, read_only, 0),
    get_term(S, Goal, 0),
    close(S, 0),
    $new_project(File),
    Goal,
    $menu_enable('(', ')'),
    !.

$new_project(File) :-
    remember(project(File), $local).

project_add_file(File) :-               %% must be global since name saved in file
    isfile(File, _, _) -> [
        recall(file(_), $local) -> true ; additem('-', '(', 1000, end_of_menu, _),
        fullfilename(S, File),
        additem(S, ')', 1000, end_of_menu, _),
        rememberz(file(File), $local),
        menuitem(1000, 5, _, ')')],
    !.

project_load_context(_, Fn, Cx) :- 
    load_context(Fn).                   %% use arity 2 version when available

$generate_file_list(List) :-
    findall(project_add_file(F), 
            recall(file(F), $local), 
            List).

$generate_context_list(List) :-
    findall(postevent(project_load_context, _, Fn, Cx), 
            [context(Cx, Fn), Cx \= base, Cx\= userbase, Cx \= project], 
            RList),
    $reverse(RList, List).

$reverse([], []).
$reverse([X, RList..], List) :-
    $reverse(RList, NList),
    $append(NList, X, List).

$append([], L, [L]).
$append([H, T1..], L, [H, T2..]) :- $append(T1, L, T2).

$generate_window_list(List) :-
    findall(openwindow(text, FName, pos(X,Y), size(W,H), options()), 
            [   iswindow(Name, text, Visible), 
                fullfilename(Name, FName),
                recall(file(FName), $local),
                not(stream(1, Name, _)), 
                positionwindow(Name, X, Y), 
                sizewindow(Name, W, H)], 
            RList),
    $reverse(RList, List).

$build_commands([Files, Contexts ; true, Windows ; true, Active ; true, cut]) :-
    $generate_file_list(Files),
    $generate_context_list(Contexts),
    $generate_window_list(Windows),
    activewindow(W, T),
    [T = text, recall(file(W), $local)] -> Active = activewindow(W, T); Active = [],
    !.
