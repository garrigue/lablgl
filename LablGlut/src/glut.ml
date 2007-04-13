(* ==== types ==== *)

type button_t = 
    | LEFT_BUTTON 
    | MIDDLE_BUTTON 
    | RIGHT_BUTTON
    | OTHER_BUTTON of int

type mouse_button_state_t = 
    | DOWN 
    | UP 

type special_key_t = 
    | KEY_F1
    | KEY_F2                    
    | KEY_F3            
    | KEY_F4    
    | KEY_F5
    | KEY_F6                    
    | KEY_F7                    
    | KEY_F8                    
    | KEY_F9                    
    | KEY_F10                   
    | KEY_F11                   
    | KEY_F12                   
     (* directional keys *)
    | KEY_LEFT                  
    | KEY_UP                    
    | KEY_RIGHT                 
    | KEY_DOWN                  
    | KEY_PAGE_UP               
    | KEY_PAGE_DOWN             
    | KEY_HOME                  
    | KEY_END                   
    | KEY_INSERT                        

type entry_exit_state_t =
    | LEFT                      
    | ENTERED

type menu_state_t = 
    | MENU_NOT_IN_USE   
    | MENU_IN_USE               

type visibility_state_t =
    | NOT_VISIBLE               
    | VISIBLE                   

type window_status_t = 
    | HIDDEN                    
    | FULLY_RETAINED            
    | PARTIALLY_RETAINED                
    | FULLY_COVERED             

type color_index_component_t =
    | RED                       
    | GREEN                     
    | BLUE                      

type layer_t =
    | NORMAL                    
    | OVERLAY                   

type font_t =
    | STROKE_ROMAN              
    | STROKE_MONO_ROMAN         
    | BITMAP_9_BY_15            
    | BITMAP_8_BY_13            
    | BITMAP_TIMES_ROMAN_10     
    | BITMAP_TIMES_ROMAN_24     
    | BITMAP_HELVETICA_10       
    | BITMAP_HELVETICA_12       
    | BITMAP_HELVETICA_18       

type glut_get_t =
    | WINDOW_X                  
    | WINDOW_Y                  
    | WINDOW_WIDTH              
    | WINDOW_HEIGHT             
    | WINDOW_BUFFER_SIZE                
    | WINDOW_STENCIL_SIZE       
    | WINDOW_DEPTH_SIZE         
    | WINDOW_RED_SIZE           
    | WINDOW_GREEN_SIZE         
    | WINDOW_BLUE_SIZE          
    | WINDOW_ALPHA_SIZE         
    | WINDOW_ACCUM_RED_SIZE     
    | WINDOW_ACCUM_GREEN_SIZE   
    | WINDOW_ACCUM_BLUE_SIZE    
    | WINDOW_ACCUM_ALPHA_SIZE   
    | WINDOW_DOUBLEBUFFER       
    | WINDOW_RGBA               
    | WINDOW_PARENT             
    | WINDOW_NUM_CHILDREN       
    | WINDOW_COLORMAP_SIZE      
    | WINDOW_NUM_SAMPLES                
    | WINDOW_STEREO             
    | WINDOW_CURSOR             
    | SCREEN_WIDTH              
    | SCREEN_HEIGHT             
    | SCREEN_WIDTH_MM           
    | SCREEN_HEIGHT_MM          
    | MENU_NUM_ITEMS            
    (* | DISPLAY_MODE_POSSIBLE : use getBool *)
    | INIT_WINDOW_X             
    | INIT_WINDOW_Y             
    | INIT_WINDOW_WIDTH         
    | INIT_WINDOW_HEIGHT                
    | INIT_DISPLAY_MODE         
    | ELAPSED_TIME              
    | WINDOW_FORMAT_ID 

type glut_get_bool_t = 
    | DISPLAY_MODE_POSSIBLE

let rgb = 0;;
let rgba = rgb;; (* same as in glut.h *)
let index = 1;;
let single = 0;;
let double = 2;;
let accum = 4;;
let alpha = 8;;
let depth = 16;;
let stencil = 32;;
let multisample = 128;;
let stereo = 256;;
let luminance = 512;;

type device_get_t =
    | HAS_KEYBOARD              
    | HAS_MOUSE                 
    | HAS_SPACEBALL             
    | HAS_DIAL_AND_BUTTON_BOX   
    | HAS_TABLET                        
    | NUM_MOUSE_BUTTONS         
    | NUM_SPACEBALL_BUTTONS     
    | NUM_BUTTON_BOX_BUTTONS    
    | NUM_DIALS                 
    | NUM_TABLET_BUTTONS                
    | DEVICE_IGNORE_KEY_REPEAT   
    | DEVICE_KEY_REPEAT          
    | HAS_JOYSTICK              
    | OWNS_JOYSTICK             
    | JOYSTICK_BUTTONS          
    | JOYSTICK_AXES             
    | JOYSTICK_POLL_RATE                

type layerget_t = 
    | OVERLAY_POSSIBLE           
    (* | LAYER_IN_USE : use layerGetInUse *)
    | HAS_OVERLAY               
    (* | TRANSPARENT_INDEX : use layerGetTransparentIndex *)
    | NORMAL_DAMAGED            
    | OVERLAY_DAMAGED           

