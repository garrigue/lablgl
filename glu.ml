(* $Id: glu.ml,v 1.4 1998-01-22 10:32:53 garrigue Exp $ *)

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

type contour_type = [exterior interior unknown ccw cw]
external next_contour : tesselator -> type:contour_type -> unit
    = "ml_gluNextContour"

type curve_type =
    [vertex_3 vertex_4 index color_4 normal texture_coord_1 texture_coord_2
     texture_coord_3 texture_coord_4 trim_2 trim_3]
external nurbs_curve :
    nurbs -> [float] Raw.t -> [float] Raw.t -> int -> curve_type -> unit
    = "ml_gluNurbsCurve"
let nurbs_curve nurb :knots :control :order type:t =
  let kl = Array.length knots and cl = Array.length control in
  let arity =
    match t with
      `index|`normal|`texture_coord_1 -> 1
    | `texture_coord_2|`trim_2 -> 2
    | `vertex_3|`texture_coord_3|`trim_3 -> 3
    | `vertex_4|`color_4|`texture_coord_4 -> 4
  in if (kl - order) * arity <> cl then invalid_arg "Glu.nurbs_curve";
  let k = Raw.create `float len:kl in
  Raw.sets_float pos:0 k knots;
  let c = Raw.create `float len:cl in
  Raw.sets_float pos:0 c control;
  nurbs_curve nurb k c order t

type nurbs_property = [
      sampling_method ([path_length parametric_error domain_distance])
      sampling_tolerance (int)
      parametric_tolerance (float)
      u_step (int)
      v_step (int)
      display_mode ([fill polygon patch])
      culling (bool)
      auto_load_matrix (bool)
  ]
external nurbs_property : nurbs -> nurbs_property -> unit
    = "ml_gluNurbsProperty"

external nurbs_surface :
    nurbs -> sknots:[float] Raw.t -> tknots:[float] Raw.t ->
    tstride:int -> control:[float] Raw.t ->
    sorder:int -> torder:int -> type:Gl.map_target -> unit
    = "ml_gluNurbsSurface"
let nurbs_surface nurbs :sknots :tknots :control :sorder :torder type:t =
  let cl = Array.length control in
  if cl = 0 then invalid_arg "Glu.nurbs_curve";
  let tstride = Array.length control.(0) in
  let sl = Array.length sknots and tl = Array.length tknots in
  let arity =
    match t with
      `index|`normal|`texture_coord_1 -> 1
    | `texture_coord_2 -> 2
    | `vertex_3|`texture_coord_3 -> 3
    | `vertex_4|`color_4|`texture_coord_4 -> 4
  in
  if tl <> cl + torder or (sl - sorder) * arity <> tstride
  then invalid_arg "Glu.nurbs_curve";
  let sk = Raw.create `float len:sl in
  Raw.sets_float sk pos:0 sknots;
  let tk = Raw.create `float len:tl in
  Raw.sets_float tk pos:0 tknots;
  let co = Raw.create `float len:(cl * tstride) in
  for i = 0 to cl - 1 do
    if Array.length control.(i) <> tstride then invalid_arg "Glu.nurbs_curve";
    Raw.sets_float co pos:(i*tstride) control.(i)
  done;
  nurbs_surface nurbs sknots:sk tknots:tk :tstride control:co
    :sorder :torder type:t

external perspective :
    fovy:float -> aspect:float -> znear:float -> zfar:float -> unit
    = "ml_gluPerspective"

external ortho2d :
    left:float -> right:float -> bottom:float -> top:float -> unit
    = "ml_gluOrtho2D"

external sphere : quadric -> radius:float -> slices:int -> stacks:int -> unit
    = "ml_gluSphere"
