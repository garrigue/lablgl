(* $Id: sphere.ml,v 1.3 1998-01-09 13:12:37 garrigue Exp $ *)

let display () =
  Gl.clear_color red:0.0 green:0.0 blue:0.0;
  Gl.clear [`color];
  Gl.color red:1. green:1. blue:1.;
  Gl.push_matrix ();
  Gl.translate x:0.0 y:0.0 z:(-5.0);
  Aux.wire_sphere radius:1.0;
  Gl.pop_matrix ();
  Gl.flush ()

let my_init () = Gl.shade_model `flat

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Gl.perspective fovy:60.0 aspect:(float w /. float h) znear:1.0 zfar:20.0;
  Gl.matrix_mode `modelview

let main () =
  Aux.init_display_mode color:`rgb number:`single;
  Aux.init_position x:0 y:0 w:400 h:400;
  Aux.init_window title:"Sphere";
  my_init ();
  Aux.reshape_func my_reshape;
  Aux.main_loop :display

let _ = Printexc.print main ()
