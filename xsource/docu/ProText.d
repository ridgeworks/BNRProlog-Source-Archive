#if 0
----------------------------------------------------------------------
> Struct:
  | font_cache
  $ struct font_cache
> Purpose:
  | This structure is used to hold a font cache entry.  This is used to reduce the number of requests to the font server that must be done.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = FontInfo* info - simple font information
  = XFontStruct* font - font structure returned by font server.
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: TextGetSelection ;
  $ char*TextGetSelection (PTextWindow*)
> Purpose:
  | This function returns the current selection which must be freed when no longer in use.
> Calling Context:
  | 
> Return Value:
  | char* - pointer to the current selection (alocated memory)
> Parameters:
  = PTextWindow* w - Text window to get the current selection from.
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
> Global Function: TextGetSelectionPosition ;
  $ voidTextGetSelectionPosition (PTextWindow*, XmTextPosition*, XmTextPosition*)
> Purpose:
  | This function retrives the start and end positions (relative to the number of charatcres from the start of the window text) of the current selection.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - Text window to get the current selection positions from
  = XmTextPosition* start - start of the current selection filled in by function
  = XmTextPosition* end - end of the current selection filled in by function.
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
> Global Function: TextSetSelection ;
  $ voidTextSetSelection (PTextWindow*, XmTextPosition, XmTextPosition)
> Purpose:
  | This function sets the current selection to be between the positions 'start' and 'end' in the window 'w'.  'start' and 'end' are the number of characters from the start of the window text.  If the current window is not the focus window, then the current selection isn't set, but the text between 'start' and 'end' is highlighted.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - window to set the current selection in.
  = XmTextPosition start - start position of the new selection
  = XmTextPosition end - end position of the new selection
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
> Global Function: TextSetCursorPosition ;
  $ voidTextSetCursorPosition (PTextWindow*, XmTextPosition)
> Purpose:
  | Sets the cursor position in 'w' to be 'pos'.  We don't scroll down to the new position.  If it is the focus window, then the new selection position is set to be this, otherwise 'pos' is highlighted.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - text window to set the new cursor position in
  = XmTextPosition pos - New cursor position in 'w'.
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
> Global Function: TextSetInsertionPosition ;
  $ voidTextSetInsertionPosition (PTextWindow*, XmTextPosition)
> Purpose:
  | This function sets the current insertion position (and selection) to be 'pos' for the text window 'w'.  If 'w' is not in focus window, the the current selection is not set to be 'pos', it is only highlighted (hence not brought into focus).  If it is the focus window, then we scroll down to the new location.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - Text window to set the insertion position
  = XmTextPosition pos - Position in text window to set the new insertion position.
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
> Global Function: TextSwapSelection ;
  $ voidTextSwapSelection (PTextWindow*, PTextWindow*)
> Purpose:
  | This function swaps the current selection from the text window 'from' to the text window 'to'.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* from - source of selection text
  = PTextWindow* to - destination of selection text.
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
> Global Function: TextInsert ;
  $ voidTextInsert (PTextWindow*, XmTextPosition, char*)
> Purpose:
  | This function inserts the text 's' at position 'pos' relative to the start of the file. 's' must be allocated.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - Text window into which 's' is being insrted
  = XmTextPosition pos - position to insert the text from the start of the file
  = char* s - string being inserted.
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
> Global Function: TextReplace ;
  $ voidTextReplace (PTextWindow*, XmTextPosition, XmTextPosition, char*)
> Purpose:
  | This function replaces the text between positions 'start' and 'end' relative to the number of characters from the start of the window text with the string 's'.  The current selection is set to be 's'. 's' Must be allocated.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PTextWindow* w - Text window whose text is to be replaced
  = XmTextPosition start - start position of text being replaced
  = XmTextPosition end - end position of text being replaced
  = char* s - replacement string.
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
> Global Function: TextCut ;
  $ BooleanTextCut (PTextWindow*)
> Purpose:
  | This function removes the current selection of a text window and puts it into the clipboard.  The text insertion point is set to be the start of removed text.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success
> Parameters:
  = PTextWindow* w - Text window whose current selection is to be cut.
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
> Global Function: TextCopy ;
  $ BooleanTextCopy (PTextWindow*)
> Purpose:
  | This function copies the current text selection onto the clipboard.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success.
