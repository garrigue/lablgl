(* $Id: raw.ml,v 1.3 1998-01-21 23:25:21 garrigue Exp $ *)

type addr
type kind =
    [bitmap byte ubyte short ushort int uint long ulong float double]
type fkind = [float double]
type ikind = [bitmap byte ubyte short ushort int uint long ulong]
type lkind = [int uint long ulong]
type 'a t =
    { kind: 'a; size: int; addr: addr; static: bool}

let kind raw = raw.kind
let byte_size raw = raw.size
let static raw = raw.static
let cast raw to:kind =
  {kind = kind; size = raw.size; addr = raw.addr; static = raw.static}

external sizeof : #kind -> int = "ml_raw_sizeof"
let length raw = raw.size / sizeof raw.kind

external get : #ikind t -> pos:int -> int = "ml_raw_get"
external set : #ikind t -> pos:int -> int -> unit = "ml_raw_set"
external get_float : #fkind t -> pos:int -> float = "ml_raw_get_float"
external set_float : #fkind t -> pos:int -> float -> unit
    = "ml_raw_set_float"
external get_hi : #lkind t -> pos:int -> int = "ml_raw_get_hi"
external set_hi : #lkind t -> pos:int -> int -> unit = "ml_raw_set_hi"
external get_lo : #lkind t -> pos:int -> int = "ml_raw_get_lo"
external set_lo : #lkind t -> pos:int -> int -> unit = "ml_raw_set_lo"

external gets : #ikind t -> pos:int -> len:int -> int array
    = "ml_raw_read"
external gets_string : 'a t -> pos:int -> len:int -> string
    = "ml_raw_read_string"
external gets_float : #fkind t -> pos:int -> len:int -> float array
    = "ml_raw_read_float"
external sets : #ikind t -> pos:int -> int array -> unit = "ml_raw_write"
external sets_string : 'a t -> pos:int -> string -> unit
    = "ml_raw_write_string"
external sets_float : #fkind t -> pos:int -> float array -> unit
    = "ml_raw_write_float"

(*
external fill : #ikind t -> pos:int -> len:int -> unit = "ml_raw_fill"
external fill_float : #fkind t -> pos:int -> len:int -> unit
    = "ml_raw_fill_float"
*)

external create : (#kind as 'a) -> len:int -> 'a t = "ml_raw_alloc"
external create_static : (#kind as 'a) -> len:int -> 'a t
    = "ml_raw_alloc_static"
external free_static : 'a t -> unit = "ml_raw_free_static"
