
type boolean_pname =
    [ `color_writemask
    | `current_raster_position_valid
    | `depth_writemask
    | `doublebuffer
    | `edge_flag
    | `index_mode
    | `light_model_local_viewer
    | `light_model_two_side
    | `map_color
    | `map_stencil
    | `pack_lsb_first
    | `pack_swap_bytes
    | `rgba_mode
    | `sample_coverage_invert
    | `stereo
    | `unpack_lsb_first
    | `unpack_swap_bytes ]

external get_boolean : boolean_pname -> bool = "ml_glGetBoolean" "noalloc"

val get_clip_plane : int -> GlMisc.equation
type light_pname =
    [ `ambient
    | `constant_attenuation
    | `diffuse
    | `linear_attenuation
    | `position
    | `quadratic_attenuation
    | `specular
    | `spot_cutoff
    | `spot_direction
    | `spot_exponent ]

val get_light : num:int -> value:light_pname -> GlLight.light_param

type material_pname =
    [ `ambient
    | `ambient_and_diffuse
    | `color_indexes
    | `diffuse
    | `emission
    | `shininess
    | `specular ]

val get_material :
  face:[ `back | `front ] -> pname:material_pname -> GlLight.material_param

type env_pname =
  [ `color | `combine_alpha | `combine_rgb | `mode | `operand0_alpha
  | `operand0_rgb | `operand1_alpha | `operand1_rgb | `operand2_alpha
  | `operand2_rgb | `source0_alpha | `source0_rgb | `source1_alpha
  | `source1_rgb | `source2_alpha | `source2_rgb | `rgb_scale | `alpha_scale 
  | `lod_bias ]

type env_param = 
    [ GlTex.filter_param | GlMultiTex.env_param | `rgb_scale of Gl.rgb | `alpha_scale of Gl.rgb ]

val get_tex_env : env_pname -> env_param

type gen_pname = 
  [ `mode
  | `object_plane
  | `eye_plane ]

val get_tex_gen : coord:GlTex.coord -> pname:gen_pname -> GlTex.gen_param

type parameter_pname =
  [ `border_color | `generate_mipmap | `mag_filter | `min_filter | `priority
  | `wrap_r | `wrap_s | `wrap_t | `min_lod | `max_lod | `base_level | `max_level 
  | `lod_bias | `depth_mode | `compare_mode ]

type parameter_target = [`texture_1d|`texture_2d|`texture_cube_map]

val get_tex_parameter : target:parameter_target -> pname:parameter_pname -> GlTex.parameter


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

