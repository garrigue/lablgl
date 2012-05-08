
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

val fog : [<fog_param] -> unit

val coord : float -> unit
