(* $Id: aux.ml,v 1.1 1998-01-05 06:32:41 garrigue Exp $ *)

external init_window : title:string -> unit = "ml_auxInitWindow"

external auxInitDisplayMode :
    [rgba index single double depth accum stencil] list -> unit
    = "ml_auxInitDisplayMode"

let init_display_mode :buffer ?:color [< `index >] ?:number [< `single >] =
  auxInitDisplayMode
    ((color : [index rgba]) :: (number : [single double])
     :: (buffer : [depth accum stencil] list))

external init_position : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_auxInitPosition"

external reshape_func : (w:int -> h:int -> unit) -> unit
     
