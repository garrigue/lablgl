(* $Id: glLight.ml,v 1.4 1999-11-15 09:55:05 garrigue Exp $ *)

open Gl

type color_material =
    [`emission|`ambient|`diffuse|`specular|`ambient_and_diffuse]
external color_material : face:face -> color_material -> unit
    = "ml_glColorMaterial"

type fog_param = [
    `mode [`linear|`exp|`exp2]
  | `density float
  | `start float
  | `End float
  | `index float
  | `color rgba
]
external fog : fog_param -> unit = "ml_glFog"

type light_param = [
    `ambient rgba
  | `diffuse rgba
  | `specular rgba
  | `position point4
  | `spot_direction point3
  | `spot_exponent float
  | `spot_cutoff float
  | `constant_attenuation float
  | `linear_attenuation float
  | `quadratic_attenuation float
]
external light : num:int -> light_param -> unit
    = "ml_glLight"
type light_model_param =
    [ `ambient rgba | `local_viewer float | `two_side bool ]
external light_model : light_model_param -> unit = "ml_glLightModel"

type material_param = [
    `ambient rgba
  | `diffuse rgba
  | `specular rgba
  | `emission rgba
  | `shininess float
  | `ambient_and_diffuse rgba
  | `color_indexes (float * float * float)
]
external material : face:face -> material_param -> unit
    = "ml_glMaterial"
