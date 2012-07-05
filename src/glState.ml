open Gl

type boolean_pname = 
  [ `current_raster_position_valid
  | `edge_flag
  | `light_model_local_viewer
  | `light_model_two_side
  | `sample_coverage_invert
  | `color_writemask
  | `depth_writemask
  | `unpack_swap_bytes
  | `unpack_lsb_first
  | `pack_swap_bytes
  | `pack_lsb_first
  | `map_color
  | `map_stencil
  | `rgba_mode
  | `index_mode
  | `doublebuffer
  | `stereo ]

external get_boolean : boolean_pname -> bool = "ml_glGetBoolean" "noalloc"

external get_clip_plane : int -> GlMisc.equation = "ml_glGetClipPlane"

let get_clip_plane plane =
  if plane < 0 or plane > 5 then invalid_arg "GlState.get_clip_plane";
  get_clip_plane plane

(* lights *)

type light_pname = [
    `ambient (* of rgba *)
  | `diffuse (* of rgba *)
  | `specular (* of rgba *)
  | `position (* of point4 *)
  | `spot_direction (* of point3 *)
  | `spot_exponent (* of float *)
  | `spot_cutoff (* of float *)
  | `constant_attenuation (* of float *)
  | `linear_attenuation (* of float *)
  | `quadratic_attenuation (* of float *)
]

external get_light_ambient : int -> rgba = "ml_glGetLightfv_AMBIENT"
external get_light_diffuse : int -> rgba = "ml_glGetLightfv_DIFFUSE"
external get_light_specular : int -> rgba = "ml_glGetLightfv_SPECULAR"
external get_light_position : int -> point4  = "ml_glGetLightfv_POSITION"
external get_light_spot_direction : int -> point3 = "ml_glGetLightfv_SPOT_DIRECTION"
external get_light_spot_exponent : int -> float = "ml_glGetLightfv_SPOT_EXPONENT"
external get_light_spot_cutoff : int -> float = "ml_glGetLightfv_SPOT_CUTOFF"
external get_light_constant_attenuation : int -> float = "ml_glGetLightfv_CONSTANT_ATTENUATION"
external get_light_linear_attenuation : int -> float = "ml_glGetLightfv_LINEAR_ATTENUATION"
external get_light_quadratic_attenuation : int -> float = "ml_glGetLightfv_QUADRATIC_ATTENUATION"

let get_light ~num ~value : GlLight.light_param =
  match value with
      `ambient                 -> `ambient (get_light_ambient num)
    | `diffuse                 -> `diffuse (get_light_diffuse num)
    | `specular                -> `specular (get_light_specular num)
    | `position                -> `position (get_light_position num)
    | `spot_direction          -> `spot_direction (get_light_spot_direction num)
    | `spot_exponent           -> `spot_exponent (get_light_spot_exponent num)
    | `spot_cutoff             -> `spot_cutoff (get_light_spot_cutoff num)
    | `constant_attenuation    -> `constant_attenuation (get_light_constant_attenuation num)
    | `linear_attenuation      -> `linear_attenuation (get_light_linear_attenuation num)
    | `quadratic_attenuation   -> `quadratic_attenuation (get_light_quadratic_attenuation num)
    
(* material *)

type material_pname =
    [ `ambient
    | `ambient_and_diffuse
    | `color_indexes
    | `diffuse 
    | `emission
    | `shininess
    | `specular]

external get_material_ambient : [`back|`front] -> rgba = "ml_glGetMaterialfv_AMBIENT"
external get_material_diffuse : [`back|`front] -> rgba = "ml_glGetMaterialfv_DIFFUSE"
external get_material_specular : [`back|`front] -> rgba = "ml_glGetMaterialfv_SPECULAR"
external get_material_emission : [`back|`front] -> rgba = "ml_glGetMaterialfv_EMISSION"
external get_material_shininess : [`back|`front] -> float = "ml_glGetMaterialfv_SHININESS"
external get_material_ambient_and_diffuse : [`back|`front] -> rgba = "ml_glGetMaterialfv_AMBIENT_AND_DIFFUSE"
external get_material_color_indexes : [`back|`front] -> (float * float * float) = "ml_glGetMaterialfv_COLOR_INDEXES"

let get_material ~(face:[`back|`front]) ~pname : GlLight.material_param =
  match pname with
    | `ambient             -> `ambient (get_material_ambient face)
    | `ambient_and_diffuse -> `ambient_and_diffuse (get_material_ambient_and_diffuse face)
    | `color_indexes       -> `color_indexes (get_material_color_indexes face)
    | `diffuse             -> `diffuse (get_material_diffuse face)
    | `emission            -> `emission (get_material_emission face)
    | `shininess           -> `shininess (get_material_shininess face)
    | `specular            -> `specular (get_material_specular face)

