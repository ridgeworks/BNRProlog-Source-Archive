/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/dograf.p,v 1.1 1995/09/22 11:23:54 harrisja Exp $
*
*  $Log: dograf.p,v $
 * Revision 1.1  1995/09/22  11:23:54  harrisja
 * Initial version.
 *
*
*/

/*   DOGRAF / INQGRAF  IMPLEMENTATION CODE
     -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

 NOTE : gc_attrib(PositionX,PositionY,Scalex,ScaleY,OffsetX,OffsetY,Angle) 
        is stored in $local.
*/

$free_GC_fail(Gc) :-
	free_GC(Gc),
	failexit.


/* DOGRAF/INQGRAF ERROR HANDLING ROUTINE.

	If the debugger is ON, then print out a failure message for each 
	primitive that fails, and continue dograf execution.
	If the debugger is OFF, then succeed and continue. */
$graf_debug(Msg..):-
          enable_trace(DbugOn),
          DbugOn=1,!,
          write(Msg..).
$graf_debug(Msg..).

/* Puts a copy of the local attribute set  in the local state space 
  IF and ONLY if the set has been changed in the last graf traverse. */
$put_local_attrib(Gc_Attrib,Gc_Attrib,Wid,GC,PictID) :- !.
$put_local_attrib(Gc_Attrib,New_Attrib,Wid,GC,PictID) :-
    $setgc(Wid, [GC,PictID,New_Attrib..]).
	
dograf(Name,G) :-
    !,
    window_id(Name,W,[GC,PictID,GcAttr..]),
	$dograf(G,PictID,W,GC,GcAttr).

$dograf([G..],PictID,W,GC,Gc_Attrib) :-
	!,
    not(not([$$dograf(PictID, GC, Gc_Attrib, New_Attrib, [G..]),   % may fail
    /* Any locally held attributes changed in the top level will become permanent.*/
			$put_local_attrib(Gc_Attrib,New_Attrib,W,GC,PictID)
	])).

$dograf(G,PictID,W,GC,Gc_Attrib) :-
	 % Handles a single primitive, DOES NOT UNINSTANTIATE OUTCOMING BOUND VARIABLES.
	$$dograf(PictID, GC, Gc_Attrib, New_Attrib, G),
	/* Any locally held attributes changed in the top level will become permanent.*/
    $put_local_attrib(Gc_Attrib,New_Attrib,W,GC,PictID).

$$dograf(-1, GC, Gc_Attrib, New_Attrib, G) :-
	!,
	$traversegraflist(G,dograf,Gc_Attrib,New_Attrib,GC).

$$dograf(PictID, GC, Gc_Attrib, New_Attrib, G) :- 
    $inqcrectabs_C(GC,L,T,R,B),
    crectabs_C(GC,0,0,1,1),
	$update_attributes(G,PictID,GC,Gc_Attrib,New_Attrib),
    crectabs_C(GC,L,T,R,B),
	rememberz(picture_element(PictID,G),$local).

inqgraf(Name,G) :-
    !,
    window_id(Name,W,[GC,PictID,Gc_Attrib..]),
    $traversegraflist(G,inqgraf,Gc_Attrib,New_Attrib,GC),  % may fail cut,
    $put_local_attrib(Gc_Attrib,New_Attrib,W,GC,PictID).

% TRAVERSE GRAF LIST
/*  This predicate will traverse the input structure, keep a proper record 
	of the graphics attributes at various levels of nesting, and output the 
	primitives to handlers for execution.

    There are two types of attributes that this predicate deals with :
    1)  Local attributes.  These are stored in GC_ATTRIB, and contain attibutes
		that don't need to be passed to C : All changes and inquiries to these 
		attributes are done from within PROLOG.
        The local attributes are : Pen position, Scale, Offset, and Pen Angle. 
		The same local attribute can be set MANY TIMES within a nesting level, 
		and the set of attributes passed OUT of that level will reflect the 
		MOST RECENT change in the attributes.  The attributes that are output 
		from the top level of the command list (in the dograf predicate) are 
		used to update the global attribute list in the state space; all other 
		sets of attributes are local to the command list and disappear after 
		execution.

    2)  All other graphics attributes are stored in a C structure.  This 
		predicate keeps track of a pointer to this structure (GC) for the level 
		of nesting which we are currently in.
        These attributes access C routines that query and set their contents. */

$traversegraflist([],DoGraf,Gc_Attrib,Gc_Attrib,GC):-!. %%% vars caught here, bound to []

