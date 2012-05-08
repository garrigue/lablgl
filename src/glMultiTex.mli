open Gl
open GlTex

type texture = 
  [ `texture0 | `texture1 | `texture2 | `texture3
  | `texture4 | `texture5 | `texture6 | `texture7
  | `texture8 | `texture9 | `texture10 | `texture11
  | `texture12 | `texture13 | `texture14 | `texture15
  | `texture16 | `texture17 | `texture18 | `texture19
  | `texture20 | `texture21 | `texture22 | `texture23
  | `texture24 | `texture25 | `texture26 | `texture27
  | `texture28 | `texture29 | `texture30 | `texture31 ]

val active : texture -> unit

val client_active : texture -> unit

type env_param = [
    `mode of [`modulate|`decal|`blend|`replace|`combine]
  | `combine_rgb of [`replace|`modulate|`add|`add_signed|`interpolate|`subtract|`dot3_rgb|`dot3_rgba]
  | `combine_alpha of [`replace|`modulate|`add |`add_signed |`interpolate |`subtract ]
  | `source0_rgb of [`texture|`constant|`primary_color|`previous]
  | `source1_rgb of [`texture|`constant|`primary_color|`previous]
  | `source2_rgb of [`texture|`constant|`primary_color|`previous]
  | `operand0_rgb of [`src_color|`one_minus_src_color|`src_alpha|`one_minus_src_alpha]
  | `operand1_rgb of [`src_color|`one_minus_src_color|`src_alpha|`one_minus_src_alpha]
  | `operand2_rgb of [`src_color|`one_minus_src_color|`src_alpha|`one_minus_src_alpha]
  | `source0_alpha of [`texture|`constant|`primary_color|`previous]
  | `source1_alpha of [`texture|`constant|`primary_color|`previous]
  | `source2_alpha of [`texture|`constant|`primary_color|`previous]
  | `operand0_alpha of [`src_alpha|`one_minus_src_alpha]
  | `operand1_alpha of [`src_alpha|`one_minus_src_alpha]
  | `operand2_alpha of [`src_alpha|`one_minus_src_alpha]
  | `color of rgba
]

val env : env_param -> unit

val coord1d : texture -> float -> unit
val coord2d : texture -> float * float -> unit
val coord3d : texture -> float * float * float -> unit
val coord4d : texture -> float * float * float * float -> unit

val coord1f : texture -> float -> unit
val coord2f : texture -> float * float -> unit
val coord3f : texture -> float * float * float -> unit
val coord4f : texture -> float * float * float * float -> unit

val coord1i : texture -> int -> unit
val coord2i : texture -> int * int -> unit
val coord3i : texture -> int * int * int -> unit
val coord4i : texture -> int * int * int * int -> unit

(* GlTex naming scheme *)

val coord1 : texture -> float -> unit
val coord2 : texture -> float * float -> unit
val coord3 : texture -> float * float * float -> unit
val coord4 : texture -> float * float * float * float -> unit

val coord : texture -> s:float -> ?t:float -> ?r:float -> ?q:float -> unit -> unit

(* state queries *)

val max_texture_units : unit -> int

val mode_combine : unit -> unit
val combine_rgb_replace : unit -> unit
val combine_rgb_add : unit -> unit
