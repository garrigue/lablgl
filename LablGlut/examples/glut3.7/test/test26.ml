#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:18:42 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Test for Glut.postWindowRedisplay and
   Glut.postWindowOverlayRedisplay introduced with GLUT 4 API. *)

let window1 = ref(-1);;
let window2 = ref(-1);;
let win1displayed = ref 0;;
let win2displayed = ref 0;;
let win1vis = ref Glut.NOT_VISIBLE;;
let win2vis = ref Glut.NOT_VISIBLE;;
(*
let win1vis = ref false;;
let win2vis = ref false;;
*)
let overlaySupported = ref false;;
let over1displayed = ref 0;;

let checkifdone () = 
  if ((!win1displayed > 15) && (!win2displayed > 15) && 
      ((not !overlaySupported) || !over1displayed>15)) then begin
    printf("PASS ->  test26\n");
    exit(0);
    end
  ;;

let window1display () = 
  if (Glut.getWindow() <> !window1) then failwith(" window1display\n");
  GlClear.color (0.0,  1.0,  0.0);
  GlClear.clear [`color];
  Gl.flush();
  incr win1displayed;
  checkifdone();
  ;;

let overDisplay () =
  GlClear.clear [`color];
  GlDraw.rect (-0.5, -0.5)  (0.5, 0.5);
  Gl.flush();
  incr over1displayed;
  checkifdone();
  ;;

let window2display () = 
  if (Glut.getWindow() <> !window2) then failwith(" window2display\n");
  GlClear.color (0.0, 0.0, 1.0);
  GlClear.clear [`color];
  Glut.swapBuffers();
  incr win2displayed;
  checkifdone();
  ;;

let timefunc ~value = failwith(" test26\n") ;;

let count = ref 0;;
let idle () = 
  if (!count mod 2 <> 0) then begin
    Glut.postWindowRedisplay(!window1);
    Glut.postWindowRedisplay(!window2);
  end else begin
    Glut.postWindowRedisplay(!window2);
    Glut.postWindowRedisplay(!window1);
  end;
  if (!overlaySupported) then Glut.postWindowOverlayRedisplay(!window1);
  incr count;
  ;;

let window1vis ~state = 
  win1vis := state ;
  (* if (!win1vis <> Glut.NOT_VISIBLE && !win2vis <> Glut.NOT_VISIBLE) then  *)
  if (!win1vis <> Glut.NOT_VISIBLE && !win2vis <> Glut.NOT_VISIBLE) then  
    Glut.idleFunc(Some idle)
  ;;

let window2status ~state = 
  win2vis := 
    if (state = Glut.FULLY_RETAINED) || (state = Glut.PARTIALLY_RETAINED) then
      Glut.VISIBLE else Glut.NOT_VISIBLE;
  if (!win1vis <> Glut.NOT_VISIBLE && !win2vis <> Glut.NOT_VISIBLE) then 
    Glut.idleFunc(Some idle);
  ;;

let main () = 
  ignore(Glut.init Sys.argv);

  Glut.initWindowSize 100 100 ;
  Glut.initWindowPosition 50 100 ;
  Glut.initDisplayMode ~double_buffer:false ~alpha:false (); 
  window1 := Glut.createWindow("1");
  Glut.displayFunc(window1display);
  Glut.visibilityFunc(window1vis);

  Glut.initDisplayMode ~double_buffer:false ~index:true ();
  overlaySupported := Glut.layerGet Glut.OVERLAY_POSSIBLE;
  if (!overlaySupported) then begin
    printf("testing Glut.postWindowOverlayRedisplay since overlay supported\n");
    Glut.establishOverlay();
    Glut.overlayDisplayFunc(overDisplay);
    let transP = Glut.layerGetTransparentIndex() in
    GlClear.index (float_of_int(Glut.layerGetTransparentIndex()));
    let opaqueP = (transP + 1) mod Glut.get(Glut.WINDOW_COLORMAP_SIZE) in
    Glut.setColor opaqueP 1.0 0.0 0.0 ;
  end;
  Glut.initWindowPosition 250 100 ;
  Glut.initDisplayMode ~double_buffer:true ~alpha:false ();
  window2 := Glut.createWindow("2");
  Glut.displayFunc(window2display);
  Glut.windowStatusFunc(window2status);

  Glut.timerFunc 9000 timefunc 1 ;

  Glut.mainLoop();
  ;;

let _ = main();;

