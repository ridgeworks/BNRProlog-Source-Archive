/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/stringlistresource.p,v 1.1 1995/09/22 11:28:48 harrisja Exp $
*
*  $Log: stringlistresource.p,v $
 * Revision 1.1  1995/09/22  11:28:48  harrisja
 * Initial version.
 *
*
*/

stringlistresource(newfile,['New','Open as:','Untitled']).
stringlistresource(openfile,['Open']).
stringlistresource(closefile,['Save ',' before closing it?']).
stringlistresource(savefileas,['Save','Save as:']).
stringlistresource(savefilecopy,['Save','Save a copy as:']).
stringlistresource(reverttofile,['Discard changes to ','?']).
stringlistresource(printfile,['Save ',' before printing it?']).
stringlistresource(renamefile,['Rename','Rename ',' to :']).
stringlistresource(deletefile,['Delete']).
stringlistresource(loadfile,['Load']).
stringlistresource(cannotreplace,['Unable to replace ','. (It may be locked!)']).
stringlistresource(cannotsave,['Unable to save ','.']).
stringlistresource(cannotcreate,['Unable to create ','.']).
stringlistresource(cannotcopy,['Unable to copy ',' to ','.']).
stringlistresource(cannotrename,['Unable to rename ',' to ','.']).
stringlistresource(cannotdelete,['Unable to delete ','.']).
stringlistresource(loadingcontext,['Re-','Loading context \'','\' from application.','\' from source \'','\'.']).
stringlistresource(nomemforpredicates,['Insufficient memory to collect the names of all the predicates defined in context \'','\'.']).
stringlistresource(nopredicates,['There are no defined predicates in context \'','\' that may be listed (at this time).']).
stringlistresource(exitcontext,['Exiting context \'','\'.']).
stringlistresource(listfile,['Select predicates for listing:']).
