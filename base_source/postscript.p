/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/postscript.p,v 1.1 1995/09/22 11:26:07 harrisja Exp $
*
*  $Log: postscript.p,v $
 * Revision 1.1  1995/09/22  11:26:07  harrisja
 * Initial version.
 *
*
*/

printpicture(Frame,PictureID) :-
	printpicture(Frame,PictureID,settings(portrait, 1, 1, 1000)).

printpicture(DestFrame,PictureId,settings(Form,CopiesToDo,FirstPage,LastPage)) :-
	recall(picture(PictureID, _, SrcFrame, [Desc..]),$local),
	T is cputime,
	swrite(TempFile,'/tmp/ps',T),
	open(S,TempFile,read_write,0),
	set_end_of_file(S),
	openwindow(graf,'$$$temp_ps',_,_,options(hidden)),
	$ps_page_frame(Form,PageFrame),
	$ps_prolog(S),
	repeat,
	new_counter(0,C),
	$ps_print_pages(S,Form,SrcFrame,DestFrame,PageFrame,1,FirstPage,LastPage,PictureID),
	C,
	counter_value(C,Copies),
	Copies = CopiesToDo,
	cut,
	closewindow('$$$temp_ps'),
	$ps_epilog(S),
	close(S,_),
	swrite(Cmd,'lpr ',TempFile),
	system(Cmd),
	deletefile(TempFile).

$ps_print_pages(S,Form,SrcFrame,DestFrame,PageFrame,Page,FirstPage,LastPage,PictureID):-
	Page > LastPage,
	!.

$ps_print_pages(S,Form,SrcFrame,frame(DFL,DFT,DFR,DFB),frame(PFL,PFT,PFR,PFB),Page,FirstPage,LastPage,PictureID) :-
	PFT > DFB,
	!.

$ps_print_pages(S,Form,SrcFrame,DestFrame,PageFrame,Page,FirstPage,LastPage,PictureID) :-
	Page >= FirstPage
	-> $ps_print_page(S,Form,SrcFrame,DestFrame,Page,PageFrame,PictureID),
	$ps_next_page(Form,DestFrame,PageFrame,PageFrame1),
	successor(Page,Page1),
	$ps_print_pages(S,Form,SrcFrame,DestFrame,PageFrame1,Page1,FirstPage,LastPage,PictureID).

$ps_print_page(S,Form,SrcFrame,DestFrame,Page,PageFrame,PictureID) :-
	$ps_orient(S,Form),
	$ps_project(S,SrcFrame,DestFrame,PageFrame),
	window_id('$$$temp_ps',_,[GC,_..]),
	remember(font_set(false,GC),$local),
	recall(picture(PictureID, _, _, [Desc..]),$local),
	$ps_traverse(Desc,S,'$$$temp_ps'),
	foreach(recall(picture_element(PictureID,G),$local) do
		$ps_traverse(G,S,'$$$temp_ps')),
	forget(font_set(_,GC),$local),
	$ps(S,grestore),
	$ps(S,showpage).

$ps_next_page(Form, frame(DFL,DFT,DFR,DFB),frame(PFL,PFT,PFR,PFB),frame(PFR,PFT,PFR1,PFB)) :-
	DFR > PFR,
	!,
	PFR1 is PFR + (PFR-PFL).

$ps_next_page(Form, frame(DFL,DFT,DFR,DFB),frame(PFL,PFT,PFR,PFB),frame(PFL1,PFB,PFR1,PFB1)) :-
	$ps_page_frame(Form, frame(PFL1, _, PFR1, _)),
	PFB1 is PFB + (PFB-PFT).

$ps_traverse(G,S,W) :-
	window_id(W,Id,[GC,_,GcAttr..]),
	$ps_traverse(G,S,GC,GcAttr,NewGcAttr),
	$put_local_attrib(GcAttr,NewGcAttr,Id,GC,-1).

