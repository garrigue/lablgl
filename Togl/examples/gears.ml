(* $Id: gears.ml,v 1.4 1998-01-28 06:30:22 garrigue Exp $ *)

(*
 * 3-D gear wheels.  This program is in the public domain.
 *
 * Brian Paul
 * LablGL version by Jacques Garrigue
 *)

let pi = acos (-1.)

(*
 * Draw a gear wheel.  You'll probably want to call this function when
 * building a display list since we do a lot of trig here.
 *
 * Input:  inner_radius - radius of hole at center
 *         outer_radius - radius at center of teeth
 *         width - width of gear
 *         teeth - number of teeth
 *         tooth_depth - depth of tooth
 *)
let gear :inner :outer :width :teeth :tooth_depth =
  let r0 = inner
  and r1 = outer -. tooth_depth /. 2.0
  and r2 = outer +. tooth_depth /. 2.0 in

  let ta = 2.0 *. pi /. float teeth in
  let da = ta /. 4.0 in

  Gl.shade_model `flat;

  Gl.normal z:1.0;

  let vertex :i :r :z ?:s [< 0 >] =
    let angle = float i *. ta +. float s *. da in
    Gl.vertex x:(r *. cos angle) y:(r *. sin angle) :z
  in

  (* draw front face *)
  let z = width *. 0.5 in
  Gl.begin_block `quad_strip;
  for i=0 to teeth do
    vertex :i r:r0 :z;
    vertex :i r:r1 :z;
    vertex :i r:r0 :z;
    vertex :i r:r1 :z s:3;
  done;
  Gl.end_block ();
  
  (* draw front sides of teeth *)
  Gl.begin_block `quads;
  for i=0 to teeth - 1 do
    vertex :i r:r1 :z;
    vertex :i r:r2 s:1 :z;
    vertex :i r:r2 s:2 :z;
    vertex :i r:r1 s:3 :z;
  done;
  Gl.end_block ();

  Gl.normal z:(-1.0);

  (* draw back face *)
  let z = -. width *. 0.5 in
  Gl.begin_block `quad_strip;
  for i=0 to teeth do
    vertex :i r:r1 :z;
    vertex :i r:r0 :z;
    vertex :i r:r1 s:3 :z;
    vertex :i r:r0 :z;
  done;
  Gl.end_block ();

  (* draw back sides of teeth *)
  Gl.begin_block `quads;
  for i=0 to teeth - 1 do
    vertex :i r:r1 s:3 :z;
    vertex :i r:r2 s:2 :z;
    vertex :i r:r2 s:1 :z;
    vertex :i r:r1 :z;
  done;
  Gl.end_block ();

  (* draw outward faces of teeth *)
  let z = width *. 0.5 and z' = width *. (-0.5) in
  Gl.begin_block `quad_strip;
  for i=0 to teeth - 1 do
    let angle = float i *. ta in
    vertex :i r:r1 :z;
    vertex :i r:r1 z:z';
    let u = r2 *. cos(angle+.da) -. r1 *. cos(angle)
    and v = r2 *. sin(angle+.da) -. r1 *. sin(angle) in
    Gl.normal x:v y:(-.u);
    vertex :i r:r2 s:1 :z;
    vertex :i r:r2 s:1 z:z';
    Gl.normal x:(cos angle) y:(sin angle);
    vertex :i r:r2 s:2 :z;
    vertex :i r:r2 s:2 z:z';
    let u = r1 *. cos(angle +. 3. *. da) -. r2 *. cos(angle +. 2. *. da)
    and v = r1 *. sin(angle +. 3. *. da) -. r2 *. sin(angle +. 2. *. da) in
    Gl.normal x:v y:(-.u);
    vertex :i r:r1 s:3 :z;
    vertex :i r:r1 s:3 z:z';
    Gl.normal x:(cos angle) y:(sin angle);
  done;
  vertex i:0 r:r1 :z;
  vertex i:0 r:r1 z:z';
  Gl.end_block ();

  Gl.shade_model `smooth;

  (* draw inside radius cylinder *)
  Gl.begin_block `quad_strip;
  for i=0 to teeth do
    let angle = float i *. ta in
    Gl.normal x:(-. cos angle) y:(-. sin angle);
    vertex :i r:r0 z:z';
    vertex :i r:r0 :z;
  done;
  Gl.end_block ()

