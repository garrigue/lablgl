(* This program was written by Yasuhiko Minamide, nan@kurims.kyoto-u.ac.jp *)
(* $Id: tennis.ml,v 1.17 2001-05-08 01:58:26 garrigue Exp $ *)

open StdLabels

let image_height = 64
and image_width = 64

let make_image () =
  let image =
    GlPix.create `ubyte ~width:image_width ~height:image_height ~format:`rgba in
  for i = 0 to image_width - 1 do
    for j = 0 to image_height - 1 do
      Raw.sets (GlPix.to_raw image) ~pos:(4*(i*image_height+j))
        (if (((i land 6 ) = 6) or ((j land 6) = 6)) 
         then [|0;0;0;255|]
         else [|255;255;255;0|])
    done
  done;
  image



let image_height = 256
and image_width = 256


let make_image2 () =
  let on_circle (x0,y0) (x,y) = 
    let d = (x -. x0) *. (x -. x0) +. (y -. y0) *. (y -. y0)  in
    ((d > 0.9 *. 0.9) && (d < 1.1 *. 1.1))  in

  let on_line (x,y) =
  if x <= -.2.0 then on_circle (-. 2.0, 0.0) (x,y) 
  else if x >= 2.0 then on_circle (2.0, 0.0) (x,y)  		       
  else ((0.9 < y) && (y < 1.1)) || ((-1.1 <= y) && ( y <= -0.9)) in

  let on_white (i,j) =
    let x = (float (i - 128) /. 128.0) *. 6.0 in
    let y = (float (j - 128) /. 128.0) *. 2.0 in
    on_line (x,y) in
	
  let image =
    GlPix.create `ubyte ~width:image_width ~height:image_height ~format:`rgb in
  for i = 0 to image_width - 1 do
    for j = 0 to image_height - 1 do
      Raw.sets (GlPix.to_raw image) ~pos:(3*(i*image_height+j))
        (if on_white (j,i)
         then [|255;255;255|]
         else [|255;255;0|])
    done
  done;
  image



let ft x = x *. 0.03

let cw = ft (9.0 +. 4.5)
let cl = ft 39.0
let sw = ft 9.0
let sl = ft 21.0
let lw = 0.015 
let wlw = 0.02

let square (x1, y1) (x2, y2) =
  List.iter ~f:GlDraw.vertex2
    [ x1, y1;
      x2, y1;
      x2, y2;
      x1, y2 ]

let collide ~pos ~vel ~plane ~func =
  let between (a,b,x) = 
    let (a,b) = if a > b then (b,a) else (a,b) in
    (x > a) && (x < b) in
  let (xpos,ypos,zpos) = pos in
  let (dx,dy,dz) = vel in
  if dx = 0.0 then (xpos, ypos +. dy,  zpos +. dz) else
  let ((x1,y1,z1),(x2,y2,z2)) = plane in
  let y = if dy = 0.0 then ypos else (dy /. dx) *. (x1 -. xpos) +. ypos in
  let z = if dz = 0.0 then zpos else (dz /. dx) *. (x1 -. xpos) +. zpos in
  if between (y1, y2, y) && between (z1, z2, z) && between (xpos, xpos +. dx, x1) 
    then begin func (); (x1, y, z) end 
  else (xpos +. dx, ypos +. dy,  zpos +. dz)
  


