#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Sun Aug 11 14:55:37 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Test for GLUT 3.0's overlay functionality. *)

let transP = ref 0
let main_win = ref 0
let x = ref 0.0 and y = ref 0.0

let render_normal () =
  Glut.useLayer(Glut.NORMAL);
  GlClear.clear [`color];
  GlDraw.color (0.0,0.0,1.0);
  GlDraw.begins `polygon;
  GlDraw.vertex ~x:0.2 ~y:0.28 ();
  GlDraw.vertex ~x:0.5 ~y:0.58 ();
  GlDraw.vertex ~x:0.2 ~y:0.58 ();
  GlDraw.ends();
  Gl.flush();
;;

let render_overlay () = 
  GlClear.clear [`color];
  GlDraw.begins `polygon;
  GlDraw.vertex ~x:(0.2 +. !x) ~y:(0.2 +. !y) ();
  GlDraw.vertex ~x:(0.5 +. !x) ~y:(0.5 +. !y) ();
  GlDraw.vertex ~x:(0.2 +. !x) ~y:(0.5 +. !y) ();
  GlDraw.ends();
  Gl.flush();
;;

let render () = 
  Glut.useLayer(Glut.NORMAL);
  render_normal();
  if (Glut.layerGet(Glut.HAS_OVERLAY)) then begin
    Glut.useLayer(Glut.OVERLAY);
    render_overlay();
  end
;;

let render_sub () =
  printf("render_sub\n");
  Glut.useLayer(Glut.NORMAL);
  render_normal();
  if (Glut.layerGet(Glut.HAS_OVERLAY)) then begin
    Glut.useLayer(Glut.OVERLAY);
    render_overlay();
  end
;;

let display_count = ref 0
let damage_expectation = ref false

let timer ~value = 
  if (value <> 777) then failwith("unexpected timer value");
  damage_expectation := true;
  Glut.showWindow();
;;

let rec time2 ~value = 
  if (value = 666) then begin
    printf("PASS: test17\n");
    exit(0);
  end;
  if (value <> 888) then failwith("bad value");
  Glut.destroyWindow(!main_win);
  Glut.timerFunc 500 time2 666;
;;

let move_on () =
  incr display_count;
  if (!display_count = 2) then begin
    damage_expectation := true;
    Glut.iconifyWindow();
    Glut.timerFunc 500  timer  777;
  end;
  if !display_count = 4 then begin
    printf "display_count = 4\n";
    Glut.initDisplayMode ();
    ignore(Glut.createSubWindow !main_win 10 10 150 150);
    GlClear.color (0.5, 0.5, 0.5);
    Glut.displayFunc(render_sub);
    Glut.initDisplayMode ~index:true ();
    Glut.establishOverlay();
    Glut.copyColormap !main_win;
    Glut.setColor ~cell:((!transP + 1) mod 2) ~red:0.0 ~green:1.0 ~blue:1.0;
    Glut.removeOverlay();
    Glut.establishOverlay();
    Glut.copyColormap(!main_win);
    Glut.copyColormap(!main_win);
    Glut.setColor ~cell:((!transP + 1) mod 2) ~red:1.0 ~green:1.0 ~blue:1.0;
    GlClear.index ((float_of_int !transP));
    GlDraw.index (float_of_int ((!transP + 1) mod 2));
    Glut.setWindow(!main_win);
    Glut.removeOverlay();
    Glut.timerFunc 500  time2  888;
  end
;;

let display_normal() = 
  if (Glut.layerGet(Glut.NORMAL_DAMAGED) <> !damage_expectation) then
    failwith(" normal damage not expected\n");
  render_normal();
  move_on();
;;

let display_overlay() = 
  if (Glut.layerGet(Glut.OVERLAY_DAMAGED) <> !damage_expectation) then
    failwith(" overlay damage not expected\n");
  render_overlay();
  move_on();
;;

let been_here = ref false (* strange: this never gets set to true... -ijt *)
let display2() =
  if Glut.layerGet(Glut.NORMAL_DAMAGED) then
    failwith(" normal damage not expected\n");
  if Glut.layerGet(Glut.OVERLAY_DAMAGED) then
    failwith(" overlay damage not expected\n");
  if (!been_here) then Glut.postOverlayRedisplay()
  else begin
    Glut.overlayDisplayFunc(display_overlay);
    Glut.displayFunc(display_normal);
    damage_expectation := true;
    Glut.postOverlayRedisplay();
    Glut.postRedisplay();
  end
;;

let display() = 
  if not (Glut.layerGet(Glut.NORMAL_DAMAGED)) then
    failwith(" normal damage expected\n");
  if not (Glut.layerGet(Glut.OVERLAY_DAMAGED)) then
    failwith(" overlay damage expected\n");
  render();

  Glut.displayFunc(display2);
  Glut.postRedisplay();
;;

let main () =
  ignore(Glut.init Sys.argv);
  Glut.initWindowSize 300 300;
  Glut.initDisplayMode ~index:true ();

  if not (Glut.layerGet(Glut.OVERLAY_POSSIBLE)) then begin
    printf "UNRESOLVED: need overlays for this test (your window system "; 
    printf "lacks overlays)\n";
    exit(0);
  end;
  Glut.initDisplayMode ();
  main_win := Glut.createWindow("test17");

  if Glut.layerGetInUse() = Glut.OVERLAY then
    failwith(" overlay should not be in use\n");
  if Glut.layerGet(Glut.HAS_OVERLAY) then
    failwith(" overlay should not exist\n");
  if Glut.layerGetTransparentIndex() <> -1 then
    failwith(" transparent pixel of normal plane should be -1\n");
  if Glut.layerGet(Glut.NORMAL_DAMAGED) then
    failwith(" no normal damage yet\n");
  (* raises exception if overlay is not in use: *)
  ignore(Glut.layerGet(Glut.OVERLAY_DAMAGED)); 
  GlClear.color (0.0, 1.0, 0.0);

  Glut.initDisplayMode ~index:true ();

  (* Small torture test. *)
  Glut.establishOverlay();
  Glut.removeOverlay();
  Glut.establishOverlay();
  Glut.establishOverlay();
  Glut.showOverlay();
  Glut.hideOverlay();
  Glut.showOverlay();
  Glut.removeOverlay();
  Glut.removeOverlay();
  Glut.establishOverlay();

  if (Glut.get(Glut.WINDOW_RGBA) <> 0) then
    failwith(" overlay should not be RGBA\n");
  Glut.useLayer(Glut.NORMAL);
  if not (Glut.get(Glut.WINDOW_RGBA) <> 0) then
    failwith(" normal should be RGBA\n");
  Glut.useLayer(Glut.OVERLAY);
  if (Glut.get(Glut.WINDOW_RGBA) <> 0) then
    failwith(" overlay should not be RGBA\n");
  if (Glut.layerGetInUse() = Glut.NORMAL) then
    failwith(" overlay should be in use\n");
  if not (Glut.layerGet(Glut.HAS_OVERLAY)) then
    failwith(" overlay should exist\n");
  if (Glut.layerGetTransparentIndex() = -1) then
    failwith(" transparent pixel should exist\n");
  if Glut.layerGet(Glut.NORMAL_DAMAGED) then
    failwith(" no normal damage yet\n");
  if Glut.layerGet(Glut.OVERLAY_DAMAGED) then
    failwith(" no overlay damage yet\n");
  transP := Glut.layerGetTransparentIndex();
  GlClear.index (float_of_int (Glut.layerGetTransparentIndex()));
  Glut.setColor ((!transP + 1) mod 2)  1.0  0.0  1.0;
  GlDraw.index (float_of_int ((!transP + 1) mod 2));
  Glut.useLayer(Glut.NORMAL);
  if (Glut.layerGetInUse() = Glut.OVERLAY) then
    failwith(" overlay should not be in use\n");
  Glut.displayFunc(display);

  Glut.mainLoop();
;;

let _ = main();;



