
open Gl
open Raw

type kind = [`edge_flag | `texture_coord | `color | `index | `normal | `vertex ]

external edge_flag : [< `bitmap] Raw.t -> unit = "ml_glEdgeFlagPointer"

external tex_coord
    : size:int -> [< `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glTexCoordPointer"

external color
    : size:int ->
      [< `byte | `ubyte | `short | `ushort | `int | `uint | `float | `double]
      Raw.t -> unit 
	= "ml_glColorPointer"

external index
    : [< `ubyte | `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glIndexPointer"

external normal
    : [< `byte | `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glNormalPointer"

external vertex
    : size:int -> [< `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glVertexPointer"

external enable
    : kind -> unit
	= "ml_glEnableClientState"

external disable
    : kind -> unit
	= "ml_glDisableClientState"

external element : int -> unit = "ml_glArrayElement"

external draw_arrays : GlDraw.shape -> first:int -> count:int -> unit 
    = "ml_glDrawArrays"

external draw_elements 
    :  GlDraw.shape -> count:int -> [< `ubyte | `ushort | `uint] Raw.t -> unit
	= "ml_glDrawElements"  
