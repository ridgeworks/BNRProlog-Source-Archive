#if 0
----------------------------------------------------------------------
> Global Function: OpenFile ;
  $ BooleanOpenFile (PTextWindow*)
> Purpose:
  | This opens the file that is in the 'filename' field of 'new_window'.  If the file is already opened in read_only mode then a warning is printed out.  If it can't open the file, FALSE is returned.  It then reads the file into sets the contents of 'new_window' to be the file contents.  The 'file_saved' field of 'new_window' is set to TRUE, and 'err' to zero.  Once the file has been read, it is closed.  If it can't close the file, a warning is printed out.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success
> Parameters:
  = PTextWindow* new_window - Text Window to read the file into.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: SaveFile ;
  $ BooleanSaveFile (PTextWindow*, char*)
> Purpose:
  | This function saves the contents of 'fw' into a temporary file (/tmp/bnrpXXXXXX where the X's get replaced with the process ID) and then into the file pointed to by 'fname'.  If the save into 'fname' is successful, the temporary file is removed and the 'file_saved' flag of 'fw' is set to TRUE.  If any problems occur with either of the files, warnings are printed out
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on sucess
> Parameters:
  = PTextWindow* fw - text window whose contents are to be saved
  = char* fname - Name of the file to save to.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
