(* $Id: glArray.ml,v 1.6 2008-10-30 07:51:33 garrigue Exp $ *)

open Gl
open Raw

type kind = [`edge_flag | `texture_coord | `color | `index | `normal | `vertex ]

let check_static func f raw =
  if not (Raw.static raw) then
    invalid_arg ("GlArray." ^ func ^ " : buffer must be static");
  f raw

external _edge_flag : [< `bitmap] Raw.t -> unit = "ml_glEdgeFlagPointer"
let edge_flag raw = check_static "edge_flag" _edge_flag raw

type vertex_array_type = [ `short | `int | `float | `double]
type normal_array_type = [`byte | `short | `int | `float | `double]
type color_array_type  = [`byte | `ubyte | `short | `ushort | `int | `uint | `float | `double]
type index_array_type  = [ `ubyte | `short | `int | `float | `double ]
type texcoord_array_type = [ `short | `int | `float | `double ]
type fogcoord_array_type = [ `float | `double ]

external _tex_coord :
  [< `one | `two | `three | `four] -> 
  [< texcoord_array_type ] Raw.t -> unit 
	= "ml_glTexCoordPointer"
let tex_coord n = check_static "tex_coord" (_tex_coord n)


external _color :
  [< `three | `four] ->
  [< color_array_type ] Raw.t
  -> unit 
	= "ml_glColorPointer"
let color n = check_static "color" (_color n)

external _fog_coord : [< fogcoord_array_type ] Raw.t -> unit = "ml_glFogCoordPointer"

let fog_coord raw = check_static "fog_coord" _fog_coord raw

external _index : [< index_array_type ] Raw.t -> unit 
	= "ml_glIndexPointer"
let index raw = check_static "index" _index raw

external _normal : [< normal_array_type ] Raw.t -> unit 
	= "ml_glNormalPointer"
let normal raw = check_static "normal" _normal raw

external _vertex : 
  [< `two | `three | `four] -> [< vertex_array_type ] Raw.t 
  -> unit 
	= "ml_glVertexPointer"
let vertex n = check_static "vertex" (_vertex n)

external enable : kind -> unit= "ml_glEnableClientState"

external disable : kind -> unit	= "ml_glDisableClientState"

external element : int -> unit = "ml_glArrayElement"

external draw_arrays : GlDraw.shape -> first:int -> count:int -> unit 
    = "ml_glDrawArrays"

external multi_draw_arrays : mode:GlDraw.shape -> items:(int * int) array -> primcount:int -> unit
  = "ml_glMultiDrawArrays"

let multi_draw_arrays ~mode items =
  let primcount = Array.length items in
  multi_draw_arrays ~mode ~items ~primcount

external draw_elements 
    :  GlDraw.shape -> count:int -> [< `ubyte | `ushort | `uint] Raw.t -> unit
	= "ml_glDrawElements"  