$traversegraflist([G,Gs..],DoGraf,Gc_Attrib,New_Attrib,GC) :-  % starting a new list
    list(G),
	!,
    clone_GC(GC,NewGC),
    /* It is not important to keep the local attribute information that may 
		come from lower nesting levels, so it is discarded. Also, any variable 
		instantiations made in this lower level are discarded. */
    not(not($traversegraflist(G,DoGraf,Gc_Attrib,_,NewGC)))
	; $free_GC_fail(NewGC),					% free the GC upon backtracking
    free_GC(NewGC),
    !,  %%% required to remove cp, aids LCO and GC
    $traversegraflist(Gs,DoGraf,Gc_Attrib,New_Attrib,GC).


/* Will direct do and inq primitives to the execgraf handling routine. */
$traversegraflist([G,Gs..],DoGraf,Gc_Attrib,New_Attrib,GC) :-
    !,
    $execgraf(G,DoGraf,Gc_Attrib,Attrib_Back,GC),!, % G not a list
    $traversegraflist([Gs..],DoGraf,Attrib_Back,New_Attrib,GC).

/* Will direct do and inq primitives not imbedded in a list to the execgraf 
	handling routine. */
$traversegraflist(GrafStruct,DoGraf,Gc_Attrib,New_Attrib,GC) :-    % not a list
    $execgraf(GrafStruct,DoGraf,Gc_Attrib,New_Attrib,GC).


clone_GC(GC,NewGC) :-
	clone_GC_C(GC,NewGC).

free_GC(GC) :-
	free_GC_C(GC).

/* EXECGRAF will execute a single primitive call. */

$execgraf([],_,Gc_Attrib,Gc_Attrib,GC) :-  % Catch variable primitives.
	!.

$execgraf($$$bind_to_variable(P..),_,Gc_Attrib,Gc_Attrib,GC) :-  % Catch variable functors.
	!,
	$graf_debug('\nDOGRAF WARNING : Variable Functor.\n').


	/* Execute DO descriptor */
$execgraf(F(P..),dograf,Gc_Attrib,New_Attrib,GC) :-  
    graf_output_desc(F),
    cut,
    F(Gc_Attrib,New_Attrib,P,GC),
    /* NOTE : If the primitive fails, it is due to :
         1. One or more of the arguments given were variable, or
         2. Other errors (Eg. Incorrect parameter types, system errors, etc.) */
    !.  % it succeeded, commit

	/* Execute INQ descriptor */
$execgraf(F(P..),inqgraf,Gc_Attrib,Gc_Attrib,GC) :- 
    graf_attr_desc(F,Cmd),
    !,
    Cmd(Gc_Attrib,P,GC),
    /* NOTE : If the primitive fails, it is due to :
		1. One or more of the arguments given were variable, or
		2. Other errors (Eg. Incorrect parameter types, system errors, etc.)
		3. Failure caused by using an inqgraf primitive as a filter */
    !.  % it succeeded, commit

	/* THIS NEXT CLAUSE 'OPENS THE DOOR' FOR THE USER TO EXECUTE
  	  ANY COMMAND WITHIN A DO(INQ)GRAF STRUCTURE. */
$execgraf(G,DoGraf,Gc_Attrib,Gc_Attrib,GC) :-   % try to execute
    G, /* ??? should we trap errors here (capsule) ??? */
    !. 

$execgraf(F(ParmList..),DoGraf,Gc_Attrib,Gc_Attrib,GC) :-  % nothing worked => debug message
   not(nonvar(ParmList..)),
   !,
   $graf_debug('\nDOGRAF WARNING : ',DoGraf(F(ParmList..)),
	' contains illegal variable parameters.\n').

$execgraf(GrafStruct,DoGraf,Gc_Attrib,Gc_Attrib,GC) :-  % nothing worked => debug message
   $graf_debug('\nDOGRAF WARNING : ',DoGraf(GrafStruct),' has failed.\n').

%%% do descriptor in do and inq modes
do(Gc_Attrib,Gc_Attrib,[GrafStruct],GC) :-  
    not(not($traversegraflist(GrafStruct,dograf,Gc_Attrib,_,GC))).
inqdo(Gc_Attrib,[GrafStruct],GC) :-  
	iswindow(Window,graf,_),
	window_id(Window,W,[GC,PictID,Gc_Attrib..]),
	not(not($$dograf(PictID, GC, Gc_Attrib, _, GrafStruct))). 
%%% inq descriptor in do and inq modes
inq(Gc_Attrib,Gc_Attrib,[GrafStruct],GC) :-  
    $traversegraflist(GrafStruct,inqgraf,Gc_Attrib,_,GC).
