(* $Id: glTex.ml,v 1.2 1999-11-15 09:55:10 garrigue Exp $ *)

open Gl
open GlPix

external coord1 : float -> unit = "ml_glTexCoord1d"
external coord2 : float -> float -> unit = "ml_glTexCoord2d"
external coord3 : float -> float -> float -> unit = "ml_glTexCoord3d"
external coord4 : float -> float -> float -> float -> unit
    = "ml_glTexCoord4d"
let default x = function Some x -> x | None -> x
let coord :s ?:t ?:r ?:q () =
  match q with
    Some q -> coord4 s (default 0.0 t) (default 0.0 r) q
  | None -> match r with
      Some r -> coord3 s (default 0.0 t) r
    | None -> match t with
	Some t -> coord2 s t
      |	None -> coord1 s
let coord2 (s,t) = coord2 s t
let coord3 (s,t,r) = coord3 s t r
let coord4 (s,t,r,q) = coord4 s t r q
type env_param = [`mode [`modulate|`decal|`blend|`replace] | `color rgba]
external env : env_param -> unit = "ml_glTexEnv"
type coord = [`s|`t|`r|`q]
type gen_param = [
    `mode [`object_linear|`eye_linear|`sphere_map]
  | `object_plane point4
  | `eye_plane point4
]
external gen : coord:coord -> gen_param -> unit = "ml_glTexGen"
type format =
    [`color_index|`red|`green|`blue|`alpha|`rgb|`rgba
    |`luminance|`luminance_alpha]
external image1d :
    proxy:bool -> level:int -> internal:int ->
    width:int -> border:bool -> format:#format -> #kind Raw.t -> unit
    = "ml_glTexImage1D_bc""ml_glTexImage1D"
let image1d ?:proxy{=false} ?:level{=0} ?internal:i ?:border{=false} img =
  let internal = match i with None -> format_size (format img) | Some i -> i in
  if width img mod 2 <> 0 then raise (GLerror "Gl.image1d : bad width");
  if height img < 1 then raise (GLerror "Gl.image1d : bad height");
  image1d :proxy :level :internal width:(width img) :border
    format:(format img) (to_raw img)
external image2d :
    proxy:bool -> level:int -> internal:int -> width:int ->
    height:int -> border:bool -> format:#format -> #kind Raw.t -> unit
    = "ml_glTexImage2D_bc""ml_glTexImage2D"
let image2d ?:proxy{=false} ?:level{=0} ?internal:i ?:border{=false} img =
  let internal = match i with None -> format_size (format img) | Some i -> i in
  if width img mod 2 <> 0 then raise (GLerror "Gl.image2d : bad width");
  if height img mod 2 <> 0 then raise (GLerror "Gl.image2d : bad height");
  image2d :proxy :level :internal :border
    width:(width img) height:(height img) format:(format img) (to_raw img)
type filter =
    [`nearest|`linear|`nearest_mipmap_nearest|`linear_mipmap_nearest
    |`nearest_mipmap_linear|`linear_mipmap_linear]
type wrap = [`clamp|`repeat]
type parameter = [
    `min_filter filter
  | `mag_filter [`nearest|`linear]
  | `wrap_s wrap
  | `wrap_t wrap
  | `border_color rgba
  | `priority clampf
] 
external parameter : target:[`texture_1d|`texture_2d] -> parameter -> unit
    = "ml_glTexParameter"
