(* $Id: gl.mli,v 1.8 1998-01-19 06:57:07 garrigue Exp $ *)

exception GLerror of string

type rgb = float * float * float
type rgba = float * float * float * float

type point2 = float * float
type point3 = float * float * float
type point4 = float * float * float * float

type clampf = float
type glist

type addr
type gltype = [bitmap byte float int short ubyte uint ushort]
type 'a rawdata = { kind: 'a; size: int; addr: addr }

val coerce_bitmap : gltype rawdata -> [bitmap] rawdata

type cmp_func = [ never less equal lequal greater notequal gequal always ]
type face = [back both front]
type cap =
  [alpha_test auto_normal blend clip_plane0 clip_plane1 clip_plane2
   clip_plane3 clip_plane4 clip_plane5 color_material cull_face depth_test
   dither fog light0 light1 light2 light3 light4 light5 light6 light7
   lighting line_smooth line_stipple logic_op map1_color_4 map1_index
   map1_normal map1_texture_coord_1 map1_texture_coord_2 map1_texture_coord_3
   map1_texture_coord_4 map1_vertex_3 map1_vertex_4 map2_color_4 map2_index
   map2_normal map2_texture_coord_1 map2_texture_coord_2 map2_texture_coord_3
   map2_texture_coord_4 map2_vertex_3 map2_vertex_4 normalize point_smooth
   polygon_smooth polygon_stipple scissor_test stencil_test texture_1d
   texture_2d texture_gen_q texture_gen_r texture_gen_s texture_gen_t]

type accum_op = [accum add load mult return]
external accum : op:accum_op -> float -> unit = "ml_glAccum"
external alpha_func : cmp_func -> ref:clampf -> unit = "ml_glAlphaFunc"

type begin_enum =
  [line_loop line_strip lines points polygon quad_strip quads triangle_fan
   triangle_strip triangles]
external begin_block : begin_enum -> unit = "ml_glBegin"
external bitmap :
  width:int ->
  height:int -> orig:point2 -> move:point2 -> [bitmap] rawdata -> unit
  = "ml_glBitmap"
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

val clear_accum : rgb -> ?alpha:float -> unit
type buffer = [accum color depth stencil]
external clear : buffer list -> unit = "ml_glClear"
val clear_color : rgb -> ?alpha:float -> unit
external clear_depth : clampf -> unit = "ml_glClearDepth"
external clear_index : float -> unit = "ml_glClearIndex"
external clear_stencil : int -> unit = "ml_glClearStencil"
val clip_plane : plane:int -> equation:float array -> unit
val color : rgb -> ?alpha:float -> unit
val color_mask :
  ?red:bool -> ?green:bool -> ?blue:bool -> ?alpha:bool -> unit
type color_material = [ambient ambient_and_diffuse diffuse emission specular]
external color_material : face:face -> color_material -> unit
  = "ml_glColorMaterial"
external copy_pixels :
  x:int ->
  y:int -> width:int -> height:int -> type:[color depth stencil] -> unit
  = "ml_glCopyPixels"
external cull_face : face -> unit = "ml_glCullFace"

external depth_func : cmp_func -> unit = "ml_glDepthFunc"
external depth_mask : bool -> unit = "ml_glDepthMask"
external depth_range : near:float -> far:float -> unit = "ml_glDepthRange"
external disable : cap -> unit = "ml_glDisable"
type draw_buffer_mode =
  [aux(int) back back_left back_right front front_and_back front_left
   front_right left none right]
external draw_buffer : draw_buffer_mode -> unit = "ml_glDrawBuffer"
type pixels_format =
  [alpha blue color_index depth_component green luminance luminance_alpha 
   red rgb rgba stencil_index]
external draw_pixels :
  width:int -> height:int -> format:pixels_format -> gltype rawdata -> unit
  = "ml_glDrawPixels"

external edge_flag : bool -> unit = "ml_glEdgeFlag"
external enable : cap -> unit = "ml_glEnable"
external end_block : unit -> unit = "ml_glEnd"
external eval_coord1 : float -> unit = "ml_glEvalCoord1d"
external eval_coord2 : float -> float -> unit = "ml_glEvalCoord1d"
external eval_mesh1 : mode:[line point] -> int -> int -> unit
  = "ml_glEvalMesh1"
external eval_mesh2 : mode:[line point] -> int -> int -> int -> int -> unit
  = "ml_glEvalMesh1"
external eval_point1 : int -> unit = "ml_glEvalPoint1"
external eval_point2 : int -> int -> unit = "ml_glEvalPoint2"

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"
type fog_param =
  [End(float) color(rgba) density(float) index(float)
   mode([exp exp2 linear]) start(float)]
external fog : fog_param -> unit = "ml_glFog"
external front_face : [ccw cw] -> unit = "ml_glFrontFace"
external frustum :
  left:float ->
  right:float -> bottom:float -> top:float -> near:float -> far:float -> unit
  = "ml_glFrustum"

type hint_target =
  [fog line_smooth perspective_correction point_smooth polygon_smooth]
type hint = [dont_care fastest nicest]
external hint : target:hint_target -> hint -> unit = "ml_glHint"

external index_mask : int -> unit = "ml_glIndexMask"
external index : float -> unit = "ml_glIndexd"
external init_names : unit -> unit = "ml_glInitNames"
external is_enabled : cap -> bool = "ml_glIsEnabled"

