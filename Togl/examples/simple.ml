(* $Id: simple.ml,v 1.1 1998-01-07 08:52:34 garrigue Exp $ *)

let main () =
  Aux.init_display_mode color:`rgba number:`single buffer:[`depth];
  Aux.init_position x:0 y:0 w:500 h:500;
  Aux.init_window title:"LablGL";
  Gl.clear_color red:0. green:0. blue:0. alpha:0.;
  Gl.clear [`color];
  Gl.color red:1. green:1. blue:1.;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Gl.ortho left:(-2.) right:2. bottom:(-2.) top:2. near:(-2.) far:2.;
  Gl.begin_block `polygon;
  Gl.vertex x:(-0.5) y:(-0.5);
  Gl.vertex x:(-0.5) y:(0.5);
  Gl.vertex x:(0.5) y:(0.5);
  Gl.vertex x:(0.5) y:(-0.5);
  Gl.end_block ();
  Gl.flush ()

let _ = Printexc.print main (); Unix.sleep 10