> Parameters:
  = PTextWindow* w - Text window whose current selection is to be copied.
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
> Global Function: TextPaste ;
  $ BooleanTextPaste (PTextWindow*)
> Purpose:
  | This function puts the contents of the clipboard at the location of the current selection.  The current selection is then set to be the start of the pasted text.  This returns FALSE if the clipboard is empty.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success
> Parameters:
  = PTextWindow* w - Text window whose current selection is to be pasted over.
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
> Global Function: TextRemove ;
  $ BooleanTextRemove (PTextWindow*)
> Purpose:
  | This function removes the current selection of a window w.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success.
> Parameters:
  = PTextWindow* w - Text window whose current selection will be removed
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
> Global Function: getSelection ;
  $ BNRP_BooleangetSelection (BNRP_TCB*)
> Purpose:
  | This primitive gets the current selection of a text window.  The first arguement is the text window id, and the second is unified with the symbol representing the current text selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getSelectCAbs ;
  $ BNRP_BooleangetSelectCAbs (BNRP_TCB*)
> Purpose:
  | This primitive gets the position of the current selection relative to the number of characters from the start of the text.  The first arguement is the text window id, and the second is unified with the number of characters from the start of the file that the current selection starts at.  The third arguement is unified with the number of characters from the start of the file that the current selection ends at.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setCursorPosition ;
  $ BNRP_BooleansetCursorPosition (BNRP_TCB*)
> Purpose:
  | This primitive sets the cursor position to be a given number of characters from the start of the file.  The first arguement is the text window id, and the second is the number of characters from the start of the file to set the cursor position.  If the window id given is the window in focus, then the current selection is set to be the new cursor position.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setSelectCAbs ;
  $ BNRP_BooleansetSelectCAbs (BNRP_TCB*)
> Purpose:
  | This primitive sets the current selection to be the characters between two positions.  The first arguement is the text window id, the second is the start position from the start of the text, and the third is the end position relative to the end of the text.  The positioning is the number of characters from the start or end of the selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setSelectLAbs ;
  $ BNRP_BooleansetSelectLAbs (BNRP_TCB*)
> Purpose:
  | This primitive sets the current selection to be the characters between two positions.  The first arguement is the text window id, the second is the start position from the start of the text, and the third is the end position relative to the end of the text.  The positioning is the number of lines from the start or end of the text.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setSelectLRel ;
  $ BNRP_BooleansetSelectLRel (BNRP_TCB*)
> Purpose:
  | This primitive sets the current selection to be the characters between two line positions.  The first arguement is the text window id, the second is the start position from the start of the current selection, and the third is the end position relative to the end of the current selection.  The positioning is the number of lines from the start or end of the selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setSelectCRel ;
  $ BNRP_BooleansetSelectCRel (BNRP_TCB*)
> Purpose:
  | This primitive sets the current selection to be the characters between two positions.  The first arguement is the text window id, the second is the start position from the start of the current selection, and the third is the end position relative to the end of the current selection.  The positioning is the number of characters from the start or end of the selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setSelection ;
  $ BNRP_BooleansetSelection (BNRP_TCB*)
> Purpose:
  | This primitive sets the current selection to a given symbol.  The first arguement is the text window id, and the second is the symbol to set the current selection to.  The text is searched from the start of the current text selection to the end of the file and back around to the start if the scan direction is set to "forward", other wise it is searched from the end of the current selection to the start of the file and through the end of the file to the end of the selection.  As soon as the symbol is found, it sets the new selection to be the found expression.  The current selection ignored if it is the same as the symbol passed in while searching. 
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getCsize ;
  $ BNRP_BooleangetCsize (BNRP_TCB*)
> Purpose:
  | This primitive returns the number of characters in the contents of a text window.  The first arguement is the text window id, and the second is unified with the number of characters.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getLsize ;
  $ BNRP_BooleangetLsize (BNRP_TCB*)
> Purpose:
  | This primitive gets the number of lines that the contents of a text window uses.  The first arguement is the text window id, and the second is unified with the number of lines the text uses.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getSelectLAbs ;
  $ BNRP_BooleangetSelectLAbs (BNRP_TCB*)
> Purpose:
  | This primitive gets the number of text lines that occur before the current text selection and the number of lines that the current text selection uses.  It takes three arguements, the first is the text window id, and the second is unified with the number of text lines before the text selection and the third is unified with the number of text lines that the current selection uses.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: doEditAction ;
  $ BNRP_BooleandoEditAction (BNRP_TCB*)
