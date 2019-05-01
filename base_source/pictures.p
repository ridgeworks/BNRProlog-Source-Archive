/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/pictures.p,v 1.1 1995/09/22 11:26:03 harrisja Exp $
*
*  $Log: pictures.p,v $
 * Revision 1.1  1995/09/22  11:26:03  harrisja
 * Initial version.
 *
*
*/


graf_output_desc(pictrel).
graf_output_desc(pictabs).

pictrel([Px,Py,Etc..],[Px,Py,Etc..],PictArgs,GC) :-
	$drawpict([Px,Py,Etc..], PictArgs, Px, Py, GC).

pictabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],PictArgs,GC) :-
	$drawpict([Px,Py,Sx,Sy,Ox,Oy,A], PictArgs, Ox, Oy, GC).

$drawpict([Px,Py,Sx,Sy,Etc..], [L,T,R,B,PictureID], Ox, Oy, GC) :-
	integer(PictureID),
	recall(picture(PictureID, _, frame(FXL,FYT,FXR,FYB), 
			[offset(XO,YO),scale(XS,YS),Attrs..]),$local),
    L1 is round(min(L,R)), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)),
    T1 is round(min(T,B)),
    B1 is round(max(T,B)),
	XScale is Sx*XS*(R1-L1)/(FXR-FXL),
	YScale is Sy*YS*(B1-T1)/(FYB-FYT),
	XOffset is Ox+L1-FXL+XO,
	YOffset is Oy+T1-FYT+YO,
	iswindow(Window,graf,_),
	window_id(Window,W,[GC,_,GCAttr..]),
	$window_attributes(Window,SavedAttrs),
	$dograf([offset(XOffset,YOffset),scale(XScale,YScale),Attrs..],
			-1,W,GC,GcAttr),
	foreach(recall(picture_element(PictureID,G),$local) do
		dograf(Window,G)),
	dograf(Window,SavedAttrs).

pictrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Pict],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

pictabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Pict],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

beginpicture(Window, frame(L,T,R,B), PictureID) :-
	window_id(Window,W,[GC,-1,GCAttrs..]), /* don't allow nested pictures (for now) */
	L1 is round(min(L,R)),
	R1 is round(max(L,R)),
	T1 is round(min(T,B)),
	B1 is round(max(T,B)),
	$newpictID(NewPictureID),
	PictureID=NewPictureID,
	$window_attributes(Window,Attrs),
	$setgc(W,[GC,PictureID,GCAttrs..]),
	remember(picture(PictureID,Window,frame(L1,T1,R1,B1),[Attrs..]),$local).

endpicture(PictureID) :-
	integer(PictureID),
	get_obj(Op,picture(PictureID,Window,Etc..),$local),
	window_id(Window,W,[GC,PictureID,GCAttrs..]),
	$setgc(W,[GC,-1,GCAttrs..]),
	put_obj(Op,picture(PictureID,nil,Etc..),$local).

deletepicture(PictureID) :-
	integer(PictureID),
	forget(picture(PictureID, Window, Etc..), $local),
	forget_all(picture_element(PictureID, G),$local),
	window_id(Window,W,[GC,PictureID,GCAttrs..])
	-> $setgc(W,[GC,-1,GCAttrs..]).

loadpicture(File, ResID, PictureID, Frame) :-
	open(Stream,File,read_only,0),
	get_term(Stream,picture(Frame,Etc..),GErr),
	GErr = 0
	; [close(Stream,0),fail],
	cut,
	$newpictID(NewPictureID),
	PictureID=NewPictureID,
	remember(picture(PictureID,nil,Frame,Etc..),$local),
	$loadpictureelements(Stream,PictureID,PErr),
	close(Stream,0),
	PErr = 0.

$loadpictureelements(Stream,PictureID,PErr) :-
	repeat,
	get_term(Stream,picture_element(G),Err),
	Err = 0
	-> rememberz(picture_element(PictureID,G),$local),
	Err \= 0,
	cut,
	Err = -39
	-> PErr = 0
	;  PErr = Err.

