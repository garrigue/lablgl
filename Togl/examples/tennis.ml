(* $Id: tennis.ml,v 1.4 1998-01-23 13:30:24 garrigue Exp $ *)

let ft x = x *. 0.03

let cw = ft (9.0 +. 4.5)
let cl = ft 39.0
let sw = ft 9.0
let sl = ft 21.0
let lw = 0.015 
let wlw = 0.02

class ball () =
  val mutable x = 0.0
  val mutable y = 0.0
  val mutable z = 0.15
  val mutable vel_z = 0.0
  val mutable vel_x = 0.3
  val mutable moving = false

  method set_vel v = vel_x <- v /. 3.6

  method draw =
    Gl.disable `blend;
    Gl.color (1.0, 1.0, 0.0);
    Gl.push_matrix ();
    Gl.translate :x :y :z;
    Glu.sphere radius:0.01 slices:8 stacks:8 (Glu.new_quadric ());
    Gl.pop_matrix ()

  method do_tick delta =
    if moving then begin
      x <- x -. vel_x *. delta;
      z <- z +. vel_z *. delta;
      vel_z <- vel_z -. delta *. 0.98;
      if z <= 0.0 then begin
	vel_z <- -. vel_z *. 0.8;
	z <- -. z
      end
    end;
    moving

  method switch = moving <- not moving; moving
end

class view :togl :ball :setup =
  val togl = togl
  val ball = ball
  val setup = setup

  method draw =
    Togl.make_current togl;
    setup ();

    (* Sky *)
    Gl.shade_model `smooth;
    Gl.disable `depth_test;
    Gl.begin_block `polygon;
    Gl.color (0.0, 0.0, 1.0);
    Gl.vertex3 (2.0, -2.0, 2.0);
    Gl.vertex3 (2.0, 2.0, 2.0);
    Gl.color (0.5, 0.5, 1.0);
    Gl.vertex2 (2.0, 2.0);
    Gl.vertex2 (2.0, -2.0);
    Gl.end_block (); 
   
    Gl.shade_model `flat;

    let square (x1, y1) (x2, y2) =
      List.iter fun:Gl.vertex2
	[ x1, y1;
	  x2, y1;
	  x2, y2;
	  x1, y2 ]
    in
    (* Ground *)
    Gl.begin_block `quads;
    Gl.color (0.5, 0.5, 0.5);
    square (-2.0, 2.0) (2.0, -2.0);
    Gl.end_block ();

    (* Court *)
    Gl.begin_block `quads;
    Gl.color (0.2, 0.7, 0.2);
    square (cl, cw) (-.cl, -.cw);

    (* Lines *)
    Gl.color (1.0, 1.0, 1.0);
    square (-.cl, cw)   (cl, cw -. lw);
    square (-.cl, -.cw)	(cl, -.cw +. lw);
    square (cl, cw)     (cl -. wlw, -. cw);
    square (-.cl, cw)   (-.cl +. wlw, -.cw);
    square (-.sl, lw /. 2.) (sl, -.lw /. 2.);
    square (-.cl, sw)   (cl, sw -. lw);
    square (-.cl, -.sw) (cl, -.sw +. lw);
    square (sl, sw)     (sl -. lw, -. sw);
    square (-.sl, sw)   (-.sl +. lw, -.sw);
    Gl.end_block ();

    (* Net ( translucent ) *)
    Gl.enable `blend;
    Gl.blend_func src:`src_alpha dst:`one_minus_src_alpha;

    Gl.begin_block `quad_strip;
    Gl.color (0.7, 0.7, 0.0) alpha:0.7;
    List.iter fun:(fun (y,z) -> Gl.vertex x:0.0 :y :z)
      [ cw +. 0.05, 0.0;
	cw +. 0.05, 0.115;
	0.0, 0.0;
	0.0, 0.09;
	-.cw -. 0.05, 0.0;
	-.cw -. 0.05, 0.115 ];
    Gl.end_block ();

    ball#draw;
    
    Togl.swap_buffers togl;
    Gl.flush ()
end

let setup3d () =
  Gl.clear [`color;`depth];
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Glu.perspective fovy:40.0 aspect:1.0 z:(0.1,20.0);
  Gl.matrix_mode `modelview;
  Gl.load_identity ();
  Glu.look_at eye:(-1.0, 0.0, 0.2) center:(0.0, 0.0, 0.09) up:(1.0, 0.0, 0.0)

let setup2d () =
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Glu.perspective fovy:45.0 aspect:1.0 z:(0.1,20.0);
  Gl.matrix_mode `modelview;
  Gl.load_identity ();
  Glu.look_at eye:(0.0, 0.0, 3.0) center:(0.0, 0.0, 0.0) up:(1.0, 0.0, 0.0)

open Tk

let main () =
  let top = openTk () in
  Wm.title_set top title:"Tennis Court";

  let f0 = Frame.create parent:top in
  let canvas =
    Togl.create parent:f0 width:600 height:600
      rgba:true double:true depth:true
  and f1 = Frame.create parent:f0 in
  let court2d =
    Togl.create parent:f1 width:200 height:200
      rgba:true double:true depth:true
  and sx =
    Scale.create parent:f1 label:"X Velocity"
      from:0. to:200. orient:`Horizontal
  and start =
    Button.create parent:f1 text:"Start"
  in

  let ball = new ball () in
  let view3d = new view togl:canvas :ball setup:setup3d
  and view2d = new view togl:court2d :ball setup:setup2d
  in

  Scale.configure sx command:(ball#set_vel);
  Button.configure start command:
    begin fun () ->
      Button.configure start text:(if ball#switch then "Stop" else "Start")
    end;
  Togl.timer_func ms:20
    cb:(fun () -> if ball#do_tick 0.002 then (view3d#draw; view2d#draw));
  (* bind top events:[[],`Visibility]
    action:(`Set([],fun _ -> view3d#draw; view2d#draw)); *)
  Togl.display_func canvas cb:(fun () -> view3d#draw);
  Togl.display_func court2d cb:(fun () -> view2d#draw);

  pack [coe court2d; coe sx; coe start];
  pack [coe canvas; coe f1] side:`Left;
  pack [f0] expand:true fill:`Both;
  mainLoop ()

let _ = main ()
