(* $Id: double.ml,v 1.5 1999-11-15 14:32:17 garrigue Exp $ *)

class view togl :title = object (self)
  val mutable corner_x = 0.
  val mutable corner_y = 0.
  val mutable corner_z = 0.
  val font_base = Togl.load_bitmap_font togl font:`fixed_8x13
  val mutable x_angle = 0.
  val mutable y_angle = 0.
  val mutable z_angle = 0.

  method togl = togl

  method reshape =
    let width = Togl.width togl and height = Togl.height togl in
    let aspect = float width /. float height in
    GlDraw.viewport x:0 y:0 w:width h:height;
    (* Set up projection transform *)
    GlMat.mode `projection;
    GlMat.load_identity ();
    GlMat.frustum x:(-.aspect, aspect) y:(-1.0, 1.0) z:(1.0, 10.0);
    corner_x <- -. aspect;
    corner_y <- -1.0;
    corner_z <- -1.1;
    (* Change back to model view transform for rendering *)
    GlMat.mode `modelview

  method print_string s =
    GlList.call_lists base:font_base(`byte s) 

  method display =
    GlClear.clear [`color;`depth];
    GlMat.load_identity(); (* Reset modelview matrix to the identity matrix *)
    GlMat.translate z:(-3.0) ();      (* Move the camera back three units *)
    GlMat.rotate x:1. x_angle;  (* Rotate by X, Y, Z angles *)
    GlMat.rotate y:1. y_angle;
    GlMat.rotate z:1. z_angle;
    
    Gl.enable `depth_test;

    (* Front face *)
    GlDraw.begins `quads;
    GlDraw.color (0.0, 0.7, 0.1);	(* Green *)
    GlDraw.vertex3 (-1.0, 1.0, 1.0);
    GlDraw.vertex3(1.0, 1.0, 1.0);
    GlDraw.vertex3(1.0, -1.0, 1.0);
    GlDraw.vertex3(-1.0, -1.0, 1.0);
    (* Back face *)
    GlDraw.color (0.9, 1.0, 0.0);   (* Yellow *)
    GlDraw.vertex3(-1.0, 1.0, -1.0);
    GlDraw.vertex3(1.0, 1.0, -1.0);
    GlDraw.vertex3(1.0, -1.0, -1.0);
    GlDraw.vertex3(-1.0, -1.0, -1.0);
    (* Top side face *)
    GlDraw.color (0.2, 0.2, 1.0);   (* Blue *)
    GlDraw.vertex3(-1.0, 1.0, 1.0);
    GlDraw.vertex3(1.0, 1.0, 1.0);
    GlDraw.vertex3(1.0, 1.0, -1.0);
    GlDraw.vertex3(-1.0, 1.0, -1.0);
    (* Bottom side face *)
    GlDraw.color (0.7, 0.0, 0.1);   (* Red *)
    GlDraw.vertex3(-1.0, -1.0, 1.0);
    GlDraw.vertex3(1.0, -1.0, 1.0);
    GlDraw.vertex3(1.0, -1.0, -1.0);
    GlDraw.vertex3(-1.0, -1.0, -1.0);
    GlDraw.ends();
   
    Gl.disable `depth_test;
    GlMat.load_identity();
    GlDraw.color( 1.0, 1.0, 1.0 );
    GlPix.raster_pos x:corner_x y:corner_y z:corner_z ();
    self#print_string title;
    Togl.swap_buffers togl

  method x_angle a = x_angle <- a; Togl.render togl
  method y_angle a = y_angle <- a; Togl.render togl
  method z_angle a = z_angle <- a; Togl.render togl
end

let create_view :parent :double =
  new view
    (Togl.create :parent width:200 height:200 depth:true rgba:true :double ())

open Tk

let main () =
  let top = openTk () in
  let f = Frame.create parent:top () in
  let single = create_view parent:f double:false title:"Single buffer"
  and double = create_view parent:f double:true title:"Double buffer" in
  let sx =
    Scale.create parent:top label:"X Axis" from:0. to:360. orient:`Horizontal
      command:(fun x -> single#x_angle x; double#x_angle x) ()
  and sy =
    Scale.create parent:top label:"Y Axis" from:0. to:360. orient:`Horizontal
      command:(fun y -> single#y_angle y; double#y_angle y) ()
  and button =
    Button.create parent:top text:"Quit" command:(fun () -> destroy top) ()
  in

  List.iter fun:
    (fun o ->
      Togl.display_func o#togl cb:(fun () -> o#display);
      Togl.reshape_func o#togl cb:(fun () -> o#reshape);
      bind o#togl events:[[`Button1],`Motion] action:
	(`Set([`MouseX;`MouseY], fun ev ->
	  let width = Togl.width o#togl
	  and height =Togl.height o#togl
	  and x = ev.ev_MouseX
	  and y = ev.ev_MouseY in
	  let x_angle = 360. *. float y /. float height
	  and y_angle = 360. *. float (width - x) /. float width in
	  Scale.set to:x_angle sx;
	  Scale.set to:y_angle sy)))
    [single;double];

  pack side:`Left padx:(`Pix 3) pady:(`Pix 3) fill:`Both expand:true
    [single#togl; double#togl];
  pack fill:`Both expand:true [f];
  pack fill:`X [coe sx; coe sy; coe button];
  mainLoop ()

let _ = main ()
