#if 0
----------------------------------------------------------------------
> Global Function: bit_hash ;
  $ intbit_hash (char*)
> Purpose:
  | This is a hash function that returns the bitmap table position for a previously stored name or returns the appropriate spot to place a new name.
> Calling Context:
  | 
> Return Value:
  | int - position in table to use (or where bitmap already resides). -1 if no more space in the table.
> Parameters:
  = char* Bitmap_Name - Name of the bitmap to be hashed.
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
> Global Function: ReadBitmapFromFile ;
  $ intReadBitmapFromFile (char*, Pixmap*, unsigned int*, unsigned int*, Drawable)
> Purpose:
  | This function reads a bitmap file from either the directory specified in bitmapSearchPath, the local bitmap directory LOCAL_BITPATH or from the system default bitmap directory BITPATH.  Returns the XReadBitmapFile result code.
> Calling Context:
  | 
> Return Value:
  | int - result of XReadBitmapFile()
> Parameters:
  = char* file_in - name of the bitmap
  = Pixmap* bitmap - value ofthe bitmap filled in bythe function
  = unsigned int* width - width of the bitmap filled in by function
  = unsigned int* height - height of the bitmap filled in by system
  = Drawable draw - drawable widget
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
> Global Function: get_bitmap ;
  $ intget_bitmap (char*, Pixmap*, Drawable)
> Purpose:
  | This function retrieves a specified bitmap.  If it is present in the bitmap table, it is loaded from there, otherwise it is loaded from disk, inserted into the table, and returned.  Returns the hash position of the bitmap, or -1 if the bitmap was loaded but not cached or -2 if the bitmap could not be loaded.
> Calling Context:
  | 
> Return Value:
  | int
> Parameters:
  = char* Bitmap_Name - name of the bitmap
  = Pixmap* bitmap - pixmap ofthe loaded bitmap filled in by function
  = Drawable draw - drawable widget
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
> Global Function: get_symbol_bitmap_entry ;
  $ intget_symbol_bitmap_entry (char*, Drawable)
> Purpose:
  | Returns the bitmap table index to one of the standard Prolog patterns.  Returns NotPrologPattern if the input symbol is not a standard Prolog pattern.  If the standard Prolog pattern specified has not been loaded into the bitmap table, then it's loaded using 'draw'.
> Calling Context:
  | 
> Return Value:
  | int - bitmap table index of 'Symbol' or NotPrologPattern or -1 on failure.
> Parameters:
  = char* Symbol - name of the standard Prolog bitmap to find
  = Drawable draw - drawable widget
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
> Global Function: SetClipRegion ;
  $ voidSetClipRegion (GrafContextPtr)
> Purpose:
  | This function sets the clipping region by intersecting the update region (if it exists and is valid) with the existing clipping region.  Updates the clip mask in the specified graphics context with this region.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = GrafContextPtr gptr - XXXXX_G_PAR
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
> Global Function: StartGrafUpdate ;
  $ voidStartGrafUpdate (PGrafWindow*)
> Purpose:
  | This function starts an update operation on the current graf window.  This function is called when a Prolog update event is generated.  The update region is set in the graf window data structure where it is used as a clipping region.  Sets the valid_update_region flag to TRUE and sets the update region to be the exposed region and resets the exposed region of the graphics context.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PGrafWindow* window - Graphics window to start the update operation on.
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
> Global Function: ModifyGrafUpdate ;
  $ voidModifyGrafUpdate (PGrafWindow*, XRectangle*)
> Purpose:
  | This function modifies the update region on the window as a result of calling validrect.  Validrect is only valid when an update operation is in progress.  Validrect does the error checking.  it removes the region 'rectangle' from the update_region of a graphics context.  Sets the clip region to be the update region.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PGrafWindow* window - graphics window whose update region is to be modified
  = XRectangle* rectangle - area inside of update region to be removed from the update region.
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
> Global Function: TerminateGrafUpdate ;
  $ voidTerminateGrafUpdate ()
> Purpose:
  | This function terminates the update operation on all windows with update regions.  The update operation starts when an update event is returned to Prolog.  The update region is set in the graf window data structure where it is used by all dograf operations.  It is removed the next time userevent is called.
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
> Global Function: get_pixel_by_name ;
  $ unsigned longget_pixel_by_name (char*)
> Purpose:
  | Gets the pixel number associated with the colour name 'colorname' (ie. "black", "cyan", etc).  If the color isn't already allocated, then an attempt to allocate it is made.  If this fails, then the pixel value of black or white is returned depending on the darkness of 'colorname'.
