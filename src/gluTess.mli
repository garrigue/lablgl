(* $Id: gluTess.mli,v 1.6 2003-10-30 08:53:55 garrigue Exp $ *)

type t

val create : unit -> t

val begins : t -> unit
val ends : t -> unit

val vertex : t -> [`double] Raw.t -> unit

val next_contour : t -> kind:[`ccw|`cw|`exterior|`interior|`unknown] -> unit

(* The following functions are only available in GLU version 1.2 *)

val begin_contour : t -> unit
val end_contour : t -> unit

val begin_polygon :  t -> unit
val end_polygon : t -> unit

val normal : t -> Gl.vect3 -> unit

type property = [
  | `winding_rule of [`odd|`nonzero|`positive|`negative|`abs_geq_two]
  | `boundary_only of bool
  | `tolerance of float
]
val property : t -> property -> unit

