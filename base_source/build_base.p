/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/build_base.p,v 1.1 1995/09/22 11:22:52 harrisja Exp $
*
*  $Log: build_base.p,v $
 * Revision 1.1  1995/09/22  11:22:52  harrisja
 * Initial version.
 *
*
*/

build_base :-
	write('Combining base files...\n'),
	system('cat_base'),
	write('Compiling...\n'),
	compile(base).

$initialization :- 
	load_context('../compile'),
	build_base.