type video_resize_t = 
    | VIDEO_RESIZE_POSSIBLE     
    | VIDEO_RESIZE_IN_USE       
    | VIDEO_RESIZE_X_DELTA      
    | VIDEO_RESIZE_Y_DELTA      
    | VIDEO_RESIZE_WIDTH_DELTA  
    | VIDEO_RESIZE_HEIGHT_DELTA 
    | VIDEO_RESIZE_X            
    | VIDEO_RESIZE_Y            
    | VIDEO_RESIZE_WIDTH                
    | VIDEO_RESIZE_HEIGHT       

type get_modifiers_t = 
    | ACTIVE_SHIFT               
    | ACTIVE_CTRL                
    | ACTIVE_ALT                 

let active_shift = 1
let active_ctrl = 2
let active_alt = 4

type cursor_t = 
     (* Basic arrows. *)
    | CURSOR_RIGHT_ARROW                
    | CURSOR_LEFT_ARROW         
     (* Symbolic cursor shapes. *)
    | CURSOR_INFO               
    | CURSOR_DESTROY            
    | CURSOR_HELP               
    | CURSOR_CYCLE              
    | CURSOR_SPRAY              
    | CURSOR_WAIT               
    | CURSOR_TEXT               
    | CURSOR_CROSSHAIR          
     (* Directional cursors. *)
    | CURSOR_UP_DOWN            
    | CURSOR_LEFT_RIGHT         
     (* Sizing cursors. *)
    | CURSOR_TOP_SIDE           
    | CURSOR_BOTTOM_SIDE                
    | CURSOR_LEFT_SIDE          
    | CURSOR_RIGHT_SIDE         
    | CURSOR_TOP_LEFT_CORNER    
    | CURSOR_TOP_RIGHT_CORNER   
    | CURSOR_BOTTOM_RIGHT_CORNER        
    | CURSOR_BOTTOM_LEFT_CORNER 
    | CURSOR_INHERIT              (* inherit cursor from parent window *)
    | CURSOR_NONE                     (* blank cursor *)
    | CURSOR_FULL_CROSSHAIR   (* full-screen crosshair  : if available *)

type game_mode_t = 
    | GAME_MODE_ACTIVE
    | GAME_MODE_POSSIBLE
    | GAME_MODE_WIDTH
    | GAME_MODE_HEIGHT
    | GAME_MODE_PIXEL_DEPTH
    | GAME_MODE_REFRESH_RATE
    | GAME_MODE_DISPLAY_CHANGED

type key_repeat_t = 
    | KEY_REPEAT_OFF
    | KEY_REPEAT_ON
    | KEY_REPEAT_DEFAULT

exception BadEnum of string
exception InvalidState of string 
exception OverlayNotInUse of string

open Printf;;

(* ==== file-local variables ==== *)

let is_init = ref false;;
let is_displayModeInit = ref false;;
let is_windowSizeInit = ref false;;
let is_windowPositionInit = ref false;;
let has_createdWindow = ref false;;

 (* === GLUT initialization sub-API. === *)
external _glutInit : int -> string array -> int = "ml_glutInit" 

let init ~argv = 
  if !is_init then argv else begin
    is_init := true;
    let argc = Array.length argv in
    let argv = Array.append argv [|""|] in
    let argc = _glutInit argc argv in
    Array.sub argv 0 argc
  end

external _glutInitDisplayMode : 
    double_buffer:bool ->
    index:bool ->
    accum:bool ->
    alpha:bool ->
    depth:bool ->
    stencil:bool ->
    multisample:bool ->
    stereo:bool ->
    luminance:bool ->
    unit =
    "bytecode_glutInitDisplayMode"
    "native_glutInitDisplayMode"

let initDisplayMode 
    ?(double_buffer=false)
    ?(index=false) 
    ?(accum=false)
    ?(alpha=false) 
    ?(depth=false) 
    ?(stencil=false) 
    ?(multisample=false) 
    ?(stereo=false) 
    ?(luminance=false) 
    dummy_unit
    = 
    is_displayModeInit := true;
    _glutInitDisplayMode 
        double_buffer
        index
        accum
        alpha
        depth
        stencil
        multisample
        stereo
        luminance
    ;;

external _glutInitWindowSize : int->int->unit = "ml_glutInitWindowSize"

external _glutInitWindowPosition : int->int->unit = "ml_glutInitWindowPosition"
let initWindowPosition ~x ~y =
    is_windowPositionInit := true;
    _glutInitWindowPosition x y;;

let initWindowSize ~w ~h =   
    is_windowSizeInit := true;
    _glutInitWindowSize w h;;

external mainLoop : unit->unit = "ml_glutMainLoop"

 (* === GLUT window sub-API. === *)

external _glutCreateWindow : string->int = "ml_glutCreateWindow"

let createWindow ~title =
    has_createdWindow := true;
    let winid = _glutCreateWindow title in
    winid;;

external postRedisplay : unit->unit = 
    "ml_glutPostRedisplay"
external swapBuffers : unit->unit = 
    "ml_glutSwapBuffers" 
external createSubWindow: win:int->x:int->y:int->w:int->h:int->int = 
    "ml_glutCreateSubWindow"
