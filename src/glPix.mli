(* $Id: glPix.mli,v 1.2 1999-11-15 09:55:10 garrigue Exp $ *)

(* An abstract type for pixmaps *)

type ('a, 'b) t

val create :
  (#Gl.kind as 'a) ->
  format:(#Gl.format as 'b) -> width:int -> height:int -> ('b, 'a) t

val of_raw :
  (#Gl.kind as 'a) Raw.t ->
  format:(#Gl.format as 'b) -> width:int -> height:int -> ('b, 'a) t
val to_raw : ('a, 'b) t -> 'b Raw.t
val format : ('a, 'b) t -> 'a
val width : ('a, 'b) t -> int
val height : ('a, 'b) t -> int
val raw_pos : (#Gl.format, #Gl.kind) t -> x:int -> y:int -> int
    (* [raw_pos image :x :y] partially evaluates on [image] *)

(* openGL functions *)

val read :
  x:int ->
  y:int ->
  width:int ->
  height:int ->
  format:(#Gl.format as 'a) -> type:(#Gl.kind as 'b) -> ('a, 'b) t

type bitmap = ([`color_index], [`bitmap]) t
val bitmap :
  bitmap -> orig:Gl.point2 -> move:Gl.point2 -> unit

val draw : (#Gl.format, #Gl.kind) t -> unit

type map =
  [`a_to_a|`b_to_b|`g_to_g|`i_to_a|`i_to_b
  |`i_to_g|`i_to_i|`i_to_r|`r_to_r|`s_to_s]
val map : map -> float array -> unit

type store_param = [
    `pack_swap_bytes bool
  | `pack_lsb_first bool
  | `pack_row_length int
  | `pack_skip_pixels int
  | `pack_skip_rows int
  | `pack_alignment int
  | `unpack_swap_bytes bool
  | `unpack_lsb_first bool
  | `unpack_row_length int
  | `unpack_skip_pixels int
  | `unpack_skip_rows int
  | `unpack_alignment int
]
val store : store_param -> unit

type transfer_param = [
    `map_color bool
  | `map_stencil bool
  | `index_shift int
  | `index_offset int
  | `red_scale float
  | `red_bias float
  | `green_scale float
  | `green_bias float
  | `blue_scale float
  | `blue_bias float
  | `alpha_scale float
  | `alpha_bias float
  | `depth_scale float
  | `depth_bias float
]
val transfer : transfer_param -> unit

val zoom : x:float -> y:float -> unit
val raster_pos : x:float -> y:float -> ?z:float -> ?w:float -> unit

val copy :
  x:int ->
  y:int -> width:int -> height:int -> type:[`color|`depth|`stencil] -> unit
