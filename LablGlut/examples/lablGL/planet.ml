(* $Id: planet.ml,v 1.1 2003-09-25 13:54:10 raffalli Exp $ *)
(* converted to lablglut by Issac Trotts on July 25, 2002 *)

#load"unix.cma";;

class planet = object (self)
  val mutable year = 0.0
  val mutable day = 0.0
  val mutable eye = 0.0
  val mutable time = 0.0

  method tick new_time =
    if time = 0. then time <- new_time else
    let diff = new_time -. time in
    time <- new_time;
    day <- mod_float (day +. diff *. 200.) 360.0;
    year <- mod_float (year +. diff *. 20.) 360.0;

  method day_add =
    day <- mod_float (day +. 10.0) 360.0
  method day_subtract =
    day <- mod_float (day -. 10.0) 360.0
  method year_add =
    year <- mod_float (year +. 5.0) 360.0
  method year_subtract =
    year <- mod_float (year -. 5.0) 360.0
  method eye x =
    eye <- x; self#display

  method display =
    GlClear.clear [`color;`depth];

    GlDraw.color (1.0, 1.0, 1.0);
    GlMat.push();
    GlMat.rotate ~angle:eye ~x:1. ();
(*	draw sun	*)
    GlLight.material ~face:`front (`specular (1.0,1.0,0.0,1.0));
    GlLight.material ~face:`front (`shininess 5.0);
    GluQuadric.sphere ~radius:1.0 ~slices:32 ~stacks:32 ();
(*	draw smaller planet	*)
    GlMat.rotate ~angle:year ~y:1.0 ();
    GlMat.translate () ~x:3.0;
    GlMat.rotate ~angle:day ~y:1.0 ();
    GlDraw.color (0.0, 1.0, 1.0);
    GlDraw.shade_model `flat;
    GlLight.material ~face:`front(`shininess 128.0);
    GluQuadric.sphere ~radius:0.2 ~slices:10 ~stacks:10 ();
    GlDraw.shade_model `smooth;
    GlMat.pop ();
    Gl.flush ();
    Glut.swapBuffers (); 
end

let myinit () =
  let light_ambient = 0.5, 0.5, 0.5, 1.0
  and light_diffuse = 1.0, 0.8, 0.2, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 1.0, 1.0, 0.0
  in
  List.iter (GlLight.light ~num:0)
    [ `ambient light_ambient; `diffuse light_diffuse;
      `specular light_specular; `position light_position ];
  GlFunc.depth_func `less;
  List.iter Gl.enable [`lighting; `light0; `depth_test];
  GlDraw.shade_model `smooth


let my_reshape ~w ~h  =
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  GlMat.mode `projection;
  GlMat.load_identity();
  GluMat.perspective ~fovy:60.0 ~aspect:(float w /. float h) ~z:(1.0,20.0);
  GlMat.mode `modelview;
  GlMat.load_identity();
  GlMat.translate () ~z:(-5.0)

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)

let main () =
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~double_buffer:true ~depth:true ();
  Glut.initWindowSize ~w:700 ~h:500;
  ignore(Glut.createWindow "Planet");

  myinit ();

  let planet = new planet in
  (*
  let scale =
    Scale.create top ~min:(-45.) ~max:45. ~orient:`Vertical
      ~command:(planet#eye) ~showvalue:false ~highlightbackground:`Black in
  *)
  (*
  bind togl ~events:[`Enter] ~action:(fun _ -> Focus.set togl);
  bind scale ~events:[`Enter] ~action:(fun _ -> Focus.set scale);
  bind togl ~events:[`KeyPress] ~fields:[`KeySymString]
  *)
  Glut.specialFunc ~cb:(fun ~key ~x ~y -> match key with
	  | Glut.KEY_LEFT ->  planet#year_subtract
      |	Glut.KEY_RIGHT -> planet#year_add
      |	Glut.KEY_UP -> planet#day_add
      |	Glut.KEY_DOWN -> planet#day_subtract
      |	_ -> ();
      planet#display);
  Glut.keyboardFunc ~cb:(fun ~key ~x ~y -> match key with
      |	27(*esc*) -> exit 0
      | _ -> ());
  (*Glut.timerFunc ~ms:20
    ~cb:(fun ~value -> planet#tick (Unix.gettimeofday()); planet#display) ~value:0;*)
  let rec _timedUpdate ~value = 
      planet#tick (Unix.gettimeofday()); 
      Glut.postRedisplay();
      Glut.timerFunc ~ms:20 ~cb:_timedUpdate ~value:0
      in
  Glut.timerFunc ~ms:20 ~cb:_timedUpdate ~value:0; 
  Glut.displayFunc ~cb:(fun () -> planet#display);
  Glut.reshapeFunc ~cb:my_reshape;
  my_reshape ~w:700 ~h:500;
  Glut.mainLoop ()

let _ = Printexc.print main ()