external destroyWindow: win:int -> unit = 
    "ml_glutDestroyWindow"
external setWindow: win:int -> unit = 
    "ml_glutSetWindow"
external getWindow: unit -> int =
     "ml_glutGetWindow"
external setWindowTitle: title:string -> unit  = 
    "ml_glutSetWindowTitle"
external setIconTitle: title:string -> unit = 
    "ml_glutSetIconTitle"
external positionWindow: x:int -> y:int -> unit = 
    "ml_glutPositionWindow"
external reshapeWindow: w:int -> h:int -> unit = 
    "ml_glutReshapeWindow"
external popWindow: unit -> unit = 
    "ml_glutPopWindow"
external pushWindow: unit -> unit = 
    "ml_glutPushWindow"
external iconifyWindow: unit -> unit = 
    "ml_glutIconifyWindow"
external showWindow: unit -> unit = 
    "ml_glutShowWindow"
external hideWindow: unit -> unit = 
    "ml_glutHideWindow"
external fullScreen: unit -> unit = 
    "ml_glutFullScreen"

external _setCursor: c:int -> unit = "ml_glutSetCursor"
let setCursor c = 
    let ic = match c with 
     (* Basic arrows. *)
    | CURSOR_RIGHT_ARROW -> 0  (* values from glut.h *)
    | CURSOR_LEFT_ARROW -> 1 
     (* Symbolic cursor shapes. *)
    | CURSOR_INFO -> 2
    | CURSOR_DESTROY -> 3
    | CURSOR_HELP -> 4
    | CURSOR_CYCLE -> 5
    | CURSOR_SPRAY -> 6
    | CURSOR_WAIT -> 7
    | CURSOR_TEXT -> 8
    | CURSOR_CROSSHAIR -> 9
     (* Directional cursors. *)
    | CURSOR_UP_DOWN -> 10
    | CURSOR_LEFT_RIGHT -> 11
     (* Sizing cursors. *)
    | CURSOR_TOP_SIDE -> 12
    | CURSOR_BOTTOM_SIDE -> 13
    | CURSOR_LEFT_SIDE -> 14
    | CURSOR_RIGHT_SIDE -> 15
    | CURSOR_TOP_LEFT_CORNER -> 16
    | CURSOR_TOP_RIGHT_CORNER -> 17
    | CURSOR_BOTTOM_RIGHT_CORNER -> 18
    | CURSOR_BOTTOM_LEFT_CORNER -> 19
    | CURSOR_INHERIT -> 100
    | CURSOR_NONE -> 101
    | CURSOR_FULL_CROSSHAIR -> 102
    in _setCursor ic
    ;;

 (* === GLUT overlay sub-API. === *)
external establishOverlay: unit->unit  = "ml_glutEstablishOverlay"
external removeOverlay: unit->unit = "ml_glutRemoveOverlay"
external postOverlayRedisplay: unit->unit = "ml_glutPostOverlayRedisplay"
external showOverlay: unit->unit = "ml_glutShowOverlay"
external hideOverlay: unit->unit = "ml_glutHideOverlay"

external _useLayer: int -> unit = "ml_glutUseLayer"
let useLayer layer = _useLayer (match layer with NORMAL -> 0 | OVERLAY -> 1)

 (* === GLUT menu sub-API. === *)

external createMenu: cb:(value:int -> unit) ->int =
    "ml_glutCreateMenu"
external destroyMenu: menu:int->unit = 
    "ml_glutDestroyMenu"
external getMenu: unit->int = 
    "ml_glutGetMenu"
external setMenu: menu:int->unit  = 
    "ml_glutSetMenu"
external addMenuEntry: label:string->value:int->unit  = 
    "ml_glutAddMenuEntry"
external addSubMenu: label:string->submenu:int->unit  = 
    "ml_glutAddSubMenu"
external changeToMenuEntry: item:int->label:string->value:int->unit = 
    "ml_glutChangeToMenuEntry"
external changeToSubMenu: item:int->label:string->submenu:int->unit = 
    "ml_glutChangeToSubMenu"
external removeMenuItem: item:int->unit= 
    "ml_glutRemoveMenuItem"

let int_of_button b = match b with
    | LEFT_BUTTON -> 0
    | MIDDLE_BUTTON -> 1
    | RIGHT_BUTTON -> 2
    | OTHER_BUTTON n -> n

let b2i b = int_of_button b;;

external _attachMenu: button:int->unit= "ml_glutAttachMenu"
let attachMenu ~button = _attachMenu (b2i button);;

external _detachMenu: button:int->unit= "ml_glutDetachMenu"
let detachMenu ~button = _detachMenu (b2i button);;

 (* === GLUT window callback sub-API. === *)

let window_wrapper cbFunc wr =
  let table = Hashtbl.create 3 in
  fun ~cb ->
    Hashtbl.add table (getWindow()) cb;
    cbFunc ~cb:(wr (fun () -> Hashtbl.find table (getWindow())))
  
external _displayFunc : cb:(unit->unit)->unit = "ml_glutDisplayFunc"
let displayFunc = window_wrapper _displayFunc (fun cb () -> cb () ())

