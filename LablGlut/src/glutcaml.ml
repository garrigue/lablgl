(* ==== types ==== *)

type glut_button_t =
    GLUT_LEFT_BUTTON
  | GLUT_MIDDLE_BUTTON
  | GLUT_RIGHT_BUTTON
  | GLUT_OTHER_BUTTON of int

type glut_mouse_button_state_t =
    GLUT_DOWN
  | GLUT_UP 

type glut_special_key_t =
    GLUT_KEY_F1
  | GLUT_KEY_F2
  | GLUT_KEY_F3
  | GLUT_KEY_F4
  | GLUT_KEY_F5
  | GLUT_KEY_F6
  | GLUT_KEY_F7
  | GLUT_KEY_F8
  | GLUT_KEY_F9
  | GLUT_KEY_F10
  | GLUT_KEY_F11
  | GLUT_KEY_F12
  | GLUT_KEY_LEFT
  | GLUT_KEY_UP
  | GLUT_KEY_RIGHT
  | GLUT_KEY_DOWN
  | GLUT_KEY_PAGE_UP
  | GLUT_KEY_PAGE_DOWN
  | GLUT_KEY_HOME
  | GLUT_KEY_END
  | GLUT_KEY_INSERT                        

type glut_entry_exit_state_t =
    GLUT_LEFT
  | GLUT_ENTERED

type glut_menu_state_t =
    GLUT_MENU_NOT_IN_USE
  | GLUT_MENU_IN_USE               

type glut_visibility_state_t =
    GLUT_NOT_VISIBLE
  | GLUT_VISIBLE                   

type glut_window_status_t =
    GLUT_HIDDEN
  | GLUT_FULLY_RETAINED
  | GLUT_PARTIALLY_RETAINED
  | GLUT_FULLY_COVERED             

type glut_color_index_component_t =
    GLUT_RED
  | GLUT_GREEN
  | GLUT_BLUE                      

type glut_layer_t =
    GLUT_NORMAL
  | GLUT_OVERLAY                   

type glut_font_t =
    GLUT_STROKE_ROMAN
  | GLUT_STROKE_MONO_ROMAN
  | GLUT_BITMAP_9_BY_15
  | GLUT_BITMAP_8_BY_13
  | GLUT_BITMAP_TIMES_ROMAN_10
  | GLUT_BITMAP_TIMES_ROMAN_24
  | GLUT_BITMAP_HELVETICA_10
  | GLUT_BITMAP_HELVETICA_12
  | GLUT_BITMAP_HELVETICA_18       

type glut_get_t =
    GLUT_WINDOW_X
  | GLUT_WINDOW_Y
  | GLUT_WINDOW_WIDTH
  | GLUT_WINDOW_HEIGHT
  | GLUT_WINDOW_BUFFER_SIZE
  | GLUT_WINDOW_STENCIL_SIZE
  | GLUT_WINDOW_DEPTH_SIZE
  | GLUT_WINDOW_RED_SIZE
  | GLUT_WINDOW_GREEN_SIZE
  | GLUT_WINDOW_BLUE_SIZE
  | GLUT_WINDOW_ALPHA_SIZE
  | GLUT_WINDOW_ACCUM_RED_SIZE
  | GLUT_WINDOW_ACCUM_GREEN_SIZE
  | GLUT_WINDOW_ACCUM_BLUE_SIZE
  | GLUT_WINDOW_ACCUM_ALPHA_SIZE
  | GLUT_WINDOW_DOUBLEBUFFER
  | GLUT_WINDOW_RGBA
  | GLUT_WINDOW_PARENT
  | GLUT_WINDOW_NUM_CHILDREN
  | GLUT_WINDOW_COLORMAP_SIZE
  | GLUT_WINDOW_NUM_SAMPLES
  | GLUT_WINDOW_STEREO
  | GLUT_WINDOW_CURSOR
  | GLUT_SCREEN_WIDTH
  | GLUT_SCREEN_HEIGHT
  | GLUT_SCREEN_WIDTH_MM
  | GLUT_SCREEN_HEIGHT_MM
  | GLUT_MENU_NUM_ITEMS
  | GLUT_INIT_WINDOW_X
  | GLUT_INIT_WINDOW_Y
  | GLUT_INIT_WINDOW_WIDTH
  | GLUT_INIT_WINDOW_HEIGHT
  | GLUT_INIT_DISPLAY_MODE
  | GLUT_ELAPSED_TIME
  | GLUT_WINDOW_FORMAT_ID 

type glut_get_bool_t =
    GLUT_DISPLAY_MODE_POSSIBLE

let glut_rgb = 0
let glut_rgba = glut_rgb (* same as in glut.h *)
let glut_index = 1
let glut_single = 0
let glut_double = 2
let glut_accum = 4
let glut_alpha = 8
let glut_depth = 16
let glut_stencil = 32
let glut_multisample = 128
let glut_stereo = 256
let glut_luminance = 512

type glut_device_get_t =
    GLUT_HAS_KEYBOARD
  | GLUT_HAS_MOUSE
  | GLUT_HAS_SPACEBALL
  | GLUT_HAS_DIAL_AND_BUTTON_BOX
  | GLUT_HAS_TABLET
  | GLUT_NUM_MOUSE_BUTTONS
  | GLUT_NUM_SPACEBALL_BUTTONS
  | GLUT_NUM_BUTTON_BOX_BUTTONS
  | GLUT_NUM_DIALS
  | GLUT_NUM_TABLET_BUTTONS
  | GLUT_DEVICE_IGNORE_KEY_REPEAT
  | GLUT_DEVICE_KEY_REPEAT
  | GLUT_HAS_JOYSTICK
  | GLUT_OWNS_JOYSTICK
  | GLUT_JOYSTICK_BUTTONS
  | GLUT_JOYSTICK_AXES
  | GLUT_JOYSTICK_POLL_RATE                

