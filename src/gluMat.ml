(* $Id: gluMat.ml,v 1.2 2000-04-12 07:40:25 garrigue Exp $ *)

open Gl

external look_at :
    eye:(float * float * float) ->
    center:(float * float * float) ->
    up:(float * float * float) -> unit
    = "ml_gluLookAt"

external ortho2d :
    left:float -> right:float -> bottom:float -> top:float -> unit
    = "ml_gluOrtho2D"
let ortho2d ~x:(left,right) ~y:(bottom,top) =
  ortho2d ~left ~right ~bottom ~top

external perspective :
    fovy:float -> aspect:float -> znear:float -> zfar:float -> unit
    = "ml_gluPerspective"
let perspective ~fovy ~aspect ~z:(znear,zfar) =
  perspective ~fovy ~aspect ~znear ~zfar

external pick_matrix :
    x:float -> y:float -> width:float -> height:float -> unit
    = "ml_gluPickMatrix"

external project : point3 -> point3 = "ml_gluProject"
external unproject : point3 -> point3 = "ml_gluUnProject"
