#load"unix.cma";;

open Jitter


let check_gl_errors place =
  match Gl.get_error () with
      `no_error -> ()
    | x         -> Gl.raise_error place

  
let pi = acos (-1.)

let accFrustum (x,y,w,h) (left,right) (bottom,top) (near,far) 
    (pixdx,pixdy) (eyedx,eyedy) focus =
  let xwsize = right -. left
  and ywsize = top -. bottom in
  let dx = -.(pixdx *. xwsize /. (float w) +. eyedx *. near /.focus)
  and dy = -.(pixdy *. ywsize /. (float h) +. eyedy *. near /.focus) in
  GlMat.mode `projection;
  GlMat.load_identity ();
  GlMat.frustum (left +. dx, right +. dx) (bottom +. dy, top +. dy) (near, far);
  GlMat.mode `modelview;
  GlMat.load_identity ();
  GlMat.translate3 (-.eyedx, -.eyedy, 0.0)

    
let accPerspective viewport fovy aspect (near,far) 
    (pixdx,pixdy) (eyedx,eyedy) focus =
  let fov2 = ((fovy*.pi) /. 180.0) /. 2.0 in
  let top = near /. ((cos fov2) /. (sin fov2)) in
  let bottom = -.top
  and right = top *. aspect in
  let left = -.right in
  accFrustum viewport (left, right) (bottom, top) (near, far)
    (pixdx, pixdy) (eyedx, eyedy) focus

let init () = 
  let ambient  = ( 0.0, 0.0, 0.0, 1.0 )
  and diffuse  = ( 1.0, 1.0, 1.0, 1.0 )
  and specular = ( 1.0, 1.0, 1.0, 1.0 )
  and position = ( 0.0, 3.0, 3.0, 0.0 )
  and lmodel_ambient = ( 0.2, 0.2, 0.2, 1.0 )
  and local_view = false in

  GlLight.light 0 (`ambient ambient);
  GlLight.light 0 (`diffuse diffuse);
  GlLight.light 0 (`position position);
  
  GlLight.light_model (`ambient lmodel_ambient);
  GlLight.light_model (`local_viewer local_view);

  GlDraw.front_face `cw;
  List.iter Gl.enable [
    `lighting;
    `light0;
    `auto_normal;
    `normalize;
    `depth_test 
  ];
  GlClear.color ~alpha:1.0 (0.0, 0.0, 0.0);
  GlClear.accum ~alpha:1.0 (0.0, 0.0, 0.0);
  GlDraw.shade_model `smooth;
  GlDraw.color (1.0, 1.0, 1.0)

class teapot pos amb dif spec shine =
object(self)

  val mutable angle = 0.0

  method render () =
    GlMat.push ();
    GlMat.translate3 pos;
    GlLight.material `front (`ambient amb);
    GlLight.material `front (`diffuse dif);
    GlLight.material `front (`specular spec);
    GlLight.material `front (`shininess (shine*.128.0));
    Glut.solidTeapot 0.5; 
    GlMat.pop ()

end

class scene =
object(self)
  
  val teapots = List.map (fun (pos,amb,dif,spec,shine) -> new teapot pos amb dif spec shine) [
    (-1.1, -0.5, -4.5),
    (0.1745, 0.01175, 0.01175, 1.0),
    (0.61424, 0.04136, 0.04136, 1.0),
    (0.727811, 0.626959, 0.626959, 1.0), 0.6;
    (-0.5, -0.5, -5.0),
    (0.24725, 0.1995, 0.0745, 1.0), 
    (0.75164, 0.60648, 0.22648, 1.0),
    (0.628281, 0.555802, 0.366065, 1.0), 0.4;
    (0.2, -0.5, -5.5),
    (0.19225, 0.19225, 0.19225, 1.0),
    (0.50754, 0.50754, 0.50754, 1.0),
    (0.508273, 0.508273, 0.508273, 1.0), 0.4;
    (1.0, -0.5, -6.0),
    (0.0215, 0.1745, 0.0215, 1.0),
    (0.07568, 0.61424, 0.07568, 1.0),
    (0.633, 0.727811, 0.633, 1.0), 0.6;
    (1.8, -0.5, -6.5),
    (0.0, 0.1, 0.06, 1.0),
    (0.0, 0.50980392, 0.50980392, 1.0),
    (0.50196078, 0.50196078, 0.50196078, 1.0), 0.25;
  ]

  val mutable viewport = (0,0,0,0)

  val mutable cam_pos = (0.0,0.0,0.0)

  method render jitter (x,y,w,h) = 
    let jx, jy = j16.(jitter) in
    accPerspective viewport 45.0 ((float w) /. (float h)) (1.0, 15.0) (10., 10.) (0.33*.jx,0.33*.jy) 5.0;
    (* ruby, gold, silver, emerald, and cyan teapots *)
    GlMat.translate3 (0., 0., -0.);
    List.iter (fun teapot -> teapot#render ()) teapots

  method display () =
    GlClear.clear [`accum];
    for jitter = 0 to 15 do
      GlClear.clear [`color ; `depth];
      self#render jitter viewport;
      GlFunc.accum ~op:`accum 0.125;
    done;
    GlFunc.accum ~op:`return 1.0;
    Gl.flush();
    Glut.swapBuffers ()

  method reshape ~w ~h =
    Printf.fprintf stderr "reshape (%d, %d)\n" w h;
    viewport <- (0,0,w,h);
    GlDraw.viewport ~x:0 ~y:0 ~w ~h

end

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
let main () =
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~double_buffer:true ~depth:true ~accum:true ();
  Glut.initWindowSize ~w:700 ~h:500;
  ignore(Glut.createWindow "Depth of Field");
  init ();
  let scene = new scene in
  Glut.specialFunc ~cb:(fun ~key ~x ~y -> 
    match key with
      | _ -> ());
  Glut.keyboardFunc ~cb:(fun ~key ~x ~y -> 
    match key with
      |	27(*esc*) -> exit 0
      | _ -> ());
  let rec _timedUpdate ~value =
    Glut.postRedisplay();
    Glut.timerFunc ~ms:20 ~cb:_timedUpdate ~value:0
  in
  Glut.timerFunc ~ms:20 ~cb:_timedUpdate ~value:0; 
  Glut.displayFunc ~cb:scene#display;
  Glut.reshapeFunc ~cb:scene#reshape;
  Glut.mainLoop ()
    
let _ = Printexc.print main ()
