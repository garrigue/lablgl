#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:18:40 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests various obscure interactions in menu creation and 
   destruction  including the support for Sun's Creator 3D
   overlay "high cell" overlay menu colormap cell allocation. *)

let display () = 
  GlClear.clear [`color];
  Gl.finish(); 
  ;;

let timer ~value = 
  if (value <> 23) then failwith("bad timer value\n");
  printf("PASS: test24\n");
  exit(0);
  ;;

let menuSelect ~value = ();;

let main () = 
  (* win2  men1  men2  men3; *)
  ignore(Glut.init Sys.argv);

  if (0 <> Glut.getMenu()) then
    failwith("current menu wrong, should be zero\n");
  if (0 <> Glut.getWindow()) then
    failwith("current window wrong, should be zero\n");
  Glut.initWindowSize 140 140;

  (* Make sure initial Glut. init display mode is right. *)
  if (Glut.get(Glut.INIT_DISPLAY_MODE) <> (Glut.rgba lor Glut.single lor Glut.depth)) then
    failwith(" init display mode wrong\n");
  Glut.initDisplayMode ~double_buffer:false ~alpha:false ~stencil:true ();
  if (Glut.get(Glut.INIT_DISPLAY_MODE) <> (Glut.rgba lor Glut.single lor Glut.stencil)) then
    failwith(" display mode wrong\n");
  (* Interesting :   creating menu before creating windows. *)
  let men1 = Glut.createMenu(menuSelect) in

  (* Make sure Glut.createMenu doesn't change init display mode. 
   *)
  if (Glut.get(Glut.INIT_DISPLAY_MODE) <> (Glut.rgba lor Glut.single lor Glut.stencil)) then
    failwith(" display mode changed\n");
  if (men1 <> Glut.getMenu()) then
    failwith(" current menu wrong\n");
  Glut.addMenuEntry "hello" 1;
  Glut.addMenuEntry "bye" 2;
  Glut.addMenuEntry "yes" 3;
  Glut.addMenuEntry "no" 4;
  Glut.addSubMenu "submenu" 5;

  let win1 = Glut.createWindow("test24") in
  Glut.displayFunc(display);

  if (win1 <> Glut.getWindow()) then
    failwith(" current window wrong\n");
  if (men1 <> Glut.getMenu()) then
    failwith(" current menu wrong\n");
  let men2 = Glut.createMenu(menuSelect) in
  Glut.addMenuEntry "yes" 3;
  Glut.addMenuEntry "no" 4;
  Glut.addSubMenu "submenu" 5;

  (* Make sure Glut.createMenu doesn't change init display mode. 
   *)
  if (Glut.get(Glut.INIT_DISPLAY_MODE) <> (Glut.rgba lor Glut.single lor Glut.stencil)) then
    failwith(" display mode changed\n");
  if (men2 <> Glut.getMenu()) then
    failwith(" current menu wrong\n");
  if (win1 <> Glut.getWindow()) then
    failwith(" current window wrong\n");
  let win2 = Glut.createWindow("test24 second") in
  Glut.displayFunc(display);

  if (win2 <> Glut.getWindow()) then
    failwith(" current window wrong\n");
  Glut.destroyWindow(win2);

  if (0 <> Glut.getWindow()) then
    failwith(" current window wrong  should be zero\n");
  let men3 = Glut.createMenu(menuSelect) in
  Glut.addMenuEntry "no" 4;
  Glut.addSubMenu "submenu" 5;

  if (Glut.get(Glut.INIT_DISPLAY_MODE) <> (Glut.rgba lor Glut.single lor Glut.stencil)) then
    failwith(" display mode changed\n");
  Glut.destroyMenu(men3);

  if (0 <> Glut.getMenu()) then
    failwith(" current menu wrong  should be zero\n");
  Glut.timerFunc(2 * 1000) timer 23;
  Glut.mainLoop();
  ;;

let _ = main();;

