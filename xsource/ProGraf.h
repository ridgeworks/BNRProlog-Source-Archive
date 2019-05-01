/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProGraf.h,v 1.1 1995/09/22 11:26:43 harrisja Exp $
*
*  $Log: ProGraf.h,v $
 * Revision 1.1  1995/09/22  11:26:43  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_ProGraf
#define _H_ProGraf

#include "ProText.h"		/* Load in the FontInfo definition */
#include "ProWindows.h"

#define BITMAP_NAMESIZE 50 	/* Maximum number of characters allowed
				  in a bitmap name */

#define MAX_BITMAPS 100		/* Maximum number of bitmaps a user can
				 load during a session */

enum fill_types {hollow, pentype, usertype, clear, invert};
enum pen_modes {copy, or, xor, pen_clear, notcopy, notor, notxor, notclear};


typedef struct bitmap_table {
        int		ispattern;/*Used to distinguish between (1)icons 
			 									and     (2)patterns. */
        char   bitname[BITMAP_NAMESIZE]; 
        Pixmap bitimage; 			/* The bitmap image */
		int	   frame_L,frame_T,  /* Upper left co-ordinate of picture */
			   pict_width,pict_height;
        } BitmapTableRec;

	
typedef struct _grafStruct {
	GC	gc;
 	struct _pgraf *parent_window;   /* Back pointer to the PGrafWindow window structure */
 	struct _grafStruct	*prev_gptr;   /* Back pointer to previous grafStruct */
	Region  update_region;         /* region to update after an expose */
	Region  accum_expose_region;   /* used to compress expose events */
	Boolean valid_update_region;   /* TRUE if update region in use */
	Boolean default_clip_rect;     /* TRUE if default clip rectangle */
	XRectangle clip_rect;	       /* holds the user clip rectangle */
	enum fill_types fill_mode;	/* Holds the graphics fill mode */
	enum pen_modes pen_mode;	/* Holds the graphics pen mode */

	  				/* Bitmap table indexes to
					  pen, back, and user patterns.  */
	int	penpatindex, backpatindex, userpatindex;
	int	pensize;

	/*  This variable will hold the function that was set before a call
	  to fillmode(clear).  When the fillmode is later changed back
	  to anything but clear, the function will revert to what it was
	  originally. */
	int		current_function;
	int		textMode;
	XFontStruct	*font;
	FontInfo	fontInfo;
	char	*foreColorName;
	unsigned long	foreColor;
	char	*backColorName;
	unsigned long	backColor;
	Drawable	draw;		/* canvas widget window or picture pixmap */
	int			left,top; /* used as offset during picture creation */
} GrafContextRec, *GrafContextPtr;


extern void BindPGrafPrimitives();
extern void StartGrafUpdate();
extern void ModifyGrafUpdate();
extern void TerminateGrafUpdate();
extern void InitGrafWindow();
extern void TerminateGrafWindow();
extern void PrologColors();

extern BitmapTableRec	bitmap_table[MAX_BITMAPS];

extern Boolean createdSinglePlaneGC;
extern GC singlePlaneGC;

#define BITPATH        "/usr/include/X11/bitmaps/"  /* Default bitmap directory */
#define LOCAL_BITPATH  "/bitmaps/"                  /* local bitmap directory */
#endif
