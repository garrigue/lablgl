(* $Id: gl.mli,v 1.2 1998-01-05 06:32:44 garrigue Exp $ *)

exception GLerror of string

val gl_clear_color :
  ?red:float -> ?green:float -> ?blue:float -> ?alpha:float -> unit

type gl_buffer_bit = [accum color depth stencil]
external gl_clear : gl_buffer_bit list -> unit = "ml_glClear"

external gl_flush : unit -> unit = "ml_glFlush"
external gl_finish : unit -> unit = "ml_glFinish"

type point = float * float
external gl_rect : point -> point -> unit = "ml_glRect"

external gl_vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
  = "ml_glVertex"

type gl_begin_enum =
  [line_loop line_strip lines points polygon quad_strip quads triangle_fan
   triangle_strip triangles]
external gl_begin : gl_begin_enum -> unit = "ml_glBegin"
external gl_end : unit -> unit = "ml_glEnd"

external gl_point_size : float -> unit = "ml_glPointSize"
external gl_line_width : float -> unit = "ml_glLineWidth"
external gl_line_stipple : factor:int -> pattern:int -> unit
  = "ml_glLineStipple"

external gl_polygon_mode :
  face:[back both front] -> mode:[fill line point] -> unit
  = "ml_glPolygonMode"
external gl_front_face : mode:[ccw cw] -> unit = "ml_glFrontFace"
external gl_cull_face : mode:[back both front] -> unit = "ml_glCullFace"

external gl_polygon_stipple : mask:string -> unit = "ml_glPolygonStipple"

external gl_edge_flag : bool -> unit = "ml_glEdgeFlag"
external gl_normal : x:float -> y:float -> z:float -> unit = "ml_glNormal"
