open Printf

(* Original program Copyright (c) Mark J. Kilgard  1994.  *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Adapted and ported to lablglut by Issac Trotts on Sun Sep 1 2002. *)

let spinning = ref false 
and moving = ref false
and scaling = ref false
and xlating = ref false
and beginx = ref 0 
and beginy = ref 0
and w = ref 300 
and h = ref 300
and curquat = ref (Trackball.trackball (0.0,0.0) (0.0,0.0))
and lastquat = ref (Trackball.unit_quat())
and newModel = ref true
and scalefactor = ref 1.0

let f2i f = int_of_float f
let i2f i = float_of_int i

let recalcModelView () = 
  GlMat.pop();
  GlMat.push();
  let m = Trackball.build_rotmatrix !curquat in
  GlMat.mult m ;
  GlMat.scale ~x:!scalefactor ~y:!scalefactor ~z:!scalefactor (); 
  newModel := false;
  ;;

let showMessage x y z message = 
  GlMat.push();
  Gl.disable `lighting;
  GlMat.translate ~x ~y ~z ();
  GlMat.scale ~x:0.005 ~y:0.005 ~z:0.005 ();
  String.iter (function c->Glut.strokeCharacter Glut.STROKE_ROMAN 
    (int_of_char c)) message;
  Gl.enable `lighting ;
  GlMat.pop();
  ;;

let redraw () = 
  if (!newModel) then recalcModelView();
  GlClear.clear [`color; `depth]; 
  Glut.solidTeapot 1.0 ;
  showMessage 0.0 1.0 0.0 "Spin me."; 
  Glut.swapBuffers();
  ;;

let update_wh w' h' = 
  w := w';
  h := h';
  ;;

let myReshape ~w ~h =
  printf "reshape\n";
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  update_wh w h;
  ;;

let mouse ~button ~state ~x ~y = 
  if (button = Glut.LEFT_BUTTON && state = Glut.DOWN) then begin
    spinning := false;
    Glut.idleFunc (Some (function () -> ())); 
    moving := true;
    beginx := x;
    beginy := y;
    scaling := 
      if (Glut.getModifiers() land Glut.active_shift <> 0) then true else false;
  end;
  if (button = Glut.LEFT_BUTTON && state = Glut.UP) then moving := false;
  ;;

let animate () = 
  curquat := Trackball.add_quats !lastquat !curquat ;
  newModel := true;
  Glut.postRedisplay();
  ;;

let motion ~x ~y = 
  if (!scaling) then begin
    scalefactor := !scalefactor *. (1.0 +. ((float_of_int(!beginy - y)) /. 
      (float_of_int !h)));
    beginx := x;
    beginy := y;
    newModel := true;
    Glut.postRedisplay();
  end else if (!moving) then begin
    let x0 = i2f !beginx 
    and y0 = i2f !beginy 
    and w = i2f !w 
    and h = i2f !h in
    lastquat := Trackball.trackball 
      ~p1:((2.0 *. x0 -. w) /. w,
           (h -. 2.0 *. y0) /. h)
      ~p2:((2.0 *. (i2f x) -. w) /. w, 
           (h -. 2.0 *. (i2f y)) /. h);
    beginx := x;
    beginy := y;
    spinning := true;
    Glut.idleFunc(Some animate); 
  end
  ;;

let lightZeroSwitch = ref true and lightOneSwitch = ref true

let controlLights ~value = 
  match value with
  | 1 -> begin
    lightZeroSwitch := not !lightZeroSwitch;
    if (!lightZeroSwitch) then Gl.enable `light0 else Gl.disable `light0
    end
  | 2 -> begin
    lightOneSwitch := not !lightOneSwitch;
    if (!lightOneSwitch) then Gl.enable `light1 else Gl.disable `light1
    end
  (*
#ifdef GL_MULTISAMPLE_SGIS
  | 3 ->
    if (glIsEnabled(GL_MULTISAMPLE_SGIS)) then
      glDisable(GL_MULTISAMPLE_SGIS);
    } else {
      glEnable(GL_MULTISAMPLE_SGIS);
    break;
#endif
    *)
  | 4 -> Glut.fullScreen()
  | 5 -> exit(0)
  | _ -> ();
  Glut.postRedisplay();
  ;;

let vis ~state =
  if state = Glut.VISIBLE then begin
    if !spinning then Glut.idleFunc(Some animate);
  end else if !spinning then Glut.idleFunc(Some (function () -> ()));
  ;;

let main() = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:false ~double_buffer:true ~depth:true 
    ~multisample:true ();
  ignore(Glut.createWindow "teaspin");
  Glut.displayFunc redraw;
  Glut.reshapeFunc myReshape;
  Glut.visibilityFunc vis;
  Glut.mouseFunc mouse; 
  Glut.motionFunc motion; 
  ignore(Glut.createMenu controlLights);
  Glut.addMenuEntry "Toggle right light" 1;
  Glut.addMenuEntry "Toggle left light" 2;
  (*
  if Glut.get Glut.WINDOW_NUM_SAMPLES > 0 then begin
    Glut.addMenuEntry "Toggle multisampling" 3;
    Glut.setWindowTitle "teaspin (multisample capable)";
  end
  *)
  Glut.addMenuEntry "Full screen" 4;
  Glut.addMenuEntry "Quit"  5;
  Glut.attachMenu Glut.RIGHT_BUTTON;
  (* Gl.enable `cull_face; *)
  GlMat.mode `projection;
  GluMat.perspective ~fovy:40.0 ~aspect:1.0 ~z:(1.0, 40.0) ;
  GlMat.mode `modelview;
  GluMat.look_at 
    ~eye:(0.0,0.0,10.0) 
    ~center:(0.0,0.0,0.0)
    ~up:(0.0,1.0,0.0);
  GlMat.push();  (* dummy push so we can pop on model recalc *)
  List.iter Gl.enable [`lighting; `light0; `light1; `depth_test ];
  GlLight.light ~num:0 (`diffuse (0.9, 0.3, 0.3, 1.0)) ;
  GlLight.light ~num:0 (`position (1.0, 1.0, 1.0, 1.0)) ;
  GlLight.light ~num:1 (`diffuse (0.3, 0.2, 0.9, 1.0)) ;
  GlLight.light ~num:1 (`position (-1.0, -1.0, 1.0, 1.0)) ;
  GlDraw.line_width 2.0;
  Glut.mainLoop();
  ;;

let _ = main()

