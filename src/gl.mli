(* $Id: gl.mli,v 1.1 1997-12-26 02:50:28 garrigue Exp $ *)

val clear_color :
    ?red:float -> ?green:float -> ?blue:float -> ?alpha:float -> unit

val clear : buffers:[color depth accum stencil] list -> unit
