(* $Id: gluTess.mli,v 1.8 2004-07-13 09:44:03 garrigue Exp $ *)
(* Code contributed by Jon Harrop *)

type winding_rule = [`odd|`nonzero|`positive|`negative|`abs_geq_two]

type vertices = (float * float * float) list

val tesselate :
  ?winding:winding_rule -> ?boundary_only:bool -> ?tolerance:float  ->
  vertices list -> unit
(** Render directly to current screen.
    Each [vertices] in the input is a contour in the single polygon
    represented by [vertices list]. *)

type triangles =
  { singles: vertices list; strips: vertices list; fans: vertices list }
    
val tesselate_and_return :
  ?winding:winding_rule -> ?tolerance:float -> vertices list -> triangles
(** Return 3 lists of triangles instead of rendering directly *)