type level_pname =
  [ `width | `height | `depth | `border | `internal_format | `components 
  | `red_size | `green_size | `blue_size | `alpha_size
  | `luminance_size | `intensity_size | `depth_size | `compressed | `compressed_image_size ]

type tex_level_parameter =
  [ `width of int
  | `height of int
  | `depth of int
  | `border of int
  | `internal_format of Gl.internalformat
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

val get_tex_level_parameter :  target:level_target -> lod:int -> pname:level_pname -> tex_level_parameter

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
  [ `red | `green | `blue | `alpha | `rgb | `rgba | `luminance | `luminance_alpha ]

val get_tex_image : ?target:image_target -> ?level:int -> format:([< format ] as 'a) -> kind:[< Gl.real_kind ] -> unit -> ('a,[< Gl.real_kind ]) GlPix3D.t

val get_compressed_tex_image : ?target:image_target -> ?level:int -> unit -> [`ubyte] Raw.t

val get_polygon_stipple : unit -> GlPix.bitmap

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
  | `table_scale of Gl.rgba
  | `table_bias of Gl.rgba ]

val get_color_table_parameter : target:GlColor.table -> pname:color_table_pname -> color_table_parameter

val get_color_table : target:GlColor.table -> format:([< GlColor.table_format ] as 'a)  -> kind:([< Gl.real_kind ] as 'b) -> ('a, 'b) GlPix.t


val get_convolution_filter : target:[`convolution_1d|`convolution_2d] -> format:([< GlConvolution.format ] as 'a) -> kind:([< Gl.real_kind] as 'b) -> ('a,'b) GlPix.t

val get_separable_filter : target:[`separable_2d] -> format:([< GlConvolution.format ] as 'a) -> kind:([< Gl.real_kind] as 'b) -> ('a,'b) GlPix.t * ('a,'b) GlPix.t


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

val get_histogram_parameter : target:GlColor.histogram -> pname:histogram_pname -> histogram_parameter


type minmax_pname = 
  [ `minmax_format
  | `minmax_sink ]

type minmax_parameter = 
  [ `minmax_format of Gl.format (* this ought to be wrong, it should probably be only a subset *)
  | `minmax_sink of bool ]

val get_minmax_parameter : pname:minmax_pname -> minmax_parameter


(* float queries ----- *)

type float4_pname = 
  [ `current_raster_position
  | `accum_clear_value ]

type float4_value =
  [ `current_raster_position of Gl.point4
  | `accum_clear_value of Gl.point4 ]

type float3_pname = 
  [ `current_normal | `point_distance_attenuation ]

type float3_value = 
  [ `current_normal of Gl.point3 
  | `point_distance_attenuation of Gl.point3 ]

type float2_pname =
  [ `depth_range
  | `aliased_point_size_range
  | `smooth_point_size_range
  | `aliased_line_width_range
  | `smooth_line_width_range ]

type float2_value =
  [ `depth_range of Gl.point2
  | `aliased_point_size_range of Gl.point2
  | `smooth_point_size_range of Gl.point2
  | `aliased_line_width_range of Gl.point2
  | `smooth_line_width_range of Gl.point2 ]

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
  [ `fog_color of Gl.rgba
  | `blend_color of Gl.rgba
  | `current_color of Gl.rgba
  | `current_secondary_color of Gl.rgba
  | `current_raster_color of Gl.rgba
  | `color_clear_value of Gl.rgba
  | `light_model_ambient of Gl.rgba ]


(* may be 2, 3 or 4 floats, we default to 4 *)
type texcoord_pname = 
  [ `current_texture_coords
  | `current_raster_texture_coords ]

type texcoord_value = 
  [ `current_texture_coords of Gl.point4
  | `current_raster_texture_coords of Gl.point4 ]
    
type domain_pname =
  [ `map1_grid_domain
  | `map2_grid_domain ]

type domain_value =
  [ `map1_grid_domain of Gl.point2
  | `map2_grid_domain of Gl.point4 ]


val get_float4 : float4_pname -> (float * float * float * float)
val get_float3 : float3_pname -> (float * float * float)
val get_float2 : float2_pname -> (float * float)
val get_float  : float_pname -> float
val get_matrix4 : matrix4_pname ->  GlMat.t
val get_color : color_pname -> Gl.rgba
val get_texcoord : texcoord_pname -> (float * float * float * float)
val get_domain1 : [`map1_grid_domain] -> (float * float)
val get_domain2 : [`map2_grid_domain] -> (float * float * float * float)

type floatv_pname =
    [ float_pname | float2_pname | float3_pname | float4_pname 
    | matrix4_pname | color_pname | texcoord_pname | domain_pname ]

type floatv_value =
    [ float_value | float2_value | float3_value | float4_value 
    | matrix4_value | color_value | texcoord_value | domain_value ]

val get_floatv : pname:floatv_pname -> floatv_value

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
  | `texture_coord_array_size of int
  | `texture_coord_array_stride of int
  | `edge_flag_array_stride of int
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
  | `blend_src_alpha of GlFunc.sfactor
  | `blend_dst_rgb of GlFunc.dfactor
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

val get_int4 : int4_pname -> (int * int * int * int)
val get_int2 : int2_pname -> (int * int)
val get_int  : int_pname -> int
val get_enum : enum_pname -> enum_value

type intv_pname = 
    [ int4_pname | int2_pname | int_pname | enum_pname ]

type intv_value =
  [ int4_value | int2_value | int_value | enum_value ]

val get_intv : [<intv_pname] -> intv_value
