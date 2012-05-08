(** Vertex array manipulation functions *)
(* $Id: glArray.mli,v 1.7 2008-10-25 02:22:58 garrigue Exp $ *)

(** The six different kinds for array *)
type kind =
  [ `color | `edge_flag | `index | `normal | `texture_coord | `vertex ]

(** Tell openGL the address of the edgeFlag array.
    Raw array must be static. *)
val edge_flag : [ `bitmap ] Raw.t -> unit

(** Tell openGL the address of the texCoor array
    Raw array must be static. *)
val tex_coord :
  [< `one | `two | `three | `four] -> 
  [< `double | `float | `int | `short ] Raw.t -> unit

(** Tell openGL the address of the color array
    Raw array must be static. *)
val color :
  [< `three | `four] ->
  [< `byte | `double | `float | `int | `short | `ubyte | `uint | `ushort ]
  Raw.t -> unit

(** Tell openGL the address of the index array
    Raw array must be static. *)
val index : [< `double | `float | `int | `short | `ubyte ] Raw.t -> unit

(** Tell openGL the address of the normal array
    Raw array must be static. *)
val normal : [< `byte | `double | `float | `int | `short ] Raw.t -> unit

(** Tell openGL the address of the vertex array
    Raw array must be static. *)
val vertex :
  [< `two | `three | `four] -> [< `double | `float | `int | `short ] Raw.t 
  -> unit

(** Tell openGL the address of to use the specified array
    Raw array must be static. *)
external enable : kind -> unit = "ml_glEnableClientState"

(** Tell openGL the address of not to use the specified array
    Raw array must be static. *)
external disable : kind -> unit = "ml_glDisableClientState"

(* GlArray.element i
   sends to openGL the element i of all enabled arrays *)
external element : int -> unit = "ml_glArrayElement"

(* GlArray.draw_arrays shape i c
   sends to openGL a GlDraw.begins shape and all the element from i to i+c-1 
   of all enabled arrays and finally do a GlDraw.ends () *)
external draw_arrays : GlDraw.shape -> first:int -> count:int -> unit
  = "ml_glDrawArrays"

(* GlArray.draw_elements shape c tbl
   sends to openGL a GlDraw.begins shape and all the element from tbl[0] to 
   tbl[c-1] of all enabled arrays and finally do a GlDraw.ends () *)
