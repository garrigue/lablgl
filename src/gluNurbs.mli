(* $Id: gluNurbs.mli,v 1.5 2001-10-01 02:59:13 garrigue Exp $ *)

type t

val create : unit -> t

val begin_curve : t -> unit
val begin_surface : t -> unit
val begin_trim : t -> unit

val end_curve : t -> unit
val end_surface : t -> unit
val end_trim : t -> unit

val load_sampling_matrices :
  t ->
  model:[`float] Raw.t -> persp:[`float] Raw.t -> view:[`int] Raw.t -> unit

val curve :
  t -> knots:float array ->
  control:float array -> order:int -> kind:[< GlMap.target] -> unit

val pwl_curve : t -> kind:[`trim_2|`trim_3] -> float array -> unit

val surface :
  t ->
  sknots:float array ->
  tknots:float array ->
  control:float array array ->
  sorder:int -> torder:int -> target:[< Gl.target] -> unit

type property = [
    `sampling_method of [`path_length|`parametric_error|`domain_distance]
  | `sampling_tolerance of int
  | `parametric_tolerance of float
  | `u_step of int
  | `v_step of int
  | `display_mode of [`fill|`polygon|`patch]
  | `culling of bool
  | `auto_load_matrix of bool
]
val property : t -> property -> unit
