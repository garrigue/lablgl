open Gl

type fog_mode = [`linear|`exp|`exp2]

type coordinate_source = [`fragment_depth| `fog_coordinate]

type fog_param =
  [ `mode of fog_mode
  | `density of float
  | `start of float
  | `End of float
  | `index of float
  | `color of rgba
  | `coordinate_source of coordinate_source ]


external fog : fog_param -> unit = "ml_glFog" "noalloc"

external coord : float -> unit = "ml_glFogCoordd" "noalloc"

