#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard, 1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* ported to lablglut by Issac Trotts on Aug. 3, 2002 *)

open Printf
exception Failure of string

let main = 
  let fake_argv = [|
    "program";
    "-display";
    ":0";
    "-geometry";
    "500x400-34-23";
    "-indirect";
    "-iconic"
  |] in

  let alt() = 
    try 
      let altdisplay = Sys.getenv("GLUT_TEST_ALT_DISPLAY") in
      fake_argv.(2) <- altdisplay;  
    with Not_found -> printf "GLUT_TEST_ALT_DISPLAY not set\n"; in
  alt(); 

  let new_argv = Glut.init fake_argv in
  if ((Array.length new_argv) != 1) then 
    raise (Failure "argument processing");
  let w = Glut.get(Glut.INIT_WINDOW_WIDTH) in
  if w != 500 then 
    raise (Failure(sprintf "width wrong, got %d, not 500" w));
  let h = Glut.get(Glut.INIT_WINDOW_HEIGHT) in
  if h != 400 then 
    raise (Failure(sprintf "width height, got %d, not 400" h));
  let screen_width = Glut.get(Glut.SCREEN_WIDTH) in 
  let screen_height = Glut.get(Glut.SCREEN_HEIGHT) in 
  let x = Glut.get(Glut.INIT_WINDOW_X) in 
  if x != (screen_width - 500 - 34) then
    raise (Failure 
      (sprintf "width x, got %i, not %i" x (screen_width - 500 - 34)));
  let y = Glut.get(Glut.INIT_WINDOW_Y) in 
  if y != (screen_height - 400 - 23) then
    raise (Failure 
      (sprintf "width y, got %d, not %d" y (screen_height - 400 - 23)));
(* need to figure out a way to deal with this -ijt *)
 (* if Glut.get(Glut.INIT_DISPLAY_MODE) != *)
    (* (Glut.RGBA | Glut.SINGLE | Glut.DEPTH) then *)
    (* raise (Failure "width wrong 0"); *)
  Glut.initWindowPosition 10 10;
  Glut.initWindowSize 200 200;
  (* Glut.initDisplayMode(Glut.DOUBLE | Glut.RGB | Glut.DEPTH | Glut.STENCIL); *)
  if (Glut.get(Glut.INIT_WINDOW_WIDTH) != 200) then
    raise (Failure "width wrong 1");
  if (Glut.get(Glut.INIT_WINDOW_HEIGHT) != 200) then
    raise (Failure "width wrong 2");
  if (Glut.get(Glut.INIT_WINDOW_X) != 10) then
    raise (Failure "width wrong 3");
  if (Glut.get(Glut.INIT_WINDOW_Y) != 10) then
    raise (Failure "width wrong 4");
    (* FIXME
  if (Glut.get(Glut.INIT_DISPLAY_MODE) !=
    (Glut.DOUBLE | Glut.RGB | Glut.DEPTH | Glut.STENCIL)) {
    printf("FAIL: width wrong");
    exit(1);
    *)
  printf("PASS: test1\n");
  exit 0
  ;;

let _ = main();;

