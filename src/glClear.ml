(* $Id: glClear.ml,v 1.1 1998-01-29 11:45:42 garrigue Exp $ *)

open Gl

external accum : float -> float -> float -> float -> unit
    = "ml_glClearAccum"
let accum (r,g,b : rgb) ?:alpha [< 1. >] =
  accum r g b alpha

type buffer = [color depth accum stencil]
external clear : buffer list -> unit = "ml_glClear"

external color :
    red:float -> green:float -> blue:float -> alpha:float -> unit
    = "ml_glClearColor"
let color (red, green, blue : rgb) ?:alpha [< 1. >] =
  color :red :green :blue :alpha
external depth : clampf -> unit = "ml_glClearDepth"
external index : float -> unit = "ml_glClearIndex"
external stencil : int -> unit = "ml_glClearStencil"
