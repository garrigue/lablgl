#!/usr/bin/env lablglut

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This test makes sure damaged gets set when a window is
   resized smaller. *)

let width = ref (-1);;
let height = ref (-1);;
let displayCount = ref 0;;

let onDone ~value = 
  if (!displayCount <> 2) then failwith "test19  damage expected\n";
  fprintf stderr  "PASS :  test19\n" ;
  exit(0);
  ;;

let reshape ~w ~h = 
  printf "window reshaped :  w=%d  h=%d\n"  w  h ;
  width := w;
  height := h;
  ;;

let display () = 
  if not (Glut.layerGet Glut.NORMAL_DAMAGED) then
    failwith "test19  damage expected\n" ;
  incr displayCount;
  if (!width = -1 || !height = -1) then
    failwith "test19  reshape not called\n" ;
  GlClear.clear [`color];
  Gl.flush();
  if (!displayCount = 1) then begin
    Glut.reshapeWindow (!width / 2)  (!height / 2);
    Glut.timerFunc 1000  onDone  0 ;
    end
  ;;

let main () = 
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow("test19"));
  Glut.displayFunc(display);
  Glut.reshapeFunc(reshape);
  Glut.mainLoop();
  ;;

let _ = main();;

