(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests GLUT's video resize API (currently only supported
   on SGI's InfiniteReality hardware). *)

(* Ported to lablglut by Issac Trotts on Sat Aug 11 2002. *)

open Printf

let light_diffuse = (1.0,0.0,0.0)
let light_position = (1.0,1.0,1.0)
let x=ref 0 and y=ref 0 and w=ref 0 and h=ref 0
let dx=ref 0 and dy=ref 0 and dw=ref 0 and dh=ref 0

let (-=) x y = x := !x - y
let (+=) x y = x := !x + y

let display () = 
  GlClear.clear [`color; `depth];
  Glut.solidTeapot 1.0;
  Glut.swapBuffers();
;;

let show_video_size() =
  printf "Glut.VIDEO_RESIZE_X = %d\n" 
    (Glut.videoResizeGet Glut.VIDEO_RESIZE_X);
  printf "Glut.VIDEO_RESIZE_Y = %d\n" 
    (Glut.videoResizeGet Glut.VIDEO_RESIZE_Y);
  printf "Glut.VIDEO_RESIZE_WIDTH = %d\n" 
    (Glut.videoResizeGet Glut.VIDEO_RESIZE_WIDTH);
  printf "Glut.VIDEO_RESIZE_HEIGHT = %d\n" 
    (Glut.videoResizeGet Glut.VIDEO_RESIZE_HEIGHT);
;;

let keyboard ~key ~x ~y = 
  printf "c = %c\n" (char_of_int key);
  if key = 27 then exit 0;
  match (char_of_int key) with
  |  'a' -> Glut.videoPan 0  0  1280  1024;
  |  'b' -> Glut.videoPan 0  0  1600  1024;
  |  'c' -> Glut.videoPan 640  512  640  512;
  |  'q' -> Glut.videoPan 320  256  640  512;
  |  '1' -> Glut.videoResize 0  0  640  512;
  |  '2' -> Glut.videoResize 0  512  640  512;
  |  '3' -> Glut.videoResize 512  512  640  512;
  |  '4' -> Glut.videoResize 512  0  640  512;
  |  's' -> Glut.stopVideoResizing ();
  |  '=' -> show_video_size();
  |  ' ' -> Glut.postRedisplay();
  |   _  -> ()
;;

let rec time2 ~value = 
  Glut.videoResize !x !y !w !h;
  Glut.postRedisplay();
  x -= !dx;
  y -= !dy;
  w += !dx * 2;
  h += !dy * 2;
  if !x > 0 
  then Glut.timerFunc 100  time2  0
  else begin
    Glut.stopVideoResizing();
    printf "PASS: test21  with video resizing tested\n";
    exit 0;
  end
;;

let rec time1 ~value = 
  Glut.videoPan !x !y !w !h;
  x += !dx;
  y += !dy;
  w -= !dx * 2;
  h -= !dy * 2;
  if !x < 200 then Glut.timerFunc 100 time1 0 else Glut.timerFunc 100 time2 0
;;

let main() = 
  let interact = ref false in
  ignore(Glut.init Sys.argv);
  for i = 1 to ((Array.length Sys.argv)-1) do
    if "-i" = Sys.argv.(i) then interact := true;
  done;

  Glut.initDisplayMode ~double_buffer:true ();
  ignore(Glut.createWindow "test21");

  if Glut.videoResizeGet Glut.VIDEO_RESIZE_POSSIBLE = 0 then begin
    printf "video resizing not supported\n";
    printf "PASS: test21\n";
    exit 0;
  end;
  Glut.setupVideoResizing();
  printf "Glut.VIDEO_RESIZE_X_DELTA = %d\n" 
    (dx := Glut.videoResizeGet Glut.VIDEO_RESIZE_X_DELTA; !dx);
  printf "Glut.VIDEO_RESIZE_Y_DELTA = %d\n" 
    (dy := Glut.videoResizeGet Glut.VIDEO_RESIZE_Y_DELTA; !dy);
  printf "Glut.VIDEO_RESIZE_WIDTH_DELTA = %d\n" 
    (dw := Glut.videoResizeGet Glut.VIDEO_RESIZE_WIDTH_DELTA; !dw);
  printf "Glut.VIDEO_RESIZE_HEIGHT_DELTA = %d\n" 
    (dh := Glut.videoResizeGet Glut.VIDEO_RESIZE_HEIGHT_DELTA; !dh);
  printf "Glut.VIDEO_RESIZE_X = %d\n" 
    (x := Glut.videoResizeGet Glut.VIDEO_RESIZE_X; !x);
  printf "Glut.VIDEO_RESIZE_Y = %d\n" 
    (y := Glut.videoResizeGet Glut.VIDEO_RESIZE_Y; !y);
  printf "Glut.VIDEO_RESIZE_WIDTH = %d\n" 
    (w := Glut.videoResizeGet Glut.VIDEO_RESIZE_WIDTH; !w);
  printf "Glut.VIDEO_RESIZE_HEIGHT = %d\n" 
    (h := Glut.videoResizeGet Glut.VIDEO_RESIZE_HEIGHT; !h);
  Glut.stopVideoResizing();
  Glut.setupVideoResizing();

  Glut.displayFunc display;
  Glut.fullScreen();

  GlLight.light ~num:0 (`diffuse (1.0, 0.0, 0.0, 0.0));
  GlLight.light ~num:0 (`position (1.0, 1.0, 1.0, 1.0));
  Gl.enable `lighting;
  Gl.enable `light0;
  Gl.enable `depth_test;
  GlMat.mode `projection;
  GluMat.perspective ~fovy:22.0 ~aspect:1.0 ~z:(1.0, 10.0);
  GlMat.mode `modelview;
  GluMat.look_at 
    ~eye:(0.0, 0.0, 5.0) 
    ~center:(0.0, 0.0, 0.0) 
    ~up:(0.0, 1.0, 0.0);
  GlMat.translate ~z:(-1.0) ();

  Glut.keyboardFunc keyboard;
  if not !interact then Glut.timerFunc 100  time1  0;
  Glut.mainLoop();
;;

let _ = main();;
