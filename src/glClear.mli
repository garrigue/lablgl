(* $Id: glClear.mli,v 1.1 1998-01-29 11:45:43 garrigue Exp $ *)

type buffer = [accum color depth stencil]
val clear : buffer list -> unit
    (* Clear the specified buffers *)

val accum : Gl.rgb -> ?alpha:float -> unit
val color : Gl.rgb -> ?alpha:float -> unit
val depth : Gl.clampf -> unit
val index : float -> unit
val stencil : int -> unit
    (* Set the clear value for each buffer *)