inqinq(Gc_Attrib,[GrafStruct],GC) :-  
    $traversegraflist(GrafStruct,inqgraf,Gc_Attrib,_,GC).

/* List of accepted graphics inquiry primitives */
graf_attr_desc(angle,inqangle).        % turtle graphics
graf_attr_desc(backcolor,inqbackcolor).
graf_attr_desc(backpat,inqbackpat).
graf_attr_desc(fillpat,inqfillpat).
graf_attr_desc(forecolor,inqforecolor).
graf_attr_desc(offset,inqoffset).
graf_attr_desc(penmode,inqpenmode).
graf_attr_desc(penpat,inqpenpat).
graf_attr_desc(pensize,inqpensize).
graf_attr_desc(position,inqposition).
graf_attr_desc(scale,inqscale).
graf_attr_desc(textface,inqtextface).
graf_attr_desc(textfont,inqtextfont).
graf_attr_desc(textmode,inqtextmode).
graf_attr_desc(textsize,inqtextsize).
graf_attr_desc(textwidth,inqtextwidth).
graf_attr_desc(textlines,inqtextlines).
graf_attr_desc(userpat,inquserpat).

graf_attr_desc(inq,inqinq).
graf_attr_desc(do,inqdo).

graf_attr_desc(dograf,_):-failexit($traversegraflist).    %%% prohibit nested calls to these??
graf_attr_desc(inqgraf,_):-failexit($traversegraflist).   %%%

inqposition([Posx,Posy,Rest..],[Posx_int,Posy_int,_..],GC):-
	Posx_int is round(Posx),
	Posy_int is round(Posy).
inqscale([Px,Py,Scalx,Scaly,Rest..],[Scalx,Scaly,_..],GC).
inqoffset([Px,Py,Sx,Sy,Offx,Offy,A],[Offx,Offy,_..],GC).
inqangle([Px,Py,Sx,Sy,Ox,Oy,Angl],[Angl,_..],GC).

/* The following lines are calls to external C routines. */

inqforecolor(Gc_Attrib,[Fore],GC):-
    /* This case will check if Fore is an integer color number. */
    numeric(Fore),
    !,
    Fore_int is round(Fore),
    inqforecolor_C(GC,Fore_int).
inqforecolor(Gc_Attrib,[Fore],GC):-
    inqforecolor_C(GC,Fore).


inqbackcolor(Gc_Attrib,[Back],GC):-
    /* This case will check if Back is an integer color number. */
    numeric(Back),
    !,
    Back_int is round(Back),
    inqbackcolor_C(GC,Back_int).
inqbackcolor(Gc_Attrib,[Back],GC):-
    inqbackcolor_C(GC,Back).
    
	
inqpenmode(Gc_Attrib,[Mode],GC):-
    inqpenmode_C(GC,Mode).


inqpensize(Gc_Attrib,[LineWidth, LineWidth],GC):-
    var(LineWidth),
    !,
    inqpensize_C(GC,LineWidth).
inqpensize(Gc_Attrib,[LineWidth, LineWidth_int],GC):-
	% This primitive is being used in filter mode: check the parameter's type
    LineWidth_int is round(LineWidth),
    inqpensize_C(GC,LineWidth_int).

inqpenpat(Gc_Attrib,[Pattern],GC) :-
    !,
    inqpenpat_C(GC,Pattern).
inqpenpat(Gc_Attrib,[Resource, Id],GC) :-
    var(Resource, Id),
    !,
    inqpenpat_C(GC,Resource,Id).
inqpenpat(Gc_Attrib,[Resource, Id],GC) :-
    Resource_int is round(Resource),
    Id_int is round(Id),
    inqpenpat_C(GC,Resource_int,Id_int).

inqbackpat(Gc_Attrib,[Pattern],GC) :-
    !,
    inqbackpat_C(GC,Pattern).
inqbackpat(Gc_Attrib,[Resource, Id],GC) :-
    var(Resource, Id),
    !,
    inqbackpat_C(GC,Resource,Id).
inqbackpat(Gc_Attrib,[Resource, Id],GC) :-
    Resource_int is round(Resource),
    Id_int is round(Id),
    inqbackpat_C(GC,Resource_int,Id_int).

inquserpat(Gc_Attrib,[Pattern],GC) :-
    !,
    inquserpat_C(GC,Pattern).
inquserpat(Gc_Attrib,[Resource, Id],GC) :-
    var(Resource, Id),
    !,
    inquserpat_C(GC,Resource,Id).