> Calling Context:
  | 
> Return Value:
  | unsigned long - pixel value of the colour 'colorname'.
> Parameters:
  = char* colorname - name ofthe colour whose pixel value is to be found.
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
> Global Function: AllocCustomColor ;
  $ unsigned longAllocCustomColor (int)
> Purpose:
  | This function alloates a custom colour given by the user.  'colorid' is of the form 'xxRRGGBB'.  (RR,GG,BB represent the red, green, and blue components of the colour, where 00 is the darkest and FF is the brightest.  The x's represent the MSB of 'colorid' which is ignored.  if the given colour can't be allocated in the pixmap, then either white or black is returned depending on how dark the given colour was.
> Calling Context:
  | 
> Return Value:
  | unsigned long - pixel value of the color allocated.
> Parameters:
  = int colorid - color to allocate
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
> Global Function: InitGrafWindow ;
  $ voidInitGrafWindow (PGrafWindow*)
> Purpose:
  | This function initializes the GrafContextRec data structure upon the opening of a graphics window.  This includes the update and expose regions and the font information.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PGrafWindow* w - Graphics window being opened.
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
> Global Function: PrologColors ;
  $ voidPrologColors (PGrafWindow*)
> Purpose:
  | This function performs additional initialization functions upon the opening of a graphics window.  The graphics window must be visible when this function is called.  This sets up the initialPixmap variable, created a graphics context for the window and sets it up, and sets up the initial clip region (entire window).
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PGrafWindow* w - graphics window being initialized.
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
> Global Function: TerminateGrafWindow ;
  $ voidTerminateGrafWindow (PGrafWindow*)
> Purpose:
  | This function is called upon the closure of a graphics window.  It deallocates the expose region, update region, graphics context, foreground colour name, background colour name, the font name and the graphics context pointer of 'w'
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PGrafWindow* w - Graphics window to terminate.
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
> Global Function: clone_GC ;
  $ BNRP_Booleanclone_GC (BNRP_TCB*)
> Purpose:
  | This primitive gets a clone of a graphics context.  It has two arguements.  The first is the graphics context id of the context to copy, and the second is unified with the graphics context id of the copy.  The new context is chained to the old context.
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
> Global Function: clone_of_GC ;
  $ GrafContextPtrclone_of_GC (GrafContextPtr)
> Purpose:
  | This function makes an exact copy of src_gcptr and returns it.  The new graphics context's previous context is set to be 'src_gcptr.  The returned context is in allocated memory.  All internal structures of 'src_gcptr' that have been allocated are copied into allocated memory in the new graphics context.
> Calling Context:
  | 
> Return Value:
  | GrafContextPtr - copy of 'src_gcptr'
> Parameters:
  = GrafContextPtr src_gcptr - graphics context to make a copy of.
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
> Global Function: SetFunction ;
  $ voidSetFunction (GC, int)
> Purpose:
  | This function sets up the bitwise logical operation in a graphics context.  Used for inversion pen modes and such.  Some values for function are: GXcopy, GXclear, and GXinvert.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = GC gc - graphics context whose bitwise logical operation is to be set to 'function'.
  = int function - bitwise operation to set up
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
> Global Function: switch_fill_mode ;
  $ voidswitch_fill_mode (GrafContextPtr)
> Purpose:
  | This function sets the stipple being used for a graphics context depending on the fill mode being used.  This function is used whenever the fill mode is changed.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = GrafContextPtr gptr - graphics context pointer
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
> Global Function: switch_pen_mode ;
  $ voidswitch_pen_mode (GrafContextPtr)
> Purpose:
  | This function sets up the current_function parameter of 'gptr' depending on the pen mode value.  This is called whenever the pen mode changes.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = GrafContextPtr gptr - graphics context pointer
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
> Global Function: free_GC ;
  $ BNRP_Booleanfree_GC (BNRP_TCB*)
> Purpose:
  | This primitive removes a graphics context.  It's single arguement is the graphics context id of the context to be removed.  The values stored in the previous graphics context to the current one are set up.  These values include: font, foreground colour, background colour, pen size, clip region, fill mode and pen mode.  The space allocated with the graphics context is freed.
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
> Global Function: multi_lineabs ;
  $ BNRP_Booleanmulti_lineabs (BNRP_TCB*)
> Purpose:
  | This primitive draws multiple line connected line segments.  The first arguement is the graphics context id, and the second is a list of points that represent the joining point for the lines.  it's of the form: [X1,Y1,X2,Y2,...]
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
> Global Function: polygon ;
  $ BNRP_Booleanpolygon (BNRP_TCB*)
> Purpose:
  | This primitive draws an n sided polygon in a graphics context.  It has two arguements.  The first is the graphics context id, and the second is the list of vertices of the polygon.  The list is of the format {X1,Y1,X2,Y2,...].  The last point in the list must be the first point in the list.  The polygon is filled using the current fill pattern.
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
> Global Function: forecolor ;
  $ BNRP_Booleanforecolor (BNRP_TCB*)
> Purpose:
  | This primitive sets the foregorund colour for a graphics context.  The first arguement is a graphics context id, and the second is either the name of the colour, or an integer value representing the colour.  This is described in full in the Graphics Descriptors chapter of the reference manual under forecolor().
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
> Global Function: backcolor ;
  $ BNRP_Booleanbackcolor (BNRP_TCB*)
> Purpose:
  | This primitive sets the backgorund colour for a graphics context.  The first arguement is a graphics context id, and the second is either the name of the colour, or an integer value representing the colour.  This is described in full in the Graphics Descriptors chapter of the reference manual under backcolor().
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
> Global Function: penmode ;
  $ BNRP_Booleanpenmode (BNRP_TCB*)
> Purpose:
  | This primitive sets the pen mode for a graphics context.  The first arguement is the graphics context id and the second is the pen mode which is one of the symbols:
  | - copy
  | - notcopy
  | - or
  | - notor
  | - xor
  | - notxor
  | - clear
  | - notclear
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
> Global Function: pensize ;
  $ BNRP_Booleanpensize (BNRP_TCB*)
> Purpose:
  | This primitive sets the pen width for a graphics context.  The first arguement is the graphics context id and the second is the new pen width (integer).
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
> Global Function: get_pattern_index ;
  $ intget_pattern_index (BNRP_TCB*, Drawable)
> Purpose:
  | Returns an index into the bitmap table, using the same tcb as penpat(), backpat(), and userpat().  Accepts wither a pattern name, or resource and id description.  
> Calling Context:
  | 
> Return Value:
  | int - index into bitmap_table for the pattern or -1 on failure
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = Drawable draw - drawable widget of the graphics context being changed.
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
> Global Function: penpat ;
  $ BNRP_Booleanpenpat (BNRP_TCB*)
> Purpose:
  | This primitive sets the pen pattern to be used.  It has either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, the second is the name of the pattern to use (symbol).  If it has three arguements, then the second is the resource number and the third is the id of a pattern to be loaded from disk.
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
> Global Function: backpat ;
  $ BNRP_Booleanbackpat (BNRP_TCB*)
> Purpose:
  | This primitive sets the background pattern to be used.  It has either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, the second is the name of the pattern to use (symbol).  If it has three arguements, then the second is the resource number and the third is the id of a pattern to be loaded from disk.
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
> Global Function: userpat ;
  $ BNRP_Booleanuserpat (BNRP_TCB*)
> Purpose:
  | This primitive sets the user pattern to be used.  It has either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, the second is the name of the pattern to use (symbol).  If it has three arguements, then the second is the resource number and the third is the id of a pattern to be loaded from disk.
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
> Global Function: fillpat ;
  $ BNRP_Booleanfillpat (BNRP_TCB*)
> Purpose:
  | This primitive sets the fill pattern to be used by a graphics context.  The first arguement is the grephics context id, and the second is the fill pattern to use which is one of the symbols:
  | - hollow
  | - pentype
  | - usertype
  | - clear
  | - invert
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
> Global Function: inqforecolor ;
  $ BNRP_Booleaninqforecolor (BNRP_TCB*)
> Purpose:
  | This primitive returns the name of the colour being used in the foreground for a graphics context.  The first arguement is the graphics context id, and the second is unified with the foreground colour name as described in the reference manual in the Graphics Descriptors chapter for forecolor(_Color).
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
> Global Function: inqbackcolor ;
  $ BNRP_Booleaninqbackcolor (BNRP_TCB*)
> Purpose:
  | This primitive returns the name of the colour being used in the background for a graphics context.  The first arguement is the graphics context id, and the second is unified with the background colour name as described in the reference manual in the Graphics Descriptors chapter for backcolor(_Color).
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
> Global Function: inqpenmode ;
  $ BNRP_Booleaninqpenmode (BNRP_TCB*)
> Purpose:
  | This primitive gets the pen mode being used by a graphics context.  The first argument is the graphics context id, and the second is unified with the pen mode bein used (symbol).  The pen mode is one of the following:
  | - copy
  | - notcopy
  | - or
  | - notor
  | - xor
  | - notxor
  | - clear
  | - notclear
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
> Global Function: inqpensize ;
  $ BNRP_Booleaninqpensize (BNRP_TCB*)
> Purpose:
  | This primitive returns the current pen size being used by a graphics context.  The first arguement is the graphics context id, and the second is unified with the pen size (integer) being used by the graphics context.
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
> Global Function: prolog_symbol ;
  $ char*prolog_symbol (char*)
> Purpose:
  | This function determines if 'Pattern' is one of the standard Prolog patterns.  If it is then the appropriate value from: white, lightgray, gray, darkgray, and black is returned.  Otherwise 'Pattern' is returned
> Calling Context:
  | 
> Return Value:
  | char* - Name of the pattern 'Pattern'
> Parameters:
  = char* Pattern - 'Pattern' to check.
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
> Global Function: parse_bitmap_name ;
  $ BNRP_Booleanparse_bitmap_name (BNRP_TCB*, char*)
> Purpose:
  | This function parses a pattern bitmap name 'Bitmap_Name' and unifies it's name (or resource number an id pair) with the second (and third) arguements of 'tcb'.  'Bitmap_name' is of the form PATX.YY.bit.  If its one of the standard Prolog patterns (white, lightgray, gray, darkgray, black) then the second arguement of 'tcb' is unified with the name of the pattern (eg. "black").  Otherwise the second arguement of 'tcb' is unified with X and the third with YY.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = char* Bitmap_Name - Name of a pattern bitmap
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
> Global Function: inqpenpat ;
  $ BNRP_Booleaninqpenpat (BNRP_TCB*)
> Purpose:
  | This primitive returns the current pen pattern name (symbol).  If the pattern was loaded using resource and index numbers, and is not one of the Prolog standard patterns (such as lightgray) return the resource and index numbers.  This primitive takes either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, then the second is
  | unified with the name of the pen pattern.  If it has three arguements, then the second is unified with the resource number and the third is unified with the id number.
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
> Global Function: inqbackpat ;
  $ BNRP_Booleaninqbackpat (BNRP_TCB*)
> Purpose:
  | This primitive returns the current background pattern name (symbol).  If the pattern was loaded using resource and index numbers, and is not one of the Prolog standard patterns (such as lightgray) return the resource and index numbers.  This primitive takes either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, then the second is unified with the name of the background pattern.  If it has three arguements, then the second is unified with the resource number and the third is unified with the id number.
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
> Global Function: inquserpat ;
  $ BNRP_Booleaninquserpat (BNRP_TCB*)
> Purpose:
  | This primitive returns the current user pattern name (symbol).  If the pattern was loaded using resource and index numbers, and is not one of the Prolog standard patterns (such as lightgray) return the resource and index numbers.  This primitive takes either two or three arguements.  The first arguement is always the graphics context id.  If it has two arguements, then the second is
  | unified with the name of the user pattern.  If it has three arguements, then the second is unified with the resource number and the third is unified with the id number.
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
> Global Function: inqfillpat ;
  $ BNRP_Booleaninqfillpat (BNRP_TCB*)
> Purpose:
  | This primitive gets the current fill pattern being used by a graphics context.  It has two arguements, the first is the graphics context id, and the second is unified with the fill pattern being used (symbol).  The possible fill patterns are:
  | - hollow
  | - pentype
  | - usertype
  | - clear
  | - invert
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
> Global Function: lineabs ;
  $ BNRP_Booleanlineabs (BNRP_TCB*)
> Purpose:
  | This primitive draws a line between two points.  It has 5 arguements.  The first is the graphics context id, the second and third are the x-y coordinates ofthe start of the line, and the other two arguements are the x-y coordinates of the end of the line.
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
> Global Function: rectabs ;
  $ BNRP_Booleanrectabs (BNRP_TCB*)
> Purpose:
  | This primitive draws a rectangle using the coordinates ofthe top left corner and bottom right corner.  The rectangle is filled using the current fill mode.  It has five arguements.  The first is the graphics context id, the second and third represent the x-y coordinates of the top left corner, and the last two represent the x-y coordinates of the bottom right corner.
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
> Global Function: arcabs ;
  $ BNRP_Booleanarcabs (BNRP_TCB*)
> Purpose:
  | This primitive draws an arc inside of a given rectangle (rectangle not drawn) starting at a given angle from the 3:00 position in the rectangle and of a size of the given arc angle.  Th arc is filled with the current fill mode.  This primitive has seven arguement as follows:
  | - graphics context id
  | - x coordinate of left edge of rectangle
  | - y coordinate of top edge of rectangle
  | - x coordinate of right edge of rectangle
  | - y coordinate of bottom edge of rectangle
  | - start angle from the 3:00 position inside of the rectangle
  | - angle of the finished arc
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
> Global Function: ovalabs ;
  $ BNRP_Booleanovalabs (BNRP_TCB*)
> Purpose:
  | This primitive draws a oval using the specified rectangle size (the rectangle is not drawn).  The co-ordinates are relative to the graf window.  It takes 5 arguements.  The first is the graphics context id, the second and third represent the x-y coordinates of the top left corner of the rectangle, and the fourth and fifth arguements are the c-y coordinates of the bottom right corner of the rectangle.  The oval is filled with the given fill mode
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
> Global Function: XmuDrawRoundedRectangle ;
  $ voidXmuDrawRoundedRectangle (Display*, Drawable, GC, int, int, int, int, int, int)
> Purpose:
  | This is an Xmu function.  It's in here to remove the dependency on Xmu.  This function draws a hollow rounded rectangle to the specified graphics context.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Display* dpy - display to draw on
  = Drawable draw - drawable widget
  = GC gc - graphics context to draw in
  = int x - left edge x position of rectangle
  = int y - top edge y position of rectangle
  = int w - width of rectangle
  = int h - height of rectangle
  = int ew - width of oval used to determine how round the corners are
  = int eh - height of oval used to determine how round the corners are
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
> Global Function: XmuFillRoundedRectangle ;
  $ voidXmuFillRoundedRectangle (Display*, Drawable, GC, int, int, int, int, int, int)
> Purpose:
  | This is an Xmu function.  It's in here to remove the dependency on Xmu.  This function draws a filled rounded rectangle to the specified graphics context.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Display* dpy - Display to draw on
  = Drawable draw - drawable widget
  = GC gc - graphics context to draw in
  = int x - left edge x value of rectangle
  = int y - top edge y value of rectangle
  = int w - width of rectangle
  = int h- height of rectangle
  = int ew - width of oval used to determine how round the corners are
  = int eh - height of oval used to determine how round the corners are
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
> Global Function: rrectabs ;
  $ BNRP_Booleanrrectabs (BNRP_TCB*)
> Purpose:
  | This primitive draws a rounded rectangle.  It has 7 arguements.  The first is the graphics context pointer.  The second and third represent the x-y coordinates of the top left corner of the rectangle, and the fourth and fifith are the x-y coordinates of the bottom right corner of the rectangle.  The sizth is the width of the oval and the seventh is the height of the oval  The last two specify how rounded the corners get.  It gets filled using the current fill mode.
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
> Global Function: inqcrectabs ;
  $ BNRP_Booleaninqcrectabs (BNRP_TCB*)
> Purpose:
  | This primitive gets the position of the current clipping rectangle inside of a graphics context.  It has 5 arguements.  The first is the graphics context pointer.  The second and third is unified with the x-y coordinates of the top left corner of the rectangle, and the fourth and fifth are unified with the x-y coordinates of the bottom right corner of the rectangle.  The clipping rectangle is where all subsequent drawing operations will be clipped to.  If there isn't a user specified clipping rectangle (crectabs primitive) then the coordinates of the entire window are returned (which is the default clipping rectangle).
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
> Global Function: crectabs ;
  $ BNRP_Booleancrectabs (BNRP_TCB*)
> Purpose:
  | This primitive sets the user-specified clipping rectangle.  It has 5 arguements.  The first is the graphics context pointer.  The second and third represent the x-y coordinates of the top left corner of the rectangle, and the fourth and fifth are the x-y coordinates of the bottom right corner of the rectangle.  The clipping rectangle is where all subsequent drawing operations will be clipped to.
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
> Global Function: iconabs ;
  $ BNRP_Booleaniconabs (BNRP_TCB*)
> Purpose:
  | This primitive retrieves an icon, scales it to fit in the given rectangle, and draws it as a stipple using the current foreground and background colours.  It takes 6 arguements.  The first is the graphics context id.  The second and third are the x and y co-ordinates of the top left corner of the rectangle to place the icon in.  The fourth and fifth are the x and y co-ordinates of the bottom right corner of the same rectangle.  The sixth arguement is the icon id of the icon to be displayed.  This icon is added to the bitmap table.
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
> Global Function: LosingFocusCB ;
  $ voidLosingFocusCB (Widget, XtPointer, XmTextVerifyPtr)
> Purpose:
  | This is an event callback used when a textbox loses focus.  It sets the textEditState to be false to stop editing and sets the editSelStart and editSelEnd parameters to be the current selection or the insertion position if there isn't a selection.  This function has now been disabled.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = XtPointer client_data
  = XmTextVerifyPtr call_data - XXXXX_G_PAR
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
> Global Function: EditBoxChangedCB ;
  $ voidEditBoxChangedCB (Widget, XtPointer, XmTextVerifyPtr)
> Purpose:
  | This is the event callback used when the contents of a text box changes.  If a character in the editexit set is entered, then we notify X to not process the character for the widget 'w'.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w - text box widget
  = XtPointer client_data - event data
  = XmTextVerifyPtr call_data - event data
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
> Global Function: AnalyseTextParms ;
  $ BooleanAnalyseTextParms (BNRP_TCB*, GrafContextPtr*, PGrafWindow**, Position*, Position*, Dimension*, Dimension*, char**, XmTextPosition*, XmTextPosition*, int*)
> Purpose:
  | This function analyses the arguements of 'tcb' for the editbabs primitive.
> Calling Context:
  | 
> Return Value:
  | Boolean
> Parameters:
  = BNRP_TCB* tcb - task control block pointer
  = GrafContextPtr* gptr - graphics context to use
  = PGrafWindow** window - graphics window associated with 'gptr'
  = Position* x - left edge x position of the text box to be drawn
  = Position* y - tope edge y position of the text box to be drawn
  = Dimension* width - width of the text box
  = Dimension* height - height of the text box
  = char** textstring - text string to initially put into the textbox (function allocates memory for this!!)
  = XmTextPosition* selstart - start position of text
  = XmTextPosition* selend - end position of text
  = int* linenum - number of lines in the text box
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
> Global Function: IntersectRect ;
  $ voidIntersectRect (XRectangle, XRectangle, XRectangle*)
> Purpose:
  | This function returns a rectangle 'Result' which is the rectangle that represents the intersection of R1 and R2.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = XRectangle R1 - first interseting rectangle
  = XRectangle R2 - second intersecting rectangle
  = XRectangle* Result - intersection of R1 and R2 filled in by the function.
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
> Global Function: editbabs ;
  $ BNRP_Booleaneditbabs (BNRP_TCB*)
> Purpose:
  | Creates an editable text box in the rectangle.  The text box is preloaded with the contents of the sixth arguement and a text editing state is enteered.  The system remains in a text editing state until a non text editing event occurs.  The current text is then unified wit hthe seventh arguement.  The event chich terminates the text editing state is returned.  The twelfth parameter sepecifies an edit exit set to use.  The arguements are as follows
  | - graphics context id
  | - x value of left edge of text box to draw
  | - y value of top edge of text box to draw
  | - x value of right edge of text box to draw
  | - y value of top edge of text box to draw
  | - list of three symbols to be initially placed in text box
  | - unified with the contents of textbox when editing is finished
  | - unified with event name of the event which stopped editing
  | - unified with the window where the event occured
  | - unified with the first piece of data from the event
  | - unified with the second peice of data from the event
  | - list containing the edit exit set to be used.
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
> Global Function: scrollrect ;
  $ BNRP_Booleanscrollrect (BNRP_TCB*)
> Purpose:
  | This primitive scrolls a rectangular region of a graphics window by a horizontal and vertical displacement.  Exposed regions are filled in with the window's current background pattern.  This primitive takes 7 arguements as follows:
  | - graphics context id
  | - left edge x position
  | - top edge y position
  | - right edge x position
  | - bottom edge y position
  | - x displacement
  | - y displacement
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
> Global Function: getGrafTextSize ;
  $ BNRP_BooleangetGrafTextSize (BNRP_TCB*)
> Purpose:
  | This primitive gets the point size of the font being used by a graphics context.  The first arguement is a graphics context id, and the second is unified with the point size of the font being used.
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
> Global Function: getGrafTextFont ;
  $ BNRP_BooleangetGrafTextFont (BNRP_TCB*)
> Purpose:
  | This primitive gets the name of the font being used by a graphics context.  The first arguement is a graphics context id, and the second is unified with the name of the font being used.
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
> Global Function: setGrafTextSize ;
  $ BNRP_BooleansetGrafTextSize (BNRP_TCB*)
> Purpose:
  | This primitive sets the point size of the font being used by a graphics context.  The first arguement is a graphics context id and the second is the point size to be used for the font.  If the font can't be loaded with the given size, then FALSE is returned.
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
> Global Function: setGrafTextFont ;
  $ BNRP_BooleansetGrafTextFont (BNRP_TCB*)
> Purpose:
  | This primitive sets the font to be used by a grpahics context.  The first arguement is a graphics context id, and the second is the name of the font to be used.  Ifthe font can't be loaded, FALSE is returned.
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
> Global Function: getGrafTextFace ;
  $ BNRP_BooleangetGrafTextFace (BNRP_TCB*)
> Purpose:
  | This primitive gets the text face for the font being used by a graphics context.  The first arguement is the graphics context id, andthe second is unified with a list containing the weight and slant values for the graphics context font.
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
> Global Function: setGrafTextFace ;
  $ BNRP_BooleansetGrafTextFace (BNRP_TCB*)
> Purpose:
  | This primitive sets the text face of the font being used by a graphics context.  The first arguement is a graphics context id and the second is a list containing one or both of the weight and slant of the font.  Valid weight values are "bold" or "normal".  Valid slant values are "normal" or "italic".
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
> Global Function: setGrafTextMode ;
  $ BNRP_BooleansetGrafTextMode (BNRP_TCB*)
> Purpose:
  | This primiitve sets the current text mode used by a graphics context.  The first arguement is a graphics context id, and the second is one of the following symbols: "or", "xor", or "clear".  The mode defines how the text is written to the screen.
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
> Global Function: getGrafTextMode ;
  $ BNRP_BooleangetGrafTextMode (BNRP_TCB*)
> Purpose:
  | This primiitve gets the current text mode used by a graphics context.  The first arguement is a graphics context id, and the second is unified with one of the following symbols depending on the current text writing mode: "or", "xor", or "clear".
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
> Global Function: textWidth ;
  $ BNRP_BooleantextWidth (BNRP_TCB*)
> Purpose:
  | This function gets the width in pixels that a piece of text would take in a graphics context.  It has three arguements.  The first is a graphics context id, the second is the string whose width is to be found, and the third is unified with the width in pixels of the second arguement.
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
> Global Function: textAbs ;
  $ BNRP_BooleantextAbs (BNRP_TCB*)
> Purpose:
  | This primitive writes text in a graphics context at a given position using the text mode of the graphics context given.  It has 4 arguements.  The first is a graphics context id, the second and third are the x and y co-ordinates relative to the graf window origin.  The fourth arguement is the string to output.
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
> Global Function: get_icon_value ;
  $ BNRP_Booleanget_icon_value (BNRP_TCB*)
> Purpose:
  | This primitive reads an icon into a stream or into a symbol.  The first arguement is the icon id and the second is either a list or a variable.  If it is a list, the first list element is a file pointer and the second is the id of the I/O handler that works on the file pointer(must handle OUTPUTSTRING).  If it is a variable, then the value of the icon is unified with it.  If the icon with the specified icon id is not in the bitmap table, then an attempt to load it is made.
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
> Global Function: defaultbitmapdir ;
  $ BNRP_Booleandefaultbitmapdir (BNRP_TCB*)
> Purpose:
  | This primitive sets or queries the default directory to look for bitmaps in first.  This is initially set to ".".  If the single arguement is a symbol, then it sets the default bitmap directory to be the one given.  If it is a variable, the arguement is unified with the name of the current default bitmap directory.
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
> Global Function: BindPGrafPrimitives ;
  $ voidBindPGrafPrimitives ()
> Purpose:
  | Binds the X graphics primitives into the system, and sets up the initialPixmap variable.
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
> Data Item: bitmap_table
  $ BitmapTableRec[MAX_BITMAPS] bitmap_table
> Purpose:
  | This is the table that stores loaded bitmaps.  Saves us from having to reload them each time.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: White
  $ char[] White
> Purpose:
  | Definition of a white bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: Lightgray
  $ char[] Lightgray
> Purpose:
  | Definition of a light grey bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: Gray
  $ char[] Gray
> Purpose:
  | Definition of a gray bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: Darkgray
  $ char[] Darkgray
> Purpose:
  | Definition of a dark gray bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: Black
  $ char[] Black
> Purpose:
  | Definition of a black bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: singlePlaneGC
  $ GC singlePlaneGC
> Purpose:
  | This is a single place graphics context that is used for displaying icons.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: createdSinglePlaneGC
  $ Boolean createdSinglePlaneGC
> Purpose:
  | TRUE when a single place graphics context has already been created and stored in singlePlaneGC.  Used in iconabs primitive.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: initialPixmap
  $ Pixmap initialPixmap
> Purpose:
  | Initial pixmap associated with a newly opened graphics window.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: bitmapSearchPath
  $ char[] bitmapSearchPath
> Purpose:
  | This is the path that is searched first for bitmaps and patterns.  This can be set by clls to the defaultbitmapdir primitive.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: NotPrologPattern
  $ #define NotPrologPattern
> Purpose:
  | The error code that occurs when apattern isn't a pattern that Prolog understands.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_LINE_SEGMENTS
  $ #define MAX_LINE_SEGMENTS
> Purpose:
  | Maximum number of line segments that can be drawn from one call to the multi_lineabs primitive.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: ICON_SIZE
  $ #define ICON_SIZE
> Purpose:
  | Default height and width for icons
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | bitmap_table
  $ struct bitmap_table
> Purpose:
  | This is used as an entry in a table of loaded bitmaps.  Holds all information needed to handle loaded bitmaps.  Saves from havingto load them each time.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = int ispattern - is 1 for icons, and is 2 for patterns
  = char[BITMAP_NAMESIZE] bitname - name of the bitmap
  = Pixmap bitimage - the bitmap image
  = int frame_L - left co-ordinate of picture
  = int frame_T - top co-ordinate of picture
  = int pict_width - width of picture
  = int pict_height - height of picture
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
> Struct:
  | _grafStruct
  $ struct _grafStruct
> Purpose:
  | This structure stores the current graphics structure in a graphics context
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = GC gc - graphics structure associated with this record
  = _pgraf* parent_window - parent graf window
  = _grafStruct* prev_gptr - pointer to the previous graphcs context in the chain
  = Region update_region - region to update after an expose event
  = Region accum_expose_region - used to compress expose events
  = Boolean valid_update_region - TRUE if update region is in use
  = Boolean default_clip_rect - TRUE if default clip rectangle
  = XRectangle clip_rect - holds the user clip rectangle
  = fill_types fill_mode - graphics fill mode
  = pen_modes pen_mode - graphics pen mode
  = int penpatindex - bitmap table index to pen pattern
  = int backpatindex - bitmap table index to background pattern
  = int userpatindex - bitmap table index to  user pattern
  = int pensize - pen width
  = int current_function - function used to revert the fillmode to what it was before a clear fillmode was used.
  = int textMode - mode value to write text with (GXcopy, GXinvert or GXclear)
  = XFontStruct* font - font to write text with
  = FontInfo fontInfo - font information of font being used to write text with
  = char* foreColorName - name of the foreground colour
  = unsigned long foreColor - value of the foreground colour
  = char* backColorName - name of the background colour
  = unsigned long backColor - value of the background colour
  = Drawable draw - canvas widget window or picture pixmap
  = int left - left edge offset used during picture creation
  = int top - top edge offset used during picture creation
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
> Enumeration:
  | fill_types
  $ enum fill_types {hollow, pentype, usertype, clear, invert}
> Purpose:
  = This enum defines all ofthe different fill types available for filling objects.
> Tags:
  = hollow
  = pentype
  = usertype
  = clear
  = invert - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Enumeration:
  | pen_modes
  $ enum pen_modes {copy, or, xor, pen_clear, notcopy, notor, notxor, notclear}
> Purpose:
  = This enum defines all of the different pen modes available for drawing.
> Tags:
  = copy
  = or
  = xor
  = pen_clear
  = notcopy
  = notor
  = notxor
  = notclear - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | BitmapTableRec
  $ typedef bitmap_table BitmapTableRec
> Purpose:
  | Type definition for a bitmap_table structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | GrafContextRec
  $ typedef _grafStruct GrafContextRec
> Purpose:
  | Type definition for a _grafStruct structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | GrafContextPtr
  $ typedef _grafStruct* GrafContextPtr
> Purpose:
  | Type definition for a pointer to a _grafStruct structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ProGraf
  $ #define _H_ProGraf
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BITMAP_NAMESIZE
  $ #define BITMAP_NAMESIZE
> Purpose:
  | Maximum number of characters allowed in a bitmap name.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAX_BITMAPS
  $ #define MAX_BITMAPS
> Purpose:
  | This is the maximum number of bitmaps a user coan load during a session.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BITPATH
  $ #define BITPATH
> Purpose:
  | This is the default bitmap directory used when bitmaps can't be found in LOCAL_BITPATH or in the user specified path.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LOCAL_BITPATH
  $ #define LOCAL_BITPATH
> Purpose:
  | This is the local bitmap directory path
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
