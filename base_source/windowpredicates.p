/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/windowpredicates.p,v 1.1 1995/09/22 11:29:12 harrisja Exp $
*
*  $Log: windowpredicates.p,v $
 * Revision 1.1  1995/09/22  11:29:12  harrisja
 * Initial version.
 *
*
*/

/*
 *   WindowPredicates - All the window arrangment predicates
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

stackwindows(_WindowType, _Visible) :- [
    prologwindows(_AllWindows),
    $remove_others(_AllWindows, _WindowType, _Visible, _Windows),
    $stackwindows(_Windows), 
    ! ].            % remove choicepoints in $remove_others and $stackwindows

tilewindows(_WindowType, _Visible) :- [
    prologwindows(_AllWindows),
    $remove_others(_AllWindows, _WindowType, _Visible, _Windows),
    termlength(_Windows, _n, _),
    $windoworder(_n, _numx, _numy),
    $tilewindows(_Windows, _numx, _numy),
    ! ].            % remove choicepoints in $remove_others and $tilewindows

%%% 4 constants used to determine how to stack windows
%%% windows stacked in groups of 5.
%%% first pair determine movement within a group of 5
%%% second pair determine movement between groups
%%% eg. (20, 10, 15, 0) means that window 2 will be left 20 and down 10 from window 1
%%%                                window 6 will be left 15 and down 0 from window 1
$stackoffset(20, 10, 15, 2).

$stackwindows(_ws) :-
    termlength(_ws, _n, _), 
    scrndimensions(_sw, _sh, main),
    mbarheight(_mbh),
    $stackoffset(_sx, _sy, _ssx, _),
    _t is (_n // 5) - 1,
    _n > 4 ->
        [_winwidth is (_sw - 8 - (4 * _sx) - (_t * _ssx)),
         _winheight is (_sh - _mbh - 8 - _mbh - (_sy * 4)),
         _offsetx is (_sx * 4) + 4 + (_t * _sx)];
        [_winwidth is (_sw - 8 - (_sx * (_n-1))),
         _winheight is (_sh - _mbh - 8 - _mbh - (_sy * (_n-1))),
         _offsetx is (_n-1) * _sx + 4 ],
    _offsety is _mbh + _mbh + 4,
    $adjuststackwindows(_ws, _t, 5, _offsetx, _offsety, _winwidth, _winheight).

$windoworder(_windows, _numx, _numy) :- [
    _numx is min(integer(sqrt(_windows*1.0)), 4),
    _numy is (_windows + _numx - 1) // _numx].

$tilewindows(_ws, _numx, _numy) :- [
    scrndimensions(_sw, _sh, main),
    mbarheight(_mbh),
    _winwidth is (_sw - 4 - (_numx * 4)) // _numx,
    _winheight is (_sh  - (_mbh + 4) * (_numy + 1)) // _numy,
    $adjustwindows(_ws, _numy, 1, 1, _winwidth, _winheight) ].

$adjustwindows([], _, _, _, _, _).
$adjustwindows([_w, _ws..], _numy, _posx, _posy, _width, _height) :- [
    $sizewin(_w, _width, _height),
    _offsetx is 4 + ((_posx - 1) * (_width + 4)),
    mbarheight(_mbh),
    _offsety is _mbh + 4 + _mbh + ((_posy-1) * (_height + _mbh + 4)), 
    $positionwin(_w, _offsetx, _offsety),
    successor(_posy, _t),
    _t > _numy ->
        [successor(_posx, _u), $adjustwindows(_ws, _numy, _u, 1, _width, _height)] ;
        [$adjustwindows(_ws, _numy, _posx, _t, _width, _height)] ].

$adjuststackwindows([], _, _, _, _, _, _).
$adjuststackwindows([_w, _ws..], _n, _count, _offsetx, _offsety, _width, _height) :- [
    $sizewin(_w, _width, _height),
    $positionwin(_w, _offsetx, _offsety),
    mbarheight(_mbh),
    $stackoffset(_sx, _sy, _ssx, _ssy),
    _newx is _offsetx - _sx,
    _newy is _offsety + _sy,
    successor(_newcount, _count),
    _newcount < 1 ->
        [successor(_nn, _n),
         _t is 4 + (4 * _sx) + (_nn * _ssx),
         _u is _mbh + _mbh + 4 + _ssy,
         $adjuststackwindows(_ws, _nn, 5, _t, _u, _width, _height)];
        [$adjuststackwindows(_ws, _n, _newcount, _newx, _newy, _width, _height)] ].

$remove_others([], _, _, []).
$remove_others([X, Xs..], Type, Visible, [X, Rs..] ) :-
    not(not(iswindow(X, Type, Visible))),
    $remove_others(Xs, Type, Visible, Rs).
$remove_others([X, Xs..], Type, Visible, [Rs..] ) :- 
    $remove_others(Xs, Type, Visible, Rs). 

%%% Only size and position window if required.

$sizewin(_w, _width, _height) :- [
    sizewindow(_w, _a, _b),
    _a = _width,
    _b = _height,
    ! ].
$sizewin(_w, _width, _height) :- sizewindow(_w, _width, _height).

$positionwin(_w, _offsetx, _offsety) :- [
    positionwindow(_w, _a, _b),
    _a = _offsetx,
    _b = _offsety,
    ! ].
$positionwin(_w, _offsetx, _offsety) :- positionwindow(_w, _offsetx, _offsety).