$ps_traverse([],_,_,GcAttr,GcAttr).
$ps_traverse([G,Gs..], S, GC, GcAttr, NewGcAttr) :-
	list(G),
	!,
	$ps_clone_GC(S,GC,NewGC),
	not(not($ps_traverse(G, S, NewGC, GcAttr, _)))
	; [$ps_free_GC(S,NewGC),fail],
	$ps_free_GC(S,NewGC),
	!,
	$ps_traverse(Gs, S, GC, GcAttr, NewGcAttr).
$ps_traverse([G,Gs..], S, GC, GcAttr, NewGcAttr) :-
	!,
	$ps_execgraf(G, S, GC, GcAttr, GcAttr1),
	!,
	$ps_traverse(Gs, S, GC, GcAttr1, NewGcAttr).
$ps_traverse(G, S, GC, GcAttr, NewGcAttr) :-
	$ps_execgraf(G, S, GC, GcAttr, NewGcAttr).
	
$ps_execgraf([], _, _, GcAttr, GcAttr).
$ps_execgraf($$$var_functor(P..), _, _, GcAttr, GcAttr).
$ps_execgraf(F(P..), S, GC, GcAttr, NewAttr) :-
	$ps_graf_desc(F,Fps),
	Fps(GcAttr,P,S,GC),
	cut,
	fail. % into next case
$ps_execgraf(F(P..), S, GC, GcAttr, NewAttr) :-
	$execgraf(F(P..), dograf, GcAttr, NewAttr, GC).
	
$ps_clone_GC(S,GC,NewGC) :-
	!,
	$ps(S,gsave),
	clone_GC_C(GC,NewGC),
	recall(font_set(State,GC),$local),
	remember(font_set(State,NewGC),$local),
	cut.
	
$ps_free_GC(S,GC) :-
	!,
	$ps(S,grestore),
	free_GC_C(GC),
	forget(font_set(State,GC),$local),
	cut.
	
$ps_forecolor(Gc_Attrib,[Fore],S,GC) :- 
	$grayscale(Fore,ForeGray),
	$ps_comment(S,"forecolor",Fore),
	$ps(S,setgray,ForeGray).

$ps_pensize(Gc_Attrib,[LineWidth, Unused],S,GC) :-
	$ps_comment(S,"pensize",LineWidth),
	$ps(S,setlinewidth,LineWidth).

$ps_line([Px,Py,Sx,Sy,Ox,Oy,A],[Dist],S,GC) :-             % turtle graphics
    A_rad is (A*pi/180),
    PxNew is Dist*cos(A_rad)*Sx +Px,
    PyNew is Dist*sin(A_rad)*Sy +Py,    % Clockwise rotation is considered positive.
	$ps_comment(S,"line",Dist),
	$ps(S,moveto,Px,Py),
	$ps(S,lineto,PxNew,PyNew),
	$$renderpath(pentype,stroke,S,GC).

$ps_arcrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, StartAngle, DeltaAngle],S,GC) :-
    L1 is min(L,R)*Sx +Px, 	    % Make sure the rect's components are ordered correctly
    R1 is max(L,R)*Sx +Px,
    T1 is min(T,B)*Sy +Py,
    B1 is max(T,B)*Sy +Py,
	CX is (L1+R1)/2,
	CY is (T1+B1)/2,
	Rad is R1-CX,
	ScalY is (R1-L1)/(B1-T1),
	Ang1 is 360-StartAngle,
	Ang2 is Ang1-DeltaAngle,
	$ps_comment(S,arcrel,L,T,R,B,StartAngle,DeltaAngle),
	$ps(S,gsave),
	$ps(S,scale,1,ScalY),
	$ps(S,arc,CX,CY,Rad,Ang1,Ang2),
	$renderpath(S,GC),
	$ps(S,grestore).

$ps_arcabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S, GC) :-
	$ps_arcrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S, GC).

$ps_circlerel([Px,Py,Sx,Sy,Ox,Oy,A], [X, Y, R],S, GC) :-
    X1 is X*Sx +Px,
    Y1 is Y*Sy +Py,
	$ps_comment(S,circlerel,X,Y,R),
	$ps(S,arc,X1,Y1,R,0,360),
	$renderpath(S,GC).

