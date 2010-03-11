(* Simple Demo for GLSL *)
(* This demo comes from this tutorial: *)
(* http://www.lighthouse3d.com/opengl/glsl/ *)
(* The tutorial and this demo was made by António Ramires Fernandes. *)
(* No restrictions apply to the use of this program. *)
(* Converted from C to OCaml by Florent Monnier. *)

let changeSize ~w ~h =
  (* Prevent a divide by zero, when window is too short
     (you cant make a window of zero width). *)
  let h =
    if h = 0
    then 1
    else h
  in

  let ratio = 1.0 *. float w /. float h in

  (* Reset the coordinate system before modifying *)
  GlMat.mode `projection;
  GlMat.load_identity();
  
  (* Set the viewport to be the entire window *)
  GlDraw.viewport 0 0 w h;

  (* Set the correct perspective. *)
  GluMat.perspective 45.0 ratio (1.0, 1000.0);
  GlMat.mode `modelview;
;;


let renderScene() =
  GlClear.clear [`color; `depth];

  GlMat.load_identity();
  GluMat.look_at
      (0.0, 0.0, 5.0)
      (0.0, 0.0, -1.0)
      (0.0, 1.0, 0.0);

  let lpos = (1.0, 0.5, 1.0, 0.0) in
  GlLight.light 0 (`position lpos);
  Glut.solidTeapot 1.0;

  Glut.swapBuffers();
;;


let processNormalKeys ~key ~x ~y =
  if key = 27 then exit 0;
;;


let toon_frag = "
// simple toon fragment shader
varying vec3 normal, lightDir;

vec4 toonify(in float intensity)
{
    vec4 color;

    if (intensity > 0.98)
        color = vec4(0.9,0.9,0.9,1.0);
    else if (intensity > 0.5)
        color = vec4(0.4,0.4,0.8,1.0);
    else if (intensity > 0.25)
        color = vec4(0.3,0.3,0.5,1.0);
    else
        color = vec4(0.1,0.1,0.1,1.0);

    return(color);
}

void main()
{
    float intensity;
    vec3 norm;

    norm = normalize(normal);
    intensity = max(dot(lightDir,norm),0.0);

    gl_FragColor = toonify(intensity);
    // or use this line to get a classic lighting:
    //gl_FragColor = intensity * vec4(0.9,0.2,0.0,1.0);
}
"

let toon_vert = "
// simple toon vertex shader
varying vec3 normal, lightDir;

void main()
{
    lightDir = normalize(vec3(gl_LightSource[0].position));
    normal = normalize(gl_NormalMatrix * gl_Normal);

    gl_Position = ftransform();
}
"


let setShaders() =
  let v = GlShader.create `vertex_shader
  and f = GlShader.create `fragment_shader in

  GlShader.source v toon_vert;
  GlShader.source f toon_frag;

  GlShader.compile v;
  GlShader.compile f;

  let p = GlShader.create_program() in
  GlShader.attach p f;
  GlShader.attach p v;

  GlShader.link_program p;
  GlShader.use_program p;
;;


(* main *)
let () =
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode
      ~double_buffer:true
      ~depth:true ();
  Glut.initWindowPosition 100 100;
  Glut.initWindowSize 320 320;
  ignore(Glut.createWindow "simple GLSL demo");

  Glut.displayFunc renderScene;
  Glut.reshapeFunc changeSize;
  Glut.keyboardFunc processNormalKeys;
  Glut.idleFunc (Some renderScene);

  Gl.enable `depth_test;
  GlClear.color (1.0, 1.0, 1.0);

  setShaders();

  Glut.mainLoop();
;;

