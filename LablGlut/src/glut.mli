(* glut.mli is deprecated.  Please use glutcaml.mli instead. -ijt *)

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

(* display mode bit masks *)
val rgb:int
val rgba:int
val index:int
val single:int
val double:int
val accum:int
val alpha:int
val depth:int
val stencil:int
val multisample:int
val stereo:int
val luminance:int

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

(* key modifier bit masks *)
val active_shift:int
val active_ctrl:int
val active_alt:int

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
  | CURSOR_INHERIT                (* inherit cursor from parent window *)
  | CURSOR_NONE               (* blank cursor *)
  | CURSOR_FULL_CROSSHAIR   (* full-screen crosshair (if available) *)

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

    (* GLUT initialization sub-API. *)
val init: argv:(string array)->string array (* returns new argv *)
val initDisplayMode: (* The last argument must be () *)
    ?double_buffer:bool->
    ?index:bool->
    ?accum:bool->
    ?alpha:bool->
    ?depth:bool->
    ?stencil:bool->
    ?multisample:bool->
    ?stereo:bool->
    ?luminance:bool->
    unit->
    unit
val initWindowPosition: x:int->y:int->unit
val initWindowSize: w:int->h:int->unit
val mainLoop: unit->unit

    (* GLUT window sub-API. *)
val createWindow: title:string->int (* returns window id *)
val postRedisplay: unit->unit
val swapBuffers: unit->unit
val createSubWindow: win:int->x:int->y:int->w:int->h:int->int
val destroyWindow: win:int->unit
val getWindow: unit->int
val setWindow: win:int->unit  
val setWindowTitle: title:string->unit
val setIconTitle: title:string->unit
val positionWindow: x:int->y:int->unit
val reshapeWindow: w:int->h:int->unit
val popWindow: unit->unit
val pushWindow: unit->unit
val iconifyWindow: unit->unit
val showWindow: unit->unit
val hideWindow: unit->unit
val fullScreen: unit->unit
val setCursor: cursor_t->unit

    (* GLUT overlay sub-API. *)
val establishOverlay: unit->unit
val removeOverlay: unit->unit
val useLayer: layer_t->unit
val postOverlayRedisplay: unit->unit
val showOverlay: unit->unit
val hideOverlay: unit->unit

    (* GLUT menu sub-API. *)
val createMenu: cb:(value:int->unit)->int
val destroyMenu: menu:int->unit
val getMenu: unit->int
val setMenu: menu:int->unit
val addMenuEntry: label:string->value:int->unit
val addSubMenu: label:string->submenu:int->unit
val changeToMenuEntry: item:int->label:string->value:int->unit
val changeToSubMenu: item:int->label:string->submenu:int->unit
val removeMenuItem: item:int->unit
val attachMenu: button:button_t->unit
val detachMenu: button:button_t->unit

    (* GLUT window callback sub-API. *)
val displayFunc: cb:(unit->unit)->unit
val reshapeFunc: cb:(w:int->h:int->unit)->unit
val keyboardFunc: cb:(key:int->x:int->y:int->unit)->unit
val mouseFunc: cb:(button:button_t->state:mouse_button_state_t->
  x:int->y:int->unit)->unit
val motionFunc: cb:(x:int->y:int->unit)->unit 
val passiveMotionFunc: cb:(x:int->y:int->unit)->unit 
val entryFunc: cb:(state:entry_exit_state_t->unit)->unit 
val visibilityFunc: cb:(state:visibility_state_t->unit)->unit
val idleFunc: cb:((unit->unit) option)->unit
val timerFunc: ms:int->cb:(value:int->unit)->value:int->unit
val menuStateFunc: cb:(status:menu_state_t->unit)->unit
val specialFunc: cb:(key:special_key_t->x:int->y:int->unit)->unit
val spaceballMotionFunc: cb:(x:int->y:int->z:int->unit)->unit
val spaceballRotateFunc: cb:(x:int->y:int->z:int->unit)->unit
val spaceballButtonFunc: cb:(button:int->state:int->unit)->unit
val buttonBoxFunc: cb:(button:int->state:int->unit)->unit
val dialsFunc: cb:(dial:int->value:int->unit)->unit
val tabletMotionFunc: cb:(x:int->y:int->unit)->unit
val tabletButtonFunc: cb:(button:int->state:int->x:int->y:int->unit)->unit
val menuStatusFunc: cb:(status:menu_state_t->x:int->y:int->unit)->unit
val overlayDisplayFunc: cb:(unit->unit)->unit

    (* GLUT color index sub-API. *)