external _reshapeFunc : cb:(w:int->h:int->unit)->unit = "ml_glutReshapeFunc"
let reshapeFunc = window_wrapper _reshapeFunc (fun cb ~w -> cb () ~w)

external _keyboardFunc : cb:(key:int->x:int->y:int->unit)->unit =
  "ml_glutKeyboardFunc"
let keyboardFunc = window_wrapper _keyboardFunc (fun cb ~key -> cb () ~key)

external _glutMouseFunc : cb:(int -> int -> int -> int -> unit)->unit =
  "ml_glutMouseFunc"
let mouse_cb_wrapper user_func ibutton istate x y =
    let b = match ibutton with 
        | 0 -> LEFT_BUTTON 
        | 1 -> MIDDLE_BUTTON 
        | 2 -> RIGHT_BUTTON 
        | n -> OTHER_BUTTON n in
    let s = match istate with 
        | 0 -> DOWN 
        | 1 -> UP 
        | _ -> raise (BadEnum "istate in mouse_cb_wrapper") in
    user_func () ~button:b ~state:s ~x ~y;;
let mouseFunc = window_wrapper _glutMouseFunc mouse_cb_wrapper

let eta_x cb ~x = cb () ~x

external _motionFunc : cb:(x:int->y:int->unit)->unit = "ml_glutMotionFunc"
let motionFunc = window_wrapper _motionFunc eta_x

external _passiveMotionFunc : cb:(x:int->y:int->unit)->unit =
  "ml_glutPassiveMotionFunc"
let passiveMotionFunc = window_wrapper _passiveMotionFunc eta_x

let eta_state cb ~state = cb () ~state

external _entryFunc : cb:(state:entry_exit_state_t->unit)->unit =
  "ml_glutEntryFunc" 
let entryFunc = window_wrapper _entryFunc eta_state

external _visibilityFunc : cb:(state:visibility_state_t->unit)->unit =
  "ml_glutVisibilityFunc"
let visibilityFunc = window_wrapper _visibilityFunc eta_state

(* idleFunc is for the entire program, not just a single window,
   so its name does not depend on the window id *)
external _glutIdleFunc:(unit->unit)->unit="ml_glutIdleFunc"

external _setIdleFuncToNull:unit->unit="ml_glutSetIdleFuncToNull"
let idleFunc ~cb = 
    match cb with 
    | None -> _setIdleFuncToNull();
    | Some cb -> 
      begin
        _glutIdleFunc cb;
      end
;;

(* timerFunc is non-window-dependent *)

external _timerFunc : int -> int -> unit = "ml_glutTimerFunc"

external init_timerFunc : (int -> unit) -> unit = "init_glutTimerFunc_cb"

let timer_hashtbl = Hashtbl.create 101

let real_call_back i = 
  Hashtbl.find timer_hashtbl i ()

let _ = 
  init_timerFunc real_call_back

let timer_count = ref 0 

