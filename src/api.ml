(* Raw OpenGL API *)

(* type of the OpenGL constants, ie uint *)
type enum = int

(* GL texture units *)

let texture0  : enum = 0x84c0
let texture1  : enum = 0x84c1
let texture2  : enum = 0x84c2
let texture3  : enum = 0x84c3
let texture4  : enum = 0x84c4
let texture5  : enum = 0x84c5
let texture6  : enum = 0x84c6
let texture7  : enum = 0x84c7
let texture8  : enum = 0x84c8
let texture9  : enum = 0x84c9
let texture10 : enum = 0x84ca
let texture11 : enum = 0x84cb
let texture12 : enum = 0x84cc
let texture13 : enum = 0x84cd
let texture14 : enum = 0x84ce
let texture15 : enum = 0x84cf
let texture16 : enum = 0x84d0
let texture17 : enum = 0x84d1
let texture18 : enum = 0x84d2
let texture19 : enum = 0x84d3
let texture20 : enum = 0x84d4
let texture21 : enum = 0x84d5
let texture22 : enum = 0x84d6
let texture23 : enum = 0x84d7
let texture24 : enum = 0x84d8
let texture25 : enum = 0x84d9
let texture26 : enum = 0x84da
let texture27 : enum = 0x84db
let texture28 : enum = 0x84dc
let texture29 : enum = 0x84dd
let texture30 : enum = 0x84de
let texture31 : enum = 0x84df

(* tex env sources and operands *)

(*
let source0_rgb : enum = 0x8580
let source1_rgb : enum = 0x8581
let source2_rgb : enum = 0x8582

let source0_alpha : enum = 0x8588
let source1_alpha : enum = 0x8589
let source2_alpha : enum = 0x858a

let operand0_rgb : enum = 0x8590
let operand1_rgb : enum = 0x8591
let operand2_rgb : enum = 0x8592

let operand0_alpha : enum = 0x8598
let operand1_alpha : enum = 0x8599
let operand2_alpha : enum = 0x859a
*)

external activeTexture : enum -> unit  = "ml_glActiveTexture" "noalloc"
external clientActiveTexture : enum -> unit = "ml_glClientActiveTexture" "noalloc"

external multiTexCoord1d : enum -> float -> unit = "ml_glMultiTexCoord1d" "noalloc"
external multiTexCoord1f : enum -> float -> unit = "ml_glMultiTexCoord1f" "noalloc"
external multiTexCoord1i : enum -> int -> unit = "ml_glMultiTexCoord1i" "noalloc"
external multiTexCoord1s : enum -> int -> unit = "ml_glMultiTexCoord1s" "noalloc"

external multiTexCoord2d : enum -> float -> float -> unit = "ml_glMultiTexCoord2d" "noalloc"
external multiTexCoord2f : enum -> float -> float -> unit = "ml_glMultiTexCoord2f" "noalloc"
external multiTexCoord2i : enum -> int -> int -> unit = "ml_glMultiTexCoord2i" "noalloc"
external multiTexCoord2s : enum -> int -> int -> unit = "ml_glMultiTexCoord2s" "noalloc"

external multiTexCoord3d : enum -> float -> float -> float -> unit = "ml_glMultiTexCoord3d" "noalloc"
external multiTexCoord3f : enum -> float -> float -> float -> unit = "ml_glMultiTexCoord3f" "noalloc"
external multiTexCoord3i : enum -> int -> int -> int -> unit = "ml_glMultiTexCoord3i" "noalloc"
external multiTexCoord3s : enum -> int -> int -> int -> unit = "ml_glMultiTexCoord3s" "noalloc"

external multiTexCoord4d : enum -> float -> float -> float -> float -> unit = "ml_glMultiTexCoord4d" "noalloc"
external multiTexCoord4f : enum -> float -> float -> float -> float -> unit = "ml_glMultiTexCoord4f" "noalloc"
external multiTexCoord4i : enum -> int -> int -> int -> int -> unit = "ml_glMultiTexCoord4i" "noalloc"
external multiTexCoord4s : enum -> int -> int -> int -> int -> unit = "ml_glMultiTexCoord4s" "noalloc"

external multiTexCoord1dv : enum -> float array -> unit = "ml_glMultiTexCoord1dv" "noalloc"
external multiTexCoord1fv : enum -> float array -> unit = "ml_glMultiTexCoord1fv" "noalloc"
external multiTexCoord1iv : enum -> int array -> unit = "ml_glMultiTexCoord1iv" "noalloc"
external multiTexCoord1sv : enum -> int array -> unit = "ml_glMultiTexCoord1sv" "noalloc"

external multiTexCoord2dv : enum -> float array -> unit = "ml_glMultiTexCoord2dv" "noalloc"
external multiTexCoord2fv : enum -> float array -> unit = "ml_glMultiTexCoord2fv" "noalloc"
external multiTexCoord2iv : enum -> int array -> unit = "ml_glMultiTexCoord2iv" "noalloc"
external multiTexCoord2sv : enum -> int array -> unit = "ml_glMultiTexCoord2sv" "noalloc"

external multiTexCoord3dv : enum -> float array -> unit = "ml_glMultiTexCoord3dv" "noalloc"
external multiTexCoord3fv : enum -> float array -> unit = "ml_glMultiTexCoord3fv" "noalloc"
external multiTexCoord3iv : enum -> int array -> unit = "ml_glMultiTexCoord3iv" "noalloc"
external multiTexCoord3sv : enum -> int array -> unit = "ml_glMultiTexCoord3sv" "noalloc"

external multiTexCoord4dv : enum -> float array -> unit = "ml_glMultiTexCoord4dv" "noalloc"
external multiTexCoord4fv : enum -> float array -> unit = "ml_glMultiTexCoord4fv" "noalloc"
external multiTexCoord4iv : enum -> int array -> unit = "ml_glMultiTexCoord4iv" "noalloc"
external multiTexCoord4sv : enum -> int array -> unit = "ml_glMultiTexCoord4sv" "noalloc"

