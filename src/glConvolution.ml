
open Gl
open GlPix

type filter = [`convolution_1d | `convolution_2d | `separable_2d ]

type format =
  [`alpha|`blue|`green|`luminance|`luminance_alpha|`red|`rgb|`rgba]

external filter1d : target:[`convolution_1d] -> internal:[< internalformat ] -> width:int -> format:[< format ] -> [< real_kind ] Raw.t ->  unit = "ml_glConvolutionFilter1D" "noalloc"

external filter2d : target:[`convolution_2d] -> internal:[< internalformat ] -> width:int -> height:int -> format:[< format ] -> [< real_kind ] Raw.t -> unit = "ml_glConvolutionFilter2D_bc"  "ml_glConvolutionFilter2D" "noalloc"

external separable_filter2d : target:[`separable_2d] -> internal:[< internalformat ] -> width:int -> height:int -> format:[< format ] -> [< real_kind ] Raw.t -> [< real_kind ] Raw.t -> unit = "ml_glSeparableFilter2D_bc" "ml_glSeparableFilter2D" "noalloc"

let filter1d ~internal ~width ~format r =
  filter1d ~target:`convolution_1d ~internal ~width ~format r

let filter2d ~internal ~width ~height ~format r =
    filter2d ~target:`convolution_2d ~internal ~width ~height ~format r

let separable_filter2d  ~internal ~width ~height ~format r =
  separable_filter2d ~target:`separable_2d ~internal ~width ~height ~format r

external copy_filter1d : target:[`convolution_1d] -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> unit = "ml_glCopyConvolutionFilter1D" "noalloc"

let copy_filter1d ~internal ~x ~y ~width = 
  copy_filter1d ~target:`convolution_1d ~internal ~x ~y ~width

external copy_filter2d : target:[`convolution_2d] -> internal:[< internalformat ] -> x:int -> y:int -> width:int -> height:int -> unit = "ml_glCopyConvolutionFilter2D_bc" "ml_glCopyConvolutionFilter2D" "noalloc"

let copy_filter2d ~internal ~x ~y ~width ~height = 
  copy_filter2d ~target:`convolution_2d ~internal ~x ~y ~width ~height

type border_mode = [ `reduce | `constant_border | `replicate_border ]


type parameter = 
  [ `filter_scale of rgba 
  | `filter_bias of rgba
  | `border_mode of border_mode ]

external parameter_filter_scale : target:filter -> pvalue:rgba -> unit = "ml_glConvolutionParameterfv_CONVOLUTION_FILTER_SCALE" "noalloc"
external parameter_filter_bias : target:filter -> pvalue:rgba -> unit = "ml_glConvolutionParameterfv_CONVOLUTION_FILTER_BIAS" "noalloc"
external parameter_border_mode : target:filter -> pvalue:border_mode -> unit = "ml_glConvolutionParameteriv_CONVOLUTION_BORDER_MODE" "noalloc"

let parameter ~target ~param =
  match param with 
      `filter_scale pvalue -> parameter_filter_scale ~target ~pvalue
    | `filter_bias pvalue  -> parameter_filter_bias ~target ~pvalue
    | `border_mode pvalue  -> parameter_border_mode ~target ~pvalue