$ps_circleabs([Px,Py,Sx,Sy,Ox,Oy,A], Args,S,GC) :-
	$ps_circlerel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S, GC).

$ps_ovalrel([Px,Py,Sx,Sy,Ox,Oy,A], [L,T,R,B],S, GC) :-
    L1 is min(L,R)*Sx +Px, 	    % Make sure the rect's components are ordered correctly
    R1 is max(L,R)*Sx +Px,
    T1 is min(T,B)*Sy +Py,
    B1 is max(T,B)*Sy +Py,
	CX is (L1+R1)/2,
	CY is (T1+B1)/2,
	R is R1-L1,
	ScalY is (R1-L1)/(B1-T1),
	$ps_comment(S,ovalrel,L,T,R,B),
	$ps(S,gsave),
	$ps(S,scale,1,ScalY),
	$ps(S,arc,CX,CY,R,0,360),
	$renderpath(S,GC),
	$ps(S,grestore).

$ps_ovalabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S, GC) :-
	$ps_ovalrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S, GC).

$ps_rectrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],S, GC) :-
    L1 is (min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px)-1,
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py)-1,
	$ps_comment(S,rectrel,L,T,R,B),
	$ps(S,rect, L1,T1,R1,B1),
	$renderpath(S,GC).

$ps_rectabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S, GC) :-
	$ps_rectrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S, GC).

$ps_pictrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, PictureID],S, GC) :-
    L1 is (min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px),
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py),
	$ps_comment(S,pictrel,L,T,R,B,PictureID),
	recall(picture(PictureID, _, frame(FX1,FY1,FX2,FY2), [Desc..]),$local),
	$ps(S,gsave),
	$ps(S,translate,L1-FX1,T1-FY1),
	$ps(S,scale,(R1-L1)/(FX2-FX1),(B1-T1)/(FY2-FY1)),
	$ps_traverse(Desc,S,'$$$temp_ps'),
	foreach(recall(picture_element(PictureID,G),$local) do
		$ps_traverse(G,S,'$$$temp_ps')),
	$ps(S,grestore).

$ps_pictabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S, GC) :-
	$ps_pictrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S, GC).

$ps_iconrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Icon],S,GC) :-
    L1 is (min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px),
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py),
	$ps_comment(S,iconrel,L,T,R,B,Icon),
	$ps(S,gsave),
	$ps(S,translate,L1,T1),
	$ps(S,scale,(R1-L1)/32,(B1-T1)/32),
	$ps(S,bitdump,4,32,32),
	$get_icon_value(Icon,S),
	$ps(S,grestore).

$ps_iconabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S,GC) :-
	$ps_iconrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S,GC).

$ps_crectrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],S,GC) :-
    L1 is (min(L,R)*Sx +Px), % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px),
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py),
    $ps_comment(S,crectrel,L,T,R,B),
	$ps(S,rect, L1,T1,R1,B1),
	$ps(S,clip),
	$ps(S,newpath).

$ps_crectabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S,GC) :-
	$ps_crectrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S,GC).

/* Recursively checks a list of points representing endpoints in a series of connected
  line segments. 
   FAILS when a parameter of an incorrect type (or a VARIABLE parameter) is encountered. 
   RETURNS the updated pen position corresponding to the end of the line segment.*/
$ps_check_segment_list_rel([],GC,GC,S).
$ps_check_segment_list_rel([Xrel,Yrel,Ps..],[Px,Py,Sx,Sy,Rest..],[PxNew,PyNew,Sx,Sy,Rest..],S) :-
	Xabs is (Xrel*Sx + Px),
	Yabs is (Yrel*Sx + Py),
	$ps(S,lineto,Xabs,Yabs),
	$ps_check_segment_list_rel(Ps,[Xabs,Yabs,Sx,Sy,Rest..],[PxNew,PyNew,Sx,Sy,Rest..],S).

