(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Test display callbacks are not called for non-viewable
   windows and overlays. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 2002. *)

open Printf

let transP = ref 0 and opaqueP = ref 0
let main_win = ref 0 and  sub_win = ref 0
let overlaySupported = ref false
let subHidden = ref false and overlayHidden = ref false
let warnIfNormalDisplay = ref false
let firstTime = ref true

let fail18() = failwith "test18"

let time5_cb ~value = 
  if value <> -3 then fail18();
  printf "PASS: test18\n";
  exit 0;
  ;;

let time4_cb ~value = 
  if value <> -6 then fail18();
  warnIfNormalDisplay := false;
  Glut.timerFunc 750  time5_cb (-3);
  Glut.setWindow !sub_win;
  Glut.postRedisplay();
  Glut.setWindow !main_win;
  if !overlaySupported then Glut.postOverlayRedisplay();
  ;;

let time3_cb ~value = 
  if  value <> 6 then fail18();
  Glut.setWindow !main_win;
  Glut.hideOverlay();
  overlayHidden := true;
  warnIfNormalDisplay := true;
  Glut.timerFunc 500  time4_cb (-6);
  ;;

let time2_cb ~value = 
  if value <> 56 then fail18();
  Glut.setWindow !main_win;
  if !overlaySupported then begin
    Glut.showOverlay();
    overlayHidden := false;
  end;
  Glut.setWindow !sub_win;
  Glut.hideWindow();
  subHidden := true;
  Glut.timerFunc 500 time3_cb 6;
  ;;

let time_cb ~value = 
  if value <> 456 then fail18();
  Glut.setWindow !sub_win;
  subHidden := false;
  Glut.showWindow();
  Glut.timerFunc 500 time2_cb 56;
  ;;

let display () =
  if !warnIfNormalDisplay then begin
    printf "WARNING: hiding overlay should not generate normal plane expose not \n";
    printf "does overlay operation work correctly?";
    print_newline();
  end;
  if Glut.layerGetInUse() <> Glut.NORMAL then fail18();
  GlClear.clear [`color];
  Gl.flush();
  if !firstTime then begin
    Glut.timerFunc 500 time_cb 456;
    firstTime := false;
  end;
  ;;

let subDisplay () = 
  if Glut.layerGetInUse() <> Glut.NORMAL then fail18();
  if !subHidden then begin
    printf "display callback generated when subwindow was hidden not \n";
    fail18();
  end;
  GlClear.clear [`color];
  Gl.flush ();
  ;;

let overDisplay () = 
  if Glut.layerGetInUse() <> Glut.OVERLAY then fail18();
  if !overlayHidden then begin
    printf "display callback generated when overlay was hidden not \n";
    fail18();
  end;
  GlClear.clear [`color];
  Gl.flush();
  ;;

let subVis ~state = 
  if Glut.layerGetInUse() <> Glut.NORMAL then fail18();
  if !subHidden && state = Glut.VISIBLE then begin
    printf "visible callback generated when overlay was hidden not \n";
    fail18();
  end;
  if not !subHidden && state = Glut.NOT_VISIBLE then begin
    printf "non-visible callback generated when overlay was shown not \n";
    fail18()
  end;
  ;;

let main () =
  ignore(Glut.init Sys.argv);
  Glut.initWindowSize ~w:300 ~h:300;
  Glut.initDisplayMode ~alpha:true ();

  main_win := Glut.createWindow "test18";

  if Glut.get Glut.WINDOW_COLORMAP_SIZE <> 0 then begin
    printf "RGBA color model windows should report zero colormap entries.\n";
    fail18();
  end;

  Glut.initDisplayMode ~index:true ();
  Glut.displayFunc display;

  overlaySupported := Glut.layerGet Glut.OVERLAY_POSSIBLE ;
  if !overlaySupported then begin
    Glut.establishOverlay ();
    Glut.hideOverlay ();
    overlayHidden := true;
    Glut.overlayDisplayFunc overDisplay;
    transP := Glut.layerGetTransparentIndex();
    GlClear.index (float_of_int(Glut.layerGetTransparentIndex()));
    opaqueP := !transP + 1 mod (Glut.get Glut.WINDOW_COLORMAP_SIZE);
    Glut.setColor !opaqueP  1.0  0.0  1.0;
    GlClear.index (float_of_int !opaqueP);
  end;
  Glut.initDisplayMode ~alpha:true ();
  sub_win := Glut.createSubWindow !main_win  10  10  20  20;
  GlClear.color (0.0, 1.0, 0.0);
  Glut.displayFunc subDisplay;
  Glut.visibilityFunc subVis;
  Glut.hideWindow();
  subHidden := true;

  Glut.mainLoop();
  ;;

let _ = main();;



