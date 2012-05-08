(* 
   ciglut : a demo of using caml-images, glut, and opengl to draw a textured
    rectangle.

   Copyright (c) 2002 Issac J. Trotts.  LGPL
*)

open Image
open OImage
open Info
open Printf

let width = ref 1
and height = ref 1;;

let endl = print_newline;;

let pow2floor x =
  let y = ref x in
  let i = ref 31 in
  while !i >= 0 && (!y land (1 lsl !i)) == 0 do 
    i := !i - 1; 
  done;
  1 lsl !i;
;;

let pow2ceil x = 
  let p2f = pow2floor x in 
  if p2f = x then x else (pow2floor x) lsl 1;;

let i2f i = float_of_int i;;
let f2i f = int_of_float f;;

let raw_of_camlimg cimg =
  let w = cimg#width and h = cimg#height in 
  let image = GlPix.create `ubyte ~format:`rgb ~width:w ~height:h in
  for i = 0 to w - 1 do
    for j = 0 to h - 1 do
      let pixel = cimg#get i j in (* pixel is a Color.rgb *)
      Raw.sets (GlPix.to_raw image) ~pos:(3*(i*h+j))
        [| pixel.r; pixel.g; pixel.b |];
    done
  done;
  image
;;

(* scale the image up so it's a power of two along each axis.
   (IMPROVEME: this takes too long) *)
let rescale img = 
  let newimg = img#resize None (pow2ceil img#width) (pow2ceil img#height) in 
  img#destroy;
  newimg;;

let initialize ci_img =
  printf "initializing..."; endl();
  GlClear.color (0.0, 0.0, 0.0);
  (* save the original width and height *)
  let w = ci_img#width and h = ci_img#height in
  width := w;
  height := h;
  let ci_img = if pow2floor w <> w || pow2floor h <> h 
                then rescale ci_img else ci_img in
  let gl_image = raw_of_camlimg ci_img in
  GlPix.store (`unpack_alignment 1);
  GlTex.image2d gl_image;
  List.iter (GlTex.parameter ~target:`texture_2d)
    [ `wrap_s `clamp;
      `wrap_t `clamp;
      `mag_filter `linear;
      `min_filter `linear ];
  GlTex.env `texture_env (`mode `decal);
  Gl.enable `texture_2d;
  GlDraw.shade_model `flat;
  printf "done"; endl();
;;

(* -- ui callbacks -- *)


let disp_called = ref false

let display () =
  if not(!disp_called) then begin
    Glut.reshapeWindow !width !height;
    GluMat.ortho2d ~x:(0.0, i2f !width) ~y:(0.0, i2f !height);
    disp_called := true
  end;

  GlClear.clear [`color];
  GlDraw.begins `quads;
  let w = i2f !width and h = i2f !height in
  GlTex.coord2(1.0, 0.0); GlDraw.vertex3(0.0, 0.0, 0.0);
  GlTex.coord2(1.0, 1.0); GlDraw.vertex3(w, 0.0, 0.0);
  GlTex.coord2(0.0, 1.0); GlDraw.vertex3(w, h, 0.0);
  GlTex.coord2(0.0, 0.0); GlDraw.vertex3(0.0, h, 0.0);
  GlDraw.ends();

  GlDraw.begins `lines;
  GlDraw.color(1.0, 0.0, 0.0);
  GlDraw.vertex2(0.0, 0.0);
  GlDraw.vertex2(1.0, 0.0);

  GlDraw.color(0.0, 1.0, 0.0);
  GlDraw.vertex2(0.0, 0.0);
  GlDraw.vertex2(0.0, 1.0);
  GlDraw.ends();

  Gl.flush ();

;;

let on_keyboard ~key ~x ~y = 
  match key with 
  | 27 -> exit 0;
  | _ -> ();
;;

let view_with_glut img = 
  (* open a couple of Glut windows and display the file directly
     and via texture on a square *)
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~double_buffer:false ~depth:false ();
  Glut.initWindowSize 256 256;
  ignore(Glut.createWindow "ocimgview");
  GlDraw.shade_model `flat;
  GlClear.color(0.0,0.0,0.0);
  (* GluMat.ortho2d ~x:(0.0,1.0) ~y:(0.0,1.0); *)
  initialize img;
  Glut.displayFunc (fun () -> display());
  Glut.keyboardFunc (fun ~key ~x ~y -> on_keyboard ~key ~x ~y);
  Glut.postRedisplay();
  Glut.mainLoop();
;;

let _ = 
  Bitmap.maximum_live := 15000000; (* 60MB *)
  Bitmap.maximum_block_size := !Bitmap.maximum_live / 16;
  let r = Gc.get () in
  r.Gc.max_overhead <- 30;
  Gc.set r
;;

let _ =
  let filename = ref None in
  let argfmt = [
    (* "-scale", Arg.Float (fun sc -> scale := sc), "scale"; *)
  ] in
  Arg.parse argfmt (fun s -> filename := Some s)
    "ocimgview file";
  let filename = match !filename with 
  | None -> Arg.usage argfmt "ocimgview file"; exit(-1);
  | Some s -> s 
  in
  printf "Reading in %s" filename; endl();
  let img = OImage.load filename [] in
  let img = OImage.rgb24 img in

  view_with_glut img;
;;

