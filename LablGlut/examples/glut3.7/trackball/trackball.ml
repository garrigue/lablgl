open Printf

type vec = { x:float; y:float; z:float }
type quat = { v:vec ; w:float } 

let as_tuple v = v.x, v.y, v.z

(*
 * This size should really be based on the distance from the center of
 * rotation to the point on the object underneath the mouse.  That
 * point would then track the mouse as closely as possible.  This is a
 * simple example  though  so that is left as an Exercise for the
 * Programmer.
 *)

let trackballsize = 0.8

(*
 * Local function prototypes (not defined in trackball.h)
 *)

let vzero = (0.0, 0.0, 0.0)

(* vector subtract *)
let (-^) a b = { 
  x=a.x-.b.x; 
  y=a.y-.b.y; 
  z=a.z-.b.z; 
  }

(* vector add *)
let (+^) a b = {
  x=a.x+.b.x; 
  y=a.y+.b.y; 
  z=a.z+.b.z; 
  }

(* cross product *)
let (^^) a b = {
  x=a.y *. b.z  -.  a.z *. b.y;
  y=a.z *. b.x  -.  a.x *. b.z;
  z=a.x *. b.y  -.  a.y *. b.x 
  }

let vlength v = sqrt (v.x *. v.x  +.  v.y *. v.y  +.  v.z *. v.z)

let vscale s v = { x=s *. v.x; y=s *. v.y; z=s *. v.z }

let vnormal v = vscale (1.0 /. (vlength v)) v

(* dot product *)
let (^.^) a b = a.x *. b.x +. a.y *. b.y +. a.z *. b.z

(*
 * Project an x y pair onto a sphere of radius r OR a hyperbolic sheet
 * if we are away from the center of the sphere.
 *)
let tb_project_to_sphere r x y =
  let d = sqrt(x*.x +. y*.y) in
  let z = 
    if (d < r *. 0.70710678118654752440) then    (* Inside sphere *)
      sqrt(r*.r -. d*.d)
    else begin           (* On hyperbola *)
      let t = r /. 1.41421356237309504880 in
      t*.t /. d
    end in
  z
;;

(*
 *  Given an axis and angle  compute quaternion.
 *)
let axis_to_quat ~axis ~phi =
  let ax = match axis with x,y,z-> {x=x; y=y; z=z} in
  let sax = vscale (sin (phi/.2.0)) (vnormal ax) in
  { v=sax; w=(cos (phi /. 2.0)) }
;;


(*
 * Ok  simulate a track-ball.  Project the points onto the virtual
 * trackball  then figure out the axis of rotation  which is the cross
 * product of P1 P2 and O P1 (O is the center of the ball  0 0 0)
 * Note:  This is a deformed trackball-- is a trackball in the center 
 * but is deformed into a hyperbolic sheet of rotation away from the
 * center.  This particular function was chosen after trying out
 * several variations.
 *
 * It is assumed that the arguments to this routine are in the range
 * (-1.0 ... 1.0)
 *)

let trackball ~p1 ~p2 =  
  match p1 with p1x, p1y -> match p2 with p2x, p2y ->
    if (p1 = p2) 
    then (* zero rotation *) { v={x=0.0; y=0.0; z=0.0}; w=1.0 }
    else begin
      (*
       * First  figure out z-coordinates for projection of P1 and P2 to
       * deformed sphere
       *)
      let pp1 = {x=p1x; y=p1y; z=(tb_project_to_sphere trackballsize p1x p1y) } in
      let pp2 = {x=p2x; y=p2y; z=(tb_project_to_sphere trackballsize p2x p2y) } in
      let ax = pp2 ^^ pp1 in (* cross product *)

      (*  Figure out how much to rotate around that axis. *)
      let d = pp1 -^ pp2 in
      let t = (vlength d) /. (2.0 *. trackballsize) in

      (* Avoid problems with out-of-control values... *)
      let clamp x a b = if x < a then a else if x > b then b else x in
      let t = clamp t (-1.0) 1.0 in

      let phi = 2.0 *. asin(t) in
      
      axis_to_quat (as_tuple ax) phi
  end
;;

(*
 * Given two rotations  e1 and e2  expressed as quaternion rotations 
 * figure out the equivalent single rotation and stuff it into dest.
 *
 * This routine also normalizes the result every RENORMCOUNT times it is
 * called  to keep error from creeping in.
 *
 * NOTE: This routine is written so that q1 or q2 may be the same
 * as dest (or each other).
 *)