type env_pname =
  [ `color | `combine_alpha | `combine_rgb | `mode | `operand0_alpha
  | `operand0_rgb | `operand1_alpha | `operand1_rgb | `operand2_alpha
  | `operand2_rgb | `source0_alpha | `source0_rgb | `source1_alpha
  | `source1_rgb | `source2_alpha | `source2_rgb | `rgb_scale | `alpha_scale 
  | `lod_bias ]

type env_param = 
    [ GlTex.filter_param | GlMultiTex.env_param | `rgb_scale of rgb | `alpha_scale of rgb ]

external get_tex_env_mode : [`texture_env] -> GlMultiTex.mode_param = "ml_glGetTexEnviv_TEXTURE_ENV_MODE"
external get_tex_env_combine_rgb : [`texture_env] -> GlMultiTex.combine_rgb_param = "ml_glGetTexEnviv_COMBINE_RGB"
external get_tex_env_combine_alpha : [`texture_env] -> GlMultiTex.combine_alpha_param = "ml_glGetTexEnviv_COMBINE_ALPHA"
external get_tex_env_source0_rgb : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE0_RGB"
external get_tex_env_source1_rgb : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE1_RGB"
external get_tex_env_source2_rgb : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE2_RGB"
external get_tex_env_operand0_rgb : [`texture_env] -> GlMultiTex.operand_rgb_param = "ml_glGetTexEnviv_OPERAND0_RGB"
external get_tex_env_operand1_rgb : [`texture_env] -> GlMultiTex.operand_rgb_param = "ml_glGetTexEnviv_OPERAND1_RGB"
external get_tex_env_operand2_rgb : [`texture_env] -> GlMultiTex.operand_rgb_param = "ml_glGetTexEnviv_OPERAND2_RGB"
external get_tex_env_source0_alpha : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE0_ALPHA"
external get_tex_env_source1_alpha : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE1_ALPHA"
external get_tex_env_source2_alpha : [`texture_env] -> GlMultiTex.source_param = "ml_glGetTexEnviv_SOURCE2_ALPHA"
external get_tex_env_operand0_alpha : [`texture_env] -> GlMultiTex.operand_alpha_param = "ml_glGetTexEnviv_OPERAND0_ALPHA"
external get_tex_env_operand1_alpha : [`texture_env] -> GlMultiTex.operand_alpha_param = "ml_glGetTexEnviv_OPERAND1_ALPHA"
external get_tex_env_operand2_alpha : [`texture_env] -> GlMultiTex.operand_alpha_param = "ml_glGetTexEnviv_OPERAND2_ALPHA"
external get_tex_env_color : [`texture_env] -> rgba = "ml_glGetTexEnvfv_TEXTURE_ENV_COLOR"
external get_tex_env_rgb_scale : [`texture_env] -> rgb = "ml_glGetTexEnvfv_TEXTURE_ENV_COLOR"
external get_tex_env_alpha_scale : [`texture_env] -> rgb = "ml_glGetTexEnvfv_TEXTURE_ENV_COLOR"
external get_tex_env_lod_bias : [`filter_control] -> float = "ml_glGetTexEnvfv_TEXTURE_LOD_BIAS"

let get_tex_env pname =
  match pname with
  | `color          -> `color (get_tex_env_color `texture_env)
  | `combine_alpha  -> `combine_alpha (get_tex_env_combine_alpha `texture_env)
  | `combine_rgb    -> `combine_rgb (get_tex_env_combine_rgb `texture_env) 
  | `mode           -> `mode (get_tex_env_mode `texture_env) 
  | `operand0_alpha -> `operand0_alpha (get_tex_env_operand0_alpha `texture_env)
  | `operand0_rgb   -> `operand0_rgb (get_tex_env_operand0_rgb `texture_env) 
  | `operand1_alpha -> `operand1_alpha (get_tex_env_operand1_alpha `texture_env) 
  | `operand1_rgb   -> `operand1_rgb (get_tex_env_operand1_rgb `texture_env) 
  | `operand2_alpha -> `operand2_alpha (get_tex_env_operand2_alpha `texture_env)
  | `operand2_rgb   -> `operand2_rgb (get_tex_env_operand2_rgb `texture_env) 
  | `source0_alpha  -> `source0_alpha (get_tex_env_source0_alpha `texture_env)
  | `source0_rgb    -> `source0_rgb (get_tex_env_source0_rgb `texture_env) 
  | `source1_alpha  -> `source1_alpha (get_tex_env_source1_alpha `texture_env)
  | `source1_rgb    -> `source1_rgb (get_tex_env_source1_rgb `texture_env) 
  | `source2_alpha  -> `source2_alpha (get_tex_env_source2_alpha `texture_env)
  | `source2_rgb    -> `source2_rgb (get_tex_env_source2_rgb `texture_env) 
  | `rgb_scale      -> `rgb_scale (get_tex_env_rgb_scale `texture_env)
  | `alpha_scale    -> `alpha_scale (get_tex_env_alpha_scale `texture_env)
  | `lod_bias       -> `lod_bias (get_tex_env_lod_bias `filter_control)

type gen_pname = 
  [ `mode
  | `object_plane
  | `eye_plane ]

external get_tex_gen_mode : GlTex.coord -> GlTex.gen_mode_param = "ml_glGetTexGeniv_TEXTURE_GEN_MODE"
external get_tex_gen_object_plane : GlTex.coord -> point4 = "ml_glGetTexGenfv_OBJECT_PLANE"
external get_tex_gen_eye_plane : GlTex.coord -> point4 = "ml_glGetTexGenfv_EYE_PLANE"

let get_tex_gen ~coord ~pname =
  match pname with
  | `mode          -> `mode (get_tex_gen_mode coord)
  | `object_plane  -> `object_plane (get_tex_gen_object_plane coord)
  | `eye_plane     -> `eye_plane (get_tex_gen_eye_plane coord)

type parameter_pname =
  [ `border_color | `generate_mipmap | `mag_filter | `min_filter | `priority
  | `wrap_r | `wrap_s | `wrap_t | `min_lod | `max_lod | `base_level | `max_level 
  | `lod_bias | `depth_mode | `compare_mode ]

