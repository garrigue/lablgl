(* $Id: sphere.ml,v 1.1 1998-01-07 08:52:35 garrigue Exp $ *)

let display () =
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
  Gl.perspective fovy:60.0 aspect:(float w /. float h) znear:1.0 zfar:1.0;
  Gl.matrix_mode `modelview

let main () =
  Aux.init_display_mode color:`rgba number:`single;
  Aux.init_position x:0 y:0 w:400 h:400;
  Aux.init_window title:"Sphere";
  my_init ();
  Aux.reshape_func my_reshape;
  Aux.main_loop :display

let _ = Printexc.print main ()