inquserpat(Gc_Attrib,[Resource, Id],GC) :-
    Resource_int is round(Resource),
    Id_int is round(Id),
    inquserpat_C(GC,Resource_int,Id_int).

inqfillpat(Gc_Attrib,[FillPat],GC) :-
    inqfillpat_C(GC,FillPat).

inqtextfont(Gc_Attrib,[Font],GC) :-
    inqtextfont_C(GC,F),
	$font(Font,F).

inqtextmode(Gc_Attrib,[Mode],GC) :-
	inqtextmode_C(GC,Mode).

inqtextsize(Gc_Attrib,[Pointsize],GC) :-
    inqtextsize_C(GC,Pointsize).

inqtextface(Gc_Attrib,[Styles..],GC) :-
    inqtextface_C(GC,Styles).

inqtextwidth(Gc_Attrib,[Text,Width],GC) :-
    textwidth_C(GC,Text,Width).

inqtextlines(Gc_Attrib,[Text,Width,Lines],GC) :-
	$textlines(GC,Text,Width,Lines).

/* List of accepted graphics output primitives */
graf_output_desc(line) :- !.    % turtle graphics
graf_output_desc(move) :- !.    % turtle graphics    
graf_output_desc(turn) :- !.    % turtle graphics
   
graf_output_desc(arcrel) :- !.    
graf_output_desc(circlerel) :- !.    
graf_output_desc(iconrel) :- !.    
graf_output_desc(linerel) :- !.
graf_output_desc(moverel) :- !.
graf_output_desc(ovalrel) :- !.
graf_output_desc(rectrel) :- !.
graf_output_desc(crectrel) :- !.
graf_output_desc(rrectrel) :- !.
graf_output_desc(textrel) :- !.
graf_output_desc(textbrel) :- !.

graf_output_desc(arcabs) :- !.
graf_output_desc(circleabs) :- !.
graf_output_desc(iconabs) :- !.
graf_output_desc(lineabs) :- !.
graf_output_desc(moveabs) :- !.
graf_output_desc(ovalabs) :- !.
graf_output_desc(rectabs) :- !.
graf_output_desc(crectabs) :- !.
graf_output_desc(rrectabs) :- !.
graf_output_desc(textabs) :- !.
graf_output_desc(textbabs) :- !.

graf_output_desc(scrollrect) :- !.
graf_output_desc(polygon) :- !.

graf_output_desc(textlines) :- !.

graf_output_desc(do) :- !.
graf_output_desc(inq) :- !.

%%% allow attribute descriptors as output descriptors
graf_output_desc(F):-graf_attr_desc(F,_).


graf_output_desc(dograf):- !,failexit($traversegraflist).    %%% prohibit nested calls to these??
graf_output_desc(inqgraf):- !,failexit($traversegraflist).   %%%


%***************
graf_output_desc(region).
%***************

/* ATTRIBUTE SETTING PRIMITIVES */
/* NOTE : Checks are done here to determine if the given parameters are variable.
	 If any are variable, the primitive will succeed, and will NOT call any external
	 C routines associated with that primitive. */

position([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X,Y],GC) :-
    PxNew is X*Sx + Ox,
    PyNew is Y*Sy + Oy.    

scale([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,SxNew,SyNew,Ox,Oy,A], [Scalx,Scaly],GC) :-
    SxNew is Scalx,
    SyNew is Scaly,    
    inqpensize_C(GC, PenSize),
    NewPenSize is round(PenSize * SxNew / Sx),
    pensize_C(GC,NewPenSize),                   		% Set new pen size
    inqtextsize_C(GC,TxSize),
    NewTxSize is round(TxSize * SxNew / Sx),

    /* Set the new text size.  MAY FAIL IF THE SPECIFIED TEXT SIZE IS TOO LARGE. */
    textsize_C(GC,NewTxSize).


offset([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,OxNew,OyNew,A], [Offx, Offy],GC):-
	OxNew is round(Offx),	
	OyNew is round(Offy).


angle([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,DegreesNew], [Degrees],GC):-
	DegreesNew is round(Degrees).


/* Begin calls to external C attribute setting routines */

forecolor(Gc_Attrib,Gc_Attrib, [Fore],GC) :- 
    forecolor_C(GC,Fore).

backcolor(Gc_Attrib,Gc_Attrib, [Back],GC) :-
    backcolor_C(GC,Back).

penmode(Gc_Attrib,Gc_Attrib, [Mode],GC) :-
    penmode_C(GC,Mode).

pensize(Gc_Attrib,Gc_Attrib, [LineWidth, Unused],GC) :-
    LineWidth_int is round(LineWidth),
    pensize_C(GC,LineWidth_int).

