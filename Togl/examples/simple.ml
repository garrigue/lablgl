(* $Id: simple.ml,v 1.9 2000-04-16 12:35:34 garrigue Exp $ *)

open Tk

let main () =
  (* Aux.init_display_mode [`rgb;`single;`depth];
  Aux.init_position ~x:0 ~y:0 ~w:500 ~h:500;
  Aux.init_window ~title:"LablGL"; *)
  let top = openTk () in
  let togl =
    Togl.create ~width:500 ~height:500 ~rgba:true ~depth:true top in
  Wm.title_set top "LablGL";
  pack ~fill:`Both [togl];
  Togl.display_func togl ~cb:
    begin fun () ->
      GlClear.color (0.0, 0.0, 0.0);
      GlClear.clear [`color];
      GlDraw.color (1.0, 1.0, 1.0);
      GlMat.mode `projection;
      GlMat.load_identity ();
      GlMat.ortho ~x:(-1.0,1.0) ~y:(-1.0,1.0) ~z:(-1.0,1.0);
      GlDraw.begins `polygon;
      GlDraw.vertex ~x:(-0.5) ~y:(-0.5) ();
      GlDraw.vertex ~x:(-0.5) ~y:(0.5) ();
      GlDraw.vertex ~x:(0.5) ~y:(0.5) ();
      GlDraw.vertex ~x:(0.5) ~y:(-0.5) ();
      GlDraw.ends ();
      Gl.flush ()
    end;
  ignore (Timer.add ~ms:10000 ~callback:(fun () -> destroy top));
  mainLoop ()

let _ = main ()
