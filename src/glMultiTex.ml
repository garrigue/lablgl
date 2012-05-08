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

type mode_param = [`modulate|`decal|`blend|`replace|`combine]
type combine_rgb_param = [`replace|`modulate|`add|`add_signed|`interpolate|`subtract|`dot3_rgb|`dot3_rgba]
type combine_alpha_param = [`replace|`modulate|`add |`add_signed |`interpolate |`subtract ]

type source_param = [`texture|`constant|`primary_color|`previous]

type operand_rgb_param = [`src_color|`one_minus_src_color|`src_alpha|`one_minus_src_alpha]

type operand_alpha_param = [`src_alpha|`one_minus_src_alpha]


type env_target = [ `texture_env | `filter_control ]

type env_param = [
    `mode of mode_param
  | `combine_rgb of combine_rgb_param
  | `combine_alpha of combine_alpha_param
  | `source0_rgb of source_param
  | `source1_rgb of source_param
  | `source2_rgb of source_param
  | `operand0_rgb of operand_rgb_param
  | `operand1_rgb of operand_rgb_param
  | `operand2_rgb of operand_rgb_param
  | `source0_alpha of source_param
  | `source1_alpha of source_param
  | `source2_alpha of source_param
  | `operand0_alpha of operand_alpha_param
  | `operand1_alpha of operand_alpha_param
  | `operand2_alpha of operand_alpha_param
  | `color of rgba
]

type filter_param = [ `lod_bias of float ]

external env : [< env_target ] -> [< env_param | filter_param] -> unit = "ml_glTexEnv" "noalloc"

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

(*
external max_texture_units : unit -> int  = "ml_max_texture_units" "noalloc"
*)
