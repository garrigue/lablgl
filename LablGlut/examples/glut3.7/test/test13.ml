#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:18:31 MDT 2002. *)

#load "unix.cma"

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

let window1 = ref (-1);;
let window2 = ref (-1);;
let win1reshaped = ref false;;
let win2reshaped = ref false;;
let win1displayed = ref false;;
let win2displayed = ref false;;

let checkifdone () =
  if (!win1reshaped && !win2reshaped && 
      !win1displayed && !win2displayed) then begin
    Unix.sleep(1);
    printf("PASS ->  test13\n");
    exit(0);
    end
  ;;

let window1reshape ~w ~h =
  if (Glut.getWindow() <> !window1) then failwith(" window1reshape\n");
  GlDraw.viewport ~x:0 ~y:0 ~w  ~h ;
  win1reshaped := true
  ;;

let window1display () =
  if (Glut.getWindow() <> !window1) then failwith(" window1display\n");
  GlClear.color (0.0, 1.0, 0.0);
  GlClear.clear [`color];
  Gl.flush();
  win1displayed := true;
  checkifdone();
  ;;

let window2reshape ~w ~h = 
  if (Glut.getWindow() <> !window2) then failwith(" window2reshape\n");
  GlDraw.viewport ~x:0 ~y:0 ~w ~h ;
  win2reshaped := true;
  ;;

let window2display () =
  if (Glut.getWindow() <> !window2) then failwith(" window2display\n");
  GlClear.color (0.0, 0.0, 1.0);
  GlClear.clear [`color];
  Gl.flush();
  win2displayed := true;
  checkifdone();
  ;;

let timefunc ~value = failwith(" test13\n") ;;

let main () = 
  ignore (Glut.init Sys.argv);
  Glut.initWindowSize 100  100 ;
  Glut.initWindowPosition 50  100 ;
  Glut.initDisplayMode ~double_buffer:false ~alpha:false ();
  window1 := Glut.createWindow("1");
  if (Glut.get(Glut.WINDOW_X) <> 50) then failwith(" test13\n");
  if (Glut.get(Glut.WINDOW_Y) <> 100) then failwith(" test13\n");
  Glut.reshapeFunc(window1reshape);
  Glut.displayFunc(window1display);

  Glut.initWindowSize 100  100 ;
  Glut.initWindowPosition 250  100 ;
  Glut.initDisplayMode ~double_buffer:false ~alpha:false ();
  window2 := Glut.createWindow("2");
  if (Glut.get(Glut.WINDOW_X) <> 250) then failwith(" test13\n");
  if (Glut.get(Glut.WINDOW_Y) <> 100) then failwith(" test13\n");
  Glut.reshapeFunc(window2reshape);
  Glut.displayFunc(window2display);

  Glut.timerFunc 7000 timefunc 1 ;

  Glut.mainLoop();
  ;;

let _ = main();;

