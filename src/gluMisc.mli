(* $Id: gluMisc.mli,v 1.3 2001-10-01 02:59:13 garrigue Exp $ *)

open Gl

val get_string : [`extensions|`version] -> string

val build_1d_mipmaps :
  ?internal:int -> ([< GlTex.format], [< kind]) GlPix.t -> unit

val build_2d_mipmaps :
  ?internal:int -> ([< GlTex.format], [< kind]) GlPix.t -> unit

val scale_image :
  width:int -> height:int ->
  ([< format] as 'a, [< kind] as 'b) GlPix.t -> ('a, 'b) GlPix.t
