type filter = [ `convolution_1d | `convolution_2d | `separable_2d ]

type format =
    [ `alpha | `blue | `green | `luminance | `luminance_alpha
    | `red | `rgb | `rgba ]

val filter1d :
  internal:[< Gl.internalformat ] ->
  width:int -> format:[< format ] -> [< Gl.real_kind ] Raw.t -> unit


val filter2d :
  internal:[< Gl.internalformat ] ->
  width:int ->
  height:int -> format:[< format ] -> [< Gl.real_kind ] Raw.t -> unit


val separable_filter2d :
  internal:[< Gl.internalformat ] ->
  width:int ->
  height:int ->
  format:[< format ] ->
  [< Gl.real_kind ] Raw.t -> [< Gl.real_kind ] Raw.t -> unit


val copy_filter1d :
  internal:[< Gl.internalformat ] -> x:int -> y:int -> width:int -> unit

val copy_filter2d :
  internal:[< Gl.internalformat ] ->
  x:int -> y:int -> width:int -> height:int -> unit


type border_mode = [ `reduce | `constant_border | `replicate_border ]

type parameter = 
  [ `filter_scale of Gl.rgba 
  | `filter_bias of Gl.rgba
  | `border_mode of border_mode ]

val parameter :
  target:filter -> param:[<parameter] -> unit