type parameter_target = [`texture_1d|`texture_2d|`texture_cube_map]

external get_tex_parameter_border_color : parameter_target -> rgba  = "ml_glGetTexParameterfv_TEXTURE_BORDER_COLOR"
external get_tex_parameter_generate_mipmap : parameter_target -> bool = "ml_glGetTexParameteriv_GENERATE_MIPMAP"
external get_tex_parameter_mag_filter : parameter_target -> GlTex.mag_filter = "ml_glGetTexParameteriv_TEXTURE_MAG_FILTER"
external get_tex_parameter_min_filter : parameter_target -> GlTex.min_filter = "ml_glGetTexParameteriv_TEXTURE_MIN_FILTER"
external get_tex_parameter_priority : parameter_target -> clampf = "ml_glGetTexParameterfv_TEXTURE_PRIORITY"
external get_tex_parameter_wrap_r : parameter_target -> GlTex.wrap = "ml_glGetTexParameteriv_TEXTURE_WRAP_R"
external get_tex_parameter_wrap_s : parameter_target -> GlTex.wrap = "ml_glGetTexParameteriv_TEXTURE_WRAP_S"
external get_tex_parameter_wrap_t : parameter_target -> GlTex.wrap = "ml_glGetTexParameteriv_TEXTURE_WRAP_T"
external get_tex_parameter_min_lod : parameter_target -> float = "ml_glGetTexParameterfv_TEXTURE_MIN_LOD"
external get_tex_parameter_max_lod : parameter_target -> float = "ml_glGetTexParameterfv_TEXTURE_MAX_LOD"
external get_tex_parameter_base_level : parameter_target -> int = "ml_glGetTexParameteriv_TEXTURE_BASE_LEVEL"
external get_tex_parameter_max_level : parameter_target -> int = "ml_glGetTexParameteriv_TEXTURE_MAX_LEVEL"
external get_tex_parameter_lod_bias :  parameter_target -> float = "ml_glGetTexParameterfv_TEXTURE_LOD_BIAS"
external get_tex_parameter_depth_mode : parameter_target -> GlTex.depth_mode = "ml_glGetTexParameteriv_DEPTH_TEXTURE_MODE"
external get_tex_parameter_compare_mode : parameter_target -> GlTex.compare_mode = "ml_glGetTexParameteriv_TEXTURE_COMPARE_MODE"

let get_tex_parameter ~target ~pname =
  match pname with
    | `border_color    -> `border_color (get_tex_parameter_border_color target)
    | `generate_mipmap -> `generate_mipmap (get_tex_parameter_generate_mipmap target)
    | `mag_filter      -> `mag_filter (get_tex_parameter_mag_filter target)
    | `min_filter      -> `min_filter (get_tex_parameter_min_filter target)
    | `priority        -> `priority (get_tex_parameter_priority target)
    | `wrap_r          -> `wrap_r (get_tex_parameter_wrap_r target)
    | `wrap_s          -> `wrap_s (get_tex_parameter_wrap_s target)
    | `wrap_t          -> `wrap_t (get_tex_parameter_wrap_t target)
    | `min_lod         -> `min_lod (get_tex_parameter_min_lod target)
    | `max_lod         -> `max_lod (get_tex_parameter_max_lod target)
    | `base_level      -> `base_level (get_tex_parameter_base_level target)
    | `max_level       -> `max_level (get_tex_parameter_max_level target)
    | `lod_bias        -> `lod_bias (get_tex_parameter_lod_bias target)
    | `depth_mode      -> `depth_mode (get_tex_parameter_depth_mode target)
    | `compare_mode    -> `compare_mode (get_tex_parameter_compare_mode target)

type level_target =
  [ GlTex.target_1d 
  | GlTex.target_3d 
  | `texture_2d
  | `texture_cube_map_positive_x
  | `texture_cube_map_negative_x
  | `texture_cube_map_positive_y
  | `texture_cube_map_negative_y
  | `texture_cube_map_positive_z
  | `texture_cube_map_negative_z
  | `proxy_texture_2d ]
(* texture_cube_map not allowed *)

type level_pname =
  [ `width | `height | `depth | `border | `internal_format | `components 
  | `red_size | `green_size | `blue_size | `alpha_size
  | `luminance_size | `intensity_size | `depth_size | `compressed | `compressed_image_size ]

