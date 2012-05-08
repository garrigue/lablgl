(* $Id: glShader.mli,v 1.1 2010-03-11 08:30:02 garrigue Exp $ *)
(* Code contributed by Florent Monnier *)

(** GLSL Shaders *)

type shader_object
type shader_program

val create: shader_type:[`vertex_shader|`fragment_shader] -> shader_object
val delete: shader:shader_object -> unit
val source: shader:shader_object  -> string -> unit
val compile: shader:shader_object -> unit
val create_program: unit -> shader_program
val delete_program: program:shader_program -> unit
val attach: program:shader_program -> shader:shader_object  -> unit
val detach: program:shader_program -> shader:shader_object -> unit
val link_program: program:shader_program -> unit
val use_program: program:shader_program -> unit
val unuse_program: unit -> unit
val shader_compile_status: shader:shader_object -> bool
val shader_compile_status_exn: shader:shader_object -> unit
val get_uniform_location: program:shader_program -> name:string -> int


val get_program_attached_shaders: program:shader_program -> int
val get_program_active_uniforms: program:shader_program -> int
val get_program_active_attributes: program:shader_program -> int

val get_program_validate_status: program:shader_program -> bool
val get_program_link_status: program:shader_program -> bool
val get_program_delete_status: program:shader_program -> bool


val uniform1f: location:int -> v0:float -> unit
val uniform2f: location:int -> v0:float -> v1:float -> unit
val uniform3f: location:int -> v0:float -> v1:float -> v2:float -> unit
val uniform4f: location:int -> v0:float -> v1:float -> v2:float -> v3:float -> unit
val uniform1i: location:int -> v0:int -> unit
val uniform2i: location:int -> v0:int -> v1:int -> unit
val uniform3i: location:int -> v0:int -> v1:int -> v2:int -> unit
val uniform4i: location:int -> v0:int -> v1:int -> v2:int -> v3:int -> unit

val uniform1fv: location:int -> value:float array -> unit
val uniform2fv: location:int -> count:int -> value:float array -> unit
val uniform3fv: location:int -> count:int -> value:float array -> unit
val uniform4fv: location:int -> count:int -> value:float array -> unit
val uniform1iv: location:int -> value:int array -> unit
val uniform2iv: location:int -> count:int -> value:int array -> unit
val uniform3iv: location:int -> count:int -> value:int array -> unit
val uniform4iv: location:int -> count:int -> value:int array -> unit

val uniform_matrix2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit
val uniform_matrix3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit
val uniform_matrix4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit

val uniform_matrix2x3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit
val uniform_matrix3x2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit

val uniform_matrix2x4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit
val uniform_matrix4x2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit

val uniform_matrix3x4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit
val uniform_matrix4x3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit


val get_attrib_location: program:shader_program -> name:string -> int
val bind_attrib_location: program:shader_program -> index:int -> name:string -> unit


val vertex_attrib1s: index:int -> v:int -> unit
val vertex_attrib1d: index:int -> v:float -> unit
val vertex_attrib2s: index:int -> v0:int -> v1:int -> unit
val vertex_attrib2d: index:int -> v0:float -> v1:float -> unit
val vertex_attrib3s: index:int -> v0:int -> v1:int -> v2:int -> unit
val vertex_attrib3d: index:int -> v0:float -> v1:float -> v2:float -> unit
val vertex_attrib4s: index:int -> v0:int -> v1:int -> v2:int -> v3:int -> unit
val vertex_attrib4d: index:int -> v0:float -> v1:float -> v2:float -> v3:float -> unit

val get_shader_infolog: shader:shader_object -> string
val get_program_infolog: program:shader_program -> string

