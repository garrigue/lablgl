(** support for 3D pixmaps *)

type ('a, 'b) t 
(** the buffer type *)

(** constructors *)

val create :
  ([< `bitmap | `byte | `float | `int | `short | `ubyte | `uint | `ushort ]
   as 'a) ->
  format:([< Gl.format ] as 'b) ->
  width:int -> height:int -> depth:int -> ('b, 'a) t
(** create a buffer of specified dimensions and format *)

val of_raw :
  ([< `bitmap | `byte | `float | `int | `short | `ubyte | `uint | `ushort ]
   as 'a)
  Raw.t ->
  format:([< Gl.format ] as 'b) ->
  width:int -> height:int -> depth:int -> ('b, 'a) t
(** create a buffer containing the given raw data *)

val to_raw : ('a, 'b) t -> 'b Raw.t
(** convert the given buffer into raw data *)

(** pixmap data accessors *) 

val format : ('a, 'b) t -> 'a
(** pixmap format *)

(** pixmap dimensions *)

val width : ('a, 'b) t -> int
val height : ('a, 'b) t -> int
val depth : ('a, 'b) t -> int

val raw_pos :
  ([< Gl.format ],
   [< Gl.kind ])
  t -> x:int -> y:int -> z:int -> int
(** returns the pixel value at the given position in the pixmap  *)

external raster_pos :
  x:float -> y:float -> ?z:float -> ?w:float -> unit -> unit
  = "ml_glRasterPos"
(** see the RasterPos function in section 2.12 of the 1.3 specs *)

val slice :
  ([< Gl.format ] as 'a, [< Gl.kind ] as 'b) t -> int -> ('a, 'b) GlPix.t
(** extract a slice of a 3D pixmap as a 2D pixmap *)

val of_glpix : ('a, 'b) GlPix.t -> ('a, 'b) t
(** create a 3D pixmap out of a 2D one.
    The new value will have the same dimensions, and a depth of 1.
    Note that both value will share the same underlying raw data
    and thus modifying one would also impact the other.
*)
