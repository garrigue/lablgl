(* glutcaml.mli is the OCaml interface for Mark Kilgard's simple, 
   cross-platform OpenGL windowing library GLUT.

   Copyright (c) Issac Trotts 2003.
   Released under a BSD-style license. *)

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

(* display mode bit masks *)
val glut_rgb : int
val glut_rgba : int
val glut_index : int
val glut_single : int
val glut_double : int
val glut_accum : int
val glut_alpha : int
val glut_depth : int
val glut_stencil : int
val glut_multisample : int
val glut_stereo : int
val glut_luminance : int

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

(* key modifier bit masks *)
val glut_active_shift : int
val glut_active_ctrl : int
val glut_active_alt : int

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
  | GLUT_CURSOR_FULL_CROSSHAIR(* full-screen crosshair (if available) *)

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

(* GLUT initialization sub-API. *)
val glutInit : argv:string array -> string array(* returns new argv *)
val glutInit2 : unit -> unit (* simpler version that sends off Sys.argv *)
val glutInitDisplayMode :
  ?double_buffer: bool -> ?index: bool -> ?accum: bool -> ?alpha: bool ->
    ?depth: bool -> ?stencil: bool -> ?multisample: bool -> ?stereo: bool ->
    ?luminance: bool -> unit -> unit
val glutInitWindowPosition : x:int -> y:int -> unit
val glutInitWindowSize : w:int -> h:int -> unit
val glutMainLoop : unit -> unit

(* GLUT window sub-API. *)
val glutCreateWindow : title:string -> int(* returns window id *)
val glutCreateWindow2 : title:string -> unit 
val glutPostRedisplay : unit -> unit
val glutSwapBuffers : unit -> unit
val glutCreateSubWindow : win:int -> x:int -> y:int -> w:int -> h:int -> int
val glutDestroyWindow : win:int -> unit
val glutGetWindow : unit -> int
val glutSetWindow : win:int -> unit  
val glutSetWindowTitle : title:string -> unit
val glutSetIconTitle : title:string -> unit
val glutPositionWindow : x:int -> y:int -> unit
val glutReshapeWindow : w:int -> h:int -> unit
val glutPopWindow : unit -> unit
val glutPushWindow : unit -> unit
val glutIconifyWindow : unit -> unit
val glutShowWindow : unit -> unit
val glutHideWindow : unit -> unit
val glutFullScreen : unit -> unit
val glutSetCursor : glut_cursor_t -> unit

(* GLUT overlay sub-API. *)
val glutEstablishOverlay : unit -> unit
val glutRemoveOverlay : unit -> unit
val glutUseLayer : glut_layer_t -> unit
val glutPostOverlayRedisplay : unit -> unit
val glutShowOverlay : unit -> unit
val glutHideOverlay : unit -> unit

(* GLUT menu sub-API. *)
val glutCreateMenu : cb:(int -> unit) -> int
val glutDestroyMenu : menu:int -> unit
val glutGetMenu : unit -> int
val glutSetMenu : menu:int -> unit
val glutAddMenuEntry : label:string -> value:int -> unit
val glutAddSubMenu : label:string -> submenu:int -> unit
val glutChangeToMenuEntry : item:int -> label:string -> value:int -> unit
val glutChangeToSubMenu : item:int -> label:string -> submenu:int -> unit
val glutRemoveMenuItem : item:int -> unit
val glutAttachMenu : button:glut_button_t -> unit
val glutDetachMenu : button:glut_button_t -> unit

(* GLUT window callback sub-API. *)
val glutDisplayFunc : cb:(unit -> unit) -> unit
val glutReshapeFunc : cb:(int -> int -> unit) -> unit
val glutKeyboardFunc : cb:(int -> int -> int -> unit) -> unit
val glutMouseFunc :
  cb:(glut_button_t -> glut_mouse_button_state_t -> int -> int -> unit) -> unit
val glutMotionFunc : cb:(int -> int -> unit) -> unit 
val glutPassiveMotionFunc : cb:(int -> int -> unit) -> unit 
val glutEntryFunc : cb:(glut_entry_exit_state_t -> unit) -> unit 
val glutVisibilityFunc : cb:(glut_visibility_state_t -> unit) -> unit
val glutIdleFunc : cb:(unit -> unit) option -> unit
val glutTimerFunc : ms:int -> cb:(int -> unit) -> value:int -> unit
val glutMenuStateFunc : cb:(glut_menu_state_t -> unit) -> unit
val glutSpecialFunc : cb:(glut_special_key_t -> int -> int -> unit) -> unit
val glutSpaceballMotionFunc : cb:(int -> int -> int -> unit) -> unit
val glutSpaceballRotateFunc : cb:(int -> int -> int -> unit) -> unit
val glutSpaceballButtonFunc : cb:(int -> int -> unit) -> unit
val glutButtonBoxFunc : cb:(int -> int -> unit) -> unit
val glutDialsFunc : cb:(int -> int -> unit) -> unit
val glutTabletMotionFunc : cb:(int -> int -> unit) -> unit
val glutTabletButtonFunc : cb:(int -> int -> int -> int -> unit) -> unit
val glutMenuStatusFunc : cb:(glut_menu_state_t -> int -> int -> unit) -> unit
val glutOverlayDisplayFunc : cb:(unit -> unit) -> unit