type tex_level_parameter =
  [ `width of int
  | `height of int
  | `depth of int
  | `border of int
  | `internal_format of internalformat
  | `components of int
  | `red_size of int
  | `green_size of int
  | `blue_size of int
  | `alpha_size of int
  | `luminance_size of int
  | `intensity_size of int
  | `depth_size of int
  | `compressed of bool
  | `compressed_image_size of int ]

external get_tex_level_width : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_WIDTH"
external get_tex_level_height : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_HEIGHT"
external get_tex_level_depth : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_DEPTH"
external get_tex_level_border : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_BORDER"
external get_tex_level_internal_format : level_target -> int -> internalformat = "ml_glGetTexLevelParameteriv_TEXTURE_INTERNAL_FORMAT"
external get_tex_level_components : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_COMPONENTS"
external get_tex_level_red_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_RED_SIZE"
external get_tex_level_green_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_GREEN_SIZE"
external get_tex_level_blue_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_BLUE_SIZE"
external get_tex_level_alpha_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_ALPHA_SIZE"
external get_tex_level_luminance_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_LUMINANCE_SIZE"
external get_tex_level_intensity_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_INTENSITY_SIZE"
external get_tex_level_depth_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_DEPTH_SIZE"
external get_tex_level_compressed : level_target -> int -> bool = "ml_glGetTexLevelParameteriv_TEXTURE_COMPRESSED"
external get_tex_level_compressed_image_size : level_target -> int -> int = "ml_glGetTexLevelParameteriv_TEXTURE_COMPRESSED_IMAGE_SIZE"


let get_tex_level_parameter ~target ~lod ~pname =
  match pname with
      `width                 -> `width (get_tex_level_width target lod)
    | `height                -> `height (get_tex_level_height target lod)
    | `depth                 -> `depth (get_tex_level_depth target lod)
    | `border                -> `border (get_tex_level_border target lod)
    | `internal_format       -> `internal_format (get_tex_level_internal_format target lod)
    | `components            -> `components (get_tex_level_components target lod) 
    | `red_size              -> `red_size (get_tex_level_red_size target lod)
    | `green_size            -> `green_size (get_tex_level_green_size target lod)
    | `blue_size             -> `blue_size (get_tex_level_blue_size target lod)
    | `alpha_size            -> `alpha_size (get_tex_level_alpha_size target lod)
    | `luminance_size        -> `luminance_size (get_tex_level_luminance_size target lod)
    | `intensity_size        -> `intensity_size (get_tex_level_intensity_size target lod)
    | `depth_size            -> `depth_size (get_tex_level_depth_size target lod)
    | `compressed            -> `compressed (get_tex_level_compressed target lod)
    | `compressed_image_size -> `compressed_image_size (get_tex_level_compressed_image_size target lod)

(*
  no way to know the size of the maps?
external get_pixel_map : GlPix.map -> [`float] Raw.t

external get_map : GlMap.target -> [`order | `coeff | `domain ] -> [`double] Raw.t

*)

type image_target =
  [ `texture_1d
  | `texture_2d
  | `texture_cube_map_positive_x
  | `texture_cube_map_negative_x
  | `texture_cube_map_positive_y
  | `texture_cube_map_negative_y
  | `texture_cube_map_positive_z
  | `texture_cube_map_negative_z
  | `texture_3d ]

type format =
  [ `red
  | `green
  | `blue
  | `alpha
  | `rgb
  | `rgba
  | `luminance
  | `luminance_alpha ]

external get_tex_image : target:image_target -> level:int -> format:([< format ] as 'a) -> kind:[< real_kind ] -> ([< real_kind ] Raw.t * int * int * int) = "ml_glGetTexImage"

external get_compressed_tex_image : target:image_target -> level:int -> [< real_kind ] Raw.t = "ml_glGetCompressedTexImage"

let get_tex_image ?(target=`texture_2d) ?(level=0) ~format ~kind () =
  let r, width, height, depth = get_tex_image ~target ~level ~format ~kind in
  GlPix3D.of_raw r ~format ~width ~height ~depth

let get_compressed_tex_image ?(target=`texture_2d) ?(level=0) () =
  get_compressed_tex_image ~target ~level 

external get_polygon_stipple : unit -> [`bitmap] Raw.t = "ml_glGetPolygonStipple"

