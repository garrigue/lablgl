
(* Ported to lablglut by Issac Trotts on Sun Aug 11 14:56:08 MDT 2002. *)

open Printf

(** 
 * My first GLUT prog.
 * Uses most GLUT calls to prove it all works.
 * G Edwards  30 Aug 95.
 *
 * Notes:
 * Display lists are not shared between windows  and there doesn't seem to be
 *  any provision for this in GLUT. See glxCreateContext.
 *
 * The windows are internally indexed 0 1 2 3 4 5 6. The actual window ids
 * returned by Glut. are held in winId.(0)  ...
 *
 * Todo:
 *
 * Could reorder the windows so 0 1 2 3 4 5 6 are the gfx  7 8 text.
 *
 * 30 Aug 95  GJE  Created. Version 1.00
 * 05 Sep 95  GJE  Version 1.01. 
 * 07 Sep 95  GJE  Version 1.02. More or less complete. All possible GLUT
 *                 calls used  except dials/buttons/tablet/spaceball stuff.
 * 15 Sep 95  GJE  Add "trackball" code.
 *
 *  Calls not used yet: these callbacks are registered but inactive.
 *
 *  Glut.spaceball<xxx>Func
 *  Glut.buttonBoxFunc
 *  Glut.dialsFunc
 *  Glut.tabletMotionFunc
 *  Glut.tabletButtonFunc
 *
 * Tested on:
 *  R3K Indigo Starter
 *  R4K Indigo Elan
 *  R4K Indy XZ
 *  R4K Indy XL
 *  R4K Indigo2 Extreme
 *)

(* Controls *)

let version = "1.00"
let date    = "17Aug02"
let delay     = ref 1000 (* delay for timer test *)
let menudelay = ref 200  (* hack to fix Glut.menuStateFunc bug *)
let maxwin    = ref 9    (* max no. of windows *)

let autodelay = ref 1500;(* delay in demo mode  *)

let pos = [|
  (50, 150);             (* win 0  *)
  (450, 150);            (* win 1  *)
  (50, 600);             (* win 2  *)
  (450, 600);            (* win 3  *)
  (10, 10);              (* subwin 4 (relative to parent win 0) *)
  (300, 400);            (* help win 5  *)
  (850, 150);            (* cmap win 6  *)
  (850, 600);            (* cmap win 7  *)
  (250, 450);            (* text win 8  *)
|]

let size = [|
  (350, 350);            (* win 0  *)
  (350, 350);            (* win 1  *)
  (350, 350);            (* win 2  *)
  (350, 350);            (* win 3  *)
  (200, 200);            (* subwin 4  *)
  (700, 300);            (* help win 5  *)
  (350, 350);            (* cmap win 6  *)
  (350, 350);            (* cmap win 7  *)
  (800, 450);            (* text win 8  *)
|]

let pr stuff = if !debug printf stuff

(* #define GLNEWLIST(a  b)  glNewList(a  b)  fprintf(stderr 
   "creating list %d \n"  a); *)
(* #define GLCALLLIST(a)    glCallList(a)  fprintf(stderr 
   "calling list %d \n"  a); *)
(* #define GLUTSETWINDOW(x) Glut.setWindow(x)  fprintf(stderr 
   "gsw at %d\n"  __LINE__) *)

(* Globals *)

let winId = ref [| 0 |] (* table of Glut. window IDs  *)
let winVis = ref [| false |] (* is window visible  *)

let text = ref [| false |]              (* is text on  *)
let winFreeze = ref [| false |]         (* user requested menuFreeze  *)
let menuFreeze = ref false              (* menuFreeze while menus posted  *)
let timerOn = ref false                 (* timer active  *)
let animation = ref true                (* idle func animation on  *)
let debug = ref false;                  (* dump all events  *)
let showKeys = ref false                (* dump key events  *)
let demoMode = ref false                (* run automatic demo  *)
let backdrop = ref false                (* use backdrop polygon  *)
let passive = ref false                 (* report passive motions  *)
let leftDown = ref false                (* left button down ?  *)
let middleDown = ref false              (* middle button down ?  *)

let displayMode = Glut.double  lor  Glut.rgb  lor  Glut.depth
let currentShape = ref 0                (* current Glut. shape  *)
let scrollLine = ref 0 and scrollCol = ref 0;(* help scrolling params  *)
let lineWidth = ref 1                   (* line width  *)
let angle = ref 0                       (* global rotation angle  *)
let textPtr = ""                        (* pointers to text window text  *)
let textCount = ref 0 and helpCount = ref 0(* text list indexes  *)
let scaleFactor = ref 0.0;              (* window size scale factor  *)

let menu1 = ref(-1) and  menu2 = ref(-1) and  menu3 = ref(-1) 
let menu4 = ref(-1) and  menu5 = ref(-1) and  menu6 = ref 0 
let menu7 = ref(-1) and  menu8 = ref(-1)

let modeNames m = 
  (if m land Glut.rgba then "RGBA " else "") ^
  (if m land Glut.index then "INDEX " else "") ^
  (if m land Glut.single then "SINGLE " else "") ^
  (if m land Glut.doublebuffer then "DOUBLEBUFFER " else "") ^
  (if m land Glut.depth then "DEPTH " else "") ^
  (if m land Glut.accum then "ACCUM " else "") ^
  (if m land Glut.alpha then "ALPHA " else "") ^
  (if m land Glut.stencil then "STENCIL " else "") ^
  (if m land Glut.multisample then "MULTISAMPLE " else "") ^
  (if m land Glut.stereo then "STEREO " else "") ^

let modes = ref 0 (* bit set for modes *)

let menuButton = [| false; false; true |]

type mode_t = 
  | MOUSEBUTTON
  | MOUSEMOTION
  | APPLY
  | RESET

let main () = 
  ignore(Glut.init Sys.argv);
  checkArgs ();
  (* Scale window position/size if needed. Ignore aspect ratios. *)
  if (scaleFactor > 0.0) 
  then scaleWindows(scaleFactor)
  else scaleWindows((Glut.get Glut.SCREEN_WIDTH) / 1280.0);

  (* Set initial display mode *)  
  modes := Glut.rgba lor Glut.doublebuffer lor Glut.depth;
  setInitDisplayMode();

  makeMenus();
  makeWindow(0);
  makeWindow(1);

  Glut.idleFunc(idleFunc);
  Glut.menuStateFunc(menuStateFunc);

  if (demoMode) then autoDemo(-2);

  Glut.mainLoop();
;;

(* gfxInit - Init opengl for each window *)

let gfxInit index = 
  let grey10 = (0.10, 0.10, 0.10, 1.0) in
  let grey20 = (0.2, 0.2, 0.2, 1.0) in
  let black = (0.0, 0.0, 0.0, 0.0) in
  let diffuse0 = (1.0, 0.0, 0.0, 1.0) in
  let diffuse1 = (0.0, 1.0, 0.0, 1.0) in
  let diffuse2 = (1.0, 1.0, 0.0, 1.0) in
  let diffuse3 = (0.0, 1.0, 1.0, 1.0) in
  let diffuse4 = (1.0, 0.0, 1.0, 1.0) in

  let xx = 3.0 in
  let yy = 3.0 in 
  let zz = (-2.5) in

  let vertex = [|
    (-. xx, -. yy, zz);
    (   xx, -. yy, zz);
    (   xx,    yy, zz);
    (-. xx,    yy, zz);
  |]

  (* warning: This func mixes RGBA and CMAP calls in an ugly
     fashion *)

  redefineShapes(!currentShape);  (* set up display lists  *)
  Glut.setWindow(winId.(index));  (* hack - redefineShapes
                                   changes Glut. win *)

  (* Shaded backdrop square (RGB or CMAP) *)

  glNewList(100  GL_COMPILE);
  glPushAttrib(GL_LIGHTING);
  glDisable(GL_LIGHTING);
  glBegin(GL_POLYGON);

  glColor4fv(black);
  glIndexi(0);
  glVertex3fv(vertex.(0));

  glColor4fv(grey10);
  glIndexi(3);
  glVertex3fv(vertex.(1));

  glColor4fv(grey20);
  glIndexi(4);
  glVertex3fv(vertex.(2));

  glColor4fv(grey10);
  glIndexi(7);
  glVertex3fv(vertex.(3));

  glEnd();
  glPopAttrib();
  glIndexi(9);
  glEndList();

