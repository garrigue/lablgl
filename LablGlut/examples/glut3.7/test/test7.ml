#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* ported to lablglut by Issac Trotts on August 6, 2002 *)

open Printf

let w1 = ref 0;;
let w2 = ref 0;;

let display () = GlClear.clear [`color] ;;

let time9 ~value = 
  if (value <> 9) then failwith(" time9 expected 9\n");
  printf("PASS ->  test7\n");
  exit(0);
  ;;

let time8 ~value = 
  if (value <> 8) then failwith(" time8 expected 8\n");
  printf("window 1 to 350x250+20+200; window 2 to 50x150+50+50\n");
  Glut.setWindow(!w1);
  Glut.reshapeWindow 350  250 ;
  Glut.positionWindow 20  200 ;
  Glut.setWindow(!w2);
  Glut.reshapeWindow 50  150 ;
  Glut.positionWindow 50  50 ;
  Glut.timerFunc 1000  time9  9 ;
  ;;

let time7 ~value = 
  if (value <> 7) then failwith(" time7 expected 7\n");
  printf("window 1 fullscreen; window 2 popped on top\n");
  Glut.setWindow(!w1);
  Glut.showWindow();
  Glut.fullScreen();
  Glut.setWindow(!w2);
  Glut.showWindow();
  Glut.popWindow();
  (* It can take a long time for Glut.fullScreen to really happen
     on a Windows 95 PC.  I believe this has to do with the memory
     overhead for resizing a huge soft color and/or ancillary buffers. *)
  Glut.timerFunc 6000  time8  8 ;
  ;;

let time6 ~value = 
  if (value <> 6) then failwith(" time6 expected 6\n");
  printf("change icon tile for both windows\n");
  Glut.setWindow(!w1);
  Glut.setIconTitle("icon1");
  Glut.setWindow(!w2);
  Glut.setIconTitle("icon2");
  Glut.timerFunc 1000  time7  7 ;
  ;;

let time5 ~value = 
  if (value <> 5) then failwith(" time5 expected 5\n");
  Glut.setWindow(!w1);
  let wx = Glut.get(Glut.WINDOW_X) 
  and wy = Glut.get(Glut.WINDOW_Y) in
  printf "window x = %i, y = %i\n" wx wy;
  if (wx <> 20) then
    printf("WARNING: x position expected to be 20\n");
  if (wy <> 20) then
    printf("WARNING: y position expected to be 20\n");
  if (Glut.get(Glut.WINDOW_WIDTH) <> 250) then
    printf("WARNING: width expected to be 250\n");
  if (Glut.get(Glut.WINDOW_HEIGHT) <> 250) then
    printf("WARNING: height expected to be 250\n");
  Glut.setWindow(!w2);
  if (Glut.get(Glut.WINDOW_X) <> 250) then
    printf("WARNING: x position expected to be 250\n");
  if (Glut.get(Glut.WINDOW_Y) <> 250) then
    printf("WARNING: y position expected to be 250\n");
  if (Glut.get(Glut.WINDOW_WIDTH) <> 150) then
    printf("WARNING: width expected to be 150\n");
  if (Glut.get(Glut.WINDOW_HEIGHT) <> 150) then
    printf("WARNING: height expected to be 150\n");
  printf("iconify both windows\n");
  Glut.setWindow(!w1);
  Glut.iconifyWindow();
  Glut.setWindow(!w2);
  Glut.iconifyWindow();
  Glut.timerFunc 1000  time6  6 ;
  ;;

let time4 ~value = 
  if (value <> 4) then failwith(" time4 expected 4\n");
  printf("reshape and reposition window\n");
  Glut.setWindow(!w1);
  Glut.reshapeWindow 250  250 ;
  Glut.positionWindow 20  20 ;
  Glut.setWindow(!w2);
  Glut.reshapeWindow 150  150 ;
  Glut.positionWindow 250  250 ;
  Glut.timerFunc 1000  time5  5 ;
  ;;

let time3 ~value = 
  if (value <> 3) then failwith(" time3 expected 3\n");
  printf("show both windows again\n");
  Glut.setWindow(!w1);
  Glut.showWindow();
  Glut.setWindow(!w2);
  Glut.showWindow();
  Glut.timerFunc 1000  time4  4 ;
  ;;

let time2 ~value = 
  if (value <> 2) then failwith(" time2 expected 2\n");
  printf("hiding w1; iconify w2\n");
  Glut.setWindow(!w1);
  Glut.hideWindow();
  Glut.setWindow(!w2);
  Glut.iconifyWindow();
  Glut.timerFunc 1000  time3  3 ;
  ;;

let time1 ~value = 
  if (value <> 1) then failwith(" time1 expected 1\n");
  printf("changing window titles\n");
  Glut.setWindow(!w1);
  Glut.setWindowTitle("changed title");
  Glut.setWindow(!w2);
  Glut.setWindowTitle("changed other title");
  Glut.timerFunc 2000  time2  2 ;
  ;;

let main () = 
  Glut.initWindowPosition 20  20 ;
  ignore(Glut.init Sys.argv);
  w1 := Glut.createWindow("test 1");
  Glut.displayFunc(display);
  Glut.initWindowPosition 200  200 ;
  w2 := Glut.createWindow("test 2");
  Glut.displayFunc(display);
  Glut.timerFunc 1000  time1  1 ;
  Glut.mainLoop();
  ;;

let _ = main();;

