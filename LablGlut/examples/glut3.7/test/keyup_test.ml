#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21 -> 18 -> 25 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

let keyboard ~key ~x ~y = 
  printf "kDN ->  %d <%d> @ (%d %d)"  key key x y;  
  print_newline();;

let keyup ~key ~x ~y = 
  printf "kUP ->  %d <%d> @ (%d %d)"  key  key x y ;  
  print_newline();;

let special ~key ~x ~y = 
  printf "sDN ->  %s @ (%d %d)"  (Glut.string_of_special key) x  y ;
  print_newline();;

let specialup ~key ~x ~y = 
  printf "sUP ->  %s @ (%d %d)"  (Glut.string_of_special key) x  y ;
  print_newline();;

let menu ~value = 
  printf "menu_cb"; print_newline();
  match value with
  | 1 -> Glut.ignoreKeyRepeat(true);
  | 2 -> Glut.ignoreKeyRepeat(false);
  | 3 -> Glut.keyboardFunc (fun ~key ~x ~y -> ());
  | 4 -> Glut.keyboardFunc(keyboard);
  | 5 -> Glut.keyboardUpFunc (fun ~key ~x ~y -> ());
  | 6 -> Glut.keyboardUpFunc(keyup);
  | 7 -> Glut.specialFunc (fun ~key ~x ~y -> ());
  | 8 -> Glut.specialFunc(special);
  | 9 -> Glut.specialUpFunc (fun ~key ~x ~y -> ());
  | 10 -> Glut.specialUpFunc(specialup);
  | _ -> failwith "bad menu in menu_cb"
  ;;

let display () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let main () = 
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow("keyup test"));
  GlClear.color (0.49, 0.62, 0.75);
  Glut.displayFunc(display);
  Glut.keyboardFunc(keyboard);
  Glut.keyboardUpFunc(keyup);
  Glut.specialFunc(special);
  Glut.specialUpFunc(specialup);
  ignore(Glut.createMenu(menu));
  Glut.addMenuEntry "Ignore autorepeat"  1;
  Glut.addMenuEntry "Accept autorepeat"  2;
  Glut.addMenuEntry "Stop key"  3;
  Glut.addMenuEntry "Start key"  4;
  Glut.addMenuEntry "Stop key up"  5;
  Glut.addMenuEntry "Start key up"  6;
  Glut.addMenuEntry "Stop special"  7;
  Glut.addMenuEntry "Start special"  8;
  Glut.addMenuEntry "Stop special up"  9;
  Glut.addMenuEntry "Start special up"  10;
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  Glut.mainLoop();
  ;;

let _ = main();;