/* This section handles the drawing of multiple connected lines */
$ps_linerel([Px,Py,Rest..], [X, Y, Points..],S,GC) :-
	$ps_comment(S,linerel,X,Y,Points..),
	$ps(S,moveto,Px,Py),
    $ps_check_segment_list_rel([X,Y,Points..],[Px,Py,Rest..],[PxNew,PyNew,Rest..],S),
	$$renderpath(pentype,stroke,S,GC).

/* Recursively checks a list of points representing endpoints in a series of connected
  line segments.
   FAILS when a parameter of an incorrect type (or a VARIABLE parameter) is encountered. 
   RETURNS the updated pen position corresponding to the end of the line segment.*/
$ps_check_segment_list_abs([],GC,GC,S).
$ps_check_segment_list_abs([X,Y,Ps..],[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A],S) :-
	Xabs is (X*Sx + Ox),
	Yabs is (Y*Sx + Oy),
	$ps(S,lineto,Xabs,Yabs),
	$ps_check_segment_list_abs([Ps..],[Xabs,Yabs,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A],S).

$ps_lineabs([Px,Py,Sx,Sy,Ox,Oy,A], [X, Y, Points..],S,GC) :-
	$ps_comment(S,lineabs,X,Y,Points..),
	$ps(S,moveto,Px,Py),
    $ps_check_segment_list_abs([X,Y,Points..],[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A],S),
	$$renderpath(pentype,stroke,S,GC).

$ps_rrectrel([Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, OvalWidth, OvalHeight],S,GC) :-
    New_Width is (OvalWidth*Sx),
    New_Height is (OvalHeight*Sy),
    L1 is (min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px) - 1,
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py) - 1,
	Rad is New_Width/2,
	$ps_comment(S,rrectrel,L,T,R,B,OvalWidth,OvalHeight),
	$ps(S,moveto,L1+Rad,T1),
	$ps(S,arcto,R1,T1,R1,B1,Rad), $ps(S,fourpop),
	$ps(S,arcto,R1,B1,L1,B1,Rad), $ps(S,fourpop),
	$ps(S,arcto,L1,B1,L1,T1,Rad), $ps(S,fourpop),
	$ps(S,arcto,L1,T1,R1,T1,Rad), $ps(S,fourpop),
	$renderpath(S,GC).

$ps_rrectabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S,GC) :-
	$ps_rrectrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S,GC).

$ps_textrel([Px,Py,Sx,Sy,Ox,Oy,A],[X, Y, Text],S,GC) :-
	$check_font(S,GC),
    PxNew is X*Sx + Px,
    PyNew is Y*Sx + Py,
	$ps_comment(S,textrel,X,Y,Text),
	$ps(S, showText, Text, PxNew, PyNew).

$ps_textabs([Px,Py,Sx,Sy,Ox,Oy,A], [X, Y, Text],S,GC) :-
	$check_font(S,GC),
    PxNew is X*Sx + Ox,
    PyNew is Y*Sx + Oy,
	$ps_comment(S,textabs,X,Y,Text),
	$ps(S, showText, Text, PxNew, PyNew).

$ps_textbrel([Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Text],S,GC) :-
    L1 is (min(L,R)*Sx +Px),   % Make sure the rect's components are ordered correctly
    R1 is (max(L,R)*Sx +Px),
    T1 is (min(T,B)*Sy +Py),
    B1 is (max(T,B)*Sy +Py),
	$check_font(S,GC),
	$ps_comment(S,textbrel,L,T,R,B,Text),
	$ps(S,rect, L1,T1,R1,B1),
	$$renderpath(clear,fill,S,GC),
	$textbox_arg(Text,Str,Start),
	$textbox(GC, L1, T1, R1, B1, Str, Start, $ps_drawtext, S).

$ps_drawtext(S,X,Y,Str) :-
	$ps(S, showText, Str, X, Y).
	
$ps_textbabs([Px,Py,Sx,Sy,Ox,Oy,A], Args, S,GC) :-
	$ps_textbrel([Ox,Oy,Sx,Sy,Ox,Oy,A], Args, S,GC).

