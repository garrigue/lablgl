
open Gl
open GlPix

type filter = [`convolution_1d | `convolution_2d | `separable_2d ]

type format =
  [`alpha|`blue|`green|`luminance|`luminance_alpha|`red|`rgb|`rgba]

external filter1d : target:[`convolution_1d] -> internal:[< internalformat ] -> width:int -> format:[< format ] -> [< real_kind ] Raw.t ->  unit = "ml_glConvolutionFilter1D" "noalloc"

external filter2d : target:[`convolution_2d] -> internal:[< internalformat ] -> width:int -> height:int -> format:[< format ] -> [< real_kind ] Raw.t -> unit = "ml_glConvolutionFilter2D"  "ml_glConvolutionFilter2Dbc" "noalloc"

external separable_filter2d : target:[`separable_2d] -> internal:[< internalformat ] -> width:int -> height:int -> format:[< format ] -> [< `real_kind ] Raw.t -> [< `real_kind ] Raw.t -> unit = "ml_glSeparableFilter2D" "ml_glSeparableFilter2Dbc" "noalloc"

external copy_filter1d : target:[`convolution_1d] -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> unit = "ml_glCopyConvolutionFilter1D" "noalloc"

external copy_filter2d : target:[`convolution_2d] -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> height:int -> unit = "ml_glCopyConvolutionFilter2D" "ml_glCopyConvolutionFilter2Dbc" "noalloc"

type parameter = 
  [`convolution_filter_scale of rgba 
  |`convolution_filter_bias of rgba ]

type pname =
  [`convolution_filter_scale
  |`convolution_filter_bias ]

external parameter : target:filter -> pname:pname -> params:rgba -> unit = "ml_glConvolutionParameterfv" "noalloc"

let parameter ~target ~param =
  match param with 
      `convolution_filter_scale params -> parameter ~target ~pname:`convolution_filter_scale ~params
    | `convolution_filter_bias params  -> parameter ~target ~pname:`convolution_filter_bias ~params
      
