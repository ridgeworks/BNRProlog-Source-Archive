/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProFiles.c,v 1.2 1998/01/20 16:43:02 thawker Exp $
*
*  $Log: ProFiles.c,v $
 * Revision 1.2  1998/01/20  16:43:02  thawker
 * Cast NULL to an int each time it is compared to an int, to remove
 * warnings this caused on solaris
 *
 * Revision 1.1  1995/09/22  11:26:24  harrisja
 * Initial version.
 *
*
*/

/* include files */

#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#else
#include <strings.h>
#endif

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/keysym.h>
#include <X11/Shell.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>

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

/*-------------------------------------------------------------
**	OpenFile
**		Open the present file.  Returns true if file 
**  exists and open is sucessful.
*/
Boolean OpenFile(new_window)
    PTextWindow *new_window;
{
   struct stat statbuf;		/* Information on a file. */
   int file_length;		/* Length of file. 	  */
   char * file_string;	/* Contents of file. 	  */
   FILE *fp = NULL;		/* Pointer to open file   */
   
   if ((fp = fopen(new_window->filename, "r+")) == NULL)
	if ((fp = fopen(new_window->filename, "r")) != NULL) 
           { fprintf(stderr, "Warning: file opened read only.\n"); } 
        else 
           { return(FALSE); }

   if (stat(new_window->filename, &statbuf) == 0)
	 file_length = statbuf.st_size;
   else
	 file_length = 1000000; /* arbitrary file length */

   /* read the file string */
   file_string = (char *) XtMalloc(file_length+1);
   fread(file_string, sizeof(char), file_length, fp);
	file_string[file_length] = '\0';

   /* close up the file */
   if (fclose(fp) != (int)NULL) fprintf(stderr, "Warning: unable to close file.\n");

   /* added the file string to the text widget */
   XmTextSetString(new_window->text, file_string);
   XtFree(file_string);

   new_window->file_saved = TRUE; 
	new_window->err = 0;
	 
   return(TRUE);
}


/*-------------------------------------------------------------
**	SaveFile
**		Save the present file. 
*/
Boolean SaveFile(fw,fname)
    PTextWindow *fw;
    char *fname;
{
    char           *file_string = NULL;	   /* Contents of file. */
    FILE           *tfp,*fp;		   
    Boolean        result=FALSE;
    char           *tempname = (char *)XtMalloc(25); /* Temporary file name. */
     
    extern char    *mktemp();

    /* Should check here for different source and target (i-node #s differ?) 
       and skip the tmp file if they are not the same */

    strcpy(tempname, "/tmp/bnrpXXXXXX");
    if ((tfp = fopen(mktemp(tempname), "w")) != NULL) 

       { /* get the text string */
        file_string = (char *)XmTextGetString(fw->text);

        /* write to a temp file */
        if (fwrite(file_string,sizeof(char),strlen(file_string),tfp) >= strlen(file_string))
           { /* close the temp file */
            if (fclose(tfp) == 0) 

               { /* Write the data to the saved file also. Changed from system
                 ("cp tempname fname") since failed occasionally (out of memory?) */
                if ((fp = fopen(fname,"w")) != NULL) 

                   { if (fwrite(file_string,sizeof(char),strlen(file_string),fp) >= 
                          strlen(file_string))
               	        { if (fclose(fp) == 0)
                             { /* remove temp file */
                               unlink (tempname);
                               fw->file_saved = TRUE;  
                               result = TRUE;
                              }
                          else
                             { perror(
                                 "Warning: unable to close saved file, text not saved. Reason"); }
                        }
                     else
                        { perror(
                            "Warning: unable to write to saved file, text not saved. Reason");}
                    }
                 else
                    { perror(
                       "Warning: unable to open saved file, text not saved. Reason");}
               }
            else
              { perror(
                  "Warning: unable to close temp file, text not saved. Reason");}
           }
        else
          { perror("Warning: unable to write to temp file, text not saved. Reason");}
       }
    else
       { perror(
              "Warning: unable to open temp file, text not saved. Reason");}


    XtFree(tempname);
    if (file_string != NULL) XtFree(file_string);

    return(result);
}

