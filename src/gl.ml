(* $Id: gl.ml,v 1.25 2000-06-12 08:39:47 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

let _ = Callback.register_exception "glerror" (GLerror "")

(* Types common to all modules *)

type rgb = float * float * float
type rgba = float * float * float * float

type point2 = float * float
type point3 = float * float * float
type point4 = float * float * float * float
type vect3 = float * float *float

type clampf = float
type short = int
type kind = [`bitmap|`byte|`float|`int|`short|`ubyte|`uint|`ushort]
type real_kind = [`byte|`float|`int|`short|`ubyte|`uint|`ushort]

type format =
  [`alpha|`blue|`color_index|`depth_component|`green|`luminance
  |`luminance_alpha|`red|`rgb|`rgba|`stencil_index]
let format_size format =
  match (format :> format) with
    `rgba -> 4
  | `rgb -> 3
  | `luminance_alpha -> 2
  | _ -> 1

type target =
  [`color_4|`index|`normal|`texture_coord_1|`texture_coord_2|`texture_coord_3
  |`texture_coord_4|`trim_2|`trim_3|`vertex_3|`vertex_4]
let target_size (target : #target) =
    match target with
      `index|`normal|`texture_coord_1 -> 1
    | `texture_coord_2|`trim_2 -> 2
    | `vertex_3|`texture_coord_3|`trim_3 -> 3
    | `vertex_4|`color_4|`texture_coord_4 -> 4

type cmp_func =
  [`always|`equal|`gequal|`greater|`lequal|`less|`never|`notequal]
type face = [`back|`both|`front]

(* Basic functions *)

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"

type cap =
  [`alpha_test|`auto_normal|`blend|`clip_plane0|`clip_plane1|`clip_plane2
  |`clip_plane3|`clip_plane4|`clip_plane5|`color_material|`cull_face
  |`depth_test|`dither|`fog|`light0|`light1|`light2|`light3|`light4|`light5
  |`light6|`light7|`lighting|`line_smooth|`line_stipple|`logic_op
  |`map1_color_4|`map1_index|`map1_normal|`map1_texture_coord_1
  |`map1_texture_coord_2|`map1_texture_coord_3|`map1_texture_coord_4
  |`map1_vertex_3|`map1_vertex_4|`map2_color_4|`map2_index|`map2_normal
  |`map2_texture_coord_1|`map2_texture_coord_2|`map2_texture_coord_3
  |`map2_texture_coord_4|`map2_vertex_3|`map2_vertex_4|`normalize|`point_smooth
  |`polygon_smooth|`polygon_stipple|`scissor_test|`stencil_test|`texture_1d
  |`texture_2d|`texture_gen_q|`texture_gen_r|`texture_gen_s|`texture_gen_t]

external enable : cap -> unit = "ml_glEnable"
external disable : cap -> unit = "ml_glDisable"
external is_enabled : cap -> bool = "ml_glIsEnabled"
