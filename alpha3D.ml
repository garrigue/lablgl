(* $Id: alpha3D.ml,v 1.1 1998-01-08 09:19:09 garrigue Exp $ *)

let myinit () =
  let mat_ambient = 0.0, 0.0, 0.0, 0.15
  and mat_specular = 1.0, 1.0, 1.0, 1.15
  and shininess = 15.0
  in
  Gl.material face:`front param:(`ambient mat_ambient);
  Gl.material face:`front param:(`specular mat_specular);
  Gl.material face:`front param:(`shininess shininess);

  Gl.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test]

let eye_position = ref false

let toggle_eye :x :y =
  eye_position := not !eye_position

let display () =
  let position = 0.0, 0.0, 1.0, 1.0
  and mat_torus = 0.75, 0.75, 0.0, 1.0
  and mat_cylinder = 0.0, 0.75, 0.75, 0.15
  in
  Gl.clear [`color;`depth];
  Gl.light num:0 param:(`position position);
  Gl.push_matrix ();
  if !eye_position then
    Gl.look_at eye:(0.0,0.0,9.0) center:(0.0,0.0,0.0) up:(0.0,1.0,0.0)
  else
    Gl.look_at eye:(0.0,0.0,-9.0) center:(0.0,0.0,0.0) up:(0.0,1.0,0.0);
  Gl.push_matrix ();
  Gl.translate x:0.0 y:0.0 z:1.0;
  Gl.material face:`front param:(`diffuse mat_torus);
  Aux.solid_torus inner:0.275 outer:0.85;
  Gl.pop_matrix ();

  Gl.enable `blend;
  Gl.depth_mask false;
  Gl.blend_func src:`src_alpha dst:`one;
  Gl.material face:`front param:(`diffuse mat_cylinder);
  Gl.translate x:0.0 y:0.0 z:(-1.0);
  Aux.solid_cylinder radius:1.0 height:2.0;
  Gl.depth_mask true;
  Gl.disable `blend;
  Gl.pop_matrix ();

  Gl.flush ()

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Gl.perspective fovy:30.0 aspect:(float w /. float h) znear:1.0 zfar:20.0;
  Gl.matrix_mode `modelview;
  Gl.load_identity ()

let main () =
  Aux.init_display_mode color:`rgb number:`single buffer:[`depth];
  Aux.init_position x:0 y:0 w:500 h:500;
  Aux.init_window title:"Alpha3D";
  Aux.mouse_func button:`left mode:`down fun:toggle_eye;
  Aux.key_func key:`space fun:(fun () -> eye_position := not !eye_position);
  myinit ();
  Aux.reshape_func my_reshape;
  Aux.main_loop :display

let _ = Printexc.print main ()
