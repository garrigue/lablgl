#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug 9 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This is an interactive test (not automatically run by "make
   test") that requires user interaction to verify that input
   callbacks operate as expected. *)

let mouseButtons = ref(-1);;

let display () =
  GlClear.clear [`color];
  Gl.flush();
  ;;

let time7 ~value = 
  if (value <> 7) then failwith(" time7 expected 6\n");
  printf("PASS :  test6\n");
  exit(0);
  ;;

let int_of_menu_state s = 
  match s with Glut.MENU_NOT_IN_USE -> 0 | Glut.MENU_IN_USE -> 1;;

let mstatus ~status = printf "state : %d\n" (int_of_menu_state status);;

let mstatus2 ~status ~x ~y = 
  printf "state : %d  x=%d  y=%d\n" (int_of_menu_state status) x y ;;

let menu2 ~value = 
  printf "menu item selected :  %d\n"  value ;
  if (value <> 46) then failwith(" time6 expected 45\n");
  Glut.destroyMenu(Glut.getMenu());
  Glut.destroyWindow(Glut.getWindow());
  Glut.timerFunc 1000  time7  7 ;
  ;;

let time6 ~value = 
  if (value <> 6) then failwith(" time6 expected 6\n");
  Glut.menuStateFunc(mstatus);
  Glut.menuStatusFunc(mstatus2);
  ignore(Glut.createMenu(menu2));
  Glut.addMenuEntry "name"  46 ;
  Glut.attachMenu(Glut.LEFT_BUTTON);
  Glut.attachMenu(Glut.MIDDLE_BUTTON);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  printf("Pop up menu with any mouse button and select the item\n");
  ;;

let estate = ref 0;;

let entry ~state =
  printf "entry :  %s\n" (if state = Glut.LEFT then "left" else "entered");
  match !estate with
  | 0 -> if (state = Glut.LEFT) then incr estate
  | 1 -> begin
    if (state = Glut.ENTERED) then incr estate;
    Glut.timerFunc 1000 time6 6;
    Glut.entryFunc (fun ~state->());
    end
  | _ -> failwith "unrecignized state in entry()"
  ;;

let time5 ~value = 
  if (value <> 5) then failwith(" time5 expected 5\n");
  Glut.entryFunc(entry);
  printf "In the black window  leave it  then enter it\n" ;
  ;;

let motion ~x ~y = 
  printf "motion x=%d  y=%d\n"  x  y ;
  Glut.motionFunc (fun ~x ~y -> ());
  Glut.timerFunc 1000 time5 5 ;
  ;;

let time4 ~value = 
  if (value <> 4) then failwith(" time4 expected 4\n");
  Glut.motionFunc(motion);
  printf "In the black window  move mouse with some button held down\n" ;
  ;;

let passive ~x ~y =
  printf "passive x=%d  y=%d\n" x y ;
  Glut.timerFunc 1000 time4 4 ;
  Glut.passiveMotionFunc (fun ~x ~y->()) ;
  ;;

let time3 ~value = 
  if (value <> 3) then failwith(" time3 expected 3\n");
  Glut.passiveMotionFunc(passive);
  printf("In the black window  mouse the mouse around with NO buttons down\n");
  ;;

let mode = ref 0;;

let mouse ~button ~state ~x ~y =
  printf "but=%s  state=%s  x=%d  y=%d  modifiers=%i\n" 
    (Glut.string_of_button button) (Glut.string_of_button_state state) 
    x y (Glut.getModifiers()) ;
  match !mode with
  | 0 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.DOWN) then
      failwith(" mouse left down not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    incr mode;
    end
  | 1 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.UP) then
      failwith(" mouse left up not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    match !mouseButtons with
    | 1 -> begin
      mode := 6;         (* Skip right or middle button tests. *)
      printf("In the black window  please click :  Shift-left  Ctrl-left  then Alt-left (in that order)\n");
      end
    | 2 -> 
      mode := 4;         (* Continue with right button test
                           (skip middle button). *)
    | 3 -> 
      mode := 2;         (* Continue with middle button test. *)
    | _ -> failwith (sprintf "invalid value for mouseButtons: %i" !mouseButtons)
    end
  | 2 -> begin
    if (button <> Glut.MIDDLE_BUTTON && state = Glut.DOWN) then
      failwith(" mouse center down not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    incr mode;
    end
  | 3 -> begin
    if (button <> Glut.MIDDLE_BUTTON && state = Glut.UP) then
      failwith(" mouse center up not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    incr mode;
    end
  | 4 -> begin
    if (button <> Glut.RIGHT_BUTTON && state = Glut.DOWN) then
      failwith(" mouse right down not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    incr mode;
    end
  | 5 -> begin
    if (button <> Glut.RIGHT_BUTTON && state = Glut.UP) then
      failwith(" mouse right up not found\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" mouse expected no modifier\n");
    printf("In the black window  please click :  Shift-left  Ctrl-left  then Alt-left (in that order)\n");
    incr mode;
    end
  | 6 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.DOWN) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_shift <> 1 then
      failwith(" mouse expected shift modifier\n");
    incr mode;
    end
  | 7 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.UP) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_shift <> 1 then
      failwith(" mouse expected shift modifier\n");
    incr mode;
    end
  | 8 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.DOWN) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_ctrl <> 1 then
      failwith(" mouse expected ctrl modifier\n");
    incr mode;
    end
  | 9 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.UP) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_ctrl = 0 then
      failwith(" mouse expected ctrl modifier\n");
    incr mode;
    end
  | 10 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.DOWN) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_alt = 0 then
      failwith(" mouse expected alt modifier\n");
    incr mode;
    end
  | 11 -> begin
    if (button <> Glut.LEFT_BUTTON && state = Glut.UP) then
      failwith(" mouse right down not found\n");
    if Glut.getModifiers() land Glut.active_alt = 0 then
      failwith(" mouse expected alt modifier\n");
    Glut.timerFunc 1000 time3 3 ;
    Glut.mouseFunc (fun ~button ~state ~x ~y -> ());
    incr mode;
    end
  | _ -> failwith(sprintf " mouse called with bad mode :  %d\n"  !mode);
  ;;

let menu ~value = failwith(" menu callback should never be called\n") ;;

let time2 ~value = 
  if (value <> 2) then failwith(" time2 expected 2\n");
  Glut.mouseFunc(mouse);

  (* By attaching and detaching a menu to each button  make
     sure button usage for menus does not mess up normal button 
     callback. *)
  ignore(Glut.createMenu(menu));
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  Glut.attachMenu(Glut.MIDDLE_BUTTON);
  Glut.attachMenu(Glut.LEFT_BUTTON);
  Glut.detachMenu(Glut.RIGHT_BUTTON);
  Glut.detachMenu(Glut.MIDDLE_BUTTON);
  Glut.detachMenu(Glut.LEFT_BUTTON);
  Glut.destroyMenu(Glut.getMenu());

  match !mouseButtons with
  | 3 -> 
    printf("In the black window  please click :  left  then middle  then right buttons (in that order)\n");
  | 2 -> 
    printf("In the black window  please click :  left  then right buttons (in that order)\n");
  | 1 -> 
    printf("In the black window  please click :  left button\n");
  | 0 -> 
    (* No mouse buttons??  Skip all subsequent tests since they 
       involve the mouse. *)
    Glut.timerFunc 1000 time7 7;
    Glut.mouseFunc (fun ~button ~state ~x ~y -> ());
  | _ -> failwith(sprintf "invalid number for mouseButtons: %i" !mouseButtons)
  ;;

let smode = ref 0;;

(* XXX Warning  sometimes an X window manager will intercept
   some keystroke like Alt-F2.  Be careful about window manager
   interference when running test6. *)

let special ~key ~x ~y = 
  printf "key=%s  x=%d  y=%d  modifiers=%i"
    (Glut.string_of_special key) x y 
    (Glut.getModifiers());
  print_newline();
  let _ = match !smode with
  | 0 -> begin
    if (key <> Glut.KEY_F2) then
      failwith(" special expected F2\n");
    if (Glut.getModifiers() <> 0) then
      failwith(" special expected no modifier\n");
    end
  | 1 -> begin
    if (key <> Glut.KEY_F2) then
      failwith(" special expected F2\n");
    if Glut.getModifiers() land Glut.active_shift = 0 then
      failwith(" special expected shift modifier\n");
    end
  | 2 -> begin
    if (key <> Glut.KEY_F2) then
      failwith(" special expected F2\n");
      if Glut.getModifiers() land Glut.active_ctrl = 0 then
      failwith(" special expected ctrl modifier\n");
    end
  | 3 -> begin
    if (key <> Glut.KEY_F2) then
      failwith(" special expected F2\n");
    if Glut.getModifiers() land Glut.active_alt = 0 then
      failwith(" special expected alt modifier\n");
    Glut.specialFunc (fun ~key ~x ~y -> ());
    Glut.timerFunc 1000 time2 2;
    end
  | _ -> failwith(sprintf "special called with bad mode :  %d\n" !smode) in
  incr smode;
  ;;

let time1 ~value = 
  printf("PLEASE EXPECT TO SEE A WARNING ON THE NEXT LINE : ");
  print_newline();
  ignore(Glut.getModifiers());
  printf("DID YOU SEE A WARNING?  IT IS AN ERROR NOT TO SEE ONE.");
  print_newline();
  if (value <> 1) then failwith(" time1 expected 1");
  Glut.specialFunc(special);
  printf("In the black window  please press : F2  Shift-F2  Ctrl-F2  then Alt-F2");
  print_newline();
  ;;

let kmode = ref 0;;

let keyboard ~key ~x ~y = 
  let c = key in 
  printf "char=%d  x=%d  y=%d  modifiers=%i" c x y (Glut.getModifiers());
  print_newline();
  let _ = match !kmode with
  | 0 -> begin
    if c <> int_of_char 'g' then failwith(" keyboard expected g\n");
    if Glut.getModifiers() <> 0 then failwith(" keyboard expected no modifier\n");
    end;
  | 1 -> begin
    if (c <> int_of_char 'G') then
      failwith(" keyboard expected G\n");
    if Glut.getModifiers() land Glut.active_shift = 0 then
      failwith(" keyboard expected shift modifier\n");
    end
  | 2 -> begin
    if (c <> 0x7) then     (* Bell  Ctrl-g *)
      failwith(" keyboard expected g\n");
    if Glut.getModifiers() land Glut.active_ctrl = 0 then
      failwith(" keyboard expected ctrl modifier\n");
    end
  | 3 -> begin
    if (c <> int_of_char 'g') then failwith(" keyboard expected g\n");
    if Glut.getModifiers() land Glut.active_alt = 0 then
      failwith(" keyboard expected alt modifier\n");
    Glut.keyboardFunc (fun ~key ~x ~y -> ());
    Glut.timerFunc 1000 time1 1 ;
    end
  | _ -> failwith(sprintf "keyboard called with bad mode :  %d\n" !kmode) in
  incr kmode;
  ;;

let time0 ~value = 
  if (value <> 0) then failwith(" time0 expected 0\n");
  Glut.keyboardFunc(keyboard);
  printf("In the black window  please press :  g  G  Ctrl-g  then Alt-g");
  print_newline();
  ;;

let main() = 
  ignore(Glut.init Sys.argv);
  mouseButtons := Glut.deviceGet(Glut.NUM_MOUSE_BUTTONS);
  if (!mouseButtons < 0) then 
    failwith(sprintf "negative mouse buttons? mouseButtons=%d\n" !mouseButtons); 
  if !mouseButtons > 3 then begin
    printf "More than 3 mouse buttons (ok).  mouseButtons=%d\n" !mouseButtons;
    mouseButtons := 3;  (* Testing only of 3 mouse buttons. *)
    end;
  mouseButtons := 0;
  ignore(Glut.createWindow("test"));
  Glut.displayFunc(display);
  Glut.timerFunc 1000 time0 0 ;
  Glut.mainLoop();
  ;;

let _ = main();;

