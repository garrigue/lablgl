/* $Id: ml_glu.c,v 1.17 2000-12-20 03:56:21 garrigue Exp $ */

#include <GL/gl.h>
#include <GL/glu.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include "gl_tags.h"
#include "glu_tags.h"
#include "ml_gl.h"

#ifndef GLU_VERSION_1_2
#define GLU_TESS_WINDING_RULE
#define GLU_TESS_WINDING_ODD
#define GLU_TESS_WINDING_NONZERO
#define GLU_TESS_WINDING_POSITIVE
#define GLU_TESS_WINDING_NEGATIVE
#define GLU_TESS_WINDING_ABS_GEQ_TWO
#define GLU_TESS_BOUNDARY_ONLY
#define GLU_TESS_TOLERANCE
#endif

static GLenum GLUenum_val(value tag)
{
    switch(tag)
    {
#include "glu_tags.c"
    }
    ml_raise_gl ("Unknown GLU tag");
}

/* Does not register the structure with Caml !
static value Val_addr (void *addr)
{
    value wrapper;
    if (!addr) ml_raise_gl ("Bad address");
    wrapper = alloc(1,No_scan_tag);
    Field(wrapper,0) = (value) addr;
    return wrapper;
}
*/

#define Nurb_val(struc) ((GLUnurbsObj *) Field(struc,1))
#define Quad_val(struc) ((GLUquadricObj *) Field(struc,1))
#define Tess_val(struc) ((GLUtriangulatorObj *) Field(struc,1))

#define Store_addr(struc, addr) Field(struc,1) = (value) addr


#define ML_final(cname) \
static void ml_##cname (value struc) \
{ cname ((GLvoid *) Field(struc,1)); }

ML_final (gluDeleteNurbsRenderer)
ML_final (gluDeleteQuadric)
ML_final (gluDeleteTess)

/* Called from ML */

ML_1 (gluBeginCurve, Nurb_val)
ML_1 (gluBeginPolygon, Tess_val)
ML_1 (gluBeginSurface, Nurb_val)
ML_1 (gluBeginTrim, Nurb_val)

value ml_gluBuild1DMipmaps (value internal, value width,
			    value format, value data)
{
    GLenum error;

    error = gluBuild1DMipmaps (GL_TEXTURE_1D, GLenum_val(internal),
			       Int_val(width), GLenum_val(format),
			       Type_raw(data), Void_raw(data));
    if (error) ml_raise_gl((char*)gluErrorString(error));
    return Val_unit;
}

value ml_gluBuild2DMipmaps (value internal, value width, value height,
			    value format, value data)
{
    GLint error;

    error = gluBuild2DMipmaps (GL_TEXTURE_2D, GLenum_val(internal),
			       Int_val(width), Int_val(height),
			       GLenum_val(format),
			       Type_raw(data), Void_raw(data));
    if (error) ml_raise_gl((char*)gluErrorString(error));
    return Val_unit;
}

ML_6 (gluCylinder, Quad_val, Double_val, Double_val, Double_val,
      Int_val, Int_val)
ML_bc6 (ml_gluCylinder)

ML_5 (gluDisk, Quad_val, Double_val, Double_val, Int_val, Int_val)

ML_1 (gluEndCurve, Nurb_val)
ML_1 (gluEndPolygon, Tess_val)
ML_1 (gluEndSurface, Nurb_val)
ML_1 (gluEndTrim, Nurb_val)

ML_1_ (gluGetString, GLUenum_val, copy_string)

ML_4 (gluLoadSamplingMatrices, Nurb_val, Float_raw, Float_raw, Int_raw)
ML_3 (gluLookAt, Triple(arg1,Double_val,Double_val,Double_val),
      Triple(arg2,Double_val,Double_val,Double_val),
      Triple(arg3,Double_val,Double_val,Double_val))

value ml_gluNewNurbsRenderer (void)
{
    value struc = alloc_final (2, ml_gluDeleteNurbsRenderer, 1, 32);
    Store_addr(struc, gluNewNurbsRenderer());
    return struc;
}

value ml_gluNewQuadric (void)
{
    value struc = alloc_final (2, ml_gluDeleteQuadric, 1, 32);
    Store_addr(struc, gluNewQuadric());
    return struc;
}

value ml_gluNewTess (void)
{
    value struc = alloc_final (2, ml_gluDeleteTess, 1, 32);
    Store_addr(struc, gluNewTess());
    return struc;
}

ML_2 (gluNextContour, Tess_val, GLUenum_val)

#define Fsize_raw(raw) (Int_val(Size_raw(raw))/sizeof(GLfloat))

