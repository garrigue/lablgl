(* $Id: glLight.ml,v 1.5 2000-04-03 02:57:41 garrigue Exp $ *)

open Gl

type color_material =
    [`emission|`ambient|`diffuse|`specular|`ambient_and_diffuse]
external color_material : face:face -> color_material -> unit
    = "ml_glColorMaterial"

type fog_param = [
    `mode of [`linear|`exp|`exp2]
  | `density of float
  | `start of float
  | `End of float
  | `index of float
  | `color of rgba
]
external fog : fog_param -> unit = "ml_glFog"

type light_param = [
    `ambient of rgba
  | `diffuse of rgba
  | `specular of rgba
  | `position of point4
  | `spot_direction of point3
  | `spot_exponent of float
  | `spot_cutoff of float
  | `constant_attenuation of float
  | `linear_attenuation of float
  | `quadratic_attenuation of float
]
external light : num:int -> light_param -> unit
    = "ml_glLight"
type light_model_param =
    [ `ambient of rgba | `local_viewer of float | `two_side of bool ]
external light_model : light_model_param -> unit = "ml_glLightModel"

type material_param = [
    `ambient of rgba
  | `diffuse of rgba
  | `specular of rgba
  | `emission of rgba
  | `shininess of float
  | `ambient_and_diffuse of rgba
  | `color_indexes of (float * float * float)
]
external material : face:face -> material_param -> unit
    = "ml_glMaterial"
