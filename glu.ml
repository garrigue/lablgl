(* $Id: glu.ml,v 1.3 1998-01-21 09:12:34 garrigue Exp $ *)

type nurbs
type tesselator
type quadric

external begin_curve : nurbs -> unit = "ml_gluBeginCurve"
external begin_polygon : tesselator -> unit = "ml_gluBeginPolygon"
external begin_surface : nurbs -> unit = "ml_gluBeginSurface"
external begin_trim : nurbs -> unit = "ml_gluBeginTrim"

external build_1d_mipmaps :
    internal:int ->
    width:int -> format:Gl.tex_format -> #Gl.gltype Raw.t -> unit
    = "ml_gluBuild1DMipmaps"

external build_2d_mipmaps :
    internal:int -> width:int ->
    height:int -> format:Gl.tex_format -> #Gl.gltype Raw.t -> unit
    = "ml_gluBuild1DMipmaps"

external cylinder :
    quadric -> base:float -> top:float -> height:float ->
    slices:int -> stacks:int -> unit
    = "ml_gluCylinder_bc" "ml_gluCylinder"

external disk :
    quadric -> inner:float -> outer:float -> slices:int -> loops:int -> unit
    = "ml_gluDisk"

external end_curve : nurbs -> unit = "ml_gluEndCurve"
external end_polygon : tesselator -> unit = "ml_gluEndPolygon"
external end_surface : nurbs -> unit = "ml_gluEndSurface"
external end_trim : nurbs -> unit = "ml_gluEndTrim"

external get_string : [version extensions] -> string = "ml_gluGetString"

external load_sampling_matrices :
    nurbs -> model:[float] Raw.t ->
    persp:[float] Raw.t -> view:[int] Raw.t -> unit
    = "ml_gluLoadSamplingMatrices"

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
