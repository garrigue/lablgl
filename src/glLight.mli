(* $Id: glLight.mli,v 1.1 1998-01-29 11:45:49 garrigue Exp $ *)

open Gl

type color_material =
    [ambient ambient_and_diffuse diffuse emission specular]
val color_material : face:face -> color_material -> unit

type fog_param =
  [End(float) color(rgba) density(float) index(float)
   mode([exp exp2 linear]) start(float)]
val fog : fog_param -> unit

type light_param =
  [ambient(rgba) constant_attenuation(float) diffuse(rgba)
   linear_attenuation(float) position(point4) quadratic_attenuation(float)
   specular(rgba) spot_cutoff(float) spot_direction(point4)
   spot_exponent(float)]
val light : num:int -> light_param -> unit

type model_param =
  [ambient(rgba) local_viewer(float) two_side(bool)]
val model : model_param -> unit
    (* glLightModel *)

type material_param =
  [ambient(rgba) ambient_and_diffuse(rgba)
   color_indexes(float * float * float) diffuse(rgba) emission(rgba)
   shininess(float) specular(rgba)]
val material : face:face -> material_param -> unit
