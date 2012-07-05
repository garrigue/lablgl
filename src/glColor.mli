(** support for color tables, histograms & minmax *)

(** See section 3.6 of the OpenGL 1.3 specifications. *)

(** data types *)

type table =
  [ `color_table | `post_color_matrix | `post_convolution | `proxy_color_table
  | `proxy_post_color_matrix | `proxy_post_convolution ]

type table_format =
  [ `alpha | `blue | `green | `luminance | `luminance_alpha
  | `red | `rgb | `rgba ]

type histogram = [`histogram | `proxy_histogram ]

(** set a color table up in the fixed pipeline *)
val table :
  target:[<table] ->
  ?internal:Gl.internalformat ->
  ([< table_format ], [< Gl.real_kind ]) GlPix.t -> unit
(** see ColorTable in section 3.6.3 of the specs *)

type parameter = [ `table_bias of Gl.rgba | `table_scale of Gl.rgba ]

(** color tables functions

 see section 3.6.3 of the specs *)

(** set color tables parameters *)
val table_parameter :
  target:[<table] -> param:[<parameter] -> unit

(** copy a color table *)
val copy :
  target:[<table] ->
  internal:[< Gl.internalformat ] -> x:int -> y:int -> width:int -> unit

(** set a range of a table *)
val sub_table :
  target:[<table] ->
  start:int ->
  count:int -> ([< table_format ], [< Gl.real_kind ]) GlPix.t -> unit

(** copy a range of a table *)
val copy_sub :
  target:[<table] -> start:int -> x:int -> y:int -> count:int -> unit

(** set a histogram up *)
val histogram : 
  target:[<histogram] -> width:int -> internal:[<Gl.internalformat] -> sink:bool -> unit

val reset_histogram :
  target:[<histogram] -> unit

val minmax : 
  internal:[<Gl.internalformat] -> sink:bool -> unit

val reset_minmax : unit -> unit
