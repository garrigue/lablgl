(* $Id: glFunc.mli,v 1.1 1998-01-29 11:45:47 garrigue Exp $ *)

val accum : op:[accum add load mult return] -> float -> unit

val alpha_func : Gl.cmp_func -> ref:Gl.clampf -> unit

type sfactor =
  [constant_alpha_ext constant_color_ext dst_alpha dst_color one
   one_minus_constant_alpha_ext one_minus_constant_color_ext
   one_minus_dst_alpha one_minus_dst_color one_minus_src_alpha src_alpha
   src_alpha_saturate zero]
type dfactor =
  [constant_alpha_ext constant_color_ext dst_alpha one
   one_minus_constant_alpha_ext one_minus_constant_color_ext
   one_minus_dst_alpha one_minus_src_alpha one_minus_src_color src_alpha
   src_color zero]
val blend_func : src:sfactor -> dst:dfactor -> unit

val color_mask :
  ?red:bool -> ?green:bool -> ?blue:bool -> ?alpha:bool -> unit

val depth_func : Gl.cmp_func -> unit
val depth_mask : bool -> unit
val depth_range : near:float -> far:float -> unit

val index_mask : int -> unit

val stencil_func : Gl.cmp_func -> ref:int -> mask:int -> unit
val stencil_mask : int -> unit
type stencil_op = [decr incr invert keep replace zero]
val stencil_op :
  ?fail:stencil_op -> ?zfail:stencil_op -> ?zpass:stencil_op -> unit

type logic_op =
  [And Or and_inverted and_reverse clear copy copy_inverted equiv invert 
   nand noop nor or_inverted or_reverse set xor]
val logic_op : logic_op -> unit

type draw_buffer =
  [aux(int) back back_left back_right front front_and_back front_left
   front_right left none right]
val draw_buffer : draw_buffer -> unit

type read_buffer =
  [aux(int) back back_left back_right front front_left front_right left
   right]
val read_buffer : read_buffer -> unit
