(* $Id: raw.ml,v 1.1 1998-01-19 07:29:11 garrigue Exp $ *)

type addr
type rawtype =
    [bitmap byte ubyte short ushort int uint long ulong float double]
type 'a t =
    { kind: 'a; size: int; addr: addr}

let kind raw = raw.kind
let size raw = raw.size

external sizeof : rawtype -> int = "ml_raw_sizeof"

external unsafe_set_byte : 'a t -> pos:int -> to:int = "ml_raw_set_byte"
external unsafe_set_ubyte : 'a t -> pos:int -> to:int = "ml_raw_set_ubyte"
external unsafe_set_short : 'a t -> pos:int -> to:int = "ml_raw_set_short"
external unsafe_set_ushort : 'a t -> pos:int -> to:int = "ml_raw_set_ushort"
external unsafe_set_int : 'a t -> pos:int -> to:int = "ml_raw_set_int"
external unsafe_set_int_lo : 'a t -> pos:int -> to:int = "ml_raw_set_int_lo"
external unsafe_set_int_hi : 'a t -> pos:int -> to:int = "ml_raw_set_int_hi"
external unsafe_set_long : 'a t -> pos:int -> to:int = "ml_raw_set_long"
external unsafe_set_long_lo : 'a t -> pos:int -> to:int = "ml_raw_set_long_lo"
external unsafe_set_long_hi : 'a t -> pos:int -> to:int = "ml_raw_set_long_hi"
external unsafe_set_float : 'a t -> pos:int -> to:float = "ml_raw_set_float"
external unsafe_set_double : 'a t -> pos:int -> to:float = "ml_raw_set_double"

external unsafe_get_byte : 'a t -> pos:int -> to:int = "ml_raw_get_byte"
external unsafe_get_ubyte : 'a t -> pos:int -> to:int = "ml_raw_get_ubyte"
external unsafe_get_short : 'a t -> pos:int -> to:int = "ml_raw_get_short"
external unsafe_get_ushort : 'a t -> pos:int -> to:int = "ml_raw_get_ushort"
external unsafe_get_int : 'a t -> pos:int -> to:int = "ml_raw_get_int"
external unsafe_get_int_lo : 'a t -> pos:int -> to:int = "ml_raw_get_int_lo"
external unsafe_get_int_hi : 'a t -> pos:int -> to:int = "ml_raw_get_int_hi"
external unsafe_get_long : 'a t -> pos:int -> to:int = "ml_raw_get_long"
external unsafe_get_long_lo : 'a t -> pos:int -> to:int = "ml_raw_get_long_lo"
external unsafe_get_long_hi : 'a t -> pos:int -> to:int = "ml_raw_get_long_hi"
external unsafe_get_float : 'a t -> pos:int -> to:float = "ml_raw_get_float"
external unsafe_get_double : 'a t -> pos:int -> to:float = "ml_raw_get_double"

