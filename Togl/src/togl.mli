(* $Id: togl.mli,v 1.4 1999-11-15 14:32:16 garrigue Exp $ *)

type w
type widget = w Widget.widget

val render : widget -> unit
val swap_buffers : widget -> unit
val height : widget -> int
val width : widget -> int
type font = [
    `fixed_8x13
  | `fixed_9x15
  | `times_10
  | `times_24
  | `helvetica_10
  | `helvetica_12
  | `helvetica_18
  | `Xfont string
]
val load_bitmap_font : widget -> font:font -> GlList.base
val unload_bitmap_font : widget -> base:GlList.base -> unit
val use_layer : widget -> num:int -> unit
val show_overlay : widget -> unit
val hide_overlay : widget -> unit
val overlay_redisplay : widget -> unit
val exists_overlay : widget -> bool
val get_overlay_transparent_value : widget -> int
val make_current : widget -> unit

val display_func : widget -> cb:(unit -> unit) -> unit
val reshape_func : widget -> cb:(unit -> unit) -> unit
val overlay_display_func : widget -> cb:(unit -> unit) -> unit

val dump_to_eps_file :
    filename:string -> ?rgba:bool -> ?render:(unit -> unit) -> widget -> unit

val timer_func : ms:int -> cb:(unit -> unit) -> unit

val configure : ?height:int -> ?width:int -> widget -> string

val create :
  parent:'a Widget.widget ->
  ?name:string ->
  ?accum:bool ->
  ?accumalphasize:int ->
  ?accumbluesize:int ->
  ?accumgreensize:int ->
  ?accumredsize:int ->
  ?alpha:bool ->
  ?alphasize:int ->
  ?auxbuffers:int ->
  ?bluesize:int ->
  ?depth:bool ->
  ?depthsize:int ->
  ?double:bool ->
  ?greensize:int ->
  ?height:int ->
  ?overlay:bool ->
  ?privatecmap:bool ->
  ?redsize:int ->
  ?rgba:bool ->
  ?stencil:bool ->
  ?stencilsize:int -> ?stereo:bool -> ?width:int -> unit -> widget
