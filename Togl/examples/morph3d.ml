(* $Id: morph3d.ml,v 1.2 1998-01-26 03:18:42 garrigue Exp $ *)

(*-
 * morph3d.c - Shows 3D morphing objects (TK Version)
 *
 * This program was inspired on a WindowsNT(R)'s screen saver. It was written 
 * from scratch and it was not based on any other source code. 
 * 
 * Porting it to xlock (the final objective of this code since the moment I
 * decided to create it) was possible by comparing the original Mesa's gear
 * demo with it's ported version, so thanks for Danny Sung for his indirect
 * help (look at gear.c in xlock source tree). NOTE: At the moment this code
 * was sent to Brian Paul for package inclusion, the XLock Version was not
 * available. In fact, I'll wait it to appear on the next Mesa release (If you
 * are reading this, it means THIS release) to send it for xlock package 
 * inclusion). It will probably there be a GLUT version too.
 *
 * Thanks goes also to Brian Paul for making it possible and inexpensive
 * to use OpenGL at home.
 *
 * Since I'm not a native english speaker, my apologies for any gramatical
 * mistake.
 *
 * My e-mail addresses are
 *
 * vianna@cat.cbpf.br 
 *         and
 * marcelo@venus.rdc.puc-rio.br
 *
 * Marcelo F. Vianna (Feb-13-1997)
 *)

(*
This document is VERY incomplete, but tries to describe the mathematics used
in the program. At this moment it just describes how the polyhedra are 
generated. On futhurer versions, this document will be probabbly improved.

Since I'm not a native english speaker, my apologies for any gramatical
mistake.

Marcelo Fernandes Vianna 
- Undergraduate in Computer Engeneering at Catholic Pontifical University
- of Rio de Janeiro (PUC-Rio) Brasil.
- e-mail: vianna@cat.cbpf.br or marcelo@venus.rdc.puc-rio.br
- Feb-13-1997

POLYHEDRA GENERATION

For the purpose of this program it's not sufficient to know the polyhedra
vertexes coordinates. Since the morphing algorithm applies a nonlinear 
transformation over the surfaces (faces) of the polyhedron, each face has
to be divided into smaller ones. The morphing algorithm needs to transform 
each vertex of these smaller faces individually. It's a very time consoming
task.

In order to reduce calculation overload, and since all the macro faces of
the polyhedron are transformed by the same way, the generation is made by 
creating only one face of the polyhedron, morphing it and then rotating it
around the polyhedron center. 

What we need to know is the face radius of the polyhedron (the radius of 
the inscribed sphere) and the angle between the center of two adjacent 
faces using the center of the sphere as the angle's vertex.

The face radius of the regular polyhedra are known values which I decided
to not waste my time calculating. Following is a table of face radius for
the regular polyhedra with edge length = 1:

    TETRAHEDRON  : 1/(2*sqrt(2))/sqrt(3)
    CUBE	 : 1/2
    OCTAHEDRON   : 1/sqrt(6)
    DODECAHEDRON : T^2 * sqrt((T+2)/5) / 2     -> where T=(sqrt(5)+1)/2
    ICOSAHEDRON  : (3*sqrt(3)+sqrt(15))/12

I've not found any reference about the mentioned angles, so I needed to
calculate them, not a trivial task until I figured out how :)
Curiously these angles are the same for the tetrahedron and octahedron.
A way to obtain this value is inscribing the tetrahedron inside the cube
by matching their vertexes. So you'll notice that the remaining unmatched
vertexes are in the same straight line starting in the cube/tetrahedron
center and crossing the center of each tetrahedron's face. At this point
it's easy to obtain the bigger angle of the isosceles triangle formed by
the center of the cube and two opposite vertexes on the same cube face.
The edges of this triangle have the following lenghts: sqrt(2) for the base
and sqrt(3)/2 for the other two other edges. So the angle we want is:
     +-----------------------------------------------------------+
     | 2*ARCSIN(sqrt(2)/sqrt(3)) = 109.47122063449069174 degrees |
     +-----------------------------------------------------------+
For the cube this angle is obvious, but just for formality it can be
easily obtained because we also know it's isosceles edge lenghts:
sqrt(2)/2 for the base and 1/2 for the other two edges. So the angle we 
want is:
     +-----------------------------------------------------------+
     | 2*ARCSIN((sqrt(2)/2)/1)   = 90.000000000000000000 degrees |
     +-----------------------------------------------------------+
