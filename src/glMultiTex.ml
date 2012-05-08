open Gl

type texture = 
  [ `texture0 | `texture1 | `texture2 | `texture3
  | `texture4 | `texture5 | `texture6 | `texture7
  | `texture8 | `texture9 | `texture10 | `texture11
  | `texture12 | `texture13 | `texture14 | `texture15
  | `texture16 | `texture17 | `texture18 | `texture19
  | `texture20 | `texture21 | `texture22 | `texture23
  | `texture24 | `texture25 | `texture26 | `texture27
  | `texture28 | `texture29 | `texture30 | `texture31 ]

let enum_of_texture = function
  | `texture0   -> Api.texture0
  | `texture1   -> Api.texture1
  | `texture2   -> Api.texture2
  | `texture3   -> Api.texture3
  | `texture4   -> Api.texture4
  | `texture5   -> Api.texture5
  | `texture6   -> Api.texture6
  | `texture7   -> Api.texture7
  | `texture8   -> Api.texture8
  | `texture9   -> Api.texture9
  | `texture10  -> Api.texture10
  | `texture11  -> Api.texture11
  | `texture12  -> Api.texture12
  | `texture13  -> Api.texture13
  | `texture14  -> Api.texture14
  | `texture15  -> Api.texture15
  | `texture16  -> Api.texture16
  | `texture17  -> Api.texture17
  | `texture18  -> Api.texture18
  | `texture19  -> Api.texture19
  | `texture20  -> Api.texture20
  | `texture21  -> Api.texture21
  | `texture22  -> Api.texture22
  | `texture23  -> Api.texture23
  | `texture24  -> Api.texture24
  | `texture25  -> Api.texture25
  | `texture26  -> Api.texture26
  | `texture27  -> Api.texture27
  | `texture28  -> Api.texture28
  | `texture29  -> Api.texture29
  | `texture30  -> Api.texture30
  | `texture31  -> Api.texture31

let e_of_t = enum_of_texture

let active tex = Api.activeTexture (e_of_t tex)

let client_active tex = Api.clientActiveTexture (e_of_t tex)

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

external env : env_param -> unit = "ml_glTexEnv" "noalloc"

let coord1d tex f = Api.multiTexCoord1d (e_of_t tex) f
let coord2d tex (f1,f2) = Api.multiTexCoord2d (e_of_t tex) f1 f2
let coord3d tex (f1,f2,f3) = Api.multiTexCoord3d (e_of_t tex) f1 f2 f3
let coord4d tex (f1,f2,f3,f4) = Api.multiTexCoord4d (e_of_t tex) f1 f2 f3 f4

let coord1f tex f = Api.multiTexCoord1f (e_of_t tex) f
let coord2f tex (f1,f2) = Api.multiTexCoord2f (e_of_t tex) f1 f2
let coord3f tex (f1,f2,f3) = Api.multiTexCoord3f (e_of_t tex) f1 f2 f3
let coord4f tex (f1,f2,f3,f4) = Api.multiTexCoord4f (e_of_t tex) f1 f2 f3 f4

let coord1i tex f = Api.multiTexCoord1i (e_of_t tex) f
let coord2i tex (f1,f2) = Api.multiTexCoord2i (e_of_t tex) f1 f2
let coord3i tex (f1,f2,f3) = Api.multiTexCoord3i (e_of_t tex) f1 f2 f3
let coord4i tex (f1,f2,f3,f4) = Api.multiTexCoord4i (e_of_t tex) f1 f2 f3 f4

(* GlTex naming scheme *)

let coord1 = coord1d
let coord2 = coord2d
let coord3 = coord3d
let coord4 = coord4d

let default x = function Some x -> x | None -> x

let coord tex ~s ?t ?r ?q () =
  let tex = (e_of_t tex) in
  match q with
    | Some q -> Api.multiTexCoord4d tex s (default 0.0 t) (default 0.0 r) q
    | None   -> match r with
	| Some r -> Api.multiTexCoord3d tex s (default 0.0 t) r
	| None   -> match t with
	    | Some t -> Api.multiTexCoord2d tex s t
	    | None   -> Api.multiTexCoord1d tex s


(* state queries *)

external max_texture_units : unit -> int  = "ml_max_texture_units" "noalloc"

external mode_combine : unit -> unit = "ml_mode_combine" "noalloc"
external combine_rgb_replace : unit -> unit = "ml_combine_rgb_replace" "noalloc"
external combine_rgb_add : unit -> unit = "ml_combine_rgb_add" "noalloc"

