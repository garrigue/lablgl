(* $Id: tesselate.ml,v 1.1 2004-07-13 07:55:18 garrigue Exp $ *)

open Tk

let top = openTk()
let togl =
  Togl.create top ~width:500 ~height:500 ~rgba:true ~depth:true ~double:true

let () =
  Wm.title_set top "LablGL";
  pack ~fill:`Both [togl];
  Togl.display_func togl ~cb:
      begin fun () ->
        GlClear.color (0.0, 0.0, 0.0);
        GlClear.clear [`color];
        GlDraw.color (1.0, 1.0, 1.0);
        GlMat.mode `projection;
        GlMat.load_identity ();
        GlMat.ortho ~x:(-1.0,2.0) ~y:(-1.0,2.0) ~z:(-1.0,2.0);
        GluTess.tesselate
          [[0.,0.,0.;1.,0.,0.;1.,1.,0.;0.,1.,0.];
           [0.2,0.2,0.;0.2,0.8,0.;0.8,0.8,0.;0.8,0.2,0.]];
        Gl.flush ();
        Togl.swap_buffers togl
      end;
  mainLoop()
