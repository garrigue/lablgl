(* $Id: glLight.ml,v 1.7 2003-04-24 16:42:59 erickt Exp $ *)

open Gl

type color_material =
    [`emission|`ambient|`diffuse|`specular|`ambient_and_diffuse]
external color_material : face:[<face] -> [<color_material] -> unit
    = "ml_glColorMaterial"

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
external light : num:int -> [<light_param] -> unit
    = "ml_glLight"

type color_control = [`separate_specular_color|`single_color]
    
type light_model_param = 
  [ `ambient of rgba 
  | `local_viewer of bool 
  | `two_side of bool 
  | `color_control of color_control ]

external light_model : [<light_model_param] -> unit = "ml_glLightModel"

type material_param = [
    `ambient of rgba
  | `diffuse of rgba
  | `specular of rgba
  | `emission of rgba
  | `shininess of float
  | `ambient_and_diffuse of rgba
  | `color_indexes of (float * float * float)
]
external material : face:[<face] -> [<material_param] -> unit
    = "ml_glMaterial"