For the octahedron we use the same idea used for the tetrahedron, but now
we inscribe the cube inside the octahedron so that all cubes's vertexes
matches excatly the center of each octahedron's face. It's now clear that
this angle is the same of the thetrahedron one:
     +-----------------------------------------------------------+
     | 2*ARCSIN(sqrt(2)/sqrt(3)) = 109.47122063449069174 degrees |
     +-----------------------------------------------------------+
For the dodecahedron it's a little bit harder because it's only relationship
with the cube is useless to us. So we need to solve the problem by another
way. The concept of Face radius also exists on 2D polygons with the name
Edge radius:
  Edge Radius For Pentagon (ERp)
  ERp = (1/2)/TAN(36 degrees) * VRp = 0.6881909602355867905
  (VRp is the pentagon's vertex radio).
  Face Radius For Dodecahedron
  FRd = T^2 * sqrt((T+2)/5) / 2 = 1.1135163644116068404
Why we need ERp? Well, ERp and FRd segments forms a 90 degrees angle, 
completing this triangle, the lesser angle is a half of the angle we are 
looking for, so this angle is:
     +-----------------------------------------------------------+
     | 2*ARCTAN(ERp/FRd)	 = 63.434948822922009981 degrees |
     +-----------------------------------------------------------+
For the icosahedron we can use the same method used for dodecahedron (well
the method used for dodecahedron may be used for all regular polyhedra)
  Edge Radius For Triangle (this one is well known: 1/3 of the triangle height)
  ERt = sin(60)/3 = sqrt(3)/6 = 0.2886751345948128655
  Face Radius For Icosahedron
  FRi= (3*sqrt(3)+sqrt(15))/12 = 0.7557613140761707538
So the angle is:
     +-----------------------------------------------------------+
     | 2*ARCTAN(ERt/FRi)	 = 41.810314895778596167 degrees |
     +-----------------------------------------------------------+

*)


let scale = 0.3

let vect_mul (x1,y1,z1) (x2,y2,z2) =
  (y1 *. z2 -. z1 *. y2, z1 *. x2 -. x1 *. z2, x1 *. y2 -. y1 *. x2)

let sqr a = a *. a

(* Increasing this values produces better image quality, the price is speed. *)
(* Very low values produces erroneous/incorrect plotting *)
let tetradivisions =            23
let cubedivisions =             20
let octadivisions =             21
let dodecadivisions =           10
let icodivisions =              15

let tetraangle =                109.47122063449069174
let cubeangle =                 90.000000000000000000
let octaangle =                 109.47122063449069174
let dodecaangle =               63.434948822922009981
let icoangle =                  41.810314895778596167

let pi = acos (-1.)
let sqrt2 = sqrt 2.
let sqrt3 = sqrt 3.
let sqrt5 = sqrt 5.
let sqrt6 = sqrt 6.
let sqrt15 = sqrt 15.
let cossec36_2 = 0.8506508083520399322
let cosd x =  cos (float x /. 180. *. pi)
let sind x =  sin (float x /. 180. *. pi)
let cos72 = cosd 72
let sin72 = sind 72
let cos36 = cosd 36
let sin36 = sind 36

(*************************************************************************)

let front_shininess =   60.0
let front_specular  =   0.7, 0.7, 0.7, 1.0
let ambient         =   0.0, 0.0, 0.0, 1.0
let diffuse         =   1.0, 1.0, 1.0, 1.0
let position0       =   1.0, 1.0, 1.0, 0.0
let position1       =   -1.0,-1.0, 1.0, 0.0
let lmodel_ambient  =   0.5, 0.5, 0.5, 1.0
let lmodel_twoside  =   true

let materialRed     =   0.7, 0.0, 0.0, 1.0
let materialGreen   =   0.1, 0.5, 0.2, 1.0
let materialBlue    =   0.0, 0.0, 0.7, 1.0
let materialCyan    =   0.2, 0.5, 0.7, 1.0
let materialYellow  =   0.7, 0.7, 0.0, 1.0
let materialMagenta =   0.6, 0.2, 0.5, 1.0
let materialWhite   =   0.7, 0.7, 0.7, 1.0
let materialGray    =   0.2, 0.2, 0.2, 1.0
let all_gray = Array.create len:20 fill:materialGray

