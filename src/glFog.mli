(** this module deals with fog generation 
    see sections 3.10 - Fog 
             and 2.7  - Vertex Specification
    of the OpenGL 1.4 specifications
*)

type fog_mode = [`linear|`exp|`exp2]

type coord_src = [`fragment_depth| `fog_coordinate]

type fog_param =
  [ `mode of fog_mode
  | `density of float
  | `start of float
  | `End of float
  | `index of float
  | `color of Gl.rgba
  | `coord_src of coord_src ]
(** fog parameters *)


val fog : [<fog_param] -> unit
(** fog parameters tuning 
    see Fog function in section 3.10
*)

(* OpenGL 1.4+ only *)
val coord : float -> unit
(** fog coordinate 
    see section 2.7 - vertex specification in OpenGL 1.4 specifications
*)