class view :togl :gear1 :gear2 :gear3 ?:limit as self =
  val togl = togl
  val gear1 = gear1
  val gear2 = gear2
  val gear3 = gear3
  val limit = match limit with None -> 0 | Some n -> n
  val mutable view_rotx = 0.0
  val mutable view_roty = 0.0
  val mutable view_rotz = 0.0
  val mutable angle = 0.0
  val mutable count = 1

  method rotx a = view_rotx <- a
  method roty a = view_roty <- a

  method draw =
    Gl.clear [`color;`depth];

    Gl.push_matrix ();
    Gl.rotate angle:view_rotx x:1.0;
    Gl.rotate angle:view_roty y:1.0;
    Gl.rotate angle:view_rotz z:1.0;

    Gl.push_matrix ();
    Gl.translate x:(-3.0) y:(-2.0);
    Gl.rotate :angle z:1.0;
    (* gear inner:1.0 outer:4.0 width:1.0 teeth:20 tooth_depth:0.7; *)
    Gl.call_list gear1;
    Gl.pop_matrix ();

    Gl.push_matrix ();
    Gl.translate x:3.1 y:(-2.0);
    Gl.rotate angle:(-2.0 *. angle -. 9.0) z:1.0;
    (* gear inner:0.5 outer:2.0 width:2.0 teeth:10 tooth_depth:0.7; *)
    Gl.call_list gear2;
    Gl.pop_matrix ();

    Gl.push_matrix ();
    Gl.translate x:(-3.1) y:4.2;
    Gl.rotate angle:(-2.0 *. angle -. 25.0) z:1.0;
    (* gear inner:1.3 outer:2.0 width:0.5 teeth:10 tooth_depth:0.7; *)
    Gl.call_list gear3;
    Gl.pop_matrix ();

    Gl.pop_matrix ();
    
    Togl.swap_buffers togl;

    count <- count + 1;
    if count =limit then exit 0

  method idle =
    angle <- angle +. 2.0;
    self#draw

  method reshape =
    let w = Togl.width togl and h = Togl.height togl in
    Gl.viewport x:0 y:0 :w :h;
    Gl.matrix_mode `projection;
    Gl.load_identity ();
    let r = float w /. float h in
    let r' = 1. /. r in
    if (w>h) then
      Gl.frustum x:(-. r,r) y:(-1.0,1.0) z:(5.0,60.0)
    else
      Gl.frustum x:(-1.0,1.0) y:(-.r',r') z:(5.0,60.0);

    Gl.matrix_mode `modelview;
    Gl.load_identity();
    Gl.translate z:(-40.0);
    Gl.clear[`color;`depth]
end

let init () =
  let pos = 5.0, 5.0, 10.0, 0.0
  and red = 0.8, 0.1, 0.0, 1.0
  and green = 0.0, 0.8, 0.2, 1.0
  and blue = 0.2, 0.2, 1.0, 1.0 in

  Gl.light num:0 (`position pos);
  List.iter fun:Gl.enable
    [`cull_face;`lighting;`light0;`depth_test;`normalize];

  (* make the gears *)
  let make_gear :inner :outer :width :teeth :color =
    let list = Gl.gen_lists 1 in
    Gl.new_list list mode:`compile;
    Gl.material face:`front (`ambient_and_diffuse color);
    gear :inner :outer :width :teeth tooth_depth:0.7;
    Gl.end_list ();
    list
  in
  let gear1 = make_gear inner:1.0 outer:4.0 width:1.0 teeth:20 color:red
  and gear2 = make_gear inner:0.5 outer:2.0 width:2.0 teeth:10 color:green
  and gear3 = make_gear inner:1.3 outer:2.0 width:0.5 teeth:10 color:blue in

  (gear1, gear2, gear3)

open Tk

let main () =
  let top = openTk () in
  let f = Frame.create parent:top in
  let v = Textvariable.create () in
  let my_scale =
    Scale.create from:0. to:180. showvalue:false
      highlightbackground:`Black in
  let togl =
    Togl.create parent:f width:300 height:300
      rgba:true depth:true double:true
  and sh = my_scale parent:f orient:`Horizontal
  and sv = my_scale parent:top orient:`Vertical
  in
  
  Wm.title_set top title:"Gears";

  let gear1, gear2, gear3 = init() in
  let view = new view :togl :gear1 :gear2 :gear3 in
  Scale.configure sv command:(view#rotx);
  Scale.configure sh command:(view#roty);
  Scale.set sh to:20.; Scale.set sv to:40.;
  Togl.reshape_func togl cb:(fun () -> view#reshape);
  Togl.display_func togl cb:(fun () -> view#draw);
  Togl.timer_func ms:20 cb:(fun () -> view#idle);
  pack [sv] side:`Right fill:`Y;
  pack [f] expand:true fill:`Both;
  pack [togl] side:`Top expand:true fill:`Both;
  pack [sh] side:`Bottom fill:`X;
  Tk.mainLoop ()

let _ = main ()
