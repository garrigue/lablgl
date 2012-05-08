(* some vector maths *)

let pi = acos (-1.)

let dot (x1,y1,z1,w1) (x2,y2,z2,w2) = 
  (x1 *. x2 +. y1 *. y2 +. z1 *. z2) /. (w1 *. w2)

let dot3 (x1,y1,z1) (x2,y2,z2) = 
  x1 *. x2 +. y1 *. y2 +. z1 *. z2

let cross (x1,y1,z1,w1) (x2,y2,z2,w2) = 
  (
    y1 *. z2 -. z1 *. y2,
    z1 *. x2 -. x1 *. z2,
    x1 *. y2 -. y1 *. x2,
    w1 *. w2
  )

let cross3 (x1,y1,z1) (x2,y2,z2) = 
  ( y1 *. z2 -. z1 *. y2,
    z1 *. x2 -. x1 *. z2,
    x1 *. y2 -. y1 *. x2 )

let vadd (x1,y1,z1) (x2,y2,z2) = 
  ( x1 +. x2, y1 +. y2, z1 +. z2)

let vsub (x1,y1,z1) (x2,y2,z2) = 
  ( x1 -. x2, y1 -. y2, z1 -. z2)

let rotate_x (x,y,z) a = 
  let ca = cos a
  and sa = sin a in
  ( x, ca *. y +. sa *. z, -.sa *. y -. ca *. z )

let rotate_y (x,y,z) a =
  let ca = cos a
  and sa = sin a in
  ( ca *. x -. sa *. z, y, -.sa *. x +. ca *. z )

let rotate_z (x,y,z) a =
  let ca = cos a
  and sa = sin a in
  ( ca *. x +. sa *. y, -.sa *. x +. ca *. y, z )

(*
let vmat_mul m (x,y,z,w) = 
  let dot m = 
    (m 0) *. x +. (m 1) *. y +. (m 2) *. z  +. (m 3) *. w
  in
  (dot (fun i -> m.(i).(0)), dot (fun i -> m.(i).(1)), dot (fun i -> m.(i).(2)), m.(3).(3))
*)
let vmat_mul m (x,y,z,w) = 
  let dot m = 
    (m 0) *. x +. (m 1) *. y +. (m 2) *. z  +. (m 3) *. w 
  in
  (dot (fun i -> m.(i).(0)), dot (fun i -> m.(i).(1)), dot (fun i -> m.(i).(2)), m.(3).(3))

let guard f msg = 
  try 
    f () 
  with e -> prerr_endline msg; exit 0

let dot v1 v2 = guard (fun () -> dot v1 v2) "dot"

let cross v1 v2 = guard (fun () -> cross v1 v2) "cross"

let vadd v1 v2 = guard (fun () -> vadd v1 v2) "vadd"

let vsub v1 v2 = guard (fun () -> vsub v1 v2) "vsub"

let rotate_x v a = guard (fun () -> rotate_x v a) "rotate_x"
let rotate_y v a = guard (fun () -> rotate_y v a) "rotate_y"
let rotate_z v a = guard (fun () -> rotate_z v a) "rotate_z"
  
let vmat_mul m v = guard (fun () -> vmat_mul m v) "vmat_mul"
  
let normalize (x,y,z,w) = 
  let f = 1. /. (sqrt (dot (x,y,z,w) (x,y,z,w))) in
  ( x *. f , y *. f , z *. f, 1.0 )
    
let normalize3 (x,y,z) = 
  let f = 1. /. (sqrt (dot3 (x,y,z) (x,y,z))) in
  ( x *. f , y *. f , z *. f )


(* ---------------- *)

let normal4 (x,y,z,w) = 
  let fact = 1. /. w in
  GlDraw.normal3 (x *. fact, y *. fact, z *. fact)