savepicture(File, ResID, PictName, PictureID) :-
	integer(PictureID),
	recall(picture(PictureID,Window,Etc..),$local),
	open(Stream,File,read_write,0),
	put_term(Stream,picture(Etc..),PErr),nl(Stream),
	PErr = 0
	; [close(Stream,0),fail],
	cut,
	$savepictureelements(Stream,PictureID,SErr),
	close(Stream,0),
	SErr = 0.

$savepictureelements(Stream,PictureID,Err) :-
	recall(picture_element(PictureID,G),$local),
	put_term(Stream,picture_element(G),Err),nl(Stream),
	Err \= 0,
	!. 
$savepictureelements(_,_,0).


listpictures(Pictures) :-
	findset(Pid,recall(picture(Pid,_..),$local),Pictures).

ispicture(PictureID, WindowName, Frame) :-
	recall(picture(PictureID, WindowName, Frame, _..), $local).

$get_icon_value(Icon, Stream) :-
	$outstream(Stream,FileP),	
	$get_icon_value_C(Icon,FileP).

$newpictID(PictureID) :-
	new_counter(0,C),
	repeat,
	counter_value(C,PictureID),
	C,
	not(recall(picture(PictureID,_..),$local)),
	!.

$window_attributes(Window,
					[offset(Ox,Oy),	% offset and scale go first since they are adjusted
					scale(Sx,Sy),	% when picture is projected to a rectangle
					angle(A),
					backcolor(BC),
					backpat(BP..),
					fillpat(FP),
					forecolor(FC),
					penmode(PM),
					penpat(PP..),
					pensize(PW,PH),
					position(PX,PY),
					textface(Styles..),
					textfont(F),
					textmode(TM),
					textsize(TS),
					userpat(UP..)]) :-
	inqgraf(Window,[offset(Ox,Oy),	% offset and scale go first since they are adjusted
					scale(Sx,Sy),	% when picture is projected to a rectangle
					angle(A),
					backcolor(BC),
					backpat(BP..),
					fillpat(FP),
					forecolor(FC),
					penmode(PM),
					penpat(PP..),
					pensize(PW,PH),
					position(PX,PY),
					textface(Styles..),
					textfont(F),
					textmode(TM),
					textsize(TS),
					userpat(UP..)]).


picttoscrap(PictureID) :-
	integer(PictureID),
    recall(picture(PictureID,Window,Etc..),$local),
    open(Stream,pict_pipe,read_write_pipe,0),
    put_term(Stream,picture(Etc..),PErr),
    PErr = 0
    ; [close(Stream,0),fail],
	cut,
    $picteltstoscrap(Stream,PictureID,SErr),
    cut,
    SErr = 0
    ; [close(stream,0),fail],
	cut,
    $validstream(Stream,FileP),
    $picttoscrap(FileP),
    close(Stream,_).

$picteltstoscrap(Stream,PictureID,Err) :-
    recall(picture_element(PictureID,G),$local),
    put_term(Stream,picture_element(G),Err),
    Err \= 0,
    !.
$picteltstoscrap(_,_,0).

scraptopict(PictureID) :-
    open(Stream,pict_pipe,read_write_pipe,0),
    $validstream(Stream,FileP),
    $scraptopict(FileP),
    get_term(Stream,picture(Frame,Etc..),GErr),
    GErr = 0
    ; [close(Stream,0),fail],
    cut,
	$newpictID(NewPictureID),
	PictureID=NewPictureID,
    remember(picture(PictureID,nil,Frame,Etc..),$local),
    $picteltsfromscrap(Stream,PictureID,PErr),
    close(Stream,_),
    PErr = 0.

$picteltsfromscrap(Stream,PictureID,PErr) :-
    repeat,
    get_term(Stream,picture_element(G),Err),
    Err = 0
    -> rememberz(picture_element(PictureID,G),$local),
    Err \= 0,
    cut,
    Err = -39
    -> PErr = 0
    ;  PErr = Err.


