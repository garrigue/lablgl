(* $Id: checker.ml,v 1.7 2000-04-12 09:49:05 garrigue Exp $ *)

let image_height = 64
and image_width = 64

let make_image () =
  let image =
    GlPix.create `ubyte ~format:`rgb ~width:image_width ~height:image_height in
  for i = 0 to image_width - 1 do
    for j = 0 to image_height - 1 do
      Raw.sets (GlPix.to_raw image) ~pos:(3*(i*image_height+j))
	(if (i land 8 ) lxor (j land 8) = 0
	 then [|255;255;255|]
	 else [|0;0;0|])
    done
  done;
  image

let myinit () =
  GlClear.color (0.0, 0.0, 0.0);
  Gl.enable `depth_test;
  GlFunc.depth_func `less;

  let image = make_image () in
  GlPix.store (`unpack_alignment 1);
  GlTex.image2d image;
  List.iter ~f:(GlTex.parameter ~target:`texture_2d)
    [ `wrap_s `clamp;
      `wrap_t `clamp;
      `mag_filter `nearest;
      `min_filter `nearest ];
  GlTex.env (`mode `decal);
  Gl.enable `texture_2d;
  GlDraw.shade_model `flat

let display () =
  GlClear.clear [`color;`depth];
  GlDraw.begins `quads;
  GlTex.coord2(0.0, 0.0); GlDraw.vertex3(-2.0, -1.0, 0.0);
  GlTex.coord2(0.0, 1.0); GlDraw.vertex3(-2.0, 1.0, 0.0);
  GlTex.coord2(1.0, 1.0); GlDraw.vertex3(0.0, 1.0, 0.0);
  GlTex.coord2(1.0, 0.0); GlDraw.vertex3(0.0, -1.0, 0.0);
  
  GlTex.coord2(0.0, 0.0); GlDraw.vertex3(1.0, -1.0, 0.0);
  GlTex.coord2(0.0, 1.0); GlDraw.vertex3(1.0, 1.0, 0.0);
  GlTex.coord2(1.0, 1.0); GlDraw.vertex3(2.41421, 1.0, -1.41421);
  GlTex.coord2(1.0, 0.0); GlDraw.vertex3(2.41421, -1.0, -1.41421);
  GlDraw.ends ();
  Gl.flush ()

let reshape togl =
  let w = Togl.width togl and h = Togl.height togl in
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  GluMat.perspective ~fovy:60.0 ~aspect:(1.0 *. float w /. float h) ~z:(1.0,30.0);
  GlMat.mode `modelview;
  GlMat.load_identity ();
  GlMat.translate ~z:(-3.6) ()

open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create ~width:500 ~height:500 ~rgba:true ~depth:true top in
  myinit ();
  Togl.display_func togl ~cb:display;
  Togl.reshape_func togl ~cb:(fun () -> reshape togl);
  pack ~expand:true ~fill:`Both [togl];
  mainLoop ()

let _ = main ()
