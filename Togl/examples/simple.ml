(* $Id: simple.ml,v 1.3 1998-01-15 08:34:42 garrigue Exp $ *)

open Tk

let main () =
  (* Aux.init_display_mode [`rgb;`single;`depth];
  Aux.init_position x:0 y:0 w:500 h:500;
  Aux.init_window title:"LablGL"; *)
  let top = openTk () in
  let togl =
    Togl.create parent:top width:500 height:500 rgba:true depth:true in
  Wm.title_set top title:"LablGL";
  pack [togl] fill:`Both;
  Togl.display_func togl cb:
    begin fun () ->
      Gl.clear_color (0.0, 0.0, 0.0);
      Gl.clear [`color];
      Gl.color (1.0, 1.0, 1.0);
      Gl.matrix_mode `projection;
      Gl.load_identity ();
      Gl.ortho left:(-1.) right:1. bottom:(-1.) top:1. near:(-1.) far:1.;
      Gl.begin_block `polygon;
      Gl.vertex x:(-0.5) y:(-0.5);
      Gl.vertex x:(-0.5) y:(0.5);
      Gl.vertex x:(0.5) y:(0.5);
      Gl.vertex x:(0.5) y:(-0.5);
      Gl.end_block ();
      Gl.flush ()
    end;
  Timer.add ms:10000 callback:(fun () -> destroy top);
  mainLoop ()

let _ = Printexc.print main ()