let timerFunc ~ms ~cb:(cb:(value:'a -> unit)) ~value =
    let i = !timer_count in
    incr timer_count;
    Hashtbl.add timer_hashtbl i (fun () -> 
      Hashtbl.remove timer_hashtbl i; 
      cb value);
    _timerFunc ms i

let special_of_int i = match i with
  | 1 -> KEY_F1    (* values from glut.h *)
  | 2 -> KEY_F2    
  | 3 -> KEY_F3    
  | 4 -> KEY_F4    
  | 5 -> KEY_F5    
  | 6 -> KEY_F6    
  | 7 -> KEY_F7    
  | 8 -> KEY_F8    
  | 9 -> KEY_F9    
  | 10 -> KEY_F10    
  | 11 -> KEY_F11    
  | 12 -> KEY_F12    
  | 100 -> KEY_LEFT    
  | 101 -> KEY_UP    
  | 102 -> KEY_RIGHT    
  | 103 -> KEY_DOWN    
  | 104 -> KEY_PAGE_UP    
  | 105 -> KEY_PAGE_DOWN    
  | 106 -> KEY_HOME    
  | 107 -> KEY_END    
  | 108 -> KEY_INSERT    
  | _ -> raise (BadEnum "key in special_of_int");;

external _glutSpecialFunc : cb:(key:int->x:int->y:int->unit)->unit =
  "ml_glutSpecialFunc"
let specialFunc =
  window_wrapper _glutSpecialFunc
    (fun cb ~key -> cb () ~key:(special_of_int key))

external _spaceballMotionFunc: cb:(x:int->y:int->z:int->unit)->unit =
  "ml_glutSpaceballMotionFunc"
let spaceballMotionFunc = window_wrapper _spaceballMotionFunc eta_x

external _spaceballRotateFunc: cb:(x:int->y:int->z:int->unit)->unit =
  "ml_glutSpaceballRotateFunc"
let spaceballRotateFunc = window_wrapper _spaceballRotateFunc eta_x

let eta_button cb ~button = cb () ~button

external _spaceballButtonFunc: cb:(button:int->state:int->unit)->unit = "ml_glutSpaceballButtonFunc"
let spaceballButtonFunc = window_wrapper _spaceballButtonFunc eta_button

external _buttonBoxFunc: cb:(button:int->state:int->unit)->unit =
  "ml_glutButtonBoxFunc"
let buttonBoxFunc = window_wrapper _buttonBoxFunc eta_button

external _dialsFunc: cb:(dial:int->value:int->unit)->unit = "ml_glutDialsFunc"
let dialsFunc = window_wrapper _dialsFunc (fun cb ~dial -> cb () ~dial)

external _tabletMotionFunc: cb:(x:int->y:int->unit)->unit =
  "ml_glutTabletMotionFunc"
let tabletMotionFunc = window_wrapper _tabletMotionFunc eta_x

external _tabletButtonFunc: cb:(button:int->state:int->x:int->y:int->unit)->unit
    = "ml_glutTabletButtonFunc"
let tabletButtonFunc = window_wrapper _tabletButtonFunc eta_button

external menuStatusFunc: cb:(status:menu_state_t->x:int->y:int->unit)->unit =
  "ml_glutMenuStatusFunc"

external _overlayDisplayFunc: cb:(unit->unit)->unit =
  "ml_glutOverlayDisplayFunc"
let overlayDisplayFunc =
  window_wrapper _overlayDisplayFunc (fun cb () -> cb () ())

 (* === GLUT color index sub-API. === === *)
external setColor: cell:int->red:float->green:float->blue:float->unit = 
    "ml_glutSetColor"
external getColor: index:int->component:int->float = 
    "ml_glutGetColor"
external copyColormap: win:int->unit = 
    "ml_glutCopyColormap"

 (* === GLUT state retrieval sub-API. === *)
external _get: igtype:int->int = "ml_glutGet"
let get ~gtype = 
    let igtype = match gtype with
    | WINDOW_X -> 100
    | WINDOW_Y -> 101
    | WINDOW_WIDTH -> 102
    | WINDOW_HEIGHT -> 103
    | WINDOW_BUFFER_SIZE -> 104
    | WINDOW_STENCIL_SIZE -> 105
    | WINDOW_DEPTH_SIZE -> 106
    | WINDOW_RED_SIZE -> 107
    | WINDOW_GREEN_SIZE -> 108
    | WINDOW_BLUE_SIZE -> 109
    | WINDOW_ALPHA_SIZE -> 110
    | WINDOW_ACCUM_RED_SIZE -> 111
    | WINDOW_ACCUM_GREEN_SIZE -> 112
    | WINDOW_ACCUM_BLUE_SIZE -> 113
    | WINDOW_ACCUM_ALPHA_SIZE -> 114
    | WINDOW_DOUBLEBUFFER -> 115
    | WINDOW_RGBA -> 116
    | WINDOW_PARENT -> 117
    | WINDOW_NUM_CHILDREN -> 118
    | WINDOW_COLORMAP_SIZE -> 119
    | WINDOW_NUM_SAMPLES -> 120
    | WINDOW_STEREO -> 121
    | WINDOW_CURSOR -> 122
    | SCREEN_WIDTH -> 200
    | SCREEN_HEIGHT -> 201
    | SCREEN_WIDTH_MM -> 202
    | SCREEN_HEIGHT_MM -> 203
    | MENU_NUM_ITEMS -> 300
    (* | DISPLAY_MODE_POSSIBLE -> 400 *)
    | INIT_WINDOW_X -> 500
    | INIT_WINDOW_Y -> 501
    | INIT_WINDOW_WIDTH -> 502 
    | INIT_WINDOW_HEIGHT -> 503
    | INIT_DISPLAY_MODE -> 504
    | ELAPSED_TIME -> 700
    | WINDOW_FORMAT_ID -> 123
    in _get igtype ;;

let getBool ~gtype = _get (match gtype with DISPLAY_MODE_POSSIBLE -> 400) <> 0

external _deviceGet: idgtype:int->int = "ml_glutDeviceGet"
let deviceGet ~dgtype =
    let idgtype = match dgtype with 
    | HAS_KEYBOARD -> 600
    | HAS_MOUSE -> 601
    | HAS_SPACEBALL -> 602
    | HAS_DIAL_AND_BUTTON_BOX -> 603
    | HAS_TABLET -> 604
    | NUM_MOUSE_BUTTONS -> 605
    | NUM_SPACEBALL_BUTTONS -> 606
    | NUM_BUTTON_BOX_BUTTONS -> 607
    | NUM_DIALS -> 608
    | NUM_TABLET_BUTTONS -> 609
    | DEVICE_IGNORE_KEY_REPEAT -> 610
    | DEVICE_KEY_REPEAT -> 611
    | HAS_JOYSTICK -> 612
    | OWNS_JOYSTICK -> 613
    | JOYSTICK_BUTTONS -> 614
    | JOYSTICK_AXES -> 615
    | JOYSTICK_POLL_RATE -> 616
    in _deviceGet idgtype;;

 (* === GLUT extension support sub-API === *) 
external extensionSupported: name:string->bool = "ml_glutExtensionSupported"

external getModifiers: unit->int = "ml_glutGetModifiers"
(*
let getModifiers () = let m = _getModifiers() in
  if m land 1 <> 0 then [ACTIVE_SHIFT] else [] @
  if m land 2 <> 0 then [ACTIVE_CTRL] else [] @
  if m land 4 <> 0 then [ACTIVE_ALT] else [];;
*)

let int_of_modifiers m = 
  let ret = ref 0 in 
  let rec f = function 
    | [] -> ()
    | h::t -> begin
      ret := (!ret lor (match h with
        | ACTIVE_SHIFT -> 1
        | ACTIVE_CTRL -> 2
        | ACTIVE_ALT -> 4));
      f t 
      end in
  f m;
  !ret;;

external _layerGet: int->int = "ml_glutLayerGet"
let layerGet ~lgtype = 
  let ilgtype = match lgtype with 
    | OVERLAY_POSSIBLE -> 800
    | HAS_OVERLAY -> 802
    | NORMAL_DAMAGED -> 804
    | OVERLAY_DAMAGED -> 805 in
  let ret = _layerGet ilgtype in 
  if lgtype = OVERLAY_DAMAGED && ret = -1 then
    raise (OverlayNotInUse "in layerGet OVERLAY_DAMAGED")
  else 
    ret <> 0
;;

let layerGetTransparentIndex() = _layerGet 803 ;; (* from glut.h *)

let layerGetInUse () = 
  match _layerGet 801 with
  | 0 -> NORMAL
  | 1 -> OVERLAY
  | _ -> failwith "unexpected value in layerGetInUse"

 (* === GLUT font sub-API === *)

(* convert font to integer value from glut.h *)
let f2i font = match font with 
    | STROKE_ROMAN -> 0
    | STROKE_MONO_ROMAN -> 1
    | BITMAP_9_BY_15 -> 2
    | BITMAP_8_BY_13 -> 3
    | BITMAP_TIMES_ROMAN_10 -> 4
    | BITMAP_TIMES_ROMAN_24 -> 5
    | BITMAP_HELVETICA_10 -> 6
    | BITMAP_HELVETICA_12 -> 7
    | BITMAP_HELVETICA_18 -> 8;;

external _bitmapCharacter: font:int->c:int->unit = "ml_glutBitmapCharacter"
let bitmapCharacter ~font ~c = _bitmapCharacter (f2i font) c;;

external _bitmapWidth: font:int->c:int->int = "ml_glutBitmapWidth"
let bitmapWidth ~font ~c = _bitmapWidth (f2i font) c;;

external _strokeCharacter: font:int->c:int->unit = "ml_glutStrokeCharacter"
let strokeCharacter ~font ~c = _strokeCharacter (f2i font) c;;

external _strokeWidth: font:int->c:int->int = "ml_glutStrokeWidth"
let strokeWidth ~font ~c = _strokeWidth (f2i font) c;;

 (* === GLUT pre-built models sub-API === *)
external wireSphere: radius:float->slices:int->stacks:int->unit = 
    "ml_glutWireSphere"
external solidSphere: radius:float->slices:int->stacks:int->unit = 
    "ml_glutSolidSphere"
external wireCone: base:float->height:float->slices:int->stacks:int->unit = 
    "ml_glutWireCone"
external solidCone: base:float->height:float->slices:int->stacks:int->unit = 
    "ml_glutSolidCone"
external wireCube: size:float->unit = 
    "ml_glutWireCube"
external solidCube: size:float->unit = 
    "ml_glutSolidCube"
external wireTorus: innerRadius:float->outerRadius:float->sides:int->rings:int
    ->unit = "ml_glutWireTorus"
external solidTorus: innerRadius:float->outerRadius:float->sides:int->rings:int
    ->unit = "ml_glutSolidTorus"
external wireDodecahedron: unit->unit = 
    "ml_glutWireDodecahedron"
external solidDodecahedron: unit->unit = 
    "ml_glutSolidDodecahedron"
external wireTeapot: size:float->unit = 
    "ml_glutWireTeapot"
external solidTeapot: size:float->unit = 
    "ml_glutSolidTeapot"
external wireOctahedron: unit->unit = 
    "ml_glutWireOctahedron"
external solidOctahedron: unit->unit = 
    "ml_glutSolidOctahedron"
external wireTetrahedron: unit->unit = 
    "ml_glutWireTetrahedron"
external solidTetrahedron: unit->unit = 
    "ml_glutSolidTetrahedron"
external wireIcosahedron: unit->unit = 
    "ml_glutWireIcosahedron"
external solidIcosahedron: unit->unit = 
    "ml_glutSolidIcosahedron"

 (* GLUT version 4 functions included in the GLUT 3.7 distribution *)
external initDisplayString: str:string->unit = "ml_glutInitDisplayString"
external warpPointer: x:int->y:int->unit = "ml_glutWarpPointer"

external _bitmapLength: font:int->str:string->int = "ml_glutBitmapLength"
let bitmapLength ~font ~str = _bitmapLength (f2i font) str;;

external _strokeLength: font:int->str:string->int = "ml_glutStrokeLength"
let strokeLength ~font ~str = _strokeLength (f2i font) str;;

external _windowStatusFunc: (int->unit)->unit = "ml_glutWindowStatusFunc"
let windowStatusFunc ~cb = 
  _windowStatusFunc  
   (fun s -> 
    cb ~state:(match s with
      | 0 -> HIDDEN 
      | 1 -> FULLY_RETAINED 
      | 2 -> PARTIALLY_RETAINED 
      | 3 -> FULLY_COVERED 
      | _ -> failwith "invalid value in glutWindowStatus ocaml callback"))
  ;;

external postWindowRedisplay: win:int->unit = 
  "ml_glutPostWindowRedisplay"

external postWindowOverlayRedisplay: win:int->unit = 
  "ml_glutPostWindowOverlayRedisplay"

external keyboardUpFunc: cb:(key:int->x:int->y:int->unit)->unit = "ml_glutKeyboardUpFunc"

external _glutSpecialUpFunc : (key:int->x:int->y:int->unit)->unit = "ml_glutSpecialUpFunc"
let specialUpFunc ~cb =
  _glutSpecialUpFunc 
      (fun ~key ~x ~y -> cb ~key:(special_of_int key) ~x ~y) ;;

external _ignoreKeyRepeat: ignore:int->unit = "ml_glutIgnoreKeyRepeat"
let ignoreKeyRepeat ~ignore = _ignoreKeyRepeat (if ignore = true then 1 else 0)

external _setKeyRepeat: mode:int->unit = "ml_glutSetKeyRepeat"
let setKeyRepeat ~mode = 
  _setKeyRepeat (match mode with
    | KEY_REPEAT_OFF -> 0
    | KEY_REPEAT_ON -> 1
    | KEY_REPEAT_DEFAULT -> 2
  );;

external joystickFunc: cb:(buttonMask:int->x:int->y:int->z:int->unit)->
  pollInterval:int->unit = "ml_glutJoystickFunc" 

external forceJoystickFunc: unit->unit = "ml_glutForceJoystickFunc"

  (* GLUT video resize sub-API. *)
external _videoResizeGet: int->int = "ml_glutVideoResizeGet"
let videoResizeGet which = 
  let i = match which with 
  | VIDEO_RESIZE_POSSIBLE -> 900
  | VIDEO_RESIZE_IN_USE -> 901
  | VIDEO_RESIZE_X_DELTA -> 902
  | VIDEO_RESIZE_Y_DELTA -> 903
  | VIDEO_RESIZE_WIDTH_DELTA -> 904
  | VIDEO_RESIZE_HEIGHT_DELTA -> 905
  | VIDEO_RESIZE_X -> 906
  | VIDEO_RESIZE_Y -> 907
  | VIDEO_RESIZE_WIDTH -> 908
  | VIDEO_RESIZE_HEIGHT -> 909
  in  _videoResizeGet i
;;

external setupVideoResizing: unit->unit = 
  "ml_glutSetupVideoResizing"
external stopVideoResizing: unit->unit = 
  "ml_glutStopVideoResizing"
external videoResize: x:int->y:int->width:int->height:int->unit = 
  "ml_glutVideoResize"
external videoPan: x:int->y:int->width:int->height:int->unit = 
  "ml_glutVideoPan"

  (* GLUT debugging sub-API. *)
external reportErrors: unit->unit = "ml_glutReportErrors"

 (* GLUT game mode sub-API *)
external gameModeString: str:string->unit = "ml_glutGameModeString"

external enterGameMode: unit->unit = "ml_glutEnterGameMode"

external leaveGameMode: unit->unit = "ml_glutLeaveGameMode"

external _gameModeGet: mode:int->int = "ml_glutGameModeGet"

let gameModeGet ~mode = 
    let imode = match mode with
    | GAME_MODE_ACTIVE -> 0
    | GAME_MODE_POSSIBLE -> 1
    | GAME_MODE_WIDTH -> 2
    | GAME_MODE_HEIGHT -> 3
    | GAME_MODE_PIXEL_DEPTH -> 4
    | GAME_MODE_REFRESH_RATE -> 5
    | GAME_MODE_DISPLAY_CHANGED -> 6 in
    _gameModeGet imode;;

  (* ocaml specific *)
let string_of_special key = match key with
  | KEY_F1 -> "KEY_F1"
  | KEY_F2 -> "KEY_F2"
  | KEY_F3 -> "KEY_F3"
  | KEY_F4 -> "KEY_F4"
  | KEY_F5 -> "KEY_F5"
  | KEY_F6 -> "KEY_F6"
  | KEY_F7 -> "KEY_F7"
  | KEY_F8 -> "KEY_F8"
  | KEY_F9 -> "KEY_F9"
  | KEY_F10 -> "KEY_F10"
  | KEY_F11 -> "KEY_F11"
  | KEY_F12 -> "KEY_F12"
  | KEY_LEFT -> "KEY_LEFT"
  | KEY_UP -> "KEY_UP"
  | KEY_RIGHT -> "KEY_RIGHT"
  | KEY_DOWN -> "KEY_DOWN"
  | KEY_PAGE_UP -> "KEY_PAGE_UP"
  | KEY_PAGE_DOWN -> "KEY_PAGE_DOWN"
  | KEY_HOME -> "KEY_HOME"
  | KEY_END -> "KEY_END"
  | KEY_INSERT -> "KEY_INSERT"

let int_of_cursor c = match c with 
  | CURSOR_RIGHT_ARROW -> 0
  | CURSOR_LEFT_ARROW -> 1
  | CURSOR_INFO -> 2
  | CURSOR_DESTROY -> 3
  | CURSOR_HELP -> 4
  | CURSOR_CYCLE -> 5
  | CURSOR_SPRAY -> 6
  | CURSOR_WAIT -> 7
  | CURSOR_TEXT -> 8
  | CURSOR_CROSSHAIR -> 9
  | CURSOR_UP_DOWN -> 10
  | CURSOR_LEFT_RIGHT -> 11
  | CURSOR_TOP_SIDE -> 12
  | CURSOR_BOTTOM_SIDE -> 13
  | CURSOR_LEFT_SIDE -> 14
  | CURSOR_RIGHT_SIDE -> 15
  | CURSOR_TOP_LEFT_CORNER -> 16
  | CURSOR_TOP_RIGHT_CORNER -> 17
  | CURSOR_BOTTOM_RIGHT_CORNER -> 18
  | CURSOR_BOTTOM_LEFT_CORNER -> 19
  | CURSOR_INHERIT -> 100
  | CURSOR_NONE -> 101
  | CURSOR_FULL_CROSSHAIR -> 102

let string_of_cursor c = match c with 
  | CURSOR_RIGHT_ARROW -> "CURSOR_RIGHT_ARROW"
  | CURSOR_LEFT_ARROW -> "CURSOR_LEFT_ARROW"
  | CURSOR_INFO -> "CURSOR_INFO"
  | CURSOR_DESTROY -> "CURSOR_DESTROY"
  | CURSOR_HELP -> "CURSOR_HELP"
  | CURSOR_CYCLE -> "CURSOR_CYCLE"
  | CURSOR_SPRAY -> "CURSOR_SPRAY"
  | CURSOR_WAIT -> "CURSOR_WAIT"
  | CURSOR_TEXT -> "CURSOR_TEXT"
  | CURSOR_CROSSHAIR -> "CURSOR_CROSSHAIR"
  | CURSOR_UP_DOWN -> "CURSOR_UP_DOWN"
  | CURSOR_LEFT_RIGHT -> "CURSOR_LEFT_RIGHT"
  | CURSOR_TOP_SIDE -> "CURSOR_TOP_SIDE"
  | CURSOR_BOTTOM_SIDE -> "CURSOR_BOTTOM_SIDE"
  | CURSOR_LEFT_SIDE -> "CURSOR_LEFT_SIDE"
  | CURSOR_RIGHT_SIDE -> "CURSOR_RIGHT_SIDE"
  | CURSOR_TOP_LEFT_CORNER -> "CURSOR_TOP_LEFT_CORNER"
  | CURSOR_TOP_RIGHT_CORNER -> "CURSOR_TOP_RIGHT_CORNER"
  | CURSOR_BOTTOM_RIGHT_CORNER -> "CURSOR_BOTTOM_RIGHT_CORNER"
  | CURSOR_BOTTOM_LEFT_CORNER -> "CURSOR_BOTTOM_LEFT_CORNER"
  | CURSOR_INHERIT -> "CURSOR_INHERIT"
  | CURSOR_NONE -> "CURSOR_NONE"
  | CURSOR_FULL_CROSSHAIR -> "CURSOR_FULL_CROSSHAIR"
  ;;

let int_of_modifier m = match m with 
  | ACTIVE_SHIFT -> 1
  | ACTIVE_CTRL -> 2          
  | ACTIVE_ALT -> 4
  ;;

(*
let int_of_modifiers ms = 
  List.fold_left (lor) 0 (List.map int_of_modifier ms);; 
*)

let string_of_button b = match b with 
  | LEFT_BUTTON -> "LEFT_BUTTON"
  | MIDDLE_BUTTON -> "MIDDLE_BUTTON"
  | RIGHT_BUTTON -> "RIGHT_BUTTON"
  | OTHER_BUTTON n -> "OTHER_BUTTON" ^ string_of_int n 
  ;;

let string_of_button_state s = match s with
  | DOWN -> "DOWN"
  | UP -> "UP"
  ;;
  
let string_of_modifier m = match m with
  | ACTIVE_SHIFT -> "ACTIVE_SHIFT"
  | ACTIVE_CTRL -> "ACTIVE_CTRL"
  | ACTIVE_ALT -> "ACTIVE_ALT"
  ;;

(* convert a list of strings to a single string *)
let string_of_strings l = 
  let rec _string_of_list l = match l with 
    | [] -> ""
    | h::t -> h^(if t=[] then "" else ", "^(_string_of_list t))
  in "[ " ^ (_string_of_list l) ^ " ]";;

let string_of_modifiers ml = 
  string_of_strings (List.map string_of_modifier ml);;

let string_of_window_status status = match status with
  | HIDDEN -> "HIDDEN"
  | FULLY_RETAINED -> "FULLY_RETAINED"
  | PARTIALLY_RETAINED -> "PARTIALLY_RETAINED"
  | FULLY_COVERED -> "FULLY_COVERED"
  ;;

let string_of_vis_state vis = match vis with 
  | NOT_VISIBLE -> "NOT_VISIBLE"
  | VISIBLE     -> "VISIBLE"
  ;;

