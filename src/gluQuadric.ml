(* $Id: gluQuadric.ml,v 1.1 1998-01-29 11:46:11 garrigue Exp $ *)

type t

external create : unit -> t = "ml_gluNewQuadric"

external cylinder :
    t -> base:float -> top:float -> height:float ->
    slices:int -> stacks:int -> unit
    = "ml_gluCylinder_bc" "ml_gluCylinder"
let cylinder :base :top :height :slices :stacks ?:quad [< create () >] =
  cylinder :base :top :height :slices :stacks quad

external disk :
    t -> inner:float -> outer:float -> slices:int -> loops:int -> unit
    = "ml_gluDisk"
let disk :inner :outer :slices :loops ?:quad [< create () >] =
  disk :inner :outer :slices :loops quad

external partial_disk :
    t -> inner:float -> outer:float ->
    slices:int -> loops:int -> start:float -> sweep:float -> unit
    = "ml_gluPartialDisk_bc" "ml_gluPartialDisk"
let partial_disk :inner :outer :slices :loops
    :start :sweep ?:quad [< create () >] =
  partial_disk :inner :outer :slices :loops :start :sweep quad

external draw_style : t -> [fill line silhouette point] -> unit
    = "ml_gluQuadricDrawStyle"
external normals : t -> [none flat smooth] -> unit
    = "ml_gluQuadricNormals"
external orientation : t -> [inside outside] -> unit
    = "ml_gluQuadricOrientation"
external texture : t -> bool -> unit
    = "ml_gluQuadricTexture"

external sphere : t -> radius:float -> slices:int -> stacks:int -> unit
    = "ml_gluSphere"
let sphere :radius :slices :stacks ?:quad [< create () >] =
  sphere :radius :slices :stacks quad
