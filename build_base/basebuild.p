/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/basebuild.p,v 1.1 1995/09/22 11:21:32 harrisja Exp $
*
*  $Log: basebuild.p,v $
 * Revision 1.1  1995/09/22  11:21:32  harrisja
 * Initial version.
 *
*
*/

checkout -d :old: -newer -r -project  'WAM Compilerº'
checkout -d :source: -update -project  'WAM Compilerº'
transferckid :old:interval.c :source:interval.c
modifyreadonly :source:interval.h
NameRevisions -a -public -r -project "WAM Compilerº" "Release 4.2.0"
projectinfo -project "WAM Compilerº" -r -comments -d ">12/21/92"
catenate ':base:base0' > :base:base0.prolog
catenate ':base:base0' ':base:base1' > :base:base1.prolog
catenate ':base:base1.prolog' ':base:base2' > :base:base2.prolog
catenate ':base:base2.prolog' ':base:base3' > :base:base3.prolog
catenate ':base:base3.prolog' ':base:base4' ':base:cmp_clause' ':base:cmp_arithmetic' > :base:base4.prolog
catenate ':base:base4.prolog' ':base:base_pprint' ':base:base_listener' ':base:base5' ':base:crias6' ':base:constraint_network' ':base:tasking' 'base:networking' > :base:base5.prolog




CompareOld
