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

external active : [<texture] -> unit = "ml_glActiveTexture" "noalloc"

external client_active : [<texture] -> unit = "ml_glClientActiveTexture" "noalloc"

type mode_param = [`modulate|`decal|`blend|`replace|`combine|`add]
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

external coord1 : [<texture] -> float -> unit = "ml_glMultiTexCoord1d" "noalloc"
external coord2 : [<texture] -> float -> float -> unit = "ml_glMultiTexCoord2d" "noalloc"
external coord3 : [<texture] -> float -> float -> float -> unit = "ml_glMultiTexCoord3d" "noalloc"
external coord4 : [<texture] -> float -> float -> float -> float -> unit = "ml_glMultiTexCoord4d" "noalloc"

let coord tex ~s ?t ?r ?q () =
  let default x = function Some x -> x | None -> x in
  match q with
    | Some q -> coord4 tex s (default 0.0 t) (default 0.0 r) q
    | None   -> match r with
	| Some r -> coord3 tex s (default 0.0 t) r
	| None   -> match t with
	    | Some t -> coord2 tex s t
	    | None   -> coord1 tex s


let coord2 tex (s,t) = coord2 tex s t
let coord3 tex (s,t,r) = coord3 tex s t r
let coord4 tex (s,t,r,q) = coord4 tex s t r q
 
