/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProGraf.c,v 1.12 1998/01/20 16:44:57 thawker Exp $
*
*  $Log: ProGraf.c,v $
 * Revision 1.12  1998/01/20  16:44:57  thawker
 * Cast NULL to an int each time it is compared to or used as an int,
 * to remove warnings this caused on solaris
 *
 * Revision 1.11  1996/04/28  22:38:29  yanzhou
 * In EditBoxChangedCB, call_data->doit is set to TRUE if
 * textEditState is true.
 *
 * Revision 1.10  1996/04/18  23:17:41  yanzhou
 * Two changes are made:
 *
 * 1) It was possible for editbabs() to issue memcpy(to, from, length) where length < 0,
 *    which caused xBNRProlog to core-dump under certain circumstances.
 *
 *    Now fixed.
 *
 * 2) In the previous version, a change was made to check textEditState in EditBoxChangedCB,
 *    which was a BAD idea, because keys like XK_KP_Enter do not usually trigger the
 *    EditBoxChangedCB callback routine.  Now reverted to check textEditState in KeyPressCB.
 *
 * Revision 1.9  1996/01/12  15:03:52  yanzhou
 * Bitmaps are now searched in the following order:
 *   1) $HOME/bitmaps
 *   2) defaultbitmapdir
 *   3) /usr/include/X11/bitmaps
 *
 * Revision 1.8  1996/01/03  09:45:52  yanzhou
 * "Cut and Paste" now works in text fields (edit boxes).
 *
 * Revision 1.7  1995/11/01  11:32:33  yanzhou
 * Modified: SetFunction() to set PlaneMask to (fg xor bg) by default.
 *
 * Revision 1.6  1995/10/25  16:42:19  yanzhou
 * New primitive: defaultbitmapdir().
 * Bitmaps are now looked up in:
 *   a) defaultbitmapdir
 *   b) $HOME/bitmaps
 *   c) /usr/include/X11/bitmaps
 *
 * Revision 1.5  1995/10/20  12:28:41  yanzhou
 * Modified: fore/backcolor_C()
 *   to reset PlaneMask after color changes.
 *
 * Revision 1.4  1995/10/20  12:10:26  yanzhou
 * Modified:
 *   To terminate the editbabs eventLoop() correctly.
 *
 * Revision 1.3  1995/10/19  13:29:37  yanzhou
 * Modified:
 *  1) SetFunction: set PlaneMask to (backcolor xor forecolor)
 *     when GXinvert is being used.
 *  2) get_pixel_by_name and AllocCustomColor:
 *     smarter default color handling.
 *
 * Revision 1.2  1995/10/13  15:39:51  harrisja
 * *** empty log message ***
 *
 * Revision 1.1  1995/09/22  11:26:28  harrisja
 * Initial version.
 *
*
*/

/* include files */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#else
#include <strings.h>
#endif
#include <math.h>
#include <memory.h>

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/keysym.h>
#include <X11/Shell.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
/* can I exclude this???
#include <X11/Xmu/Xmu.h>
*/
#include <Xm/Xm.h>
#include <Xm/Protocols.h>
#include <Xm/AtomMgr.h>
#include <Xm/CascadeB.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/MainW.h>
#include <Xm/BulletinB.h>
#include <Xm/MwmUtil.h>
#include <Xm/RowColumn.h>
#include <Xm/Text.h>
#include <Xm/DialogS.h>
#include <Xm/FileSB.h>
#include <Xm/MessageB.h>
#include <Xm/Label.h>
#include <Xm/SelectioB.h>
#include <Xm/CutPaste.h>
#include <Xm/DrawingA.h>

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProGraf.h"
#include "ProMenus.h"
#include "ProText.h"
#include "ProWindows.h"
#include "ProEvents.h"
#include "Prolog.h"

#define	 NotPrologPattern	-2

BitmapTableRec	bitmap_table[MAX_BITMAPS]  ;		   /* Table that holds data on bitmaps
						 							     loaded during a session */

#define  MAX_LINE_SEGMENTS 100   /* Define the maximum number of line segments 
			 						that can be drawn from ONE call to the 
 									multi_lineabs primitive (The segment endpoints are
									passed in the form of a PROLOG list) */


#define ICON_SIZE	32 /* default icon size */

