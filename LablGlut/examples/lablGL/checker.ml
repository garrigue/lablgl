(* $Id: checker.ml,v 1.1 2003-09-25 13:54:10 raffalli Exp $ *)
(* converted by Issac Trotts.  July 25, 2002 *)

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
  List.iter (GlTex.parameter ~target:`texture_2d)
    [ `wrap_s `clamp;
      `wrap_t `clamp;
      `mag_filter `nearest;
      `min_filter `nearest ];
  GlTex.env `texture_env (`mode `decal);
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

let reshape ~w ~h =
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  GluMat.perspective ~fovy:60.0 ~aspect:(1.0 *. float w /. float h) ~z:(1.0,30.0);
  GlMat.mode `modelview;
  GlMat.load_identity ();
  GlMat.translate ~z:(-3.6) ()

let main () =
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~depth:true () ;
  Glut.initWindowSize ~w:500 ~h:500 ;
  ignore(Glut.createWindow ~title:"checker");
  myinit ();
  Glut.displayFunc ~cb:display ;
  Glut.reshapeFunc ~cb:reshape ;
  Glut.mainLoop ()

let _ = main ()
