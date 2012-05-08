(* $Id: gl.ml,v 1.30 2007-04-13 01:17:50 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

exception TagError of int

let _ = Callback.register_exception "glerror" (GLerror "")
let _ = Callback.register_exception "tagerror" (TagError 0)

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
  |`luminance_alpha|`red|`rgb|`rgba|`bgr|`bgra|`stencil_index]

let format_size (#format as f) =
  match f with
      `rgba | `bgra -> 4
    | `rgb  | `bgr -> 3
    | `luminance_alpha -> 2
    | _ -> 1

type internalformat = [
  `alpha | `alpha4 | `alpha8 | `alpha12 | `alpha16 
| `luminance | `luminance4 | `luminance8 | `luminance12 | `luminance16
| `luminance_alpha | `luminance4_alpha4 | `luminance6_alpha2 | `luminance8_alpha8
| `luminance12_alpha4 | `luminance12_alpha12 | `luminance16_alpha16
| `intensity | `intensity4 | `intensity8 | `intensity12 | `intensity16
| `rgb | `r3_g3_b2 | `rgb4 | `rgb5 | `rgb8 | `rgb10 | `rgb12 | `rgb16
| `rgba | `rgba2 | `rgba4 | `rgb5_a1 | `rgba8 | `rgb10_a2 | `rgba12 | `rgba16 
]

type target =
  [`color_4|`index|`normal|`texture_coord_1|`texture_coord_2|`texture_coord_3
  |`texture_coord_4|`trim_2|`trim_3|`vertex_3|`vertex_4]
let target_size = function
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
  |`light6|`light7|`lighting|`line_smooth|`line_stipple
  |`index_logic_op |`color_logic_op
  |`map1_color_4|`map1_index|`map1_normal|`map1_texture_coord_1
  |`map1_texture_coord_2|`map1_texture_coord_3|`map1_texture_coord_4
  |`map1_vertex_3|`map1_vertex_4|`map2_color_4|`map2_index|`map2_normal
  |`map2_texture_coord_1|`map2_texture_coord_2|`map2_texture_coord_3
  |`map2_texture_coord_4|`map2_vertex_3|`map2_vertex_4|`normalize|`point_smooth
  |`polygon_offset_fill|`polygon_offset_line|`polygon_offset_point
  |`polygon_smooth|`polygon_stipple|`scissor_test|`stencil_test|`texture_1d
  |`texture_2d|`texture_cube_map|`texture_gen_q|`texture_gen_r|`texture_gen_s|`texture_gen_t
  |`sample_coverage|`sample_alpha_to_coverage|`sample_alpha_to_one|`multisample
  | `convolution_1d | `convolution_2d | `separable_2d | `histogram | `minmax ]

external enable : [< cap ] -> unit = "ml_glEnable"
external disable : [< cap ] -> unit = "ml_glDisable"
external is_enabled : [< cap ] -> bool = "ml_glIsEnabled"

type error =
  [`no_error|`invalid_enum|`invalid_value|`invalid_operation
  |`stack_overflow|`stack_underflow|`out_of_memory|`table_too_large]
external get_error : unit -> error = "ml_glGetError"
let raise_error name =
  let err = get_error () in
  if err = `no_error then () else
  let s =
    List.assoc err
      [ `invalid_enum, "Invalid Enum";
        `invalid_value, "Invalid Value";
        `invalid_operation, "Invalid Operation";
        `stack_overflow, "Stack Overflow";
        `stack_underflow, "Stack Underflow";
        `out_of_memory, "Out of Memory";
        `table_too_large, "Table Too Large" ]
  in
  let s = if name = "" then s else (name ^ ": " ^ s) in
  raise (GLerror s)
