#!/usr/bin/env lablglut

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* ported to lablglut by Issac Trotts on August 6, 2002 *)

let main () = 
  ignore(Glut.init Sys.argv);
  printf "Keyboard :   %s\n"  (if Glut.deviceGet(Glut.HAS_KEYBOARD) <> 0 then "YES"  else  "no") ;
  printf "Mouse :      %s\n"  (if Glut.deviceGet(Glut.HAS_MOUSE)  <> 0 then "YES"  else  "no") ;
  printf "Spaceball :  %s\n"  (if Glut.deviceGet(Glut.HAS_SPACEBALL)  <> 0 then "YES"  else  "no") ;
  printf "Dials :      %s\n"  (if Glut.deviceGet(Glut.HAS_DIAL_AND_BUTTON_BOX)  <> 0 then "YES"  else  "no") ;
  printf "Tablet :     %s\n\n"  (if Glut.deviceGet(Glut.HAS_TABLET)  <> 0 then "YES"  else  "no") ;
  printf "Mouse buttons :       %d\n"  (Glut.deviceGet(Glut.NUM_MOUSE_BUTTONS)) ;
  printf "Spaceball buttons :   %d\n"  (Glut.deviceGet(Glut.NUM_SPACEBALL_BUTTONS)) ;
  printf "Button box buttons :  %d\n"  (Glut.deviceGet(Glut.NUM_BUTTON_BOX_BUTTONS)) ;
  printf "Dials :               %d\n"  (Glut.deviceGet(Glut.NUM_DIALS)) ;
  printf "Tablet buttons :      %d\n\n"  (Glut.deviceGet(Glut.NUM_TABLET_BUTTONS)) ;
  printf "PASS :  test11\n" ;
  ;;

let _ = main();;

