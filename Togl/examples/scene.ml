(* $Id: scene.ml,v 1.4 1998-01-28 01:44:13 garrigue Exp $ *)

(*  Initialize material property and light source.
 *)
let myinit () =
  let light_ambient = 0.0, 0.0, 0.0, 1.0
  and light_diffuse = 1.0, 1.0, 1.0, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 1.0, 1.0, 0.0
  in
  Gl.light num:0 (`ambient light_ambient);
  Gl.light num:0 (`diffuse light_diffuse);
  Gl.light num:0 (`specular light_specular);
  Gl.light num:0 (`position light_position);
  
  Gl.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test]

let pi = acos (-1.)

let solid_torus :inner :outer =
  let slices = 32 and faces = 16 in
  let slice_angle = 2.0 *. pi /. float slices
  and face_angle = 2.0 *. pi /. float faces in
  let vertex :i :j =
    let angle1 = slice_angle *. float i
    and angle2 = face_angle *. float j in
    Gl.normal x:(cos angle1 *. cos angle2)
      y:(-. sin angle1 *. cos angle2)
      z:(sin angle2);
    Gl.vertex
      x:((outer +. inner *. cos angle2) *. cos angle1)
      y:(-. (outer +. inner *. cos angle2) *. sin angle1)
      z:(inner *. sin angle2)
  in
  Gl.begin_block `quads;
  for i = 0 to slices - 1 do
    for j = 0 to faces - 1 do
      vertex :i :j;
      vertex i:(i+1) :j;
      vertex i:(i+1) j:(j+1);
      vertex :i j:(j+1);
    done
  done;
  Gl.end_block ()

let solid_cone :radius :height =
  Glu.cylinder base:radius top:0. :height slices:15 stacks:10
    (Glu.new_quadric ())

let solid_sphere :radius =
  Glu.sphere :radius slices:32 stacks:32 (Glu.new_quadric ())

let display () =
  Gl.clear [`color; `depth];

  Gl.push_matrix ();
  Gl.rotate angle:20.0 x:1.0;

  Gl.push_matrix ();
  Gl.translate x:(-0.75) y:0.5; 
  Gl.rotate angle:90.0 x:1.0;
  solid_torus inner:0.275 outer:0.85;
  Gl.pop_matrix ();

  Gl.push_matrix ();
  Gl.translate x:(-0.75) y:(-0.5); 
  Gl.rotate angle:270.0 x:1.0;
  solid_cone radius:1.0 height:2.0;
  Gl.pop_matrix ();

  Gl.push_matrix ();
  Gl.translate x:0.75 z:(-1.0); 
  solid_sphere radius:1.0;
  Gl.pop_matrix ();

  Gl.pop_matrix ();
  Gl.flush ()

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  if w <= h then
    Gl.ortho x:(-2.5,2.5) z:(-10.0,10.0)
      y:(-2.5 *. float h /. float w, 2.5 *. float h /. float w)
  else 
    Gl.ortho y:(-2.5,2.5) z:(-10.0,10.0)
      x:(-2.5 *. float w /. float h, 2.5 *. float w /. float h);
  Gl.matrix_mode `modelview

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)

open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create parent:top rgba:true depth:true width:500 height:500 in
  Wm.title_set top title:"Scene";
  myinit ();
  Togl.reshape_func togl
    cb:(fun () -> my_reshape w:(Togl.width togl) h:(Togl.height togl));
  Togl.display_func togl cb:display;
  pack [togl] expand:true fill:`Both;
  mainLoop ()

let _ = Printexc.print main ()