type glut_layerget_t =
    GLUT_OVERLAY_POSSIBLE
  | GLUT_HAS_OVERLAY
  | GLUT_NORMAL_DAMAGED
  | GLUT_OVERLAY_DAMAGED           

type glut_video_resize_t =
    GLUT_VIDEO_RESIZE_POSSIBLE
  | GLUT_VIDEO_RESIZE_IN_USE
  | GLUT_VIDEO_RESIZE_X_DELTA
  | GLUT_VIDEO_RESIZE_Y_DELTA
  | GLUT_VIDEO_RESIZE_WIDTH_DELTA
  | GLUT_VIDEO_RESIZE_HEIGHT_DELTA
  | GLUT_VIDEO_RESIZE_X
  | GLUT_VIDEO_RESIZE_Y
  | GLUT_VIDEO_RESIZE_WIDTH
  | GLUT_VIDEO_RESIZE_HEIGHT       

type glut_get_modifiers_t =
    GLUT_ACTIVE_SHIFT
  | GLUT_ACTIVE_CTRL
  | GLUT_ACTIVE_ALT                 

let glut_active_shift = 1
let glut_active_ctrl = 2
let glut_active_alt = 4

type glut_cursor_t =
    GLUT_CURSOR_RIGHT_ARROW
  | GLUT_CURSOR_LEFT_ARROW
  | GLUT_CURSOR_INFO
  | GLUT_CURSOR_DESTROY
  | GLUT_CURSOR_HELP
  | GLUT_CURSOR_CYCLE
  | GLUT_CURSOR_SPRAY
  | GLUT_CURSOR_WAIT
  | GLUT_CURSOR_TEXT
  | GLUT_CURSOR_CROSSHAIR
  | GLUT_CURSOR_UP_DOWN
  | GLUT_CURSOR_LEFT_RIGHT
  | GLUT_CURSOR_TOP_SIDE
  | GLUT_CURSOR_BOTTOM_SIDE
  | GLUT_CURSOR_LEFT_SIDE
  | GLUT_CURSOR_RIGHT_SIDE
  | GLUT_CURSOR_TOP_LEFT_CORNER
  | GLUT_CURSOR_TOP_RIGHT_CORNER
  | GLUT_CURSOR_BOTTOM_RIGHT_CORNER
  | GLUT_CURSOR_BOTTOM_LEFT_CORNER
  | GLUT_CURSOR_INHERIT
  | GLUT_CURSOR_NONE
  | GLUT_CURSOR_FULL_CROSSHAIR   (* full-screen crosshair  : if available *)

type glut_game_mode_t =
    GLUT_GAME_MODE_ACTIVE
  | GLUT_GAME_MODE_POSSIBLE
  | GLUT_GAME_MODE_WIDTH
  | GLUT_GAME_MODE_HEIGHT
  | GLUT_GAME_MODE_PIXEL_DEPTH
  | GLUT_GAME_MODE_REFRESH_RATE
  | GLUT_GAME_MODE_DISPLAY_CHANGED

type glut_key_repeat_t =
    GLUT_KEY_REPEAT_OFF
  | GLUT_KEY_REPEAT_ON
  | GLUT_KEY_REPEAT_DEFAULT

exception BadEnum of string
exception InvalidState of string 
exception OverlayNotInUse of string

open Printf

external glutGetWindow : unit -> int = "ml_glutGetWindow"

(* generate name for callbacks, based on window id *)
let cbname glutname =
  let name = sprintf "ocaml_%s_cb_%i" glutname (glutGetWindow ()) in name

(* general routine to set up a glut callback *)
let setup glutname glutwrapper cb =
  let _ = Callback.register (cbname glutname) cb in glutwrapper ()


(* ==== file-local variables ==== *)

let is_init = ref false
let is_displayModeInit = ref false
let is_windowSizeInit = ref false
let is_windowPositionInit = ref false
let has_createdWindow = ref false

 (* === GLUT initialization sub-API. === *)
external _glutInit : int -> string array -> unit = "ml_glutInit" 

let new_argv = ref [] (* built by a callback from _glutInit *)

let add_arg str = new_argv := str :: !new_argv

let glutInit ~argv =
  is_init := true;
  let argc = Array.length argv in
  let _ = Callback.register "add_arg" add_arg in
  _glutInit argc argv;
  let retargs = Array.of_list (List.rev !new_argv) in retargs

let glutInit2 () = 
    ignore(glutInit Sys.argv);;

external _glutInitDisplayMode :
  double_buffer:bool -> index:bool -> accum:bool -> alpha:bool ->
    depth:bool -> stencil:bool -> multisample:bool -> stereo:bool ->
    luminance:bool ->
    unit = "bytecode_glutInitDisplayMode" "native_glutInitDisplayMode"

let glutInitDisplayMode
  ?(double_buffer = false) ?(index = false) ?(accum = false) ?(alpha = false)
    ?(depth = false) ?(stencil = false) ?(multisample = false)
    ?(stereo = false) ?(luminance = false) dummy_unit =
  is_displayModeInit := true;
  _glutInitDisplayMode double_buffer index accum alpha depth stencil
    multisample stereo luminance

external _glutInitWindowSize : int -> int -> unit = "ml_glutInitWindowSize"

external _glutInitWindowPosition :
  int -> int -> unit = "ml_glutInitWindowPosition"
let glutInitWindowPosition ~x ~y =
  is_windowPositionInit := true; _glutInitWindowPosition x y

let glutInitWindowSize ~w ~h =
  is_windowSizeInit := true; _glutInitWindowSize w h