static char White[8] = 	 	{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
static char Lightgray[8] = 	{ 0x11, 0x44, 0x11, 0x44, 0x11, 0x44, 0x11, 0x44 };
static char Gray[8]=		{ 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa };
static char Darkgray[8]=	{ 0xbb, 0xee, 0xbb, 0xee, 0xbb, 0xee, 0xbb, 0xee };
static char Black[8]=		{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };



GC	singlePlaneGC;
Boolean createdSinglePlaneGC = FALSE;

extern Pixmap ScalePixmap ();

Pixmap initialPixmap;

static char bitmapSearchPath[256] = ".";        /* yanzhou@bnr.ca:25/10/95 */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* Hash function that :
	- Returns the bitmap table position for a previously stored name, or
	- Returns the appropriate spot to place a new name.

   The first 25% of the table is reserved for patterns with the name PATr.ii.bit
   (where r is the resource number, and ii is the index number of the pattern), or for
   icons with the name ICONxiixxx.bit (where x are unused characters).

   The remaining 75% of the table contains bitmaps that do not correspond to the standard
   criteria (Eg. user defined bitmaps, XWindows standard bitmaps).

	-1 is returned if there is no more space left in the bitmap table.
*/

int	bit_hash(Bitmap_Name)
	char	*Bitmap_Name;
{
	int 	resource, index, first_hash,hashpos_new,dummy_int;
	char	dummy_char;
	double	Start_Alpha, AlphaNum;
	char	temp_name[BITMAP_NAMESIZE];

	strcpy(temp_name,Bitmap_Name);
	if ((sscanf(temp_name,"PAT%1u.%02u.bit",&resource,&index) == 2) ||
	    (sscanf(temp_name,"ICON%c%02u%03u.bit",&dummy_char,&index,&dummy_int) == 3))
		/* If the input name has the form PATr.ii.bit, hash into the first
		  25% of the bitmap table, making the following assumptions :
			- Hash function will not consider 'resource' number, because
			 it will very likely ALWAYS be equal to 0.
			- Assume there are just 40 patterns of resource type 0. */
		first_hash =  (int)floor((double)index*MAX_BITMAPS/160);
 	else {
		/* All other alphanumeric pattern names will be hashed into the remaining
		  75% of the table, using the first letter of the pattern as a search key. */

		/* Convert the first letter of the pattern into a number from 0..25 */
		if ((AlphaNum = (double)(Bitmap_Name[0]-97)) < 0) 
			if ((AlphaNum = (double)(Bitmap_Name[0]-65)) < 0)
		    	AlphaNum=25.0;
		Start_Alpha = ceil((double)(MAX_BITMAPS/4));
		first_hash = (int)floor(Start_Alpha+( double)(MAX_BITMAPS-Start_Alpha)/26*AlphaNum);
	}

	hashpos_new=first_hash;

	/* If the current table entry is full, but doesn't contain the expected name,
	  move forward in the table.  If an empty spot is found, exit the loop. */ 

	while ((bitmap_table[hashpos_new].bitimage != (int)NULL) &&
	       (strcmp(bitmap_table[hashpos_new].bitname,Bitmap_Name) != 0)){
		hashpos_new++;                         /* Move down to next bitmap table entry */
        if (hashpos_new > MAX_BITMAPS)       /* Wrap around to table head if necessary */
        	hashpos_new=0;
        if (hashpos_new == first_hash) {     /* If there's no more space in the table, */
            return -1;
        }
	}
	/* hashpos_new now contains the table position where either the bitmap is residing, or
	  where the system EXPECTS it to be residing. */

 	return hashpos_new;
}

/* Reads a bitmap file from either the local bitmap directory LOCAL_BITPATH,
  or from the system default bitmap directory BITPATH.
   Returns the XReadBitmapFile result code. */
int ReadBitmapFromFile(file_in,bitmap, width, height, draw)
char    *file_in;
Pixmap  *bitmap;                                        /* Returned pixmap */
unsigned int    *width, *height;                        /* Returned */
Drawable  draw;
{
	char	filename[256];
	int     x_hot, y_hot;
    int     value = BitmapOpenFailed;

    /* Try to find requested bitmap in the local bitmap path */
    strcpy(filename,getenv("HOME"));
    strcat(filename,LOCAL_BITPATH);
    strcat(filename,file_in);
    value = XReadBitmapFile(display, draw, filename, width, height, bitmap, &x_hot, &y_hot);

    /*
     * yanzhou@bnr.ca:25/10/95
     *   try to find requested bitmap in bitmapSearchPath
     */
    if (value == BitmapOpenFailed) {
        strcpy(filename, bitmapSearchPath);
        strcat(filename, "/");
        strcat(filename, file_in);
        value = XReadBitmapFile(display, draw, filename, width, height, bitmap, &x_hot, &y_hot);
    }

	/* Try to find requested bitmap in the default X path */
	if (value == BitmapOpenFailed) {
        strcpy(filename, BITPATH);
        strcat(filename, file_in);
       	value = XReadBitmapFile(display, draw, filename, width, height, bitmap, &x_hot, &y_hot);
	}

#ifdef DEBUG
	if (value == BitmapFileInvalid)
		printf( "ProGraf ERROR : Filename %s contains invalid bitmap data.\n",filename);
	else if (value == BitmapNoMemory)
		printf("ProGraf ERROR : Not enough memory to allocate pixmap. \n");
 	else if ((value == BitmapOpenFailed) && DebugTrace)
		printf( "ProGraf ERROR : Bitmap resource '%s' could not be opened.\n",file_in);
	else
		if (DebugTrace) 
            printf( "Loaded bitmap resource '%s'.\n",file_in);
#endif

	return(value);                       /* Return BitmapSuccess if everything worked */
}

/* Retreives a specified bitmap.  If it is present in the bitmap table, it is loaded from
  there; otherwise, it is loaded from disk, inserted into the table, and returned.
   Returns the hash position of the bitmap, or -1 if bitmap was loaded but not cached,
	or -2 if the bitmap could not be loaded. */
int get_bitmap(Bitmap_Name,bitmap,draw)
	char	*Bitmap_Name;
	Pixmap	*bitmap;				/* Returned */
	Drawable	draw;
{
	int 	hashpos;
	unsigned int	width,height;

	hashpos = bit_hash(Bitmap_Name);
	if (hashpos != -1) {
		  	 /* Retreive the bitmap from disk, and insert it into the table. */
		if (bitmap_table[hashpos].bitimage == (int)NULL) { 
			if (ReadBitmapFromFile(Bitmap_Name,bitmap, &width, &height, draw) != BitmapSuccess) return -2;
			strcpy(bitmap_table[hashpos].bitname,Bitmap_Name);
			bitmap_table[hashpos].bitimage = *bitmap;
	  	}
	  	else 		      				      /* Retreive data from table */
			*bitmap=bitmap_table[hashpos].bitimage;
	}
	else {
		if (ReadBitmapFromFile(Bitmap_Name,bitmap, &width, &height, draw) != BitmapSuccess) return -2;
#ifdef DEBUG
		if (DebugTrace) printf("bitmap %s allocated but not cached (cache full)\n",Bitmap_Name);
#endif
	}
	return hashpos;
}

/* Returns the bitmap table index to one of the standard PROLOG patterns.
   Returns NotPrologPattern if the input symbol is not a standard PROLOG pattern, or
	   -1 on failure.*/
int get_symbol_bitmap_entry(Symbol,draw)
	char	*Symbol;
	Drawable	draw;
{
	int	hashpos;

	if (strcmp(Symbol,"white") == 0) {
		hashpos=bit_hash("white");
		if (hashpos == -1) return -1;
		else if (bitmap_table[hashpos].bitimage == (int)NULL) {
			strcpy(bitmap_table[hashpos].bitname,"white");
			bitmap_table[hashpos].bitimage = XCreateBitmapFromData(display,draw,White,8,8);
#ifdef DEBUG
			if (DebugTrace) printf("Created pixmap for white.\n");
#endif
		}
	}
	else if ((strcmp(Symbol,"lightgray") == 0) || (strcmp(Symbol,"lightgrey") == 0)) {
		hashpos=bit_hash("lightgray");
        if (hashpos == -1) return -1;
		else if (bitmap_table[hashpos].bitimage == (int)NULL) {
        	strcpy(bitmap_table[hashpos].bitname,"lightgray");
            bitmap_table[hashpos].bitimage = XCreateBitmapFromData(display,draw,Lightgray,8,8);
#ifdef DEBUG
			if (DebugTrace) printf("Created pixmap for lightgray.\n");
#endif
		}
	} 
	else if ((strcmp(Symbol,"gray") == 0) || (strcmp(Symbol,"grey") == 0)) {
		hashpos=bit_hash("gray");
        if (hashpos == -1) return -1;
		else if (bitmap_table[hashpos].bitimage == (int)NULL) {
        	strcpy(bitmap_table[hashpos].bitname,"gray");
            bitmap_table[hashpos].bitimage = XCreateBitmapFromData(display,draw,Gray,8,8);
#ifdef DEBUG
			if (DebugTrace) printf("Created pixmap for gray.\n");
#endif
		}
    }
	else if ((strcmp(Symbol,"darkgray") == 0) || (strcmp(Symbol,"darkgrey") == 0)) {
        hashpos=bit_hash("darkgray");
        if (hashpos == -1) return -1;
		else if (bitmap_table[hashpos].bitimage == (int)NULL) {
        	strcpy(bitmap_table[hashpos].bitname,"darkgray");
            bitmap_table[hashpos].bitimage = XCreateBitmapFromData(display,draw,Darkgray,8,8);
#ifdef DEBUG
			if (DebugTrace) printf("Created pixmap for darkgray.\n");
#endif
		}
    }
    else  if (strcmp(Symbol,"black") == 0) {
        hashpos=bit_hash("black");
        if (hashpos == -1) return -1;
		else if (bitmap_table[hashpos].bitimage == (int)NULL) {
        	strcpy(bitmap_table[hashpos].bitname,"black");
            bitmap_table[hashpos].bitimage = XCreateBitmapFromData(display,draw,Black,8,8);
#ifdef DEBUG
			if (DebugTrace) printf("Created pixmap for black.\n");
#endif
		}
    }
	else return NotPrologPattern;

	/* If the bitmap load was successful, mark the new entry in the bitmap table as a PATTERN
	  (As opposed to an ICON). */
	bitmap_table[hashpos].ispattern=TRUE;
	return hashpos;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Set the Clipping Region by intersecting the update_region(if it exists)
with the existing clipping rectangle.
   Updates the CLIP MASK in the specified GC with this region.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void	SetClipRegion(gptr)
    	GrafContextPtr  gptr;

{
    if (gptr->default_clip_rect)
       { /* No clipping rectangle set. If update in effect, set clip region to
          update region */
       if (gptr->valid_update_region)
          {
#ifdef xDEBUG
           if (DebugTrace) printf("Set clip region to update region.\n");
#endif
           XSetRegion(display,gptr->gc,gptr->update_region);
			return;
          }
       else
          {
#ifdef xDEBUG
           if (DebugTrace) printf("Set clip region to none.\n");
#endif
           XSetClipMask(display,gptr->gc,None);
			return;
          }
       }
    else
       { /* a clipping rectangle has been set */
		XPoint	p[4];
		Region	clip_region;
#ifdef xDEBUG
        if (DebugTrace)
            printf("SetClipRegion: ClipRect(%d,%d), width %d, height %d.",
              gptr->clip_rect.x,gptr->clip_rect.y,gptr->clip_rect.width,
              gptr->clip_rect.height);
#endif
        /* ensure the clip rectangle is inside the window, else clips everything! */
       	if (gptr->clip_rect.x < 0) gptr->clip_rect.x = 0;
       	if (gptr->clip_rect.y < 0) gptr->clip_rect.y = 0;
       	if (gptr->clip_rect.width > gptr->parent_window->width)
       		gptr->clip_rect.width = gptr->parent_window->width;
       	if (gptr->clip_rect.height > gptr->parent_window->height)
       		gptr->clip_rect.height = gptr->parent_window->height;

		p[0].x = gptr->clip_rect.x;
		p[0].y = gptr->clip_rect.y;
		p[1].x = p[0].x + gptr->clip_rect.width;
		p[1].y = p[0].y;
		p[2].x = p[1].x;
		p[2].y = p[0].y + gptr->clip_rect.height;
		p[3].x = p[0].x;
		p[3].y = p[2].y;
		clip_region = XPolygonRegion(p, 4, WindingRule);
#ifdef xDEBUG
        if (DebugTrace)
           printf(" ClipRegion(%d,%d), width %d, height %d.",
             gptr->clip_rect.x,gptr->clip_rect.y,gptr->clip_rect.width,
             gptr->clip_rect.height);
#endif

        if (gptr->valid_update_region) {
			XIntersectRegion(clip_region, gptr->update_region, clip_region);
#ifdef xDEBUG
             if (DebugTrace)
                 printf(" Intersect with update region.");
#endif
            }
#ifdef xDEBUG
        if (DebugTrace) printf("\n");
#endif

        /* Set the clip mask in the GC */
        XSetRegion(display, gptr->gc, clip_region);
		XDestroyRegion(clip_region);
       }
}

/*  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	C O D E      C A L L E D      B Y      O T H E R      M O D U L E S   
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - /*

/* StartGrafUpdate - starts an update operation on the current graf window.
   This procedure is called when a Prolog update event is generated. The update
   region is set in the graf window data structure where it is used as a clipping
   region. */

void StartGrafUpdate(window)
    PGrafWindow *window;

{
    /* set the update region to the accumulated expose region */
    window->graf->valid_update_region = TRUE;
    window->graf->update_region = window->graf->accum_expose_region;
    /* reset the accum_expose_region in readiness for next expose
       event sequence */
    window->graf->accum_expose_region = XCreateRegion();

    /* Set the clip mask of the window's GC, based on the current expose region
      intersected with the user specified clipping rectangle. */
    SetClipRegion(window->graf);
}

/* ModifyGrafUpdate - modifies the update region on the window as a result 
   of calling validrect. Validrect is only valid when an update operation
   is in progress. Validrect does the error checking. */

void ModifyGrafUpdate(window,rectangle)
    PGrafWindow *window;
    XRectangle  *rectangle;

{
	Region     validregion;

	/* This code doesn't work properly.  Get various errors on diff permutations of code: 
	   X-server I/O errors, block already freed, etc. Think Region routines are 
           sensitive to same source/dest operands, but how to avoid it? */
	/* Create a region with the valid rect */
	validregion = XCreateRegion();
	XUnionRectWithRegion(rectangle,validregion,validregion);
	XSubtractRegion(window->graf->update_region,validregion,window->graf->update_region);
	XDestroyRegion(validregion);
	SetClipRegion(window->graf);
}

/* TerminateGrafUpdate - terminates the update operation on all windows with
   update regions. The update operation starts when an update event is returned
   to Prolog. The update region is set in the graf window data structure where
   it is used by all Dograf operations. It is removed the next time userevent
   is called. */

void TerminateGrafUpdate()
{
	PGrafWindow	*w;

	for (w = (PGrafWindow *)windowtab; w != NULL;w = (PGrafWindow *)w->next_window)
		if ((w->type == pgraf) && (w->graf->valid_update_region)) {
			w->graf->valid_update_region = FALSE;
			XDestroyRegion(w->graf->update_region);
			/* Reset the clip mask of the window's GC to the user specified
          		clipping rectangle */
			SetClipRegion(w->graf);
		}
}

unsigned long get_pixel_by_name(colorname)
    char    *colorname;
{
    XColor      color, ignore;

	if (!strcmp(colorname,"black"))
		return BlackPixel(display,DefaultScreen(display));
	else if (!strcmp(colorname,"white"))
		return WhitePixel(display,DefaultScreen(display));
    else if(XAllocNamedColor(display,DefaultColormap(display,DefaultScreen(display)),colorname,&color,&ignore))
    {

       /* e.t. trying to find where the problem is happening 
       printf("XAllocNamedColor called in ProGraf.c  %s %d %d %d %d %d %d %d %d \n",colorname,color.pixel,color.red,color.green,color.blue,ignore.pixel,ignore.red,ignore.green,ignore.blue); */
       
       return color.pixel;
    }
    else {
#ifdef DEBUG 
        printf("ProGraf WARNING : Couldn't allocate color %s\n",colorname);
#endif
        /*
         * yanzhou@bnr.ca:19/10/95: modified
         * reason: to base the choice of white or black on the
         *         brightness of the color.
         */
        if (XLookupColor(display, DefaultColormap(display,DefaultScreen(display)), 
                         colorname, &color, &ignore)) {
            if ((color.red >> 8) + (color.blue >> 8) + (color.green >> 8) >= 384)
                return WhitePixel(display,DefaultScreen(display));
        }
        return BlackPixel(display,DefaultScreen(display));
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
  Allocates a custom color given by the user. 
  INPUT : The color number is an integer,and its hex representation is xxRRGGBBh.
         (RR,GG,BB represent the red, green, and blue components of the color, 
          where 00 is the darkest, and FF is the brightest.  The x's represent the
	  MSB of the input, which is ignored.)
  OUTPUT: The pixel value of the color will be returned.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
unsigned long AllocCustomColor(colorid)
	int    colorid;
{
	char	 *hexcolor="#RRGGBB";
	Colormap cmap	  = DefaultColormap(display,DefaultScreen(display));
	XColor	 colordef, ignore;

	sprintf(hexcolor,"#%0.6x",colorid);
	
	/* e.t. trying to find error 
	printf(" A call to XParseColor is about to be made in ProGraf.c\n");/* */
	
	XParseColor(display,cmap,hexcolor,&colordef);
	if (XAllocColor(display,cmap,&colordef))
		return colordef.pixel;
	else	{
#ifdef DEBUG
	   	printf("ProGraf WARNING : Couldn't allocate color (%s)h\n",hexcolor);
#endif
        /*
         * yanzhou@bnr.ca:19/10/95: modified
         * reason: to base the choice of white or black on the
         *         brightness of the color.
         */
        if ((colordef.red >> 8) + (colordef.blue >> 8) + (colordef.green >> 8) >= 384)
            return WhitePixel(display,DefaultScreen(display));
		return BlackPixel(display,DefaultScreen(display));
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	Initializes the GrafContextRec data structure upon
 the opening of a graphics window.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
void InitGrafWindow (w)
PGrafWindow	*w;
{
	w->graf = (GrafContextPtr) XtMalloc(sizeof(GrafContextRec));
	w->graf->accum_expose_region = XCreateRegion();
	w->graf->valid_update_region = FALSE;
	w->graf->parent_window = w; 
	w->graf->top = w->graf->left = 0;

	w->graf->fontInfo.name = XtNewString("systemfont");
	w->graf->fontInfo.size = sys_font_info.size;
	w->graf->fontInfo.weight = sys_font_info.weight;
	w->graf->fontInfo.slant = sys_font_info.slant;
	w->graf->font = sys_font;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	Performs additional initialization functions upon
 the opening of a graphics window.  The graphics window
 must be visible when this function is called.	
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
void PrologColors(w)
PGrafWindow	*w;
{
	GrafContextPtr	g=w->graf;
	int			i,default_hashpos;
	
	g->draw = initialPixmap;
	g->gc = XCreateGC(display,g->draw,(int)NULL,NULL);
#ifdef DEBUG
	if (DebugTrace) printf("created a GC\n");
#endif
	g->prev_gptr = NULL;

    /* Initialize the clip region as the default */
    g->default_clip_rect = TRUE;
    XSetClipMask(display,g->gc,None);

	/* Query the server for the pixel values corresponding to PROLOG's color set */
	XSetForeground(display,g->gc,g->foreColor=BlackPixel(display,DefaultScreen(display)));
	XSetBackground(display,g->gc,g->backColor=WhitePixel(display,DefaultScreen(display)));

	g->foreColorName = XtNewString("black");
	g->backColorName = XtNewString("white");

	/* Create a default stipple pattern (solid current foreground color), and
     insert it into the GC.  All graphics operations will use the stipple for drawing. */
	default_hashpos= get_symbol_bitmap_entry("black",g->draw);
	g->fill_mode=pentype;
	g->pen_mode=copy;
	g->penpatindex=default_hashpos;
	g->userpatindex=default_hashpos;
	g->backpatindex=get_symbol_bitmap_entry("white",g->draw);
	g->current_function=GXcopy;
	g->textMode=GXcopy;
	g->pensize = 0;
	XSetLineAttributes(display,g->gc,0,LineSolid,CapButt,JoinMiter);
	XSetFillStyle(display,g->gc,FillOpaqueStippled);
	XSetStipple(display,g->gc,bitmap_table[default_hashpos].bitimage);
	if (g->font)
		XSetFont(display,g->gc,g->font->fid);
#ifdef SinglePlane
	XSetPlaneMask(display,g->gc,1);
#endif
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
	This function is called upon the closure of a
 graphics window.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * */
void TerminateGrafWindow (w)
	PGrafWindow	*w;

{
	XDestroyRegion(w->graf->accum_expose_region);
	if (w->graf->valid_update_region)
		XDestroyRegion(w->graf->update_region);

	XFreeGC(display,w->graf->gc);
	if (w->graf->foreColorName)
		XtFree(w->graf->foreColorName);
	if (w->graf->backColorName)
		XtFree(w->graf->backColorName);
	XtFree(w->graf->fontInfo.name);
	XtFree((char *)w->graf);
	w->graf = NULL;
}

/*  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	E N D     O F     E X T E R N A L L Y     C A L L E D     R O U T I N E S
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

GrafContextPtr clone_of_GC();
/* * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG clone_GC_C(+GC_Index, -New_GC_Index)  *
 * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    clone_GC(tcb)
BNRP_TCB    *tcb;
{
    GrafContextPtr  new_gcptr, src_gcptr;
    BNRP_result     result;

#ifdef xDEBUG
	if (DebugTrace) printf("clone_GC\n"); 
#endif
	if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    src_gcptr  = (GrafContextPtr)result.ival;
    
    new_gcptr  = clone_of_GC(src_gcptr);

    return  BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb,(long int)new_gcptr));
}

GrafContextPtr clone_of_GC(src_gcptr)
GrafContextPtr	src_gcptr;
{
    GrafContextPtr	new_gcptr  = (GrafContextPtr)XtMalloc(sizeof(GrafContextRec));
    *new_gcptr = *src_gcptr;		    /* Set the new GC = to the old GC */

	if (src_gcptr->foreColorName)
		new_gcptr->foreColorName = XtNewString(src_gcptr->foreColorName);
	if (src_gcptr->backColorName)
		new_gcptr->backColorName = XtNewString(src_gcptr->backColorName);
	new_gcptr->fontInfo.name = XtNewString(src_gcptr->fontInfo.name);
	new_gcptr->prev_gptr = src_gcptr;

	return new_gcptr;
}

void SetFunction(gc, function)
GC gc;
int function;
{
/*
 * Modified by yanzhou@bnr.ca 19/10/95
 *
 * reason: the invert operation does not work as expected
 *         on color displays.
 *
 * fix: always set the plane mask to (forecolor xor backcolor)
 *      if the invert function is active.
 *
 * problems left: pen-mode functions may still cause random
 *                colors on screen.
 *
 * warning: operations like `or', `xor' and `invert' will only work
 *          properly on StaticGray/StaticColor displays, where
 *          mappings between pixel values and on-screen colors are
 *          predictable.  Users should be warned that on
 *          PseudoColor/DirectColor displays, they may cause
 *          unexpected results (e.g., random colours, colours being
 *          changed by other applications, etc.).
 *
 * Modified by yanzhou@bnr.ca 01/11/95
 * reason: disabled motif buttons do not get gray'ed out.
 * cause:  see `warning' above.
 *
 * temporary solution:
 *         set the PlaneMask to (foreground xor backcolor) to
 *         maximize the chance of getting correct visual results,
 *         although the results are still unpredictable.
 *
 */

#ifndef SinglePlane
    XGCValues     gcValues;
    unsigned long planeMask = AllPlanes;        /* default to all */

    switch (function) {
    case GXcopy:
    case GXclear:
    case GXnoop:
        planeMask = AllPlanes;
        break;

    case GXcopyInverted:
    case GXinvert:
        XGetGCValues(display, gc, GCForeground | GCBackground, &gcValues);
        planeMask = gcValues.foreground ^ gcValues.background;
        break;

    default: /* temporary solution, the color problem is still there ! */
        XGetGCValues(display, gc, GCForeground | GCBackground, &gcValues);
        planeMask = gcValues.foreground ^ gcValues.background;
    }

    XSetPlaneMask(display, gc, planeMask);
#endif

	XSetFunction(display, gc, function);
}


void switch_fill_mode(gptr)
GrafContextPtr gptr;
{
	switch(gptr->fill_mode) {
	case clear: {
			/* Set the penmode to copy, but don't let the gc know we've done it.
			  This is done so the penmode existing before this override can be
			  re-installed when another fillpat OTHER than clear or invert is specified
			  (or if the user uses PENMODE to force the penmode to be a certain value). */
			SetFunction(gptr->gc,GXcopy);
			/* Set the drawing pattern. */
   		    XSetStipple(display,gptr->gc,bitmap_table[gptr->backpatindex].bitimage);
			return;
   		 }
	case hollow: 
	case pentype: {
   		 	XSetStipple(display,gptr->gc,bitmap_table[gptr->penpatindex].bitimage);
			break;
   		 }
	case usertype: {
   		 	XSetStipple(display,gptr->gc,bitmap_table[gptr->userpatindex].bitimage);
			break;
   		 }
	case invert: {
			/* Set the penmode to invert (xor), but don't let the gc know we've done it.
			  This is done so the penmode existing before this override can be
			  re-installed when another fillpat OTHER than clear or invert is specified. */
			SetFunction(gptr->gc,GXinvert);
	
			/* Set the drawing pattern to SOLID BLACK. 
			  Every pixel drawn in subsequent figures will cause the existing pixel on the screen
			  to invert. */
   		 	XSetStipple(display,gptr->gc, bitmap_table[get_symbol_bitmap_entry("black",gptr->draw)].bitimage);
			return;
	    }
	}

    /* If the fillpat was anything OTHER than clear or invert, then restore the function to what 
      the 'current_function' field in the gc says it is. */
    SetFunction(gptr->gc,gptr->current_function); 
    return;
}

void switch_pen_mode(gptr)
GrafContextPtr	gptr;
{
	switch(gptr->pen_mode) {
	case copy:		gptr->current_function = GXcopy; break;
	case notcopy:	gptr->current_function = GXcopyInverted; break;
	case or:		gptr->current_function = (gptr->backColor) ? GXand : GXor; break;
	case notor:		gptr->current_function = (gptr->backColor) ? GXandInverted : GXorInverted; break;
	case xor:		gptr->current_function = (gptr->backColor) ? GXequiv : GXxor; break;
	case notxor:	gptr->current_function = (gptr->backColor) ? GXxor : GXequiv; break;
	case pen_clear:	gptr->current_function = (gptr->backColor) ? GXorInverted : GXandInverted; break;
	case notclear:	gptr->current_function = (gptr->backColor) ? GXor : GXand; break;
	}
	SetFunction(gptr->gc, gptr->current_function);
}
/* * * * * * * * * * * * * * * *
 * PROLOG $free_GC(+GC_Index)  *
 * * * * * * * * * * * * * * * */
BNRP_Boolean    free_GC(tcb)
    BNRP_TCB    *tcb;
{
    GrafContextPtr  g,pg;
    BNRP_result     result;

#ifdef xDEBUG
	if (DebugTrace) printf("free_GC\n"); 
#endif
    if (tcb->numargs != 1) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
	pg = g->prev_gptr;
	if ((g->font) && (pg->font) && (g->font->fid != pg->font->fid))
		XSetFont(display,pg->gc,pg->font->fid);
	if (g->foreColor != pg->foreColor)
		XSetForeground(display,pg->gc,pg->foreColor);
	if (g->backColor != pg->backColor)
		XSetBackground(display,pg->gc,pg->backColor);
	if (g->pensize != pg->pensize)
    	XSetLineAttributes(display,pg->gc,pg->pensize,LineSolid,CapButt,JoinMiter);
	SetClipRegion(pg);
	switch_fill_mode(pg);
	switch_pen_mode(pg);
	if (g->foreColorName)
		XtFree(g->foreColorName);
	if (g->backColorName)
		XtFree(g->backColorName);
	XtFree(g->fontInfo.name);
    XtFree((char *)g);

    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG multi_lineabs_C(+Gc_Index, +[X1,Y1,X2,Y2, etc..]) *
 *	Will draw multiple line segments, and will connect *
 * them properly, depending on the JOIN_STYLE in the GC	   *
 * (which I have set to JoinMiter).			   *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean	multi_lineabs(tcb)
	BNRP_TCB	*tcb;
{
    BNRP_result     result;
    BNRP_term       next;
    BNRP_tag	    intype;
    GrafContextPtr  g;
    XPoint	    	parms[MAX_LINE_SEGMENTS];
    int	            count=0;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2], &result) != BNRP_list) return FALSE;

   	/* Decompose the input list, and put it in the array parms[] */
   	next=result.term.first;
	while ((intype=BNRP_getNextValue(&next,&result)) != BNRP_end) {
		if (intype != BNRP_integer) return FALSE;
		parms[count].x=result.ival - g->left;

		if (BNRP_getNextValue(&next,&result) != BNRP_integer) return FALSE;
		parms[count++].y=result.ival - g->top;
	}
   	/* At this point, count contains the number of points in the parms array. */
   	XDrawLines(display,g->draw,g->gc,parms,count,CoordModeOrigin);
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG polygon_C(+Gc_Index, +[X1,Y1,X2,Y2, etc..])      *
 *	Will draw a polygon. 			     	   *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean	polygon(tcb)
	BNRP_TCB	*tcb;
{
    BNRP_result     result;
    BNRP_term       next;
    BNRP_tag	    intype;
    GrafContextPtr  g;
    XPoint	    	parms[MAX_LINE_SEGMENTS];
    int	            count=0;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2], &result) != BNRP_list) return FALSE;

    /* Decompose the input list, and put it in the array parms[] */
    next=result.term.first;
	while ((intype=BNRP_getNextValue(&next,&result)) != BNRP_end) {
		if (intype != BNRP_integer) return FALSE;
		parms[count].x=result.ival - g->left;

		if (BNRP_getNextValue(&next,&result) != BNRP_integer) return FALSE;
		parms[count++].y=result.ival - g->top;
	}
    /* At this point, count contains the number of points in the parms array. */
	if (g->fill_mode == hollow) {
		parms[count++] = parms[0];
		XDrawLines(display,g->draw,g->gc,parms,count,CoordModeOrigin);
	}
	else
		XFillPolygon(display,g->draw,g->gc,parms,count,Complex,CoordModeOrigin);
    return TRUE;
}

/* G R A P H I C S   A T T R I B U T E   C H A N G E   R O U T I N E S 
   ------------------------------------------------------------------- */

/* * * * * * * * * * * * * * * * * * * *
 * PROLOG forecolor_C(+Gc_Index, +Color)*
 * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    forecolor(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
	BNRP_tag	    intype;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    intype=BNRP_getValue(tcb->args[2],&result);
    if (intype==BNRP_symbol) {
		if (g->foreColorName && !strcmp(g->foreColorName,result.sym.sval))
			return TRUE;
		XSetForeground(display,g->gc,g->foreColor=get_pixel_by_name(result.sym.sval));
		g->foreColorName = XtRealloc(g->foreColorName, strlen(result.sym.sval)+1);
		strcpy(g->foreColorName,result.sym.sval);
    }
    else if (intype==BNRP_integer) {
		XSetForeground(display,g->gc,g->foreColor=AllocCustomColor((int)result.ival));
		XtFree(g->foreColorName);
		g->foreColorName = NULL;
	}
	else return FALSE;

    /*
     * yanzhou@bnr.ca:20/10/95: reset PlaneMask
     */
    if (g->fill_mode == invert)
        SetFunction(g->gc, GXinvert);
    else
        SetFunction(g->gc, g->current_function);

    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * *
 * PROLOG backcolor_C(+Gc_Index, +Color)*
 * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    backcolor(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    BNRP_tag	    intype;
	unsigned long	prev_color;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
	prev_color = g->backColor;
    intype=BNRP_getValue(tcb->args[2],&result);
    if (intype==BNRP_symbol) {
		if (g->backColorName && !strcmp(g->backColorName,result.sym.sval))
			return TRUE;
		XSetBackground(display,g->gc,g->backColor=get_pixel_by_name(result.sym.sval));
		g->backColorName = XtRealloc(g->backColorName, strlen(result.sym.sval)+1);
		strcpy(g->backColorName,result.sym.sval);
    }
    else if (intype==BNRP_integer) {
		XSetBackground(display,g->gc,g->backColor=AllocCustomColor((int)result.ival));
		XtFree(g->backColorName);
		g->backColorName = NULL;
	}
	else return FALSE;
	if (g->backColor != prev_color)
		switch_pen_mode(g);
    /*
     * yanzhou@bnr.ca:20/10/95: reset PlaneMask
     */
    if (g->fill_mode == invert)
        SetFunction(g->gc, GXinvert);
    else
        SetFunction(g->gc, g->current_function);

    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG penmode_C(+Gc_Index, +Transfermode) *
 * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    penmode(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    char            *mode;
	enum pen_modes	new_mode;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_symbol) return FALSE;
    mode=result.sym.sval;
	if (strcmp(mode,"copy") == 0)
		new_mode = copy;
	else if (strcmp(mode,"notcopy") == 0)
		new_mode = notcopy;
	else if (strcmp(mode,"or") == 0)
		new_mode = or;
	else if (strcmp(mode,"notor") == 0)
		new_mode = notor;
	else if (strcmp(mode,"xor") == 0)
		new_mode = xor;
	else if (strcmp(mode,"notxor") == 0)
		new_mode = notxor;
	else if (strcmp(mode,"clear") == 0)
		new_mode = pen_clear;
	else if (strcmp(mode,"notclear") == 0)
		new_mode = notclear;
	else return FALSE;

	if (new_mode != gptr->pen_mode) {
		gptr->pen_mode = new_mode;
		switch_pen_mode(gptr);
	}
    return TRUE;
}
  
/* * * * * * * * * * * * * * * * * * * * *
 * PROLOG pensize_C(+Gc_Index, +LineWidth)*
 * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    pensize(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    XSetLineAttributes(display,gptr->gc,gptr->pensize=(unsigned int)result.ival,LineSolid,CapButt,JoinMiter);
    
    return TRUE;
}

/* Returns an index to the bitmap table, using the same tcb as PENPAT, BACKPAT, and USERPAT.   
   Accepts either a pattern name, or resource and id description. 
   Returns -1  on failure.*/
int    get_pattern_index(tcb, draw)
    BNRP_TCB    *tcb;
    Drawable	draw;
{
    BNRP_result     result;
    BNRP_tag	    intype;
    int		    resource, index, hashpos;
    Pixmap	    pen_pattern;
    char	    patfile[BITMAP_NAMESIZE];

    if (tcb->numargs > 3) return -1;

    intype=BNRP_getValue(tcb->args[2],&result);
	if (intype==BNRP_symbol) {   /* User has specified a string for a pattern descriptor. */
		strncpy(patfile, result.sym.sval, BITMAP_NAMESIZE);
		hashpos=get_symbol_bitmap_entry(patfile, draw);

		/* If the user has requested a pattern other than the list of pre-defined names,
		load the pattern. */
		if (hashpos == NotPrologPattern)
			hashpos=get_bitmap(result.sym.sval,&pen_pattern, draw);
		if (hashpos == -1)
			XFreePixmap(display,pen_pattern);
		if (hashpos < 0) return -1;
	}
   	else if (intype == BNRP_integer) {  /* User has specified a resource and index for a pattern descriptor. */
	  	resource=result.ival;
      	if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return -1;
		index=result.ival;
	  	sprintf(patfile,"PAT%u.%02u.bit",resource,index);
	  	hashpos = get_bitmap(patfile,&pen_pattern,draw);
		if (hashpos == -1)
			XFreePixmap(display,pen_pattern);
		if (hashpos < 0) return -1;
    }
	else return -1;
    return hashpos;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * 
 * PROLOG penpat_C(+Gc_Index, +PatternName)      *
 *        penpat_C(+Gc_Index, +Resource, +Index) *
 *   The resource, index numbers are included    *
 * for Macintosh compatibility.  The Mac pats    *
 * are stored in the bitmaps subdirectory.       *
 * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    penpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    int             hashpos;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    hashpos=get_pattern_index(tcb, gptr->draw); 
    if (hashpos == -1) return FALSE;

    /* Insert the pattern index into the gc structure. */
    bitmap_table[hashpos].ispattern=TRUE;
	if (gptr->penpatindex == hashpos) return TRUE;
    gptr->penpatindex=hashpos;

    /* NOTE : If the fill pattern is set to EITHER pentype OR hollow, insert the 
      requested pattern into the GC. */
    if ((gptr->fill_mode == pentype)  || (gptr->fill_mode == hollow)) {
		XSetStipple(display,gptr->gc,bitmap_table[hashpos].bitimage);
	}
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG backpat_C(+Gc_Index, +PatternName)       *
 *        backpat_C(+Gc_Index, +Resource, +Index)  *
 *   The resource, index numbers are included      *
 * for Macintosh compatibility.  The Mac pats      *
 * are stored in the bitmaps subdirectory.         *
 * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    backpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    int             hashpos;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    hashpos=get_pattern_index(tcb, gptr->draw); 
    if (hashpos == -1) return FALSE;

    bitmap_table[hashpos].ispattern=TRUE;
	if (gptr->backpatindex == hashpos) return TRUE;
    gptr->backpatindex=hashpos;
    if (gptr->fill_mode == clear) {
		XSetStipple(display,gptr->gc,bitmap_table[hashpos].bitimage);
	}
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG userpat_C(+Gc_Index, +PatternName)       *
 *        userpat_C(+Gc_Index, +Resource, +Index)  *
 *   The resource, index numbers are included      *
 * for Macintosh compatibility.  The Mac pats      *
 * are stored in the bitmaps subdirectory.         *
 * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    userpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    int             hashpos;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    hashpos=get_pattern_index(tcb, gptr->draw); 
    if (hashpos == -1) return FALSE;

    bitmap_table[hashpos].ispattern=TRUE;
	if (gptr->userpatindex == hashpos) return TRUE;
    gptr->userpatindex=hashpos;
    if (gptr->fill_mode == usertype) {
		XSetStipple(display,gptr->gc,bitmap_table[hashpos].bitimage);
	}
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG fillpat_C(+Gc_Index, +FillPattern)					     *
 *	FillPattern may be one of :						     *
 * hollow  : All subsequent figures are NOT filled : only the outlines are drawn.    *
 * pentype : All subsequent figures are filled, using the PEN  pattern.		     *
 * usertype: All subsequent figures are filled, using the USER pattern.		     *
 * clear   : All subsequent figures are filled, using the BACK pattern. The pen mode *
 *          is temporarily changed to COPY, until another non-clear fillpat call, or *
 *          a user override (PENMODE).						     *
 * invert  : The pixels in the figure to be drawn are used to invert the             * 
 *          pixels already on the graphics screen.  The pen mode is temporarily      *
 *          changed to XOR.							     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    fillpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    char            *FillPattern;
	int				new_fill_mode;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_symbol) return FALSE;
    FillPattern=result.sym.sval;

    if (strcmp(FillPattern, "clear") == 0)
		new_fill_mode = clear;
    else if  (strcmp(FillPattern, "hollow") == 0)
		new_fill_mode = hollow;
    else if  (strcmp(FillPattern, "pentype") == 0)
		new_fill_mode = pentype;
    else if  (strcmp(FillPattern, "usertype") == 0)
		new_fill_mode = usertype;
    else if  (strcmp(FillPattern, "invert") == 0)
		new_fill_mode = invert;
	else return FALSE;

	if (new_fill_mode == gptr->fill_mode) return TRUE;

	gptr->fill_mode=new_fill_mode;

	switch_fill_mode(gptr);
	return TRUE;
}


/* G R A P H I C S   A T T R I B U T E   I N Q U I R Y   R O U T I N E S
   --------------------------------------------------------------------- */

/* * * * * * * * * * * * * * * * * * * * * *
 * PROLOG $inqforecolor(+Gc_Index, ?Color) *
 * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqforecolor(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    XGCValues       values;
    XColor	    color;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

	if (gptr->foreColorName == NULL) {
    	XGetGCValues(display,gptr->gc,GCForeground,&values);
		color.pixel=values.foreground;
		XQueryColor(display,DefaultColormap(display,DefaultScreen(display)),&color);
		return BNRP_unify(tcb, tcb->args[2], 
						BNRP_makeInteger(tcb, ((color.red & 0xFF00)<<8) | 
												(color.green & 0xFF00) | (color.blue >> 8)));
	}
	else
		return BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb,gptr->foreColorName));
}

/* * * * * * * * * * * * * * * * * * * * * *
 * PROLOG $inqbackcolor(+Gc_Index, ?Color) *
 * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqbackcolor(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    XGCValues       values;
    XColor	    color;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

	if (gptr->backColorName == NULL) {
    	XGetGCValues(display,gptr->gc,GCBackground,&values);
		color.pixel=values.background;
		XQueryColor(display,DefaultColormap(display,DefaultScreen(display)),&color);
		return BNRP_unify(tcb, tcb->args[2], 
						BNRP_makeInteger(tcb, ((color.red & 0xFF00)<<8) | 
												(color.green & 0xFF00) | (color.blue >> 8)));
	}
	else
		return BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb,gptr->backColorName));
}

/* * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqpenmode_C(+Gc_Index, ?Transfermode)*
 * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqpenmode(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    char            *gcmode;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    switch(gptr->pen_mode) {
		case copy:		gcmode="copy";		break;
        case notcopy:	gcmode="notcopy";	break;
        case or:		gcmode="or";		break;
        case notor:		gcmode="notor";		break;
        case xor:		gcmode="xor";		break;
        case notxor:	gcmode="notxor";	break;
        case pen_clear:	gcmode="clear";		break;
        case notclear:	gcmode="notclear";	break;
        default:	
#ifdef DEBUG
			printf ("ProGraf ERROR : Unknown PenMode value has been set./n");
#endif
			return FALSE;
	}

    return BNRP_unify(tcb, tcb->args[2],BNRP_makeSymbol(tcb,gcmode));
}
	
/* * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqpensize_C(+Gc_Index, ?LineWidth) *
 * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqpensize(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    return BNRP_unify(tcb, tcb->args[2],BNRP_makeInteger(tcb,(int)gptr->pensize));
}

/* If the string Pattern corresponds to a standard PROLOG pattern, return that pattern
  name.  Otherwise, return Pattern untouched. */
char	*prolog_symbol(Pattern)
	char	*Pattern;
{
	if (strcmp(Pattern,"PAT0.19.bit") == 0)	     return "white";
	else if (strcmp(Pattern,"PAT0.22.bit") == 0) return "lightgray";
	else if (strcmp(Pattern,"PAT0.03.bit") == 0) return "gray";
	else if (strcmp(Pattern,"PAT0.02.bit") == 0) return "darkgray";
	else if (strcmp(Pattern,"PAT0.00.bit") == 0) return "black";
	else return Pattern;
}

BNRP_Boolean    parse_bitmap_name(tcb,Bitmap_Name)
    BNRP_TCB    *tcb;
    char	*Bitmap_Name;
{
    int		    resource, id;
    char	    *new_patname;
	char		temp_name[BITMAP_NAMESIZE];

    new_patname = prolog_symbol(Bitmap_Name);
	strcpy(temp_name,Bitmap_Name);
    if ((sscanf(temp_name, "PAT%1u.%02u.bit", &resource, &id) == 2) && (strcmp(Bitmap_Name, new_patname) == 0)){
		/* The stored pen pattern must be returned in terms of resource and id numbers. */
		if (tcb->numargs != 3) return FALSE;
		return (BNRP_unify(tcb, tcb->args[2],BNRP_makeInteger(tcb,(int)resource)) &
		       (BNRP_unify(tcb, tcb->args[3],BNRP_makeInteger(tcb,(int)id))));
    }
    else {
		/* Otherwise, return the pattern name as it is stored in the bitmap table. */
		if (tcb->numargs != 2) return FALSE;
 		return BNRP_unify(tcb, tcb->args[2],BNRP_makeSymbol(tcb,new_patname));
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqpenpat_C(+Gc_Index, ?Pen_Pattern)  *
 *        inqpenpat_C(+Gc_Index, ?Resource, ?Id)*
 * 	Returns the current pen pattern.  If   *
 * the pattern was loaded using resource and   *
 * index numbers, and is not one of the PROLOG *
 * standard patterns (such as lightgray),      *
 * return the Res and ID numbers.	       *
 * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqpenpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    return parse_bitmap_name(tcb, bitmap_table[gptr->penpatindex].bitname);
}

/* * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqbackpat_C(+Gc_Index, ?Pen_Pattern)   *
 *        inqbackpat_C(+Gc_Index, ?Resource, ?Id) *
 *      Returns the current background pattern.  *
 * If the pattern was loaded using resource and  *
 * index numbers, and is not one of the PROLOG   *
 * standard patterns (such as lightgray),        *
 * return the Res and ID numbers.                *
 * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqbackpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    return parse_bitmap_name(tcb, bitmap_table[gptr->backpatindex].bitname);
}

/* * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inquserpat_C(+Gc_Index, ?Pen_Pattern)   *
 *        inquserpat_C(+Gc_Index, ?Resource, ?Id) *
 *      Returns the current user pattern. If     *
 * the pattern was loaded using resource and     *
 * index numbers, and is not one of the PROLOG   *
 * standard patterns (such as lightgray),        *
 * return the Res and ID numbers.                *
 * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inquserpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;
    return parse_bitmap_name(tcb, bitmap_table[gptr->userpatindex].bitname);
}

/* * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqfillpat_C(+Gc_Index, ?Fillpat) *
 * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    inqfillpat(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  gptr;
    char	    *fillpat;

    if (tcb->numargs != 2) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    gptr=(GrafContextPtr)result.ival;

    switch (gptr->fill_mode) {
		case hollow: 	fillpat="hollow";	break;
		case pentype: 	fillpat="pentype";	break;
		case usertype: 	fillpat="usertype";	break;
		case clear: 	fillpat="clear";	break;
		case invert: 	fillpat="invert";	break;
		default: 		return FALSE;
    }
    return BNRP_unify(tcb, tcb->args[2],BNRP_makeSymbol(tcb,fillpat));
}

/* G R A P H I C S   O U T P U T   R O U T I N E S
   ----------------------------------------------- */

/* * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG lineabs_C(+Gc_Index, +X1,+Y1,+X2,+Y2) *
 * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean lineabs(tcb)
BNRP_TCB *tcb;
{
	GrafContextPtr	g;
    BNRP_result 	p;
	int	x1,y1,x2,y2;

	if (tcb->numargs != 5) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr)p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	x1 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	y1 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[4], &p) != BNRP_integer) return FALSE;
	x2 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[5], &p) != BNRP_integer) return FALSE;
	y2 = (int) p.ival; 

   	XDrawLine(display,g->draw,g->gc,x1-g->left,y1-g->top, x2-g->left,y2-g->top);
	return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * *
 * PROLOG rectabs_C(+Gc_Index, +L,+T,+R,+B) *
 * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean rectabs(tcb)
BNRP_TCB *tcb;
{
	GrafContextPtr	g;
    BNRP_result 	p;
	int	x1,y1,x2,y2,height,width;

	if (tcb->numargs != 5) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr)p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	x1 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	y1 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[4], &p) != BNRP_integer) return FALSE;
	x2 = (int) p.ival; 
	if (BNRP_getValue(tcb->args[5], &p) != BNRP_integer) return FALSE;
	y2 = (int) p.ival; 
	
	height = y2-y1-1;
	width  = x2-x1-1;
	if (height<0) height = 0;
	if (width<0)  width = 0;

	if (g->fill_mode == hollow) 
		XDrawRectangle(display,g->draw,g->gc,x1-g->left,y1-g->top,width,height);
	else 
		XFillRectangle(display,g->draw,g->gc,x1-g->left,y1-g->top,width+1,height+1);

	return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG arcabs_C(+Gc_Index, +L,+T,+R,+B,StartAngle,ArcAngle)*
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    arcabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    int		    x1,y1,x2,y2,startangle,arcangle,width,height;

    if (tcb->numargs != 7) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;

    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    x1=(int)result.ival;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    y1=(int)result.ival;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    x2=(int)result.ival;
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    y2=(int)result.ival;
    if (BNRP_getValue(tcb->args[6],&result) != BNRP_integer) return FALSE;
    startangle=(int)(result.ival*64);
    if (BNRP_getValue(tcb->args[7],&result) != BNRP_integer) return FALSE;
    arcangle=(int)(result.ival*64);

	width = x2-x1;
	height = y2-y1;

    if (g->fill_mode == hollow)
   	 	XDrawArc(display,g->draw,g->gc,x1-g->left,y1-g->top,width-1,height-1,startangle,arcangle);
    else 
   	 	XFillArc(display,g->draw,g->gc,x1-g->left,y1-g->top,width,height,startangle,arcangle);
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * *
 * PROLOG ovalabs_C(+Gc_Index, +L,+T,+R,+B) *
 * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    ovalabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    int             x1,y1,x2,y2,w,h;

    if (tcb->numargs != 5) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    x1=(int)result.ival;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    y1=(int)result.ival;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    x2=(int)result.ival;
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    y2=(int)result.ival;

	w = x2-x1;
	h = y2-y1;

    if (g->fill_mode == hollow)
    	XDrawArc(display,g->draw,g->gc,x1-g->left,y1-g->top,w-1,h-1,(int)0,(int)(360*64));
    else 
    	XFillArc(display,g->draw,g->gc,x1-g->left-1,y1-g->top-1,w+1,h+1,(int)0,(int)(360*64));
    return TRUE;
}

/* an attempt to remove any dependency on Xmu by placing the source for
   XmuDrawRoundedRectangle and XmuFillRoundedRectangle within ProGraf.c */

void 
XmuDrawRoundedRectangle (dpy, draw, gc, x, y, w, h, ew, eh)
    Display		*dpy;
    Drawable		draw;
    GC			gc;
    int			x, y, w, h, ew, eh;
{
	XArc	arcs[8];

	if (ew*2 > w)
	    ew = 0;
	if (eh*2 > h)
	    eh = 0;

	arcs[0].x = x;
	arcs[0].y = y;
	arcs[0].width = ew*2;
	arcs[0].height = eh*2;
	arcs[0].angle1 = 180*64;
	arcs[0].angle2 = -90*64;

	arcs[1].x = x + ew;
	arcs[1].y = y;
	arcs[1].width = w - ew*2;
	arcs[1].height = 0;
	arcs[1].angle1 = 180*64;
	arcs[1].angle2 = -180*64;

	arcs[2].x = x + w - ew*2;
	arcs[2].y = y;
	arcs[2].width = ew*2;
	arcs[2].height = eh*2;
	arcs[2].angle1 = 90*64;
	arcs[2].angle2 = -90*64;

	arcs[3].x = x + w;
	arcs[3].y = y + eh;
	arcs[3].width = 0;
	arcs[3].height = h - eh*2;
	arcs[3].angle1 = 90 * 64;
	arcs[3].angle2 = -180*64;

	arcs[4].x = x + w - ew*2;
	arcs[4].y = y + h - eh*2;
	arcs[4].width = ew * 2;
	arcs[4].height = eh * 2;
	arcs[4].angle1 = 0;
	arcs[4].angle2 = -90*64;

	arcs[5].x = x + ew;
	arcs[5].y = y + h;
	arcs[5].width = w - ew*2;
	arcs[5].height = 0;
	arcs[5].angle1 = 0;
	arcs[5].angle2 = -180*64;

	arcs[6].x = x;
	arcs[6].y = y + h - eh*2;
	arcs[6].width = ew*2;
	arcs[6].height = eh*2;
	arcs[6].angle1 = 270*64;
	arcs[6].angle2 = -90*64;

	arcs[7].x = x;
	arcs[7].y = y + eh;
	arcs[7].width = 0;
	arcs[7].height = h - eh*2;
	arcs[7].angle1 = 270*64;
	arcs[7].angle2 = -180*64;
	XDrawArcs (dpy, draw, gc, arcs, 8);
}

void
XmuFillRoundedRectangle (dpy, draw, gc, x, y, w, h, ew, eh)
    Display		*dpy;
    Drawable		draw;
    GC			gc;
    int			x, y, w, h, ew, eh;
{
	XArc	arcs[4];
	XRectangle rects[3];
	XGCValues vals;

	XGetGCValues(dpy, gc, GCArcMode, &vals);
	if (vals.arc_mode != ArcPieSlice)
	    XSetArcMode(dpy, gc, ArcPieSlice);

	if (ew*2 > w)
	    ew = 0;
	if (eh*2 > h)
	    eh = 0;

	arcs[0].x = x;
	arcs[0].y = y;
	arcs[0].width = ew*2;
	arcs[0].height = eh*2;
	arcs[0].angle1 = 180*64;
	arcs[0].angle2 = -90*64;

	arcs[1].x = x + w - ew*2;
	arcs[1].y = y;
	arcs[1].width = ew*2;
	arcs[1].height = eh*2;
	arcs[1].angle1 = 90*64;
	arcs[1].angle2 = -90*64;

	arcs[2].x = x + w - ew*2;
	arcs[2].y = y + h - eh*2;
	arcs[2].width = ew*2;
	arcs[2].height = eh*2;
	arcs[2].angle1 = 0;
	arcs[2].angle2 = -90*64;

	arcs[3].x = x;
	arcs[3].y = y + h - eh*2;
	arcs[3].width = ew*2;
	arcs[3].height = eh*2;
	arcs[3].angle1 = 270*64;
	arcs[3].angle2 = -90*64;

	XFillArcs (dpy, draw, gc, arcs, 4);

	rects[0].x = x + ew;
	rects[0].y = y;
	rects[0].width = w - ew*2;
	rects[0].height = h;

	rects[1].x = x;
	rects[1].y = y + eh;
	rects[1].width = ew;
	rects[1].height = h - eh*2;

	rects[2].x = x + w - ew;
	rects[2].y = y + eh;
	rects[2].width = ew;
	rects[2].height = h - eh*2;

	XFillRectangles (dpy, draw, gc, rects, 3);

	if (vals.arc_mode != ArcPieSlice)
	    XSetArcMode(dpy, gc, vals.arc_mode);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG rrectabs_C(+Gc_Index, +L,+T,+R,+B,OvalWidth,OvalHeight) *
 * Draws a rounded rectangle.					 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    rrectabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    int             L,T,R,B,width,height,OvalWidth,OvalHeight,xmidL,xmidR,ymidT,ymidB;

    if (tcb->numargs != 7) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    L=(int)result.ival-g->left;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    T=(int)result.ival-g->top;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    R=(int)result.ival-g->left;
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    B=(int)result.ival-g->top;
    if (BNRP_getValue(tcb->args[6],&result) != BNRP_integer) return FALSE;
    OvalWidth=(unsigned int)result.ival/2;
    if (BNRP_getValue(tcb->args[7],&result) != BNRP_integer) return FALSE;
    OvalHeight=(unsigned int)result.ival/2;

    xmidL=(int)(L+OvalWidth);
   	xmidR=(int)(R-OvalWidth);
   	ymidT=(int)(T+OvalHeight);
   	ymidB=(int)(B-OvalHeight);

	width = R-L;
	height = B-T;

    /* Check if the ovals used to draw the rounded corners overlap. */
    if ((xmidL > xmidR) || (ymidT > ymidB)) return FALSE;
	
    if (g->fill_mode == hollow) 
		XmuDrawRoundedRectangle(display,g->draw,g->gc,L,T,width,height,OvalWidth,OvalHeight);
    else 
		XmuFillRoundedRectangle(display,g->draw,g->gc,L-1,T-1,width+3,height+3,OvalWidth,OvalHeight);
    return TRUE;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG inqcrectabs_C (+Gc_Index, -L,-T,-R,-B)         *
 * Queries the user-specified clipping rectangle. 	     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean	inqcrectabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    Position        left,top,right,bottom;
	
    if (tcb->numargs != 5) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
	if (g->default_clip_rect)  {
		/* default clipping rectangle - return the whole window */
		left = 0;
		top = 0;
		right = (Position)(g->parent_window->width);
		bottom = (Position)(g->parent_window->height);
		}
	else { /* return user clipping rectangle */
		left = g->clip_rect.x;
                top = g->clip_rect.y;
		right = g->clip_rect.x+g->clip_rect.width; 
		bottom = g->clip_rect.y+g->clip_rect.height; 
		}	
#ifdef DEBUG
	if (DebugTrace) printf("Inqcrectabs %d %d %d %d\n",left,top,right,bottom);
#endif 

	return BNRP_unify(tcb,tcb->args[2],
				BNRP_makeInteger(tcb, (long)left)) &&
		   BNRP_unify(tcb,tcb->args[3],
				BNRP_makeInteger(tcb, (long)top)) &&
		   BNRP_unify(tcb,tcb->args[4],
				BNRP_makeInteger(tcb, (long)right)) &&
		   BNRP_unify(tcb,tcb->args[5],
				BNRP_makeInteger(tcb, (long)bottom));
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG crectabs_C (+Gc_Index, +L,+T,+R,+B)         *
 * Sets the user-specified clipping rectangle. 	     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean	crectabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;

    if (tcb->numargs != 5) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;

    /* Set the clip_rect field in the given GrafContextRec structure */
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    g->clip_rect.x=(short)result.ival;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    g->clip_rect.y=(short)result.ival;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    g->clip_rect.width  = (unsigned short)((short)result.ival-g->clip_rect.x);	
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    g->clip_rect.height = (unsigned short)((short)result.ival-g->clip_rect.y);	
#ifdef DEBUG
    if (DebugTrace) 
	printf("crectabs %d %d %d %d\n",g->clip_rect.x,g->clip_rect.y,g->clip_rect.x
         +g->clip_rect.width,g->clip_rect.y+g->clip_rect.height);
#endif 
    g->default_clip_rect = FALSE;
    SetClipRegion(g);
    return TRUE;
}
	  
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG iconabs_C(+Gc_Index, +L,+T,+R,+B,+IconResource)*
 *    Retreives an icon, scales it to fit in the given   *
 * rectangle, and draws it as a stipple, using the       *
 * current foreground and background colors.             *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
BNRP_Boolean    iconabs(tcb)
    BNRP_TCB    *tcb;
{
    BNRP_result     result;
    GrafContextPtr  g;
    int         L,T,R,B,resource,hashpos;
    char	    iconfile[BITMAP_NAMESIZE];
    Pixmap	    iconmap,  scaled_iconmap;
	Boolean		scaled;
	unsigned int	width,height;

    if (tcb->numargs != 6) return FALSE;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    L=(int)result.ival;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    T=(int)result.ival;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    R=(int)result.ival;
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    B=(int)result.ival;
    if (BNRP_getValue(tcb->args[6],&result) != BNRP_integer) return FALSE;
    resource=(int)result.ival;

    sprintf(iconfile,"ICON%06d.bit",resource);
    hashpos=get_bitmap(iconfile, &iconmap, g->draw);
    if (hashpos >= 0) 
    	bitmap_table[hashpos].ispattern=FALSE;
	if (hashpos < -1)
		return FALSE;

	width = R-L;
	height = B-T;
	if ((width == ICON_SIZE) && (height == ICON_SIZE)) {
		scaled = FALSE;
		scaled_iconmap = iconmap;
	}
	else {
		scaled = TRUE;
		scaled_iconmap = XCreatePixmap(display,g->draw,width,height,1);
		if (!createdSinglePlaneGC) {
			singlePlaneGC = XCreateGC(display,scaled_iconmap,0,NULL);
			createdSinglePlaneGC = TRUE;
		}
		ScalePixmap(singlePlaneGC, iconmap, scaled_iconmap, ICON_SIZE, ICON_SIZE,width, height);
	}

	XCopyPlane(display,scaled_iconmap,g->draw,g->gc,0,0,width,height,L-g->left,T-g->top,1);

	if (scaled)
    	XFreePixmap(display,scaled_iconmap);
	if (hashpos == -1)
		XFreePixmap(display,iconmap);
    return TRUE;
}

/* E N D   O F   G R A P H I C   O U T P U T   P R I M I T I V E S 			       */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#if 0
/* 
 * disabled by yanzhou@bnr.ca 20/10/95
 * reason: the handling of textEditState is now centralized in
 *         function `eventLoop'
 */

/* LosingFocusCB - callback for losing focus in the editbox text widget. 
   Set the text edit state to FALSE. */

void LosingFocusCB(w,client_data,call_data)
Widget     w;              /* widget id */
XtPointer client_data;     /* data from application */
XmTextVerifyPtr    call_data;      /* data from widget class */

{  
#ifdef xDEBUG
   if (DebugTrace) printf("LosingFocusCB.\n");
#endif
#ifdef lint
	if (client_data) ;
#endif

	if (call_data->reason == XmCR_LOSING_FOCUS) {
   		textEditState = FALSE;
        if (!XmTextGetSelectionPosition(w,&editSelStart,&editSelEnd))
   			editSelStart = editSelEnd = XmTextGetInsertionPosition(w);
    }
}
#endif

/* EditBoxChangedCB - callback for the value changing in the editbox
   text widget. If a character in the editexit set is entered, set DOIT 
   to FALSE to prevent the character being processed by the text widget. */

void EditBoxChangedCB(w,client_data,call_data)
Widget     w;              /* widget id */
XtPointer client_data;     /* data from application */
XmTextVerifyPtr    call_data;      /* data from widget class */

{  	
	char       code[16]; /* must be large enough to hold rebound keysyms */
   	KeySym     keysym;
    int        num;
 
#ifdef DEBUG
   	if (DebugTrace) printf("In EditBoxChangedCB.\n");
#endif
#ifdef lint
	if (w) ;
	if (client_data) ;
#endif

    call_data->doit = TRUE;
    if ((call_data->event) && (call_data->event->type == KeyPress)) {
        num = XLookupString((XKeyEvent *)call_data->event,code,sizeof(code),&keysym,NULL);
        /* call_data->doit = !memberEditExitSet(num,code,keysym);       */
        call_data->doit = textEditState;        /* do it if not exiting */
    }
}

/* AnalyseTextParms - analyses the parameters for editbabs */

Boolean AnalyseTextParms(tcb,gptr,window,x,y,width,height,textstring,
                         selstart,selend,linenum)

   BNRP_TCB        *tcb;
   GrafContextPtr  *gptr;
   PGrafWindow     **window;
   Position        *x,*y;
   Dimension       *width,*height;
   char            **textstring;
   XmTextPosition  *selstart, *selend;
   int             *linenum;

{   BNRP_result     result,p[3];
    BNRP_term       curr_term;

    *textstring = NULL;
    *selstart = *selend = *linenum = 0;

    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    *gptr = (GrafContextPtr)result.ival;
    *window = (PGrafWindow *)((*gptr)->parent_window);

    /* get the rectangle boundaries */
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    *x=(Position)result.ival;

    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    *y=(Position)result.ival;

    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    *width = (Dimension)(result.ival - *x);
#ifdef DEBUG
    if (DebugTrace) printf("Editbabs (%d,%d) width %d, ",*x,*y,*width);
#endif

    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    *height = (Dimension)(result.ival - *y);
#ifdef DEBUG
    if (DebugTrace) printf("height %d.\n",*height);
#endif
    if (BNRP_getValue(tcb->args[6],&result) != BNRP_list) return FALSE;
    curr_term = result.term.first;
    if ((BNRP_getIndexedValue(curr_term,1,&p[0]) != BNRP_symbol) ||
        (BNRP_getIndexedValue(curr_term,2,&p[1]) != BNRP_symbol) ||
        (BNRP_getIndexedValue(curr_term,3,&p[2]) != BNRP_symbol) ||
		(BNRP_getIndexedValue(curr_term,4,&result) != BNRP_integer)) return FALSE;
		
    *textstring = XtMalloc(strlen(p[0].sym.sval)+strlen(p[1].sym.sval)+strlen(p[2].sym.sval) + 1);
    strcpy(*textstring,p[0].sym.sval);
    strcat(*textstring,p[1].sym.sval);
    strcat(*textstring,p[2].sym.sval);
    *selstart = strlen(p[0].sym.sval);
    *selend = *selstart + strlen(p[1].sym.sval);
    if (((*linenum) = result.ival) < 0)
    	*linenum = 0;
    else if ((*linenum+1) > strlen(*textstring)) 
    	*linenum = strlen(*textstring) - 1;

#ifdef DEBUG
    if (DebugTrace)
        printf("Textstring[%d] is '%s', selstart = %d, selend = %d, linenum = %d.\n",
                 strlen(*textstring),*textstring,*selstart,*selend,*linenum);
#endif
    return TRUE;
}





/* IntersectRect - returns the intersection of the two rectangles */

void IntersectRect(R1,R2,Result)
     XRectangle R1,R2,*Result;
{
   Result->x = (R1.x > R2.x) ? R1.x : R2.x;
   Result->y = (R1.y > R2.y) ? R1.y : R2.y;
   Result->width = ((R1.x+R1.width) < (R2.x+R2.width)) ? 
                       (R1.x+R1.width-Result->x) : (R2.x+R2.width-Result->x);
   Result->height = ((R1.y+R1.height) < (R2.y+R2.height)) ? 
                       (R1.y+R1.height-Result->y) : (R2.y+R2.height-Result->y);
#ifdef DEBUG
   if (DebugTrace)
      printf("Intersect (%d,%d,%d,%d) with (%d,%d,%d,%d) gives (%d,%d,%d,%d)\n",
              R1.x,R1.y,R1.width+R1.x,R1.height+R1.y,
              R2.x,R2.y,R2.width+R2.x,R2.height+R2.y,
              Result->x,Result->y,Result->width+Result->x,Result->height+Result->y);
#endif

}
/* the procedure for matching key bindings to strings that have
meaning for XStringToKeysym */


     



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG editbabs_C (+Gc_Index, +L,+T,+R,+B,+textin,-textout, *
 *                   -E,-W,-Data1,-Data2,+Editexitset)         *
 *                                                             *
 * NOT A DOGRAF PRIMITIVE ANY LONGER!                          *
 *                                                             *
 *      Creates an editable text box in the rectangle. The     *
 * text box is preloaded with the contents of the textin       *
 * parameter and a text editing state is entered. The system   *
 * remains in the text editing state until a non text editing  *
 * event occurs. The current text is then unified with the     *
 * textout parameter. The event which terminates the text edit *
 * state is returned. The edit exit set parm is optional. If   *
 * not specified, the default is used.                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

BNRP_Boolean    editbabs(tcb)
    BNRP_TCB    *tcb;
{
    GrafContextPtr  gptr;
    PGrafWindow     *window;
    Position        x,y;
    Dimension       width,height;
    char            *editstring;
    char            *outstring;
    XmTextPosition  selstart,selend;
    int             linenum;
    BNRP_term       textoutTerm;
    int             n;
    Arg             args[15];
    XmFontList      fontList;
    BNRP_result     p;
    BNRP_tag        tag;
    BNRP_term       term;
    XGCValues       values;
    XRectangle      edit_rect,view_rect;
    Widget          editbox_clip;
    int             stringLength;
    

#ifdef DEBUG
   if (DebugTrace) printf("In $editbabs.\n");
#endif
    if (tcb->numargs != 12) return FALSE;

    /* Analyse the parameters and create an edit box with the initial string */
    if (! AnalyseTextParms(tcb,&gptr,&window,&x,&y,&width,&height,
                           &editstring,&selstart,&selend,&linenum))
       return FALSE;
    
    /* Pick up the edit exit set characters */
    numExitChars = 0;
    if ((tag = BNRP_getValue(tcb->args[12],&p)) != BNRP_list) {
		XtFree(editstring);
		return FALSE;
	}
    term = p.term.first;
    while ((tag = BNRP_getNextValue(&term,&p)) != BNRP_end) {
    	if ((tag == BNRP_symbol) && (numExitChars < MAXEXITCHARS)) {
        	if (strlen(p.sym.sval) == 1) {
            	/* single char symbol, add to editExitSet */
                editExitSet[numExitChars].ascii = TRUE;
                editExitSet[numExitChars].u.ascii_value = p.sym.sval[0];
			}
            else { /* symbolic name */
            	editExitSet[numExitChars].ascii = FALSE;
		
                if ((editExitSet[numExitChars].u.keysym = StringToKeysym(p.sym.sval)) == NoSymbol) 
                {                	
                    XtFree(editstring);
                    return FALSE;
                }
#ifdef DEBUG
                if (DebugTrace)
                	printf("keysym %X is %s\n", editExitSet[numExitChars].u.keysym,p.sym.sval);
#endif
            }
		}
        else {
			XtFree(editstring);
            return FALSE;
        }
        numExitChars ++;
	}

    /* Fill the editbox rectangle to prevent the backing store from
       restoring the previous contents when the edit box is taken down.
       Interchange foreground and background colours temporarily in the gc. */
    XGetGCValues(display,gptr->gc,GCForeground|GCBackground,&values);
    XSetForeground(display,gptr->gc,values.background);
    XSetBackground(display,gptr->gc,values.foreground);
    XFillRectangle(display,gptr->draw,gptr->gc,x,y,width,height);
    XSetForeground(display,gptr->gc,values.foreground);
    XSetBackground(display,gptr->gc,values.background);

    /* Create a widget behind the edit box to clip the edit box, if needed */
    n = 0;
    if (gptr->default_clip_rect)
       { view_rect.x = x;
         view_rect.y = y;
         view_rect.width = width;
         view_rect.height = height;
       }
    else /* intersect editbox with clip rectangle */
       { edit_rect.x = (short) x;
         edit_rect.y = (short) y;
         edit_rect.width = (unsigned short) width;
         edit_rect.height = (unsigned short) height;
         IntersectRect(gptr->clip_rect,edit_rect,&view_rect);
       }
    if (((short)view_rect.height > 0) && ((short)view_rect.width > 0))
       { XtSetArg(args[n],XmNx,view_rect.x); n++;
         XtSetArg(args[n],XmNy,view_rect.y); n++;
         XtSetArg(args[n],XmNwidth,view_rect.width); n++;
         XtSetArg(args[n],XmNheight,view_rect.height); n++;
         XtSetArg(args[n],XmNmarginHeight,0); n++;
         XtSetArg(args[n],XmNmarginWidth,0); n++;
        }
    else { /* edit box will not be visible */
#ifdef DEBUG
          if (DebugTrace) 
              printf("Editbabs - box is not visible\n");
#endif
          XtFree(editstring);
            return FALSE;
         }

    editbox_clip = XmCreateDrawingArea(window->canvas,"editbox_clip",args,n);
    XtManageChild(editbox_clip);

    /* Create the edit box */
    n = 0;
    XtSetArg(args[n],XmNx,x - view_rect.x); n++;
    XtSetArg(args[n],XmNy,y - view_rect.y); n++;
    XtSetArg(args[n],XmNwidth,width); n++;
    XtSetArg(args[n],XmNheight,height); n++;
    XtSetArg(args[n],XmNwordWrap,TRUE); n++;
    XtSetArg(args[n],XmNverifyBell,FALSE); n++;
    XtSetArg(args[n],XmNmarginHeight,0); n++;
    XtSetArg(args[n],XmNmarginWidth,0); n++;
    XtSetArg(args[n],XmNhighlightThickness,0); n++;
    XtSetArg(args[n],XmNshadowThickness,0); n++;
    XtSetArg(args[n],XmNeditMode,XmMULTI_LINE_EDIT); n++;
    XtSetArg(args[n],XmNpendingDelete,TRUE); n++;
    /* set the font for the widget */
	if (gptr->font)
    	XtSetArg(args[n],XmNfontList,fontList=XmFontListCreate(gptr->font,charset)); n++;
    editbox = XmCreateText(editbox_clip,"editbox",args,n);
	if (gptr->font)
    	XmFontListFree(fontList);
    XtManageChild(editbox);

    /* Set up the initial edit box string contents */
    XmTextSetString(editbox,editstring);

    /* if last event was a mouse down, use position to set cursor */
    if (PrologEvent->type == usermousedown)
    {  
        PUserMouseEvent *pe = (PUserMouseEvent *) PrologEvent;
        XmTextSetInsertionPosition(editbox,
                                   XmTextXYToPos(editbox,pe->mouselx-x,pe->mousely-y));
    }
    else  /* use textin specification */
    {
        XmTextSetInsertionPosition(editbox,selend);
        if (window == (PGrafWindow *) focus_window)
            XmTextSetSelection(editbox,selstart,selend,XtLastTimestampProcessed(display));
        else
            XmTextSetHighlight(editbox,selstart,selend,XmHIGHLIGHT_SELECTED);
    }
    XmTextSetTopCharacter(editbox,linenum);
    XtFree(editstring);

    /*********  Deleted 21/04/95
    XtAddCallback(editbox,XmNmodifyVerifyCallback,EditBoxChangedCB,NULL);
    XtAddCallback(editbox,XmNlosingFocusCallback,LosingFocusCB,NULL);
    ***********/
    /*  Add callbacks to the editbox to identify non textediting events */
    XtAddCallback(editbox,XmNmodifyVerifyCallback,(XtCallbackProc)EditBoxChangedCB,NULL);
    /*********  Disabled 20/10/95 by yanzhou@bnr.ca
    XtAddCallback(editbox,XmNlosingFocusCallback,(XtCallbackProc)LosingFocusCB,NULL);
    **********/

    /* Register for keypress events */
    XtAddEventHandler(editbox,KeyPressMask,FALSE,KeyPressCB,window);

    /* Give edit box the keyboard focus */
    XmAddTabGroup(editbox);
    XmProcessTraversal(editbox,XmTRAVERSE_CURRENT);

    /* Now go into local event loop to process text editing events.
       Non text editing events set the textEditState FALSE. */
    textEditState = TRUE;
    do
      eventLoop();
    while (textEditState);

    /* retrieve the final value of textout */
    editstring = XmTextGetString(editbox);
    stringLength = strlen(editstring);
    textoutTerm = BNRP_startList(tcb);

    /* yanzhou@bnr.ca 18/04/96: 
     * if there is no selection at all, use the insertion position */
    if (!XmTextGetSelectionPosition(editbox,&selstart,&selend) || (selstart == selend))
        selstart = selend = XmTextGetInsertionPosition(editbox);

    /*
     * ADDED 17/04/96 by yanzhou@bnr.ca
     *   to cope with the situation where the values of 
     *   selstart and selend are invalid (eg, > strlen(editstring))
     */
    if (selstart < 0) selstart = 0;
    if (selend > stringLength) selend = stringLength;
    if (selstart > selend) selstart = selend;
 
    outstring = XtMalloc(stringLength + 1);
 
    /* text before the selection */
    memcpy(outstring,editstring,selstart);
    outstring[selstart] = '\0';
    BNRP_addTerm(tcb,textoutTerm,BNRP_makeSymbol(tcb,outstring));

    /* text in the selection     */
    memcpy(outstring,editstring+selstart,selend-selstart);
    outstring[selend-selstart] = '\0';
    BNRP_addTerm(tcb,textoutTerm,BNRP_makeSymbol(tcb,outstring));

    /* text after the selection  */
    memcpy(outstring,editstring+selend,stringLength - selend);
    outstring[stringLength - selend] = '\0';
    BNRP_addTerm(tcb,textoutTerm,BNRP_makeSymbol(tcb,outstring));

    BNRP_addTerm(tcb,textoutTerm, BNRP_makeInteger(tcb,(long int) XmTextGetTopCharacter(editbox)));
#ifdef DEBUG
    /* printf("TextSetSelection(%d,%d)\n",selstart,selend); */
#endif

    /* destroy widget */
    XtDestroyWidget(editbox_clip);
    XtFree(editstring);
    XtFree(outstring);

    return BNRP_unify(tcb,tcb->args[7],textoutTerm) &&
           FormatPrologEvent(tcb,8,PrologEvent);

}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * PROLOG scrollrect_C (+Gc_Index, +L,+T,+R,+B, +deltaX, +deltaY) *
 * 	Scrolls a rectangular region of a graphics window by     *
 * a horiz/vert displacement.  Exposed regions are filled in     *
 * with the window's current background pattern.                 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* P R O B L E M   W I T H   R O U T I N E :

	If the scrollrect primitive is executed two times in succession, they seem
to interfere with one another.  Eg. The result from the first scrollrect call hasn't
been drawn until halfway through the second scrollrect call. */
BNRP_Boolean    scrollrect(tcb)
    BNRP_TCB    *tcb;
{
	BNRP_result     result;
    GrafContextPtr  g;
    int		    L,T,R,B,deltaX,deltaY,srcX,srcY,destX,destY;
    int	            width,height;
    XGCValues       values;

    if (tcb->numargs != 7) return FALSE;
    if (BNRP_getValue(tcb->args[1],&result) != BNRP_integer) return FALSE;
    g=(GrafContextPtr)result.ival;
    if (BNRP_getValue(tcb->args[2],&result) != BNRP_integer) return FALSE;
    L=(int)result.ival;
    if (BNRP_getValue(tcb->args[3],&result) != BNRP_integer) return FALSE;
    T=(int)result.ival;
    if (BNRP_getValue(tcb->args[4],&result) != BNRP_integer) return FALSE;
    R=(int)result.ival;
    if (BNRP_getValue(tcb->args[5],&result) != BNRP_integer) return FALSE;
    B=(int)result.ival;
    if (BNRP_getValue(tcb->args[6],&result) != BNRP_integer) return FALSE;
    deltaX=(int)result.ival;
    if (BNRP_getValue(tcb->args[7],&result) != BNRP_integer) return FALSE;
    deltaY=(int)result.ival;

    if ((deltaX == 0) && (deltaY == 0)) return TRUE;

	if (deltaX >= 0) {
		width = R-L-deltaX;
		srcX  = L;
		destX = L+deltaX;
	}
	else {
		width = R-L+deltaX;
		srcX  = L-deltaX;
		destX = L;
	}
	if (deltaY >= 0) {
		height = B-T-deltaY;
		srcY   = T;
		destY  = T+deltaY;
	}
	else {
		height = B-T+deltaY;
		srcY   = T-deltaY;
		destY  = T;
	}

    XGetGCValues(display,g->gc,GCStipple,&values);	/* Save existing stipple pattern */

    /* Set stipple pattern temporarily to the background pattern. */
    XSetStipple(display,g->gc,bitmap_table[g->backpatindex].bitimage);

    /*  Perform the actual scroll, which consists of cutting and pasting a region  */
    XCopyArea(display,g->draw, g->draw,g->gc, srcX,srcY,width,height,destX,destY);

    /* REPLACE THE PIXELS THAT WILL BE NEWLY EXPOSED BY THE SCROLL BY THE BACKGROUND PATTERN.*/
	if (deltaX > 0) 
		XFillRectangle(display,g->draw,g->gc,L,T,deltaX,B-T);
	else if (deltaX < 0)
		XFillRectangle(display,g->draw,g->gc,R+deltaX,T,-deltaX,B-T);

	if (deltaY > 0) 
		XFillRectangle(display,g->draw,g->gc,L,T,R-L,deltaY);
	else if (deltaY < 0)
		XFillRectangle(display,g->draw,g->gc,L,B+deltaY,R-L,-deltaY);

    XSetStipple(display,g->gc,values.stipple);
	return TRUE;
}

/* Prolog primitive gettextsize(+W,?Size) */
BNRP_Boolean getGrafTextSize(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	return commonGetTextSize(tcb, &g->fontInfo);
}

/* Prolog primitive gettextfont(+W,?Font) */
BNRP_Boolean getGrafTextFont(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	return commonGetTextFont(tcb, &g->fontInfo);
}

BNRP_Boolean setGrafTextSize(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;
	Boolean	res = FALSE;
	XFontStruct		*font;
	FontInfo	info;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	if (p.ival == g->fontInfo.size) return TRUE;

	info.name = g->fontInfo.name;
	info.size = p.ival;	
	info.weight = g->fontInfo.weight;
	info.slant = g->fontInfo.slant;
	if (font = getFont(&info,FALSE)) {
		res = TRUE;
		g->fontInfo.size = p.ival;
		g->font = font;
		XSetFont(display, g->gc, font->fid);
	}
		
	return res;
}

/* Prolog primitive settextfont(+W,+Font) */
BNRP_Boolean setGrafTextFont(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;
	Boolean	res = FALSE;
	XFontStruct		*font;
	FontInfo	info;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	if (strcmp(g->fontInfo.name,p.sym.sval) == 0) return TRUE;

	info.name = p.sym.sval;
	info.size = g->fontInfo.size;	
	info.weight = g->fontInfo.weight;
	info.slant = g->fontInfo.slant;
	if (font = getFont(&info,FALSE)) {
		g->fontInfo.name = XtRealloc(g->fontInfo.name,strlen(p.sym.sval)+1);
		strcpy(g->fontInfo.name, p.sym.sval);
		g->font = font;
		XSetFont(display, g->gc, font->fid);
		res = TRUE;
	}
	return res;
}
BNRP_Boolean getGrafTextFace(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	return commonGetTextFace(tcb,&g->fontInfo);
}

/* Prolog primitive settextface(+W,+Face) */
BNRP_Boolean setGrafTextFace(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;
	FontInfo	info;
	BNRP_term	curr_term;
	XFontStruct	*font;
	BNRP_tag	tag;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_list) return FALSE;
	
	info.weight = NORMAL_WEIGHT;
	info.slant = NORMAL_SLANT;
	curr_term = p.term.first;
	while ((tag = BNRP_getNextValue(&curr_term,&p)) != BNRP_end) {
		if (tag == BNRP_var) return TRUE;
		if (tag == BNRP_tailvar) return TRUE;
		if (tag != BNRP_symbol) return FALSE;
		if (strcmp(p.sym.sval,"bold") == 0)
			info.weight = BOLD_WEIGHT;
		else if (strcmp(p.sym.sval,"italic") == 0)
			info.slant = ITALIC_SLANT;
	}

	if ((info.weight != g->fontInfo.weight) || (info.slant != g->fontInfo.slant)) {
		info.name = g->fontInfo.name;
		info.size = g->fontInfo.size;
		if (font = getFont(&info,FALSE)) {
			g->fontInfo.weight = info.weight;
			g->fontInfo.slant = info.slant;
			g->font = font;
			XSetFont(display, g->gc, font->fid);
			return TRUE;
		}
		return FALSE;
	}
	return TRUE;
}

BNRP_Boolean setGrafTextMode(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;

	if (strcmp(p.sym.sval,"or") == 0)
		g->textMode = GXcopy;
	else if (strcmp(p.sym.sval,"xor") == 0)
		g->textMode = GXinvert;
	else if (strcmp(p.sym.sval,"clear") == 0)
		g->textMode = GXclear;
	else return FALSE;
	
	return TRUE;
}

BNRP_Boolean getGrafTextMode(tcb)
BNRP_TCB	*tcb;
{
	GrafContextPtr	g;
	BNRP_result	p;
	BNRP_term	mode;

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;

	switch(g->textMode) {
	case GXcopy:	mode = BNRP_makeSymbol(tcb,"or");
				break;	
	case GXinvert:	mode = BNRP_makeSymbol(tcb,"xor");
				break;	
	case GXclear:	mode = BNRP_makeSymbol(tcb,"clear");
				break;	
	default:	return FALSE;
	}
	
	return BNRP_unify(tcb, tcb->args[2], mode);
}

/* $textwidth(+GC, +S, -W) */
BNRP_Boolean textWidth(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	GrafContextPtr	g;

	if (tcb->numargs != 3) return FALSE;

	if (BNRP_getValue(tcb->args[1],&p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr)p.ival;

	if (BNRP_getValue(tcb->args[2],&p) != BNRP_symbol) return FALSE;
	if (g->font)
		return BNRP_unify(tcb, tcb->args[3], 
							BNRP_makeInteger(tcb, (long int) XTextWidth(g->font, p.sym.sval, strlen(p.sym.sval))));
	else 
		return BNRP_unify(tcb, tcb->args[3], strlen(p.sym.sval)*12);
	
}

/* textabs_C(+GC,+X,+Y,+Symbol) */
BNRP_Boolean textAbs(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	GrafContextPtr	g;
	int	x,y;

	if (tcb->numargs != 4) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	g = (GrafContextPtr) p.ival;
	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE; 
	x = p.ival;
	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE; 
	y = p.ival;
	if (BNRP_getValue(tcb->args[4], &p) != BNRP_symbol) return FALSE;
	if (g->textMode == GXcopy) {
		XDrawImageString(display, g->draw, g->gc, x-g->left, y-g->top, p.sym.sval, strlen(p.sym.sval));
	}
	else {
		SetFunction(g->gc, g->textMode);

		XDrawString(display, g->draw, g->gc, x-g->left, y-g->top, p.sym.sval, strlen(p.sym.sval));
		SetFunction(g->gc, g->current_function);
	}

	return TRUE;
}

/* $get_icon_value(+Icon,?Stream) */
BNRP_Boolean get_icon_value(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	int			hashpos;
	XImage		*image;
	int			i,j;
	char		s[ICON_SIZE*((ICON_SIZE/4)+1)+1];
	char		*temp;
	unsigned char *c;
	Pixmap		iconmap;
    ioProc      proc;
    long        fileP;
	BNRP_tag	tag;
    char	    iconfile[BITMAP_NAMESIZE];

	if (tcb->numargs != 2) return FALSE;
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
    sprintf(iconfile,"ICON%06d.bit",(int)p.ival);
    hashpos=get_bitmap(iconfile, &iconmap, DefaultRootWindow(display));
    if (hashpos >= 0)
        bitmap_table[hashpos].ispattern=FALSE;
    if (hashpos < -1)
        return FALSE;

    tag = BNRP_getValue(tcb->args[2], &p);
	
    if (tag == BNRP_list) {
        BNRP_term   list = p.term.first;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
        fileP = (long) p.ival;
        if (BNRP_getNextValue(&list,&p) != BNRP_integer) return FALSE;
        proc = (ioProc) p.ival;
    }
	else if (tag != BNRP_var) return FALSE;

	image = XGetImage(display,iconmap,0, 0, ICON_SIZE, ICON_SIZE, 1, XYPixmap);
	c = (unsigned char *)image->data;
	temp = s;
	for (i=0;i<ICON_SIZE;i++) {
		for (j=0; j<image->bytes_per_line; j++) {
			if (j < (ICON_SIZE/8)) {
				sprintf(temp, "%2.2x", (unsigned char) ~(*c));
				temp+=2;
			}
			c++;
		}
		sprintf(temp,"\n");
		temp++;
	}
	XDestroyImage(image);
	if (hashpos == -1) XFreePixmap(display,iconmap);
    if (tag == BNRP_var)
        return BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb,s));
	else {
        (void) (*proc)(OUTPUTSTRING, fileP, STRING, s,"");
	}
   	return TRUE;
}

/*
 * change/query the bitmap search path
 */
BNRP_Boolean defaultbitmapdir(tcb)
BNRP_TCB *tcb;
{
    BNRP_result dir;
    char       *dirname;
    int         len;

    if (tcb->numargs != 1) return FALSE;        /* arity check */
    switch (BNRP_getValue(tcb->args[1], &dir)) {
    case BNRP_symbol:
        dirname = dir.sym.sval;
        len = strlen(dirname);
        if (len >= sizeof(bitmapSearchPath))
            return FALSE;                       /* too long */

        strcpy(bitmapSearchPath, dirname);      /* copy     */

        /* remove trailing `/' */
        len --;
        while ((len >= 0) && (bitmapSearchPath[len] == '/')) {
            bitmapSearchPath[len] = '\0';
            len --;
        }
        break;
    case BNRP_var:
        return unify(tcb, tcb->args[1], BNRP_makeSymbol(tcb, bitmapSearchPath));
        break;
    default:
        return FALSE;
    }
    return TRUE;
}

void BindPGrafPrimitives()
{
	initialPixmap = XCreatePixmap(display,DefaultRootWindow(display),1,1,DefaultDepth(display,DefaultScreen(display)));
	BNRPBindPrimitive("clone_GC_C", clone_GC);
	BNRPBindPrimitive("free_GC_C", free_GC);
	BNRPBindPrimitive("lineabs_C", lineabs);
	BNRPBindPrimitive("rectabs_C", rectabs);
	BNRPBindPrimitive("arcabs_C", arcabs);
	BNRPBindPrimitive("ovalabs_C", ovalabs);
	BNRPBindPrimitive("forecolor_C", forecolor);
	BNRPBindPrimitive("inqforecolor_C", inqforecolor);
	BNRPBindPrimitive("backcolor_C", backcolor);
	BNRPBindPrimitive("inqbackcolor_C", inqbackcolor);
	BNRPBindPrimitive("penmode_C", penmode);
	BNRPBindPrimitive("inqpenmode_C", inqpenmode);
	BNRPBindPrimitive("crectabs_C", crectabs);
	BNRPBindPrimitive("$inqcrectabs_C", inqcrectabs);
	BNRPBindPrimitive("rrectabs_C", rrectabs);
	BNRPBindPrimitive("pensize_C", pensize);
	BNRPBindPrimitive("inqpensize_C", inqpensize);
	BNRPBindPrimitive("multi_lineabs_C", multi_lineabs);
	BNRPBindPrimitive("penpat_C", penpat);
	BNRPBindPrimitive("inqpenpat_C", inqpenpat);
	BNRPBindPrimitive("backpat_C", backpat);
	BNRPBindPrimitive("inqbackpat_C", inqbackpat);
	BNRPBindPrimitive("userpat_C", userpat);
	BNRPBindPrimitive("inquserpat_C", inquserpat);
	BNRPBindPrimitive("fillpat_C", fillpat);
	BNRPBindPrimitive("inqfillpat_C", inqfillpat);
	BNRPBindPrimitive("scrollrect_C", scrollrect);
	BNRPBindPrimitive("editbabs_C", editbabs);
	BNRPBindPrimitive("textwidth_C", textWidth);
	BNRPBindPrimitive("textfont_C", setGrafTextFont);
	BNRPBindPrimitive("textsize_C", setGrafTextSize);
	BNRPBindPrimitive("textface_C", setGrafTextFace);
	BNRPBindPrimitive("textmode_C", setGrafTextMode);
	BNRPBindPrimitive("inqtextfont_C", getGrafTextFont);
	BNRPBindPrimitive("inqtextsize_C", getGrafTextSize);
	BNRPBindPrimitive("inqtextface_C", getGrafTextFace);
	BNRPBindPrimitive("inqtextmode_C", getGrafTextMode);
	BNRPBindPrimitive("textabs_C", textAbs);
	BNRPBindPrimitive("iconabs_C", iconabs);
	BNRPBindPrimitive("polygon_C", polygon);
	BNRPBindPrimitive("$get_icon_value_C", get_icon_value);
    BNRPBindPrimitive("defaultbitmapdir", defaultbitmapdir);
}