> Purpose:
  | This primitive performs an edit action on the current text selection.  The first arguement is the id of the text window and the second is a symbol with a value of: "cut", "copy", "paste", or "clear".  A cut request will remove the current selection and put it into the clipboard.  A copy request will copy the current selection and put it into the clipboard.  A paste request will replace the current selection with the clipboard contents.  Finally, a clear operation will delete the current selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: contentsOfPipe ;
  $ char*contentsOfPipe (ioProc, long int)
> Purpose:
  | This function returns the contents of 'fileP' using 'proc' to do perform the READCHAR I/O directive until there aren't any more characters to be read from 'fileP'.
> Calling Context:
  | 
> Return Value:
  | char* - contents of 'fileP'.  Must be freed when no longer in use.
> Parameters:
  = ioProc proc - I/O procedure to do READCHAR's from 'fileP'
  = long int fileP - Some type of file pointer that indicates where to read the text from.
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
> Global Function: doInsert ;
  $ BNRP_BooleandoInsert (BNRP_TCB*)
> Purpose:
  | This primitive inserts a given piece of text at the beginning of the current text selection.  The first arguement is the text window id, and the second is either a symbol or a list.  If it is a symbol, then it is inserted before the current selection.  If it is a list, then the first list item is a file pointer and the second is the procedure used to read what the file pointer points at.  The item read is inserted before the current selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: doReplace ;
  $ BNRP_BooleandoReplace (BNRP_TCB*)
> Purpose:
  | This primitive replaces the current selection with a given piece of text.  The first arguement is the id of the text window and the second arguement is either a list or a symbol.  If it is a symbol, then the current selection is replaced with that.  If it is a list, then the first list item is a file pointer and the second is the procedure used to read what the file pointer points at.  The item read is used to replace the current selection.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getScanDirection ;
  $ BNRP_BooleangetScanDirection (BNRP_TCB*)
> Purpose:
  | This primitive gets the current scanning direction for searches for a given text window.  The first arguement is the text window id and the second is unified with either the symbol "forward" or "backward".
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getCaseSense ;
  $ BNRP_BooleangetCaseSense (BNRP_TCB*)
> Purpose:
  | This primitive gets the current case sensitivity of searches for a given text window.  The first arguement is the text window id and the second is unified with either the symbol "yes" or "no".
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setCaseSense ;
  $ BNRP_BooleansetCaseSense (BNRP_TCB*)
> Purpose:
  | This primitive sets the case sensitivity of searches for a text window.  The first arguement is the window id of the text window, while the second is either the symbol "yes" or "no".
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setScanDirection ;
  $ BNRP_BooleansetScanDirection (BNRP_TCB*)
> Purpose:
  | This primitive sets the text search direction of a text window to the direction indicated.  The first arguement is the text window id and the second is either the symbol "forward" or "backward".
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: commonGetTextSize ;
  $ BNRP_BooleancommonGetTextSize (BNRP_TCB*, FontInfo*)
> Purpose:
  | This function unifies the second arguement of the tcb with the font size stored in 'fontInfo'.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = FontInfo* fontInfo - FontInfo entry to extract font size information from
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
> Global Function: commonGetTextFont ;
  $ BNRP_BooleancommonGetTextFont (BNRP_TCB*, FontInfo*)
> Purpose:
  | This function unifies the second arguement of the tcb with the font name stored in 'fontInfo'.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = FontInfo* fontInfo - FontInfo entry to extract font name information from
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
> Global Function: getTextSize ;
  $ BNRP_BooleangetTextSize (BNRP_TCB*)
> Purpose:
  | This primitive gets the size of the font currently being used in a text window.  The first arguement is the text window ID and the second gets unified with the size of the font in points.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getTextWidth ;
  $ BNRP_BooleangetTextWidth (BNRP_TCB*)
> Purpose:
  | This primitive queries the width in pixels of a given piece of text.  The first arguement is the text window id, the second is the symbol term whose width is to be found, and the third is unified with the width of the text.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getTextFont ;
  $ BNRP_BooleangetTextFont (BNRP_TCB*)
> Purpose:
  | This primitive gets the name f the font currently being used in a text window.  The first arguement is the text window ID and the second gets unified with the name of the font being used.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: findCachedFont ;
  $ XFontStruct*findCachedFont (FontInfo*)