external glutMainLoop : unit -> unit = "ml_glutMainLoop"

 (* === GLUT window sub-API. === *)

external _glutCreateWindow : string -> int = "ml_glutCreateWindow"

let glutCreateWindow ~title =
  has_createdWindow := true; let winid = _glutCreateWindow title in winid

let glutCreateWindow2 ~title = ignore(glutCreateWindow ~title);;

external glutPostRedisplay : unit -> unit = "ml_glutPostRedisplay"
external glutSwapBuffers : unit -> unit = "ml_glutSwapBuffers" 
external glutCreateSubWindow :
  win:int -> x:int -> y:int -> w:int -> h:int ->
    int = "ml_glutCreateSubWindow"
external glutDestroyWindow : win:int -> unit = "ml_glutDestroyWindow"
external glutSetWindow : win:int -> unit = "ml_glutSetWindow"
external glutSetWindowTitle : title:string -> unit = "ml_glutSetWindowTitle"
external glutSetIconTitle : title:string -> unit = "ml_glutSetIconTitle"
external glutPositionWindow : x:int -> y:int -> unit = "ml_glutPositionWindow"
external glutReshapeWindow : w:int -> h:int -> unit = "ml_glutReshapeWindow"
external glutPopWindow : unit -> unit = "ml_glutPopWindow"
external glutPushWindow : unit -> unit = "ml_glutPushWindow"
external glutIconifyWindow : unit -> unit = "ml_glutIconifyWindow"
external glutShowWindow : unit -> unit = "ml_glutShowWindow"
external glutHideWindow : unit -> unit = "ml_glutHideWindow"
external glutFullScreen : unit -> unit = "ml_glutFullScreen"

external _setCursor : c:int -> unit = "ml_glutSetCursor"
let glutSetCursor c =
  let ic =
    match c with
      GLUT_CURSOR_RIGHT_ARROW -> 0
    | GLUT_CURSOR_LEFT_ARROW -> 1
    | GLUT_CURSOR_INFO -> 2
    | GLUT_CURSOR_DESTROY -> 3
    | GLUT_CURSOR_HELP -> 4
    | GLUT_CURSOR_CYCLE -> 5
    | GLUT_CURSOR_SPRAY -> 6
    | GLUT_CURSOR_WAIT -> 7
    | GLUT_CURSOR_TEXT -> 8
    | GLUT_CURSOR_CROSSHAIR -> 9
    | GLUT_CURSOR_UP_DOWN -> 10
    | GLUT_CURSOR_LEFT_RIGHT -> 11
    | GLUT_CURSOR_TOP_SIDE -> 12
    | GLUT_CURSOR_BOTTOM_SIDE -> 13
    | GLUT_CURSOR_LEFT_SIDE -> 14
    | GLUT_CURSOR_RIGHT_SIDE -> 15
    | GLUT_CURSOR_TOP_LEFT_CORNER -> 16
    | GLUT_CURSOR_TOP_RIGHT_CORNER -> 17
    | GLUT_CURSOR_BOTTOM_RIGHT_CORNER -> 18
    | GLUT_CURSOR_BOTTOM_LEFT_CORNER -> 19
    | GLUT_CURSOR_INHERIT -> 100
    | GLUT_CURSOR_NONE -> 101
    | GLUT_CURSOR_FULL_CROSSHAIR -> 102
  in
  _setCursor ic

 (* === GLUT overlay sub-API. === *)
external glutEstablishOverlay : unit -> unit = "ml_glutEstablishOverlay"
external glutRemoveOverlay : unit -> unit = "ml_glutRemoveOverlay"
external glutPostOverlayRedisplay :
  unit -> unit = "ml_glutPostOverlayRedisplay"
external glutShowOverlay : unit -> unit = "ml_glutShowOverlay"
external glutHideOverlay : unit -> unit = "ml_glutHideOverlay"

external _useLayer : int -> unit = "ml_glutUseLayer"
let glutUseLayer layer =
  _useLayer
    (match layer with
       GLUT_NORMAL -> 0
     | GLUT_OVERLAY -> 1)

 (* === GLUT menu sub-API. === *)

external _glutCreateMenu : unit -> int = "ml_glutCreateMenu"
let glutCreateMenu ~cb =
  let _ = Callback.register "ocaml_glutCreateMenu" cb in
  let menu_id = _glutCreateMenu () in menu_id
    
external glutDestroyMenu : menu:int -> unit = "ml_glutDestroyMenu"
external glutGetMenu : unit -> int = "ml_glutGetMenu"
external glutSetMenu : menu:int -> unit = "ml_glutSetMenu"
external glutAddMenuEntry :
  label:string -> value:int -> unit = "ml_glutAddMenuEntry"
external glutAddSubMenu :
  label:string -> submenu:int -> unit = "ml_glutAddSubMenu"
external glutChangeToMenuEntry :
  item:int -> label:string -> value:int -> unit = "ml_glutChangeToMenuEntry"
external glutChangeToSubMenu :
  item:int -> label:string -> submenu:int -> unit = "ml_glutChangeToSubMenu"
external glutRemoveMenuItem : item:int -> unit = "ml_glutRemoveMenuItem"

let glut_int_of_button b =
  match b with
    GLUT_LEFT_BUTTON -> 0
  | GLUT_MIDDLE_BUTTON -> 1
  | GLUT_RIGHT_BUTTON -> 2
  | GLUT_OTHER_BUTTON n -> n

let b2i b = glut_int_of_button b

external _attachMenu : button:int -> unit = "ml_glutAttachMenu"
let glutAttachMenu ~button = _attachMenu (b2i button)

external _detachMenu : button:int -> unit = "ml_glutDetachMenu"
let glutDetachMenu ~button = _detachMenu (b2i button)

 (* === GLUT window callback sub-API. === *)

