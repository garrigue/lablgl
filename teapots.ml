(* $Id: teapots.ml,v 1.1 1998-01-08 09:19:18 garrigue Exp $ *)

let myinit () =
  let ambient = 0.0, 0.0, 0.0, 1.0
  and diffuse = 1.0, 1.0, 1.0, 1.0
  and specular = 1.0, 1.0, 1.0, 1.0
  and position = 0.0, 3.0, 3.0, 0.0 in

  let lmodel_ambient = 0.2, 0.2, 0.2, 1.0
  and local_view = 0.0 in

  List.iter fun:(fun param -> Gl.light num:0 :param)
    [`ambient ambient; `diffuse diffuse; `position position];
  Gl.light_model (`ambient lmodel_ambient);
  Gl.light_model (`local_viewer local_view);

  Gl.front_face `cw;
  List.iter fun:Gl.enable
    [ `lighting;
      `light0;
      `auto_normal;
      `normalize;
      `depth_test ];
  Gl.depth_func `less

let render_teapot :x :y amb:(ambr,ambg,ambb) :shine
    dif:(difr,difg,difb) spec:(specr,specg,specb) =
  Gl.push_matrix ();
  Gl.translate :x :y z:0.0;
  List.iter fun:(fun param -> Gl.material face:`front :param)
    [ `ambient (ambr, ambg, ambb, 0.0);
      `diffuse (difr,difg,difb, 0.0);
      `specular (specr,specg,specb, 0.0);
      `shininess shine ];
  Aux.solid_teapot size:1.0;
  Gl.pop_matrix ()

(*  First column:  emerald, jade, obsidian, pearl, ruby, turquoise
 *  2nd column:  brass, bronze, chrome, copper, gold, silver
 *  3rd column:  black, cyan, green, red, white, yellow plastic
 *  4th column:  black, cyan, green, red, white, yellow rubber
 *)

let display () =
  Gl.clear [`color; `depth];
  render_teapot x:2.0 y:17.0 amb:(0.0215, 0.1745, 0.0215) shine:0.6
    dif:(0.07568, 0.61424, 0.07568) spec:(0.633, 0.727811, 0.633);
  render_teapot x:2.0 y:14.0 amb:(0.135, 0.2225, 0.1575)
    dif:(0.54, 0.89, 0.63) spec:(0.316228, 0.316228, 0.316228) shine:0.1;
  render_teapot x:2.0 y:11.0 amb:(0.05375, 0.05, 0.06625)
    dif:(0.18275, 0.17, 0.22525) spec:(0.332741, 0.328634, 0.346435) shine:0.3;
  render_teapot x:2.0 y:8.0 amb:(0.25, 0.20725, 0.20725)
    dif:(1.0, 0.829, 0.829) spec:(0.296648, 0.296648, 0.296648) shine:0.088;
  render_teapot x:2.0 y:5.0 amb:(0.1745, 0.01175, 0.01175) shine:0.6
    dif:(0.61424, 0.04136, 0.04136) spec:(0.727811, 0.626959, 0.626959);
  render_teapot x:2.0 y:2.0 amb:(0.1, 0.18725, 0.1745)
    dif:(0.396, 0.74151, 0.69102) spec:(0.297254, 0.30829, 0.306678) shine:0.1;
  render_teapot x:6.0 y:17.0 amb:(0.329412, 0.223529, 0.027451)
    dif:(0.780392, 0.568627, 0.113725) spec:(0.992157, 0.941176, 0.807843)
    shine:0.21794872;
  render_teapot x:6.0 y:14.0 amb:(0.2125, 0.1275, 0.054)
    dif:(0.714, 0.4284, 0.18144) spec:(0.393548, 0.271906, 0.166721) shine:0.2;
  render_teapot x:6.0 y:11.0 amb:(0.25, 0.25, 0.25) dif:(0.4, 0.4, 0.4)
    spec:(0.774597, 0.774597, 0.774597) shine:0.6;
  render_teapot x:6.0 y:8.0 amb:(0.19125, 0.0735, 0.0225) shine:0.1
    dif:(0.7038, 0.27048, 0.0828) spec:(0.256777, 0.137622, 0.086014);
  render_teapot x:6.0 y:5.0 amb:(0.24725, 0.1995, 0.0745) shine:0.4
    dif:(0.75164, 0.60648, 0.22648) spec:(0.628281, 0.555802, 0.366065);
  render_teapot x:6.0 y:2.0 amb:(0.19225, 0.19225, 0.19225) shine:0.4
    dif:(0.50754, 0.50754, 0.50754) spec:(0.508273, 0.508273, 0.508273);
  render_teapot x:10.0 y:17.0 amb:(0.0, 0.0, 0.0) dif:(0.01, 0.01, 0.01)
    spec:(0.50, 0.50, 0.50) shine:0.25;
  render_teapot x:10.0 y:14.0 amb:(0.0, 0.1, 0.06)
    dif:(0.0, 0.50980392, 0.50980392)
    spec:(0.50196078, 0.50196078, 0.50196078) shine:0.25;
  render_teapot x:10.0 y:11.0 amb:(0.0, 0.0, 0.0) dif:(0.1, 0.35, 0.1)
    spec:(0.45, 0.55, 0.45) shine:0.25;
  render_teapot x:10.0 y:8.0 amb:(0.0, 0.0, 0.0) dif:(0.5, 0.0, 0.0)
    spec:(0.7, 0.6, 0.6) shine:0.25;
  render_teapot x:10.0 y:5.0 amb:(0.0, 0.0, 0.0) dif:(0.55, 0.55, 0.55)
    spec:(0.70, 0.70, 0.70) shine:0.25;
  render_teapot x:10.0 y:2.0 amb:(0.0, 0.0, 0.0) dif:(0.5, 0.5, 0.0)
    spec:(0.60, 0.60, 0.50) shine:0.25;
  render_teapot x:14.0 y:17.0 amb:(0.02, 0.02, 0.02) dif:(0.01, 0.01, 0.01)
    spec:(0.4, 0.4, 0.4) shine:0.078125;
  render_teapot x:14.0 y:14.0 amb:(0.0, 0.05, 0.05) dif:(0.4, 0.5, 0.5)
    spec:(0.04, 0.7, 0.7) shine:0.078125;
  render_teapot x:14.0 y:11.0 amb:(0.0, 0.05, 0.0) dif:(0.4, 0.5, 0.4)
    spec:(0.04, 0.7, 0.04) shine:0.078125;
  render_teapot x:14.0 y:8.0 amb:(0.05, 0.0, 0.0) dif:(0.5, 0.4, 0.4)
    spec:(0.7, 0.04, 0.04) shine:0.078125;
  render_teapot x:14.0 y:5.0 amb:(0.05, 0.05, 0.05) dif:(0.5, 0.5, 0.5)
    spec:(0.7, 0.7, 0.7) shine:0.078125;
  render_teapot x:14.0 y:2.0 amb:(0.05, 0.05, 0.0) dif:(0.5, 0.5, 0.4)
    spec:(0.7, 0.7, 0.04) shine:0.078125;
  Gl.flush ()

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  if w <= w then
    Gl.ortho left:0.0 right:16.0 bottom:0.0 top:(16.0 *. float h /. float w)
      near:(-10.0) far:10.0
  else
    Gl.ortho left:0.0 right:(16.0 *. float w /. float h)
      bottom:16.0 top:0.0 near:(-10.0) far:10.0;
  Gl.matrix_mode `modelview

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
let main () =
    Aux.init_display_mode number:`single color:`rgb buffer:[`depth];
    Aux.init_position x:0 y:0 w:500 h:500;
    Aux.init_window title:"Teapots";
    myinit ();
    Aux.reshape_func my_reshape;
    Aux.main_loop :display

let _ = Printexc.print main ()