class ball () = object (self)
  val mutable x = 0.0
  val mutable y = 0.0
  val mutable z = 0.2
  val mutable target_x = 0.0
  val mutable target_y = 0.0
  val mutable velocity = 0.0
  val mutable angle_z = 0.0
  val mutable vel_z = 0.0
  val mutable vel_y = 0.0
  val mutable vel_x = 0.0
  val mutable moving = false

  val image = make_image2 () 


  method set_vel v = velocity <- v /. 36.0; 

  method set_velz v = angle_z <- v

  method reset = ()

  method draw =
    Gl.disable `blend;
    GlDraw.color (1.0, 1.0, 0.0);
    GlMat.push ();
    GlMat.translate ~x ~y ~z ();
    GluQuadric.sphere ~radius:0.01 ~slices:8 ~stacks:8 ();
    GlMat.pop () 

  method drawtexture =
    let q = GluQuadric.create () in

    GlMat.push ();
    Gl.enable `texture_2d;
    GlTex.image2d image;
    List.iter ~f:(GlTex.parameter ~target:`texture_2d)
      [ `wrap_s `repeat;
      	`wrap_t `repeat;
      	`mag_filter `nearest;
      	`min_filter `nearest ];
    GlMat.translate ~x ~y ~z ();
    GluQuadric.texture q true;
    GluQuadric.sphere ~radius:0.01 ~slices:16 ~stacks:8 ~quad:q ();
    Gl.disable `texture_2d;
    GlMat.pop ()


  method draw_shadow =
    Gl.disable `blend;
    GlDraw.color (0.0, 0.0, 0.0);
    GlMat.push ();
    GlMat.translate ~x ~y ();
    GluQuadric.disk ~inner:0.0 ~outer:0.01 ~slices:8 ~loops:8 ();
    GlMat.pop ()

  method draw_target =
    let (x,y) = (target_x, target_y) in
    GlDraw.begins `quads;
    GlDraw.color (0.0, 0.0, 1.0);
    square (x -. 0.05, y +. 0.05) (x +. 0.05, y -. 0.05);
    GlDraw.ends ()


  method do_tick delta =
    if moving then 
      let (x',y',z') = collide ~pos:(x,y,z) ~vel:(-. vel_x *. delta,
						vel_y *. delta,
						vel_z *. delta) 
	  ~plane:((0.0, -. cw, 0.0), (0.0, cw, 0.1))
	  ~func:(function () -> 
	    begin 
	      vel_x <- 0.0; 
	      vel_y <- 0.0; 
	      vel_z <- 0.0
             end) in
      let vel_z' = vel_z in
      let (z',vel_z') = 
	if z' < 0.01 then (-. (z' -. 0.01) +. 0.01,
			   -. vel_z' *. 0.7) else (z',vel_z') in 
      let vel_z' = vel_z' -. delta *. 0.98 in
      vel_z <- vel_z';
      x <- x';
      y <- y';
      z <- z'
      else ();
    moving

  method set_position  x' y' = x <- x'; y <- y'
  method set_target  x' y' = target_x <- x'; target_y <- y'
  method set_z  z' = z <- z' /. 100.
  method get_position  = (x, y)

  method calc_vel =
    let dx = x -. target_x  
    and dy = target_y -. y in
    let d' = sqrt ( dx *. dx +. dy *. dy) in
    let cos_z = cos(angle_z /. 180. *. 3.14) in
    if cos_z = 0.0 or d' = 0.0 then () else
    let dz = d' *. (tan(angle_z /. 180. *. 3.14)) in
    let d = d' /. cos_z in
    begin
      vel_x <- velocity *. dx /. d;
      vel_y <- velocity *. dy /. d;
      vel_z <- velocity *. dz /. d
    end


  method switch = if moving then self#reset else self#calc_vel;
                  moving <- not moving; 
                  moving
end

class poll = object
  val r = 0.008
  val y = cw +. 0.05 +. 0.008

  method draw =
    Gl.disable `blend;
    GlDraw.color (0.0, 0.0, 0.0);
    GlMat.push ();
    GlMat.translate ~y ();
    GluQuadric.cylinder  ~slices:8 ~stacks:8 ~height:0.12 ~top:r ~base:r ();
    GlMat.pop ();
    GlMat.push ();
    GlMat.translate ~y:(-. y) ();
    GluQuadric.cylinder  ~slices:8 ~stacks:8 ~height:0.12 ~top:r ~base:r ();
    GlMat.pop ()
end


class court ~togl = object
  val court = 
    Togl.make_current togl;
    let court = GlList.create `compile in
    GlDraw.shade_model `flat;
    GlDraw.begins `quads;
    GlDraw.color (0.2, 0.7, 0.2);
    square (cl, cw) (-.cl, -.cw);

    (* Lines *)
    GlDraw.color (1.0, 1.0, 1.0);
    square (-.cl, cw)   (cl, cw -. lw);
    square (-.cl, -.cw)	(cl, -.cw +. lw);
    square (cl, cw)     (cl -. wlw, -. cw);
    square (-.cl, cw)   (-.cl +. wlw, -.cw);
    square (-.sl, lw /. 2.) (sl, -.lw /. 2.);
    square (-.cl, sw)   (cl, sw -. lw);
    square (-.cl, -.sw) (cl, -.sw +. lw);
    square (sl, sw)     (sl -. lw, -. sw);
    square (-.sl, sw)   (-.sl +. lw, -.sw);
    GlDraw.ends ();
    GlList.ends ();
    court

  method draw =  GlList.call court 
end

class player = object
  (* position of a player *)
  val mutable x = -1.0
  val mutable y = 0.5


  method move x' y' =
    x <- -. x';
    y <- y'

  method position = (x,y)
end

class net ~togl = object
  val texture = 
    Togl.make_current togl;
    make_image () 