external _glutDisplayFunc : unit -> unit = "ml_glutDisplayFunc"
(* let displayFunc ~cb = setup "glutDisplayFunc" _glutDisplayFunc cb;; *)
let glutDisplayFunc ~cb =
  let _ = Callback.register (cbname "glutDisplayFunc") cb in
  _glutDisplayFunc ()

external _glutReshapeFunc : unit -> unit = "ml_glutReshapeFunc"
let glutReshapeFunc ~cb = setup "glutReshapeFunc" _glutReshapeFunc cb

external _glutKeyboardFunc : unit -> unit = "ml_glutKeyboardFunc"
let glutKeyboardFunc ~cb = setup "glutKeyboardFunc" _glutKeyboardFunc cb

external _glutMouseFunc : unit -> unit = "ml_glutMouseFunc"
let mouse_cb_wrapper user_func ibutton istate x y =
  let b =
    match ibutton with
      0 -> GLUT_LEFT_BUTTON
    | 1 -> GLUT_MIDDLE_BUTTON
    | 2 -> GLUT_RIGHT_BUTTON
    | n -> GLUT_OTHER_BUTTON n
  in
  let s =
    match istate with
      0 -> GLUT_DOWN
    | 1 -> GLUT_UP
    | _ -> raise (BadEnum "istate in mouse_cb_wrapper")
  in
  user_func b s x y
let glutMouseFunc ~cb =
  setup "glutMouseFunc" _glutMouseFunc (mouse_cb_wrapper cb)

external _glutMotionFunc : unit -> unit = "ml_glutMotionFunc"
let glutMotionFunc ~cb = setup "glutMotionFunc" _glutMotionFunc cb

external _glutPassiveMotionFunc : unit -> unit = "ml_glutPassiveMotionFunc"
let glutPassiveMotionFunc ~cb =
  setup "glutPassiveMotionFunc" _glutPassiveMotionFunc cb

external _glutEntryFunc : unit -> unit = "ml_glutEntryFunc" 
let glutEntryFunc ~cb = setup "glutEntryFunc" _glutEntryFunc cb
    
external _glutVisibilityFunc : unit -> unit = "ml_glutVisibilityFunc"
let glutVisibilityFunc ~cb = setup "glutVisibilityFunc" _glutVisibilityFunc cb

(* idleFunc is for the entire program, not just a single window,
   so its name does not depend on the window id *)
external _glutIdleFunc : unit -> unit = "ml_glutIdleFunc"
external _setIdleFuncToNull : unit -> unit = "ml_glutSetIdleFuncToNull"
let glutIdleFunc ~cb =
  match cb with
    None -> _setIdleFuncToNull ()
  | Some callback ->
      Callback.register "ocaml_glutIdleFunc" callback; _glutIdleFunc ()

(* timerFunc is non-window-dependent *)
external _glutTimerFunc : int -> int -> unit = "ml_glutTimerFunc"
let glutTimerFunc ~ms ~cb ~value:v : unit =
  let _ = Callback.register "ocaml_glutTimerFunc" cb in _glutTimerFunc ms v (* register the callback with GLUT *)

external _glutMenuStateFunc : unit -> unit = "ml_glutMenuStateFunc"
let glutMenuStateFunc ~cb = setup "glutMenuStateFunc" _glutMenuStateFunc cb

let glut_special_of_int i =
  match i with
    1 -> GLUT_KEY_F1
  | 2 -> GLUT_KEY_F2
  | 3 -> GLUT_KEY_F3
  | 4 -> GLUT_KEY_F4
  | 5 -> GLUT_KEY_F5
  | 6 -> GLUT_KEY_F6
  | 7 -> GLUT_KEY_F7
  | 8 -> GLUT_KEY_F8
  | 9 -> GLUT_KEY_F9
  | 10 -> GLUT_KEY_F10
  | 11 -> GLUT_KEY_F11
  | 12 -> GLUT_KEY_F12
  | 100 -> GLUT_KEY_LEFT
  | 101 -> GLUT_KEY_UP
  | 102 -> GLUT_KEY_RIGHT
  | 103 -> GLUT_KEY_DOWN
  | 104 -> GLUT_KEY_PAGE_UP
  | 105 -> GLUT_KEY_PAGE_DOWN
  | 106 -> GLUT_KEY_HOME
  | 107 -> GLUT_KEY_END
  | 108 -> GLUT_KEY_INSERT
  | _ -> raise (BadEnum "key in special_of_int")

external _glutSpecialFunc : unit -> unit = "ml_glutSpecialFunc"
let glutSpecialFunc ~cb =
  setup "glutSpecialFunc" _glutSpecialFunc
    (fun key x y -> cb (glut_special_of_int key) x y)

external _spaceballMotionFunc : unit -> unit = "ml_glutSpaceballMotionFunc"
let glutSpaceballMotionFunc ~cb =
  setup "glutSpaceballMotionFunc" _spaceballMotionFunc cb

external _spaceballRotateFunc : unit -> unit = "ml_glutSpaceballRotateFunc"
let glutSpaceballRotateFunc ~cb =
  setup "glutSpaceballRotateFunc" _spaceballRotateFunc cb

external _spaceballButtonFunc : unit -> unit = "ml_glutSpaceballButtonFunc"
let glutSpaceballButtonFunc ~cb =
  setup "glutSpaceballButtonFunc" _spaceballButtonFunc cb

external _buttonBoxFunc : unit -> unit = "ml_glutButtonBoxFunc"
let glutButtonBoxFunc ~cb = setup "glutButtonBoxFunc" _buttonBoxFunc cb

