(* $Id: glShader.ml,v 1.1 2010-03-11 08:30:02 garrigue Exp $ *)
(* Code contributed by Florent Monnier *)

(** GLSL Shaders *)

type shader_object
type shader_program

external create: shader_type:[`vertex_shader|`fragment_shader] -> shader_object = "ml_glcreateshader"
external delete: shader:shader_object -> unit = "ml_gldeleteshader"
external is_shader: shader:shader_object -> bool = "ml_glisshader"
external source: shader:shader_object  -> string -> unit = "ml_glshadersource"
external compile: shader:shader_object -> unit = "ml_glcompileshader"
external create_program: unit -> shader_program = "ml_glcreateprogram"
external delete_program: program:shader_program -> unit = "ml_gldeleteprogram"
external attach: program:shader_program -> shader:shader_object  -> unit = "ml_glattachshader"
external detach: program:shader_program -> shader:shader_object -> unit = "ml_gldetachshader"
external link_program: program:shader_program -> unit = "ml_gllinkprogram"
external use_program: program:shader_program -> unit = "ml_gluseprogram"
external unuse_program: unit -> unit = "ml_glunuseprogram"
external shader_compile_status: shader:shader_object -> bool = "ml_glgetshadercompilestatus"
external shader_compile_status_exn: shader:shader_object -> unit = "ml_glgetshadercompilestatus_exn"
external get_uniform_location: program:shader_program -> name:string -> int = "ml_glgetuniformlocation"


external get_program_attached_shaders: program:shader_program -> int = "ml_glgetprogram_attached_shaders"
external get_program_active_uniforms: program:shader_program -> int = "ml_glgetprogram_active_uniforms"
external get_program_active_attributes: program:shader_program -> int = "ml_glgetprogram_active_attributes"

external get_program_validate_status: program:shader_program -> bool = "ml_glgetprogram_validate_status"
external get_program_link_status: program:shader_program -> bool = "ml_glgetprogram_link_status"
external get_program_delete_status: program:shader_program -> bool = "ml_glgetprogram_delete_status"


external uniform1f: location:int -> v0:float -> unit = "ml_gluniform1f"
external uniform2f: location:int -> v0:float -> v1:float -> unit = "ml_gluniform2f"
external uniform3f: location:int -> v0:float -> v1:float -> v2:float -> unit = "ml_gluniform3f"
external uniform4f: location:int -> v0:float -> v1:float -> v2:float -> v3:float -> unit = "ml_gluniform4f"
external uniform1i: location:int -> v0:int -> unit = "ml_gluniform1i"
external uniform2i: location:int -> v0:int -> v1:int -> unit = "ml_gluniform2i"
external uniform3i: location:int -> v0:int -> v1:int -> v2:int -> unit = "ml_gluniform3i"
external uniform4i: location:int -> v0:int -> v1:int -> v2:int -> v3:int -> unit = "ml_gluniform4i"


external uniform1fv: location:int -> value:float array -> unit = "ml_gluniform1fv"
external uniform2fv: location:int -> count:int -> value:float array -> unit = "ml_gluniform2fv"
external uniform3fv: location:int -> count:int -> value:float array -> unit = "ml_gluniform3fv"
external uniform4fv: location:int -> count:int -> value:float array -> unit = "ml_gluniform4fv"

external uniform1iv: location:int -> value:int array -> unit = "ml_gluniform1iv"
external uniform2iv: location:int -> count:int -> value:int array -> unit = "ml_gluniform2iv"
external uniform3iv: location:int -> count:int -> value:int array -> unit = "ml_gluniform3iv"
external uniform4iv: location:int -> count:int -> value:int array -> unit = "ml_gluniform4iv"


external uniform_matrix2f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2f"
external uniform_matrix3f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3f"
external uniform_matrix4f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4f"

external uniform_matrix2x3f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2x3f"
external uniform_matrix3x2f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3x2f"

external uniform_matrix2x4f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2x4f"
external uniform_matrix4x2f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4x2f"

external uniform_matrix3x4f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3x4f"
external uniform_matrix4x3f: location:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4x3f"


external uniform_matrix2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2fv"
external uniform_matrix3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3fv"
external uniform_matrix4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4fv"

external uniform_matrix2x3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2x3fv"
external uniform_matrix3x2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3x2fv"

external uniform_matrix2x4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix2x4fv"
external uniform_matrix4x2fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4x2fv"

external uniform_matrix3x4fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix3x4fv"
external uniform_matrix4x3fv: location:int -> count:int -> transpose:bool -> value:float array -> unit = "ml_gluniformmatrix4x3fv"


external get_attrib_location: program:shader_program -> name:string -> int = "ml_glgetattriblocation"
external bind_attrib_location: program:shader_program -> index:int -> name:string -> unit = "ml_glbindattriblocation"


external vertex_attrib1s: index:int -> v:int -> unit = "ml_glvertexattrib1s"
external vertex_attrib1d: index:int -> v:float -> unit = "ml_glvertexattrib1d"
external vertex_attrib2s: index:int -> v0:int -> v1:int -> unit = "ml_glvertexattrib2s"
external vertex_attrib2d: index:int -> v0:float -> v1:float -> unit = "ml_glvertexattrib2d"
external vertex_attrib3s: index:int -> v0:int -> v1:int -> v2:int -> unit = "ml_glvertexattrib3s"
external vertex_attrib3d: index:int -> v0:float -> v1:float -> v2:float -> unit = "ml_glvertexattrib3d"
external vertex_attrib4s: index:int -> v0:int -> v1:int -> v2:int -> v3:int -> unit = "ml_glvertexattrib4s"
external vertex_attrib4d: index:int -> v0:float -> v1:float -> v2:float -> v3:float -> unit = "ml_glvertexattrib4d"

external get_shader_infolog: shader:shader_object -> string = "ml_glgetshaderinfolog"
external get_program_infolog: program:shader_program -> string = "ml_glgetprograminfolog"

