(* $Id: robot.ml,v 1.2 1998-01-09 13:12:35 garrigue Exp $ *)

class robot () =
  val mutable shoulder = 0
  val mutable elbow = 0

  method elbow_add =
    elbow <- (elbow+5) mod 360
  method elbow_subtract =
    elbow <- (elbow-5) mod 360
  method shoulder_add =
    shoulder <- (shoulder+5) mod 360
  method shoulder_subtract =
    shoulder <- (shoulder-5) mod 360

  method display () =
    Gl.clear [`color];
    Gl.color red:1.0 green:1.0 blue:1.0;

    Gl.push_matrix ();
    Gl.translate x:(-1.0);
    Gl.rotate angle:(float shoulder) z:1.0;
    Gl.translate x:1.0;
    Aux.wire_box width:2.0 height:0.4 depth:1.0;

    Gl.translate x:1.0;
    Gl.rotate angle:(float elbow) z:1.0;
    Gl.translate x:1.0;
    Aux.wire_box width:2.0 height:0.4 depth:1.0;

    Gl.pop_matrix ();
    Gl.flush ()
end

let myinit () =
  Gl.shade_model `flat

let my_reshape :w :h =
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Gl.perspective fovy:65.0 aspect:(float w /. float h) znear:1.0 zfar:20.0;
  Gl.matrix_mode `modelview;
  Gl.load_identity ();
  Gl.translate z:(-5.0)

(*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 *)
let main () =
  Aux.init_display_mode [`single;`rgb;`direct];
  Aux.init_position x:0 y:0 w:400 h:400;
  Aux.init_window title:"Robot";

  myinit ();

  let robot = new robot () in
  Tk.key_down_func
    (fun :key :mode ->
      match key with
	`left ->  robot#shoulder_subtract
      |	`right -> robot#shoulder_add
      |	`up -> robot#elbow_add
      |	`down -> robot#elbow_subtract
      |	_ -> ());
  Aux.reshape_func my_reshape;
  Aux.main_loop display:(robot#display)

let _ = Printexc.print main ()