external _dialsFunc : unit -> unit = "ml_glutDialsFunc"
let glutDialsFunc ~cb = setup "glutDialsFunc" _dialsFunc cb

external _tabletMotionFunc : unit -> unit = "ml_glutTabletMotionFunc"
let glutTabletMotionFunc ~cb =
  setup "glutTabletMotionFunc" _tabletMotionFunc cb

external _tabletButtonFunc : unit -> unit = "ml_glutTabletButtonFunc"
let glutTabletButtonFunc ~cb =
  setup "glutTabletButtonFunc" _tabletButtonFunc cb

external _menuStatusFunc : unit -> unit = "ml_glutMenuStatusFunc"
let glutMenuStatusFunc ~cb = setup "glutMenuStatusFunc" _menuStatusFunc cb

external _overlayDisplayFunc : unit -> unit = "ml_glutOverlayDisplayFunc"
let glutOverlayDisplayFunc ~cb =
  setup "glutOverlayDisplayFunc" _overlayDisplayFunc cb

 (* === GLUT color index sub-API. === === *)
external glutSetColor :
  cell:int -> red:float -> green:float -> blue:float ->
    unit = "ml_glutSetColor"
external glutGetColor :
  index:int -> component:int -> float = "ml_glutGetColor"
external glutCopyColormap : win:int -> unit = "ml_glutCopyColormap"

 (* === GLUT state retrieval sub-API. === *)
external _get : igtype:int -> int = "ml_glutGet"
let glutGet ~gtype =
  let igtype =
    match gtype with
      GLUT_WINDOW_X -> 100
    | GLUT_WINDOW_Y -> 101
    | GLUT_WINDOW_WIDTH -> 102
    | GLUT_WINDOW_HEIGHT -> 103
    | GLUT_WINDOW_BUFFER_SIZE -> 104
    | GLUT_WINDOW_STENCIL_SIZE -> 105
    | GLUT_WINDOW_DEPTH_SIZE -> 106
    | GLUT_WINDOW_RED_SIZE -> 107
    | GLUT_WINDOW_GREEN_SIZE -> 108
    | GLUT_WINDOW_BLUE_SIZE -> 109
    | GLUT_WINDOW_ALPHA_SIZE -> 110
    | GLUT_WINDOW_ACCUM_RED_SIZE -> 111
    | GLUT_WINDOW_ACCUM_GREEN_SIZE -> 112
    | GLUT_WINDOW_ACCUM_BLUE_SIZE -> 113
    | GLUT_WINDOW_ACCUM_ALPHA_SIZE -> 114
    | GLUT_WINDOW_DOUBLEBUFFER -> 115
    | GLUT_WINDOW_RGBA -> 116
    | GLUT_WINDOW_PARENT -> 117
    | GLUT_WINDOW_NUM_CHILDREN -> 118
    | GLUT_WINDOW_COLORMAP_SIZE -> 119
    | GLUT_WINDOW_NUM_SAMPLES -> 120
    | GLUT_WINDOW_STEREO -> 121
    | GLUT_WINDOW_CURSOR -> 122
    | GLUT_SCREEN_WIDTH -> 200
    | GLUT_SCREEN_HEIGHT -> 201
    | GLUT_SCREEN_WIDTH_MM -> 202
    | GLUT_SCREEN_HEIGHT_MM -> 203
    | GLUT_MENU_NUM_ITEMS -> 300
    | GLUT_INIT_WINDOW_X -> 500
    | GLUT_INIT_WINDOW_Y -> 501
    | GLUT_INIT_WINDOW_WIDTH -> 502
    | GLUT_INIT_WINDOW_HEIGHT -> 503
    | GLUT_INIT_DISPLAY_MODE -> 504
    | GLUT_ELAPSED_TIME -> 700
    | GLUT_WINDOW_FORMAT_ID -> 123
  in
  _get igtype

let glutGetBool ~gtype =
  _get
    (match gtype with
       GLUT_DISPLAY_MODE_POSSIBLE -> 400) <>
    0

external _deviceGet : idgtype:int -> int = "ml_glutDeviceGet"
let glutDeviceGet ~dgtype =
  let idgtype =
    match dgtype with
      GLUT_HAS_KEYBOARD -> 600
    | GLUT_HAS_MOUSE -> 601
    | GLUT_HAS_SPACEBALL -> 602
    | GLUT_HAS_DIAL_AND_BUTTON_BOX -> 603
    | GLUT_HAS_TABLET -> 604
    | GLUT_NUM_MOUSE_BUTTONS -> 605
    | GLUT_NUM_SPACEBALL_BUTTONS -> 606
    | GLUT_NUM_BUTTON_BOX_BUTTONS -> 607
    | GLUT_NUM_DIALS -> 608
    | GLUT_NUM_TABLET_BUTTONS -> 609
    | GLUT_DEVICE_IGNORE_KEY_REPEAT -> 610
    | GLUT_DEVICE_KEY_REPEAT -> 611
    | GLUT_HAS_JOYSTICK -> 612
    | GLUT_OWNS_JOYSTICK -> 613
    | GLUT_JOYSTICK_BUTTONS -> 614
    | GLUT_JOYSTICK_AXES -> 615
    | GLUT_JOYSTICK_POLL_RATE -> 616
  in
  _deviceGet idgtype

 (* === GLUT extension support sub-API === *) 
external glutExtensionSupported :
  name:string -> bool = "ml_glutExtensionSupported"

external glutGetModifiers : unit -> int = "ml_glutGetModifiers"

let glut_int_of_modifiers m =
  let ret = ref 0 in
  let rec f =
    function
      [] -> ()
    | h :: t ->
        ret :=
          !ret lor
            (match h with
               GLUT_ACTIVE_SHIFT -> 1
             | GLUT_ACTIVE_CTRL -> 2
             | GLUT_ACTIVE_ALT -> 4);
        f t
  in
  f m; !ret

