(* $Id: gluNurbs.ml,v 1.2 1999-11-15 14:32:13 garrigue Exp $ *)

open Gl

type t

external begin_curve : t -> unit = "ml_gluBeginCurve"
external begin_surface : t -> unit = "ml_gluBeginSurface"
external begin_trim : t -> unit = "ml_gluBeginTrim"

external end_curve : t -> unit = "ml_gluEndCurve"
external end_surface : t -> unit = "ml_gluEndSurface"
external end_trim : t -> unit = "ml_gluEndTrim"

external load_sampling_matrices :
    t -> model:[`float] Raw.t ->
    persp:[`float] Raw.t -> view:[`int] Raw.t -> unit
    = "ml_gluLoadSamplingMatrices"

external create : unit -> t = "ml_gluNewNurbsRenderer"

external curve :
    t -> knots:[`float] Raw.t -> control:[`float] Raw.t ->
    order:int -> type:#GlMap.target -> unit
    = "ml_gluNurbsCurve"
let curve nurb :knots :control :order type:t =
  let arity = target_size t in
  if (Array.length knots - order) * arity <> Array.length control
  then invalid_arg "GluNurb.curve";
  let knots = Raw.of_float_array kind:`float knots
  and control = Raw.of_float_array kind:`float control in
  curve nurb :knots :control :order type:t

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
external property : t -> property -> unit
    = "ml_gluNurbsProperty"

external surface :
    t -> sknots:[`float] Raw.t -> tknots:[`float] Raw.t ->
    tstride:int -> control:[`float] Raw.t ->
    sorder:int -> torder:int -> target:#target -> unit
    = "ml_gluNurbsSurface_bc" "ml_gluNurbsSurface"
let surface t :sknots :tknots :control :sorder :torder :target =
  let cl = Array.length control in
  if cl = 0 then invalid_arg "GluNurb.curve";
  let tstride = Array.length control.(0) in
  let sl = Array.length sknots and tl = Array.length tknots in
  if tl <> cl + torder or (sl - sorder) * target_size target <> tstride
  then invalid_arg "GluNurb.curve";
  let sknots = Raw.of_float_array kind:`float sknots in
  let tknots = Raw.of_float_array kind:`float tknots in
  let co = Raw.create `float len:(cl * tstride) in
  for i = 0 to cl - 1 do
    if Array.length control.(i) <> tstride then invalid_arg "GluNurb.curve";
    Raw.sets_float co pos:(i*tstride) control.(i)
  done;
  surface t :sknots :tknots :tstride control:co
    :sorder :torder :target

external pwl_curve :
    t -> count:int -> [`float] Raw.t -> type:[`trim_2|`trim_3] -> unit
    = "ml_gluPwlCurve"
let pwl_curve nurb type:t data =
  let len = Array.length data 
  and raw = Raw.of_float_array kind:`float data
  and stride = match t with `trim_2 -> 2 | `trim_3 -> 3 in
  if len mod stride <> 0 then invalid_arg "GluNurb.pwl_curve";
  pwl_curve nurb count:(len/stride) raw type:t
