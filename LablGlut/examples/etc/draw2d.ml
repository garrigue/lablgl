(* 

  draw2d : barebones sketch program by Issac Trotts

*)

open Printf;;

type v2 = { x : float; y : float };;

let endl = print_newline;;

class pwlcurve pts = 
  object
    val mutable pts = (pts : v2 list)
    method draw =
      GlDraw.begins `line_strip;
      List.iter (fun v -> 
        GlDraw.vertex2 (v.x, v.y)
        ) pts;
      GlDraw.ends ();

    method add_point p = pts <- p :: pts

    method print = printf "curve with %i points" (List.length pts); endl()

  end

class app = 
  object(self)
    val xlo = 0.0
    val xhi = 1.0
    val ylo = 0.0
    val yhi = 1.0
    val mutable npixx = 300
    val mutable npixy = 300
    val mutable ldown = false
    val mutable curves = ([] : pwlcurve list)
    val mutable cur_curve = (None : pwlcurve option)

    method reshape ~w ~h=
      GlDraw.viewport ~x:0 ~y:0 ~w ~h;
      GlMat.mode `projection;
      GlMat.load_identity();
      GlMat.ortho (xlo,xhi) (ylo,yhi) (-1.0,1.0); 
      GlMat.mode `modelview;
      GlMat.load_identity();
      npixx <- w;
      npixy <- h;

    method display =
      GlClear.clear [`color];
      GlDraw.color (0.8, 0.8, 0.8);
      List.iter (fun c -> c#draw) curves;
      GlDraw.color (0.9, 0.0, 0.0);
      begin match cur_curve with None -> () | Some c -> c#draw; end;
      Gl.flush();
      Glut.swapBuffers()

    method keyboard ~key ~x ~y =
      match (char_of_int key) with 'q' -> exit 0 | _ -> ()

    method motion ~x ~y =
      if ldown then begin self#add_point x y; Glut.postRedisplay() end

    method add_point x y =
      let p = { x = xlo +. ((float)x)/. float_of_int(npixx) *. (xhi -. xlo);
                y = yhi -. ((float)y)/. float_of_int(npixy) *. (yhi -. ylo) } in 
      let c = match cur_curve with 
        | None -> failwith "curve is none" 
        | Some c -> c in
      c#add_point p;

    method mouse ~button ~state ~x ~y =
      match button with 
      | Glut.LEFT_BUTTON -> (* left button *)
          begin
            ldown <- (state = Glut.DOWN );
            match state with 
            | Glut.DOWN -> 
              begin
                cur_curve <- Some(new pwlcurve []);
                self#add_point x y 
              end
            | Glut.UP -> 
              match cur_curve with 
              | None -> failwith "cur_curve is None"
              | Some c -> 
                begin
                  curves <- c :: curves;
                  Glut.postRedisplay();
                end
          end
      | _ -> (); (* other buttons have no effect *)

    initializer
      Glut.initWindowSize npixx npixy ;
      Glut.initWindowPosition 100 100 ;
      ignore(Glut.createWindow  "draw2d");
      GlDraw.shade_model `flat;
      GlClear.color (0.0, 0.0, 0.0);
      Glut.displayFunc (fun () -> self#display);
      Glut.reshapeFunc (fun ~w ~h -> self#reshape ~w ~h);
      Glut.keyboardFunc (fun ~key ~x ~y -> self#keyboard ~key ~x ~y);
      Glut.mouseFunc (fun ~button ~state ~x ~y -> self#mouse ~button ~state
        ~x ~y);
      Glut.motionFunc (fun ~x ~y -> self#motion ~x ~y);
      Glut.postRedisplay();
      Glut.mainLoop () ;
  end

let main() = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~double_buffer:true ~depth:false (); 
  ignore(new app);;

main();;

