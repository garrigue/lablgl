type filter = [ `convolution_1d | `convolution_2d | `separable_2d ]

type format =
  [`alpha|`blue|`green|`luminance|`luminance_alpha|`red|`rgb | `bgr |`rgba | `bgra]

val filter :
  ?internal:Gl.internalformat -> ([< format ], [< Gl.real_kind ]) GlPix.t -> unit

val separable_filter2d :
  ?internal:Gl.internalformat ->
  ([<format] as 'a, [< Gl.real_kind ] as 'b) GlPix.t -> ('a, 'b) GlPix.t -> unit

val copy_filter1d :
  internal:[<Gl.internalformat] -> x:int -> y:int -> width:int -> unit

val copy_filter2d :
  internal:[<Gl.internalformat] ->
  x:int -> y:int -> width:int -> height:int -> unit


type border_mode = [ `reduce | `constant_border | `replicate_border ]

type parameter = 
  [ `filter_scale of Gl.rgba 
  | `filter_bias of Gl.rgba
  | `border_mode of border_mode ]

val parameter :
  target:[<filter] -> param:[<parameter] -> unit
