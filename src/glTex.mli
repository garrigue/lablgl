(* $Id: glTex.mli,v 1.8 2012-03-06 03:31:02 garrigue Exp $ *)

open Gl

val coord : s:float -> ?t:float -> ?r:float -> ?q:float -> unit -> unit
val coord2 : float * float -> unit
val coord3 : float * float * float -> unit
val coord4 : float * float * float * float -> unit

type env_target = [ `texture_env | `filter_control ]

type env_param = 
  [ `mode of [`modulate|`decal|`blend|`replace|`add] 
  | `color of rgba]

type filter_param = [ `lod_bias of float ]

val env : [< env_target ] -> [env_param | filter_param ] -> unit

type coord = [`s|`t|`r|`q]

type gen_mode_param = [`object_linear|`eye_linear|`sphere_map|`reflection_map|`normal_map]

type gen_param = [
    `mode of gen_mode_param
  | `object_plane of point4
  | `eye_plane of point4
]

val gen : coord:[< coord ] -> [< gen_param ] -> unit

type format = 
  [ `color_index | `red | `green | `blue | `alpha | `rgb
  | `bgr | `rgba | `bgra | `luminance | `luminance_alpha ]


val internal_of_format : [< format] -> internalformat

type target_1d = 
  [ `texture_1d
  | `proxy_texture_1d ]

type target_2d = 
  [ `texture_2d
  | `texture_cube_map_positive_x
  | `texture_cube_map_negative_x
  | `texture_cube_map_positive_y
  | `texture_cube_map_negative_y
  | `texture_cube_map_positive_z
  | `texture_cube_map_negative_z
  | `proxy_texture_2d
  | `proxy_texture_cube_map ]

type target_3d = 
  [ `texture_3d
  | `proxy_texture_3d ]

val image1d :
  ?proxy:bool -> ?level:int -> ?internal:internalformat -> ?border:bool ->
  ([< format], [< kind]) GlPix.t -> unit

val image2d :
  ?target:target_2d -> ?level:int -> ?internal:internalformat -> ?border:bool ->
  ([< format], [< kind]) GlPix.t -> unit

val image3d : 
  ?proxy:bool -> ?level:int -> ?internal:internalformat -> ?border:bool ->
  ([< format], [< kind]) GlPix3D.t -> unit


type min_filter =
    [`nearest|`linear|`nearest_mipmap_nearest|`linear_mipmap_nearest
    |`nearest_mipmap_linear|`linear_mipmap_linear]
type mag_filter = [`nearest|`linear]
type wrap = [`clamp|`repeat|`clamp_to_edge|`clamp_to_border|`mirrored_repeat]

type depth_mode = [`luminance|`intensity|`alpha]
type compare_mode = [`lequal|`gequal]

type parameter =
  [ `min_filter of min_filter
  | `mag_filter of mag_filter
  | `wrap_s of wrap
  | `wrap_t of wrap
  | `wrap_r of wrap
  | `border_color of rgba
  | `priority of clampf
  | `generate_mipmap of bool
  | `min_lod of float
  | `max_lod of float
  | `base_level of int
  | `max_level of int 
  | `lod_bias of float
  | `depth_mode of depth_mode
  | `compare_mode of compare_mode] 

val parameter : target:[< `texture_1d|`texture_2d|`texture_cube_map] -> [< parameter ] -> unit

type texture_id
val gen_texture : unit -> texture_id
val gen_textures : len:int -> texture_id array
val bind_texture : target:[< `texture_1d|`texture_2d|`texture_cube_map] -> texture_id -> unit
val delete_texture : texture_id -> unit
val delete_textures : texture_id array -> unit
