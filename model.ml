(* $Id: model.ml,v 1.2 1998-01-09 13:12:34 garrigue Exp $ *)

let draw_triangle () =
  Glm.block mode:`line_loop
    [ `vertex2(0.0, 25.0);
      `vertex2(25.0, -25.0);
      `vertex2(-25.0, -25.0) ]

let display () =
  Gl.clear_color red:0.0 green:0.0 blue:0.0;
  Gl.clear [`color];

  Gl.load_identity ();
  Gl.color red:1.0 green:1.0 blue:1.0;
  draw_triangle ();

  Gl.enable `line_stipple;
  Gl.line_stipple factor:1 pattern:0xf0f0;
  Gl.load_identity ();
  Gl.translate x:(-10.) y:0. z:0.;
  draw_triangle ();

  Gl.line_stipple factor:1 pattern:0x8888;
  Gl.load_identity ();
  Gl.rotate angle:90. x:0. y:0. z:1.;
  draw_triangle ();
  Gl.disable `line_stipple;
  
  Gl.flush ()

let my_init () =
  Gl.shade_model `flat

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  let r = float h /. float w in
  if w <= h then
    Gl.ortho left:(-50.) right:50.
      bottom:(-50. *. r) top:(50. *. r)
      near:(-1.) far:1.
  else
    Gl.ortho bottom:(-50.) top:50.
      left:(-50. /. r) right:(50. /. r)
      near:(-1.) far:1.;
  Gl.matrix_mode `modelview

let main () =
  Aux.init_display_mode [`single;`rgb];
  Aux.init_position x:0 y:0 w:500 h:500;
  Aux.init_window title:"Model";
  my_init ();
  Aux.reshape_func my_reshape;
  my_reshape w:500 h:500;
  Aux.main_loop :display

let _ = Printexc.print main ()
