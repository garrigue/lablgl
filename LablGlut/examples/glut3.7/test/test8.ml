#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1994  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 13:41:20 MDT 2002. *)

open Printf

let main_w = ref(-1)
let w = [| 0; 0; 0; 0 |]
let win = ref(-1)
let num = ref(-1)

let fail_childnum () = 
  failwith(sprintf " Glut.get returned wrong # children: %d\n" !num)

let fail_bad_parent () = 
  failwith(sprintf " Glut.get returned bad parent: %d\n" !num)

let time2 ~value =
  printf "PASS: test8\n";
  exit 0;
  ;;

let time1 ~value = 
  Glut.setWindow w.(1);
  Glut.idleFunc None;
  Glut.keyboardFunc (fun ~key ~x ~y -> ());
  Glut.setWindow w.(0);
  Glut.idleFunc None;
  Glut.keyboardFunc (fun ~key ~x ~y -> ());
  Glut.setWindow !main_w;
  Glut.idleFunc None;    (* redundant *)
  Glut.keyboardFunc (fun ~key ~x ~y -> ());
  Glut.destroyWindow w.(1);
  Glut.destroyWindow w.(0);
  Glut.destroyWindow !main_w;
  Glut.timerFunc 500 time2 0;
  ;;

let display () = ();;

let main () = 
  ignore(Glut.init Sys.argv);
  if Glut.get Glut.INIT_WINDOW_WIDTH <> 300 then
    failwith " init width wrong";
  if Glut.get Glut.INIT_WINDOW_HEIGHT <> 300 then
    failwith " init height wrong";
  if Glut.get Glut.INIT_WINDOW_X <> -1 then
    failwith " init x wrong";
  if Glut.get Glut.INIT_WINDOW_Y <> -1 then
    failwith " init y wrong";
  if Glut.get Glut.INIT_DISPLAY_MODE <> 
     Glut.rgba lor Glut.single lor Glut.depth then
    failwith " init display mode wrong";
  Glut.initDisplayMode ();
  main_w := Glut.createWindow "main";
  Glut.displayFunc display;
  num := if Glut.getBool Glut.DISPLAY_MODE_POSSIBLE then 1 else 0;
  if !num <> 1 then
    failwith (sprintf 
      "Glut.get returned display mode not possible: %d\n" !num);
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if 0 <> !num then failwith " Glut.get returned wrong # children: %d\n" !num;
  w.(0) <- Glut.createSubWindow !main_w  10  10  20  20;
  Glut.displayFunc display;
  num := Glut.get Glut.WINDOW_PARENT;
  if !main_w <> !num then fail_bad_parent();
  Glut.setWindow !main_w;
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if 1 <> !num then fail_childnum();
  w.(1) <- Glut.createSubWindow !main_w  40  10  20  20;
  Glut.displayFunc display;
  num := Glut.get Glut.WINDOW_PARENT;
  if !main_w <> !num then fail_bad_parent();
  Glut.setWindow !main_w;
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if  2 <> !num then fail_childnum();
  w.(2) <- Glut.createSubWindow !main_w  10  40  20  20;
  Glut.displayFunc display;
  num := Glut.get Glut.WINDOW_PARENT;
  if !main_w <> !num then fail_bad_parent();
  Glut.setWindow !main_w;
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if  3 <> !num then fail_childnum();
  w.(3) <- Glut.createSubWindow !main_w  40  40  20  20;
  Glut.displayFunc display;
  num := Glut.get Glut.WINDOW_PARENT;
  if !main_w <> !num then fail_bad_parent();
  Glut.setWindow !main_w;
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if  4 <> !num then fail_childnum();
  Glut.destroyWindow w.(3);
  num := Glut.get Glut.WINDOW_NUM_CHILDREN;
  if  3 <> !num then fail_childnum();
  w.(3) <- Glut.createSubWindow !main_w  40  40  20  20;
  Glut.displayFunc display;
  ignore(Glut.createSubWindow w.(3)  40  40  20  20);
  Glut.displayFunc display;
  ignore(Glut.createSubWindow w.(3)  40  40  20  20);
  Glut.displayFunc display;
  win := Glut.createSubWindow w.(3)  40  40  20  20;
  Glut.displayFunc display;
  ignore(Glut.createSubWindow !win  40  40  20  20);
  Glut.displayFunc display;
  win := Glut.createSubWindow w.(3)  40  40  20  20;
  Glut.displayFunc display;
  ignore(Glut.createSubWindow !win  40  40  20  20);
  Glut.displayFunc display;
  Glut.destroyWindow w.(3);

  w.(3) <- Glut.createSubWindow !main_w  40  40  20  20;
  Glut.displayFunc display;

  Glut.timerFunc 500 time1 0;
  Glut.mainLoop();
  ;;

let _ = main();;