> Purpose:
  | This function returns the font associated with 'info' from the cache.
> Calling Context:
  | 
> Return Value:
  | XFontStruct* - cahced font.  NULL if it can't be found
> Parameters:
  = FontInfo* info - FontInfo of the font to be found in the cache.
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
> Global Function: cachedFont ;
  $ BooleancachedFont (XFontStruct*)
> Purpose:
  | This determines if the font 'font' is in the cache or not.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE if 'font' is in the cache
> Parameters:
  = XFontStruct* font - font to be found in cache.
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
> Global Function: cacheFont ;
  $ voidcacheFont (FontInfo*, XFontStruct*)
> Purpose:
  | This puts 'info' and 'font' into the cache if it isn't already there and if there is enough room in the cache for it.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = FontInfo* info - FontInfo to be cached associated with 'font'
  = XFontStruct* font - font associated with 'info'
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
> Global Function: GetFontInfo ;
  $ voidGetFontInfo (XFontStruct*, FontInfo*)
> Purpose:
  | Given a font 'font' it retrieves the FontInfo properties and puts them into 'info'
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = XFontStruct* font - font
  = FontInfo* info - information about 'font' filled in by function.
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
> Global Function: getFontBySpec ;
  $ XFontStruct*getFontBySpec (char*)
> Purpose:
  | This function retrieves the font associated with the font specification 'fontSpec'.  It first lists all the fonts that match the specification, and then tries loading them one by one.  It returns the first one that it successfully loads.
> Calling Context:
  | 
> Return Value:
  | XFontStruct* - font associated with 'fontSpec'
> Parameters:
  = char* fontSpec - font specification.
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
> Global Function: getFont ;
  $ XFontStruct*getFont (FontInfo*, Boolean)
> Purpose:
  | This function gets the XFontStruct associated with the FontInfo structure 'info'.  If 'exact' is TRUE, then an exact match is searched for, otherwise, the closest matching font is found if the exact font isn't there.  It does this by loading the font from the font server and checking the attributes. If a match isn't found it tries to load an oblique slant font if the slant desired is italic.  If this fails, then if an exact match was desired NULL is returned.
  | If an exact match isn't specified, Then we first adjust the size, then the slant and finally the weight.  When a match is found (exact or non-exact) the font is first cached and then returned.
> Calling Context:
  | 
> Return Value:
  | XFontStruct* - font retrieved
> Parameters:
  = FontInfo* info - font to be retrieved
  = Boolean exact - TRUE if an exact match is desired.
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
> Global Function: setTextSize ;
  $ BNRP_BooleansetTextSize (BNRP_TCB*)
> Purpose:
  | This primitive changes the size ofthe font that is currently being used by a text window.  The first arguement is the window ID of the text window, and the second is the new size (integer) to set the size to.  If the font of that size can't be found, then FALSE is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setTextFont ;
  $ BNRP_BooleansetTextFont (BNRP_TCB*)
> Purpose:
  | This primitive changes the font of a text window, but keeps the same text face and size.  The first arguement is the window id of the text window whose font is to be changed and the second arguement is the name of the new font to be used.  Ifthe font can't be found, then FALSE is returned
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: commonGetTextFace ;
  $ BNRP_BooleancommonGetTextFace (BNRP_TCB*, FontInfo*)
> Purpose:
  | This function unifies a list containing the weight and slant of the font 'fontInfo' with the second arguement of 'tcb'
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = FontInfo* fontInfo - fontInfo structure whose face is to be retrieved.
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
> Global Function: getTextFace ;
  $ BNRP_BooleangetTextFace (BNRP_TCB*)
> Purpose:
  | This primitive gets the current text face being used by a certain text window.  The first arguement is the window id of the text window, and the second is unified with a list containing the current weight and slant of the font.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: setTextFace ;
  $ BNRP_BooleansetTextFace (BNRP_TCB*)
> Purpose:
  | This primitive sets the text face ofthe font that is currently being used ina a window.  The first arguement is an ID (integer) of a text window and the second is a list containing the weight and the slant of the new text face.  If any of the members of this list is a variable or tail variable, TRUE is returned.  If a font with the specified face can't be found, then FALSE is returned, otherwise the text face of the text window is set to what is specified.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getFamily ;
  $ char*getFamily (char*)