external draw_elements :
  GlDraw.shape -> count:int -> [< `ubyte | `uint | `ushort ] Raw.t -> unit
  = "ml_glDrawElements"

module Interleaved :
sig

  type kind =
    [ `v2f
    | `v3f
    | `c4ub_v2f
    | `c4ub_v3f
    | `c3f_v3f
    | `n3f_v3f
    | `c4f_n3f_v3f
    | `t2f_v3f
    | `t4f_v4f
    | `t2f_c4ub_v3f
    | `t2f_c3f_v3f
    | `t2f_n3f_v3f
    | `t2f_c4f_n3f_v3f
    | `t4f_c4f_n3f_v4f ]

  type ivec4 = (int * int * int * int)
  type ubvec4 = ivec4

  type record = 
    [ `v2f of Gl.point2
    | `v3f of Gl.point3
    | `c4ub_v2f of ubvec4 * Gl.point2
    | `c4ub_v3f of ubvec4 * Gl.point3
    | `c3f_v3f of Gl.point3 * Gl.point3
    | `n3f_v3f of Gl.point3 * Gl.point3
    | `c4f_n3f_v3f of Gl.point4 * Gl.point3 * Gl.point3
    | `t2f_v3f of Gl.point2 * Gl.point3
    | `t4f_v4f of Gl.point4 * Gl.point4
    | `t2f_c4ub_v3f of Gl.point2 * ubvec4 * Gl.point3
    | `t2f_c3f_v3f of Gl.point2 * Gl.point3 * Gl.point3
    | `t2f_n3f_v3f of Gl.point2 * Gl.point3 * Gl.point3
    | `t2f_c4f_n3f_v3f of Gl.point2 * Gl.point4 * Gl.point3 * Gl.point3
    | `t4f_c4f_n3f_v4f of Gl.point4 * Gl.point4 * Gl.point3 * Gl.point4 ]
      

  type 'a t constraint 'a = [< kind ]

  val make : 'a -> int -> 'a t

  (* float only based records *)
  type fkind =
    [ `v2f
    | `v3f
    | `c3f_v3f
    | `n3f_v3f
    | `c4f_n3f_v3f
    | `t2f_v3f
    | `t4f_v4f
    | `t2f_c3f_v3f
    | `t2f_n3f_v3f
    | `t2f_c4f_n3f_v3f
    | `t4f_c4f_n3f_v4f ]

  val of_float_array : ([< fkind ] as 'a) -> float array -> 'a t

  (* getters *)

  val get_v2f             : [`v2f] t -> int -> Gl.point2
  val get_v3f             : [`v3f] t -> int -> Gl.point3
  val get_c4ub_v2f        : [`c4ub_v2f] t -> int ->  ubvec4 * Gl.point2
  val get_c4ub_v3f        : [`c4ub_v3f] t -> int ->  ubvec4 * Gl.point3
  val get_c3f_v3f         : [`c3f_v3f] t -> int -> Gl.point3 * Gl.point3
  val get_n3f_v3f         : [`n3f_v3f] t -> int -> Gl.point3 * Gl.point3
  val get_c4f_n3f_v3f     : [`c4f_n3f_v3f] t -> int -> Gl.point4 * Gl.point3 * Gl.point3
  val get_t2f_v3f         : [`t2f_v3f] t -> int -> Gl.point2 * Gl.point3
  val get_t4f_v4f         : [`t4f_v4f] t -> int -> Gl.point4 * Gl.point4
  val get_t2f_c4ub_v3f    : [`t2f_c4ub_v3f] t -> int -> Gl.point2 * ubvec4 * Gl.point3
  val get_t2f_c3f_v3f     : [`t2f_c3f_v3f] t -> int -> Gl.point2 * Gl.point3 * Gl.point3
  val get_t2f_n3f_v3f     : [`t2f_n3f_v3f] t -> int -> Gl.point2 * Gl.point3 * Gl.point3
  val get_t2f_c4f_n3f_v3f : [`t2f_c4f_n3f_v3f] t -> int -> Gl.point2 * Gl.point4 * Gl.point3 * Gl.point3
  val get_t4f_c4f_n3f_v4f : [`t4f_c4f_n3f_v4f] t -> int -> Gl.point4 * Gl.point4 * Gl.point3 * Gl.point4

  val get : 'a t -> int -> record

  (* setters *)

  val set_v2f             : [`v2f] t -> int -> Gl.point2 -> unit
  val set_v3f             : [`v3f] t -> int -> Gl.point3 -> unit
  val set_c4ub_v2f        : [`c4ub_v2f] t -> int ->  ubvec4 * Gl.point2 -> unit
  val set_c4ub_v3f        : [`c4ub_v3f] t -> int ->  ubvec4 * Gl.point3 -> unit
  val set_c3f_v3f         : [`c3f_v3f] t -> int -> Gl.point3 * Gl.point3 -> unit
  val set_n3f_v3f         : [`n3f_v3f] t -> int -> Gl.point3 * Gl.point3 -> unit
  val set_c4f_n3f_v3f     : [`c4f_n3f_v3f] t -> int -> Gl.point4 * Gl.point3 * Gl.point3 -> unit
  val set_t2f_v3f         : [`t2f_v3f] t -> int -> Gl.point2 * Gl.point3 -> unit
  val set_t4f_v4f         : [`t4f_v4f] t -> int -> Gl.point4 * Gl.point4 -> unit
  val set_t2f_c4ub_v3f    : [`t2f_c4ub_v3f] t -> int -> Gl.point2 * ubvec4 * Gl.point3 -> unit
  val set_t2f_c3f_v3f     : [`t2f_c3f_v3f] t -> int -> Gl.point2 * Gl.point3 * Gl.point3 -> unit
  val set_t2f_n3f_v3f     : [`t2f_n3f_v3f] t -> int -> Gl.point2 * Gl.point3 * Gl.point3 -> unit
  val set_t2f_c4f_n3f_v3f : [`t2f_c4f_n3f_v3f] t -> int -> Gl.point2 * Gl.point4 * Gl.point3 * Gl.point3 -> unit
  val set_t4f_c4f_n3f_v4f : [`t4f_c4f_n3f_v4f] t -> int -> Gl.point4 * Gl.point4 * Gl.point3 * Gl.point4 -> unit

  val set : 'a t -> int -> record -> unit

end (* Interleaved *)


