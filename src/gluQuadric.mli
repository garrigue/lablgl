(* $Id: gluQuadric.mli,v 1.2 1999-11-15 14:32:14 garrigue Exp $ *)

type t

val create : unit -> t

(* If you omit the quadric, a new one will be created *)

val cylinder :
  base:float -> top:float ->
  height:float -> slices:int -> stacks:int -> ?quad:t -> unit -> unit

val disk :
  inner:float -> outer:float ->
  slices:int -> loops:int -> ?quad:t -> unit -> unit

val partial_disk :
  inner:float ->
  outer:float ->
  slices:int ->
  loops:int -> start:float -> sweep:float -> ?quad:t -> unit -> unit

val sphere :
  radius:float -> slices:int -> stacks:int -> ?quad:t -> unit -> unit


val draw_style : t -> [`fill|`line|`point|`silhouette] -> unit
val normals : t -> [`flat|`none|`smooth] -> unit
val orientation : t -> [`inside|`outside] -> unit
val texture : t -> bool -> unit
