(* $Id: gl.ml,v 1.2 1998-01-05 06:32:42 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

let _ = Callback.register_exception "glerror" (GLerror "")

(* Plenty of small C wrappers *)

external glClearColor : float -> float -> float -> float -> unit
    = "ml_glClearColor"

let gl_clear_color
    ?:red [< 0. >] ?:green [< 0. >] ?:blue [< 0. >] ?:alpha [< 0. >] =
  glClearColor red green blue alpha

type gl_buffer_bit = [color depth accum stencil]

external gl_clear : gl_buffer_bit list -> unit
    = "ml_glClear"

external gl_flush : unit -> unit = "ml_glFlush"
external gl_finish : unit -> unit = "ml_glFinish"

type point = float * float

external gl_rect : point -> point -> unit
    = "ml_glRect"
external gl_vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
    = "ml_glVertex"

type gl_begin_enum = [
    points
    lines
    polygon
    triangles
    quads
    line_strip
    line_loop
    triangle_strip
    triangle_fan
    quad_strip     
  ]

external gl_begin : gl_begin_enum -> unit
    = "ml_glBegin"
external gl_end : unit -> unit
    = "ml_glEnd"
  
external gl_point_size : float -> unit
    = "ml_glPointSize"
external gl_line_width : float -> unit
    = "ml_glLineWidth"
external gl_line_stipple : factor:int -> pattern:int -> unit
    = "ml_glLineStipple"

external gl_polygon_mode :
    face:[front back both] -> mode:[point line fill] -> unit
    = "ml_glPolygonMode"
external gl_front_face : mode:[cw ccw] -> unit
    = "ml_glFrontFace"
external gl_cull_face : mode:[front back both] -> unit
    = "ml_glCullFace"
external gl_polygon_stipple : mask:string -> unit
    = "ml_glPolygonStipple"

external gl_edge_flag : bool -> unit
    = "ml_glEdgeFlag"

external gl_normal : x:float -> y:float -> z:float -> unit
    = "ml_glNormal"

