#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21 -> 18 -> 47 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

let main_w = ref 0;;
let w1 = ref 0;;
let w2 = ref 0;;
let w3 = ref 0;;
let w4 = ref 0;;

let display () = 
  GlClear.clear [`color];
  Glut.swapBuffers();
  ;;

let time8 ~value = 
  printf("PASS ->  test9\n");
  exit(0);
  ;;

let time7 ~value = 
  Glut.destroyWindow(!main_w);
  Glut.timerFunc 500 time8 0 ;
  ;;

let time6 ~value = 
  Glut.destroyWindow(!w1);
  Glut.timerFunc 500 time7 0 ;
  Glut.initDisplayMode ~index:true ();
  if not (Glut.getBool Glut.DISPLAY_MODE_POSSIBLE) then begin
    printf("UNRESOLVED :  test9 (your OpenGL lacks color index support)\n");
    exit(0);
  end;
  w1 := Glut.createSubWindow !main_w  10  10  10  10 ;
  Glut.displayFunc(display);
  w2 := Glut.createSubWindow !w1  10  10  30  30 ;
  Glut.displayFunc(display);
  w3 := Glut.createSubWindow !w2  10  10  50  50 ;
  Glut.displayFunc(display);
  Glut.initDisplayMode ~alpha:false ();
  w4 := Glut.createSubWindow !w3  10  10  70  70 ;
  GlClear.color (1.0,1.0,1.0); 
  Glut.displayFunc(display);
  ;;

let time5 ~value = 
  w1 := Glut.createSubWindow !main_w  10  10  10  10 ;
  Glut.displayFunc(display);
  w2 := Glut.createSubWindow !w1  10  10  30  30 ;
  Glut.displayFunc(display);
  w3 := Glut.createSubWindow !w2  10  10  50  50 ;
  Glut.displayFunc(display);
  Glut.initDisplayMode ~alpha:false ();
  w4 := Glut.createSubWindow !w3  10  10  70  70 ;
  GlClear.color (1.0, 1.0, 1.0) ;
  Glut.displayFunc(display);
  Glut.timerFunc 500 time6 0 ;
  ;;

let time4 ~value =
  Glut.destroyWindow(!w4);
  Glut.timerFunc 500 time5 0;
  ;;

let time3 ~value = 
  Glut.destroyWindow(!w3);
  Glut.timerFunc 500 time4 0;
  ;;

let time2 ~value = 
  Glut.destroyWindow(!w2);
  Glut.timerFunc 500 time3 0;
  ;;

let time1 ~value = 
  Glut.destroyWindow(!w1);
  Glut.timerFunc 500 time2 0;
  ;;

let main () = 
  ignore(Glut.init Sys.argv);

  Glut.initDisplayMode ~alpha:false ();
  main_w := Glut.createWindow("test9");
  GlClear.color (0.0, 0.0, 0.0); 
  Glut.displayFunc(display);
  Glut.initDisplayMode ~index:true ();
  if not (Glut.getBool Glut.DISPLAY_MODE_POSSIBLE) then begin
    printf("UNRESOLVED ->  test9 (your OpenGL lacks color index support)\n");
    exit(0);
    end;
  w1 := Glut.createSubWindow !main_w  10  10  10  10 ;
  Glut.setColor 1  1.0  0.0  0.0 ;  (* red *)
  Glut.setColor 2  0.0  1.0  0.0 ;  (* green *)
  Glut.setColor 3  0.0  0.0  1.0 ;  (* blue *)

  GlClear.index 1.0;
  Glut.displayFunc(display);
  w2 := Glut.createSubWindow !main_w  30  30  10  10;
  Glut.copyColormap(!w1);
  GlClear.index 2.0;
  Glut.displayFunc(display);
  w3 := Glut.createSubWindow !main_w  50  50  10  10;
  Glut.copyColormap(!w1);
  GlClear.index 3.0;
  Glut.displayFunc(display);
  w4 := Glut.createSubWindow !main_w  70  70  10  10;
  Glut.copyColormap(!w1);
  Glut.setColor 3  1.0  1.0  1.0;  (* white *)
  GlClear.index 3.0;
  Glut.displayFunc(display);
  Glut.timerFunc 750 time1 0;
  Glut.mainLoop();
  ;;

let _ = main();;