let vertex :xf :yf :zf :ampvr2 =
  let xa = xf +. 0.001 and yb = yf +. 0.001 in
  let xf2 = sqr xf and yf2 = sqr yf in
  let factor = 1. -. (xf2 +. yf2) *. ampvr2
  and factor1 = 1. -. (sqr xa +. yf2) *. ampvr2
  and factor2 = 1. -. (xf2 +. sqr yb) *. ampvr2 in
  let vertx = factor *. xf and verty = factor *. yf
  and vertz = factor *. zf in
  let neiax = factor1 *. xa -. vertx and neiay = factor1 *. yf -. verty
  and neiaz = factor1 *. zf -. vertz and neibx = factor2 *. xf -. vertx
  and neiby = factor2 *. yb -. verty and neibz = factor2 *. zf -. vertz in
  Gl.normal3 (vect_mul (neiax, neiay, neiaz) (neibx, neiby, neibz));
  Gl.vertex3 (vertx, verty, vertz)

let triangle :edge :amp :divisions :z =
  let divi = float divisions in
  let vr = edge *. sqrt3 /. 3. in
  let ampvr2 = amp /. sqr vr
  and zf = edge *. z in
  let ax = edge *. (0.5 /. divi)
  and ay = edge *. (-0.5 *. sqrt3 /. divi)
  and bx = edge *. (-0.5 /. divi) in
  for ri = 1 to divisions do
    Gl.begin_block `triangle_strip;
    for ti = 0 to ri - 1 do
      vertex :zf :ampvr2
	xf:(float (ri-ti) *. ax +. float ti *. bx)
	yf:(vr +. float (ri-ti) *. ay +. float ti *. ay);
      vertex :zf :ampvr2
	xf:(float (ri-ti-1) *. ax +. float ti *. bx)
	yf:(vr +. float (ri-ti-1) *. ay +. float ti *. ay)
    done;
    vertex xf:(float ri *. bx) yf:(vr +. float ri *. ay) :zf :ampvr2;
    Gl.end_block ()
  done

let square :edge :amp :divisions :z =
  let divi = float divisions in
  let zf = edge *. z
  and ampvr2 = amp /. sqr (edge *. sqrt2 /. 2.) in
  for yi = 0 to divisions - 1 do
    let yf = edge *. (-0.5 +. float yi /. divi) in
    let yf2 = sqr yf in
    let y = yf +. 1.0 /. divi *. edge in
    let y2 = sqr y in
    Gl.begin_block `quad_strip;
    for xi = 0 to divisions do
      let xf = edge *. (-0.5 +. float xi /. divi) in
      vertex :xf yf:y :zf :ampvr2;
      vertex :xf :yf :zf :ampvr2
    done;
    Gl.end_block ()
  done

let pentagon :edge :amp :divisions :z =
  let divi = float divisions in
  let zf = edge *. z
  and ampvr2 = amp /. sqr(edge *. cossec36_2) in
  let x =
    Array.init len:6
      fun:(fun fi -> -. cos (float fi *. 2. *. pi /. 5. +. pi /. 10.)
	             /. divi *. cossec36_2 *. edge)
  and y =
    Array.init len:6
      fun:(fun fi -> sin (float fi *. 2. *. pi /. 5. +. pi /. 10.)
	             /. divi *. cossec36_2 *. edge)
  in
  for ri = 1 to divisions do
    for fi = 0 to 4 do
      Gl.begin_block `triangle_strip;
      for ti = 0 to ri-1 do
	vertex :zf :ampvr2
	  xf:(float(ri-ti) *. x.(fi) +. float ti *. x.(fi+1))
	  yf:(float(ri-ti) *. y.(fi) +. float ti *. y.(fi+1));
	vertex :zf :ampvr2
	  xf:(float(ri-ti-1) *. x.(fi) +. float ti *. x.(fi+1))
	  yf:(float(ri-ti-1) *. y.(fi) +. float ti *. y.(fi+1))
      done;
      vertex xf:(float ri *. x.(fi+1)) yf:(float ri *. y.(fi+1)) :zf :ampvr2;
      Gl.end_block ()
    done
  done

let draw_tetra :amp :divisions :color =
  let list = Gl.gen_lists 1 in
  Gl.new_list list mode:`compile;
  triangle edge:2.0 :amp :divisions z:(0.5 /. sqrt6);
  Gl.end_list();

  Gl.material face:`both (`diffuse color.(0));
  Gl.call_list list;
  Gl.push_matrix();
  Gl.rotate angle:180.0 z:1.0;
  Gl.rotate angle:(-.tetraangle) x:1.0;
  Gl.material face:`both (`diffuse color.(1));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.push_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-180.0 +. tetraangle) x:0.5 y:(sqrt3 /. 2.);
  Gl.material face:`both (`diffuse color.(2));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-180.0 +. tetraangle) x:0.5 y:(-.sqrt3 /. 2.);
  Gl.material face:`both (`diffuse color.(3));
  Gl.call_list list;

  Gl.delete_lists from:list range:1

