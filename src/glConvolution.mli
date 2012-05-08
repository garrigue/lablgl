type filter = [ `convolution_1d | `convolution_2d | `separable_2d ]

type format =
    [ `alpha | `blue | `green | `luminance | `luminance_alpha
    | `red | `rgb | `rgba ]

val filter1d :
  target:[ `convolution_1d ] ->
  internal:[< Gl.internalformat ] ->
  width:int -> format:[< format ] -> [< Gl.real_kind ] Raw.t -> unit


val filter2d :
  target:[ `convolution_2d ] ->
  internal:[< Gl.internalformat ] ->
  width:int ->
  height:int -> format:[< format ] -> [< Gl.real_kind ] Raw.t -> unit


val separable_filter2d :
  target:[ `separable_2d ] ->
  internal:[< Gl.internalformat ] ->
  width:int ->
  height:int ->
  format:[< format ] ->
  [< `real_kind ] Raw.t -> [< `real_kind ] Raw.t -> unit


val copy_filter1d :
  target:[ `convolution_1d ] ->
  internal:[< Gl.internalformat ] -> x:int -> y:int -> width:int -> unit


val copy_filter2d :
  target:[ `convolution_2d ] ->
  internal:[< Gl.internalformat ] ->
  x:int -> y:int -> width:int -> height:int -> unit

type parameter =
    [ `convolution_filter_bias of Gl.rgba
    | `convolution_filter_scale of Gl.rgba ]

val parameter :
  target:filter ->
  param:[< `convolution_filter_bias of Gl.rgba
         | `convolution_filter_scale of Gl.rgba ] ->
  unit
