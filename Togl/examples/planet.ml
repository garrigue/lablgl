(* $Id: planet.ml,v 1.5 1998-01-28 01:44:13 garrigue Exp $ *)

class planet togl as self =
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
    Gl.clear [`color;`depth];

    Gl.color (1.0, 1.0, 1.0);
    Gl.push_matrix();
    Gl.rotate angle:eye x:1.;
(*	draw sun	*)
    Gl.material face:`front (`specular (1.0,1.0,0.0,1.0));
    Gl.material face:`front (`shininess 5.0);
    Glu.sphere radius:1.0 slices:32 stacks:32 (Glu.new_quadric ());
(*	draw smaller planet	*)
    Gl.rotate angle:year y:1.0;
    Gl.translate x:3.0;
    Gl.rotate angle:day y:1.0;
    Gl.color (0.0, 1.0, 1.0);
    Gl.shade_model `flat;
    Gl.material face:`front(`shininess 128.0);
    Glu.sphere radius:0.2 slices:10 stacks:10 (Glu.new_quadric());
    Gl.shade_model `smooth;
    Gl.pop_matrix();
    Gl.flush();
    Togl.swap_buffers togl
end

let myinit () =
  let light_ambient = 0.5, 0.5, 0.5, 1.0
  and light_diffuse = 1.0, 0.8, 0.2, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 1.0, 1.0, 0.0
  in
  Gl.light num:0 (`ambient light_ambient);
  Gl.light num:0 (`diffuse light_diffuse);
  Gl.light num:0 (`specular light_specular);
  Gl.light num:0 (`position light_position);
(*  
  Gl.enable `fog;
  Gl.fog (`mode `exp);
  Gl.fog (`density 0.1);
  Gl.fog (`color (0.3,0.3,0.3,1.0));
*)
  Gl.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test];
  Gl.shade_model `smooth


let my_reshape togl =
  let w = Togl.width togl and h = Togl.height togl in
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity();
  Glu.perspective fovy:60.0 aspect:(float w /. float h) z:(1.0,20.0);
  Gl.matrix_mode `modelview;
  Gl.load_identity();
  Gl.translate z:(-5.0)

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create parent:top width:700 height:500 double:true rgba:true
      depth:true in
  Wm.title_set top title:"Planet";

  myinit ();

  let planet = new planet togl in
  let scale =
    Scale.create parent:top from:(-45.) to:45. orient:`Vertical
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
      |	"Escape" -> destroy top
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
