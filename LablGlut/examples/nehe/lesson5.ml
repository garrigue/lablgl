(*
 * This code was created by Jeff Molofee '99 
 * If you've found this code useful, please let me know.
 *
 * Visit Jeff at http://nehe.gamedev.net/
 * 
 * Ported to O'Caml/lablglut by Jeffrey Palmer 8/02
 * For port-specific issues, comments, etc., please
 * contact jeffrey.palmer@acm.org
 *)

let rtri = ref 0.0
let rquad = ref 0.0

let init_gl width height =
    GlDraw.shade_model `smooth;
    GlClear.color (0.0, 0.0, 0.0);
    GlClear.depth 1.0;
    GlClear.clear [`color; `depth];
    Gl.enable `depth_test;
    GlFunc.depth_func `lequal;
    GlMisc.hint `perspective_correction `nicest

let draw_gl_scene () =
  GlClear.clear [`color; `depth];
  GlMat.load_identity ();

  (* Draw the pyramid *)
  GlMat.translate3 (-1.5, 0.0, -6.0);
  GlMat.rotate3 !rtri (0.0, 1.0, 0.0);
  GlDraw.begins `triangles;

  GlDraw.color   ( 1.0, 0.0, 0.0);
  GlDraw.vertex3 ( 0.0, 1.0, 0.0);
  GlDraw.color   ( 0.0, 1.0, 0.0);
  GlDraw.vertex3 (-1.0,-1.0, 1.0);
  GlDraw.color   ( 0.0, 0.0, 1.0);
  GlDraw.vertex3 ( 1.0,-1.0, 1.0);

  GlDraw.color   ( 1.0, 0.0, 0.0);               
  GlDraw.vertex3 ( 0.0, 1.0, 0.0); 
  GlDraw.color   ( 0.0, 0.0, 1.0);     
  GlDraw.vertex3 ( 1.0,-1.0, 1.0); 
  GlDraw.color   ( 0.0, 1.0, 0.0);     
  GlDraw.vertex3 ( 1.0,-1.0,-1.0);

  GlDraw.color   ( 1.0, 0.0, 0.0);                  
  GlDraw.vertex3 ( 0.0, 1.0, 0.0);       
  GlDraw.color   ( 0.0, 1.0, 0.0);           
  GlDraw.vertex3 ( 1.0,-1.0,-1.0);      
  GlDraw.color   ( 0.0, 0.0, 1.0);           
  GlDraw.vertex3 (-1.0,-1.0,-1.0);      

  GlDraw.color   ( 1.0, 0.0, 0.0);                      
  GlDraw.vertex3 ( 0.0, 1.0, 0.0);                
  GlDraw.color   ( 0.0, 0.0, 1.0);                  
  GlDraw.vertex3 (-1.0,-1.0,-1.0);            
  GlDraw.color   ( 0.0, 1.0, 0.0);              
  GlDraw.vertex3 (-1.0,-1.0, 1.0);  

  GlDraw.ends ();

  (* Draw the square *)
  GlMat.load_identity ();
  GlMat.translate3 (1.5, 0.0, -7.0);
  GlMat.rotate3 !rquad (1.0, 1.0, 1.0);
  GlDraw.begins `quads;

  GlDraw.color (0.0,1.0,0.0);                
  GlDraw.vertex3 ( 1.0, 1.0,-1.0);
  GlDraw.vertex3 (-1.0, 1.0,-1.0);
  GlDraw.vertex3 (-1.0, 1.0, 1.0);
  GlDraw.vertex3 ( 1.0, 1.0, 1.0);  
  
  GlDraw.color (1.0,0.5,0.0);                   
  GlDraw.vertex3 ( 1.0,-1.0, 1.0);
  GlDraw.vertex3 (-1.0,-1.0, 1.0);
  GlDraw.vertex3 (-1.0,-1.0,-1.0);
  GlDraw.vertex3 ( 1.0,-1.0,-1.0);  
  
  GlDraw.color (1.0,0.0,0.0);                   
  GlDraw.vertex3 ( 1.0, 1.0, 1.0);
  GlDraw.vertex3 (-1.0, 1.0, 1.0);
  GlDraw.vertex3 (-1.0,-1.0, 1.0);
  GlDraw.vertex3 ( 1.0,-1.0, 1.0);
  
  GlDraw.color (1.0,1.0,0.0);                   
  GlDraw.vertex3 ( 1.0,-1.0,-1.0); 
  GlDraw.vertex3 (-1.0,-1.0,-1.0); 
  GlDraw.vertex3 (-1.0, 1.0,-1.0); 
  GlDraw.vertex3 ( 1.0, 1.0,-1.0); 
  
  GlDraw.color (0.0,0.0,1.0);                   
  GlDraw.vertex3 (-1.0, 1.0, 1.0); 
  GlDraw.vertex3 (-1.0, 1.0,-1.0); 
  GlDraw.vertex3 (-1.0,-1.0,-1.0); 
  GlDraw.vertex3 (-1.0,-1.0, 1.0); 
  
  GlDraw.color (1.0,0.0,1.0);                   
  GlDraw.vertex3 ( 1.0, 1.0,-1.0); 
  GlDraw.vertex3 ( 1.0, 1.0, 1.0); 
  GlDraw.vertex3 ( 1.0,-1.0, 1.0); 
  GlDraw.vertex3 ( 1.0,-1.0,-1.0); 

  GlDraw.ends ();
  Glut.swapBuffers ();
  rtri := !rtri +. 0.2;
  rquad := !rquad -. 0.15

(* Handle window reshape events *)
let reshape_cb ~w ~h =
  let 
    ratio = (float_of_int w) /. (float_of_int h) 
  in
    GlDraw.viewport 0 0 w h;
    GlMat.mode `projection;
    GlMat.load_identity ();
    GluMat.perspective 45.0 ratio (0.1, 100.0);
    GlMat.mode `modelview;
    GlMat.load_identity ()

(* Handle keyboard events *)
let keyboard_cb ~key ~x ~y =
  match key with
    | 27 (* ESC *) -> exit 0
    | _ -> ()

(* Draw the scene whever idle *)
let idle_cb () =
  draw_gl_scene ()

let main () =
  let 
    width = 640 and
    height = 480
  in
    ignore (Glut.init Sys.argv);
    Glut.initDisplayMode ~alpha:true ~depth:true ~double_buffer:true ();
    Glut.initWindowSize width height;
    ignore (Glut.createWindow "O'Caml OpenGL Lesson 5");
    Glut.displayFunc draw_gl_scene;
    Glut.keyboardFunc keyboard_cb;
    Glut.reshapeFunc reshape_cb;
    Glut.idleFunc(Some idle_cb);
    init_gl width height;
    Glut.mainLoop ()

let _ = main ()
