#!/usr/bin/env lablglut

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* ported to lablglut by Issac Trotts on August 6, 2002 *)

let fake_argv = [| "program" ; "-iconic"; |];;

let displayed = ref false;;

let display () = 
  printf "display\n"; print_newline();
  GlClear.clear [`color];
  Glut.swapBuffers();
  displayed := true;
  ;;

let timer ~value = 
  printf "timer\n"; print_newline();
  if (!displayed) then failwith(" test28\n");
  printf("PASS ->  test28\n");
  exit(0);
  ;;

let main () =
  ignore (Glut.init fake_argv);
  if ((Array.length Sys.argv) <> 1) then failwith(" argument processing\n");
  Glut.initDisplayMode ~double_buffer:true ~alpha:false ();
  ignore (Glut.createWindow("test28"));
  Glut.displayFunc(display);
  Glut.timerFunc 2000  timer  0 ;
  Glut.mainLoop();
  ;;

let _ = main();;


