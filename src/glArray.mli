
(* the six different kinds fo array *)
type kind =
  [ `color | `edge_flag | `index | `normal | `texture_coord | `vertex ]

(* Tell openGL the address of the edgeFlag array *)
external edgeFlagPointer : [ `bitmap ] Raw.t -> unit = "ml_glEdgeFlagPointer"

(* Tell openGL the address of the texCoor array *)
external texCoordPointer :
  size:int -> [< `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glTexCoordPointer"

(* Tell openGL the address of the color array *)
external colorPointer :
  size:int ->
  [< `byte | `double | `float | `int | `short | `ubyte | `uint | `ushort ]
  Raw.t -> unit = "ml_glColorPointer"

(* Tell openGL the address of the index array *)
external indexPointer :
  [< `double | `float | `int | `short | `ubyte ] Raw.t -> unit
  = "ml_glIndexPointer"

(* Tell openGL the address of the normal array *)
external normalPointer :
  [< `byte | `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glNormalPointer"


(* Tell openGL the address of the vertex array *)
external vertexPointer :
  size:int -> [< `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glVertexPointer"

(* Tell openGL the address of to use the specified array *)
external enableClientState : kind -> unit = "ml_glEnableClientState"

(* Tell openGL the address of not to use the specified array *)
external disableClientState : kind -> unit = "ml_glDisableClientState"

(* GlArray.arrayElement i
   sends to openGL the element i of all enabled arrays *)
external arrayElement : int -> unit = "ml_glArrayElement"

(* GlArray.drawArrays shape i c
   sends to openGL a GlDraw.begins shape and all the element from i to i+c-1 
   of all enabled arrays and finally do a GlDraw.ends () *)
external drawArrays : GlDraw.shape -> first:int -> count:int -> unit
  = "ml_glDrawArrays"

(* GlArray.drawArrays shape c tbl
   sends to openGL a GlDraw.begins shape and all the element from tbl[0] to 
   tbl[c-1] of all enabled arrays and finally do a GlDraw.ends () *)
external drawElements :
  GlDraw.shape -> count:int -> [< `ubyte | `uint | `ushort ] Raw.t -> unit
  = "ml_glDrawElements"
