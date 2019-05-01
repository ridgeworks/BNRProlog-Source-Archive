#if 0
----------------------------------------------------------------------
> Global Function: scan ;
  $ voidscan (float, float, int, float)
> Purpose:
  | This function updates the weights in the destination pixmap between the x values Lsd and Rsd for a given y.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = float Lsd - x value of left side of area to update
  = float Rsd - x value of right side of area to update
  = int y - y value of area being updated
  = float Wt - Weight to update values to.
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
> Global Function: output_rect ;
  $ voidoutput_rect (float, float, float, float)
> Purpose:
  | This function increases each of the weights of the bits in the destination ofthe specified rectangle. 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = float Lsd - x value of left side of rectangle
  = float Tsd - y value of top side of rectangle
  = float Rsd - x value of right side of rectangle
  = float Bsd - y value of bottom side of rectangle
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
> Global Function: ScalePixmap ;
  $ PixmapScalePixmap (GC, Pixmap, Pixmap, int, int, int, int)
> Purpose:
  | This function accepts a bitmap (A pixmap of depth 1) and returns the bitmap scaled to the requested size.  The source bitmap has Rs rows and Cs columns, the destination bitmap has Rd rows and Cd columns.
> Calling Context:
  | 
> Return Value:
  | Pixmap
> Parameters:
  = GC gc - graphics context associated with the bitmap
  = Pixmap inmap - source bitmap to be scaled
  = Pixmap outmap - scaled bitmap
  = int Cs - number of columns in source
  = int Rs - number of rows in source
  = int Cd - number of columns in destination
  = int Rd - number of rows in destination
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
> Data Item: source
  $ XImage* source
> Purpose:
  | Source pixmap image.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: destination
  $ XImage* destination
> Purpose:
  | Destination pixmap image.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: dest_weight
  $ float* dest_weight
> Purpose:
  | Dynamically allocated array that holds the percentage coverage of each pixel in the destination bitmap.  If any destination pixel is more than BIT_THRESHOLD percent covered by one or more source pixels, then that destination pixel is lit.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: GRd
  $ int GRd
> Purpose:
  | This is the number of rows in the destination bitmap.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: BIT_THRESHOLD
  $ #define BIT_THRESHOLD
> Purpose:
  | Contrast control for bitmap scaling.  Any pixel in the destination bitmap that is covered by a pixel in the source bitmap by more than this percentage will be set.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: epsilon
  $ #define epsilon
> Purpose:
  | This value is used to increase or decrease a value for a floor or ceiling function which rounds up or down.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: update_destination_pixel_weight
  $ #define update_destination_pixel_weight (x,y, wt)
> Purpose:
  | Increases the weight of the pixel at x and y in the destination pixmap.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
