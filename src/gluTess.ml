(* $Id: gluTess.ml,v 1.6 2003-10-30 08:53:54 garrigue Exp $ *)

type t

external begins : t -> unit = "ml_gluBeginPolygon"
external ends : t -> unit = "ml_gluEndPolygon"

external create : unit -> t = "ml_gluNewTess"

external next_contour :
    t -> kind:[`exterior|`interior|`unknown|`ccw|`cw] -> unit
    = "ml_gluNextContour"

external begin_contour : t -> unit = "ml_gluTessBeginContour"
external end_contour : t -> unit = "ml_gluTessEndContour"

external begin_polygon : t -> data:int -> unit
    = "ml_gluTessBeginPolygon"
let begin_polygon = begin_polygon ~data:0
external end_polygon : t -> unit = "ml_gluTessEndPolygon"

external normal : t -> float -> float -> float -> unit
    = "ml_gluTessNormal"
let normal tess (x,y,z) = normal tess x y z
  
type property = [
  | `winding_rule of [`odd|`nonzero|`positive|`negative|`abs_geq_two]
  | `boundary_only of bool
  | `tolerance of float
]
external property : t -> property -> unit
    = "ml_gluTessProperty"

external vertex : t -> [`double] Raw.t -> data:int -> unit
    = "ml_gluTessVertex"
let vertex = vertex ~data:0