> Purpose:
  | This function returns the font family that is embedded in the font specification 'font'
> Calling Context:
  | 
> Return Value:
  | char* - font family associated with the font specification 'font'
> Parameters:
  = char* font - full font specification
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
> Global Function: listFonts ;
  $ BNRP_BooleanlistFonts (BNRP_TCB*)
> Purpose:
  | This primitive returns a list of all of the font families that are available from the font server.  It's single arguement gets unified with this list.  A maximum of MAX_FAMILIES font families will be returned
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getSize ;
  $ intgetSize (char*)
> Purpose:
  | This function returns the size that is embedded in the font specification string 'font'.  'font' must be the full form (no truncations of empty placeholders).
> Calling Context:
  | 
> Return Value:
  | int - size of the font 'font'
> Parameters:
  = char* font - font specification string
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
> Global Function: listSizes ;
  $ BNRP_BooleanlistSizes (BNRP_TCB*)
> Purpose:
  | This primitive returns a list of the font sizes available for a given font.  The first arguement is the name of the font and the second is the list of sizes.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: fontInfo ;
  $ BNRP_BooleanfontInfo (BNRP_TCB*)
> Purpose:
  | This primitive gets some font information for a given font.  The first three arguements indicate which font to query.  The first arguement is the font name, the second is the size, and the third is a list that contains the weight and slant.  The next 5 arguements get unified with the ascent, descent, leading. maximum width and average width.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: eqStrN ;
  $ inteqStrN (char*, char*, int)
> Purpose:
  | This function determines if two strings are equal up to a length 'n'.  Neither string needs to be NULL terminated.
> Calling Context:
  | 
> Return Value:
  | int - TRUE if they are the same otherwise FALSE
> Parameters:
  = char* s1 - first string to compare
  = char* s2 - second string to compare
  = int n - number of characters to compare
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
> Global Function: handleWindowIO ;
  $ BNRP_BooleanhandleWindowIO (va_alist)
> Purpose:
  | This function handles all I/O on text windows.  The first arguement is which I/O directive to perform and the second in the PTextWindow to perform it on.  The rest of the arguements are dependant on the I/O directive.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = va_alist  - list of arguements to be processed by the I/O directive
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
> Data Item: sys_font
  $ XFontStruct* sys_font
> Purpose:
  | This is the default system font.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: appl_font
  $ XFontStruct* appl_font
> Purpose:
  | This is the default application font
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: sys_font_info
  $ FontInfo sys_font_info
> Purpose:
  | This is the default system font information.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: appl_font_info
  $ FontInfo appl_font_info
> Purpose:
  | This is the default application font information.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: fontCache
  $ font_cache[FONT_CACHE_SIZE] fontCache
> Purpose:
  | This is a cache of the fonts that have queried.  Used to lessen the amount of times we have to access the font server.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: numCachedFonts
  $ int numCachedFonts
> Purpose:
  | Number of fonts that are currently cached.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: XA_CLIPBOARD
  $ Atom XA_CLIPBOARD
> Purpose:
  | This is a Motif atom used as the identifier for the clipboard.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: XA_TIMESTAMP
  $ Atom XA_TIMESTAMP
> Purpose:
  | This is a Motif atom used as the timestamp of the last scrap event
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: ScrapReqOutstanding
  $ Boolean ScrapReqOutstanding
> Purpose:
  | This is true if a scrap request is still pending.  Used to prevent congestion accessing the scrap contents.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: LastScrapChangedTime
  $ Time LastScrapChangedTime
> Purpose:
  | This is the time that the last change to the scrap was made.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_STRING_SIZE
  $ #define MAX_STRING_SIZE
> Purpose:
  | The maximum size of a string to be removed from a pipe, or the maximum length of a NONSTRING to be outputed to a text window in handleWindowIO().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_CLIPBOARD_TRIES
  $ #define MAX_CLIPBOARD_TRIES
> Purpose:
  | This is the maximum number of times a Motif clipboard operation can be attempted.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FONT_CACHE_SIZE
  $ #define FONT_CACHE_SIZE
> Purpose:
  | This is the maximum number of fonts that can be cached.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_FAMILIES
  $ #define MAX_FAMILIES
> Purpose:
  | This is the maximum number of font families that can be listed with the listFonts primitive
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: TOOLONG
  $ #define TOOLONG
