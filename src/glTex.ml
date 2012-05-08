(* $Id: glTex.ml,v 1.14 2012-03-06 03:31:02 garrigue Exp $ *)

open Gl
open GlPix

external coord1 : float -> unit = "ml_glTexCoord1d"
external coord2 : float -> float -> unit = "ml_glTexCoord2d"
external coord3 : float -> float -> float -> unit = "ml_glTexCoord3d"
external coord4 : float -> float -> float -> float -> unit
    = "ml_glTexCoord4d"

let default x = function Some x -> x | None -> x
let coord ~s ?t ?r ?q () =
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

type env_target = [ `texture_env | `filter_control ]

type env_param =
  [ `mode of [`modulate|`decal|`blend|`replace|`add] 
  | `color of rgba ]

type filter_param = [ `lod_bias of float ]

external env : [< env_target ] -> [env_param | filter_param] -> unit = "ml_glTexEnv"

type coord = [`s|`t|`r|`q]

type gen_mode_param = [`object_linear|`eye_linear|`sphere_map|`reflection_map|`normal_map]
type gen_param = 
  [ `mode of gen_mode_param
  | `object_plane of point4
  | `eye_plane of point4 ]

external gen : coord:[<coord] -> [<gen_param] -> unit = "ml_glTexGen"

(* note : check_pow2 isn't necessary anymore starting with OpenGL v2.0 *)
let npot = ref None

let check_pow2 n =
  if !npot = None then
    npot := Some (GlMisc.check_extension "GL_ARB_texture_non_power_of_two");
  (!npot = Some true) || (n land (n - 1) = 0)


type format = 
  [ `color_index | `red | `green | `blue | `alpha | `rgb
  | `bgr | `rgba | `bgra | `luminance | `luminance_alpha ]

let internal_of_format : [<format] -> internalformat = function
    `color_index
  | `red
  | `green
  | `blue            -> `intensity
  | `alpha           -> `alpha
  | `luminance       -> `luminance
  | `rgb             -> `rgb
  | `bgr             -> `rgb
  | `rgba            -> `rgba
  | `bgra            -> `rgba
  | `luminance_alpha -> `luminance_alpha

type target_1d =
 [ `texture_1d
 | `proxy_texture_1d ]

type target_2d =
  [ `texture_2d
  | `texture_cube_map_positive_x
  | `texture_cube_map_negative_x
  | `texture_cube_map_positive_y
  | `texture_cube_map_negative_y
  | `texture_cube_map_positive_z
  | `texture_cube_map_negative_z
  | `proxy_texture_2d
  | `proxy_texture_cube_map ]

type target_3d =
  [ `texture_3d
  | `proxy_texture_3d ]

external image1d :
    proxy:bool -> level:int -> internal:[<internalformat] ->
    width:int -> border:int -> format:[<format] -> [< kind] Raw.t -> unit
    = "ml_glTexImage1D_bc""ml_glTexImage1D"

let image1d ?(proxy=false) ?(level=0) ?internal:i ?(border=false) img =
  let internal = match i with None -> internal_of_format (format img) | Some i -> i in
  let border = if border then 1 else 0 in
  if not (check_pow2 (width img - 2 * border)) then
    raise (GLerror "Gl.image1d : bad width");
  if height img < 1 then raise (GLerror "Gl.image1d : bad height");
  image1d ~proxy ~level ~internal ~width:(width img) ~border
    ~format:(format img) (to_raw img)

external image2d :
    target:[<target_2d] -> level:int -> internal:[<internalformat] -> width:int ->
    height:int -> border:int -> format:[<format] -> [< kind] Raw.t -> unit
    = "ml_glTexImage2D_bc""ml_glTexImage2D"
let image2d ?(target=`texture_2d) ?(level=0) ?internal:i ?(border=false) img =
  let internal = match i with None -> internal_of_format (format img) | Some i -> i in
  let border = if border then 1 else 0 in
  if not (check_pow2 (width img - 2 * border)) then
    raise (GLerror "Gl.image2d : bad width");
  if not (check_pow2 (height img - 2 * border)) then
    raise (GLerror "Gl.image2d : bad height");
  image2d ~target ~level ~internal ~border
    ~width:(width img) ~height:(height img) ~format:(format img) (to_raw img)

open GlPix3D

external image3d :
    proxy:bool -> level:int -> internal:[<internalformat] -> width:int ->
    height:int -> depth:int -> border:int -> format:[< format] -> [< kind] Raw.t -> unit
    = "ml_glTexImage3D_bc""ml_glTexImage3D" "noalloc"

let image3d ?(proxy=false) ?(level=0) ?internal:i ?(border=false) img =
  let internal = match i with None -> internal_of_format (format img) | Some i -> i in
  let border = if border then 1 else 0 in
  if not (check_pow2 (width img - 2 * border)) then
    raise (GLerror "Gl.image1d : bad width");
  if height img < 1 then raise (GLerror "Gl.image1d : bad height");
  image3d ~proxy ~level ~internal ~width:(width img) ~height:(width img) ~depth:(depth img) ~border
    ~format:(format img) (to_raw img)

type min_filter =
    [`nearest|`linear|`nearest_mipmap_nearest|`linear_mipmap_nearest
    |`nearest_mipmap_linear|`linear_mipmap_linear]

type mag_filter = [`nearest|`linear]

type wrap = [`clamp|`repeat|`clamp_to_edge|`clamp_to_border|`mirrored_repeat]

type depth_mode = [`luminance|`intensity|`alpha]
type compare_mode = [`lequal|`gequal]

type parameter =
  [ `min_filter of min_filter
  | `mag_filter of mag_filter
  | `wrap_s of wrap
  | `wrap_t of wrap
  | `wrap_r of wrap
  | `border_color of rgba
  | `priority of clampf
  | `generate_mipmap of bool
  | `min_lod of float
  | `max_lod of float
  | `base_level of int
  | `max_level of int 
  | `lod_bias of float
  | `depth_mode of depth_mode
  | `compare_mode of compare_mode] 

external parameter : target:[<`texture_1d|`texture_2d|`texture_cube_map] -> [<parameter] -> unit
    = "ml_glTexParameter"

type texture_id = nativeint
external _gen_textures : int -> [`uint] Raw.t -> unit = "ml_glGenTextures"
let gen_textures ~len =
  let raw = Raw.create `uint ~len in
  _gen_textures len raw;
  let arr = Array.create len Nativeint.zero in
  for i = 0 to len - 1 do
    arr.(i) <- Raw.get_long raw ~pos:i
  done;
  arr
let gen_texture () =  (gen_textures 1).(0)

external bind_texture : target:[<`texture_1d|`texture_2d|`texture_cube_map] -> texture_id -> unit
    = "ml_glBindTexture"
external delete_texture : texture_id -> unit = "ml_glDeleteTexture"
let delete_textures a = Array.iter (fun id -> delete_texture id) a
