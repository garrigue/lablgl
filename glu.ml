(* $Id: glu.ml,v 1.2 1998-01-16 00:19:36 garrigue Exp $ *)

type nurbs
type tesselator
type quadric

external begin_curve : nurbs -> unit = "ml_gluBeginCurve"
external begin_polygon : tesselator -> unit = "ml_gluBeginPolygon"
external begin_surface : nurbs -> unit = "ml_gluBeginSurface"
external begin_trim : nurbs -> unit = "ml_gluBeginTrim"

external look_at :
    eye:(float * float * float) ->
    center:(float * float * float) ->
    up:(float * float * float) -> unit
    = "ml_gluLookAt"

external new_nurbs_renderer : unit -> nurbs = "ml_gluNewNurbsRenderer"
external new_quadric : unit -> quadric = "ml_gluNewQuadric"
external new_tess : unit -> tesselator = "ml_gluNewTess"

external perspective :
    fovy:float -> aspect:float -> znear:float -> zfar:float -> unit
    = "ml_gluPerspective"

external ortho2d :
    left:float -> right:float -> bottom:float -> top:float -> unit
    = "ml_gluOrtho2D"

external sphere : quadric -> radius:float -> slices:int -> stacks:int -> unit
    = "ml_gluSphere"

external cylinder :
    quadric -> base:float -> top:float -> height:float ->
    slices:int -> stacks:int -> unit
    = "ml_gluCylinder_bc" "ml_gluCylinder"

(*
type component = [
      alpha
      initensity_ext
      luminance
      luminance_alpha
      rgb
      rgba
  ]

type format = [
      color_index
      red
      green
      blue
      alpha
      rgb
      rgba
      luminance
      luminance_alpha
      abgr_ext
  ]

type data = [
      byte (string)
      short (int array)
      int (int array)
  ]

external build_2D_mipmaps :
      :component -> width:int -> height:int -> :format
*)