external _layerGet : int -> int = "ml_glutLayerGet"
let glutLayerGet ~lgtype =
  let ilgtype =
    match lgtype with
      GLUT_OVERLAY_POSSIBLE -> 800
    | GLUT_HAS_OVERLAY -> 802
    | GLUT_NORMAL_DAMAGED -> 804
    | GLUT_OVERLAY_DAMAGED -> 805
  in
  let ret = _layerGet ilgtype in
  if lgtype = GLUT_OVERLAY_DAMAGED && ret = -1 then
    raise (OverlayNotInUse "in layerGet OVERLAY_DAMAGED")
  else ret <> 0

let glutLayerGetTransparentIndex () = _layerGet 803 (* from glut.h *)

let glutLayerGetInUse () =
  match _layerGet 801 with
    0 -> GLUT_NORMAL
  | 1 -> GLUT_OVERLAY
  | _ -> failwith "unexpected value in layerGetInUse"

 (* === GLUT font sub-API === *)

(* convert font to integer value from glut.h *)
let f2i font =
  match font with
    GLUT_STROKE_ROMAN -> 0
  | GLUT_STROKE_MONO_ROMAN -> 1
  | GLUT_BITMAP_9_BY_15 -> 2
  | GLUT_BITMAP_8_BY_13 -> 3
  | GLUT_BITMAP_TIMES_ROMAN_10 -> 4
  | GLUT_BITMAP_TIMES_ROMAN_24 -> 5
  | GLUT_BITMAP_HELVETICA_10 -> 6
  | GLUT_BITMAP_HELVETICA_12 -> 7
  | GLUT_BITMAP_HELVETICA_18 -> 8

external _bitmapCharacter :
  font:int -> c:int -> unit = "ml_glutBitmapCharacter"
let glutBitmapCharacter ~font ~c = _bitmapCharacter (f2i font) c

external _bitmapWidth : font:int -> c:int -> int = "ml_glutBitmapWidth"
let glutBitmapWidth ~font ~c = _bitmapWidth (f2i font) c

external _strokeCharacter :
  font:int -> c:int -> unit = "ml_glutStrokeCharacter"
let glutStrokeCharacter ~font ~c = _strokeCharacter (f2i font) c

external _strokeWidth : font:int -> c:int -> int = "ml_glutStrokeWidth"
let glutStrokeWidth ~font ~c = _strokeWidth (f2i font) c

 (* === GLUT pre-built models sub-API === *)
external glutWireSphere :
  radius:float -> slices:int -> stacks:int -> unit = "ml_glutWireSphere"
external glutSolidSphere :
  radius:float -> slices:int -> stacks:int -> unit = "ml_glutSolidSphere"
external glutWireCone :
  base:float -> height:float -> slices:int -> stacks:int ->
    unit = "ml_glutWireCone"
external glutSolidCone :
  base:float -> height:float -> slices:int -> stacks:int ->
    unit = "ml_glutSolidCone"
external glutWireCube : size:float -> unit = "ml_glutWireCube"
external glutSolidCube : size:float -> unit = "ml_glutSolidCube"
external glutWireTorus :
  innerRadius:float -> outerRadius:float -> sides:int -> rings:int ->
    unit = "ml_glutWireTorus"
external glutSolidTorus :
  innerRadius:float -> outerRadius:float -> sides:int -> rings:int ->
    unit = "ml_glutSolidTorus"
external glutWireDodecahedron : unit -> unit = "ml_glutWireDodecahedron"
external glutSolidDodecahedron : unit -> unit = "ml_glutSolidDodecahedron"
external glutWireTeapot : size:float -> unit = "ml_glutWireTeapot"
external glutSolidTeapot : size:float -> unit = "ml_glutSolidTeapot"
external glutWireOctahedron : unit -> unit = "ml_glutWireOctahedron"
external glutSolidOctahedron : unit -> unit = "ml_glutSolidOctahedron"
external glutWireTetrahedron : unit -> unit = "ml_glutWireTetrahedron"
external glutSolidTetrahedron : unit -> unit = "ml_glutSolidTetrahedron"
external glutWireIcosahedron : unit -> unit = "ml_glutWireIcosahedron"
external glutSolidIcosahedron : unit -> unit = "ml_glutSolidIcosahedron"

 (* GLUT version 4 functions included in the GLUT 3.7 distribution *)
external glutInitDisplayString :
  str:string -> unit = "ml_glutInitDisplayString"
external glutWarpPointer : x:int -> y:int -> unit = "ml_glutWarpPointer"

external _bitmapLength : font:int -> str:string -> int = "ml_glutBitmapLength"
let glutBitmapLength ~font ~str = _bitmapLength (f2i font) str

external _strokeLength : font:int -> str:string -> int = "ml_glutStrokeLength"
let glutStrokeLength ~font ~str = _strokeLength (f2i font) str

external _windowStatusFunc : unit -> unit = "ml_glutWindowStatusFunc"
let glutWindowStatusFunc ~cb =
  setup "glutWindowStatusFunc" _windowStatusFunc
    (fun s ->
       cb (
            match s with
              0 -> GLUT_HIDDEN
            | 1 -> GLUT_FULLY_RETAINED
            | 2 -> GLUT_PARTIALLY_RETAINED
            | 3 -> GLUT_FULLY_COVERED
            | _ ->
                failwith "invalid value in glutWindowStatus ocaml callback"))

external glutPostWindowRedisplay :
  win:int -> unit = "ml_glutPostWindowRedisplay"

external glutPostWindowOverlayRedisplay :
  win:int -> unit = "ml_glutPostWindowOverlayRedisplay"

