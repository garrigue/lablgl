#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests GLUT's Glut.windowStatusFunc rotuine. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 16:07:37 MDT 2002. *)

open Printf

let win = ref(-1)
let subwin = ref(-1)
let cover = ref(-1)

let fail x = failwith ("test22 " ^ x)

let display () = 
  GlClear.clear [`color; `depth];
  Glut.swapBuffers();
  ;;

let time_end ~value = 
  printf "PASS: test22\n";
  exit 0;
  ;;

let time5 ~value = 
  Glut.setWindow !subwin;
  Glut.positionWindow 40 40;
  ;;

let time4 ~value = 
  Glut.setWindow !subwin;
  Glut.showWindow();
  ;;

let time3 ~value = 
  Glut.setWindow !subwin;
  Glut.hideWindow();
  ;;

let sub_state = ref 0
let cover_state = ref 0
let super_state = ref 0

let coverstat ~state = 
  if !cover <> Glut.getWindow() then fail "coverstat";
  printf "%d: cover = %s" !cover_state (Glut.string_of_window_status state);
  print_newline();
  ignore(match !cover_state with
   | 0 -> begin
    if state <> Glut.FULLY_RETAINED then fail "coverstat 2";
    Glut.timerFunc 1000 time3 0;
    end
   |  _ -> fail "coverstat 3");
  incr cover_state;
  ;;

let time2 ~value = 
  cover := Glut.createSubWindow !win 5 5 105 105;
  GlClear.color (0.0, 1.0, 0.0);
  Glut.displayFunc display;
  Glut.windowStatusFunc coverstat;
  ;;

let substat ~state = 
  if !subwin <> Glut.getWindow() then fail "substat";
  printf "%d: substate = %s" 
    !sub_state (Glut.string_of_window_status state); 
  print_newline();
  ignore(match !sub_state with
   | 0 -> begin
    if state <> Glut.FULLY_RETAINED then fail "substat 2";
    Glut.timerFunc 1000 time2 0;
    end
   | 1 -> if state <> Glut.FULLY_COVERED then fail "substat 3";
   | 2 -> begin
    if state <> Glut.HIDDEN then fail "substat 4";
    Glut.timerFunc 1000 time4 0;
    end
   | 3 -> begin
    if state <> Glut.FULLY_COVERED then fail "substat 5";
    Glut.timerFunc 1000 time5 0;
    end
   | 4 -> begin
    if state <> Glut.PARTIALLY_RETAINED then fail "substat 6";
    Glut.timerFunc 1000 time_end 0;
    end
   | _ -> fail "substat 7");
  incr sub_state;
  ;;

let time1 ~value = 
  printf "time1"; print_newline();
  subwin := Glut.createSubWindow !win 10 10 100 100;
  printf "subwin = %i" !subwin; print_newline();
  printf "get window = %i" (Glut.getWindow()); print_newline();
  GlClear.color (0.0, 1.0, 1.0);
  Glut.displayFunc display;
  Glut.windowStatusFunc substat;
  ;;

let winstat ~state = 
  if !win <> Glut.getWindow() then fail "winstat 1";
  printf "%d: win = %s" !super_state (Glut.string_of_window_status state); 
  print_newline();
  ignore(match !super_state with
   | 0 -> begin
    if state <> Glut.FULLY_RETAINED then fail "winstat 2";
    Glut.timerFunc 1000 time1 0;
    end
   | 1 -> if state <> Glut.PARTIALLY_RETAINED then fail "winstat 3";
   |  _ -> fail "winstat 4");
  incr super_state;
  ;;

let visbad ~state = fail "visbad" ;;

let main () = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:false ~double_buffer:false (); 
  win := Glut.createWindow "test22";
  GlClear.color (1.0, 0.0, 1.0);
  Glut.displayFunc display;
  Glut.visibilityFunc visbad;
  Glut.visibilityFunc (fun ~state -> ());
  Glut.windowStatusFunc (fun ~state -> ());
  Glut.visibilityFunc (fun ~state -> ());
  Glut.windowStatusFunc winstat;
  Glut.mainLoop();
  ;;

let _ = main();;

