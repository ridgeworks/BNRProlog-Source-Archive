/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/pFormat.p,v 1.1 1995/09/22 11:26:01 harrisja Exp $
*
*  $Log: pFormat.p,v $
 * Revision 1.1  1995/09/22  11:26:01  harrisja
 * Initial version.
 *
*
*/

/*
 *   pFormat - Pascal-like output format package
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1988 
 */
 
/*                            pFormat

 
    An output formatting package modelled on Pascal WRITE syntax.
    pformat/n is a variadic predicate which unifies its first argument
    with the string specified by the rest of the arguments. Each argument
    may have the form:

           term:field_length:decplaces 
 
    Both 'length' and 'decplaces' are optional. If 'length' is specified, the
    'value' string will have that length unless it can not be so represented,
    in which case the string will be long enough to represent the 'value'.
    'decplaces' only has significance for floating point numbers; it is
    ignored in all other cases. Any term will be processed, even if only
    by 'swrite' semantics.
*/

pformat(_string,_args..):- $form(_string,"",_args..).

$form(_string,_string):-!.                  %end case, no more arguments.

$form(_string,_instring,_arg,_args..):-
    [once($putform(_arg,_st)),
     concat(_instring,_st,_newstr),
     $form(_string,_newstr,_args..)
    ].

$putform(_float:_l:_dp,_s):-             %floats with frac. spec.
    [float(_float),
     _scale is 10**_dp,
     _f is round(_float*_scale),
     _i is _f//_scale,
     swrite(_is,_i),
     _fr is _f mod _scale,
     swrite(_fs,_fr),
     once($padfrac(_is,_fs,_dp,_string)),
     $right_justify(_string,_l,_s)
    ].

$putform(_nonfloat:_l:_dp,_s):-          %non-floats with frac. spec.
    [not(float(_nonfloat)),
     once($putform(_nonfloat:_l,_s))
    ].

$putform(_num:_l,_s):-                   %integers and floats with no frac. spec.
    [number(_num),
     swrite(_string,_num),
     $right_justify(_string,_l,_s)
    ].

$putform(_others:_l,_s):-                %symbols, strings and anything else with a length specifier
    [swrite(_string,_others),
     $left_justify(_string,_l,_s)
    ].

$putform(_x,_s):- swrite(_s,_x).         %when all else fails

$left_justify(_ins,_len,_outs):-
    [namelength(_ins,_currlen),
     _padl is _len-_currlen,
     name(_ins,_inl),
     $padright(_inl,_padl,32,_outl),
     name(_outs,_outl)
    ].

$padright(_il,_n,_v,_ol):-
    [$buildpad(_n,_v,_vl),
     $append(_il,_vl,_ol),
    ].

$buildpad(_n,_,[]):-
    [_n=<0,
     cut($buildpad)
    ].

$buildpad(_n,_v,[_v,_vs..]):-
    [_n1 is _n-1,
     $buildpad(_n1,_v,_vs)
    ].
     
$right_justify(_ins,_len,_outs):-
    [namelength(_ins,_currlen),
     _padl is _len-_currlen,
     name(_ins,_inl),
     $padleft(_inl,_padl,32,_outl),
     name(_outs,_outl)
    ].

$padleft(_l,_n,_,_l):-
    [_n=<0,
     cut($padleft)
    ].

$padleft([_il..],_n,_v,_ol):-
    [_n1 is _n-1,
     $padleft([_v,_il..],_n1,_v,_ol)
    ].

$padfrac(_is,_fs,_dp,_string):-             %form (leading) zeros for floats
    [name(_is,_il),
     namelength(_fs,_l),
     _padl is _dp-_l,
     name(_fs,_fl),
     $padleft(_fl,_padl,48,_flp),
     $append(_il,[46],_l1),
     $append(_l1,_flp,_lst),
     name(_string,_lst)
    ].

$append([], _L, _L) .

$append([_H, _T1..], _L, [_H, _T2..]) :-
      [
        $append([_T1..], _L, [_T2..]) 
      ] .
