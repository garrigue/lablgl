(* $Id: scene.ml,v 1.1 1998-01-08 09:19:16 garrigue Exp $ *)

(*  Initialize material property and light source.
 *)
let myinit () =
  let light_ambient = 0.0, 0.0, 0.0, 1.0
  and light_diffuse = 1.0, 1.0, 1.0, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 1.0, 1.0, 0.0
  in
  Gl.light num:0 param:(`ambient light_ambient);
  Gl.light num:0 param:(`diffuse light_diffuse);
  Gl.light num:0 param:(`specular light_specular);
  Gl.light num:0 param:(`position light_position);
  
  Gl.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test]

let display () =
  Gl.clear [`color; `depth];

  Gl.push_matrix ();
  Gl.rotate angle:20.0 x:1.0 y:0.0 z:0.0;

  Gl.push_matrix ();
  Gl.translate x:(-0.75) y:0.5 z:0.0; 
  Gl.rotate angle:90.0 x:1.0 y:0.0 z:0.0;
  Aux.solid_torus inner:0.275 outer:0.85;
  Gl.pop_matrix ();

  Gl.push_matrix ();
  Gl.translate x:(-0.75) y:(-0.5) z:0.0; 
  Gl.rotate angle:270.0 x:1.0 y:0.0 z:0.0;
  Aux.solid_cone radius:1.0 height:2.0;
  Gl.pop_matrix ();

  Gl.push_matrix ();
  Gl.translate x:0.75 y:0.0 z:(-1.0); 
  Aux.solid_sphere radius:1.0;
  Gl.pop_matrix ();

  Gl.pop_matrix ();
  Gl.flush ()

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  if w <= h then
    Gl.ortho left:(-2.5) right:2.5
      bottom:(-2.5 *. float h /. float w) top:(2.5 *. float h /. float w)
      near:(-10.0) far:10.0
  else 
    Gl.ortho bottom:(-2.5) top:2.5 left:(-2.5 *. float w /. float h) 
      right:(2.5 *. float w /. float h) near:(-10.0) far:10.0;
  Gl.matrix_mode `modelview

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
let main () =
    Aux.init_display_mode number:`single color:`rgb buffer:[`depth];
    Aux.init_position x:0 y:0 w:500 h:500;
    Aux.init_window title:"Scene";
    myinit ();
    Aux.reshape_func my_reshape;
    Aux.main_loop :display

let _ = Printexc.print main ()
