(* $Id: glLight.mli,v 1.3 1998-04-22 04:08:20 garrigue Exp $ *)

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
   specular(rgba) spot_cutoff(float) spot_direction(point3)
   spot_exponent(float)]
val light : num:int -> light_param -> unit

val light_model : [ambient(rgba) local_viewer(float) two_side(bool)] -> unit

type material_param =
  [ambient(rgba) ambient_and_diffuse(rgba)
   color_indexes(float * float * float) diffuse(rgba) emission(rgba)
   shininess(float) specular(rgba)]
val material : face:face -> material_param -> unit
