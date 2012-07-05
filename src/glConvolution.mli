(** Support for the convolutions filters *)
(** see section 3.6 of the opengl 1.3 specs *)


(** type of filter *)
type filter = [ `convolution_1d | `convolution_2d | `separable_2d ]

(** data format type *)
type format =
  [`alpha|`blue|`green|`luminance|`luminance_alpha|`red|`rgb | `bgr |`rgba | `bgra]

(** filter creation function *)
val filter :
  ?internal:Gl.internalformat -> ([< format ], [< Gl.real_kind ]) GlPix.t -> unit
(**  see ConvolutionFilter\{1D,2D\} in the specs *)


(** separable filter creation function *)
val separable_filter2d :
  ?internal:Gl.internalformat ->
  ([<format] as 'a, [< Gl.real_kind ] as 'b) GlPix.t -> ('a, 'b) GlPix.t -> unit
(** see SeparableFilter2D in the specs *)


(** creation of a copy of a 1D filter *)
val copy_filter1d :
  internal:[<Gl.internalformat] -> x:int -> y:int -> width:int -> unit
(** see CopyConvolutionFilter1D *)


(** creation of a copy of a 2D filter *)
val copy_filter2d :
  internal:[<Gl.internalformat] ->
  x:int -> y:int -> width:int -> height:int -> unit
(** see CopyConvolutionFilter2D *)


type border_mode = [ `reduce | `constant_border | `replicate_border ]
(** border handling mode in filters *)

type parameter = 
  [ `filter_scale of Gl.rgba 
  | `filter_bias of Gl.rgba
  | `border_mode of border_mode ]
(** filter parameters *)


(** filter parameter tuning function *)
val parameter :
  target:[<filter] -> param:[<parameter] -> unit
(** see ConvolutionParameter\{if\}v  *)