let draw_cube :amp :divisions :color =
  let list = Gl.gen_lists 1 in
  Gl.new_list list mode:`compile;
  square edge:2.0 :amp :divisions z:0.5;
  Gl.end_list();

  Gl.material face:`both (`diffuse color.(0));
  Gl.call_list list;
  Gl.rotate angle:cubeangle x:1.0;
  Gl.material face:`both (`diffuse color.(1));
  Gl.call_list list;
  Gl.rotate angle:cubeangle x:1.0;
  Gl.material face:`both (`diffuse color.(2));
  Gl.call_list list;
  Gl.rotate angle:cubeangle x:1.0;
  Gl.material face:`both (`diffuse color.(3));
  Gl.call_list list;
  Gl.rotate angle:cubeangle y:1.0;
  Gl.material face:`both (`diffuse color.(4));
  Gl.call_list list;
  Gl.rotate angle:(2.0 *. cubeangle) y:1.0;
  Gl.material face:`both (`diffuse color.(5));
  Gl.call_list list;

  Gl.delete_lists from:list range:1

let draw_octa :amp :divisions :color =
  let list = Gl.gen_lists 1 in
  Gl.new_list list mode:`compile;
  triangle edge:2.0 :amp :divisions z:(1.0 /. sqrt6);
  Gl.end_list();

  Gl.material face:`both (`diffuse color.(0));
  Gl.call_list list;
  Gl.push_matrix();
  Gl.rotate angle:180.0 z:1.0;
  Gl.rotate angle:(-180.0 +. octaangle) x:1.0;
  Gl.material face:`both (`diffuse color.(1));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.push_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-.octaangle) x:0.5 y:(sqrt3 /. 2.0);
  Gl.material face:`both (`diffuse color.(2));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.push_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-.octaangle) x:0.5 y:(-.sqrt3 /. 2.0);
  Gl.material face:`both (`diffuse color.(3));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.rotate angle:180.0 x:1.0;
  Gl.material face:`both (`diffuse color.(4));
  Gl.call_list list;
  Gl.push_matrix();
  Gl.rotate angle:180.0 z:1.0;
  Gl.rotate angle:(-180.0 +. octaangle) x:1.0;
  Gl.material face:`both (`diffuse color.(5));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.push_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-.octaangle) x:0.5 y:(sqrt3 /. 2.0);
  Gl.material face:`both (`diffuse color.(2));
  Gl.call_list list;
  Gl.pop_matrix();
  Gl.rotate angle:180.0 y:1.0;
  Gl.rotate angle:(-.octaangle) x:0.5 y:(-.sqrt3 /. 2.0);
  Gl.material face:`both (`diffuse color.(3));
  Gl.call_list list;

  Gl.delete_lists from:list range:1

