open Gl
open GlPix

(* color_table ---- *)

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

let table ~target ?internal:i pix =
  let internal = match i with None -> internal_of_format (GlPix.format pix) | Some i -> i in
  table ~target ~internal ~width:((width pix) * (height pix)) ~format:(GlPix.format pix) (GlPix.to_raw pix)

type parameter = [ `table_scale of rgba | `table_bias of rgba ]

external table_parameter_scale : target:table -> rgba -> unit = "ml_glColorTableParameterfv_COLOR_TABLE_SCALE" "noalloc"

external table_parameter_bias : target:table -> rgba -> unit = "ml_glColorTableParameterfv_COLOR_TABLE_BIAS" "noalloc"

let table_parameter ~target ~param =
  match param with
    | `table_scale pvalue -> table_parameter_scale ~target pvalue
    | `table_bias pvalue  -> table_parameter_bias ~target pvalue


external copy : target:table -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> unit = "ml_glCopyColorTable" "noalloc"

external sub_table : target:table -> start:int -> count:int -> format:[< table_format ] -> [< real_kind ] Raw.t -> unit = "ml_glColorSubTable" "noalloc"

let sub_table ~target ~start ~count pix = 
  sub_table ~target ~start ~count ~format:(GlPix.format pix) (GlPix.to_raw pix)


external copy_sub : target:table -> start:int -> x:int -> y:int -> count:int -> unit = "ml_glCopyColorSubTable" "noalloc"

(* histogram ----- *)

type histogram = [`histogram | `proxy_histogram]

external histogram : target:histogram -> width:int -> internal:internalformat -> bool -> unit = "ml_glHistogram" "noalloc"

(* minmax -------- *)

external minmax : target:[`minmax] -> internal:internalformat -> bool -> unit = "ml_glMinmax" "noalloc"

external reset_minmax : target:[`minmax] -> unit = "ml_glResetMinmax" "noalloc"

let minmax ~internal sink = minmax ~target:`minmax ~internal sink

let reset_minmax () = reset_minmax `minmax

