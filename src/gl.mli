(* $Id: gl.mli,v 1.4 1998-01-14 09:32:36 garrigue Exp $ *)

exception GLerror of string

type clampf = float

type rgb = float * float * float
type rgba = float * float * float * float

type point2 = float * float
type point3 = float * float * float
type point4 = float * float * float * float

val clear_color : rgb -> ?alpha:float -> unit
val color : rgb -> ?alpha:float -> unit

type buffer_bit = [accum color depth stencil]
external clear : buffer_bit list -> unit = "ml_glClear"

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"

external rect : point2 -> point2 -> unit = "ml_glRect"
external vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
  = "ml_glVertex"
val vertex2 : point2 -> unit
val vertex3 : point3 -> unit
val vertex4 : point4 -> unit

type begin_enum =
  [line_loop line_strip lines points polygon quad_strip quads triangle_fan
   triangle_strip triangles]
external begin_block : begin_enum -> unit = "ml_glBegin"
external end_block : unit -> unit = "ml_glEnd"

external point_size : float -> unit = "ml_glPointSize"
external line_width : float -> unit = "ml_glLineWidth"
external line_stipple : factor:int -> pattern:int -> unit
  = "ml_glLineStipple"

type face = [back both front]
external polygon_mode : face:face -> mode:[fill line point] -> unit
  = "ml_glPolygonMode"

external front_face : [ccw cw] -> unit = "ml_glFrontFace"
external cull_face : [back both front] -> unit = "ml_glCullFace"

external polygon_stipple : mask:string -> unit = "ml_glPolygonStipple"
external edge_flag : bool -> unit = "ml_glEdgeFlag"

val normal : ?x:float -> ?y:float -> ?z:float -> unit
val normal3d : float * float * float -> unit

external matrix_mode : [modelview projection texture] -> unit
  = "ml_glMatrixMode"
external load_identity : unit -> unit = "ml_glLoadIdentity"
val load_matrix : float array array -> unit
val mult_matrix : float array array -> unit
external push_matrix : unit -> unit = "ml_glPushMatrix"
external pop_matrix : unit -> unit = "ml_glPopMatrix"

val translate : ?x:float -> ?y:float -> ?z:float -> unit
val rotate : angle:float -> ?x:float -> ?y:float -> ?z:float -> unit
val scale : ?x:float -> ?y:float -> ?z:float -> unit

external frustum :
  left:float ->
  right:float -> bottom:float -> top:float -> near:float -> far:float -> unit
  = "ml_glFrustum"

external ortho :
  left:float ->
  right:float -> bottom:float -> top:float -> near:float -> far:float -> unit
  = "ml_glOrtho"

external viewport : x:int -> y:int -> w:int -> h:int -> unit
  = "ml_glViewport"

external depth_range : near:float -> far:float -> unit = "ml_glDepthRange"

val clip_plane : plane:int -> equation:float array -> unit

type cap =
  [alpha_test auto_normal blend clip_plane0 clip_plane1 clip_plane2
   clip_plane3 clip_plane4 clip_plane5 color_material cull_face depth_test
   dither fog light0 light1 light2 light3 light4 light5 light6 light7
   lighting line_smooth line_stipple logic_op map1_color_4 map1_index
   map1_normal map1_texture_coord_1 map1_texture_coord_2 map1_texture_coord_3
   map1_texture_coord_4 map1_vertex_3 map1_vertex_4 map2_color_4 map2_index
   map2_normal map2_texture_coord_1 map2_texture_coord_2 map2_texture_coord_3
   map2_texture_coord_4 map2_vertex_3 map2_vertex_4 normalize point_smooth
   polygon_smooth polygon_stipple scissor_test stencil_test texture2d
   texture_1d texture_gen_q texture_gen_r texture_gen_s texture_gen_t]

external enable : cap -> unit = "ml_glEnable"
external disable : cap -> unit = "ml_glDisable"

external shade_model : [flat smooth] -> unit = "ml_glShadeModel"

type light_param =
  [ambient(rgba) constant_attenuation(float) diffuse(rgba)
   linear_attenuation(float) position(point4) quadratic_attenuation(float)
   specular(rgba) spot_cutoff(float) spot_direction(point4)
   spot_exponent(float)]
external light : num:int -> light_param -> unit = "ml_glLight"

type light_model_param = [ambient(rgba) local_viewer(float) two_side(float)]
external light_model : light_model_param -> unit = "ml_glLightModel"