(*    let image = make_image () in
    GlTex.image2d image;
    List.iter f:(GlTex.parameter target:`texture_2d)
      [ `wrap_s `repeat;
      	`wrap_t `repeat;
      	`mag_filter `nearest;
      	`min_filter `nearest ]; *)

  method draw =
    Gl.enable `blend;
    GlFunc.blend_func ~src:`src_alpha ~dst:`one_minus_src_alpha;
    GlDraw.color (0.0, 0.0, 0.0) ~alpha:1.0; 
    GlTex.env (`mode `replace);
    Gl.enable `texture_2d;
    GlTex.image2d texture;
    List.iter ~f:(GlTex.parameter ~target:`texture_2d)
      [ `wrap_s `repeat;
      	`wrap_t `repeat;
      	`mag_filter `nearest;
      	`min_filter `nearest ]; 
    GlDraw.begins `quads;
    GlTex.coord2(0.0, 0.0); GlDraw.vertex3(0.0, cw +. 0.05, 0.0);
    GlTex.coord2(0.0, 3.0); GlDraw.vertex3(0.0, cw +. 0.05, 0.115);
    GlTex.coord2(9.0, 3.0); GlDraw.vertex3(0.0, 0.0, 0.09);
    GlTex.coord2(9.0, 0.0); GlDraw.vertex3(0.0, 0.0, 0.0);

    GlTex.coord2(0.0, 0.0); GlDraw.vertex3(0.0, 0.0, 0.0);
    GlTex.coord2(0.0, 3.0); GlDraw.vertex3(0.0, 0.0, 0.09);
    GlTex.coord2(9.0, 3.0); GlDraw.vertex3(0.0, -.cw -. 0.05, 0.115);
    GlTex.coord2(9.0, 0.0); GlDraw.vertex3(0.0, -.cw -. 0.05, 0.0);
    GlDraw.ends (); 
    Gl.disable `texture_2d;
    Gl.disable `blend;

    GlDraw.color (1.0, 1.0, 1.0);
    GlDraw.begins `quad_strip;
    List.iter ~f:(fun (y,z) -> GlDraw.vertex ~x:0. ~y ~z ())
      [ cw +. 0.05, 0.11;
	cw +. 0.05, 0.115;
	0.0, 0.085;
	0.0, 0.09;
	-.cw -. 0.05, 0.11;
	-.cw -. 0.05, 0.115 ];
    GlDraw.ends ()
end


class view3d ~togl ~ball ~player ~viewtype = object
  val ball : ball = ball
  val player : player = player
  val court =  new court ~togl
  val net = new net ~togl
  val poll = new poll

  method draw =
    Togl.make_current togl;
    GlClear.color (0.5, 0.5, 1.0);
    GlClear.clear [`color;`depth];

    if viewtype () = "Top View" then
      begin
	GlMat.mode `projection;
	GlMat.load_identity ();
	GlMat.rotate ~angle:90.0 ~z:1.0 ();
	GlMat.ortho ~x:(-1.2,1.2) ~y:(-1.2,1.2) ~z:(0.0,2.0); 
	GlMat.mode `modelview;
	GlMat.load_identity ();
	GluMat.look_at
	  ~eye:(0.0, 0.0, 2.0) ~center:(0.0, 0.0, 0.0) ~up:(0.0, 1.0, 0.0)
      end
    else
      begin
	GlMat.mode `projection;
	GlMat.load_identity ();
	GluMat.perspective ~fovy:40.0 ~aspect:1.0 ~z:(0.1,4.0);
	GlMat.mode `modelview;
	if viewtype () = "Center" then
	  begin
	    GlMat.load_identity ();
	    let (x,y) = player#position in
	    GluMat.look_at
	      ~eye:(x, y, 0.2) ~center:(0.0, 0.0, 0.09) ~up:(-. x, -. y, 0.0)
	  end
	else
	  begin
	    GlMat.load_identity ();
	    let (x,y) = player#position in
	    let (x',y') = ball#get_position in
	    GluMat.look_at
	      ~eye:(x, y, 0.2) ~center:(x', y', 0.09) ~up:(x' -. x, y' -. y, 0.0)
	  end;
      end;

    GlDraw.shade_model `flat;

    (* Ground *)
    GlDraw.begins `quads;
    GlDraw.color (0.5, 0.5, 0.5);
    square (-5.0, 5.0) (5.0, -5.0);
    GlDraw.ends ();

    court#draw;

    let (x,y) = ball#get_position
    in
    if x < 0.0 then 
    (net#draw;
     ball#draw_shadow;
     ball#draw)
    else
    (ball#draw_shadow;
     ball#draw;
     net#draw);
    poll#draw;

    
    Togl.swap_buffers togl;
    Gl.flush ()
end

class view2d ~togl ~ball ~player = object
  val ball : ball = ball
  val player : player = player
  val court = new court ~togl:togl

  method draw =
    Togl.make_current togl;
    GlClear.clear [`color;`depth];

    GlMat.mode `projection;
    GlMat.load_identity ();
    GlMat.rotate ~angle:90.0 ~z:1.0 ();
    GlMat.ortho ~x:(-1.5,1.5) ~y:(-1.5,1.5) ~z:(0.0,2.0); 
    GlMat.mode `modelview;
    GlMat.load_identity ();
    let (x,y) = player#position in
    GluMat.look_at
      ~eye:(0.0, 0.0, 2.0) ~center:(0.0, 0.0, 0.0) ~up:(0.0, 1.0, 0.0);
    court#draw;
    ball#draw;
    
    let (x,y) = player#position in
    GlDraw.begins `quads;
    GlDraw.color (1.0, 0.0, 0.0);
    square (x -. 0.02, y +. 0.02) (x +. 0.02, y -. 0.02);
    GlDraw.ends ();

    ball#draw_target;

    Togl.swap_buffers togl;
    Gl.flush ()
end


open Tk

let main () =
  let top = openTk () in
  Wm.title_set top "Tennis Court";

  let f0 = Frame.create top in
  let court3d =
    Togl.create f0 ~width:600 ~height:600
      ~rgba:true ~double:true ~depth:true
  and f1 = Frame.create f0 in
  let court2d =
    Togl.create f1 ~width:200 ~height:200
      ~rgba:true ~double:true ~depth:true
  and sx =
    Scale.create f1 ~label:"Velocity"
      ~min:0. ~max:200. ~orient:`Horizontal
  and sz =
    Scale.create f1 ~label:"Direction"
      ~min: (-. 90.) ~max:90. ~orient:`Horizontal
  and sht =
    Scale.create f1 ~label:"Height"
      ~min: 0. ~max:100. ~orient:`Horizontal
  and start =
    Button.create f1 ~text:"Start"
  in
  let viewseltv = Textvariable.create () in
    Textvariable.set viewseltv "Top View";
    let viewself = Frame.create  f1 in
    let viewsel = List.map ["Top View"; "Center"; "Ball"] ~f:
	begin fun t ->
	  Radiobutton.create viewself ~text: t ~value: t
	    ~variable: viewseltv
	end
    in
    pack viewsel;
  let viewtype = fun () -> Textvariable.get viewseltv in

  let ball = new ball () in
  let player = new player in
  let view3d = new view3d ~togl:court3d ~viewtype ~ball ~player
  and view2d = new view2d ~togl:court2d ~ball ~player
  in
  Scale.configure sx ~command:(ball#set_vel);
  Scale.configure sz ~command:(ball#set_velz);
  Button.configure start ~command:
    begin fun () ->
      Button.configure start ~text:(if ball#switch then "Stop" else "Start")
    end;
  Togl.timer_func ~ms:20
    ~cb:(fun () -> if ball#do_tick 0.02 then (view3d#draw; view2d#draw));
  Togl.display_func court3d ~cb:(fun () -> view3d#draw);
  Togl.display_func court2d ~cb:(fun () -> view2d#draw);
  bind court3d ~events:[`Modified([`Button1],`Motion)] ~fields:[`MouseX;`MouseY]
    ~action:(fun ev ->
          let width = Togl.width court3d
          and height =Togl.height court3d in 
	  let y = -. (float ev.ev_MouseX /. float width) +. 0.5
          and x = float ev.ev_MouseY  /. float height in
	  player#move x y;
	  view2d#draw;
	  view3d#draw);
  bind court2d ~events:[`Modified([`Button1],`Motion)] ~fields:[`MouseX;`MouseY]
    ~action:(fun ev ->
          let width = Togl.width court2d
          and height =Togl.height court2d in 
	  let y = (float ev.ev_MouseX /. float width ) -. 0.5
          and x = (float ev.ev_MouseY  /. float height) -. 0.5 in
	  let y = -. (y *. 3.0) 
          and x = -. (x *. 3.0)  in
	  ball#set_position x y;
	  view2d#draw;
	  view3d#draw);
  bind court2d ~events:[`Modified([`Button2],`Motion)] ~fields:[`MouseX;`MouseY]
    ~action:(fun ev ->
          let width = Togl.width court2d
          and height =Togl.height court2d in 
	  let y = (float ev.ev_MouseX /. float width ) -. 0.5
          and x = (float ev.ev_MouseY  /. float height) -. 0.5 in
	  let y = -. (y *. 3.0) 
          and x = -. (x *. 3.0)  in
	  ball#set_target x y;
	  print_float x;
	  print_float y;
	  print_string "\n"; 
	  view2d#draw;
	  view3d#draw);
  let rec viewselfn () =  
    begin
      Textvariable.handle viewseltv ~callback:viewselfn;
      view3d#draw
    end in
  viewselfn ();
  Scale.configure sht ~command:(fun z -> ball#set_z z; view3d#draw);
  pack [coe court2d; coe sx; coe sz; coe sht;coe start; coe viewself];
  pack [coe court3d; coe f1] ~side:`Left;
  pack [f0] ~expand:true ~fill:`Both;
  mainLoop ()

let _ = main ()
