(* $Id: glList.mli,v 1.2 1998-01-30 10:18:45 garrigue Exp $ *)

type t

val create : [compile compile_and_execute] -> t
    (* [create mode] creates a new display list in given mode.
       It is equivalent to
       [let base = gen_lists len:1 in begins (nth base pos:0)] *)
val ends : unit -> unit
    (* glEndList: end a display list started by create or begins *)
val call : t -> unit
val delete : t -> unit

type base

val nth : base -> pos:int -> t
    (* [nth base :pos] returns the index of the list at base+pos *)
val is_list : t -> bool
    (* [is_list l] is true if l indexes a display list *)
val gen_lists : len:int -> base
    (* Generate len new display lists. They are indexed by
       [nth base pos:0] to [nth base pos:(len-1)] *)
val begins : t -> mode:[compile compile_and_execute] -> unit
    (* glNewList: start the definition of a display list in given mode *)
val delete_lists : base -> len:int -> unit
    (* Delete len lists starting at base *)
val call_lists : [byte(string) int(int array)] -> ?base:base -> unit
    (* Call the lists whose indexes are given either by a string
       (code of each character) or an array.
       If the base is omited, the base given in a previous call is assumed *)
