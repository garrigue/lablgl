(* $Id: planet.ml,v 1.4 1998-01-12 05:20:03 garrigue Exp $ *)

class planet () as self =
  val mutable year = 0
  val mutable day = 0

  method day_add =
    day <- (day + 10) mod 360
  method tick =
    day <- day + 2 mod 360;
    if day mod 10 = 0 then  year <- year + 1
  method day_subtract =
    day <- (day - 10) mod 360
  method year_add =
    year <- (year + 5) mod 360
  method year_subtract =
    year <- (year - 5) mod 360

  method display () =
    Gl.clear [`color;`depth];

    Gl.color red:1.0 green:1.0 blue:1.0;
    Gl.push_matrix();
(*	draw sun	*)
    Gl.material face:`front param:(`specular (1.0,1.0,0.0,1.0));
    Gl.material face:`front param:(`shininess 5.0);
    Aux.solid_sphere radius:1.0;
(*	draw smaller planet	*)
    Gl.rotate angle:(float year) y:1.0;
    Gl.translate x:3.0;
    Gl.rotate angle:(float day) y:1.0;
    Gl.color red:0.0 green:1.0 blue:1.0;
    Gl.shade_model `flat;
    Gl.material face:`front param:(`shininess 128.0);
    Aux.solid_sphere radius:0.2;
    Gl.shade_model `smooth;
    Gl.pop_matrix();
    Gl.flush();
    Gltk.swap_buffers ()
end

let myinit () =
  let light_ambient = 0.5, 0.5, 0.5, 1.0
  and light_diffuse = 1.0, 0.8, 0.2, 1.0
  and light_specular = 1.0, 1.0, 1.0, 1.0
  (*  light_position is NOT default value	*)
  and light_position = 1.0, 0.0, 1.0, 0.0
  in
  Gl.light num:0 param:(`ambient light_ambient);
  Gl.light num:0 param:(`diffuse light_diffuse);
  Gl.light num:0 param:(`specular light_specular);
  Gl.light num:0 param:(`position light_position);
(*  
  Gl.enable `fog;
  Gl.fog (`mode `exp);
  Gl.fog (`density 0.1);
  Gl.fog (`color (0.3,0.3,0.3,1.0));
*)
  Gl.depth_func `less;
  List.iter fun:Gl.enable [`lighting; `light0; `depth_test]
(*  Gl.shade_model `flat *)


let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity();
  Gl.perspective fovy:60.0 aspect:(float w /. float h) znear:1.0 zfar:20.0;
  Gl.matrix_mode `modelview;
  Gl.load_identity();
  Gl.translate z:(-5.0)

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
let main () =
  Aux.init_display_mode [`double;`rgb;`depth];
  Aux.init_position x:0 y:0 w:700 h:500;
  Aux.init_window title:"Planet";

  myinit ();

  let planet = new planet () in
  Gltk.key_down_func
    (fun :key :mode ->
      match key with
	`left ->  planet#year_subtract
      |	`right -> planet#year_add
      |	`up -> planet#day_add
      |	`down -> planet#day_subtract
      |	_ -> Gltk.no_changes ());
(*  Gltk.idle_func (fun () -> planet#tick; planet#display()); *)
  Aux.reshape_func my_reshape;
  Aux.main_loop display:(planet#display)

let _ = Printexc.print main ()