value ml_gluNurbsCurve (value nurb, value knots, value control,
			value order, value type)
{
    GLenum targ;
    int ustride;

    switch (type) {
    case MLTAG_vertex_3:
	targ = GL_MAP1_VERTEX_3; ustride = 3; break;
    case MLTAG_vertex_4:
	targ = GL_MAP1_VERTEX_4; ustride = 4; break;
    case MLTAG_index:
	targ = GL_MAP1_INDEX; ustride = 1; break;
    case MLTAG_color_4:
	targ = GL_MAP1_COLOR_4; ustride = 4; break;
    case MLTAG_normal:
	targ = GL_MAP1_NORMAL; ustride = 3; break;
    case MLTAG_texture_coord_1:
	targ = GL_MAP1_TEXTURE_COORD_1; ustride = 1; break;
    case MLTAG_texture_coord_2:
	targ = GL_MAP1_TEXTURE_COORD_2; ustride = 2; break;
    case MLTAG_texture_coord_3:
	targ = GL_MAP1_TEXTURE_COORD_3; ustride = 3; break;
    case MLTAG_texture_coord_4:
	targ = GL_MAP1_TEXTURE_COORD_4; ustride = 4; break;
    case MLTAG_trim_2:
	targ = GLU_MAP1_TRIM_2; ustride = 2; break;
    case MLTAG_trim_3:
	targ = GLU_MAP1_TRIM_3; ustride = 3; break;
    }
    gluNurbsCurve (Nurb_val(nurb), Fsize_raw(knots), Float_raw(knots),
		   ustride, Float_raw(control), Int_val(order), targ);
    return Val_unit;
}

value ml_gluNurbsProperty (value nurb, value prop)
{
    GLfloat val;
    GLenum property = GLUenum_val (Field(prop,0));

    switch (property) {
    case GLU_SAMPLING_METHOD:
    case GLU_DISPLAY_MODE:
	val = GLUenum_val (Field(prop,1));
	break;
    case GLU_PARAMETRIC_TOLERANCE:
	val = Float_val (Field(prop,1));
	break;
    default:
	val = Int_val (Field(prop,1));
	break;
    }
    gluNurbsProperty (Nurb_val(nurb), property, val);
    return Val_unit;
}

value ml_gluNurbsSurface (value nurb, value sKnots, value tKnots,
			  value tStride, value control, value sOrder,
			  value tOrder, value tag)
{
    GLenum type;
    GLint sStride;

    switch (tag) {
    case MLTAG_vertex_3:
	type = GL_MAP2_VERTEX_3; sStride = 3; break;
    case MLTAG_vertex_4:
	type = GL_MAP2_VERTEX_4; sStride = 4; break;
    case MLTAG_index:
	type = GL_MAP2_INDEX; sStride = 1; break;
    case MLTAG_color_4:
	type = GL_MAP2_COLOR_4; sStride = 4; break;
    case MLTAG_normal:
	type = GL_MAP2_NORMAL; sStride = 3; break;
    case MLTAG_texture_coord_1:
	type = GL_MAP2_TEXTURE_COORD_1; sStride = 1; break;
    case MLTAG_texture_coord_2:
	type = GL_MAP2_TEXTURE_COORD_2; sStride = 2; break;
    case MLTAG_texture_coord_3:
	type = GL_MAP2_TEXTURE_COORD_3; sStride = 3; break;
    case MLTAG_texture_coord_4:
	type = GL_MAP2_TEXTURE_COORD_4; sStride = 4; break;
    }
    gluNurbsSurface (Nurb_val(nurb), Fsize_raw(sKnots), Float_raw(sKnots),
		     Fsize_raw(tKnots), Float_raw(tKnots), sStride,
		     Int_val(tStride), Float_raw(control),
		     Int_val(sOrder), Int_val(tOrder), type);
    return Val_unit;
}

ML_bc8 (ml_gluNurbsSurface)

ML_4 (gluOrtho2D, Double_val, Double_val, Double_val, Double_val)

ML_7 (gluPartialDisk, Quad_val, Double_val, Double_val, Int_val, Int_val,
      Double_val, Double_val)
ML_bc7 (ml_gluPartialDisk)
ML_4 (gluPerspective, Double_val, Double_val, Double_val, Double_val)

value ml_gluPickMatrix (value x, value y, value delX, value delY)
{
    GLint viewport[4];

    glGetIntegerv (GL_VIEWPORT, viewport);
    gluPickMatrix (Double_val(x), Double_val(y), Double_val(delX),
		   Double_val(delY), viewport);
    return Val_unit;
}