type material_param =
  [ambient(rgba) ambient_and_diffuse(rgba)
   color_indexes(float * float * float) diffuse(rgba) emission(rgba)
   shininess(float) specular(rgba)]
external material : face:face -> material_param -> unit = "ml_glMaterial"

type depth_func = [always equal gequal greater lequal less never notequal]
external depth_func : depth_func -> unit = "ml_glDepthFunc"
external depth_mask : bool -> unit = "ml_glDepthMask"

type sfactor =
  [constant_alpha_ext constant_color_ext dst_alpha dst_color one
   one_minus_constant_alpha_ext one_minus_constant_color_ext
   one_minus_dst_alpha one_minus_dst_color one_minus_src_alpha src_alpha
   src_alpha_saturate zero]
type dfactor =
  [constant_alpha_ext constant_color_ext dst_alpha one
   one_minus_constant_alpha_ext one_minus_constant_color_ext
   one_minus_dst_alpha one_minus_src_alpha one_minus_src_color src_alpha
   src_color zero]
external blend_func : src:sfactor -> dst:dfactor -> unit = "ml_glBlendFunc"

type fog_param =
  [End(float) color(rgba) density(float)
   index(float) mode([exp exp2 linear]) start(float)]
external fog : fog_param -> unit = "ml_glFog"

(* Call lists *)

type glist
val shift_list : glist -> by:int -> glist
external is_list : glist -> bool = "ml_glIsList"
external gen_lists : int -> glist = "ml_glGenLists"
external delete_lists : from:glist -> range:int -> unit = "ml_glDeleteLists"
external new_list : glist -> mode:[compile compile_and_execute] -> unit
  = "ml_glNewList"
external end_list : unit -> unit = "ml_glEndList"
external call_list : glist -> unit = "ml_glCallList"
external call_lists : [byte(string) int(int array)] -> unit
  = "ml_glCallLists"
external list_base : glist -> unit = "ml_glListBase"

type accum_op = [accum add load mult return]
external accum : op:accum_op -> float -> unit = "ml_glAccum"

type alpha_func = [always equal gequal greater lequal less never notequal]
external alpha_func : alpha_func -> ref:clampf -> unit = "ml_glAlphaFunc"

type bitmap
external bitmap :
  width:int -> height:int -> orig:point2 -> move:point2 -> bitmap -> unit
  = "ml_glBitmap"

val clear_accum : rgb -> ?alpha:float -> unit
external clear_depth : clampf -> unit = "ml_glClearDepth"
external clear_index : float -> unit = "ml_glClearIndex"
external clear_stencil : int -> unit = "ml_glClearStencil"

val color_mask :
  ?red:bool -> ?green:bool -> ?blue:bool -> ?alpha:bool -> unit

type color_material = [ambient_and_diffuse ambient diffuse emission specular]
external color_material : face:face -> color_material -> unit
  = "ml_glColorMaterial"

external copy_pixels :
  x:int ->
  y:int -> width:int -> height:int -> type:[color depth stencil] -> unit
  = "ml_glCopyPixels"

external eval_coord1 : float -> unit = "ml_glEvalCoord1d"
external eval_coord2 : float -> float -> unit = "ml_glEvalCoord1d"
external eval_mesh1 : mode:[line point] -> int -> int -> unit
  = "ml_glEvalMesh1"
external eval_mesh2 : mode:[line point] -> int -> int -> int -> int -> unit
  = "ml_glEvalMesh1"
external eval_point1 : int -> unit = "ml_glEvalPoint1"
external eval_point2 : int -> int -> unit = "ml_glEvalPoint2"

type hint_target =
    [fog line_smooth perspective_correction point_smooth polygon_smooth]
type hint = [fastest nicest dont_care]
external hint : target:hint_target -> hint -> unit = "ml_glHint"

external index_mask : int -> unit = "ml_glIndexMask"
external index : float -> unit = "ml_glIndexd"
external init_names : unit -> unit = "ml_glInitNames"
external is_enabled : cap -> bool = "ml_glIsEnabled"

external load_name : int -> unit = "ml_glLoadName"
type logic_op =
    [ clear set copy copy_inverted noop invert And nand Or nor
      xor equiv and_reverse and_inverted or_reverse or_inverted ]
external logic_op : logic_op -> unit = "ml_glLogicOp"