> Purpose:
  | This is the error generated when too many items are printed out in handleWindowIO() with the OUTPUTSTRING directive.  If this error occurs a jump is made to the BNRP_finishWrite().
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | FontInfo
  $ struct FontInfo
> Purpose:
  | This structure holds the basic information about a font.  Primarily used in the fontCache structure
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = char* name - name of the font
  = int size - size of the font in pixels
  = int weight - weight of the font (normal or bold)
  = int slant - slant of the font (normal or italic)
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | FontInfo
  $ typedef void FontInfo
> Purpose:
  | This is the type definition for the FontInfo structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | ioProc
  $ typedef BNRP_Boolean(*)() ioProc
> Purpose:
  | This is the type definition for a function that performs all of the I/O directives.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ProText
  $ #define _H_ProText
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_FONT_SIZE_DIFF
  $ #define MAX_FONT_SIZE_DIFF
> Purpose:
  | This is the maximum font size difference between a desired font and the one that can be loaded.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NORMAL_WEIGHT
  $ #define NORMAL_WEIGHT
> Purpose:
  | Indicates a normal weight (not bold) font in the FontInfo structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BOLD_WEIGHT
  $ #define BOLD_WEIGHT
> Purpose:
  | Indicates a bold font in the FontInfo structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NORMAL_SLANT
  $ #define NORMAL_SLANT
> Purpose:
  | Indicates a normal slant (non-italic) font in the FontInfo structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ITALIC_SLANT
  $ #define ITALIC_SLANT
> Purpose:
  | Indicates a italic font in the FontInfo structure.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NONSTRING
  $ #define NONSTRING
> Purpose:
  | Indicates that a non-string is to be written for an OUTPUTSTRING I/O directive.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: STRING
  $ #define STRING
> Purpose:
  | Indicates that a string is to be written for an OUTPUTSTRING I/O directive.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OUTPUTSTRING
  $ #define OUTPUTSTRING
> Purpose:
  | I/O directive to write a string (or chracter) to the text window
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: READCHAR
  $ #define READCHAR
> Purpose:
  | I/O directive to read a character from the current position in the text window
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: RETURNCHAR
  $ #define RETURNCHAR
> Purpose:
  | I/O directive to handle a return character in a text window.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: OPENFILE
  $ #define OPENFILE
> Purpose:
  | I/O directive to open the contents of the text window (This is disabled)
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CLOSEFILE
  $ #define CLOSEFILE
> Purpose:  | 
  | I/O directive to close the contents of the text window (This is disabled).
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GETPOSITION
  $ #define GETPOSITION
> Purpose:
  | I/O directive to get the current cursor position in the text window.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SETPOSITION
  $ #define SETPOSITION
> Purpose:
  | I/O directive to set the current position in the text window
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SETEOF
  $ #define SETEOF
> Purpose:
  | I/O directive to set EOF at the current location in the text window.  Truncates the contents.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: FLUSHFILE
  $ #define FLUSHFILE
> Purpose:
  | I/O directive for flushing the contents of a text window 
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: GETERROR
  $ #define GETERROR
> Purpose:
  | I/O directive for getting the last I/O error associated with a text window
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: window_io_proc ;
  $ BNRP_Booleanwindow_io_proc (BNRP_TCB*)
> Purpose:
  | This primitive unifies the single arguement with the id of the function used to handle window I/O directives (handleWindowIO).
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: FindValidWidgetId ;
  $ WidgetFindValidWidgetId ()
> Purpose:
  | This function returns a valid widget ID for the application.  It seaches through the windowtab entries for a window that is in use and returns it's app_shell widget
> Calling Context:
  | 
> Return Value:
  | Widget - valid widget for the application.
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
> Global Function: FindValidWindowId ;
  $ WindowFindValidWindowId ()
> Purpose:
  | This function returns a valid window id for the application.  It first searches for a valid widget for the application and uses it to find a valid window.
> Calling Context:
  | 
> Return Value:
  | Window - window widget associated with the applciation.
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
> Global Function: textToScrap ;
  $ BNRP_BooleantextToScrap (BNRP_TCB*)
> Purpose:
  | This primitive copies the symbol in the first arguement and puts it into the clipboard.  It makes MAX_CLIPBOARD_TRIES on each clipboard operation or returns FALSE.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: scrapToText ;
  $ BNRP_BooleanscrapToText (BNRP_TCB*)