val setColor: cell:int->red:float->green:float->blue:float->unit
val getColor: index:int->component:int->float
val copyColormap: win:int->unit

    (* GLUT state retrieval sub-API. *)
val get: gtype:glut_get_t->int
val getBool: gtype:glut_get_bool_t->bool 
val deviceGet: dgtype:device_get_t->int

    (* GLUT extension support sub-API *)
val extensionSupported: name:string->bool
val getModifiers: unit->int 
val layerGetTransparentIndex: unit->int 
val layerGetInUse: unit->layer_t
val layerGet: lgtype:layerget_t->bool 

    (* GLUT font sub-API *)
val bitmapCharacter: font:font_t->c:int->unit
val bitmapWidth: font:font_t->c:int->int
val strokeCharacter: font:font_t->c:int->unit
val strokeWidth: font:font_t->c:int->int

    (* GLUT pre-built models sub-API *)
val wireSphere: radius:float->slices:int->stacks:int->unit
val solidSphere: radius:float->slices:int->stacks:int->unit
val wireCone: base:float->height:float->slices:int->stacks:int->unit
val solidCone: base:float->height:float->slices:int->stacks:int->unit
val wireCube: size:float->unit
val solidCube: size:float->unit
val wireTorus: innerRadius:float->outerRadius:float->sides:int->rings:int->unit
val solidTorus: innerRadius:float->outerRadius:float->sides:int->rings:int->unit
val wireDodecahedron: unit->unit
val solidDodecahedron: unit->unit
val wireTeapot: size:float->unit
val solidTeapot: size:float->unit
val wireOctahedron: unit->unit
val solidOctahedron: unit->unit
val wireTetrahedron: unit->unit
val solidTetrahedron: unit->unit
val wireIcosahedron: unit->unit
val solidIcosahedron: unit->unit

    (* GLUT game mode sub-API *)
val gameModeString: str:string->unit
val enterGameMode: unit->unit
val leaveGameMode: unit->unit
val gameModeGet: mode:game_mode_t->int

    (* GLUT version 4 functions included in the GLUT 3.7 distribution *)
val initDisplayString: str:string->unit
val warpPointer: x:int->y:int->unit
val bitmapLength: font:font_t->str:string->int
val strokeLength: font:font_t->str:string->int
val windowStatusFunc: cb:(state:window_status_t->unit)->unit
val postWindowRedisplay: win:int->unit
val postWindowOverlayRedisplay: win:int->unit 
val keyboardUpFunc: cb:(key:int->x:int->y:int->unit)->unit
val specialUpFunc: cb:(key:special_key_t->x:int->y:int->unit)->unit
val ignoreKeyRepeat: ignore:bool->unit
val setKeyRepeat: mode:key_repeat_t->unit
val joystickFunc: cb:(buttonMask:int->x:int->y:int->z:int->unit)->
  pollInterval:int->unit
val forceJoystickFunc: unit->unit

  (* GLUT video resize sub-API. *)
val videoResizeGet: video_resize_t->int
val setupVideoResizing: unit->unit
val stopVideoResizing: unit->unit
val videoResize: x:int->y:int->width:int->height:int->unit
val videoPan: x:int->y:int->width:int->height:int->unit

  (* GLUT debugging sub-API. *)
val reportErrors: unit->unit

  (* ocaml-specific *)
val string_of_button: button_t->string
val string_of_button_state: mouse_button_state_t->string
val string_of_special: special_key_t->string
val string_of_window_status: window_status_t->string
val string_of_vis_state: visibility_state_t->string
val string_of_cursor: cursor_t->string
val int_of_cursor: cursor_t->int

