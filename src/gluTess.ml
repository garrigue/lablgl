(* $Id: gluTess.ml,v 1.3 1999-11-15 14:32:14 garrigue Exp $ *)

type t

external begins : t -> unit = "ml_gluBeginPolygon"
external ends : t -> unit = "ml_gluEndPolygon"

external create : unit -> t = "ml_gluNewTess"

external next_contour :
    t -> type:[`exterior|`interior|`unknown|`ccw|`cw] -> unit
    = "ml_gluNextContour"

external begin_contour : t -> unit = "ml_gluTessBeginContour"
external end_contour : t -> unit = "ml_gluTessEndContour"

external begin_polygon : ?data:'a -> t -> unit
    = "ml_gluTessBeginPolygon"
external end_polygon : t -> unit = "ml_gluTessEndPolygon"

external normal : t -> float -> float -> float -> unit
    = "ml_gluTessNormal"
let normal tess (x,y,z) = normal tess x y z
  
type property = [
    `winding_rule [`odd|`nonzero|`positive|`negative|`abs_geq_two]
  | `boundary_only bool
  | `tolerance float
]
external property : t -> property -> unit
    = "ml_gluTessProperty"

external vertex : t -> ?data:'a -> [`double] Raw.t -> unit
    = "ml_gluTessVertex"
