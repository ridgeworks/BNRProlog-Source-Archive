/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProText.h,v 1.1 1995/09/22 11:27:02 harrisja Exp $
*
*  $Log: ProText.h,v $
 * Revision 1.1  1995/09/22  11:27:02  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_ProText
#define _H_ProText

#define MAX_FONT_SIZE_DIFF	6

#define NORMAL_WEIGHT	0
#define BOLD_WEIGHT		1

#define NORMAL_SLANT	0
#define ITALIC_SLANT	1


#define NONSTRING       0
#define STRING          1

typedef struct {
	char	*name;
	int		size;
	int		weight;
	int		slant;
} FontInfo;

extern XFontStruct	*sys_font;
extern XFontStruct	*appl_font;
extern FontInfo		sys_font_info;
extern FontInfo		appl_font_info;

extern void TextGetSelectionPosition();
extern void TextInsert();
extern void TextSetInsertionPosition();
extern void TextSetSelection();
extern void TextSwapSelection();
extern Boolean TextCut();
extern Boolean TextCopy();
extern Boolean TextPaste();
extern Boolean TextRemove();
extern void BindPTextPrimitives();
extern XFontStruct *getFont();
extern void PollScrapContents();
extern void GetFontInfo();
extern BNRP_Boolean commonGetTextSize();
extern BNRP_Boolean commonGetTextFont();
extern BNRP_Boolean commonGetTextFace();

#define OUTPUTSTRING    0
#define READCHAR        1
#define RETURNCHAR      2
#define OPENFILE        3
#define CLOSEFILE       4
#define GETPOSITION     5
#define SETPOSITION     6
#define SETEOF          7
#define FLUSHFILE       8
#define GETERROR        9

typedef BNRP_Boolean (*ioProc)();

#endif
