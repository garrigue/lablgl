(* $Id: glPix.ml,v 1.4 1999-11-15 14:32:11 garrigue Exp $ *)

open Gl

type ('a,'b) t = { format: 'a ; width: int ; height:int ; raw: 'b Raw.t }

let create (k : #Gl.kind) :format :width :height =
  let size = format_size format * width * height in
  let len = match k with `bitmap -> (size-1)/8+1 | _ -> size in
  let raw = Raw.create k len:(width * height * format_size format) in
  { format = format; width = width; height = height; raw = raw }
  
let of_raw raw :format :width :height =
  let size = format_size format * width * height
  and len = Raw.length raw in
  let len = match Raw.kind raw with `bitmap -> len * 8 | _ -> len in
  if size > len then invalid_arg "GlPix.of_raw";
  { format = format; width = width; height = height; raw = raw }

let to_raw img = img.raw
let format img = img.format
let width img = img.width
let height img = img.height

let raw_pos img =
  let width =
    match Raw.kind img.raw with `bitmap -> (img.width-1)/8+1
    | _ -> img.width
  in
  let stride = format_size img.format in
  let line = stride * width in
  fun :x :y -> x * stride + y * line

external bitmap :
    width:int -> height:int -> orig:point2 -> move:point2 ->
    [`bitmap] Raw.t -> unit
    = "ml_glBitmap"
type bitmap = ([`color_index], [`bitmap]) t
let bitmap (img : bitmap) =
  bitmap width:img.width height:img.height img.raw

external copy :
    x:int -> y:int -> width:int -> height:int ->
    type:[`color|`depth|`stencil] -> unit
    = "ml_glCopyPixels"

external draw :
    width:int -> height:int -> format:#format -> #Gl.kind Raw.t -> unit
    = "ml_glDrawPixels"
let draw img =
  draw img.raw width:img.width height:img.height format:img.format

type map =
    [`i_to_i|`i_to_r|`i_to_g|`i_to_b|`i_to_a
    |`s_to_s|`r_to_r|`g_to_g|`b_to_b|`a_to_a]
external map : map -> float array -> unit
    = "ml_glPixelMapfv"

type store_param = [
    `pack_swap_bytes bool
  | `pack_lsb_first bool
  | `pack_row_length int
  | `pack_skip_pixels int
  | `pack_skip_rows int
  | `pack_alignment int
  | `unpack_swap_bytes bool
  | `unpack_lsb_first bool
  | `unpack_row_length int
  | `unpack_skip_pixels int
  | `unpack_skip_rows int
  | `unpack_alignment int
]
external store : store_param -> unit = "ml_glPixelStorei"

type transfer_param = [
    `map_color bool
  | `map_stencil bool
  | `index_shift int
  | `index_offset int
  | `red_scale float
  | `red_bias float
  | `green_scale float
  | `green_bias float
  | `blue_scale float
  | `blue_bias float
  | `alpha_scale float
  | `alpha_bias float
  | `depth_scale float
  | `depth_bias float
]
external transfer : transfer_param -> unit = "ml_glPixelTransfer"

external zoom : x:float -> y:float -> unit = "ml_glPixelZoom"

external raster_pos :
    x:float -> y:float -> ?z:float -> ?w:float -> unit -> unit
    = "ml_glRasterPos"

external read :
    x:int -> y:int -> width:int -> height:int ->
    format:#format -> #Gl.kind Raw.t -> unit
    = "ml_glReadPixels_bc" "ml_glReadPixels"
let read :x :y :width :height :format type:t =
  let raw = Raw.create t len:(width * height * format_size format) in
  read :x :y :width :height :format raw;
  { raw = raw; width = width; height = height; format = format }
