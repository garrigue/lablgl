#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:22:04 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

let joystick ~buttonMask ~x ~y ~z = 
  printf "joy 0x%x  x=%d y=%d z=%d\n"  buttonMask  x  y  z;
  ;;

let joyPoll () = 
  printf("force"); print_newline();
  Glut.forceJoystickFunc();
  ;;

let menu ~value = 
  match value with
  | 1 -> begin
    Glut.joystickFunc joystick  100 ;
    Glut.idleFunc None;
    end
  | 2 -> begin
    Glut.joystickFunc (fun ~buttonMask ~x ~y ~z ->())  0;
    Glut.idleFunc None;
    end
  | 3 -> begin
    Glut.joystickFunc joystick  0 ;
    Glut.idleFunc(Some joyPoll);
    end
  | _ -> failwith "invalid menu value"
  ;;

let display () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let keyboard ~key ~x ~y = 
  if (key = 27) then exit(0);
  ;;

let main() = 
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow("joystick test"));
  GlClear.color (0.29, 0.62, 1.0) ;
  Glut.displayFunc(display);
  Glut.keyboardFunc(keyboard);
  ignore(Glut.createMenu(menu));
  Glut.addMenuEntry "Enable joystick callback"  1 ;
  Glut.addMenuEntry "Disable joystick callback"  2 ;
  Glut.addMenuEntry "Force joystick polling"  3 ;
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  Glut.mainLoop();
  ;;

let _ = main();;

