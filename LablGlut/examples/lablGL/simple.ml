(* $Id: simple.ml,v 1.1 2003-09-25 13:54:10 raffalli Exp $ *)

(* open Tk *)

let main () =
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~depth:true () ;
  Glut.initWindowSize ~w:500 ~h:500 ;
  ignore(Glut.createWindow ~title:"lablglut & LablGL");
  Glut.displayFunc ~cb:
    begin fun () -> (* display callback *)
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
  (* ignore (Timer.add ~ms:10000 ~callback:(fun () -> exit 0));  *)
  Glut.mainLoop();
  ;;

let _ = main ()

