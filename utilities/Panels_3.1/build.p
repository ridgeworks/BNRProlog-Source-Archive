/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/build.p,v 1.2 1997/03/14 17:09:22 harrisj Exp $
*
*  $Log: build.p,v $
 * Revision 1.2  1997/03/14  17:09:22  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.1  1995/09/22  11:22:50  harrisja
 * Initial version.
 *
*
*/

build(panels):-
    once(compile(['panels.p','panel_uif.p',
             'button_editor.p','field_editor.p','list_editor.p',
             'panel_editor.p'])).