> Purpose:
  | This primitive gets a string from the clipboard.  The single arguement gets unified with the clipboard contents if there is an object of type "TEXT" in the clipboard.  It makes MAX_CLIPBOARD_TRIES on each clipboard operation or returns FALSE.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: scrapContents ;
  $ BNRP_BooleanscrapContents (BNRP_TCB*)
> Purpose:
  | This primitive gets the type of the object being held in the clipboard.  The first arguement is unified with the type which is either "TEXT" or "PICT".  It makes MAX_CLIPBOARD_TRIES on each clipboard operation or returns FALSE.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: pictToScrap ;
  $ BNRP_BooleanpictToScrap (BNRP_TCB*)
> Purpose:
  | This primitive transfers a picture to the clipboard.  It takes a single arguement which is a list containing the file pointer to read the picture from, and the ID (integer) of the I/O handler that works with the given file pointer (must be able to handle READCHAR).  It makes at most MAX_CLIPBOARD_TRIES attempts at ech clipboard operation.  If more than MAX_CLIPBOARD_TRIES are used then FALSE is returned.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: scrapToPict ;
  $ BNRP_BooleanscrapToPict (BNRP_TCB*)
> Purpose:
  | This primitive loads a picture from the clipboard and reads it into a file pointer.  This primitive takes a single arguemnt which is a list containing the file pointer to load the picture into and an integer indicating which I/O handler to use with the file pointer given (must be able to handle OUTPUTSTRING).  The primitive makes at most MAX_CLIPBOARD attempts on any clipboard operation.  If it doesn't succeed, then FALSE is returned.  FALSE is rreturned if there isn't a picture in the clipboard to load.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: charAt ;
  $ BNRP_BooleancharAt (BNRP_TCB*)
> Purpose:
  | This function gets the position of a character relative to X and Y coordinates in the window.  The first arguement is the text window id, the second is the X coordinate relative to the window, the third is the y coordinate relative to the window.  The fourth arguement gets unified with the position of the character relative to the number of characters from the start of the window text contents.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: getCharAt ;
  $ BNRP_BooleangetCharAt (BNRP_TCB*)
> Purpose:
  | This primitive gets the character at a given position in a text window.  It has three arguements. The first is the text window id, the second is the character positionrelative to the start of the file, and the third is unified with the character at the position given in the second arguement. 
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
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
> Global Function: BindPTextPrimitives ;
  $ voidBindPTextPrimitives ()
> Purpose:
  | This function binds in the X text handling primitives and registers the BNRP_pict format with the clipboard.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
> Global Function: SearchString ;
  $ XmTextPositionSearchString (char*, XmTextPosition, XmTextPosition, char*, int, Boolean)
> Purpose:
  | This function searches for an item 'find' of length 'findLen' in the piece of text 'text' starting at position 'start' and of length 'len'.  It uses the BoyerStrother search algorithm.  If caseSense is TRUE, then do a case sensitive search.  If 'len' is negative then a backwards search is performed.
> Calling Context:
  | 
> Return Value:
  | XmTextPosition - The start position of the found text or 'start' + 'len' +- 1 if not found (+1 if searching forwards, -1 if searching backwards)
> Parameters:
  = char* text - text to be seacrhed
  = XmTextPosition start - postion in 'text' to start search in
  = XmTextPosition len - how many characters in 'text' to search through
  = char* find - string to be found in 'text'
  = int findLen - length of string to be found
  = Boolean caseSense - TRUE if doing a case sensitive search.
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
> Global Function: ScrapContentsCB ;
  $ voidScrapContentsCB (Widget, XtPointer, Atom*, Atom*, Time*, unsigned long*, int*)
> Purpose:
  | This is the event callback that is used when scrap is queried.  It sets up the scrapchanged Prolog event if the scrap has changed.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = XtPointer data
  = Atom* selection
  = Atom* type - type of the item in the scrap
  = Time* value - time of the last scrap change
  = unsigned long* length - length ofthe item in the scrap
  = int* format - format of the item in the scrap
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
> Global Function: PollScrapContents ;
  $ voidPollScrapContents ()
> Purpose:
  | Retrieves the current scrap contents to see if it has changed.  Only one request may be outstanding at a time to prevent congestion.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
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
