(* $Id: planet.ml,v 1.11 1999-11-23 17:18:19 garrigue Exp $ *)

class planet togl = object (self)
  val togl = togl
  val mutable year = 0.0
  val mutable day = 0.0
  val mutable eye = 0.0
  val mutable time = 0.0

  method tick new_time =
    if time = 0. then time <- new_time else
    let diff = new_time -. time in
    time <- new_time;
    day <- mod_float (day +. diff *. 200.) 360.0;
    year <- mod_float (year +. diff *. 20.) 360.0
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
    GlMat.rotate angle:eye x:1. ();
(*	draw sun	*)
    GlLight.material face:`front (`specular (1.0,1.0,0.0,1.0));
    GlLight.material face:`front (`shininess 5.0);
    GluQuadric.sphere radius:1.0 slices:32 stacks:32 ();
(*	draw smaller planet	*)
    GlMat.rotate angle:year y:1.0 ();
    GlMat.translate () x:3.0;
    GlMat.rotate angle:day y:1.0 ();
    GlDraw.color (0.0, 1.0, 1.0);
    GlDraw.shade_model `flat;
    GlLight.material face:`front(`shininess 128.0);
    GluQuadric.sphere radius:0.2 slices:10 stacks:10 ();
    GlDraw.shade_model `smooth;
    GlMat.pop ();
    Gl.flush ();
    Togl.swap_buffers togl
end

let myinit () =
  let light_ambient = 0.5, 0.5, 0.5, 1.0
  and light_diffuse = 1.0, 0.8, 0.2, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 1.0, 1.0, 0.0
  in
  List.iter fun:(GlLight.light num:0)
    [ `ambient light_ambient; `diffuse light_diffuse;
      `specular light_specular; `position light_position ];
  GlFunc.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test];
  GlDraw.shade_model `smooth


let my_reshape togl =
  let w = Togl.width togl and h = Togl.height togl in
  GlDraw.viewport x:0 y:0 :w :h;
  GlMat.mode `projection;
  GlMat.load_identity();
  GluMat.perspective fovy:60.0 aspect:(float w /. float h) z:(1.0,20.0);
  GlMat.mode `modelview;
  GlMat.load_identity();
  GlMat.translate () z:(-5.0)

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create top width:700 height:500 double:true rgba:true
      depth:true in
  Wm.title_set top title:"Planet";

  myinit ();

  let planet = new planet togl in
  let scale =
    Scale.create top from:(-45.) to:45. orient:`Vertical
      command:(planet#eye) showvalue:false highlightbackground:`Black in
  bind togl events:[[],`Enter] action:(`Set([],fun _ -> Focus.set togl));
  bind scale events:[[],`Enter] action:(`Set([],fun _ -> Focus.set scale));
  bind togl events:[[],`KeyPress]
    action:(`Set([`KeySymString], fun ev ->
      begin match ev.ev_KeySymString with
	"Left" ->  planet#year_subtract
      |	"Right" -> planet#year_add
      |	"Up" -> planet#day_add
      |	"Down" -> planet#day_subtract
      |	"Escape" -> destroy top; exit 0
      |	_ -> ()
      end;
      planet#display));
  Togl.timer_func ms:20
    cb:(fun () -> planet#tick (Unix.gettimeofday()); planet#display);
  Togl.display_func togl cb:(fun () -> planet#display);
  Togl.reshape_func togl cb:(fun () -> my_reshape togl);
  my_reshape togl;
  pack [togl] side:`Left expand:true fill:`Both;
  pack [scale] side:`Right fill:`Y;
  Focus.set togl;
  mainLoop ()

let _ = Printexc.print main ()
