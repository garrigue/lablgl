(* $Id: glLight.mli,v 1.6 2003-03-13 10:15:48 erickt Exp $ *)

open Gl

type color_material =
    [`emission|`ambient|`diffuse|`specular|`ambient_and_diffuse]
val color_material : face:face -> color_material -> unit

type fog_param = [
    `mode of [`linear|`exp|`exp2]
  | `density of float
  | `start of float
  | `End of float
  | `index of float
  | `color of rgba
]
val fog : fog_param -> unit

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
val light : num:int -> light_param -> unit

val light_model : [
    `ambient of rgba
  | `local_viewer of float
  | `two_side of bool
  | `color_control of [`separate_specular_color|`single_color]
] -> unit

type material_param = [
    `ambient of rgba
  | `diffuse of rgba
  | `specular of rgba
  | `emission of rgba
  | `shininess of float
  | `ambient_and_diffuse of rgba
  | `color_indexes of (float * float * float)
]
val material : face:face -> material_param -> unit
