(* $Id: gluNurbs.mli,v 1.2 1999-11-15 14:32:13 garrigue Exp $ *)

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
  control:float array -> order:int -> type:#GlMap.target -> unit

val pwl_curve : t -> type:[`trim_2|`trim_3] -> float array -> unit

val surface :
  t ->
  sknots:float array ->
  tknots:float array ->
  control:float array array ->
  sorder:int -> torder:int -> target:#Gl.target -> unit

type property = [
    `sampling_method [`path_length|`parametric_error|`domain_distance]
  | `sampling_tolerance int
  | `parametric_tolerance float
  | `u_step int
  | `v_step int
  | `display_mode [`fill|`polygon|`patch]
  | `culling bool
  | `auto_load_matrix bool
]
val property : t -> property -> unit