$ps_polygon_points([],GC,S).

$ps_polygon_points([moveabs(X,Y),Ps..],[Px,Py,Sx,Sy,Ox,Oy,A],S) :-
	Tx is (X*Sx+Ox),
	Ty is (X*Sy+Oy),
	$ps(S,moveto,Tx,Ty),
	$ps_polygon_points(Ps,[Tx,Ty,Sx,Sy,Ox,Oy,A],S).

$ps_polygon_points([moverel(X,Y),Ps..],[Px,Py,Sx,Sy,Ox,Oy,A],S) :-
	Tx is (X*Sx+Px),
	Ty is (X*Sy+Py),
	$ps(S,moveto,Tx,Ty),
	$ps_polygon_points(Ps,[Tx,Ty,Sx,Sy,Ox,Oy,A],S).

$ps_polygon_points([linerel(Ls..),Ps..],[Px,Py,Other..],S) :-
	$ps_check_segment_list_rel(Ls,[Px,Py,Other..],[NewPx,NewPy,Other..],S),
	$ps_polygon_points(Ps,[NewPx,NewPy,Other..],S).

$ps_polygon_points([lineabs(Ls..),Ps..],[Px,Py,Other..],S) :-
	$ps_check_segment_list_abs(Ls,[Px,Py,Other..],[NewPx,NewPy,Other..],S),
	$ps_polygon_points(Ps,[NewPx,NewPy,Other..],S).

$ps_polygon([Px,Py,Etc..],PolySpec,S,GC) :-
	$ps_comment(S,polygon),
	$ps(S,moveto,Px,Py),
	$ps_polygon_points(PolySpec,[Px,Py,Etc..],S),
	$ps(S,closepath),
	$renderpath(S,GC).


$ps(S,Func, Args..) :-
	$ps_args(S,Args),
	swrite(S,Func,"\n").

$ps_comment(S,Func,Args..) :-
	swrite(S,"% ",Func,"("),
	$ps_args(S,Args),
	swrite(S,")\n").
$ps_comment(_,_,_..).

$ps_args(_,[]).
$ps_args(S,[X,Args..]):-
	$ps_arg(S,X),
	$ps_args(S,Args).

$ps_arg(S,X) :-
	X1 is X,
	swrite(S,X1,' ').
$ps_arg(S,literal(L)) :-
	nonvar(L),
	swrite(S,'/',L,' ').
$ps_arg(S,X) :-
	symbol(X),
	name(X,XL),
	$escape_parens(XL,XL1),
	name(X1,XL1),
	swrite(S,'(',X1,') ').

