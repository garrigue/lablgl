(* $Id: glu.ml,v 1.6 1998-01-23 13:30:18 garrigue Exp $ *)

open Gl

type nurbs
type tesselator
type quadric

external begin_curve : nurbs -> unit = "ml_gluBeginCurve"
external begin_polygon : tesselator -> unit = "ml_gluBeginPolygon"
external begin_surface : nurbs -> unit = "ml_gluBeginSurface"
external begin_trim : nurbs -> unit = "ml_gluBeginTrim"

external build_1d_mipmaps :
    internal:int ->
    width:int -> format:#tex_format -> #gltype Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_1d_mipmaps img ?:internal [< format_size img.format >] =
  if img.height < 1 then raise (GLerror "Glu.build_1d_mipmaps : bad height");
  build_1d_mipmaps :internal width:img.width format:img.format img.raw

external build_2d_mipmaps :
    internal:int -> width:int ->
    height:int -> format:#tex_format -> #gltype Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_2d_mipmaps img ?:internal [< format_size img.format >] =
  build_2d_mipmaps :internal
    width:img.width height:img.height format:img.format img.raw

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

external nurbs_curve :
    nurbs -> knots:[float] Raw.t -> control:[float] Raw.t ->
    order:int -> type:#curve_type -> unit
    = "ml_gluNurbsCurve"
let nurbs_curve nurb :knots :control :order type:t =
  let arity = target_size t in
  if (Array.length knots - order) * arity <> Array.length control
  then invalid_arg "Glu.nurbs_curve";
  let knots = Raw.of_float_array kind:`float knots
  and control = Raw.of_float_array kind:`float control in
  nurbs_curve nurb :knots :control :order type:t

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
    sorder:int -> torder:int -> type:map_target -> unit
    = "ml_gluNurbsSurface_bc" "ml_gluNurbsSurface"
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
  let sknots = Raw.of_float_array kind:`float sknots in
  let tknots = Raw.of_float_array kind:`float tknots in
  let co = Raw.create `float len:(cl * tstride) in
  for i = 0 to cl - 1 do
    if Array.length control.(i) <> tstride then invalid_arg "Glu.nurbs_curve";
    Raw.sets_float co pos:(i*tstride) control.(i)
  done;
  nurbs_surface nurbs :sknots :tknots :tstride control:co
    :sorder :torder type:t

external ortho2d :
    left:float -> right:float -> bottom:float -> top:float -> unit
    = "ml_gluOrtho2D"
let ortho2d x:(left,right) y:(bottom,top) =
  ortho2d :left :right :bottom :top

external partial_disk :
    quadric -> inner:float -> outer:float ->
    slices:int -> loops:int -> start:float -> sweep:float -> unit
    = "ml_gluPartialDisk_bc" "ml_gluPartialDisk"

external perspective :
    fovy:float -> aspect:float -> znear:float -> zfar:float -> unit
    = "ml_gluPerspective"
let perspective :fovy :aspect z:(znear,zfar) =
  perspective :fovy :aspect :znear :zfar

external pick_matrix :
    x:float -> y:float -> width:float -> height:float -> unit
    = "ml_gluPickMatrix"

external project : point3 -> point3 = "ml_gluProject"

external pwl_curve :
    nurbs -> count:int -> [float] Raw.t -> type:[trim_2 trim_3] -> unit
    = "ml_gluPwlCurve"
let pwl_curve nurb type:t data =
  let len = Array.length data 
  and raw = Raw.of_float_array kind:`float data
  and stride = match t with `trim_2 -> 2 | `trim_3 -> 3 in
  if len mod stride <> 0 then invalid_arg "Glu.pwl_curve";
  pwl_curve nurb count:(len/stride) raw type:t

external quadric_draw_style : quadric -> [fill line silhouette point] -> unit
    = "ml_gluQuadricDrawStyle"
external quadric_normals : quadric -> [none flat smooth] -> unit
    = "ml_gluQuadricNormals"
external quadric_orientation : quadric -> [inside outside] -> unit
    = "ml_gluQuadricOrientation"
external quadric_texture : quadric -> bool -> unit
    = "ml_gluQuadricTexture"

external scale_image :
    format:#pixels_format ->
    w:int -> h:int -> data:#gltype Raw.t ->
    w:int -> h:int -> data:#gltype Raw.t -> unit
    = "ml_gluScaleImage"
let scale_image img :width :height =
  let kind = Raw.kind img.raw
  and len = width * height * format_size img.format in
  let len = match kind with `bitmap -> (len - 7) / 8 + 1 | _ -> len in
  let raw = Raw.create kind :len in
  scale_image format:img.format w:img.width h:img.height data:img.raw
    w:width h:height data:raw;
  {format = img.format; width = width; height = height; raw = raw}

external sphere : quadric -> radius:float -> slices:int -> stacks:int -> unit
    = "ml_gluSphere"

external tess_begin_contour : tesselator -> unit = "ml_gluTessBeginContour"
external tess_end_contour : tesselator -> unit = "ml_gluTessEndContour"

external tess_begin_polygon : tesselator -> ?data:'a -> unit
    = "ml_gluTessBeginPolygon"
external tess_end_polygon : tesselator -> unit = "ml_gluTessEndPolygon"

(*
type 'a tess_callback = [
      tess_begin ([triangle_fan triangle_strip line_loop] -> unit)
      tess_edge_flag (bool -> unit)
      tess_vertex (unit -> unit)
      tess_end (unit -> unit)
      tess_combine (point3 * tess_error)]
external tess_callback : tessalator -> tess_callback -> unit
    = "ml_gluTessCallback"
let tess_callbacks = Array.create len:6 fill:

*)

external tess_normal : tesselator -> float -> float -> float -> unit
    = "ml_gluTessNormal"
let tess_normal tess (x,y,z) = tess_normal tess x y z
  
type tess_property = [
      windind_rule ([odd nonzero positive negative abs_geq_two])
      boundary_only (bool)
      tolerance (float)
  ]
external tess_property : tesselator -> tess_property -> unit
    = "ml_gluTessProperty"

external tess_vertex : tesselator -> [double] Raw.t -> ?data:'a -> unit
    = "ml_gluTessVertex"

external unproject : point3 -> point3 = "ml_gluUnProject"
