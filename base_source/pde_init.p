/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/pde_init.p,v 1.1 1995/09/22 11:25:59 harrisja Exp $
*
*  $Log: pde_init.p,v $
 * Revision 1.1  1995/09/22  11:25:59  harrisja
 * Initial version.
 *
*
*/

$openconsolewindow :-
	predicate($openwindow),		% is window support installed ?
	$console(Console),		% yes, so open the console window
	doubletime(500),		% set default double-click time
	% openwindow(text, Console, _, _, options(hidden,noclosebox)),
        not(openwindow(text, Console, _, _, options(hidden,noclosebox))) 
		-> failexit(pde_init),
	fullfilename(Console,ConsoleFile),
	open(Strm, ConsoleFile, read_write_window, 0), % open the real file
	seek(Strm, end_of_file).
$openconsolewindow.
		
$install_pde_menus(W) :-
	$install_pde_menus(W,[]).
$install_pde_menus(W, Opts) :-
	installmenu(W,'File',Opts) -> true,
	installmenu(W,'Edit') -> true,
	installmenu(W,'Find') -> true,
	installmenu(W,'Window') -> true,
	installmenu(W,'Help') -> true,
	$console(W) ->
		[installmenu(W,'Contexts') -> true],
	!.
