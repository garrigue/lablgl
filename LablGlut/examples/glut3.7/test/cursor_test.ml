#!/usr/bin/env lablglut 

(* Ported to lablglut by Issac Trotts on Tue Aug 6 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

let c2i c = match c with 
  | Glut.CURSOR_RIGHT_ARROW -> 0
  | Glut.CURSOR_LEFT_ARROW -> 1
  | Glut.CURSOR_INFO -> 2
  | Glut.CURSOR_DESTROY -> 3
  | Glut.CURSOR_HELP -> 4
  | Glut.CURSOR_CYCLE -> 5
  | Glut.CURSOR_SPRAY -> 6
  | Glut.CURSOR_WAIT -> 7
  | Glut.CURSOR_TEXT -> 8
  | Glut.CURSOR_CROSSHAIR -> 9
  | Glut.CURSOR_UP_DOWN -> 10
  | Glut.CURSOR_LEFT_RIGHT -> 11
  | Glut.CURSOR_TOP_SIDE -> 12
  | Glut.CURSOR_BOTTOM_SIDE -> 13
  | Glut.CURSOR_LEFT_SIDE -> 14
  | Glut.CURSOR_RIGHT_SIDE -> 15
  | Glut.CURSOR_TOP_LEFT_CORNER -> 16
  | Glut.CURSOR_TOP_RIGHT_CORNER -> 17
  | Glut.CURSOR_BOTTOM_RIGHT_CORNER -> 18
  | Glut.CURSOR_BOTTOM_LEFT_CORNER -> 19
  | Glut.CURSOR_INHERIT -> 100
  | Glut.CURSOR_NONE -> 101
  | Glut.CURSOR_FULL_CROSSHAIR -> 102
  ;;

let i2c i = match i with
  | 0 -> Glut.CURSOR_RIGHT_ARROW
  | 1 -> Glut.CURSOR_LEFT_ARROW
  | 2 -> Glut.CURSOR_INFO
  | 3 -> Glut.CURSOR_DESTROY
  | 4 -> Glut.CURSOR_HELP
  | 5 -> Glut.CURSOR_CYCLE
  | 6 -> Glut.CURSOR_SPRAY
  | 7 -> Glut.CURSOR_WAIT
  | 8 -> Glut.CURSOR_TEXT
  | 9 -> Glut.CURSOR_CROSSHAIR
  | 10 -> Glut.CURSOR_UP_DOWN
  | 11 -> Glut.CURSOR_LEFT_RIGHT
  | 12 -> Glut.CURSOR_TOP_SIDE
  | 13 -> Glut.CURSOR_BOTTOM_SIDE
  | 14 -> Glut.CURSOR_LEFT_SIDE
  | 15 -> Glut.CURSOR_RIGHT_SIDE
  | 16 -> Glut.CURSOR_TOP_LEFT_CORNER
  | 17 -> Glut.CURSOR_TOP_RIGHT_CORNER
  | 18 -> Glut.CURSOR_BOTTOM_RIGHT_CORNER
  | 19 -> Glut.CURSOR_BOTTOM_LEFT_CORNER
  | 100 -> Glut.CURSOR_INHERIT
  | 101 -> Glut.CURSOR_NONE
  | 102 -> Glut.CURSOR_FULL_CROSSHAIR
  | _ -> failwith "bad int given for conversion to Glut.CURSor"
  ;;

let cursors = [|
  Glut.CURSOR_INHERIT ;
  Glut.CURSOR_NONE ;
  Glut.CURSOR_FULL_CROSSHAIR ;
  Glut.CURSOR_RIGHT_ARROW ;
  Glut.CURSOR_LEFT_ARROW ;
  Glut.CURSOR_INFO ;
  Glut.CURSOR_DESTROY ;
  Glut.CURSOR_HELP ;
  Glut.CURSOR_CYCLE ;
  Glut.CURSOR_SPRAY ;
  Glut.CURSOR_WAIT ;
  Glut.CURSOR_TEXT ;
  Glut.CURSOR_CROSSHAIR ;
  Glut.CURSOR_UP_DOWN ;
  Glut.CURSOR_LEFT_RIGHT ;
  Glut.CURSOR_TOP_SIDE ;
  Glut.CURSOR_BOTTOM_SIDE ;
  Glut.CURSOR_LEFT_SIDE ;
  Glut.CURSOR_RIGHT_SIDE ;
  Glut.CURSOR_TOP_LEFT_CORNER ;
  Glut.CURSOR_TOP_RIGHT_CORNER ;
  Glut.CURSOR_BOTTOM_RIGHT_CORNER ;
  Glut.CURSOR_BOTTOM_LEFT_CORNER 
  |];;

let name = [|
  "INHERIT" ;
  "NONE" ;
  "FULL CROSSHAIR" ;
  "RIGHT ARROW" ;
  "LEFT ARROW" ;
  "INFO" ;
  "DESTROY" ;
  "HELP" ;
  "CYCLE" ;
  "SPRAY" ;
  "WAIT" ;
  "TEXT" ;
  "CROSSHAIR" ;
  "UP DOWN" ;
  "LEFT RIGHT" ;
  "TOP SIDE" ;
  "BOTTOM SIDE" ;
  "LEFT SIDE" ;
  "RIGHT SIDE" ;
  "TOP LEFT CORNER" ;
  "TOP RIGHT CORNER" ;
  "BOTTOM RIGHT CORNER" ;
  "BOTTOM LEFT CORNER" 
  |];;

let win = ref (-1);;

let futureSetCursor ~value = Glut.setCursor(Glut.CURSOR_HELP) ;;

let willret = ref true ;;

let menu ~value = 
  print_newline();
  if(value < 0) then begin
    match value with
      | -1 -> begin
        Glut.setWindow(!win);
        Glut.warpPointer 25  25 ;
        end
      | -2 -> begin
        Glut.setWindow(!win);
        Glut.warpPointer(-25) (-25);
        end
      | -3 -> begin
        Glut.setWindow(!win);
        Glut.warpPointer 250 250 ;
        end
      | -4 -> begin
        Glut.setWindow(!win);
        Glut.warpPointer 2000 200;
        end
      | -5 -> Glut.timerFunc 3000 futureSetCursor (Glut.getWindow()) ;
      | _ -> willret := false;
  end else begin
    Glut.setCursor(i2c value);
    let i = Glut.get(Glut.WINDOW_CURSOR) in 
    if (i <> value) then failwith "cursor_test : cursor not set right"; 
    end
  ;;

let display () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let keyboard ~key ~x ~y = 
  if key = 27 (*esc*) then exit 0;;

let main () = 
  ignore(Glut.init Sys.argv);
  win := Glut.createWindow("cursor test");
  GlClear.color (0.49, 0.62, 0.75);
  Glut.displayFunc(display);
  Glut.keyboardFunc keyboard;
  ignore(Glut.createMenu(menu));
  for i = 0 to ((Array.length name)-1) do 
    Glut.addMenuEntry name.(i) (c2i cursors.(i)) ; 
    done;
  Glut.addMenuEntry "Warp to (25 25)"  (-1);
  Glut.addMenuEntry "Warp to (-25 -25)"  (-2);
  Glut.addMenuEntry "Warp to (250 250)"  (-3);
  Glut.addMenuEntry "Warp to (2000 200)"  (-4);
  Glut.addMenuEntry "Set cursor in 3 secs"  (-5);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  ignore(Glut.createSubWindow !win  10  10  90  90 );
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  GlClear.color (0.3, 0.82, 0.55);
  Glut.displayFunc(display);
  ignore(Glut.createSubWindow !win  80  80  90  90);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  GlClear.color (0.9, 0.2, 0.2);
  Glut.displayFunc(display);
  Glut.mainLoop();
  ;;

let _ = main();;