type light_param =
  [ambient(rgba) constant_attenuation(float) diffuse(rgba)
   linear_attenuation(float) position(point4) quadratic_attenuation(float)
   specular(rgba) spot_cutoff(float) spot_direction(point4)
   spot_exponent(float)]
external light : num:int -> light_param -> unit = "ml_glLight"
type light_model_param = [ambient(rgba) local_viewer(float) two_side(float)]
external light_model : light_model_param -> unit = "ml_glLightModel"
external line_width : float -> unit = "ml_glLineWidth"
external line_stipple : factor:int -> pattern:int -> unit
  = "ml_glLineStipple"
external load_name : int -> unit = "ml_glLoadName"
external load_identity : unit -> unit = "ml_glLoadIdentity"
val load_matrix : float array array -> unit
type logic_op =
  [And Or and_inverted and_reverse clear copy copy_inverted equiv invert 
   nand noop nor or_inverted or_reverse set xor]
external logic_op : logic_op -> unit = "ml_glLogicOp"

type map_target =
  [color_4 index normal texture_coord_1 texture_coord_2 texture_coord_3
   texture_coord_4 vertex_3 vertex_4]
external map1 : target:map_target -> float * float -> float array -> unit
  = "ml_glMap1d"
external map2 :
  target:map_target ->
  float * float -> float * float -> float array array -> unit = "ml_glMap2d"
external map_grid1 : n:int -> range:float * float -> unit = "ml_glMapGrid1d"
external map_grid2 :
  n:int -> range:float * float -> n:int -> range:float * float -> unit
  = "ml_glMapGrid2d"
type material_param =
  [ambient(rgba) ambient_and_diffuse(rgba)
   color_indexes(float * float * float) diffuse(rgba) emission(rgba)
   shininess(float) specular(rgba)]
external material : face:face -> material_param -> unit = "ml_glMaterial"
external matrix_mode : [modelview projection texture] -> unit
  = "ml_glMatrixMode"
val mult_matrix : float array array -> unit

val normal : ?x:float -> ?y:float -> ?z:float -> unit
val normal3d : float * float * float -> unit

external ortho :
  left:float ->
  right:float -> bottom:float -> top:float -> near:float -> far:float -> unit
  = "ml_glOrtho"

external pass_through : float -> unit = "ml_glPassThrough"
type pixel_map =
  [a_to_a b_to_b g_to_g i_to_a i_to_b i_to_g i_to_i i_to_r r_to_r s_to_s]
external pixel_map : map:pixel_map -> float array -> unit = "ml_glPixelMapfv"
type pixel_store =
  [pack_alignment(int) pack_lsb_first(bool) pack_row_length(int)
   pack_skip_pixels(int) pack_skip_rows(int) pack_swap_bytes(bool)
   unpack_alignment(int) unpack_lsb_first(bool) unpack_row_length(int)
   unpack_skip_pixels(int) unpack_skip_rows(int) unpack_swap_bytes(bool)]
external pixel_store : pixel_store -> unit = "ml_glPixelStore"
type pixel_transfer =
  [alpha_bias(float) alpha_scale(float) blue_bias(float) blue_scale(float)
   depth_bias(float) depth_scale(float) green_bias(float) green_scale(float)
   index_offset(int) index_shift(int) map_color(bool) map_stencil(bool)
   red_bias(float) red_scale(float)]
external pixel_transfer : pixel_transfer -> unit = "ml_glPixelTransfer"
external pixel_zoom : x:float -> y:float -> unit = "ml_glPixelZoom"
external point_size : float -> unit = "ml_glPointSize"
external polygon_mode : face:face -> mode:[fill line point] -> unit
  = "ml_glPolygonMode"
external polygon_stipple : mask:string -> unit = "ml_glPolygonStipple"
external pop_attrib : unit -> unit = "ml_glPopAttrib"
external pop_matrix : unit -> unit = "ml_glPopMatrix"
external pop_name : unit -> unit = "ml_glPopName"
type attrib_bit =
  [accum_buffer color_buffer current depth_buffer enable eval fog hint
   lighting line list pixel_mode point polygon polygon_stipple scissor
   stencil_buffer texture transform viewport]
external push_attrib : attrib_bit list -> unit = "ml_glPushAttrib"
external push_matrix : unit -> unit = "ml_glPushMatrix"
external push_name : int -> unit = "ml_glPushName"

external raster_pos : x:float -> y:float -> ?z:float -> ?w:float -> unit
  = "ml_glRasterPos"
type read_buffer =
  [aux(int) back back_left back_right front front_left front_right left
   right]
external read_buffer : read_buffer -> unit = "ml_glReadBuffer"
external read_pixels :
  x:int ->
  y:int ->
  width:int ->
  height:int -> format:pixels_format -> type:#gltype -> #gltype rawdata
  = "ml_glReadPixels_bc" "ml_glReadPixels"
external rect : point2 -> point2 -> unit = "ml_glRect"
val rotate : angle:float -> ?x:float -> ?y:float -> ?z:float -> unit

val scale : ?x:float -> ?y:float -> ?z:float -> unit
external shade_model : [flat smooth] -> unit = "ml_glShadeModel"

val translate : ?x:float -> ?y:float -> ?z:float -> unit

external vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
  = "ml_glVertex"
val vertex2 : point2 -> unit
val vertex3 : point3 -> unit
val vertex4 : point4 -> unit
external viewport : x:int -> y:int -> w:int -> h:int -> unit
  = "ml_glViewport"

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