value ml_gluProject (value object)
{
    CAMLparam0();
    GLdouble model[16];
    GLdouble proj[16];
    GLint viewport[4];
    GLdouble winX, winY, winZ;
    CAMLlocal3(win0, win1, win2);
    value win;

    glGetDoublev (GL_MODELVIEW_MATRIX, model);
    glGetDoublev (GL_PROJECTION_MATRIX, proj);
    glGetIntegerv (GL_VIEWPORT, viewport);
    gluProject (Double_val(Field(object,0)), Double_val(Field(object,1)),
		Double_val(Field(object,2)), model, proj, viewport,
		&winX, &winY, &winZ);
    win0 = copy_double(winX);
    win1 = copy_double(winY);
    win2 = copy_double(winZ);
    win = alloc_small(3, 0);
    Field(win,0) = win0;
    Field(win,1) = win1;
    Field(win,2) = win2;
    CAMLreturn(win);
}

value ml_gluPwlCurve (value nurbs, value count, value data, value tag)
{
    GLenum type;
    GLint stride;

    switch (tag) {
    case MLTAG_trim_2:
	type = GLU_MAP1_TRIM_2; stride = 2; break;
    case MLTAG_trim_3:
	type = GLU_MAP1_TRIM_3; stride = 3; break;
    }
    gluPwlCurve (Nurb_val(nurbs), Int_val(count), Float_raw(data),
		 stride, type);
    return Val_unit;
}

ML_2 (gluQuadricDrawStyle, Quad_val, GLUenum_val)
ML_2 (gluQuadricNormals, Quad_val, GLUenum_val)
ML_2 (gluQuadricOrientation, Quad_val, GLUenum_val)
ML_2 (gluQuadricTexture, Quad_val, Int_val)

ML_7 (gluScaleImage, GLenum_val, Int_val, Int_val,
      Split(arg4,Type_raw,Void_raw), Int_val, Int_val,
      Split(arg7,Type_raw,Void_raw))
ML_bc7 (ml_gluScaleImage)
ML_4 (gluSphere, Quad_val, Double_val, Int_val, Int_val)

#define Opt_val(opt) (opt == Val_int(0) ? NULL : (void *) Field(opt,0)) 

#ifdef GLU_VERSION_1_2
ML_1 (gluTessBeginContour, Tess_val)
ML_1 (gluTessEndContour, Tess_val)
ML_2 (gluTessBeginPolygon, Tess_val, Opt_val)
ML_1 (gluTessEndPolygon, Tess_val)
ML_4 (gluTessNormal, Tess_val, Double_val, Double_val, Double_val)

value ml_gluTessProperty (value tess, value prop)
{
    GLenum which = GLUenum_val (Field(prop,0));
    GLdouble data;

    switch (which) {
    case GLU_TESS_WINDING_RULE: data = GLUenum_val (Field(prop,1)); break;
    case GLU_TESS_BOUNDARY_ONLY: data = Int_val (Field(prop,1)); break;
    case GLU_TESS_TOLERANCE: data = Double_val (Field(prop,1)); break;
    }
    gluTessProperty (Tess_val(tess), which, data);
    return Val_unit;
}
#else
#define ML_fail(cname) \
value ml_##cname (value any) \
{ ml_raise_gl ("Function not available"); }
ML_fail (gluTessBeginContour)
ML_fail (gluTessEndContour)
ML_fail (gluTessBeginPolygon)
ML_fail (gluTessEndPolygon)
ML_fail (gluTessNormal)
ML_fail (gluTessProperty)
#endif

ML_3 (gluTessVertex, Tess_val, Double_raw, Opt_val)

value ml_gluUnProject (value win)
{
    CAMLparam0();
    GLdouble model[16];
    GLdouble proj[16];
    GLint viewport[4];
    GLdouble objX, objY, objZ;
    GLint ok;
    CAMLlocal3(obj0,obj1,obj2);
    value obj;

    glGetDoublev (GL_MODELVIEW_MATRIX, model);
    glGetDoublev (GL_PROJECTION_MATRIX, proj);
    glGetIntegerv (GL_VIEWPORT, viewport);
    ok = gluUnProject (Double_val(Field(win,0)), Double_val(Field(win,1)),
		       Double_val(Field(win,2)), model, proj, viewport,
		       &objX, &objY, &objZ);
    if (!ok) ml_raise_gl ("Glu.unproject : point out of window");
    obj0 = copy_double(objX);
    obj1 = copy_double(objY);
    obj2 = copy_double(objZ);
    obj = alloc_small (3, 0);
    Field(obj,0) = obj0;
    Field(obj,1) = obj1;
    Field(obj,2) = obj2;
    CAMLreturn(obj);
}
