
open Gl
open Raw

type kind = [`edge_flag | `texture_coord | `color | `index | `normal | `vertex ]

external edgeFlagPointer : [< `bitmap] Raw.t -> unit = "ml_glEdgeFlagPointer"

external texCoordPointer
    : int -> [< `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glTexCoordPointer"

external colorPointer
    : int -> [< `byte | `ubyte | `short | `ushort | `int | `uint |
                `float | `double] Raw.t -> unit 
	= "ml_glColorPointer"

external indexPointer
    : int -> [< `ubyte | `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glIndexPointer"

external normalPointer
    : [< `byte | `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glNormalPointer"

external vertexPointer
    : int -> [< `short | `int | `float | `double] Raw.t -> unit 
	= "ml_glVertexPointer"

external enableClientState
    : kind -> unit
	= "ml_glEnableClientState"

external disableClientState
    : kind -> unit
	= "ml_glDisableClientState"

external arrayElement : int -> unit = "ml_glArrayElement"

external drawArrays : GlDraw.shape -> first:int -> count:int -> unit 
    = "ml_glDrawArrays"

external drawElements 
    :  GlDraw.shape -> count:int -> [< `ubyte | `ushort | `uint] Raw.t -> unit
	= "ml_glDrawElements"  
