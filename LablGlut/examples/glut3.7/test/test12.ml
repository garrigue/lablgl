#!/usr/bin/env lablglut

#load "unix.cma"

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 13:41:11 MDT 2002. *)

open Printf

let main () = 
  ignore(Glut.init Sys.argv);
  let a = Glut.get Glut.ELAPSED_TIME in
  Unix.sleep 1;
  let b = Glut.get Glut.ELAPSED_TIME in
  let d = b - a in
  if d < 990 || d > 1200 then failwith " test12\n";
  ignore(Glut.createWindow "dummy");
  (* try all Glut.WINDOW_* Glut.get's *)
  let value = ref (Glut.get Glut.WINDOW_X) in
  value := Glut.get(Glut.WINDOW_Y);
  value := Glut.get(Glut.WINDOW_WIDTH);
  if (!value <> 300) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_HEIGHT);
  if (!value <> 300) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_BUFFER_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_STENCIL_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_DEPTH_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_RED_SIZE);
  if (!value < 1) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_GREEN_SIZE);
  if (!value < 1) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_BLUE_SIZE);
  if (!value < 1) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_ALPHA_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_ACCUM_RED_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_ACCUM_GREEN_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_ACCUM_BLUE_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_ACCUM_ALPHA_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_DOUBLEBUFFER);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_RGBA);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_CURSOR);
  if !value <> (Glut.int_of_cursor Glut.CURSOR_INHERIT) then 
    failwith " test12\n";
  printf "Window format id = 0x%x (%d)\n" 
    (Glut.get(Glut.WINDOW_FORMAT_ID)) (Glut.get(Glut.WINDOW_FORMAT_ID));
  Glut.setCursor(Glut.CURSOR_NONE);
  value := Glut.get(Glut.WINDOW_CURSOR);
  if !value <> (Glut.int_of_cursor Glut.CURSOR_NONE) then 
    failwith " test12\n";
  Glut.warpPointer 0 0;
  Glut.warpPointer(-5) (-5);
  Glut.warpPointer 2000 2000;
  Glut.warpPointer(-4000) 4000;
  value := Glut.get(Glut.WINDOW_COLORMAP_SIZE);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_PARENT);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_NUM_CHILDREN);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_NUM_SAMPLES);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.WINDOW_STEREO);
  if (!value < 0) then failwith(" test12\n");
  (* touch Glut.SCREEN_* Glut.get's supported *)
  value := Glut.get(Glut.SCREEN_WIDTH);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.SCREEN_HEIGHT);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.SCREEN_WIDTH_MM);
  if (!value < 0) then failwith(" test12\n");
  value := Glut.get(Glut.SCREEN_HEIGHT_MM);
  if (!value < 0) then failwith(" test12\n");
  printf("PASS: test12\n");
  ;;

let _ = main();;