penpat(Gc_Attrib, Gc_Attrib, [PatName], GC) :-
	/* If the specified pattern is a symbol (either a standard PROLOG pattern name, or a
	  bitmap to be loaded from disk), */
	symbol(PatName),
	!,
	penpat_C(GC, PatName).
penpat(Gc_Attrib, Gc_Attrib, [Resource, Id], GC) :-
	Resource_int is round(Resource),
	Id_int is round(Id),
	penpat_C(GC, Resource_int, Id_int).


backpat(Gc_Attrib, Gc_Attrib, [PatName], GC) :-
        /* If the specified pattern is a symbol (either a standard PROLOG pattern name, or a
          bitmap to be loaded from disk), */
        symbol(PatName),
        !,
        backpat_C(GC, PatName).
backpat(Gc_Attrib, Gc_Attrib, [Resource, Id], GC) :-
        Resource_int is round(Resource),
        Id_int is round(Id),
        backpat_C(GC, Resource_int, Id_int).


userpat(Gc_Attrib, Gc_Attrib, [PatName], GC) :-
        /* If the specified pattern is a symbol (either a standard PROLOG pattern name, or a
          bitmap to be loaded from disk), */
        symbol(PatName),
        !,
        userpat_C(GC, PatName).
userpat(Gc_Attrib, Gc_Attrib, [Resource, Id], GC) :-
        Resource_int is round(Resource),
        Id_int is round(Id),
        userpat_C(GC, Resource_int, Id_int).

fillpat(Gc_Attrib, Gc_Attrib, [FillPat], GC) :-
	fillpat_C(GC, FillPat).


textfont(Gc_Attrib, Gc_Attrib, [Font], GC) :-
	$font(Font,F),
	textfont_C(GC,F).

textmode(Gc_Attrib, Gc_Attrib, [Mode], GC) :-
	textmode_C(GC,Mode).

textsize(Gc_Attrib, Gc_Attrib, [Pointsize], GC) :-
	textsize_C(GC,Pointsize).


textface(Gc_Attrib, Gc_Attrib, [Styles..], GC) :-
	textface_C(GC,Styles).

textwidth(Gc_Attrib, Gc_Attrib, [Text, Width], GC) :-
	textwidth_C(GC,Text, Width).

textlines(Gc_Attrib, Gc_Attrib, [Text,Width,Lines], GC) :-
	$textlines(GC,Text,Width,Lines).

/* GRAPHIC OUTPUT PRIMITIVES */  

line([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [Dist],GC) :-             % turtle graphics

/* TIMING NOTE : If Pen position is stored locally as a real number rather than
 		 an integer, this predicate takes about 0.2 ms longer to run. */
    A_rad is (A*pi/180),
    PxNew is Dist*cos(A_rad)*Sx +Px,
    PyNew is Dist*sin(A_rad)*Sy +Py,    % Clockwise rotation is considered positive.
    PxNew_int is round(PxNew),
    PyNew_int is round(PyNew),
    Px_int is round(Px),
    Py_int is round(Py),
    lineabs_C(GC, Px_int,Py_int,PxNew_int,PyNew_int).

move([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A],[Dist],GC) :-   	% turtle graphics
    A_rad is (A*pi/180),
    PxNew is Dist*cos(A_rad)*Sx +Px,
    PyNew is Dist*sin(A_rad)*Sy +Py.    % Clockwise rotation is considered positive.

turn([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,ANew], [Delta],GC) :-   	% turtle graphics
    ANew is round(A + Delta).

arcrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		    [L, T, R, B, StartAngle, DeltaAngle],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    SA_adj is round(360-(StartAngle+DeltaAngle)),
    DeltaAngle_chk is round(DeltaAngle),
    arcabs_C(GC,L1,T1,R1,B1,SA_adj,DeltaAngle_chk).

/* SAMPLE CODE FOR HANDLING INTERVAL INPUT, WHICH WILL BE IMPLEMENTED LATER. 
arcrel(Gc_Attrib,Gc_Attrib,[LR, TB, StartAngle, DeltaAngle],GC) :-
		range(LR[L,R]), range(TB[T,B]),
	   	 arcrel(Gc_Attrib,Gc_Attrib,[L,T,R,B,StartAngle,DeltaAngle],GC).
*/	


arcabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
	       	     [L, T, R, B, StartAngle, DeltaAngle],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    SA_adj is round(360-(StartAngle+DeltaAngle)),
    DeltaAngle_chk is round(DeltaAngle),
    arcabs_C(GC,L1,T1,R1,B1,SA_adj,DeltaAngle_chk ).

circlerel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		     [X, Y, Radius],GC) :-
    L is X-Radius, R is X+Radius,
    T is Y-Radius, B is Y+Radius,
    L1 is round(L*Sx +Px),
    R1 is round(R*Sx +Px),
    T1 is round(T*Sy +Py),
    B1 is round(B*Sy +Py),
    ovalabs_C(GC,L1,T1,R1,B1).

circleabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
                     [X, Y, Radius],GC) :-
    L is X-Radius, R is X+Radius,
    T is Y-Radius, B is Y+Radius,
    L1 is round(L*Sx +Ox),
    R1 is round(R*Sx +Ox),
    T1 is round(T*Sy +Oy),
    B1 is round(B*Sy +Oy),
    ovalabs_C(GC,L1,T1,R1,B1).

iconrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, Icon],GC) :-
    Icon_int is round(Icon),
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    iconabs_C(GC,L1,T1,R1,B1,Icon_int).

iconabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, Icon],GC) :-
    Icon_int is round(Icon),
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    iconabs_C(GC,L1,T1,R1,B1,Icon_int).

moverel([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
	PxNew is round(X*Sx + Px),
	PyNew is round(Y*Sy + Py).

moveabs([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
        PxNew is round(X*Sx + Ox),
        PyNew is round(Y*Sy + Oy).

ovalrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L,T,R,B],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    ovalabs_C(GC,L1,T1,R1,B1).

ovalabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L,T,R,B],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    ovalabs_C(GC,L1,T1,R1,B1).

rectrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    rectabs_C(GC,L1,T1,R1,B1).

rectabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
/* TIMING NOTE : The parameter checking done here adds about 0.4 ms onto the 
		primitive's execution time */ 
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    rectabs_C(GC,L1,T1,R1,B1).

crectrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    crectabs_C(GC,L1,T1,R1,B1).

crectabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    crectabs_C(GC,L1,T1,R1,B1).

/* Recursively checks a list of points representing endpoints in a series of connected
  line segments. 
   FAILS when a parameter of an incorrect type (or a VARIABLE parameter) is encountered. 
   RETURNS the updated pen position corresponding to the end of the line segment.*/
$check_segment_list_rel([],[],GC,GC):-!.
$check_segment_list_rel([Xrel,Yrel,Ps..],[Xabs,Yabs,PsAbs..],[Px,Py,Sx,Sy,Rest..],[PxNew,PyNew,Sx,Sy,Rest..]) :-
	Xabs is round(Xrel*Sx + Px),
	Yabs is round(Yrel*Sx + Py),
	$check_segment_list_rel(Ps,PsAbs,[Xabs,Yabs,Sx,Sy,Rest..],[PxNew,PyNew,Sx,Sy,Rest..]).

/* This section takes care of drawing a single line */
linerel([Px,Py,Sx,Sy,Ox,Oy,A],[PxNext,PyNext,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
    !,
    PxNext is round(X*Sx + Px),
    PyNext is round(Y*Sy + Py),		
    Px_int is round(Px),
    Py_int is round(Py),
    lineabs_C(GC,Px_int,Py_int,PxNext,PyNext).

/* This section handles the drawing of multiple connected lines */
linerel([Px,Py,Rest..],[PxNew,PyNew,Rest..], [X, Y, Points..],GC) :-
    Px_int is round(Px),
    Py_int is round(Py),
    $check_segment_list_rel([X,Y,Points..],[PointsAbs..],[Px,Py,Rest..],[PxNew,PyNew,Rest..]),
    multi_lineabs_C(GC, [Px_int,Py_int,PointsAbs..]).

/* Recursively checks a list of points representing endpoints in a series of connected
  line segments.
   FAILS when a parameter of an incorrect type (or a VARIABLE parameter) is encountered. 
   RETURNS the updated pen position corresponding to the end of the line segment.*/
$check_segment_list_abs([],[],GC,GC):-!.
$check_segment_list_abs([X,Y,Ps..],[Xabs,Yabs,PsAbs..],[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A]) :-
        Xabs is round(X*Sx + Ox),
        Yabs is round(Y*Sx + Oy),
        $check_segment_list_abs([Ps..],[PsAbs..],[Xabs,Yabs,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A]).

/* This section takes care of drawing a single line */
lineabs([Px,Py,Sx,Sy,Ox,Oy,A],[PxNext,PyNext,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
    !,
    PxNext is round(X*Sx + Ox),
    PyNext is round(Y*Sy + Oy),
    Px_int is round(Px),
    Py_int is round(Py),
    lineabs_C(GC,Px_int,Py_int,PxNext,PyNext).

/* This section handles the drawing of multiple connected lines */
lineabs([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y, Points..],GC) :-
    Px_int is round(Px),
    Py_int is round(Py),
    $check_segment_list_abs([X,Y,Points..],[PointsNew..],[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A]),
    multi_lineabs_C(GC,[Px_int,Py_int,PointsNew..]).

rrectrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, OvalWidth, OvalHeight],GC) :-
    New_Width is round(OvalWidth*Sx),
    New_Height is round(OvalHeight*Sy),
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    rrectabs_C(GC,L1,T1,R1,B1,New_Width,New_Height).

rrectabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, OvalWidth, OvalHeight],GC) :-
    New_Width is round(OvalWidth*Sx),
    New_Height is round(OvalHeight*Sy),
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    rrectabs_C(GC,L1,T1,R1,B1,New_Width,New_Height).

textrel([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y, Text],GC) :-
    Xnext is X*Sx + Px,
    X1 is round(Xnext),
    PyNew is Y*Sx + Py,
    Y1 is round(PyNew),
    textabs_C(GC,X1,Y1,Text),
    textwidth_C(GC, Text, Wx),
    PxNew is Xnext + Wx.

textabs([Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y, Text],GC) :-
    Xnext is X*Sx + Ox,
    X1 is round(Xnext),
    PyNew is Y*Sx + Oy,
    Y1 is round(PyNew),
    textabs_C(GC,X1,Y1,Text),
    textwidth_C(GC, Text, Wx),
    PxNew is Xnext + Wx.

textbrel([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Text],GC) :-
    L1 is round(min(L,R)*Sx +Px),   % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
	$textbabs(GC,L1,T1,R1,B1,Text).

textbabs([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Text],GC) :-
    L1 is round(min(L,R)*Sx +Ox),    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
	$textbabs(GC,L1,T1,R1,B1,Text).
	
$textbabs(GC,L,T,R,B,Text) :-
	inqfillpat_C(GC,Fillpat),
	fillpat_C(GC,clear),
	rectabs_C(GC,L,T,R,B),
	fillpat_C(GC,Fillpat),
	$textbox_arg(Text,Str,Start),
    $textbox(GC,L,T,R,B,Str,Start,textabs_C,GC).

$textbox_arg([Text1,Text2,Text3,Start],Text,Start) :-
	swrite(Text,Text1,Text2,Text3),
	!.
$textbox_arg([Text1,Text2,Text3],Text,0) :-
	swrite(Text,Text1,Text2,Text3),
	!.
$textbox_arg(Text,Text,0) :-
	symbol(Text),
	!.

scrollrect([Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B,DeltaX,DeltaY],GC) :-

    /* N O T E :  IT'S NOT CLEAR WHETHER WE WANT THIS PRIMITIVE TO BE AFFECTED BY THE
      APPLICATION OF A SCALING FACTOR. */

    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    DX is round(DeltaX),
    DY is round(DeltaY),
    scrollrect_C(GC,L1,T1,R1,B1,DX,DY).

$polygon_points([],[],GC):-!.

$polygon_points([moveabs(X,Y),Ps..],[Tx,Ty,Pts..],[Px,Py,Sx,Sy,Ox,Oy,A]) :-
	!,
	Tx is round(X*Sx+Ox),
	Ty is round(X*Sy+Oy),
	$polygon_points(Ps,Pts,[Tx,Ty,Sx,Sy,Ox,Oy,A]).

$polygon_points([moverel(X,Y),Ps..],[Tx,Ty,Pts..],[Px,Py,Sx,Sy,Ox,Oy,A]) :-
	!,
	Tx is round(X*Sx+Px),
	Ty is round(X*Sy+Py),
	$polygon_points(Ps,Pts,[Tx,Ty,Sx,Sy,Ox,Oy,A]).

$polygon_points([linerel(Ls..),Ps..],Points,[Px,Py,Other..]) :-
	!,
	$check_segment_list_rel(Ls,Pts,[Px,Py,Other..],[NewPx,NewPy,Other..]),
	$polygon_points(Ps,OtherPts,[NewPx,NewPy,Other..]),
	PxInt is round(Px),					%% added 94/2/18, LB's changes
	PyInt is round(Py),					%% added
%	$append(Pts,OtherPts,Points).		%% replaced
	$append([PxInt,PyInt,Pts..],OtherPts,Points).

$polygon_points([lineabs(Ls..),Ps..],Points,[Px,Py,Other..]) :-
	!,
	$check_segment_list_abs(Ls,Pts,[Px,Py,Other..],[NewPx,NewPy,Other..]),
	$polygon_points(Ps,OtherPts,[NewPx,NewPy,Other..]),
	PxInt is round(Px),					%% added 94/2/18, LB's changes
	PyInt is round(Py),					%% added
%	$append(Pts,OtherPts,Points).		%% replaced
	$append([PxInt,PyInt,Pts..],OtherPts,Points).

polygon(GCAttr,GCAttr,PolySpec,GC) :-
	$polygon_points(PolySpec,Points,GCAttr),
	polygon_C(GC,Points).

editbrel(Name,L,T,R,B,Text,Textout) :-
    $editbrel(Name,L,T,R,B,Text,Textout,['\t',enter]).
   
editbrel(Name,L,T,R,B,Text,Textout,[Exitset..]) :-
    $editbrel(Name,L,T,R,B,Text,Textout,[Exitset..]).

$editbrel(Name,L,T,R,B,Text,Textout,Exit) :-
    window_id(Name,W,[GC,_,Px,Py,Sx,Sy,Ox,Oy,A]),
    L1 is round(min(L,R)*Sx +Px),   % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py),
    $do_editbabs(GC,L1,T1,R1,B1,Text,Textout,Exit).

editbabs(Name,L,T,R,B,Text,Textout) :-
    $editbabs(Name,L,T,R,B,Text,Textout,['\t',enter]). 

editbabs(Name,L,T,R,B,Text,Textout,[Exitset..]) :-
    $editbabs(Name,L,T,R,B,Text,Textout,[Exitset..]).

$editbabs(Name,L,T,R,B,Text,Textout,Exit) :-
    window_id(Name,W,[GC,_,Px,Py,Sx,Sy,Ox,Oy,A]),
    L1 is round(min(L,R)*Sx +Ox),   % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy),
    $do_editbabs(GC,L1,T1,R1,B1,Text,Textout,Exit).

