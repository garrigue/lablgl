(* $Id: glPix.mli,v 1.1 1998-01-29 11:46:00 garrigue Exp $ *)

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

type bitmap = ([color_index], [bitmap]) t
val bitmap :
  bitmap -> orig:Gl.point2 -> move:Gl.point2 -> unit

val draw : (#Gl.format, #Gl.kind) t -> unit

type map =
  [a_to_a b_to_b g_to_g i_to_a i_to_b i_to_g i_to_i i_to_r r_to_r s_to_s]
val map : map -> float array -> unit

type store_param =
  [pack_alignment(int) pack_lsb_first(bool) pack_row_length(int)
   pack_skip_pixels(int) pack_skip_rows(int) pack_swap_bytes(bool)
   unpack_alignment(int) unpack_lsb_first(bool) unpack_row_length(int)
   unpack_skip_pixels(int) unpack_skip_rows(int) unpack_swap_bytes(bool)]
val store : store_param -> unit

type transfer_param =
  [alpha_bias(float) alpha_scale(float) blue_bias(float) blue_scale(float)
   depth_bias(float) depth_scale(float) green_bias(float) green_scale(float)
   index_offset(int) index_shift(int) map_color(bool) map_stencil(bool)
   red_bias(float) red_scale(float)]
val transfer : transfer_param -> unit

val zoom : x:float -> y:float -> unit
val raster_pos : x:float -> y:float -> ?z:float -> ?w:float -> unit

val copy :
  x:int ->
  y:int -> width:int -> height:int -> type:[color depth stencil] -> unit
