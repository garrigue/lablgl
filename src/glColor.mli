
type table =
  [ `color_table | `post_color_matrix | `post_convolution | `proxy_color_table
  | `proxy_post_color_matrix | `proxy_post_convolution ]

type table_format =
  [ `alpha | `blue | `green | `luminance | `luminance_alpha
  | `red | `rgb | `rgba ]

val table :
  target:table ->
  ?internal:Gl.internalformat ->
  format:[< table_format ] ->
  ([< table_format ], [< Gl.real_kind ]) GlPix.t -> unit

type parameter = [ `color_table_bias of Gl.rgba | `color_table_scale of Gl.rgba ]

val table_parameter :
  target:table -> parameter:parameter -> Gl.rgba -> unit

val copy :
  target:table ->
  internal:[< Gl.internalformat ] -> x:int -> y:int -> width:int -> unit

val sub_table :
  target:table ->
  start:int ->
  count:int -> format:[< table_format ] -> [< Gl.real_kind ] Raw.t -> unit

val copy_sub :
  target:table -> start:int -> x:int -> y:int -> count:int -> unit

val histogram : 
  width:int -> internal:Gl.internalformat -> bool -> unit

val minmax : 
  internal:Gl.internalformat -> bool -> unit

