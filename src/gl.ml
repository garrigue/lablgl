(* $Id: gl.ml,v 1.3 1998-01-06 10:22:52 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

let _ = Callback.register_exception "glerror" (GLerror "")

(* Plenty of small C wrappers *)

external glClearColor : float -> float -> float -> float -> unit
    = "ml_glClearColor"

let clear_color
    ?:red [< 0. >] ?:green [< 0. >] ?:blue [< 0. >] ?:alpha [< 0. >] =
  glClearColor red green blue alpha

type buffer_bit = [color depth accum stencil]

external clear : buffer_bit list -> unit
    = "ml_glClear"

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"

type point = float * float

external rect : point -> point -> unit
    = "ml_glRect"
external vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
    = "ml_glVertex"

type begin_enum = [
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

external begin_list : begin_enum -> unit
    = "ml_glBegin"
external end_list : unit -> unit
    = "ml_glEnd"
  
external point_size : float -> unit
    = "ml_glPointSize"
external line_width : float -> unit
    = "ml_glLineWidth"
external line_stipple : factor:int -> pattern:int -> unit
    = "ml_glLineStipple"

external polygon_mode :
    face:[front back both] -> mode:[point line fill] -> unit
    = "ml_glPolygonMode"
external front_face : mode:[cw ccw] -> unit
    = "ml_glFrontFace"
external cull_face : mode:[front back both] -> unit
    = "ml_glCullFace"
external polygon_stipple : mask:string -> unit
    = "ml_glPolygonStipple"

external edge_flag : bool -> unit
    = "ml_glEdgeFlag"

external normal : x:float -> y:float -> z:float -> unit
    = "ml_glNormal3d"

external matrix_mode : [modelview projection texture] -> unit
    = "ml_glMatrixMode"

external load_identity : unit -> unit
    = "ml_glLoadIdentity"

external _load_matrix : float array array -> unit
    = "ml_glLoadMatrix"
let load_matrix m =
  if Array.length m <> 4 then invalid_arg "Gl.load_matrix";
  Array.iter m fun:
    begin fun v ->
      if Array.length v <> 4 then invalid_arg "Gl.load_matrix"
    end;
  _load_matrix m

external _mult_matrix : float array array -> unit
    = "ml_glMultMatrix"
let mult_matrix m =
  if Array.length m <> 4 then invalid_arg "Gl.mult_matrix";
  Array.iter m fun:
    begin fun v ->
      if Array.length v <> 4 then invalid_arg "Gl.mult_matrix"
    end;
  _mult_matrix m

external translate : x:float -> y:float -> z:float -> unit
    = "ml_glTranslated"
external rotate : angle:float -> x:float -> y:float -> z:float -> unit
    = "ml_glRotated"
external scale : x:float -> y:float -> z:float -> unit
    = "ml_glScaled"

external look_at :
    eye:(float * float * float) ->
    center:(float * float * float) ->
    up:(float * float * float) -> unit
    = "ml_gluLookAt"

external frustum :
    left:float -> right:float -> bottom:float ->
    top:float -> near:float -> far:float -> unit
    = "ml_glFrustum"

external perspective :
    fovy:float -> aspect:float -> znear:float -> zfar:float -> unit
    = "ml_gluPerspective"

external ortho :
    left:float -> right:float -> bottom:float ->
    top:float -> near:float -> far:float -> unit
    = "ml_glOrtho"

external ortho2d :
    left:float -> right:float -> bottom:float -> top:float -> unit
    = "ml_gluOrtho2D"

external viewport : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_glViewport"

external depth_range : near:float -> far:float -> unit
    = "ml_glDepthRange"

external push_matrix : unit -> unit
    = "ml_glPushMatrix"
external pop_matrix : unit -> unit
    = "ml_glPopMatrix"

external _clip_plane : plane:int -> equation:float array -> unit
    = "ml_glClipPlane"
let clip_plane :plane :equation =
  if plane < 0 or plane > 5 or Array.length equation <> 4
  then invalid_arg "Gl.clip_plane";
  _clip_plane :plane :equation
