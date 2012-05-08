(* Raw OpenGL API *)

(* type of the OpenGL constants, ie uint *)
type enum = int
  
val  texture0            : enum
val  texture1            : enum
val  texture2            : enum
val  texture3            : enum
val  texture4            : enum
val  texture5            : enum
val  texture6            : enum
val  texture7            : enum
val  texture8            : enum
val  texture9            : enum
val  texture10           : enum
val  texture11           : enum
val  texture12           : enum
val  texture13           : enum
val  texture14           : enum
val  texture15           : enum
val  texture16           : enum
val  texture17           : enum
val  texture18           : enum
val  texture19           : enum
val  texture20           : enum
val  texture21           : enum
val  texture22           : enum
val  texture23           : enum
val  texture24           : enum
val  texture25           : enum
val  texture26           : enum
val  texture27           : enum
val  texture28           : enum
val  texture29           : enum
val  texture30           : enum
val  texture31           : enum

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