external _keyboardUpFunc : unit -> unit = "ml_glutKeyboardUpFunc"
let glutKeyboardUpFunc ~cb = setup "glutKeyboardUpFunc" _keyboardUpFunc cb

external _glutSpecialUpFunc : unit -> unit = "ml_glutSpecialUpFunc"
let glutSpecialUpFunc ~cb =
  setup "glutSpecialUpFunc" _glutSpecialUpFunc
    (fun ~key ~x ~y -> cb (glut_special_of_int key) x y)

external _ignoreKeyRepeat : ignore:int -> unit = "ml_glutIgnoreKeyRepeat"
let glutIgnoreKeyRepeat ~ignore =
  _ignoreKeyRepeat (if ignore = true then 1 else 0)

external _setKeyRepeat : mode:int -> unit = "ml_glutSetKeyRepeat"
let glutSetKeyRepeat ~mode =
  _setKeyRepeat
    (match mode with
       GLUT_KEY_REPEAT_OFF -> 0
     | GLUT_KEY_REPEAT_ON -> 1
     | GLUT_KEY_REPEAT_DEFAULT -> 2)

external _joystickFunc : pollInterval:int -> unit = "ml_glutJoystickFunc" 
let glutJoystickFunc ~cb ~pollInterval =
  let _ = Callback.register (cbname "glutJoystickFunc") cb in
  _joystickFunc ~pollInterval

external glutForceJoystickFunc : unit -> unit = "ml_glutForceJoystickFunc"

  (* GLUT video resize sub-API. *)
external _videoResizeGet : int -> int = "ml_glutVideoResizeGet"
let glutVideoResizeGet which =
  let i =
    match which with
      GLUT_VIDEO_RESIZE_POSSIBLE -> 900
    | GLUT_VIDEO_RESIZE_IN_USE -> 901
    | GLUT_VIDEO_RESIZE_X_DELTA -> 902
    | GLUT_VIDEO_RESIZE_Y_DELTA -> 903
    | GLUT_VIDEO_RESIZE_WIDTH_DELTA -> 904
    | GLUT_VIDEO_RESIZE_HEIGHT_DELTA -> 905
    | GLUT_VIDEO_RESIZE_X -> 906
    | GLUT_VIDEO_RESIZE_Y -> 907
    | GLUT_VIDEO_RESIZE_WIDTH -> 908
    | GLUT_VIDEO_RESIZE_HEIGHT -> 909
  in
  _videoResizeGet i

external glutSetupVideoResizing : unit -> unit = "ml_glutSetupVideoResizing"
external glutStopVideoResizing : unit -> unit = "ml_glutStopVideoResizing"
external glutVideoResize :
  x:int -> y:int -> width:int -> height:int -> unit = "ml_glutVideoResize"
external glutVideoPan :
  x:int -> y:int -> width:int -> height:int -> unit = "ml_glutVideoPan"

  (* GLUT debugging sub-API. *)
external glutReportErrors : unit -> unit = "ml_glutReportErrors"

 (* GLUT game mode sub-API *)
external glutGameModeString : str:string -> unit = "ml_glutGameModeString"

external glutEnterGameMode : unit -> unit = "ml_glutEnterGameMode"

external glutLeaveGameMode : unit -> unit = "ml_glutLeaveGameMode"

external _gameModeGet : mode:int -> int = "ml_glutGameModeGet"

let glutGameModeGet ~mode =
  let imode =
    match mode with
      GLUT_GAME_MODE_ACTIVE -> 0
    | GLUT_GAME_MODE_POSSIBLE -> 1
    | GLUT_GAME_MODE_WIDTH -> 2
    | GLUT_GAME_MODE_HEIGHT -> 3
    | GLUT_GAME_MODE_PIXEL_DEPTH -> 4
    | GLUT_GAME_MODE_REFRESH_RATE -> 5
    | GLUT_GAME_MODE_DISPLAY_CHANGED -> 6
  in
  _gameModeGet imode

  (* ocaml specific *)
let glut_string_of_special key =
  match key with
    GLUT_KEY_F1 -> "KEY_F1"
  | GLUT_KEY_F2 -> "KEY_F2"
  | GLUT_KEY_F3 -> "KEY_F3"
  | GLUT_KEY_F4 -> "KEY_F4"
  | GLUT_KEY_F5 -> "KEY_F5"
  | GLUT_KEY_F6 -> "KEY_F6"
  | GLUT_KEY_F7 -> "KEY_F7"
  | GLUT_KEY_F8 -> "KEY_F8"
  | GLUT_KEY_F9 -> "KEY_F9"
  | GLUT_KEY_F10 -> "KEY_F10"
  | GLUT_KEY_F11 -> "KEY_F11"
  | GLUT_KEY_F12 -> "KEY_F12"
  | GLUT_KEY_LEFT -> "KEY_LEFT"
  | GLUT_KEY_UP -> "KEY_UP"
  | GLUT_KEY_RIGHT -> "KEY_RIGHT"
  | GLUT_KEY_DOWN -> "KEY_DOWN"
  | GLUT_KEY_PAGE_UP -> "KEY_PAGE_UP"
  | GLUT_KEY_PAGE_DOWN -> "KEY_PAGE_DOWN"
  | GLUT_KEY_HOME -> "KEY_HOME"
  | GLUT_KEY_END -> "KEY_END"
  | GLUT_KEY_INSERT -> "KEY_INSERT"

