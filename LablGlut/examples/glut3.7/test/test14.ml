#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Try testing menu item removal and menu destruction. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 2002. *)

open Printf

let displayFunc () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let menuFunc ~value = printf "choice = %d\n" value ;;

let timefunc ~value = 
  if (value <> 1) then failwith "test14\n";
  printf("PASS: test14\n");
  exit(0);
  ;;

let main () = 
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow("test14"));
  Glut.displayFunc(displayFunc);

  let submenu = Glut.createMenu(menuFunc) in
  Glut.addMenuEntry "First" 10101;
  Glut.addMenuEntry "Second" 20202;

  let menu = Glut.createMenu menuFunc in
  Glut.addMenuEntry "Entry1" 101;
  Glut.addMenuEntry "Entry2----------"  102;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "oEntry1"  201;
  Glut.addMenuEntry "o----------"  200;
  Glut.addMenuEntry "oEntry2----------"  202;
  Glut.addMenuEntry "oEntry3"  203;
  Glut.removeMenuItem 2;
  Glut.destroyMenu menu;

  let menu = Glut.createMenu menuFunc in
  Glut.addMenuEntry "Entry1"  101;
  Glut.addMenuEntry "Entry2----------"  102;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "oEntry1"  201;
  Glut.addMenuEntry "o----------"  200;
  Glut.addMenuEntry "oEntry2----------"  202;
  Glut.addMenuEntry "oEntry3"  203;
  Glut.removeMenuItem 2;
  Glut.attachMenu Glut.RIGHT_BUTTON;

  let menu = Glut.createMenu menuFunc in
  for i = 0 to 9 do Glut.addMenuEntry "YES" i done;
  for i = 0 to 9 do Glut.removeMenuItem 1 done;
  Glut.addMenuEntry "Entry1" 101;
  Glut.addMenuEntry "Entry2" 102;
  Glut.addMenuEntry "Entry3" 103;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "----------" 303;
  for i = 0 to 9 do Glut.addMenuEntry "YES**************************" i; done;
  for i = 0 to 8 do Glut.removeMenuItem(3); done;
  Glut.destroyMenu menu;

  let menu = Glut.createMenu menuFunc in 
  for i = 0 to 9 do Glut.addMenuEntry "YES" i; done;
  for i = 0 to 9 do Glut.removeMenuItem 1; done;
  Glut.addMenuEntry "Entry1" 101;
  Glut.addMenuEntry "Entry2" 102;
  Glut.addMenuEntry "Entry3" 103;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "----------" 303;
  for i = 0 to 9 do Glut.addMenuEntry "YES**************************" i; done;
  for i = 0 to 8 do Glut.removeMenuItem 3; done;
  Glut.attachMenu Glut.MIDDLE_BUTTON;

 let menu = Glut.createMenu menuFunc in
 Glut.addMenuEntry "Entry1" 101;
 Glut.addMenuEntry "Entry2" 102;
 Glut.addMenuEntry "Entry3" 103;
 Glut.removeMenuItem 2;
 Glut.removeMenuItem 1;
 Glut.addMenuEntry "nEntry1" 201;
 Glut.addMenuEntry "nEntry2----------" 202;
 Glut.addMenuEntry "nEntry3" 203;
 Glut.removeMenuItem 2;
 Glut.removeMenuItem 1;
 Glut.addMenuEntry "n----------" 303;
 Glut.changeToMenuEntry 1 "HELLO" 34;
 Glut.changeToSubMenu 2 "HELLO menu" submenu;
 Glut.destroyMenu menu;

  let menu = Glut.createMenu(menuFunc) in
  Glut.addMenuEntry "Entry1"  101;
  Glut.addMenuEntry "Entry2"  102;
  Glut.addMenuEntry "Entry3"  103;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "nEntry1"  201;
  Glut.addMenuEntry "nEntry2----------"  202;
  Glut.addMenuEntry "nEntry3"  203;
  Glut.removeMenuItem 2;
  Glut.removeMenuItem 1;
  Glut.addMenuEntry "n----------"  303;
  Glut.attachMenu Glut.LEFT_BUTTON;

  Glut.timerFunc 2000 timefunc 1;

  Glut.mainLoop();
  ;;

let _ = main();;