let draw_dodeca :amp :divisions :color =
  let tau = (sqrt5 +. 1.0) /. 2.0 in
  let list = Gl.gen_lists 1 in
  Gl.new_list list mode:`compile;
  pentagon edge:2.0 :amp :divisions
    z:(sqr(tau) *. sqrt ((tau+.2.0)/.5.0) /. 2.0);
  Gl.end_list();

  let do_list (angle,x,y,i) =
    Gl.push_matrix();
    Gl.rotate :angle :x :y;
    Gl.material face:`both (`diffuse color.(i));
    Gl.call_list list;
    Gl.pop_matrix();
  in
  Gl.push_matrix ();
  Gl.material face:`both (`diffuse color.(0));
  Gl.call_list list;
  Gl.rotate angle:180.0 z:1.0;
  List.iter fun:do_list
    [ -.dodecaangle, 1.0, 0.0, 1;
      -.dodecaangle, cos72, sin72, 2;
      -.dodecaangle, cos72, -.sin72, 3;
      dodecaangle, cos36, -.sin36, 4;
      dodecaangle, cos36, sin36, 5 ];
  Gl.pop_matrix ();
  Gl.rotate angle:180.0 x:1.0;
  Gl.material face:`both (`diffuse color.(6));
  Gl.call_list list;
  Gl.rotate angle:180.0 z:1.0;
  List.iter fun:do_list
    [ -.dodecaangle, 1.0, 0.0, 7;
      -.dodecaangle, cos72, sin72, 8;
      -.dodecaangle, cos72, -.sin72, 9;
      dodecaangle, cos36, -.sin36, 10 ];
  Gl.pop_matrix ();
  do_list (dodecaangle, cos36, sin36, 11);

  Gl.delete_lists from:list range:1

(*
static void draw_ico( void )
{
  GLuint list;

  list = glGenLists( 1 );
  glNewList( list, GL_COMPILE );
  TRIANGLE(1.5,seno,edgedivisions,(3*SQRT3+SQRT15)/12);
  glEndList();

  glPushMatrix();

  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[0]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[1]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[2]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[3]);
  glCallList(list);
  glPopMatrix();
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[4]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[5]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[6]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[7]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[8]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[9]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[10]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[11]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[12]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[13]);
  glCallList(list);
  glPopMatrix();
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[14]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[15]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[16]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[17]);
  glCallList(list);
  glPushMatrix();
  glRotatef(180,0,1,0);
  glRotatef(-180+icoangle,0.5,-SQRT3/2,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[18]);
  glCallList(list);
  glPopMatrix();
  glRotatef(180,0,0,1);
  glRotatef(-icoangle,1,0,0);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialColor[19]);
  glCallList(list);

  glDeleteLists(list,1);
}
*)

class view togl as self =
  val togl = togl
  val mutable mono = false
  val mutable smooth = true
  val mutable step = 0.
  val mutable object = 1
  val mutable draw_object = fun :amp -> ()
  val mutable magnitude = 0.

  method width = Togl.width togl
  method height = Togl.height togl

  method draw =
    let ratio = float self#height /. float self#width in
    Gl.clear [`color;`depth];
    Gl.push_matrix();
    Gl.translate z:(-10.0);
    Gl.scale x:(scale *. ratio) y:scale z:scale;
    Gl.translate
      x:(2.5 *. ratio *. sin (step *. 1.11))
      y:(2.5 *. cos (step *. 1.25 *. 1.11));
    Gl.rotate angle:(step *. 100.) x:1.0;
    Gl.rotate angle:(step *. 95.) y:1.0;
    Gl.rotate angle:(step *. 90.) z:1.0;
    draw_object amp:((sin step +. 1.0/.3.0) *. (4.0/.5.0) *. magnitude);
    Gl.pop_matrix();
    Gl.flush();
    Togl.swap_buffers togl;
    step <- step +. 0.05

  method reshape =
    Gl.viewport x:0 y:0 w:self#width h:self#height;
    Gl.matrix_mode `projection;
    Gl.load_identity();
    Gl.frustum x:(-1.0, 1.0) y:(-1.0, 1.0) z:(5.0, 15.0);
    Gl.matrix_mode `modelview

  method key sym =
    begin match sym with
      "1" -> object <- 1
    | "2" -> object <- 2
    | "3" -> object <- 3
    | "4" -> object <- 4
    | "5" -> object <- 5
    | "Space" -> mono <- not mono
    | "Return" -> smooth <- not smooth
    | "Escape" -> exit 0
    | _ -> ()
    end;
    self#pinit

  method pinit =
    begin match object with
      1 ->
	draw_object <- draw_tetra
	     divisions:tetradivisions
	     color:[|materialRed;  materialGreen;
		     materialBlue; materialWhite|];
	magnitude <- 2.5
    | 2 ->
	draw_object <- draw_cube
	     divisions:cubedivisions
	     color:[|materialRed; materialGreen; materialCyan;
		     materialMagenta; materialYellow; materialBlue|];
	magnitude <- 2.0
    | 3 ->
	draw_object <- draw_octa
	     divisions:octadivisions
	     color:[|materialRed; materialGreen; materialBlue;
		     materialWhite; materialCyan; materialMagenta;
		     materialGray; materialYellow|];
	magnitude <- 2.5
    | 4 ->
      draw_object <- draw_dodeca
	   divisions:dodecadivisions
	   color:[|materialRed; materialGreen; materialCyan;
		   materialBlue; materialMagenta; materialYellow;
		   materialGreen; materialCyan; materialRed;
		   materialMagenta; materialBlue; materialYellow|];
      magnitude <- 2.0
    | _ -> ()
    end;
(*
    case 5:
      draw_object=draw_ico;
      MaterialColor[ 0]=MaterialRed;
      MaterialColor[ 1]=MaterialGreen;
      MaterialColor[ 2]=MaterialBlue;
      MaterialColor[ 3]=MaterialCyan;
      MaterialColor[ 4]=MaterialYellow;
      MaterialColor[ 5]=MaterialMagenta;
      MaterialColor[ 6]=MaterialRed;
      MaterialColor[ 7]=MaterialGreen;
      MaterialColor[ 8]=MaterialBlue;
      MaterialColor[ 9]=MaterialWhite;
      MaterialColor[10]=MaterialCyan;
      MaterialColor[11]=MaterialYellow;
      MaterialColor[12]=MaterialMagenta;
      MaterialColor[13]=MaterialRed;
      MaterialColor[14]=MaterialGreen;
      MaterialColor[15]=MaterialBlue;
      MaterialColor[16]=MaterialCyan;
      MaterialColor[17]=MaterialYellow;
      MaterialColor[18]=MaterialMagenta;
      MaterialColor[19]=MaterialGray;
      edgedivisions=icodivisions;
      Magnitude=2.5;
      break;
  if (mono) {
    int loop;
    for (loop=0; loop<20; loop++) MaterialColor[loop]=MaterialGray;
  }
*)
    Gl.shade_model (if smooth then `smooth else `flat)
end

open Tk

let main () =
  List.iter fun:print_string
    [ "Morph 3D - Shows morphing platonic polyhedra\n";
      "Author: Marcelo Fernandes Vianna (vianna@cat.cbpf.br)\n\n";
      "  [1]    - Tetrahedron\n";
      "  [2]    - Hexahedron (Cube)\n";
      "  [3]    - Octahedron\n";
      "  [4]    - Dodecahedron\n";
      "  [5]    - Icosahedron\n";
      "[SPACE]  - Toggle colored faces\n";
      "[RETURN] - Toggle smooth/flat shading\n";
      " [ESC]   - Quit\n" ];
  flush stdout;

  let top = openTk () in
  let togl = Togl.create parent:top width:640 height:480
      depth:true double:true rgba:true in
  Wm.title_set top title:"Morph 3D - Shows morphing platonic polyhedra";
  Gl.clear_depth 1.0;
  Gl.clear_color (0.0, 0.0, 0.0);
  Gl.color (1.0, 1.0, 1.0);

  Gl.clear [`color;`depth];
  Gl.flush();
  Togl.swap_buffers togl;

  Gl.light num:0 (`ambient ambient);
  Gl.light num:0 (`diffuse diffuse);
  Gl.light num:0 (`position position0);
  Gl.light num:1 (`ambient ambient);
  Gl.light num:1 (`diffuse diffuse);
  Gl.light num:1 (`position position1);
  Gl.light_model (`ambient lmodel_ambient);
  Gl.light_model (`two_side lmodel_twoside);
  List.iter fun:Gl.enable
    [`lighting;`light0;`light1;`depth_test;`normalize];

  Gl.material face:`both (`shininess front_shininess);
  Gl.material face:`both (`specular front_specular);

  Gl.hint target:`fog `fastest;
  Gl.hint target:`perspective_correction `fastest;
  Gl.hint target:`polygon_smooth `fastest;

  let view = new view togl in
  view#pinit;

  Togl.display_func togl cb:(fun () -> view#draw);
  Togl.reshape_func togl cb:(fun () -> view#reshape);
  Togl.timer_func ms:20 cb:(fun () -> view#draw);
  bind togl events:[[],`KeyPress]
    action:(`Set([`KeySymString], fun ev -> view#key ev.ev_KeySymString));
  Focus.set togl;
  pack [togl] expand:true fill:`Both;
  mainLoop ()

let _ = main ()
