type kind =
  [ `color | `edge_flag | `index | `normal | `texture_coord | `vertex ]
external edgeFlagPointer : [ `bitmap ] Raw.t -> unit = "ml_glEdgeFlagPointer"
external texCoordPointer :
  int -> [< `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glTexCoordPointer"
external colorPointer :
  int ->
  [< `byte | `double | `float | `int | `short | `ubyte | `uint | `ushort ]
  Raw.t -> unit = "ml_glColorPointer"
external indexPointer :
  int -> [< `double | `float | `int | `short | `ubyte ] Raw.t -> unit
  = "ml_glIndexPointer"
external normalPointer :
  [< `byte | `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glNormalPointer"
external vertexPointer :
  int -> [< `double | `float | `int | `short ] Raw.t -> unit
  = "ml_glVertexPointer"
external enableClientState : kind -> unit = "ml_glEnableClientState"
external disableClientState : kind -> unit = "ml_glDisableClientState"
external arrayElement : int -> unit = "ml_glArrayElement"
external drawArrays : GlDraw.shape -> first:int -> count:int -> unit
  = "ml_glDrawArrays"
external drawElements :
  GlDraw.shape -> count:int -> [< `ubyte | `uint | `ushort ] Raw.t -> unit
  = "ml_glDrawElements"
