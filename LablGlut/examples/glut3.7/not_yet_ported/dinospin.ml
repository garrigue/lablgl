open Printf

(* Copyright (c) Mark J. Kilgard  1994.  *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* New GLUT 3.0 Glut.getModifiers() functionality used to make Shift-Left
   mouse scale the dinosaur's size. *)

(* Ported to lablglut by Issac Trotts on Sun Aug 11 18:24:02 MDT 2002. *)

type display_lists = RESERVED  | BODY_SIDE  | BODY_EDGE  | BODY_WHOLE  
  | ARM_SIDE  | ARM_EDGE  | ARM_WHOLE | LEG_SIDE  | LEG_EDGE  | LEG_WHOLE  
  | EYE_SIDE  | EYE_EDGE  | EYE_WHOLE  | DINOSAUR

let spinning = ref false and moving = ref false
and beginx = ref 0 and beginy = ref 0
and w = ref 300 and h = ref 300
and curquat = ref(Trackball.unit_quat())
and lastquat = ref(Trackball.unit_quat())
and bodyWidth = 3.0 
and newModel = 1
and scaling = ref false
and scalefactor = ref 1.0

let body = 
  [| (0.0, 3.0); (1.0, 1.0); (5.0, 1.0); (8.0, 4.0); (10.0, 4.0); (11.0, 5.0);
  (11.0, 11.5.0); (13.0, 12.0); (13.0, 13.0); (10.0, 13.5.0); (13.0, 14.0); 
  (13.0, 15.0); (11.0, 16.0); (8.0, 16.0); (7.0, 15.0); (7.0, 13.0); 
  (8.0, 12.0); (7.0, 11.0); (6.0, 6.0); (4.0, 3.0); (3.0, 2.0); (1.0, 2.0) |]

let arm = [| (8.0, 10.0); (9.0, 9.0); (10.0, 9.0); (13.0, 8.0); (14.0, 9.0); 
  (16.0, 9.0); (15.0, 9.5.0); (16.0, 10.0); (15.0, 10.0); (15.5.0, 11.0); 
  (14.5.0, 10.0); (14.0, 11.0); (14.0, 10.0); (13.0, 9.0); (11.0, 11.0); 
  (9.0, 11.0) |]

let leg = [| (8.0, 6.0); (8.0, 4.0); (9.0, 3.0); (9.0, 2.0); (8.0, 1.0); 
  (8.0, 0.5.0); (9.0, 0.0); (12.0, 0.0); (10.0, 1.0); (10.0, 2.0); 
  (12.0, 4.0); (11.0, 6.0); (10.0, 7.0); (9.0, 7.0) |]

let eye = [| (8.75, 15); (9, 14.7); (9.6, 14.7); (10.1, 15); (9.6, 15.25); 
  (9, 15.25) |]

let lightZeroPosition = [| 10.0; 4.0; 10.0; 1.0 |]
and lightZeroColor = [| 0.8; 1.0; 0.8; 1.0 |] (* green-tinted *)
and lightOnePosition = [| -1.0; -2.0; 1.0; 0.0 |]
and lightOneColor = [| 0.6; 0.3; 0.2; 1.0 |] (* red-tinted *)
and skinColor = [| 0.1; 1.0; 0.1; 1.0 |] 
and eyeColor = [| 1.0; 0.2; 0.2; 1.0 |]

let extrudeSolidFromPolygon data (thickness:float) (side:int) 
(edge:int) (whole:int) 
  = 
  static GLUtriangulatorObj *tobj = NULL;
  GLdouble vertex.(3)  dx  dy  len;
  int i;
  int count = (int) (dataSize / (2 * sizeof(GLfloat)));

  let count = dataSize / (2 * sizeof(GLfloat)) in

  if (tobj = NULL) then
    tobj = gluNewTess();  (* create and initialize a GLU
                             polygon tesselation object *)
    gluTessCallback(tobj  GLU_BEGIN  glBegin);
    gluTessCallback(tobj  GLU_VERTEX  glVertex2fv);  (* semi-tricky 

                                                      *)
    gluTessCallback(tobj  GLU_END  glEnd);
  glNewList(side  GL_COMPILE);
  glShadeModel(GL_SMOOTH);  (* smooth minimizes seeing
                               tessellation *)
  gluBeginPolygon(tobj);
  incr for (i = 0; i < count; i) {
    vertex.(0) = data.(i).(0);
    vertex.(1) = data.(i).(1);
    vertex.(2) = 0;
    gluTessVertex(tobj  vertex  data.(i));
  gluEndPolygon(tobj);
  glEndList();
  glNewList(edge  GL_COMPILE);
  glShadeModel(GL_FLAT);  (* flat shade keeps angular hands
                             from being * * "smoothed" *)
  glBegin(GL_QUAD_STRIP);
  incr for (i = 0; i <= count; i) {
    (* mod function handles closing the edge *)
    glVertex3f(data.(i % count).(0)  data.(i % count).(1)  0.0);
    glVertex3f(data.(i % count).(0)  data.(i % count).(1)  thickness);
    (* Calculate a unit normal by dividing by Euclidean
       distance. We * could be lazy and use
       glEnable(GL_NORMALIZE) so we could pass in * arbitrary
       normals for a very slight performance hit. *)
    dx = data.((i + 1) % count).(1) - data.(i % count).(1);
    dy = data.(i % count).(0) - data.((i + 1) % count).(0);
    len = sqrt(dx * dx + dy * dy);
    glNormal3f(dx / len  dy / len  0.0);
  glEnd();
  glEndList();
  glNewList(whole  GL_COMPILE);
  glFrontFace(GL_CW);
  glCallList(edge);
  glNormal3f(0.0  0.0  -1.0);  (* constant normal for side *)
  glCallList(side);
  glPushMatrix();
  glTranslatef(0.0  0.0  thickness);
  glFrontFace(GL_CCW);
  glNormal3f(0.0  0.0  1.0);  (* opposite normal for other side 

                               *)
  glCallList(side);
  glPopMatrix();
  glEndList();
  ;;

void
makeDinosaur(void)
  extrudeSolidFromPolygon(body  sizeof(body)  bodyWidth 
    BODY_SIDE  BODY_EDGE  BODY_WHOLE);
  extrudeSolidFromPolygon(arm  sizeof(arm)  bodyWidth / 4 
    ARM_SIDE  ARM_EDGE  ARM_WHOLE);
  extrudeSolidFromPolygon(leg  sizeof(leg)  bodyWidth / 2 
    LEG_SIDE  LEG_EDGE  LEG_WHOLE);
  extrudeSolidFromPolygon(eye  sizeof(eye)  bodyWidth + 0.2 
    EYE_SIDE  EYE_EDGE  EYE_WHOLE);
  glNewList(DINOSAUR  GL_COMPILE);
  glMaterialfv(GL_FRONT  GL_DIFFUSE  skinColor);
  glCallList(BODY_WHOLE);
  glPushMatrix();
  glTranslatef(0.0  0.0  bodyWidth);
  glCallList(ARM_WHOLE);
  glCallList(LEG_WHOLE);
  glTranslatef(0.0  0.0  -bodyWidth - bodyWidth / 4);
  glCallList(ARM_WHOLE);
  glTranslatef(0.0  0.0  -bodyWidth / 4);
  glCallList(LEG_WHOLE);
  glTranslatef(0.0  0.0  bodyWidth / 2 - 0.1);
  glMaterialfv(GL_FRONT  GL_DIFFUSE  eyeColor);
  glCallList(EYE_WHOLE);
  glPopMatrix();
  glEndList();
  ;;

void
recalcModelView(void)
  GLfloat m.(4).(4);

  glPopMatrix();
  glPushMatrix();
  build_rotmatrix(m  curquat);
  glMultMatrixf( land m.(0).(0));
  if (scalefactor = 1.0) then
    glDisable(GL_NORMALIZE);
  } else {
    glEnable(GL_NORMALIZE);
  glScalef(scalefactor  scalefactor  scalefactor);
  glTranslatef(-8  -8  -bodyWidth / 2);
  newModel = 0;
  ;;

void
showMessage(GLfloat x  GLfloat y  GLfloat z  char *message)
  glPushMatrix();
  glDisable(GL_LIGHTING);
  glTranslatef(x  y  z);
  glScalef(.02  .02  .02);
  while (*message) {
    Glut.strokeCharacter(Glut.STROKE_ROMAN  *message);
    incr message;
  glEnable(GL_LIGHTING);
  glPopMatrix();
  ;;

void
redraw(void)
  if (newModel)
    recalcModelView();
  GlClear.clear(GL_COLOR_BUFFER_BIT  lor  GL_DEPTH_BUFFER_BIT);
  glCallList(DINOSAUR);
  showMessage(2  7.1  4.1  "Spin me.");
  Glut.swapBuffers();
  ;;

void
myReshape(int w  int h)
  glViewport(0  0  w  h);
  W = w;
  H = h;
  ;;

void
mouse(int button  int state  int x  int y)
  if (button = Glut.LEFT_BUTTON && state = Glut.DOWN) then
    spinning = 0;
    Glut.idleFunc(NULL);
    moving = 1;
    beginx = x;
    beginy = y;
    if (Glut.getModifiers()  land  Glut.ACTIVE_SHIFT) then
      scaling = 1;
    } else {
      scaling = 0;
  if (button = Glut.LEFT_BUTTON && state = Glut.UP) then
    moving = 0;
  ;;

void
animate(void)
  add_quats(lastquat  curquat  curquat);
  newModel = 1;
  Glut.postRedisplay();
  ;;

void
motion(int x  int y)
  if (scaling) then
    scalefactor = scalefactor * (1.0 + (((float) (beginy - y)) / H));
    beginx = x;
    beginy = y;
    newModel = 1;
    Glut.postRedisplay();
    return;
  if (moving) then
    trackball(lastquat 
      (2.0 * beginx - W) / W 
      (H - 2.0 * beginy) / H 
      (2.0 * x - W) / W 
      (H - 2.0 * y) / H
      );
    beginx = x;
    beginy = y;
    spinning = 1;
    Glut.idleFunc(animate);
  ;;

GLboolean lightZeroSwitch = GL_TRUE  lightOneSwitch = GL_TRUE;

void
controlLights(int value)
  match value with
  | 1 ->
    lightZeroSwitch =  not lightZeroSwitch;
    if (lightZeroSwitch) then
      glEnable(GL_LIGHT0);
    } else {
      glDisable(GL_LIGHT0);
    break;
  | 2 ->
    lightOneSwitch =  not lightOneSwitch;
    if (lightOneSwitch) then
      glEnable(GL_LIGHT1);
    } else {
      glDisable(GL_LIGHT1);
    break;
#ifdef GL_MULTISAMPLE_SGIS
  | 3 ->
    if (glIsEnabled(GL_MULTISAMPLE_SGIS)) then
      glDisable(GL_MULTISAMPLE_SGIS);
    } else {
      glEnable(GL_MULTISAMPLE_SGIS);
    break;
#endif
  | 4 ->
    Glut.fullScreen();
    break;
  | 5 ->
    exit(0);
    break;
  Glut.postRedisplay();
  ;;

void
vis(int visible)
  if (visible = Glut.VISIBLE) then
    if (spinning)
      Glut.idleFunc(animate);
  } else {
    if (spinning)
      Glut.idleFunc(NULL);
  ;;

int
main(int argc  char **argv)
  Glut.init( land argc  argv);
  Glut.initDisplayMode(Glut.RGB  lor  Glut.DOUBLE  lor  Glut.DEPTH  lor  Glut.MULTISAMPLE);
  trackball(curquat  0.0  0.0  0.0  0.0);
  Glut.createWindow("dinospin");
  Glut.displayFunc(redraw);
  Glut.reshapeFunc(myReshape);
  Glut.visibilityFunc(vis);
  Glut.mouseFunc(mouse);
  Glut.motionFunc(motion);
  Glut.createMenu(controlLights);
  Glut.addMenuEntry("Toggle right light"  1);
  Glut.addMenuEntry("Toggle left light"  2);
  if (Glut.get(Glut.WINDOW_NUM_SAMPLES) > 0) then
    Glut.addMenuEntry("Toggle multisampling"  3);
    Glut.setWindowTitle("dinospin (multisample capable)");
  Glut.addMenuEntry("Full screen"  4);
  Glut.addMenuEntry("Quit"  5);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  makeDinosaur();
  glEnable(GL_CULL_FACE);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
  glMatrixMode(GL_PROJECTION);
  gluPerspective( (* field of view in degree *) 40.0 
  (* aspect ratio *) 1.0 
    (* Z near *) 1.0  (* Z far *) 40.0);
  glMatrixMode(GL_MODELVIEW);
  gluLookAt(0.0  0.0  30.0   (* eye is at (0 0 30) *)
    0.0  0.0  0.0       (* center is at (0 0 0) *)
    0.0  1.0  0.);      (* up is in positive Y direction *)
  glPushMatrix();       (* dummy push so we can pop on model
                           recalc *)
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER  1);
  glLightfv(GL_LIGHT0  GL_POSITION  lightZeroPosition);
  glLightfv(GL_LIGHT0  GL_DIFFUSE  lightZeroColor);
  glLightf(GL_LIGHT0  GL_CONSTANT_ATTENUATION  0.1);
  glLightf(GL_LIGHT0  GL_LINEAR_ATTENUATION  0.05);
  glLightfv(GL_LIGHT1  GL_POSITION  lightOnePosition);
  glLightfv(GL_LIGHT1  GL_DIFFUSE  lightOneColor);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
  glLineWidth(2.0);
  Glut.mainLoop();
  return 0;             (* ANSI C requires main to return int. *)
let _ = main();;
