(* $Id: glLight.mli,v 1.4 1999-11-15 09:55:05 garrigue Exp $ *)

open Gl

type color_material =
    [`emission|`ambient|`diffuse|`specular|`ambient_and_diffuse]
val color_material : face:face -> color_material -> unit

type fog_param = [
    `mode [`linear|`exp|`exp2]
  | `density float
  | `start float
  | `End float
  | `index float
  | `color rgba
]
val fog : fog_param -> unit

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
val light : num:int -> light_param -> unit

val light_model : [`ambient rgba|`local_viewer float|`two_side bool] -> unit

type material_param = [
    `ambient rgba
  | `diffuse rgba
  | `specular rgba
  | `emission rgba
  | `shininess float
  | `ambient_and_diffuse rgba
  | `color_indexes (float * float * float)
]
val material : face:face -> material_param -> unit