(* Set proj+view *)

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(40.0  1.0  1.0  20.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  gluLookAt(0.0  0.0  5.0  0.0  0.0  0.0  0.0  1.0  0.);
  glTranslatef(0.0  0.0  -1.0);

  if (index = 6 || index = 7)
    goto colorindex;

(* Set basic material  lighting for RGB windows *)

  if (index = 0)
    glMaterialfv(GL_FRONT  GL_DIFFUSE  diffuse0);
  else if (index = 1)
    glMaterialfv(GL_FRONT  GL_DIFFUSE  diffuse1);
  else if (index = 2)
    glMaterialfv(GL_FRONT  GL_DIFFUSE  diffuse2);
  else if (index = 3)
    glMaterialfv(GL_FRONT  GL_DIFFUSE  diffuse3);
  else if (index = 4)
    glMaterialfv(GL_FRONT  GL_DIFFUSE  diffuse4);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);

  if (index = 4)
    GlClear.clearColor(0.15  0.15  0.15  1);
  else
    GlClear.clearColor(0.1  0.1  0.1  1.0);

  return;

(* Set GL basics for CMAP windows 6 7 *)

colorindex:

  glEnable(GL_DEPTH_TEST);
  if (Glut.get(Glut.WINDOW_COLORMAP_SIZE) < 16)
    warning("Color map size too small for color index window");