(* GLUT color index sub-API. *)
val glutSetColor : cell:int -> red:float -> green:float -> blue:float -> unit
val glutGetColor : index:int -> component:int -> float
val glutCopyColormap : win:int -> unit

(* GLUT state retrieval sub-API. *)
val glutGet : gtype:glut_get_t -> int
val glutGetBool : gtype:glut_get_bool_t -> bool 
val glutDeviceGet : dgtype:glut_device_get_t -> int

(* GLUT extension support sub-API *)
val glutExtensionSupported : name:string -> bool
val glutGetModifiers : unit -> int 
val glutLayerGetTransparentIndex : unit -> int 
val glutLayerGetInUse : unit -> glut_layer_t
val glutLayerGet : lgtype:glut_layerget_t -> bool 

(* GLUT font sub-API *)
val glutBitmapCharacter : font:glut_font_t -> c:int -> unit
val glutBitmapWidth : font:glut_font_t -> c:int -> int
val glutStrokeCharacter : font:glut_font_t -> c:int -> unit
val glutStrokeWidth : font:glut_font_t -> c:int -> int

(* GLUT pre-built models sub-API *)
val glutWireSphere : radius:float -> slices:int -> stacks:int -> unit
val glutSolidSphere : radius:float -> slices:int -> stacks:int -> unit
val glutWireCone :
  base:float -> height:float -> slices:int -> stacks:int -> unit
val glutSolidCone :
  base:float -> height:float -> slices:int -> stacks:int -> unit
val glutWireCube : size:float -> unit
val glutSolidCube : size:float -> unit
val glutWireTorus :
  innerRadius:float -> outerRadius:float -> sides:int -> rings:int -> unit
val glutSolidTorus :
  innerRadius:float -> outerRadius:float -> sides:int -> rings:int -> unit
val glutWireDodecahedron : unit -> unit
val glutSolidDodecahedron : unit -> unit
val glutWireTeapot : size:float -> unit
val glutSolidTeapot : size:float -> unit
val glutWireOctahedron : unit -> unit
val glutSolidOctahedron : unit -> unit
val glutWireTetrahedron : unit -> unit
val glutSolidTetrahedron : unit -> unit
val glutWireIcosahedron : unit -> unit
val glutSolidIcosahedron : unit -> unit

(* GLUT game mode sub-API *)
val glutGameModeString : str:string -> unit
val glutEnterGameMode : unit -> unit
val glutLeaveGameMode : unit -> unit
val glutGameModeGet : mode:glut_game_mode_t -> int

(* GLUT version 4 functions included in the GLUT 3.7 distribution *)
val glutInitDisplayString : str:string -> unit
val glutWarpPointer : x:int -> y:int -> unit
val glutBitmapLength : font:glut_font_t -> str:string -> int
val glutStrokeLength : font:glut_font_t -> str:string -> int
val glutWindowStatusFunc : cb:(glut_window_status_t -> unit) -> unit
val glutPostWindowRedisplay : win:int -> unit
val glutPostWindowOverlayRedisplay : win:int -> unit 
val glutKeyboardUpFunc : cb:(int -> int -> int -> unit) -> unit
val glutSpecialUpFunc : cb:(glut_special_key_t -> int -> int -> unit) -> unit
val glutIgnoreKeyRepeat : ignore:bool -> unit
val glutSetKeyRepeat : mode:glut_key_repeat_t -> unit
val glutJoystickFunc :
  cb:(int -> int -> int -> int -> unit) -> pollInterval:int -> unit
val glutForceJoystickFunc : unit -> unit

(* GLUT video resize sub-API. *)
val glutVideoResizeGet : glut_video_resize_t -> int
val glutSetupVideoResizing : unit -> unit
val glutStopVideoResizing : unit -> unit
val glutVideoResize : x:int -> y:int -> width:int -> height:int -> unit
val glutVideoPan : x:int -> y:int -> width:int -> height:int -> unit

(* GLUT debugging sub-API. *)
val glutReportErrors : unit -> unit

(* ocaml-specific *)
val glut_string_of_button : glut_button_t -> string
val glut_string_of_button_state : glut_mouse_button_state_t -> string
val glut_string_of_special : glut_special_key_t -> string
val glut_string_of_window_status : glut_window_status_t -> string
val glut_string_of_vis_state : glut_visibility_state_t -> string
val glut_string_of_cursor : glut_cursor_t -> string
val glut_int_of_cursor : glut_cursor_t -> int

