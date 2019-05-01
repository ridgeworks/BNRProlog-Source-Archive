/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/panels.p,v 1.1 1995/09/22 11:25:33 harrisja Exp $
*
*  $Log: panels.p,v $
 * Revision 1.1  1995/09/22  11:25:33  harrisja
 * Initial version.
 *
*
*/

/*
 *   panels
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/

% This file contains the $initialization routine that consults all the necessary 
% files for 'panels 3.x'. Users who build panels into their application
% will provide the functionality of this file in their own initialization,
% subject to some feature decisions, e.g., do you want Panels menu and online
% help; do you want editing capability, ..? See Implementation description
% for more information.

panels_version('panels 3.1.13').

$unix:-predicate(dragregion). %%% kludge !

%$filesep('/'):-$unix,!.
%$filesep(':').

panel_directory(PFolder):-
    recall(paneldir(PFolder),$local).
%    context(panels,PPath),            % where panels was loaded from
%    concat(Folder,panels,PPath),  % get  parent folder
%    concat(Folder,'panel_files:',PFolder).  % construct sub folder 'panel files'

$setpanelfolder(Folder):-   % set default dir to panel_files, Folder = 'panels' folder
    once(context(Cx,Path)),       % where this context was loaded from
    once(concat(Path1,'.a',Path);Path1=Path),
    concat(Folder,'panels',Path1),
    $unix -> PF=panel_files;PF='panel_files:',  
    concat(Folder,PF,PFolder), % other files in sub-folder called 'panel files'
    remember(paneldir(PFolder),$local), 
    defaultdir(PFolder).

$initialization:- 
    defaultdir(Dd),               % save current default dir

    $setpanelfolder(Folder),

    installmenu('Panels'),        % install menus in 'panels uif'

    listfonts(Fontnums),          % prebuild font info
    foreach($member(N,Fontnums) do
        [once(isfont(N,_,Name,_)),
         listsizes(N,Ss),
         $cnvrt(Ss,Sizes),
         assertz(panelfontinfo(Name,N,Sizes))]),

    panels_version(V),
    write('\n',V,'\n').

% ----------------------- Support routines -------------------------------------------

$cnvrt([],[]).
$cnvrt([S,Ss..],[Size,Sizes..]):-
    S=<30,!,  % limit font sizes in menu (System 7 generates 9-127 for many fonts)
    swrite(Size,S),
    $cnvrt(Ss,Sizes).
$cnvrt([S,Ss..],[Sizes..]):-
    %S>30,
    $cnvrt(Ss,Sizes).

$member(Item,[Item,_..]).
$member(Item,[_,Items..]):- $member(Item,Items).

$quit_context:-
    context(Cx,_),          % generate contexts
    concat(_,panels,Cx),    % if it ends with panels
    exit_context(Cx).       % exit   

$termination:-
    deletemenu(2224).             % Panels (for number see 'panels uif')

