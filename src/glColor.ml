open Gl
open GlPix

type table = 
  [ `color_table | `post_convolution | `post_color_matrix
  | `proxy_color_table | `proxy_post_convolution | `proxy_post_color_matrix ]

type table_format =
  [`alpha|`blue|`green|`luminance
  |`luminance_alpha|`red|`rgb|`rgba]

external table : target:table -> internal:[< internalformat ] -> width:int -> format:[< table_format ] ->  [< real_kind ] Raw.t -> unit = "ml_glColorTable"

let internal_of_format : [< format] -> internalformat = function
  | `red
  | `green
  | `blue            -> `intensity
  | `alpha           -> `alpha
  | `luminance       -> `luminance
  | `rgb             -> `rgb
  | `rgba            -> `rgba
  | `luminance_alpha -> `luminance_alpha

let table ~target ?internal:i ~format pix =
  let internal = match i with None -> internal_of_format (GlPix.format pix) | Some i -> i in
  table ~target ~internal ~width:((width pix) * (height pix)) ~format (GlPix.to_raw pix)

type parameter = [ `color_table_scale of rgba | `color_table_bias of rgba ]

type pname = [ `color_table_scale | `color_table_bias ]

external table_parameter : target:table -> parameter:parameter -> rgba -> unit = "ml_glColorTableParameterfv"

external copy : target:table -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> unit = "ml_glCopyColorTable" "noalloc"

(*
let copy ~target ?internal:i ~x ~y ~format =
  let internal = match i with None -> getFrameBufferFormat () | Some i -> i in
  copy ~target ~internal ~x ~y ~format
*)

external sub_table : target:table -> start:int -> count:int -> format:[< table_format ] -> [< real_kind ] Raw.t -> unit = "ml_glColorSubTable" "noalloc"

external copy_sub : target:table -> start:int -> x:int -> y:int -> count:int -> unit = "ml_glCopyColorSubTable" "noalloc"

external histogram : target:[`histogram] -> width:int -> internal:internalformat -> bool -> unit = "ml_glHistogram" "noalloc"

let histogram ~width ~internal sink = histogram ~target:`histogram ~width ~internal sink

external minmax : target:[`minmax] -> internal:internalformat -> bool -> unit = "ml_glMinmax" "noalloc"

let minmax ~internal sink = minmax ~target:`minmax ~internal sink