$escape_parens([],[]).
$escape_parens([0'(, X..], [0'\,0'(, Y..]) :-
	!,
	$escape_parens(X,Y).
$escape_parens([0'), X..], [0'\,0'), Y..]) :-
	!,
	$escape_parens(X,Y).
$escape_parens([C, X..], [C, Y..]) :-
	!,
	$escape_parens(X,Y).
	
$grayscale(white,1).
$grayscale(lightgray,0.75).
$grayscale(darkgray,0.25).
$grayscale(black,0).
$grayscale(_,0.5).

$renderpath(S,GC) :-
	inqfillpat_C(GC,FillPat),
	$$renderpath(FillPat,fill,S,GC).

$$renderpath(hollow,_,S,_) :-
	$ps(S,stroke).

$$renderpath(pentype,Fill,S,GC) :-
	inqpenpat_C(GC,PenPat),
	$grayscale(PenPat,Gray),
	$ps(S,gsave),
	$ps(S,setgray,Gray),
	$ps(S,Fill),
	$ps(S,grestore),
	$ps(S,newpath).
	
$$renderpath(usertype,Fill,S,GC) :-
	write("WARNING fillpat usertype not supported in postscript mode\n"),
	$$renderpath(pentype,S,GC).
	
$$renderpath(clear,Fill,S,GC) :-
	inqbackpat_C(GC,BackPat),
	$grayscale(BackPat,Gray),
	$ps(S,gsave),
	$ps(S,setgray,Gray),
	$ps(S,fill),
	$ps(S,grestore),
	$ps(S,newpath).

$$renderpath(invert,Fill,S,GC) :-
	write("WARNING fillpat invert not supported in postscript mode\n"),
	$ps(S,Fill).

$ps_prolog(S) :- 
	swrite(S, "%!PS-Adobe-1.0\n"),
	swrite(S, "%%EndComments\n"),
	swrite(S, "/showText { moveto 1 -1 scale show 1 -1 scale } def\n"),
	swrite(S, "/fourpop { pop pop pop pop } def\n"),
	swrite(S, "/bitdump {\n"),
	swrite(S, "/height exch def\n"),
	swrite(S, "/width exch def\n"),
	swrite(S, "/lineWidth exch def\n"),
 	swrite(S, "width height scale\n"),
	swrite(S, "/picstr lineWidth string def\n"),
	swrite(S, "width height 1 [width 0 0 height 0 0]\n"),
	swrite(S, "{ currentfile picstr readhexstring pop }\n"),
	swrite(S, "image\n"),
	swrite(S, "} def\n"),
	swrite(S, "/rect {\n"),
	swrite(S, " /bottom exch def\n"),
	swrite(S, " /right exch def\n"),
	swrite(S, " /top exch def\n"),
	swrite(S, " /left exch def\n"),
	swrite(S, "	left top moveto\n"),
	swrite(S, "	right top lineto\n"),
	swrite(S, "	right bottom lineto\n"),
	swrite(S, "	left bottom lineto\n"),
	swrite(S, "	closepath \n"),
	swrite(S, "} def\n"),
	swrite(S,"%%EndProlog\n").

$ps_orient(S, portrait) :-
	$ps_pagesize(Ph,_),
	Ty is Ph+8,
	swrite(S,'20 ',Ty,' translate 1 -1 scale\n').
$ps_orient(S, landscape) :-
	swrite(S, '20 8 translate 90 rotate 1 -1 scale\n').
$ps_page_frame(landscape,frame(0,0,Ph,Pw)) :- 
	$ps_pagesize(Ph,Pw).
$ps_page_frame(portrait,frame(0,0,Pw,Ph)) :-
	$ps_pagesize(Ph,Pw).
	
$ps_project(S,frame(SL,ST,SR,SB),frame(DL,DT,DR,DB),frame(PL,PT,PR,PB)) :-
	Tx is (DL-SL)-PL,
	Ty is (DT-ST)-PT,
	Sx is (DR-DL)/(SR-SL),
	Sy is (DB-DT)/(SB-ST),
	$ps(S,gsave),
	W is PR-PL+1, H is PB-PT+1,
	$ps(S,rect,0,0,W,H),
	$ps(S,clip),
	$ps(S,newpath),
	$ps(S,translate,Tx,Ty),
	$ps(S,scale, Sx,Sy).

$ps_pagesize(776,570).

$ps_epilog(S) :-
	swrite(S,"%%Trailer\n").

$ps_textfont(_, GC, _) :-
	update(font_set(_,GC),font_set(false,GC),$local).

$ps_textsize(_, GC, _) :-
	update(font_set(_,GC),font_set(false,GC),$local).

$ps_textface(_, GC, _) :-
	update(font_set(_,GC),font_set(false,GC),$local).

$check_font(_,GC):-
	recall(font_set(true,GC),$local).
$check_font(S,GC) :-
	inqtextfont_C(GC,Font),
	inqtextface_C(GC,Face),
	inqtextsize_C(GC,Size),
	$ps_font(Font,Name),
	$font_name(Name,Face,FontName),
	!,
	$ps(S,findfont, literal(FontName)),
	$ps(S,scalefont, Size),
	$ps(S,setfont),
	update(font_set(_,GC),font_set(true,GC),$local).

$ps_fontheight(GC, H) :-
	inqtextfont_C(GC,Font),
    inqtextface_C(GC,Face),
    inqtextsize_C(GC,Size),
	$fontheight(font(Font,Size,Face..),H). % defined in panel_works

$font_name(Name,[],Font):- 
	$addnormal(Name,Font).
$font_name(Name,Face,Font) :-
	$addbold(Name,Face,Name1),
	$additalic(Name1,Face,Font).

$addnormal('Times','Times-Roman').
$addnormal('NewCenturySchlbk','NewCenturySchlbk-Roman').
$addnormal('Palatino','Palatino-Roman').
$addnormal(Name,Name).

$addbold(Name,Face,NameBold) :-
	$member(bold,Face),
	!,
	$addbold(Name,NameBold).
$addbold(Name,_,Name).

$addbold(Name,NameBold) :- concat(Name,'-Bold',NameBold).

$additalic(Name,Face,NameItalic) :-
	$member(italic,Face),
	!,
	$additalic(Name,NameItalic).
$additalic(Name,_,Name).

$additalic(NameBold,NameItalic) :- 
	concat(Name,'-Bold',NameBold),
	$italic(Name,Italic),
	concat(NameBold,Italic,NameItalic).
$additalic(Name,NameItalic) :- 
	$italic(Name,Italic),
	swrite(NameItalic,Name,'-',Italic).
	
$italic('Times','Italic').
$italic('Palatino','Italic').
$italic('NewCenturySchlbk','Italic').
$italic(_,'Oblique').

$ps_font(systemfont,'Courier').
$ps_font(applfont,'NewCenturySchlbk').
$ps_font('new century schoolbook','NewCenturySchlbk').
$ps_font(courier,'Courier').
$ps_font(times,'Times').
$ps_font(helvetica,'Helvetica').
$ps_font(symbol,'Symbol').
$ps_font(F,N) :- symbol(F),F=N.
$ps_font(0,'Courier').
$ps_font(1,'NewCenturySchlbk').
$ps_font(20,'Times').
$ps_font(21,'Helvetica').
$ps_font(22,'Courier').
$ps_font(23,'Symbol').
$ps_font(N,'NewCenturySchlbk'):- integer(N).

$ps_graf_desc(forecolor, $ps_forecolor).
$ps_graf_desc(pensize, $ps_pensize).
$ps_graf_desc(line, $ps_line).
$ps_graf_desc(arcrel, $ps_arcrel).
$ps_graf_desc(arcabs, $ps_arcabs).
$ps_graf_desc(circlerel, $ps_circlerel).
$ps_graf_desc(circleabs, $ps_circleabs).
$ps_graf_desc(ovalrel, $ps_ovalrel).
$ps_graf_desc(ovalabs, $ps_ovalabs).
$ps_graf_desc(pictrel, $ps_pictrel).
$ps_graf_desc(pictabs, $ps_pictabs).
$ps_graf_desc(rectrel, $ps_rectrel).
$ps_graf_desc(rectabs, $ps_rectabs).
$ps_graf_desc(rrectrel, $ps_rrectrel).
$ps_graf_desc(rrectabs, $ps_rrectabs).
$ps_graf_desc(crectrel, $ps_crectrel).
$ps_graf_desc(crectabs, $ps_crectabs).
$ps_graf_desc(iconrel, $ps_iconrel).
$ps_graf_desc(iconabs, $ps_iconabs).
$ps_graf_desc(linerel, $ps_linerel).
$ps_graf_desc(lineabs, $ps_lineabs).
$ps_graf_desc(textrel, $ps_textrel).
$ps_graf_desc(textabs, $ps_textabs).
$ps_graf_desc(textbrel, $ps_textbrel).
$ps_graf_desc(textbabs, $ps_textbabs).
$ps_graf_desc(textfont, $ps_textfont).
$ps_graf_desc(textsize, $ps_textsize).
$ps_graf_desc(textface, $ps_textface).
$ps_graf_desc(polygon, $ps_polygon).