let glut_int_of_cursor c =
  match c with
    GLUT_CURSOR_RIGHT_ARROW -> 0
  | GLUT_CURSOR_LEFT_ARROW -> 1
  | GLUT_CURSOR_INFO -> 2
  | GLUT_CURSOR_DESTROY -> 3
  | GLUT_CURSOR_HELP -> 4
  | GLUT_CURSOR_CYCLE -> 5
  | GLUT_CURSOR_SPRAY -> 6
  | GLUT_CURSOR_WAIT -> 7
  | GLUT_CURSOR_TEXT -> 8
  | GLUT_CURSOR_CROSSHAIR -> 9
  | GLUT_CURSOR_UP_DOWN -> 10
  | GLUT_CURSOR_LEFT_RIGHT -> 11
  | GLUT_CURSOR_TOP_SIDE -> 12
  | GLUT_CURSOR_BOTTOM_SIDE -> 13
  | GLUT_CURSOR_LEFT_SIDE -> 14
  | GLUT_CURSOR_RIGHT_SIDE -> 15
  | GLUT_CURSOR_TOP_LEFT_CORNER -> 16
  | GLUT_CURSOR_TOP_RIGHT_CORNER -> 17
  | GLUT_CURSOR_BOTTOM_RIGHT_CORNER -> 18
  | GLUT_CURSOR_BOTTOM_LEFT_CORNER -> 19
  | GLUT_CURSOR_INHERIT -> 100
  | GLUT_CURSOR_NONE -> 101
  | GLUT_CURSOR_FULL_CROSSHAIR -> 102

let glut_string_of_cursor c =
  match c with
    GLUT_CURSOR_RIGHT_ARROW -> "CURSOR_RIGHT_ARROW"
  | GLUT_CURSOR_LEFT_ARROW -> "CURSOR_LEFT_ARROW"
  | GLUT_CURSOR_INFO -> "CURSOR_INFO"
  | GLUT_CURSOR_DESTROY -> "CURSOR_DESTROY"
  | GLUT_CURSOR_HELP -> "CURSOR_HELP"
  | GLUT_CURSOR_CYCLE -> "CURSOR_CYCLE"
  | GLUT_CURSOR_SPRAY -> "CURSOR_SPRAY"
  | GLUT_CURSOR_WAIT -> "CURSOR_WAIT"
  | GLUT_CURSOR_TEXT -> "CURSOR_TEXT"
  | GLUT_CURSOR_CROSSHAIR -> "CURSOR_CROSSHAIR"
  | GLUT_CURSOR_UP_DOWN -> "CURSOR_UP_DOWN"
  | GLUT_CURSOR_LEFT_RIGHT -> "CURSOR_LEFT_RIGHT"
  | GLUT_CURSOR_TOP_SIDE -> "CURSOR_TOP_SIDE"
  | GLUT_CURSOR_BOTTOM_SIDE -> "CURSOR_BOTTOM_SIDE"
  | GLUT_CURSOR_LEFT_SIDE -> "CURSOR_LEFT_SIDE"
  | GLUT_CURSOR_RIGHT_SIDE -> "CURSOR_RIGHT_SIDE"
  | GLUT_CURSOR_TOP_LEFT_CORNER -> "CURSOR_TOP_LEFT_CORNER"
  | GLUT_CURSOR_TOP_RIGHT_CORNER -> "CURSOR_TOP_RIGHT_CORNER"
  | GLUT_CURSOR_BOTTOM_RIGHT_CORNER -> "CURSOR_BOTTOM_RIGHT_CORNER"
  | GLUT_CURSOR_BOTTOM_LEFT_CORNER -> "CURSOR_BOTTOM_LEFT_CORNER"
  | GLUT_CURSOR_INHERIT -> "CURSOR_INHERIT"
  | GLUT_CURSOR_NONE -> "CURSOR_NONE"
  | GLUT_CURSOR_FULL_CROSSHAIR -> "CURSOR_FULL_CROSSHAIR"

let glut_int_of_modifier m =
  match m with
    GLUT_ACTIVE_SHIFT -> 1
  | GLUT_ACTIVE_CTRL -> 2
  | GLUT_ACTIVE_ALT -> 4

let glut_string_of_button b =
  match b with
    GLUT_LEFT_BUTTON -> "LEFT_BUTTON"
  | GLUT_MIDDLE_BUTTON -> "MIDDLE_BUTTON"
  | GLUT_RIGHT_BUTTON -> "RIGHT_BUTTON"
  | GLUT_OTHER_BUTTON n -> "OTHER_BUTTON" ^ string_of_int n

let glut_string_of_button_state s =
  match s with
    GLUT_DOWN -> "DOWN"
  | GLUT_UP -> "UP"
  
let glut_string_of_modifier m =
  match m with
    GLUT_ACTIVE_SHIFT -> "ACTIVE_SHIFT"
  | GLUT_ACTIVE_CTRL -> "ACTIVE_CTRL"
  | GLUT_ACTIVE_ALT -> "ACTIVE_ALT"

(* convert a list of strings to a single string *)
let glut_string_of_strings l =
  let rec _string_of_list l =
    match l with
      [] -> ""
    | h :: t -> h ^ (if t = [] then "" else ", " ^ _string_of_list t)
  in
  "[ " ^ _string_of_list l ^ " ]"

let glut_string_of_modifiers ml =
  glut_string_of_strings (List.map glut_string_of_modifier ml)

let glut_string_of_window_status status =
  match status with
    GLUT_HIDDEN -> "HIDDEN"
  | GLUT_FULLY_RETAINED -> "FULLY_RETAINED"
  | GLUT_PARTIALLY_RETAINED -> "PARTIALLY_RETAINED"
  | GLUT_FULLY_COVERED -> "FULLY_COVERED"

let glut_string_of_vis_state vis =
  match vis with
    GLUT_NOT_VISIBLE -> "NOT_VISIBLE"
  | GLUT_VISIBLE -> "VISIBLE"

