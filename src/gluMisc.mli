(* $Id: gluMisc.mli,v 1.1 1998-01-29 11:46:08 garrigue Exp $ *)

open Gl

val get_string : [extensions version] -> string

val build_1d_mipmaps :
  (#GlTex.format, #kind) GlPix.t -> ?internal:int -> unit

val build_2d_mipmaps :
  (#GlTex.format, #kind) GlPix.t -> ?internal:int -> unit

val scale_image :
  (#format as 'a, #kind as 'b) GlPix.t ->
  width:int -> height:int -> ('a, 'b) GlPix.t
