#!/usr/bin/env lablglut

(*

 Copyright (c) Mark J. Kilgard, 1994, 1996. 

 This program is freely distributable without licensing fees 
 and is provided without guarantee or warrantee expressed or 
 implied. This program is -not- in the public domain. 

 Ported to lablglut by Issac Trotts on August 5, 2002.

*)

open Printf

let count = ref 0;;

let save_count = ref 0;;
let head = ref 0;;
let tail = ref 0;;
let diff = ref 0;;

let timer2 ~value = 
  if (value <> 36)           then raise (Failure "timer value wrong\n");
  if (!count <> !save_count) then raise (Failure "counter still counting\n");
  printf("PASS: test2\n");
  exit 0 ;
  ;;

let timer ~value = 
  if (value <> 42) then raise (Failure "timer value wrong\n");
  if (!count <= 0) then raise (Failure "idle func not running\n");
  Glut.idleFunc None;
  save_count := !count;
  tail := Glut.get(Glut.ELAPSED_TIME);
  diff := !tail - !head;
  printf "diff = %d (%d - %d)\n" !diff !tail !head ;
  if !diff > int_of_float(500.0 *. 1.2) then begin
    printf("THIS TEST IS TIME SENSITIVE; IF IT FAILS, TRY RUNNING IT AGAIN.\n");
    raise (Failure "timer too late\n");
    end;
  if !diff < int_of_float(500.0 *. 0.9) then begin
    printf("THIS TEST IS TIME SENSITIVE; IF IT FAILS, TRY RUNNING IT AGAIN.\n");
    raise (Failure "timer too soon\n");
    end;
  Glut.timerFunc 100 timer2 36 
  ;;

let menuSelect ~value = () ;; (* do nothing *)

let never_void () =
  if false 
    then begin printf "never_void shouldn't be called."; print_newline() end
    else raise (Failure "never_void should never be called\n")
  ;;

let never_value ~state = 
  if false
    then begin printf "never_value shouldn't be called."; print_newline() end
    else raise (Failure "never_value most be NOT visible\n")
  ;;

let the_win = ref (-1);;

let display () = 
  Glut.setWindow !the_win;
  GlClear.clear [`color];
  Gl.flush();
  ;;

let main () =
  ignore (Glut.init Sys.argv);
  Glut.initWindowPosition 10  10 ;
  Glut.initWindowSize 200  200 ;
  Glut.initDisplayMode ~double_buffer:false ~alpha:false ~depth:true ();
  let win = (Glut.createWindow "test2")  in
  (* 
  this doesn't seem to be in lablGL
  glGetIntegerv(GL_INDEX_MODE, &isIndex);
  if  isIndex <> 0  then raise (Failure "window should be RGB\n");
  *)
  the_win:=win;
  Glut.setWindow win ; 
  Glut.displayFunc display ;
  let menu = Glut.createMenu menuSelect  in
  Glut.setMenu menu ;
  Glut.reshapeFunc (fun  ~w ~h -> () );
  Glut.reshapeFunc (fun  ~w ~h -> () );
  Glut.keyboardFunc (fun  ~key ~x ~y -> ());
  Glut.keyboardFunc (fun  ~key ~x ~y -> ());
  Glut.mouseFunc (fun ~button ~state ~x ~y -> ());
  Glut.mouseFunc (fun ~button ~state ~x ~y -> ());
  Glut.motionFunc (fun  ~x ~y -> ());
  Glut.motionFunc (fun  ~x ~y -> ());
  Glut.visibilityFunc (fun ~state -> ());
  Glut.visibilityFunc (fun ~state -> ());
  Glut.menuStateFunc (fun  ~status -> ());
  Glut.menuStateFunc (fun  ~status -> ());
  Glut.menuStatusFunc (fun  ~status ~x ~y -> ());
  Glut.menuStatusFunc (fun  ~status ~x ~y -> ());
  Glut.specialFunc (fun  ~key ~x ~y -> ());
  Glut.specialFunc (fun  ~key ~x ~y -> ());
  Glut.spaceballMotionFunc (fun ~x ~y ~z -> ());
  Glut.spaceballMotionFunc (fun ~x ~y ~z -> ());
  Glut.spaceballRotateFunc (fun ~x ~y ~z -> ());
  Glut.spaceballRotateFunc (fun ~x ~y ~z -> ());
  Glut.spaceballButtonFunc (fun ~button ~state -> ());
  Glut.spaceballButtonFunc (fun ~button ~state -> ());
  Glut.buttonBoxFunc (fun ~button ~state -> ());
  Glut.buttonBoxFunc (fun ~button ~state -> ());
  Glut.dialsFunc (fun ~dial ~value -> ());
  Glut.dialsFunc (fun ~dial ~value -> ());
  Glut.tabletMotionFunc (fun ~x ~y -> ());
  Glut.tabletMotionFunc (fun ~x ~y -> ());
  Glut.tabletButtonFunc (fun ~button ~state ~x ~y -> ());
  Glut.tabletButtonFunc (fun ~button ~state ~x ~y -> ());
  let menus = ref [] in
  let windows = ref [] in
  let num = 1 in
  for i = 0 to (num-1) do 
    (* let menu = Glut.createMenu menuSelect in  *)
    let window = Glut.createWindow "test" in
    windows := window :: !windows;
    menus := menu :: !menus; 
    Glut.displayFunc(display);
    for j = 0 to (i-1) do
      Glut.addMenuEntry "Hello"  1 ;
      Glut.addSubMenu "Submenu"  menu ; 
      done;
    if menu <> Glut.getMenu()  then 
      raise (Failure (sprintf "current menu not %d\n" menu)); 
    if window <> Glut.getWindow()  then
      raise (Failure (sprintf "current window not %d\n" window));
    Glut.displayFunc never_void ;
    Glut.visibilityFunc never_value ;  
    Glut.hideWindow();
    done;
  List.iter (fun m -> Glut.destroyMenu m) !menus ; 
  List.iter (fun w -> Glut.destroyWindow w) !windows ;  
  (* Glut.setWindow win; (* ijt *) *)
  Glut.timerFunc 500 timer 42 ;
  head := Glut.get(Glut.ELAPSED_TIME);
  Glut.idleFunc (Some(fun () -> incr count));
  Glut.mainLoop();
  exit 0;;

let _ = main();;

