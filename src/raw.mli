(* $Id: raw.mli,v 1.1 1998-01-20 11:36:10 garrigue Exp $ *)

type 'a t

type kind = [bitmap byte double float int long short ubyte uint ulong ushort]
type fkind = [double float]
type ikind = [bitmap byte int long short ubyte uint ulong ushort]
type lkind = [int long uint ulong]

val kind : 'a t -> 'a
val byte_size : 'a t -> int
val static : 'a t -> bool
val cast : 'a t -> to:'b -> 'b t

external sizeof : #kind -> int = "ml_raw_sizeof"
val length : #kind t -> int

external get : #ikind t -> pos:int -> int = "ml_raw_get"
external set : #ikind t -> pos:int -> to:int -> unit = "ml_raw_set"

external get_float : #fkind t -> pos:int -> float = "ml_raw_get_float"
external set_float : #fkind t -> pos:int -> to:float -> unit
  = "ml_raw_set_float"

external get_hi : #lkind t -> pos:int -> int = "ml_raw_get_hi"
external set_hi : #lkind t -> pos:int -> to:int -> unit = "ml_raw_set_hi"

external get_lo : #lkind t -> pos:int -> int = "ml_raw_get_lo"
external set_lo : #lkind t -> pos:int -> to:int -> unit = "ml_raw_set_lo"

external read : #ikind t -> pos:int -> len:int -> int array = "ml_raw_read"
external read_string : 'a t -> pos:int -> len:int -> string
  = "ml_raw_read_string"
external read_float : #fkind t -> pos:int -> len:int -> float array
  = "ml_raw_read_float"

external write : #ikind t -> pos:int -> src:int array -> unit
  = "ml_raw_write"
external write_string : 'a t -> pos:int -> src:string -> unit
  = "ml_raw_write_string"
external write_float : #fkind t -> pos:int -> src:float array -> unit
  = "ml_raw_write_float"

external create : (#kind as 'a) -> len:int -> 'a t = "ml_raw_alloc"
external create_static : (#kind as 'a) -> len:int -> 'a t
    = "ml_raw_alloc_static"
external free_static : 'a t -> unit = "ml_raw_free_static"
