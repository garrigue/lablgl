(* $Id: glTex.mli,v 1.1 1998-01-29 11:46:03 garrigue Exp $ *)

open Gl

val coord : s:float -> ?t:float -> ?r:float -> ?q:float -> unit
val coord2 : float * float -> unit
val coord3 : float * float * float -> unit
val coord4 : float * float * float * float -> unit

type env_param = [color(rgba) mode([blend decal modulate replace])]
val env : env_param -> unit

type coord = [q r s t]
type gen_param =
  [eye_plane(point4) mode([eye_linear object_linear sphere_map])
   object_plane(point4)]
val gen : coord:coord -> gen_param -> unit

type format =
  [alpha blue color_index green luminance luminance_alpha red rgb rgba]
val image1d :
  (#format, #kind) GlPix.t ->
  ?proxy:bool -> ?level:int -> ?internal:int -> ?border:bool -> unit
val image2d :
  (#format, #kind) GlPix.t ->
  ?proxy:bool -> ?level:int -> ?internal:int -> ?border:bool -> unit

type filter =
  [linear linear_mipmap_linear linear_mipmap_nearest nearest
   nearest_mipmap_linear nearest_mipmap_nearest]
type wrap = [clamp repeat]
type parameter =
  [border_color(rgba) mag_filter([linear nearest]) min_filter(filter)
   priority(clampf) wrap_s(wrap) wrap_t(wrap)]
val parameter : target:[texture_1d texture_2d] -> parameter -> unit
