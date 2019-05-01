/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/scale.c,v 1.1 1995/09/22 11:27:43 harrisja Exp $
*
*  $Log: scale.c,v $
 * Revision 1.1  1995/09/22  11:27:43  harrisja
 * Initial version.
 *
*
*/

/* include files */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <math.h>
#include <memory.h>

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/Xlib.h>

#include <Xm/Xm.h>

#include "BNRProlog.h"
#include "Prolog.h"
#include "ProGraf.h"

/* B I T M A P   S C A L I N G   R O U T I N E S */

#define	BIT_THRESHOLD 0.50  /*  Contrast control for bitmap scaling.  Any pixel
							in the destination bitmap that is covered by a pixel
							in the source bitmap by more than 30% will be set. */

static XImage	*source, *destination;
static	float 	*dest_weight;        /* Dynamically allocated array that holds the
										percentage coverage of each pixel in the
										destination bitmap.  If any destination pixel
										is more than BIT_THRESHOLD percent covered
										by one or more source pixels, then that
										destination pixel is lit. */

int	GRd;

#define epsilon (1.0E-6)
#define update_destination_pixel_weight(x,y, wt) dest_weight[(x*GRd)+y] += (wt)

void scan(Lsd, Rsd, y, Wt)
	float	Lsd, Rsd, Wt;
	int		y;
{
	int		x = (int)Lsd;
	float	Lceil,Rfloor;  /* Rounded endpoints of the rectangle. */

	Lceil=ceil(Lsd+epsilon);
	Rfloor=floor(Rsd-epsilon);

	if (Lceil > Rfloor) 
		update_destination_pixel_weight(x,y,(Rsd-Lsd)*Wt);
	else {
		update_destination_pixel_weight(x,y,(Lceil-Lsd)*Wt);
		for (x=(int)Lceil; x < (int)Rfloor; x++) 
			update_destination_pixel_weight(x,y,Wt);
		update_destination_pixel_weight(x,y,(Rsd-Rfloor)*Wt);
	}
}

void output_rect(Lsd, Tsd, Rsd, Bsd)
        float   Lsd, Tsd, Rsd, Bsd;
{
	int		y = (int)Tsd;
	float	Tceil,Bfloor;

	Tceil=ceil(Tsd+epsilon);
	Bfloor=floor(Bsd-epsilon);

	if (Tceil > Bfloor) 
		scan(Lsd,Rsd,y,(Bsd-Tsd));
	else {
		scan(Lsd,Rsd,y,(Tceil-Tsd));
		for (y=(int)Tceil; y < (int)Bfloor; y++) 
			scan(Lsd,Rsd,y,1.0);
		scan(Lsd,Rsd,y,(Bsd-Bfloor));
	}
}

/* Accepts a bitmap (A pixmap of depth 1), and returns the bitmap scaled to the
   requested size.  The source bitmap has Rs rows and Cs columns, the destination bitmap
   has Rd rows and Rd columns. */

Pixmap ScalePixmap (gc, inmap, outmap, Cs,Rs,Cd,Rd )
	GC	gc;
	Pixmap	inmap;
	Pixmap	outmap;
	int	Rs,Cs;
	int	Rd,Cd;

{
	register int	y,x;

	/* The co-ordinates of the source pixel, transformed from the source co-ordinate
	  system to the destination system. */
	float		pixelsd_L,pixelsd_T,pixelsd_R,pixelsd_B;

	float	StoDx, StoDy;
	XGCValues       values;
	int		black = BlackPixel(display,DefaultScreen(display));
	int		white = WhitePixel(display,DefaultScreen(display));
	int		i,size;

	GRd = Rd;

	/* Put plane 1 of the incoming Pixmap into the source bit image (Plane 1 corresponds
	  to all BLACK pixels in the inmap). */
	source=XGetImage(display,inmap,0,0,Cs,Rs,(unsigned long)1,XYPixmap);
	XGetGCValues(display,gc,GCForeground|GCBackground,&values);
	XSetForeground(display,gc,white);
	XSetBackground(display,gc,white);

	StoDx=(float)Cd/(float)Cs;		/* Source->Dest bitmap scaling factors */
	StoDy=(float)Rd/(float)Rs;		/*in the X and Y directions */

	/* Create and clear the pixmap that will hold the destination image. */
	XFillRectangle(display,outmap,gc,0,0,Cd,Rd);
	XSetForeground(display,gc,black);
	destination=XGetImage(display,outmap,0,0,Cd,Rd,(unsigned long)1,XYPixmap);

	/* Allocate space for weight array */
	size = Rd*Cd;
	dest_weight=(float*)XtMalloc(size*sizeof(float));
	for (x=0;x<size;x++)
		dest_weight[x] = 0.0;

	pixelsd_B = 0.0;
	for (y=0; y<Rs; y++) {
		pixelsd_T = pixelsd_B;
		pixelsd_B += StoDy;
		pixelsd_R = 0.0;
		for (x=0; x<Cs; x++) {
			pixelsd_L = pixelsd_R;
			pixelsd_R += StoDx;

			/* If the source pixel under examination is ON, then scale it into the destination bit image */
			if (XGetPixel(source,x,y)==black)
				output_rect(pixelsd_L,pixelsd_T,pixelsd_R,pixelsd_B);
		}
	}

	/* Deallocate space for weight array */
	i=0;
	for (x=0;x<Cd;x++) {
		for (y=0;y<Rd;y++)
			if (dest_weight[i++] > BIT_THRESHOLD)
				XPutPixel(destination,x,y,black);
	}
	XtFree((char *)dest_weight);

	/* Convert the image into the destination bitmap, and clean up. */
	XPutImage(display,outmap,gc,destination,0,0,0,0,Cd,Rd);

	XDestroyImage(source);
	XDestroyImage(destination);
	XSetForeground(display,gc,values.foreground);
	XSetBackground(display,gc,values.background);
	return outmap;
}
