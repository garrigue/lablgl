type ('a, 'b) t 

val create :
  ([< `bitmap | `byte | `float | `int | `short | `ubyte | `uint | `ushort ]
   as 'a) ->
  format:([< Gl.format ] as 'b) ->
  width:int -> height:int -> depth:int -> ('b, 'a) t

val of_raw :
  ([< `bitmap | `byte | `float | `int | `short | `ubyte | `uint | `ushort ]
   as 'a)
  Raw.t ->
  format:([< Gl.format ] as 'b) ->
  width:int -> height:int -> depth:int -> ('b, 'a) t

val to_raw : ('a, 'b) t -> 'b Raw.t
val format : ('a, 'b) t -> 'a
val width : ('a, 'b) t -> int
val height : ('a, 'b) t -> int
val depth : ('a, 'b) t -> int

val raw_pos :
  ([< Gl.format ],
   [< `bitmap | `byte | `float | `int | `short | `ubyte | `uint | `ushort ])
  t -> x:int -> y:int -> z:int -> int

external raster_pos :
  x:float -> y:float -> ?z:float -> ?w:float -> unit -> unit
  = "ml_glRasterPos"

val slice :
  ([< Gl.format ] as 'a, [< Gl.kind ] as 'b) t -> int -> ('a, 'b) GlPix.t

val of_glpix : ('a, 'b) GlPix.t -> ('a, 'b) t
