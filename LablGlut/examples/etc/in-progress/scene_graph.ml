#!/usr/bin/env lablglut

(* 
   scene_graph.ml : a functional scene graph demo 

   Copyright (c) 2002 Issac Trotts.  This program can be distributed and 
   modified as long as this message comes with it.

   08aug02 : wrote

TODO:
  - draw bounding boxes
  - add trackball

*)

open Printf;;

(* ==== types ==== *)
type point_t = { px:float; py:float; pz:float }

type vec_t = { vx:float; vy:float; vz:float }

type frame_t = { e1:vec_t; e2:vec_t; e3:vec_t }

(* affine frame *)
type aframe_t = { orig:point_t; frame:frame_t }

type camera_t = {
  (* frame:aframe_t; *)
  pos:point_t
  up:vec_t
  center:point_t  (* focus point: where we're looking *)
  fovy:float;
  znear:float;
  zfar:float;
  }

(* functional node.  lets you put in any code for a node *)
type fnode_t = {
  render:(camera_t->unit);
  (* bounds:(unit->box_t) *)
  }

type node_t = 
  | Empty 
  | FNode of fnode_t 
  ;;

let separator nodes = 
  let render camera = 
    GlMat.push();
    Array.iter (fun n->match n with | Empty -> () | FNode fn -> fn.render cam);
    GlMat.pop() in
  FNode { render=render; }

let translation ?(x=0.0) ?(y=0.0) ?(z=0.0) () = 
  FNode { render = (fun cam->GlMat.translate ~x ~y ~z ()) } ;;


(* ==== file-global data *)

let the_cam = { 
  pos = { px=0.0; py=0.0; pz=0.0 };
  up = { vx=0.0; vy=1.0; vz=0.0 };
  center = { px= 0.0; py= 0.0; pz = -1.0; }
  fovy = 45; 
  znear = 1.0;
  zfar = 1000.0;
};;

let the_scene = separator [|
  
|];;

(*
type box_t = {
  lo:point_t ;
  hi:point_t 
  }
*)

(* let expand_b_p b p = { lo=pmin b.lo p; hi=pmax b.hi p; };; *)

(* let expand_b_b b1 b2 = { lo= *)


let tea_node () = 
  let lo = { px = -1.0; py = -1.0; pz = -1.0 }
  and hi = { px=1.0; py=1.0; pz=1.0 } in
  FNode { render=(fun cam -> Glut.solidTeapot 1.0);
          (* bounds=(fun () -> { lo=lo; hi=hi; } )  *)
          }
  ;;

let display () = 
  GlClear.clear [`color;`depth];

  Glut.solidTeapot 1.0;
  
  Glut.swapBuffers();
  ;;

let idle() = 
  ()
  ;; (* ... *)

let reshape ~w ~h =
  GlDraw.viewport ~x:0 ~y:0 ~w:w ~h:h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  let r = float w /. float h in
  let r' = 1. /. r in
  GluMat.perspective ~fovy:45.0 ~aspect:1.0 ~z:(1.0, 10.0) ;

  GlMat.mode `modelview;
  GlMat.load_identity();
  GlMat.translate ~z:(-6.0) ();
  GlMat.rotate ~angle:25.0 ~x:1.0  ~y:0.0  ~z:0.0 ();
  GlMat.rotate ~angle:25.0 ~x:0.0  ~y:1.0  ~z:0.0 ();
  GlClear.clear[`color;`depth]
  ;;

let special ~key ~x ~y =
  let delta = 5.0 in
  let redisp = ref true in 
  match key with 
  (*
    | Glut.KEY_LEFT  -> view#roty (-. delta) ; 
    | Glut.KEY_RIGHT -> view#roty delta ;
    | Glut.KEY_DOWN  -> view#rotx (-. delta) ; 
    | Glut.KEY_UP  -> view#rotx delta ;
    *)
    | _ -> begin 
      redisp := false; 
    end;
  if !redisp then Glut.postRedisplay ();
  ;;

let keyboard ~key ~x ~y = 
  match (char_of_int key) with 
    | 'q' -> exit 0; 
    | _ -> ()
  ;;

let init () =
  let pos = 5.0, 5.0, -10.0, 1.0
  and green = 0.0, 0.8, 0.2, 1.0 in
  GlLight.light ~num:0 (`position pos);
  GlLight.light ~num:0 (`diffuse green);
  List.iter Gl.enable [`lighting;`light0;`depth_test]; 
  ;;

let main () =
  ignore (Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~double_buffer:true ~depth:true () ;
  Glut.initWindowSize ~w:300 ~h:300;
  ignore (Glut.createWindow ~title:"scene graph demo");

  init ();
  Glut.keyboardFunc ~cb:keyboard ;
  Glut.reshapeFunc ~cb:reshape ;
  Glut.displayFunc ~cb:display ;
  Glut.idleFunc ~cb:idle ;
  Glut.specialFunc ~cb:special ;
  Glut.mainLoop();
  ;;

let _ = main ()