let get_polygon_stipple () =
  let r = get_polygon_stipple () in
  GlPix.of_raw r ~format:`color_index ~width:32 ~height:32 

(* imaging subset -------------------------- *)

type color_table_pname = 
  [ `table_format
  | `table_width
  | `table_red_size
  | `table_green_size
  | `table_blue_size
  | `table_alpha_size
  | `table_luminance_size
  | `table_intensity_size
  | `table_scale
  | `table_bias ]

type color_table_parameter = 
  [ `table_format of GlColor.table_format
  | `table_width of int
  | `table_red_size of int
  | `table_green_size of int
  | `table_blue_size of int
  | `table_alpha_size of int
  | `table_luminance_size of int
  | `table_intensity_size of int
  | `table_scale of rgba
  | `table_bias of rgba ]


external get_color_table_format : target:GlColor.table -> GlColor.table_format = "ml_glGetColorTableParameteriv_COLOR_TABLE_FORMAT"
external get_color_table_width : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_WIDTH" "noalloc"
external get_color_table_red_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_RED_SIZE" "noalloc"
external get_color_table_green_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_GREEN_SIZE" "noalloc"
external get_color_table_blue_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_BLUE_SIZE" "noalloc"
external get_color_table_alpha_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_ALPHA_SIZE" "noalloc"
external get_color_table_luminance_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_LUMINANCE_SIZE" "noalloc"
external get_color_table_intensity_size : target:GlColor.table -> int = "ml_glGetColorTableParameteriv_COLOR_TABLE_INTENSITY_SIZE" "noalloc"
external get_color_table_scale : target:GlColor.table -> rgba = "ml_glGetColorTableParameterfv_COLOR_TABLE_SCALE"
external get_color_table_bias : target:GlColor.table -> rgba = "ml_glGetColorTableParameterfv_COLOR_TABLE_BIAS"

let get_color_table_parameter ~target ~pname =
  match pname with
    | `table_format          -> `table_format (get_color_table_format ~target)
    | `table_width           -> `table_width (get_color_table_width ~target)
    | `table_red_size        -> `table_red_size (get_color_table_red_size ~target)
    | `table_green_size      -> `table_green_size (get_color_table_green_size ~target)
    | `table_blue_size       -> `table_blue_size (get_color_table_blue_size ~target)
    | `table_alpha_size      -> `table_alpha_size (get_color_table_alpha_size ~target)
    | `table_luminance_size  -> `table_luminance_size (get_color_table_luminance_size ~target)
    | `table_intensity_size  -> `table_intensity_size (get_color_table_intensity_size ~target)
    | `table_scale           -> `table_scale (get_color_table_scale ~target)
    | `table_bias            -> `table_bias (get_color_table_bias ~target)

external get_color_table : target:GlColor.table -> format:[< GlColor.table_format ]  -> kind:([< real_kind ] as 'a) -> ('a Raw.t * int) = "ml_glGetColorTable" 

let get_color_table ~target ~format ~kind =
  let r, width = get_color_table ~target ~format ~kind in
  GlPix.of_raw r ~format ~width ~height:1

external get_convolution_filter : target:[`convolution_1d|`convolution_2d] -> format:[< GlConvolution.format ]  -> kind:([< real_kind] as 'a) -> 'a Raw.t * int * int = "ml_glGetConvolutionFilter"

let get_convolution_filter ~target ~format ~kind =
  let r,width,height = get_convolution_filter ~target ~format ~kind in
  GlPix.of_raw r ~format ~width ~height

external get_separable_filter : target:[`separable_2d] -> format:[< GlConvolution.format ]  -> kind:([< real_kind] as 'a) -> 'a Raw.t * int * 'a Raw.t * int = "ml_glGetSeparableFilter"

let get_separable_filter ~target ~format ~kind =
  let r1, width, r2, height = get_separable_filter ~target ~format ~kind in
  GlPix.of_raw r1 ~format ~width ~height:1, GlPix.of_raw r2 ~format ~width:1 ~height
  

type histogram_pname =
  [ `histogram_width
  | `histogram_format
  | `histogram_red_size
  | `histogram_green_size
  | `histogram_blue_size
  | `histogram_alpha_size
  | `histogram_luminance_size
  | `histogram_sink ]

type histogram_parameter = 
  [ `histogram_width of int
  | `histogram_format of int
  | `histogram_red_size of int
  | `histogram_green_size of int
  | `histogram_blue_size of int
  | `histogram_alpha_size of int
  | `histogram_luminance_size of int
  | `histogram_sink of bool ]
    
external get_histogram_width : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_WIDTH" "noalloc"
external get_histogram_format : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_FORMAT" "noalloc"
external get_histogram_red_size : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_RED_SIZE" "noalloc"
external get_histogram_green_size : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_GREEN_SIZE" "noalloc"
external get_histogram_blue_size : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_BLUE_SIZE" "noalloc"
external get_histogram_alpha_size : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_ALPHA_SIZE" "noalloc"
external get_histogram_luminance_size : target:GlColor.histogram -> int = "ml_glGetHistogramParameteriv_HISTOGRAM_LUMINANCE_SIZE" "noalloc"
external get_histogram_sink : target:GlColor.histogram -> bool = "ml_glGetHistogramParameteriv_HISTOGRAM_SINK" "noalloc"

let get_histogram_parameter ~target ~pname =
  match pname with
    | `histogram_width             -> `histogram_width (get_histogram_width ~target)
    | `histogram_format            -> `histogram_format (get_histogram_format ~target)
    | `histogram_red_size          -> `histogram_red_size (get_histogram_red_size ~target)
    | `histogram_green_size        -> `histogram_green_size (get_histogram_green_size ~target)
    | `histogram_blue_size         -> `histogram_blue_size (get_histogram_blue_size ~target)
    | `histogram_alpha_size        -> `histogram_alpha_size (get_histogram_alpha_size ~target)
    | `histogram_luminance_size    -> `histogram_luminance_size (get_histogram_luminance_size ~target)
    | `histogram_sink              -> `histogram_sink (get_histogram_sink ~target)

type minmax_pname = 
  [ `minmax_format
  | `minmax_sink ]

type minmax_parameter = 
  [ `minmax_format of Gl.format (* this ought to be wrong, it should probably be only a subset *)
  | `minmax_sink of bool ]

external get_minmax_format : [`minmax] -> Gl.format = "ml_glGetMinmaxParameteriv_MINMAX_FORMAT"
external get_minmax_sink : [`minmax] -> bool = "ml_glGetMinmaxParameteriv_MINMAX_SINK" "noalloc"

let get_minmax_parameter ~pname =
  match pname with
    | `minmax_format -> `minmax_format (get_minmax_format `minmax)
    | `minmax_sink   -> `minmax_sink (get_minmax_sink `minmax)


(* float queries ----- *)

type float4_pname = 
  [ `current_raster_position
  | `accum_clear_value ]

type float4_value =
  [ `current_raster_position of point4
  | `accum_clear_value of point4 ]

type float3_pname = 
  [ `current_normal 
  | `point_distance_attenuation ]

type float3_value = 
  [ `current_normal of point3 
  | `point_distance_attenuation of point3 ]

type float2_pname =
  [ `depth_range
  | `aliased_point_size_range
  | `smooth_point_size_range
  | `aliased_line_width_range
  | `smooth_line_width_range ]

type float2_value =
  [ `depth_range of point2
  | `aliased_point_size_range of point2
  | `smooth_point_size_range of point2
  | `aliased_line_width_range of point2
  | `smooth_line_width_range of point2 ]

type float_pname =
  [ `fog_density
  | `fog_start
  | `fog_end
  | `polygon_offset_factor
  | `polygon_offset_units
  | `red_scale
  | `green_scale
  | `blue_scale
  | `alpha_scale
  | `red_bias
  | `green_bias
  | `blue_bias
  | `alpha_bias
  | `post_convolution_red_scale
  | `post_convolution_green_scale
  | `post_convolution_blue_scale
  | `post_convolution_alpha_scale
  | `post_convolution_red_bias
  | `post_convolution_green_bias
  | `post_convolution_blue_bias
  | `post_convolution_alpha_bias
  | `post_color_matrix_red_scale
  | `post_color_matrix_green_scale
  | `post_color_matrix_blue_scale
  | `post_color_matrix_alpha_scale
  | `post_color_matrix_red_bias
  | `post_color_matrix_green_bias
  | `post_color_matrix_blue_bias
  | `post_color_matrix_alpha_bias
  | `zoom_x
  | `zoom_y
  | `current_raster_distance
  | `point_size
  | `point_size_min
  | `point_size_max
  | `point_fade_threshold_size
  | `line_width
  | `sample_coverage_value
  | `smooth_point_size_granularity
  | `smooth_line_width_granularity
  | `fog_index
  | `index_clear_value
  | `current_index
  | `current_raster_index 
  | `alpha_test_ref
  | `depth_clear_value
  | `max_texture_lod_bias ]

type float_value =
  [ `fog_density of float
  | `fog_start of float
  | `fog_end of float
  | `polygon_offset_factor of float
  | `polygon_offset_units of float
  | `red_scale of float
  | `green_scale of float
  | `blue_scale of float
  | `alpha_scale of float
  | `red_bias of float
  | `green_bias of float
  | `blue_bias of float
  | `alpha_bias of float
  | `post_convolution_red_scale of float
  | `post_convolution_green_scale of float
  | `post_convolution_blue_scale of float
  | `post_convolution_alpha_scale of float
  | `post_convolution_red_bias of float
  | `post_convolution_green_bias of float
  | `post_convolution_blue_bias of float
  | `post_convolution_alpha_bias of float
  | `post_color_matrix_red_scale of float
  | `post_color_matrix_green_scale of float
  | `post_color_matrix_blue_scale of float
  | `post_color_matrix_alpha_scale of float
  | `post_color_matrix_red_bias of float
  | `post_color_matrix_green_bias of float
  | `post_color_matrix_blue_bias of float
  | `post_color_matrix_alpha_bias of float
  | `zoom_x of float
  | `zoom_y of float
  | `current_raster_distance of float
  | `point_size of float
  | `point_size_min of float
  | `point_size_max of float
  | `point_fade_threshold_size of float
  | `line_width of float
  | `sample_coverage_value of float
  | `smooth_point_size_granularity of float
  | `smooth_line_width_granularity of float
  | `fog_index of float
  | `index_clear_value of float
  | `current_index of float
  | `current_raster_index of float 
  | `alpha_test_ref of float
  | `depth_clear_value of float
  | `max_texture_lod_bias of float ]

type matrix4_pname = GlMat.kind

type matrix4_value =
  [ `modelview_matrix of GlMat.t  | `transpose_modelview_matrix of GlMat.t
  | `projection_matrix of GlMat.t | `transpose_projection_matrix of GlMat.t
  | `color_matrix of GlMat.t      | `transpose_color_matrix of GlMat.t
  | `texture_matrix of GlMat.t    | `transpose_texture_matrix of GlMat.t]

type color_pname =
  [ `fog_color
  | `blend_color
  | `current_color
  | `current_secondary_color
  | `current_raster_color
  | `color_clear_value 
  | `light_model_ambient ]

type color_value =
  [ `fog_color of rgba
  | `blend_color of rgba
  | `current_color of rgba
  | `current_secondary_color of rgba
  | `current_raster_color of rgba
  | `color_clear_value of rgba
  | `light_model_ambient of rgba ]


(* may be 2, 3 or 4 floats, we default to 4 *)
type texcoord_pname = 
  [ `current_texture_coords
  | `current_raster_texture_coords ]

type texcoord_value = 
  [ `current_texture_coords of point4
  | `current_raster_texture_coords of point4 ]
    
type domain_pname =
  [ `map1_grid_domain
  | `map2_grid_domain ]

type domain_value =
  [ `map1_grid_domain of point2
  | `map2_grid_domain of point4 ]


external get_float4 : float4_pname -> (float * float * float * float) = "ml_glGetDoublev_4"
external get_float3 : float3_pname -> (float * float * float) = "ml_glGetDoublev_3"
external get_float2 : float2_pname -> (float * float) = "ml_glGetDoublev_2"
external get_float  : float_pname -> float = "ml_glGetDouble"
let get_matrix4 pname = GlMat.get_matrix pname
external get_color : color_pname -> rgba = "ml_glGetDoublev_4"
external get_texcoord : texcoord_pname -> (float * float * float * float) = "ml_glGetDoublev_4"
external get_domain1 : [`map1_grid_domain] -> (float * float) = "ml_glGetDoublev_2"
external get_domain2 : [`map2_grid_domain] -> (float * float * float * float) = "ml_glGetDoublev_4"

type floatv_pname =
    [ float_pname | float2_pname | float3_pname | float4_pname 
    | matrix4_pname | color_pname | texcoord_pname | domain_pname ]

type floatv_value =
    [ float_value | float2_value | float3_value | float4_value 
    | matrix4_value | color_value | texcoord_value | domain_value ]

(* hack: relies on the ocaml internal representation of 'parameterized' polymorphic 
   variants as a tuple, see get_intv as well *)
let get_floatv ~pname =
  match pname with
    | #float_pname as x      -> Obj.magic (x, get_float x) 
    | #float2_pname as x     -> Obj.magic (x, get_float2 x)
    | #float3_pname as x     -> Obj.magic (x, get_float3 x)
    | #float4_pname as x     -> Obj.magic (x, get_float4 x)
    | #matrix4_pname as x    -> Obj.magic (x, get_matrix4 x)
    | #color_pname as x      -> Obj.magic (x, get_color x)
    | #texcoord_pname as x   -> Obj.magic (x, get_texcoord x)
    | `map1_grid_domain as x -> Obj.magic (x, get_domain1 x)
    | `map2_grid_domain as x -> Obj.magic (x, get_domain2 x)

(* integer queries --------------------- *)

type int_pname = 
  [ `index_shift
  | `index_offset
  | `num_compressed_texture_formats
  | `vertex_array_size
  | `vertex_array_stride
  | `normal_array_stride
  | `color_array_size
  | `color_array_stride
  | `index_array_stride
  | `edge_flag_array_stride
  | `texture_coord_array_size
  | `texture_coord_array_stride
  | `fog_coord_array_stride
  | `secondary_color_array_size
  | `secondary_color_array_stride
  | `color_matrix_stack_depth
  | `modelview_stack_depth
  | `projection_stack_depth
  | `texture_stack_depth
  | `line_stipple_pattern
  | `line_stipple_repeat
  | `stencil_value_mask
  | `stencil_ref
  | `index_writemask
  | `stencil_writemask
  | `stencil_clear_value
  | `unpack_image_height
  | `unpack_skip_images
  | `unpack_row_length
  | `unpack_skip_rows
  | `unpack_skip_pixels
  | `unpack_alignment
  | `pack_image_height
  | `pack_skip_images
  | `pack_row_length
  | `pack_skip_rows
  | `pack_skip_pixels
  | `pack_alignment
(*
  | `color_table_red_size
  | `color_table_green_size
  | `color_table_blue_size
  | `color_table_alpha_size
  | `color_table_luminance_size
  | `color_table_intensity_size
  | `histogram_red_size
  | `histogram_green_size
  | `histogram_blue_size
  | `histogram_alpha_size
  | `histogram_luminance_size
*)
  | `max_lights
  | `max_clip_planes
  | `max_color_matrix_stack_depth
  | `max_modelview_stack_depth
  | `max_projection_stack_depth
  | `max_texture_stack_depth
  | `subpixel_bits
  | `max_3d_texture_size
  | `max_texture_size
  | `max_cube_map_texture_size
  | `max_pixel_map_table
  | `max_name_stack_depth
  | `max_list_nesting
  | `max_eval_order
  | `max_attrib_stack_depth
  | `max_client_attrib_stack_depth
  | `aux_buffers
  | `max_elements_indices
  | `max_elements_vertices
  | `max_texture_units
  | `sample_buffers
  | `samples
(*
  | `red_bits
  | `green_bits
  | `blue_bits
  | `alpha_bits
*)
  | `index_bits
  | `depth_bits
  | `stencil_bits
  | `accum_red_bits
  | `accum_green_bits
  | `accum_blue_bits
  | `accum_alpha_bits
  | `list_base
  | `list_index
  | `list_mode
  | `attrib_stack_depth
  | `client_attrib_stack_depth
  | `name_stack_depth
  | `selection_buffer_size
  | `feedback_buffer_size
  | `compressed_texture_formats ]

type int_value = 
  [ `index_shift of int
  | `index_offset of int
  | `num_compressed_texture_formats of int
  | `vertex_array_size of int
  | `vertex_array_stride of int
  | `normal_array_stride of int
  | `color_array_size of int
  | `color_array_stride of int
  | `index_array_stride of int
  | `edge_flag_array_stride of int
  | `texture_coord_array_size of int
  | `texture_coord_array_stride of int
  | `fog_coord_array_stride of int
  | `secondary_color_array_size of int
  | `secondary_color_array_stride of int
  | `color_matrix_stack_depth of int
  | `modelview_stack_depth of int
  | `projection_stack_depth of int
  | `matrix_stack_depth of int
  | `line_stipple_pattern of int
  | `line_stipple_repeat of int
  | `stencil_value_mask of int
  | `stencil_ref of int
  | `index_writemask of int
  | `stencil_writemask of int
  | `stencil_clear_value of int
  | `unpack_image_height of int
  | `unpack_skip_images of int
  | `unpack_row_length of int
  | `unpack_skip_rows of int
  | `unpack_skip_pixels of int
  | `unpack_alignment of int
  | `pack_image_height of int
  | `pack_skip_images of int
  | `pack_row_length of int
  | `pack_skip_rows of int
  | `pack_skip_pixels of int
  | `pack_alignment of int
(*
  | `color_table_red_size
  | `color_table_green_size
  | `color_table_blue_size
  | `color_table_alpha_size
  | `color_table_luminance_size
  | `color_table_intensity_size
  | `histogram_red_size
  | `histogram_green_size
  | `histogram_blue_size
  | `histogram_alpha_size
  | `histogram_luminance_size
*)
  | `max_lights of int
  | `max_clip_planes of int
  | `max_color_matrix_stack_depth of int
  | `max_modelview_stack_depth of int
  | `max_projection_stack_depth of int
  | `max_texture_stack_depth of int
  | `subpixel_bits of int
  | `max_3d_texture_size of int
  | `max_texture_size of int
  | `max_cube_map_texture_size of int
  | `max_pixel_map_table of int
  | `max_name_stack_depth of int
  | `max_list_nesting of int
  | `max_eval_order of int
  | `max_attrib_stack_depth of int
  | `max_client_attrib_stack_depth of int
  | `aux_buffers of int
  | `max_elements_indices of int
  | `max_elements_vertices of int
  | `max_texture_units of int
  | `sample_buffers of int
  | `samples of int
(*
  | `red_bits of int
  | `green_bits of int
  | `blue_bits of int
  | `alpha_bits of int
*)
  | `index_bits of int
  | `depth_bits of int
  | `stencil_bits of int
  | `accum_red_bits of int
  | `accum_green_bits of int
  | `accum_blue_bits of int
  | `accum_alpha_bits of int
  | `list_base of int
  | `list_index of int
  | `list_mode of int
  | `attrib_stack_depth of int
  | `client_attrib_stack_depth of int
  | `name_stack_depth of int
  | `selection_buffer_size of int
  | `feedback_buffer_size of int
  | `compressed_texture_formats of int ]


type int4_pname = 
  [ `viewport 
  | `scissor_box ]

type int4_value =
  [ `viewport of (int * int * int * int)
  | `scissor_box of (int * int * int * int) ]

type int2_pname =
  [ `max_viewport_dims ]

type int2_value =
  [ `max_viewport_dims of (int * int) ]

type enum_pname =
  [ `client_active_texture
  | `vertex_array_type
  | `normal_array_type
  | `color_array_type
  | `index_array_type
  | `texture_coord_array_type
  | `matrix_mode
  | `fog_mode
  | `fog_coord_src
  | `shade_model
  | `color_material_parameter
  | `color_material_face
  | `light_model_color_control
  | `cull_face_mode
  | `front_face
  | `active_texture
  | `alpha_test_func
  | `stencil_func
  | `stencil_fail
  | `stencil_pass_depth_fail
  | `stencil_pass_depth_pass
  | `depth_func
  | `blend_src_rgb
  | `blend_src_alpha
  | `blend_dst_rgb
  | `blend_dst_alpha
  | `blend_equation
  | `logic_op_mode
  | `perspective_correction_hint
  | `point_smooth_hint
  | `line_smooth_hint
  | `polygon_smooth_hint
  | `fog_hint
  | `texture_compression_hint
  | `generate_mipmap_hint
  | `render_mode
  | `feedback_buffer_type
  | `draw_buffer
  | `read_buffer
  | `polygon_mode ]

type enum_value =
  [ `client_active_texture of GlMultiTex.texture
  | `vertex_array_type of GlArray.vertex_array_type
  | `normal_array_type of GlArray.normal_array_type
  | `color_array_type of GlArray.color_array_type
  | `index_array_type of GlArray.index_array_type
  | `texture_coord_array_type of GlArray.texcoord_array_type
  | `matrix_mode of GlMat.mode
  | `fog_mode of GlFog.fog_mode
  | `fog_coord_src of GlFog.coord_src
  | `shade_model of GlDraw.shade_model
  | `color_material_parameter of GlLight.material_param
  | `color_material_face of Gl.face
  | `light_model_color_control of GlLight.color_control
  | `cull_face_mode of Gl.face
  | `front_face of GlDraw.face_dir
  | `active_texture of GlMultiTex.texture
  | `alpha_test_func of Gl.cmp_func
  | `stencil_func of Gl.cmp_func
  | `stencil_fail of GlFunc.stencil_op
  | `stencil_pass_depth_fail of GlFunc.stencil_op
  | `stencil_pass_depth_pass of GlFunc.stencil_op
  | `depth_func of Gl.cmp_func
  | `blend_src_rgb of GlFunc.sfactor
  | `blend_dst_rgb of GlFunc.dfactor
  | `blend_src_alpha of GlFunc.sfactor
  | `blend_dst_alpha of GlFunc.dfactor
  | `blend_equation of GlFunc.blend_equation
  | `logic_op_mode of GlFunc.logic_op
  | `perspective_correction_hint of GlMisc.hint
  | `point_smooth_hint of GlMisc.hint
  | `line_smooth_hint of GlMisc.hint
  | `polygon_smooth_hint of GlMisc.hint
  | `fog_hint of GlMisc.hint
  | `texture_compression_hint of GlMisc.hint
  | `generate_mipmap_hint of GlMisc.hint
  | `render_mode of GlMisc.render_mode
  | `feedback_buffer_type of GlMisc.feedback_mode
  | `draw_buffer of GlFunc.draw_buffer
  | `read_buffer of GlFunc.draw_buffer
  | `polygon_mode of GlDraw.polygon_mode ]

external get_int4 : int4_pname -> (int * int * int * int) = "ml_glGetIntegerv_4"
external get_int2 : int2_pname -> (int * int) = "ml_glGetIntegerv_2"
external get_int  : int_pname -> int = "ml_glGetInteger"
external get_enum : enum_pname -> [> enum_value ] = "ml_glGetEnum"

(* hack: relies on the ocaml internal representation of 'parameterized' polymorphic 
   variants as a tuple, same as get_floatv *)
let get_int4_ (x : int4_pname) : [> int4_value ] = Obj.magic (x, get_int4 x)
let get_int2_ (x : int2_pname) : [> int2_value ] = Obj.magic (x, get_int2 x)
let get_int_ (x : int_pname) : [> int_value ] = Obj.magic (x, get_int x)

type intv_pname = 
    [ int4_pname | int2_pname | int_pname | enum_pname ]

type intv_value =
  [ int4_value | int2_value | int_value | enum_value ]

let get_intv : [<intv_pname] -> intv_value = function
    | #int4_pname as x -> get_int4_ x
    | #int2_pname as y -> get_int2_ y
    | #int_pname  as z -> get_int_ z
    | #enum_pname as w -> get_enum w
