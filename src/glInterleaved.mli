
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
    

type 'a t 
constraint 'a = [< kind ]

val kind : 'a t -> 'a

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

val of_raw : 'a -> 'b Raw.t -> 'a t

val arrays : 'a t -> unit
