(* $Id: gluMat.mli,v 1.1 1998-01-29 11:46:06 garrigue Exp $ *)

open Gl

val look_at :
  eye:point3 -> center:point3 -> up:vect3 -> unit

val ortho2d : x:float * float -> y:float * float -> unit

val perspective : fovy:float -> aspect:float -> z:float * float -> unit

val pick_matrix :
  x:float -> y:float -> width:float -> height:float -> unit

val project : point3 -> point3
val unproject : point3 -> point3
