#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21 -> 18 -> 48 MDT 2002. *)

#load "unix.cma"

open Printf

(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* timer_test is supposed to demonstrate that window system
   event related callbacks (like the keyboard callback) do not
   "starve out" the dispatching of timer callbacks.  Run this
   program and hold down the space bar.  The correct behavior
   (assuming the system does autorepeat) is interleaved "key is 
   32" and "timer called" messages.  If you don't see "timer
   called" messages  that's a problem.  This problem exists in
   GLUT implementations through GLUT 3.2. *)

let display () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let rec timer1 ~value = 
  printf "timer %d called\n" value ; print_newline();
  Glut.timerFunc 500  timer1 value ;
  ;;

let rec timer2 ~value = 
  printf "timer %d called\n" value ; print_newline();
  Glut.timerFunc 1000  timer2 value ;
  ;;

let num_times = ref 0;;

let keyboard ~key ~x ~y = 
  if (!num_times = 0) then Glut.timerFunc 500 timer1 1 ;
  if (!num_times = 0) then Glut.timerFunc 1000 timer2  2 ;
  incr num_times;
  if !num_times = 5 then exit 0;
  printf "key is %d\n"  key ; print_newline();
  if key = 27 then exit 0; (* esc *)
  Unix.sleep(1);
  ;;

let main () = 
  printf "\n== timer test ==\n\n";
  printf "Please the spacebar.\n" ;
  printf "The correct behavior (assuming the system does autorepeat)\n" ;
  printf "is \"key is 32\" and then \"timer X called\" messages\n"  ;
  printf "with X = 1 or 2 and about two 1 for one 2.\n"  ;
  printf "If you don't see \"timer X called\" messages  that's a problem.\n\n" ;
  printf "Press \"Esc\" to quit\n"  ;
  print_newline();
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow("timer test"));
  GlClear.color (0.49, 0.62, 0.75);
  Glut.displayFunc(display);
  Glut.keyboardFunc(keyboard);
  Glut.mainLoop();
  ;;

let _ = main();;

