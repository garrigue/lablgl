(* $Id: gluQuadric.mli,v 1.1 1998-01-29 11:46:13 garrigue Exp $ *)

type t

val create : unit -> t

(* If you omit the quadric, a new one will be created *)

val cylinder :
   base:float -> top:float ->
   height:float -> slices:int -> stacks:int -> ?quad:t -> unit

val disk :
  inner:float -> outer:float -> slices:int -> loops:int -> ?quad:t -> unit

val partial_disk :
  inner:float ->
  outer:float ->
  slices:int -> loops:int -> start:float -> sweep:float -> ?quad:t -> unit

val sphere : radius:float -> slices:int -> stacks:int -> ?quad:t -> unit


val draw_style : t -> [fill line point silhouette] -> unit
val normals : t -> [flat none smooth] -> unit
val orientation : t -> [inside outside] -> unit
val texture : t -> bool -> unit
