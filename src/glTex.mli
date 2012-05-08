(* $Id: glTex.mli,v 1.7 2007-04-13 02:48:43 garrigue Exp $ *)

open Gl

val coord : s:float -> ?t:float -> ?r:float -> ?q:float -> unit -> unit
val coord2 : float * float -> unit
val coord3 : float * float * float -> unit
val coord4 : float * float * float * float -> unit

type env_param = [
    `mode of [`modulate|`decal|`blend|`replace] 
  | `color of rgba]
val env : env_param -> unit

type coord = [`s|`t|`r|`q]
type gen_param = [
    `mode of [`object_linear|`eye_linear|`sphere_map|`reflection_map|`normal_map]
  | `object_plane of point4
  | `eye_plane of point4
]
val gen : coord:coord -> gen_param -> unit

type format =
    [`color_index|`red|`green|`blue|`alpha|`rgb|`rgba
    |`luminance|`luminance_alpha]


type internal = [
  `alpha | `alpha4 | `alpha8 | `alpha12 | `alpha16 
| `luminance | `luminance4 | `luminance8 | `luminance12 | `luminance16
| `luminance_alpha | `luminance4_alpha4 | `luminance6_alpha2 | `luminance8_alpha8
| `luminance12_alpha4 | `luminance12_alpha12 | `luminance16_alpha16
| `intensity | `intensity4 | `intensity8 | `intensity12 | `intensity16
| `rgb | `r3_g3_b2 | `rgb4 | `rgb5 | `rgb8 | `rgb10 | `rgb12 | `rgb16
| `rgba | `rgba2 | `rgba4 | `rgb5_a1 | `rgba8 | `rgb10_a2 | `rgba12 | `rgba16
]

type target_2d = [
  `texture_2d
| `texture_cube_map_positive_x
| `texture_cube_map_negative_x
| `texture_cube_map_positive_y
| `texture_cube_map_negative_y
| `texture_cube_map_positive_z
| `texture_cube_map_negative_z
| `proxy_texture_2d
| `proxy_texture_cube_map
]

(*
type target_1d = [
  `texture_1d
| `proxy_texture_1d
]

type target_3d = [
  `texture_3d
| `proxy_texture_3d
]
*)

val image1d :
  ?proxy:bool -> ?level:int -> ?internal:internal -> ?border:bool ->
  ([< format], [< kind]) GlPix.t -> unit
val image2d :
  ?target:target_2d -> ?level:int -> ?internal:internal -> ?border:bool ->
  ([< format], [< kind]) GlPix.t -> unit

(*
val image3d : 
  ?proxy:bool -> ?level:int -> ?internal:internal -> ?border:bool ->
  ([< format], [< kind]) GlPix.t -> unit
*)

type filter =
    [`nearest|`linear|`nearest_mipmap_nearest|`linear_mipmap_nearest
    |`nearest_mipmap_linear|`linear_mipmap_linear]
type wrap = [`clamp|`repeat|`clamp_to_edge|`clamp_to_border]
type parameter = [
    `min_filter of filter
  | `mag_filter of [`nearest|`linear]
  | `wrap_s of wrap
  | `wrap_t of wrap
  | `wrap_r of wrap
  | `border_color of rgba
  | `priority of clampf
  | `generate_mipmap of bool
] 
val parameter : target:[`texture_1d|`texture_2d|`texture_cube_map] -> parameter -> unit

type texture_id
val gen_texture : unit -> texture_id
val gen_textures : len:int -> texture_id array
val bind_texture : target:[`texture_1d|`texture_2d|`texture_cube_map] -> texture_id -> unit
val delete_texture : texture_id -> unit
val delete_textures : texture_id array -> unit