$do_editbabs(GC,L,T,R,B,[Text1,Text2,Text3,Start],Textout,[Exitset..]) :-
	symbol(Text1,Text2,Text3),
	!,
	$$do_editbabs(GC,L,T,R,B,[Text1,Text2,Text3,Start],Textout,[Exitset..]).

$do_editbabs(GC,L,T,R,B,[Text1,Text2,Text3],[Textout1,Textout2,Textout3],[Exitset..]) :-
	symbol(Text1,Text2,Text3),
	!,
	$$do_editbabs(GC,L,T,R,B,[Text1,Text2,Text3,0],[Textout1,Textout2,Textout3,_],[Exitset..]).

$do_editbabs(GC,L,T,R,B,Text,Textout,[Exitset..]) :-
	symbol(Text),
	!,
	$$do_editbabs(GC,L,T,R,B,[Text,'','',0],[Textout1,Textout2,Textout3,_],[Exitset..]),
	swrite(Textout,Textout1,Textout2,Textout3).

$$do_editbabs(GC,L,T,R,B,Text,Textout,[Exitset..]) :-
    editbabs_C(GC,L,T,R,B,Text,Textout,Event,Window,D1,D2,[Exitset..]),
    nextevent(Event,Window,D1,D2).

$update_attributes([],PictID,GC,GcAttr,GcAttr):-!.
$update_attributes([G..],PictID,GC,GcAttr,NewAttr) :-
	!,
	$$update_attributes(G,PictID,GC,GcAttr,NewAttr).
$update_attributes(G,PictID,GC,GcAttr,NewAttr) :-
	$$update_attributes([G],PictID,GC,GcAttr,NewAttr).

$$update_attributes([],PictID,GC,GcAttr,GcAttr):-!.
$$update_attributes([G,Gs..],PictID,GC,GcAttr,NewAttr) :-
	$$$update_attributes(G,PictID,GC,GcAttr,GcAttr1),
	$$update_attributes(Gs,PictID,GC,GcAttr1,NewAttr).

$$$update_attributes([G..],PictID,GC,GcAttr,GcAttr):-!.
$$$update_attributes(do(G..),PictID,GC,GcAttr,NewAttr):-
	!,
	$$update_attributes(G,PictID,GC,GcAttr,NewAttr).
$$$update_attributes(F(P..),PictID,GC,GcAttr,NewAttr):-
	graf_output_desc(F), % includes attribute descriptors
    $execgraf(F(P..),dograf,GcAttr,NewAttr,GC).