(* Try to reuse an existing color map *)

  if ((index = 6) && (winId.(7) <> 0)) then
    Glut.copyColormap(winId.(7));
  } else if ((index = 7) && (winId.(6) <> 0)) then
    Glut.copyColormap(winId.(6));
  } else {
    Glut.setColor(8  0.1  0.1  0.1);
    Glut.setColor(9  1.0  0.5  0.0);
    Glut.setColor(10  1.0  0.6  0.8);
  GlClear.clearIndex(8);
  glIndexi(index + 3);

  ;;

(* makeMenus - Create popup menus *)

void
makeMenus(void)

(* General control / debug *)

  menu2 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("toggle auto demo mode (a)"  312);
  Glut.addMenuEntry("toggle freezing in menus"  300);
  Glut.addMenuEntry("toggle text per window (t)"  301);
  Glut.addMenuEntry("toggle global timer"  302);
  Glut.addMenuEntry("toggle global animation"  303);
  Glut.addMenuEntry("toggle per window animation"  304);
  Glut.addMenuEntry("toggle debug prints (D)"  305);
  Glut.addMenuEntry("toggle shaded backdrop"  307);
  Glut.addMenuEntry("toggle passive motion callback"  308);
  Glut.addMenuEntry("increase line width (l)"  310);
  Glut.addMenuEntry("decrease line width  (L)"  311);

(* Shapes *)

  menu3 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("sphere"  200);
  Glut.addMenuEntry("cube"  201);
  Glut.addMenuEntry("cone"  202);
  Glut.addMenuEntry("torus"  203);
  Glut.addMenuEntry("dodecahedron"  204);
  Glut.addMenuEntry("octahedron"  205);
  Glut.addMenuEntry("tetrahedron"  206);
  Glut.addMenuEntry("icosahedron"  207);
  Glut.addMenuEntry("teapot"  208);

(* Open/close windows *)

  menu4 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("open all windows"  450);
  Glut.addMenuEntry("close all windows"  451);
  Glut.addMenuEntry(" "  9999);
  Glut.addMenuEntry("create win 0"  400);
  Glut.addMenuEntry("create win 1"  401);
  Glut.addMenuEntry("create win 2"  402);
  Glut.addMenuEntry("create win 3"  403);
  Glut.addMenuEntry("create sub window"  404);
  Glut.addMenuEntry("create color index win 6"  406);
  Glut.addMenuEntry("create color index win 7"  407);
  Glut.addMenuEntry(" "  9999);
  Glut.addMenuEntry("destroy win 0"  410);
  Glut.addMenuEntry("destroy win 1"  411);
  Glut.addMenuEntry("destroy win 2"  412);
  Glut.addMenuEntry("destroy win 3"  413);
  Glut.addMenuEntry("destroy sub window"  414);
  Glut.addMenuEntry("destroy color index win 6"  416);
  Glut.addMenuEntry("destroy color index win 7"  417);

(* Window manager stuff *)

  menu5 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("move current win"  430);
  Glut.addMenuEntry("resize current win"  431);
  Glut.addMenuEntry("iconify current win"  432);
  Glut.addMenuEntry("show current win"  433);
  Glut.addMenuEntry("hide current win"  434);
  Glut.addMenuEntry("push current win"  435);
  Glut.addMenuEntry("pop current win"  436);
  Glut.addMenuEntry(" "  9999);
  Glut.addMenuEntry("move win 1"  420);
  Glut.addMenuEntry("resize win 1"  421);
  Glut.addMenuEntry("iconify win 1"  422);
  Glut.addMenuEntry("show win 1"  423);
  Glut.addMenuEntry("hide win 1"  424);
  Glut.addMenuEntry("push win 1"  425);
  Glut.addMenuEntry("pop win 1"  426);

(* Gfx modes *)

  createMenu6();        (* build dynamically  *)

(* Texty reports *)

  menu7 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("report current win modes"  700);
  Glut.addMenuEntry("report current device data"  701);
  Glut.addMenuEntry("check OpenGL extensions"  702);
  Glut.addMenuEntry("dump internal data (d)"  703);

(* Play with menus *)

  menu8 = Glut.createMenu(menuFunc);
  Glut.addMenuEntry("toggle menus on left button"  805);
  Glut.addMenuEntry("toggle menus on middle button"  806);
  Glut.addMenuEntry("toggle menus on right button"  807);
  Glut.addMenuEntry("---------------------------"  9999);
  Glut.addMenuEntry("add plain items"  800);
  Glut.addMenuEntry("add submenu items"  801);
  Glut.addMenuEntry("change new entries to plain items"  802);
  Glut.addMenuEntry("change new entries to submenus"  803);
  Glut.addMenuEntry("remove all new items"  804);
  Glut.addMenuEntry("---------------------------"  9999);

(* Main menu *)

  menu1 = Glut.createMenu(menuFunc);
  Glut.addSubMenu("control"  menu2);
  Glut.addSubMenu("shapes"  menu3);
  Glut.addSubMenu("windows"  menu4);
  Glut.addSubMenu("window ops"  menu5);
  Glut.addSubMenu("gfx modes"  menu6);
  Glut.addSubMenu("reports"  menu7);
  Glut.addSubMenu("menus"  menu8);
  Glut.addMenuEntry("help (h)"  101);
  Glut.addMenuEntry("quit (esc)"  100);
  ;;

(* createMenu6 - Dynamically rebuild menu of display modes to
   show current choices *)

void
createMenu6(void)
  char str.(100);
  int i;

  if (menu6 <> 0)
    Glut.destroyMenu(menu6);
  menu6 = Glut.createMenu(menuFunc);

  incr for (i = 0; i < MODES; i) {
    sprintf(str  "%srequest %s"  (modes land ((i) ? "+ " : "   ")  modeNames.(i));
    Glut.addMenuEntry(str  602 + i);
  ;;

(* menuFunc - Process return codes from popup menus *)

void
menuFunc(int value)
  static int initItems = 10;
  int items  m;

  if (initItems = 0) then
    Glut.setMenu(menu8);
    initItems = Glut.get(Glut.MENU_NUM_ITEMS);
  PR("Menu returned value %d \n"  value);

  match value with

(* GLUT shapes *)

  | 200 ->
  | 201 ->
  | 202 ->
  | 203 ->
  | 204 ->
  | 205 ->
  | 206 ->
  | 207 ->
  | 208 ->
    redefineShapes(value - 200);
    break;

(* Overall controls *)

  | 300 ->
    menuFreeze =  not menuFreeze;
    break;

  | 301 ->
    text.(idToIndex(Glut.getWindow())) =  not (text.(idToIndex(Glut.getWindow())));
    break;

  | 302 ->
    timerOn =  not timerOn;
    if (timerOn)
      Glut.timerFunc(DELAY  timerFunc  1);
    break;

  | 303 ->
    animation =  not animation;
    if (animation)
      Glut.idleFunc(idleFunc);
    else
      Glut.idleFunc(NULL);
    break;

  | 304 ->
    winFreeze.(idToIndex(Glut.getWindow())) =  not (winFreeze[idToIndex(
          Glut.getWindow())]);
    break;

  | 305 ->
    debug =  not debug;
    break;

  | 307 ->
    backdrop =  not backdrop;
    break;

  | 308 ->
    passive =  not passive;
    if (passive)
      Glut.passiveMotionFunc(passiveMotionFunc);
    else
      Glut.passiveMotionFunc(NULL);
    break;

  | 310 ->
    lineWidth += 1;
    updateAll();
    break;

  | 311 ->
    lineWidth -= 1;
    if (lineWidth < 1)
      lineWidth = 1;
    updateAll();
    break;

  | 312 ->
    demoMode =  not demoMode;
    if (demoMode)
      autoDemo(-2);
    break;

(* Window create/destroy. *)

(* Creates *)

  | 400 ->
    makeWindow(0);
    break;

  | 401 ->
    makeWindow(1);
    break;

  | 402 ->
    makeWindow(2);
    break;

  | 403 ->
    makeWindow(3);
    break;

  | 404 ->
    makeWindow(4);
    break;

  | 406 ->
    makeWindow(6);
    break;

  | 407 ->
    makeWindow(7);
    break;

(* Destroys *)

  | 410 ->
    killWindow(0);
    break;

  | 411 ->
    killWindow(1);
    break;

  | 412 ->
    killWindow(2);
    break;

  | 413 ->
    killWindow(3);
    break;

  | 414 ->
    killWindow(4);
    break;

  | 416 ->
    killWindow(6);
    break;

  | 417 ->
    killWindow(7);
    break;

  | 450 ->
    makeAllWindows();
    break;

  | 451 ->
    killAllWindows();
    break;

(* Window movements etc. *)

  | 420 ->
    positionWindow(1);
    break;

  | 421 ->
    reshapeWindow(1);
    break;

  | 422 ->
    iconifyWindow(1);
    break;

  | 423 ->
    showWindow(1);
    break;

  | 424 ->
    hideWindow(1);
    break;

  | 425 ->
    pushWindow(1);
    break;

  | 426 ->
    popWindow(1);
    break;

  | 430 ->
    positionWindow(idToIndex(Glut.getWindow()));
    break;

  | 431 ->
    reshapeWindow(idToIndex(Glut.getWindow()));
    break;

  | 432 ->
    iconifyWindow(idToIndex(Glut.getWindow()));
    break;

  | 433 ->
    showWindow(idToIndex(Glut.getWindow()));
    break;

  | 434 ->
    hideWindow(idToIndex(Glut.getWindow()));
    break;

  | 435 ->
    pushWindow(idToIndex(Glut.getWindow()));
    break;

  | 436 ->
    popWindow(idToIndex(Glut.getWindow()));
    break;

(* Test gfx modes. *)

  | 600 ->
    makeWindow(3);
    break;

  | 601 ->
    killWindow(3);
    break;

  | 602 ->
  | 603 ->
  | 604 ->
  | 605 ->
  | 606 ->
  | 607 ->
  | 608 ->
  | 609 ->
  | 610 ->
  | 611 ->
    modes.(value - 602) =  not modes.(value - 602);
    setInitDisplayMode();
    break;

(* Text reports *)

(* This is pretty ugly. *)

#define INDENT 30
#define REPORTSTART(text)                          \
        printf("\n" text "\n");                    \
        textPtr.(0) = (char *)malloc(strlen(text)+1); \
	strcpy(textPtr.(0)  text);                  \
        textCount = 1;

#define REPORTEND                                  \
        scrollLine = 0;                            \
        textPtr.(textCount) = NULL;                 \
        makeWindow(8);                             \
        updateText();

#define GLUTGET(name)                              \
       {                                           \
          char str.(100)  str2.(100);                \
          int s  len;                              \
          sprintf(str  # name);                    \
          len = (int) strlen(# name);              \
          incr for(s = 0 ; s < INDENT-len; s)         \
            strcat(str  " ");                      \
          sprintf(str2  ": %d\n" Glut.get(name));   \
	  strcat(str  str2);                       \
	  printf(str);                             \
	  textPtr.(textCount) = str \
 	  incr textCount;                             \

  | 700 ->

    printf("XXXXXX Glut.getWindow = %d\n"  Glut.getWindow());
    REPORTSTART("Glut.get():");

    GLUTGET(Glut.WINDOW_X);
    GLUTGET(Glut.WINDOW_Y);
    GLUTGET(Glut.WINDOW_WIDTH);
    GLUTGET(Glut.WINDOW_HEIGHT);
    GLUTGET(Glut.WINDOW_BUFFER_SIZE);
    GLUTGET(Glut.WINDOW_STENCIL_SIZE);
    GLUTGET(Glut.WINDOW_DEPTH_SIZE);
    GLUTGET(Glut.WINDOW_RED_SIZE);
    GLUTGET(Glut.WINDOW_GREEN_SIZE);
    GLUTGET(Glut.WINDOW_BLUE_SIZE);
    GLUTGET(Glut.WINDOW_ALPHA_SIZE);
    GLUTGET(Glut.WINDOW_ACCUM_RED_SIZE);
    GLUTGET(Glut.WINDOW_ACCUM_GREEN_SIZE);
    GLUTGET(Glut.WINDOW_ACCUM_BLUE_SIZE);
    GLUTGET(Glut.WINDOW_ACCUM_ALPHA_SIZE);
    GLUTGET(Glut.WINDOW_DOUBLEBUFFER);
    GLUTGET(Glut.WINDOW_RGBA);
    GLUTGET(Glut.WINDOW_PARENT);
    GLUTGET(Glut.WINDOW_NUM_CHILDREN);
    GLUTGET(Glut.WINDOW_COLORMAP_SIZE);
    GLUTGET(Glut.WINDOW_NUM_SAMPLES);
    GLUTGET(Glut.STEREO);
    GLUTGET(Glut.SCREEN_WIDTH);
    GLUTGET(Glut.SCREEN_HEIGHT);
    GLUTGET(Glut.SCREEN_HEIGHT_MM);
    GLUTGET(Glut.SCREEN_WIDTH_MM);
    GLUTGET(Glut.MENU_NUM_ITEMS);
    GLUTGET(Glut.DISPLAY_MODE_POSSIBLE);
    GLUTGET(Glut.INIT_DISPLAY_MODE);
    GLUTGET(Glut.INIT_WINDOW_X);
    GLUTGET(Glut.INIT_WINDOW_Y);
    GLUTGET(Glut.INIT_WINDOW_WIDTH);
    GLUTGET(Glut.INIT_WINDOW_HEIGHT);
    GLUTGET(Glut.ELAPSED_TIME);

    REPORTEND;
    break;

#define GLUTDEVGET(name)                         \
        {                                        \
          char str.(100)  str2.(100);              \
          int len  s;                            \
          sprintf(str  # name);                  \
          len = (int) strlen(# name);            \
          incr for(s = 0 ; s < INDENT-len; s)       \
            strcat(str  " ");                    \
          sprintf(str2  ": %d\n"                 \
	     Glut.deviceGet(name));               \
	  strcat(str  str2);                     \
	  printf(str);                           \
	  textPtr.(textCount) = str;    \
 	  incr textCount;                           \

  | 701 ->
    REPORTSTART("Glut.deviceGet():");

    GLUTDEVGET(Glut.HAS_KEYBOARD);
    GLUTDEVGET(Glut.HAS_MOUSE);
    GLUTDEVGET(Glut.HAS_SPACEBALL);
    GLUTDEVGET(Glut.HAS_DIAL_AND_BUTTON_BOX);
    GLUTDEVGET(Glut.HAS_TABLET);
    GLUTDEVGET(Glut.NUM_MOUSE_BUTTONS);
    GLUTDEVGET(Glut.NUM_SPACEBALL_BUTTONS);
    GLUTDEVGET(Glut.NUM_BUTTON_BOX_BUTTONS);
    GLUTDEVGET(Glut.NUM_DIALS);
    GLUTDEVGET(Glut.NUM_TABLET_BUTTONS);

    REPORTEND;
    break;

#define EXTCHECK(name)                           \
        {                                        \
          char str.(100)  str2.(100);              \
          int len  s;                            \
          sprintf(str  # name);                  \
          len = (int) strlen(# name);            \
          incr for(s = 0 ; s < INDENT-len; s)       \
            strcat(str  " ");                    \
          sprintf(str2  ": %s\n"                 \
	     Glut.extensionSupported(# name)?     \
	       "yes": "no");                     \
	  strcat(str  str2);                     \
	  printf(str);                           \
	  textPtr.(textCount) = str;    \
 	  incr textCount;                           \

  | 702 ->
    REPORTSTART("Glut.extensionSupported():");

    EXTCHECK(GL_EXT_abgr);
    EXTCHECK(GL_EXT_blend_color);
    EXTCHECK(GL_EXT_blend_minmax);
    EXTCHECK(GL_EXT_blend_logic_op);
    EXTCHECK(GL_EXT_blend_subtract);
    EXTCHECK(GL_EXT_polygon_offset);
    EXTCHECK(GL_EXT_texture);
    EXTCHECK(GL_EXT_guaranteed_to_fail);
    EXTCHECK(GLX_SGI_swap_control);
    EXTCHECK(GLX_SGI_video_sync);
    EXTCHECK(GLX_SGIS_multi_sample);

    REPORTEND;
    break;

  | 703 ->
    dumpIds();
    break;

(* Mess around with menus *)

  | 800 ->
    if (Glut.getMenu() <> menu8)  (* just a test  *)
      printf("Glut.getMenu() returned unexpected value\n");
    Glut.addMenuEntry("help"  101);
    Glut.addMenuEntry("help"  101);
    Glut.addMenuEntry("help"  101);
    Glut.addMenuEntry("help"  101);
    Glut.addMenuEntry("help"  101);
    break;

  | 801 ->
    Glut.addSubMenu("shapes"  menu3);
    Glut.addSubMenu("shapes"  menu3);
    Glut.addSubMenu("shapes (a long string to break menus with)"  menu3);
    Glut.addSubMenu("shapes"  menu3);
    Glut.addSubMenu("shapes"  menu3);
    break;

  | 802 ->
    items = Glut.get(Glut.MENU_NUM_ITEMS);
    incr for (m = initItems + 1; m <= items; m) {
      Glut.changeToMenuEntry(m  "help"  101);
    break;

  | 803 ->
    items = Glut.get(Glut.MENU_NUM_ITEMS);
    incr for (m = initItems + 1; m <= items; m) {
      Glut.changeToSubMenu(m  "shapes"  menu3);
    break;

  | 804 ->
    items = Glut.get(Glut.MENU_NUM_ITEMS);
    (* reverse order so renumbering not aproblem  *)
    for (m = items; m >= initItems + 1; m--) {
      Glut.removeMenuItem(m);
    break;

  | 805 ->
    menuButton.(0) =  not menuButton.(0);
    attachMenus();
    break;

  | 806 ->
    menuButton.(1) =  not menuButton.(1);
    attachMenus();
    break;

  | 807 ->
    menuButton.(2) =  not menuButton.(2);
    attachMenus();
    break;

(* Direct menu items.  *)

  | 100 ->
    exit(0);
    break;

  | 101 ->
    if (winId.(5) = 0)
      makeWindow(5);
    else
      killWindow(5);
    break;

  | 9999 ->
    break;

  | _ -> 
    fprintf(stderr  "\007Unhandled case %d in menu callback\n"  value);

  ;;

(* redefineShapes - Remake the shapes display lists *)

void
redefineShapes(int shape)
  int i;

#define C3                \
   	 switch(i)        \
	 {                \
	     | 0 ->      \
	     | 3 ->      \
	       C1;        \
	       break;     \
	                  \
	     | 1 ->      \
	     | 2 ->      \
	     | 4 ->      \
	     | 6 ->      \
	     | 7 ->      \
	       C2;        \
	       break;     \
	 }                \
	 currentShape = shape

  incr for (i = 0; i < MAXWIN; i) {
    if (winId.(i)) then
      Glut.setWindow(winId.(i));
      if (glIsList(i + 1))
        glDeleteLists(i + 1  1);
      glNewList(i + 1  GL_COMPILE);

      match shape with

#undef  C1
#define C1  Glut.solidSphere(1.5  10  10)
#undef  C2
#define C2  Glut.wireSphere(1.5  10  10)

      | 0 ->
        C3;
        break;

#undef  C1
#define C1 Glut.solidCube(2)
#undef  C2
#define C2 Glut.wireCube(2)

      | 1 ->
        C3;
        break;

#undef  C1
#define C1 Glut.solidCone(1.5  1.75  10  10);
#undef  C2
#define C2 Glut.wireCone(1.5  1.75  10  10);

      | 2 ->
        C3;
        break;

#undef  C1
#define C1 Glut.solidTorus(0.5  1.1  10  10)
#undef  C2
#define C2 Glut.wireTorus(0.5  1.1  10  10)

      | 3 ->
        C3;
        break;

#undef  C1
#define C1 glScalef(.8  .8  .8);Glut.solidDodecahedron()
#undef  C2
#define C2 glScalef(.8  .8  .8);Glut.wireDodecahedron()

      | 4 ->
        C3;
        break;

#undef  C1
#define C1 glScalef(1.5  1.5  1.5);Glut.solidOctahedron()
#undef  C2
#define C2 glScalef(1.5  1.5  1.5);Glut.wireOctahedron()

      | 5 ->
        C3;
        break;

#undef  C1
#define C1 glScalef(1.8  1.8  1.8);Glut.solidTetrahedron()
#undef  C2
#define C2 glScalef(1.8  1.8  1.8);Glut.wireTetrahedron()

      | 6 ->
        C3;
        break;

#undef  C1
#define C1 glScalef(1.5  1.5  1.5);Glut.solidIcosahedron()
#undef  C2
#define C2 glScalef(1.5  1.5  1.5);Glut.wireIcosahedron()

      | 7 ->
        C3;
        break;

#undef  C1
#define C1 Glut.solidTeapot(1.5);
#undef  C2
#define C2 Glut.wireTeapot(1.5);

      | 8 ->
        C3;
        break;
      glEndList();
  ;;

(* positionWindow - Shift a window *)

void
positionWindow(int index)
  int x  y;

  if (winId.(index) = 0)
    return;

  Glut.setWindow(winId.(index));
  x = Glut.get(Glut.WINDOW_X);
  y = Glut.get(Glut.WINDOW_Y);
  Glut.positionWindow(x + 50  y + 50);
  ;;

(* reshapeWindow - Change window size a little *)

void
reshapeWindow(int index)
  int x  y;

  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  x = Glut.get(Glut.WINDOW_WIDTH);
  y = Glut.get(Glut.WINDOW_HEIGHT);
(* Glut.reshapeWindow(x * (index % 2? 0.8: 1.2)  y * (index % 2? 

   1.2: 0.8)); *)
  Glut.reshapeWindow((int) (x * 1.0)  (int) (y * 0.8));
  ;;

(* iconifyWindow - Iconify a window *)

void
iconifyWindow(int index)
  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  Glut.iconifyWindow();
  ;;

(* showWindow - Show a window (map or uniconify it) *)

void
showWindow(int index)
  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  Glut.showWindow();
  ;;

(* hideWindow - Hide a window (unmap it) *)

void
hideWindow(int index)
  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  Glut.hideWindow();
  ;;

(* pushWindow - Push a window *)

void
pushWindow(int index)
  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  Glut.pushWindow();
  ;;

(* popWindow - Pop a window *)

void
popWindow(int index)
  if (winId.(index) = 0)
    return;
  Glut.setWindow(winId.(index));
  Glut.popWindow();
  ;;

(* drawScene - Draw callback  triggered by expose events etc.
   in GLUT. *)

void
drawScene(void)
  int winIndex;

  GlClear.clear(GL_COLOR_BUFFER_BIT  lor  GL_DEPTH_BUFFER_BIT);

  winIndex = idToIndex(Glut.getWindow());
  (* printf("drawScene for index %d  id %d\n"  winIndex 
     Glut.getWindow());  *)

  glPushMatrix();
  glLineWidth(lineWidth);
  if (backdrop)
    glCallList(100);

  (* Left button spinning  *)

  trackBall(APPLY  0  0  0  0);

  (* Apply continuous spinning  *)

  glRotatef(angle  0  1  0);

  glCallList(winIndex + 1);
  glPopMatrix();

  if (text.(winIndex))
    showText();

  Glut.swapBuffers();
  ;;

(* showText - Render some text in the current GLUT window *)

void
showText(void)
  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  gluOrtho2D(0  100  0  100);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f(1.0  1.0  1.0);
  glIndexi(7);

  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);

  glLineWidth(lineWidth);

  textString(1  1  "Glut.BITMAP_8_BY_13"  Glut.BITMAP_8_BY_13);
  textString(1  5  "Glut.BITMAP_9_BY_15"  Glut.BITMAP_9_BY_15);
  textString(1  10  "Glut.BITMAP_TIMES_ROMAN_10"  Glut.BITMAP_TIMES_ROMAN_10);
  textString(1  15  "Glut.BITMAP_TIMES_ROMAN_24"  Glut.BITMAP_TIMES_ROMAN_24);

  strokeString(1  25  "Glut.STROKE_ROMAN"  Glut.STROKE_ROMAN);
  strokeString(1  35  "Glut.STROKE_MONO_ROMAN"  Glut.STROKE_MONO_ROMAN);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);

  glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();

  ;;

(* textString - Bitmap font string *)

void
textString(int x  int y  char *msg  void *font)
  glRasterPos2f(x  y);
  while (*msg) {
    Glut.bitmapCharacter(font  *msg);
    incr msg;
  ;;

(* strokeString - Stroke font string *)

void
strokeString(int x  int y  char *msg  void *font)
  glPushMatrix();
  glTranslatef(x  y  0);
  glScalef(.04  .04  .04);
  while (*msg) {
    Glut.strokeCharacter(font  *msg);
    incr msg;
  glPopMatrix();
  ;;

(* idleFunc - GLUT idle func callback - animates windows *)

void
idleFunc(void)
  int i;

  if ( not leftDown &&  not middleDown)
    angle += 1;
    angle = angle % 360;

  incr for (i = 0; i < MAXWIN; i) {
    if (winId.(i) && winVis.(i) &&  not winFreeze.(i)) then
      Glut.setWindow(winId.(i));
      Glut.postRedisplay();
  ;;

(* reshapeFunc - Reshape callback. *)

void
reshapeFunc(int width  int height)
  int winId;
  float aspect;

  winId = Glut.getWindow();
  PR("reshape callback for window id %d \n"  winId);

  glViewport(0  0  width  height);
  aspect = (float) width / height;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(40.0  aspect  1.0  20.0);
  glMatrixMode(GL_MODELVIEW);
  ;;

(* visible - Visibility callback. Turn off rendering in
   invisible windows *)

void
visible(int state)
  int winId;
  static GLboolean someVisible = GL_TRUE;

  winId = Glut.getWindow();
  (* printf("visible: state = %d \n"  state);  *)

  if (state = Glut.VISIBLE) then
    PR("Window id %d visible \n"  winId);
    winVis.(idToIndex(winId)) = GL_TRUE;
  } else {
    PR("Window %d not visible \n"  winId);
    winVis.(idToIndex(winId)) = GL_FALSE;

  if ((winVis.(0) = GL_FALSE) && (winVis.(1) = GL_FALSE) && (winVis.(2) = GL_FALSE)
    && (winVis.(3) = GL_FALSE) && (winVis.(6) = GL_FALSE) && (winVis.(7) =
      GL_FALSE)) {
    Glut.idleFunc(NULL);
    PR("All windows not visible; idle func disabled\n");
    someVisible = GL_FALSE;
  } else {
    if ( not someVisible) then
      PR("Some windows now visible; idle func enabled\n");
      someVisible = GL_TRUE;
      if (animation)
        Glut.idleFunc(idleFunc);
  ;;

(* keyFunc - Ascii key callback *)

(* ARGSUSED1 *)
void
keyFunc(unsigned char key  int x  int y)
  int i  ii;

  if (debug || showKeys)
    printf("Ascii key '%c' 0x%02x\n"  key  key);

  match key with
  | 0x1b ->
    exit(0);
    break;

  | 'a' ->
    demoMode =  not demoMode;
    if (demoMode)
      autoDemo(-2);
    break;

  | 's' ->
    AUTODELAY = AUTODELAY * 0.666;
    break;

  | 'S' ->
    AUTODELAY = AUTODELAY * 1.5;
    break;

  | 'q' ->
    killWindow(idToIndex(Glut.getWindow()));
    break;

  | 'k' ->
    showKeys =  not showKeys;
    break;

  | 'p' ->
    demoMode =  not demoMode;
    if (demoMode)
      autoDemo(-999);
    break;

  | 'D' ->
    debug =  not debug;
    break;

  | 'd' ->
    dumpIds();
    break;

  | 'h' ->
    if (winId.(5) = 0)
      makeWindow(5);
    else
      killWindow(5);
    break;

  | 't' ->
    ii = idToIndex(Glut.getWindow());
    text.(ii) =  not text.(ii);
    break;

  | 'r' ->
    trackBall(RESET  0  0  0  0);
    break;

  | 'l' ->
    lineWidth += 1;
    updateAll();
    break;

  | 'L' ->
    lineWidth -= 1;
    if (lineWidth < 1)
      lineWidth = 1;
    updateAll();
    break;

  | '0' ->
  | '1' ->
  | '2' ->
  | '3' ->
  | '4' ->
  | '6' ->
    i = key - '0';
    winVis.(i) =  not winVis.(i);
    break;

  | ')' ->
    makeWindow(0);
    break;

  | ' not ' ->
    makeWindow(1);
    break;

  | '@' ->
    makeWindow(2);
    break;

  | '#' ->
    makeWindow(3);
    break;

  ;;

(* specialFunc - Special keys callback (F keys  cursor keys
   etc. *)

(* ARGSUSED1 *)
void
specialFunc(int key  int x  int y)
  if (debug || showKeys)
    printf("Special key %d\n"  key);

  match key with
  | Glut.KEY_PAGE_DOWN ->
    scrollLine += 10;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_PAGE_UP ->
    scrollLine -= 10;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_DOWN ->
    scrollLine += 1;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_UP ->
    scrollLine -= 1;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_HOME ->
    scrollLine = 0;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_END ->
    scrollLine = 9999;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_RIGHT ->
    scrollCol -= 1;
    updateHelp();
    updateText();
    break;

  | Glut.KEY_LEFT ->
    scrollCol += 1;
    updateHelp();
    updateText();
    break;
  ;;

(* mouseFunc - Mouse button callback *)

void
mouseFunc(int button  int state  int x  int y)
  PR("Mouse button %d  state %d  at pos %d  %d\n"  button  state  x  y);

  trackBall(MOUSEBUTTON  button  state  x  y);
  ;;

(* motionFunc - Mouse movement (with a button down) callback *)

void
motionFunc(int x  int y)
  PR("Mouse motion at %d  %d\n"  x  y);

  trackBall(MOUSEMOTION  0  0  x  y);

  Glut.postRedisplay();
  ;;

(* passiveMotionFunc - Mouse movement (with no button down)
   callback *)

void
passiveMotionFunc(int x  int y)
  printf("Mouse motion at %d  %d\n"  x  y);
  ;;

(* entryFunc - Window entry event callback *)

void
entryFunc(int state)
  int winId = Glut.getWindow();
  PR("Entry event: window id %d (index %d)  state %d \n"  winId  idToIndex(
      winId)  state);
  ;;

(* menuStateFunc - Callback to tell us when menus are popped
   up/down. *)

int menu_state = Glut.MENU_NOT_IN_USE;

void
menuStateFunc(int state)
  printf("menu stated = %d\n"  state);
  menu_state = state;

  if (Glut.getWindow() = 0) then
    PR("menuStateFunc: window invalid\n");
    return;
  PR("Menus are%sin use\n"  state = Glut.MENU_IN_USE ? " " : " not ");

  if ((state = Glut.MENU_IN_USE) && menuFreeze)
    Glut.idleFunc(NULL);
  else if (animation)
    Glut.idleFunc(idleFunc);
  ;;

(* timerFunc - General test of global timer *)

void
timerFunc(int value)
  printf("timer callback: value %d\n"  value);
  if (timerOn) then
    Glut.timerFunc(DELAY  timerFunc  1);
  ;;

#if 0
(* delayedReinstateMenuStateCallback - Hack to reinstate
   MenuStateCallback after a while.  *)

void
delayedReinstateMenuStateCallback(int state)
  Glut.menuStateFunc(menuStateFunc);
  ;;

#endif

(* setInitDisplayMode - update display modes from display mode
   menu *)

void
setInitDisplayMode(void)
  int i;

  displayMode = 0;

  incr for (i = 0; i < MODES; i) {
    if (modes.(i)) then
      (* printf("Requesting %s \n"  modeNames.(i));  *)
      displayMode  lor = Glut.mode.(i);

  Glut.initDisplayMode(displayMode);

  createMenu6();
  if ( not Glut.get(Glut.DISPLAY_MODE_POSSIBLE))
    warning("This display mode not supported\n");
  ;;

(* makeWindow - Create one of the windows *)

void
makeWindow(int index)
  char str.(99);

  if (winId.(index) <> 0) then
    (* warning("Attempt to create window which is already
       created");  *)
    return;
  match index with

  | 0 ->              (* ordinary RGB windows  *)
  | 1 ->
  | 2 ->
  | 3 ->

    setInitDisplayMode();
    Glut.initWindowPosition(pos.(index).(0)  pos.(index).(1));
    Glut.initWindowSize(size.(index).(0)  size.(index).(1));
    winId.(index) = Glut.createWindow(" ");
    PR("Window %d id = %d \n"  index  winId.(index));
    gfxInit(index);

    addCallbacks();

    sprintf(str  "window %d (RGB)"  index);
    Glut.setWindowTitle(str);
    sprintf(str  "icon %d"  index);
    Glut.setIconTitle(str);
    Glut.setMenu(menu1);
    Glut.attachMenu(Glut.RIGHT_BUTTON);
    break;

  | 4 ->              (* subwindow  *)

    setInitDisplayMode();
    winId.(index) = Glut.createSubWindow(winId.(0)  pos.(index).(0)  pos.(index)
      .(1)  size.(index).(0)  size.(index).(1));
    PR("Window %d id = %d \n"  index  winId.(index));
    gfxInit(index);
    Glut.displayFunc(drawScene);
    Glut.visibilityFunc(visible);
    Glut.reshapeFunc(reshapeFunc);

    break;

  | 5 ->              (* help window  *)
  | 8 ->              (* text window  *)
    Glut.initDisplayMode(Glut.DOUBLE  lor  Glut.RGB  lor  Glut.DEPTH);
    Glut.initWindowPosition(pos.(index).(0)  pos.(index).(1));
    Glut.initWindowSize(size.(index).(0)  size.(index).(1));
    winId.(index) = Glut.createWindow(" ");
    PR("Window %d id = %d \n"  index  winId.(index));

    (* addCallbacks();  *)
    Glut.keyboardFunc(keyFunc);
    Glut.specialFunc(specialFunc);

    GlClear.clearColor(0.15  0.15  0.15  1.0);
    glColor3f(1  1  1);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0  300  0  100);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    if (index = 5) then
      Glut.displayFunc(updateHelp);
      Glut.setWindowTitle("help (RGB) win 5");
      Glut.setIconTitle("help");
    } else {
      Glut.displayFunc(updateText);
      Glut.setWindowTitle("text (RGB) win 8");
      Glut.setIconTitle("text");
    Glut.setMenu(menu1);
    Glut.attachMenu(Glut.RIGHT_BUTTON);
    break;

  | 6 ->              (* color index window  *)
  | 7 ->              (* color index window  *)

    Glut.initDisplayMode(Glut.DOUBLE  lor  Glut.INDEX  lor  Glut.DEPTH);
    Glut.initWindowPosition(pos.(index).(0)  pos.(index).(1));
    Glut.initWindowSize(size.(index).(0)  size.(index).(1));
    winId.(index) = Glut.createWindow(" ");
    PR("Window %d id = %d \n"  index  winId.(index));

    gfxInit(index);

    addCallbacks();

    sprintf(str  "window %d (color index)"  index);
    Glut.setWindowTitle(str);
    sprintf(str  "icon %d"  index);
    Glut.setIconTitle(str);
    Glut.setMenu(menu1);
    Glut.attachMenu(Glut.RIGHT_BUTTON);
    break;

  ;;

(* killWindow - Kill one of the main windows *)

void
killWindow(int index)
  int i;

  if (winId.(index) = 0) then
    (* fprintf(stderr  "Attempt to kill invalid window in
       killWindow\n");  *)
    return;
  PR("Killing win %d\n"  index);
  Glut.setWindow(winId.(index));

  (* Disable all callbacks for safety  although
     Glut.destroyWindow  should do this.  *)

  removeCallbacks();

  Glut.destroyWindow(winId.(index));
  winId.(index) = 0;
  winVis.(index) = GL_FALSE;

#if 0
  (* If we reinstate the menu state func here  prog breaks.  So
     reinstate it a little later.  *)
  Glut.timerFunc(MENUDELAY  delayedReinstateMenuStateCallback  1);
#endif

  if (index = 5) then     (* help  *)
    scrollLine = 0;
    scrollCol = 0;
  if (index = 8) then     (* text window  *)
    incr for (i = 0; textPtr.(i) <> NULL; i) {
      free(textPtr.(i)); (* free the text strings  *)
      textPtr.(i) = NULL;
  ;;

(* addCallbacks - Add some standard callbacks after creating a
   window *)

void
addCallbacks(void)
  Glut.displayFunc(drawScene);
  Glut.visibilityFunc(visible);
  Glut.reshapeFunc(reshapeFunc);
  Glut.keyboardFunc(keyFunc);
  Glut.specialFunc(specialFunc);
  Glut.mouseFunc(mouseFunc);
  Glut.motionFunc(motionFunc);
  Glut.entryFunc(entryFunc);

(* Callbacks for exotic input devices. Must get my dials &
   buttons back. *)

  Glut.spaceballMotionFunc(spaceballMotionCB);
  Glut.spaceballRotateFunc(spaceballRotateCB);
  Glut.spaceballButtonFunc(spaceballButtonCB);

  Glut.buttonBoxFunc(buttonBoxCB);
  Glut.dialsFunc(dialsCB);

  Glut.tabletMotionFunc(tabletMotionCB);
  Glut.tabletButtonFunc(tabletButtonCB);
  ;;

(* removeCallbacks - Remove all callbacks before destroying a
   window. GLUT probably does this  anyway but we'll be safe. *)

void
removeCallbacks(void)
  Glut.visibilityFunc(NULL);
  Glut.reshapeFunc(NULL);
  Glut.keyboardFunc(NULL);
  Glut.specialFunc(NULL);
  Glut.mouseFunc(NULL);
  Glut.motionFunc(NULL);
  Glut.entryFunc(NULL);
  ;;

(* updateHelp - Update the help window after user scrolls. *)

void
updateHelp(void)
  static char *helpPtr[] =
    "(Use PGUP  PGDN  HOME  END  arrows to scroll help text)          " 
    "                                                                " 
    "A demo program for GLUT.                                        " 
    "G Edwards  Aug 95                                               " 
    "Exercises 99% of GLUT calls                                     " 
    VERSIONLONG 
    "                                                                " 
    "This text uses Glut.STROKE_MONO_ROMAN font  a built-in vector font." 
    "(Try resizing the help window).                                 " 
    "                                                                " 
    "Keys:                                                           " 
    " esc   quit                                                     " 
    " t     toggle text on/off in each window                        " 
    " h     toggle help                                              " 
    " q     quit current window                                      " 
    " a     auto demo                                                " 
    " p     pause/unpause demo                                       " 
    " l     increase line width (gfx  land  stroke text)                  " 
    " L     decrease line width (gfx  land  stroke text)                  " 
    " r     reset transforms                                         " 
    " k     show keyboard events                                     " 
    " D     show all events                                          " 
    "                                                                " 
    "Mouse:                                                          " 
    " Left button:    rotate                                         " 
    " Middle button:  pan                                            " 
    " Left + middle:  zoom                                           " 
    NULL};

  updateScrollWindow(5  helpPtr);
  ;;

(* updateText - Update a text window *)

void
updateText(void)
  int i;

  if (textPtr.(0) = NULL) then
    incr for (i = 0; i < 20; i) {
      textPtr.(i) = (char *) malloc(50);
      strcpy(textPtr.(i)  "no current text");
    textPtr.(20) = NULL;
  updateScrollWindow(8  textPtr);
  ;;

(* updateScrollWindow *)

void
updateScrollWindow(int index  char **ptr)
  int i  j  lines = 0;

  if (winId.(index) = 0)
    return;

  Glut.setWindow(winId.(index));

  incr for (i = 0; ptr.(i) <> NULL; i)
    incr lines;

  if (scrollLine < 0)
    scrollLine = 0;
  if (scrollLine > (lines - 5))
    scrollLine = lines - 5;

  GlClear.clear(GL_COLOR_BUFFER_BIT);

  glLineWidth(lineWidth);

  incr for (i = scrollLine  j = 1; ptr.(i) <> NULL; i++  j)
    strokeString(scrollCol * 50  100 - j * 6  ptr.(i) 
      Glut.STROKE_MONO_ROMAN);

  Glut.swapBuffers();

  ;;

(* updateAll - Update all visible windows after soem global
   change  eg. line width *)

void
updateAll(void)
  int i;

  if (winId.(5) <> 0)
    updateHelp();

  if (winId.(8) <> 0)
    updateText();

  incr for (i = 0; i < MAXWIN; i)
    if (winId.(i)) then
      Glut.setWindow(winId.(i));
      Glut.postRedisplay();
  ;;

(* idToIndex - Convert GLUT window id to our internal index *)

int
idToIndex(int id)
  int i;
  incr for (i = 0; i < MAXWIN; i) {
    if (winId.(i) = id)
      return i;
  fprintf(stderr  "error: id %d not found \n"  id);
  return (-1);
  ;;

(* warning - warning messages *)

void
warning(char *msg)
  fprintf(stderr  "\007");

  if (debug) then
    fprintf(stderr  "%s"  msg);
    if (msg.(strlen(msg)) <> '\n')
      fprintf(stderr  "%s"  "\n");
  ;;

(* dumpIds - Debug: dump some internal data  *)

void
dumpIds(void)
  int i  j;

  printf("\nInternal data:\n");

  incr for (i = 0; i < MAXWIN; i)
    printf("Index %d  Glut. win id %d  visibility %d\n"  i  winId.(i) 
      winVis.(i));

  incr for (i = 0; i < MAXWIN; i) {
    if (winId.(i))
      Glut.setWindow(winId.(i));
    else {
      printf("index %d - no Glut. window\n"  i);
      continue;

    incr for (j = 1; j <= MAXWIN; j)
      printf("Index %d  display list %d %s defined\n"  i  j  glIsList(j) ?
        "is " : "not");
  ;;

(* autoDemo - Run auto demo/test This is a bit tricky. We need
   to start a timer sequence which progressively orders things
   to be done. The work really gets done when we return from
   our callback. Have to think about the event loop / callback
   design here. *)

void
autoDemo(int value)

#define STEP(a  b)  \
    | a ->         \
        action(a);  \
	Glut.timerFunc(AUTODELAY * b  autoDemo  next(a); \
	break;

  static int index = 0;
  static int count = 0;
  static int restartValue = -2;

  if (value = -999)
    value = restartValue;

  restartValue = value;

#define AUTODELAY2 (unsigned int) (AUTODELAY*0.66)

  (* fprintf(stderr  "autoDemo: value %d \n"  value);  *)

  if ( not demoMode)
    return;

  if (menu_state = Glut.MENU_IN_USE) then
    Glut.timerFunc(AUTODELAY / 2  autoDemo  value);
    return;
  match value with

(* Entry point; kill off existing windows. *)

  | -2 ->
    killAllWindows();
    Glut.timerFunc(AUTODELAY / 2  autoDemo  1);
    break;

(* Start making windows *)

  | -1 ->
    makeWindow(0);
    Glut.timerFunc(AUTODELAY  autoDemo  0);  (* skip case 0
                                               first time  *)
    break;

(* Change shape  land  backdrop *)

  | 0 ->
    currentShape = (currentShape + 1) % 9;
    redefineShapes(currentShape);
    count += 1;
    if (count % 2)
      backdrop =  not backdrop;
    Glut.timerFunc(AUTODELAY  autoDemo  1);
    break;

(* Keep making windows *)

  | 1 ->
    makeWindow(1);
    Glut.timerFunc(AUTODELAY  autoDemo  2);
    break;

  | 2 ->
    makeWindow(2);
    Glut.timerFunc(AUTODELAY  autoDemo  3);
    break;

  | 3 ->
    makeWindow(3);
    Glut.timerFunc(AUTODELAY  autoDemo  4);
    break;

  | 4 ->
    makeWindow(4);
    Glut.timerFunc(AUTODELAY  autoDemo  5);
    break;

  | 5 ->
    makeWindow(5);
    Glut.timerFunc(AUTODELAY * 2  autoDemo  51);
    break;

  | 51 ->
    makeWindow(6);
    Glut.timerFunc(AUTODELAY * 2  autoDemo  52);
    break;

  | 52 ->
    makeWindow(7);
    Glut.timerFunc(AUTODELAY * 2  autoDemo  53);
    break;

(* Kill last 3 windows  leave 4 up. *)

  | 53 ->
    killWindow(7);
    Glut.timerFunc(AUTODELAY  autoDemo  54);
    break;

  | 54 ->
    killWindow(6);
    Glut.timerFunc(AUTODELAY  autoDemo  6);
    break;

  | 6 ->
    killWindow(5);
    Glut.timerFunc(AUTODELAY  autoDemo  7);
    break;

  | 7 ->
    killWindow(4);
    Glut.timerFunc(AUTODELAY  autoDemo  700);
    break;

(* Change shape again *)

  | 700 ->
    currentShape = (currentShape + 1) % 9;
    redefineShapes(currentShape);
    Glut.timerFunc(AUTODELAY  autoDemo  701);
    break;

(* Cycle 4 main windows through various window ops.  *)

  | 701 ->
    positionWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 701 : 702);
    break;

  | 702 ->
    reshapeWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 702 : 703);
    break;

  | 703 ->
    iconifyWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 703 : 704);
    break;

  | 704 ->
    showWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 704 : 705);
    break;

  | 705 ->
    hideWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 705 : 706);
    break;

  | 706 ->
    showWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 706 : 707);
    break;

  | 707 ->
    pushWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 707 : 708);
    break;

  | 708 ->
    popWindow(index);
    index = (index + 1) % 4;
    Glut.timerFunc(AUTODELAY2  autoDemo  index > 0 ? 708 : 8);
    break;

(* Kill all windows *)

  | 8 ->
    killWindow(3);
    Glut.timerFunc(AUTODELAY  autoDemo  9);
    break;

  | 9 ->
    killWindow(2);
    Glut.timerFunc(AUTODELAY  autoDemo  10);
    break;

  | 10 ->
    killWindow(1);
    Glut.timerFunc(AUTODELAY  autoDemo  11);
    break;

  | 11 ->
    killWindow(0);
    Glut.timerFunc(AUTODELAY  autoDemo  -1);  (* back to start  *)
    break;

  ;;

(* attachMenus - Attach/detach menus to/from mouse buttons *)

void
attachMenus(void)
  int i  b;
  int button.(3) =
  {Glut.LEFT_BUTTON  Glut.MIDDLE_BUTTON  Glut.RIGHT_BUTTON};

  incr for (i = 0; i < MAXWIN; i) {
    if (winId.(i) <> 0) then
      incr for (b = 0; b < 3; b) {
        Glut.setWindow(winId.(i));
        Glut.setMenu(menu1);
        if (menuButton.(b))
          Glut.attachMenu(button.(b));
        else
          Glut.detachMenu(button.(b));
  ;;

(* killAllWindows - Kill all windows (except 0) *)

void
killAllWindows(void)
  int w;

  incr for (w = 1; w < MAXWIN; w)
    if (winId.(w))
      killWindow(w);
  ;;

(* makeAllWindows - Make all windows *)

void
makeAllWindows(void)
  int w;

  incr for (w = 0; w < MAXWIN; w)
    if ( not winId.(w))
      makeWindow(w);
  ;;

(* checkArgs - Check command line args *)

void
checkArgs(int argc  char *argv[])
  int argp;
  GLboolean quit = GL_FALSE;
  GLboolean error = GL_FALSE;

#define AA argv.(argp)

#if 0
#incr define NEXT argp;      \
	    if(argp >= argc) \
	    {                \
	       Usage();      \
	       Exit(1);      \
#endif

  argp = 1;
  while (argp < argc) {
    if (match(AA  "-help")) then
      commandLineHelp();
      quit = GL_TRUE;
    } else if (match(AA  "-version")) then
      printf(VERSIONLONG "\n");
      quit = GL_TRUE;
    } else if (match(AA  "-auto")) then
      demoMode = GL_TRUE;
    } else if (match(AA  "-scale")) then
      incr argp;
      scaleFactor = atof(argv.(argp));
    } else {
      fprintf(stderr  "Unknown arg: %s\n"  AA);
      error = GL_TRUE;
      quit = GL_TRUE;
    incr argp;

  if (error) then
    commandLineHelp();
    exit(1);
  if (quit)
    exit(0);
  ;;

(* commandLineHelp - Command line help *)

void
commandLineHelp(void)
  printf("Usage:\n");
  printf(" -h.(elp)            this stuff\n");
  printf(" -v.(ersion)         show version\n");
  printf(" -a.(uto)            start in auto demo mode\n");
  printf(" -s.(cale) f         scale windows by f\n");
  printf("Standard GLUT args:\n");
  printf(" -iconic            start iconic\n");
  printf(" -display DISP      use display DISP\n");
  printf(" -direct            use direct rendering (default)\n");
  printf(" -indirect          use indirect rendering\n");
  printf(" -sync              use synchronous X protocol\n");
  printf(" -gldebug           check OpenGL errors\n");
  printf(" -geometry WxH+X+Y  standard X window spec (overridden here) \n");
  ;;

(* match - Match a string (any unique substring). *)

GLboolean
match(char *arg  char *t)
  if (strstr(t  arg))
    return GL_TRUE;
  else
    return GL_FALSE;
  ;;

(* scaleWindows - Scale initial window sizes ansd positions *)

void
scaleWindows(float scale)
  int i;

  incr for (i = 0; i < MAXWIN; i) {
    pos.(i).(0) = pos.(i).(0) * scale;
    pos.(i).(1) = pos.(i).(1) * scale;
    size.(i).(0) = size.(i).(0) * scale;
    size.(i).(1) = size.(i).(1) * scale;
  ;;

(* trackBall - A simple trackball (not with proper rotations). *)

(** A simple trackball with spin = left button
                           pan  = middle button
                           zoom = left + middle
   Doesn't have proper trackball rotation  ie axes which remain fixed in
   the scene. We should use the trackball code from 4Dgifts. *)

#define STARTROTATE(x  y)     \
{                             \
    startMX = x;              \
    startMY = y;              \
  ;;

#define STOPROTATE(x  y)      \
{                             \
    steadyXangle = varXangle; \
    steadyYangle = varYangle; \
  ;;

#define STARTPAN(x  y)        \
{                             \
    startMX = x;              \
    startMY = y;              \
  ;;

#define STOPPAN(x  y)         \
{                             \
    steadyX = varX;           \
    steadyY = varY;           \
  ;;

#define STARTZOOM(x  y)       \
{                             \
    startMX = x;              \
    startMY = y;              \
  ;;

#define STOPZOOM(x  y)        \
{                             \
    steadyZ = varZ;           \
  ;;

static float
fixAngle(float angle)
  return angle - floor(angle / 360.0) * 360.0;
  ;;

void
trackBall(int mode  int button  int state  int x  int y)
  static int startMX = 0  startMY = 0;  (* initial mouse pos  *)
  static int deltaMX = 0  deltaMY = 0;  (* initial mouse pos  *)
  static float steadyXangle = 0.0  steadyYangle = 0.0;
  static float varXangle = 0.0  varYangle = 0.0;
  static float steadyX = 0.0  steadyY = 0.0  steadyZ = 0.0;
  static float varX = 0.0  varY = 0.0  varZ = 0.0;

  match mode with

  | RESET ->
    steadyXangle = steadyYangle = steadyX = steadyY = steadyZ = 0.0;
    break;

  | MOUSEBUTTON ->

    if (button = Glut.LEFT_BUTTON && state = Glut.DOWN &&  not middleDown) then
      STARTROTATE(x  y);
      leftDown = GL_TRUE;
    } else if (button = Glut.LEFT_BUTTON && state = Glut.DOWN &&
      middleDown) {
      STOPPAN(x  y);
      STARTZOOM(x  y);
      leftDown = GL_TRUE;
    } else if (button = Glut.MIDDLE_BUTTON && state = Glut.DOWN &&
       not leftDown) {
      STARTPAN(x  y);
      middleDown = GL_TRUE;
    } else if (button = Glut.MIDDLE_BUTTON && state = Glut.DOWN &&
      leftDown) {
      STOPROTATE(x  y);
      STARTZOOM(x  y);
      middleDown = GL_TRUE;
    } else if (state = Glut.UP && button = Glut.LEFT_BUTTON &&  not middleDown) then
      STOPROTATE(x  y);
      leftDown = GL_FALSE;
    } else if (state = Glut.UP && button = Glut.LEFT_BUTTON && middleDown) then
      STOPZOOM(x  y);
      STARTROTATE(x  y);
      leftDown = GL_FALSE;
    } else if (state = Glut.UP && button = Glut.MIDDLE_BUTTON &&  not leftDown) then
      STOPPAN(x  y);
      middleDown = GL_FALSE;
    } else if (state = Glut.UP && button = Glut.MIDDLE_BUTTON && leftDown) then
      STOPZOOM(x  y);
      STARTROTATE(x  y);
      middleDown = GL_FALSE;
    break;

  | APPLY ->

    if (leftDown &&  not middleDown) then
      glTranslatef(steadyX  steadyY  steadyZ);
      glRotatef(varXangle  0  1  0);
      glRotatef(varYangle  1  0  0);
    (* Middle button pan  *)

    else if (middleDown &&  not leftDown) then
      glTranslatef(varX  varY  steadyZ);
      glRotatef(steadyXangle  0  1  0);
      glRotatef(steadyYangle  1  0  0);
    (* Left + middle zoom.  *)

    else if (leftDown && middleDown) then
      glTranslatef(steadyX  steadyY  varZ);
      glRotatef(steadyXangle  0  1  0);
      glRotatef(steadyYangle  1  0  0);
    (* Nothing down.  *)

    else {
      glTranslatef(steadyX  steadyY  steadyZ);
      glRotatef(steadyXangle  0  1  0);
      glRotatef(steadyYangle  1  0  0);
    break;

  | MOUSEMOTION ->

    deltaMX = x - startMX;
    deltaMY = startMY - y;

    if (leftDown &&  not middleDown) then
      varXangle = fixAngle(steadyXangle + deltaMX);
      varYangle = fixAngle(steadyYangle + deltaMY);
    } else if (middleDown &&  not leftDown) then
      varX = steadyX + deltaMX / 100.0;
      varY = steadyY + deltaMY / 100.0;
    } else if (leftDown && middleDown) then
      varZ = steadyZ - deltaMY / 50.0;
    break;

  ;;

(* Callbacks for exotic input devices. These have not been
   tested yet owing to the usual complete absence of such
   devices in the UK support group. *)

(* spaceballMotionCB *)

void
spaceballMotionCB(int x  int y  int z)
  printf("spaceballMotionCB: translations are X %d  Y %d  Z %d\n"  x  y  z);
  ;;

(* spaceballRotateCB *)

void
spaceballRotateCB(int x  int y  int z)
  printf("spaceballRotateCB: rotations are X %d  Y %d  Z %d\n"  x  y  z);
  ;;

(* spaceballButtonCB *)

void
spaceballButtonCB(int button  int state)
  printf("spaceballButtonCB: button %d  state %d\n"  button  state);
  ;;

(* buttonBoxCB *)

void
buttonBoxCB(int button  int state)
  printf("buttonBoxCB: button %d  state %d\n"  button  state);
  ;;

(* dialsCB *)

void
dialsCB(int dial  int value)
  printf("dialsCB: dial %d  value %d\n"  dial  value);
  ;;

(* tabletMotionCB *)

void
tabletMotionCB(int x  int y)
  printf("tabletMotionCB: X %d  Y %d\n"  x  y);
  ;;

(* tabletButtonCB *)

(* ARGSUSED2 *)
void
tabletButtonCB(int button  int state  int dummy1  int dummy2)
  printf("tabletButtonCB: button %d  state %d\n"  button  state);
let _ = main();;