let renormcount = 97

let count = ref 0

(*
 * Quaternions always obey:  a^2 + b^2 + c^2 + d^2 = 1.0
 * If they don't add up to 1.0  dividing by their magnitued will
 * renormalize them.
 *
 * Note: See the following for more information on quaternions:
 *
 * - Shoemake  K.  Animating rotation with quaternion curves  Computer
 *   Graphics 19  No 3 (Proc. SIGGRAPH'85)  245-254  1985.
 * - Pletinckx  D.  Quaternion calculus as a basic tool in computer
 *   graphics  The Visual Computer 5  2-13  1989.
 *)
let normalized_quat q = 
  let minv = 1.0 /. (sqrt((q.v ^.^ q.v) +. q.w *. q.w)) in
  { v = vscale minv q.v; w = q.w *. minv }
;;

let add_quats ~q1 ~q2 = 
  let t1 = vscale q2.w q1.v in
  let t2 = vscale q1.w q2.v in 
  let t3 = q2.v ^^ q1.v in
  let q = { v = t1 +^ t2 +^ t3;  
            w = q1.w *. q2.w -. (q1.v ^.^ q2.v) } in
  incr count;
  if (!count > renormcount) then begin
    count := 0;
    normalized_quat q;
  end else 
    q
;;

let unit_quat () = { v={x=0.0;y=0.0;z=0.0}; w=1.0 }

(*
 * Build a rotation matrix  given a quaternion rotation.
 *
 *)

(* -- need to write a test for this ... -ijt *)
let build_rotmatrix ~q = 
  GlMat.of_array 
    [|
      [| 
      1.0 -. 2.0 *. (q.v.y *. q.v.y +. q.v.z *. q.v.z);
      2.0 *. (q.v.x *. q.v.y -. q.v.z *. q.w);
      2.0 *. (q.v.z *. q.v.x +. q.v.y *. q.w);
      0.0
      |];
      [|
      2.0 *. (q.v.x *. q.v.y +. q.v.z *. q.w);
      1.0 -. 2.0 *. (q.v.z *. q.v.z +. q.v.x *. q.v.x);
      2.0 *. (q.v.y *. q.v.z -. q.v.x *. q.w);
      0.0
      |];
      [|
      2.0 *. (q.v.z *. q.v.x -. q.v.y *. q.w);
      2.0 *. (q.v.y *. q.v.z +. q.v.x *. q.w);
      1.0 -. 2.0 *. (q.v.y *. q.v.y +. q.v.x *. q.v.x);
      0.0
      |];
      [|
      0.0;
      0.0;
      0.0;
      1.0;
      |]
    |]


(*
 * (c) Copyright 1993  1994  Silicon Graphics  Inc.
 * ALL RIGHTS RESERVED
 * Permission to use  copy  modify  and distribute this software for
 * any purpose and without fee is hereby granted  provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation  and that
 * the name of Silicon Graphics  Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific 
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND  EXPRESS  IMPLIED OR OTHERWISE 
 * INCLUDING WITHOUT LIMITATION  ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS  INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT 
 * SPECIAL  INCIDENTAL  INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND  OR ANY DAMAGES WHATSOEVER  INCLUDING WITHOUT LIMITATION 
 * LOSS OF PROFIT  LOSS OF USE  SAVINGS OR REVENUE  OR THE CLAIMS OF
 * THIRD PARTIES  WHETHER OR NOT SILICON GRAPHICS  INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS  HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY  ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION  USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use  duplication  or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics 
 * Inc.  2011 N.  Shoreline Blvd.  Mountain View  CA 94039-7311.
 *
 * OpenGL(TM) is a trademark of Silicon Graphics  Inc.
 *)
(*
 * Trackball code:
 *
 * Implementation of a virtual trackball.
 * Implemented by Gavin Bell  lots of ideas from Thant Tessman and
 *   the August '88 issue of Siggraph's "Computer Graphics " pp. 121-129.
 *
 * Vector manip code:
 *
 * Original code from:
 * David M. Ciemiewicz  Mark Grossman  Henry Moreton  and Paul Haeberli
 *
 * Much mucking with by:
 * Gavin Bell
 *)

(* Ported to lablglut by Issac Trotts on Sun Aug 11 2002. *)

