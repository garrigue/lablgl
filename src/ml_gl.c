/* $Id: ml_gl.c,v 1.11 1998-01-15 08:34:40 garrigue Exp $ */

#include <GL/gl.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "gl_tags.h"
#include "ml_gl.h"

extern void invalid_argument (char *) Noreturn;
extern void raise_with_string (value tag, char * msg) Noreturn;

void ml_raise_gl(char *errmsg)
{
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
      gl_exn = caml_named_value("glerror");
  raise_with_string(*gl_exn, errmsg);
}

ML_double4(glClearColor)
ML_double4(glColor4d)

value ml_glClear(value bit_list)  /* ML */
{
    GLbitfield accu = 0;

    while (bit_list != Val_int(0)) {
	switch (Field (bit_list, 0)) {
	case MLTAG_color:
	    accu |= GL_COLOR_BUFFER_BIT; break;
	case MLTAG_depth:
	    accu |= GL_DEPTH_BUFFER_BIT; break;
	case MLTAG_accum:
	    accu |= GL_ACCUM_BUFFER_BIT; break;
	case MLTAG_stencil:
	    accu |= GL_STENCIL_BUFFER_BIT; break;
	}
	bit_list = Field (bit_list, 1);
    }
    glClear (accu);
    return Val_unit;
}

ML_void(glFlush)
ML_void(glFinish)

value ml_glRect(value p1, value p2)  /* ML */
{
    glRectd (Double_val (Field (p1, 0)),
	     Double_val (Field (p1, 1)),
	     Double_val (Field (p2, 0)),
	     Double_val (Field (p2, 1)));
    return Val_unit;
}

value ml_glVertex(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glVertex2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glVertex3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glVertex4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}

value ml_glRasterPos(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glRasterPos2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glRasterPos3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glRasterPos4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}

GLenum GLenum_val(value tag)
{
    switch(tag)
    {
#include "gl_tags.c"
    }
    ml_raise_gl("Unknown tag");
}

ML_GLenum(glBegin)
ML_void(glEnd)

ML_float(glPointSize)
ML_float(glLineWidth)

value ml_glLineStipple(value factor, value pattern)  /* ML */
{
    glLineStipple(Int_val(factor), Int_val(pattern));
    return Val_unit;
}

value ml_glPolygonMode(value face, value mode)  /* ML */
{
    glPolygonMode(GLenum_val(face), GLenum_val(mode));
    return Val_unit;
}

ML_GLenum(glFrontFace)
ML_GLenum(glCullFace)

ML_string(glPolygonStipple)

ML_int(glEdgeFlag)
ML_double3(glNormal3d)

ML_GLenum(glMatrixMode)

ML_void(glLoadIdentity)

value ml_glLoadMatrix(value m)  /* ML */
{
    GLdouble matrix[16];
    int i, j;

    for (i = 0; i < 4; i++)
	for (j = 0; j < 4; j++)
	    matrix[i*4+j] = Double_val (Field (Field (m, i), j));
    glLoadMatrixd (matrix);
    return Val_unit;
}

value ml_glMultMatrix(value m)  /* ML */
{
    GLdouble matrix[16];
    int i, j;

    for (i = 0; i < 4; i++)
	for (j = 0; j < 4; j++)
	    matrix[i*4+j] = Double_val (Field (Field (m, i), j));
    glMultMatrixd (matrix);
    return Val_unit;
}

ML_double3(glTranslated)
ML_double4(glRotated)
ML_double3(glScaled)

ML_double6(glFrustum)

ML_double6(glOrtho)

ML_int4(glViewport)
ML_double2(glDepthRange)

ML_void(glPushMatrix)
ML_void(glPopMatrix)

value ml_glClipPlane(value plane, value equation)  /* ML */
{
    double eq[4];
    int i;

    for (i = 0; i < 4; i++)
	eq[i] = Double_val (Field(equation,i));
    glClipPlane (GL_CLIP_PLANE0 + Int_val(plane), eq);
    return Val_unit;
}

ML_GLenum(glEnable)
ML_GLenum(glDisable)

ML_GLenum(glShadeModel)

value ml_glLight (value n, value param)  /* ML */
{
    float params[4];
    int i;

    if (Int_val(n) >= GL_MAX_LIGHTS) invalid_argument ("Gl.light");
    switch (Field(param,0))
    {
    case MLTAG_ambient:
    case MLTAG_diffuse:
    case MLTAG_specular:
    case MLTAG_position:
    case MLTAG_spot_direction:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    default:
	params[0] = Float_val (Field(param, 1));
    }
    glLightfv (GL_LIGHT0 + Int_val(n), GLenum_val(Field(param,0)), params);
    return Val_unit;
}

value ml_glLightModel (value param)  /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_ambient:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param,1),i));
	glLightModelfv (GL_LIGHT_MODEL_AMBIENT, params);
	break;
    case MLTAG_local_viewer:
	glLightModelf (GL_LIGHT_MODEL_LOCAL_VIEWER,
		       Float_val(Field(param,1)));
	break;
    case MLTAG_two_side:
	glLightModelf (GL_LIGHT_MODEL_TWO_SIDE,
		       Float_val(Field(param,1)));
	break;
    }
    return Val_unit;
}

value ml_glMaterial (value face, value param)  /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_shininess:
	params[0] = Float_val (Field(param, 1));
	break;
    case MLTAG_color_indexes:
	for (i = 0; i < 3; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    default:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    }
    glMaterialfv (GLenum_val(face), GLenum_val(Field(param,0)), params);
    return Val_unit;
}

ML_GLenum(glDepthFunc)
ML_int(glDepthMask)

ML_GLenum2(glBlendFunc)

value ml_glFog (value param) /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_mode:
	glFogi(GL_FOG_MODE, GLenum_val(Field(param,1)));
	break;
    case MLTAG_density:
	glFogf(GL_FOG_DENSITY, Float_val(Field(param,1)));
	break;
    case MLTAG_start:
	glFogf(GL_FOG_START, Float_val(Field(param,1)));
	break;
    case MLTAG_End:
	glFogf(GL_FOG_END, Float_val(Field(param,1)));
	break;
    case MLTAG_index:
	glFogf(GL_FOG_INDEX, Float_val(Field(param,1)));
	break;
    case MLTAG_color:
	for (i = 0; i < 4; i++) params[i] = Field(Field(param,1),i);
	glFogfv(GL_FOG_COLOR, params);
	break;
    }
    return Val_unit;
}


ML_int_int (glIsList)
ML_int2 (glDeleteLists)
ML_int_int (glGenLists)

value ml_glNewList (value glist, value mode)  /* ML */
{
    glNewList (Int_val (glist), GLenum_val (mode));
    return Val_unit;
}

ML_void (glEndList)
ML_int (glCallList)
ML_int (glListBase)

extern mlsize_t string_length (value);

value ml_glCallLists (value indexes)  /* ML */
{
    int len,i;
    int * table;

    switch (Field(indexes,0)) {
    case MLTAG_byte:
	glCallLists (string_length(Field(indexes,1)),
		     GL_UNSIGNED_BYTE,
		     String_val(Field(indexes,1)));
	break;
    case MLTAG_int:
	len = Wosize_val (indexes);
	table = calloc (len, sizeof (GLint));
	for (i = 0; i < len; i++) table[i] = Int_val (Field(indexes,i));
	glCallLists (len, GL_INT, table);
	free (table);
	break;
    }
    return Val_unit;
}

ML_GLenum_float_ (glAccum)
ML_GLenum_float_ (glAlphaFunc)

value ml_glBitmap (value width, value height, value orig, value move,
		   value bitmap)  /* ML */
{
    glBitmap (Int_val(width), Int_val(height),
	      Float_val(Field(orig,0)), Float_val(Field(orig,1)),
	      Float_val(Field(move,0)), Float_val(Field(move,1)),
	      Addr_val(bitmap));
    return Val_unit;
}

ML_float4 (glClearAccum)
ML_double (glClearDepth)
ML_float (glClearIndex)
ML_int (glClearStencil)

ML_int4 (glColorMask)
ML_GLenum2 (glColorMaterial)

value ml_glCopyPixels (value x, value y, value width, value height,
		       value type)
{
    glCopyPixels (Int_val(x), Int_val(y), Int_val(width), Int_val(height),
		  GLenum_val(type));
    return Val_unit;
}

ML_GLenum (glDrawBuffer)

value ml_glDrawPixels (value width, value height, value format, value data)
{
    GLenum type = GLenum_val(Field(data,0));
    value data1 = Field(data,1);
    GLvoid *pixels;
    int i;

    switch (type)
    {
    case GL_BYTE: pixels = String_val(data1); break;
    case GL_BITMAP: pixels = Addr_val(data1); break;
    case GL_INT:
	pixels = calloc(Wosize_val(data1), sizeof(GLint));
	for (i = 0; i < Wosize_val(data1); i++)
	    ((GLint*)pixels)[i] = Int_val(Field(data1,i));
	break;
    case GL_FLOAT:
	pixels = calloc(Wosize_val(data1), sizeof(GLfloat));
	for (i = 0; i < Wosize_val(data1); i++)
	    ((GLfloat*)pixels)[i] = Float_val(Field(data1,i));
	break;
    }
    glDrawPixels (Int_val(width), Int_val(height), GLenum_val(format),
		  type, pixels);
    if (type == GL_INT || type == GL_FLOAT) free(pixels);
    return Val_unit;
}

ML_double (glEvalCoord1d)
ML_double2 (glEvalCoord2d)
ML_GLenum_int2_ (glEvalMesh1)
ML_GLenum_int4_ (glEvalMesh2)
ML_int (glEvalPoint1)
ML_int2 (glEvalPoint2)

value ml_glHint (value target, value hint)
{
    GLenum targ;

    switch (target) {
    case MLTAG_fog:	targ = GL_FOG_HINT; break;
    case MLTAG_line_smooth:	targ = GL_LINE_SMOOTH_HINT; break;
    case MLTAG_perspective_correction:
	targ = GL_PERSPECTIVE_CORRECTION_HINT; break;
    case MLTAG_point_smooth:	targ = GL_POINT_SMOOTH_HINT; break;
    case MLTAG_polygon_smooth:	targ = GL_POLYGON_SMOOTH_HINT; break;
    }
    glHint (targ, GLenum_val(hint));
    return Val_unit;
}

ML_int (glIndexMask)
ML_double (glIndexd)
ML_void (glInitNames)
ML_GLenum_int (glIsEnabled)

ML_int (glLoadName)
ML_GLenum (glLogicOp)

value ml_glMap1d (value target, value u1, value u2, value points)
{
    int i, order;
    double *dpoints;
    GLenum targ;
    int len = Wosize_val(points);

    if (len == 0) invalid_argument("Gl.map1");
    order = Wosize_val(Field(points,0));
    dpoints = calloc (order*len, sizeof(GLdouble));
    for (i = 0; i < len; i++) {
	int j;
	value point = Field(points,i);
	if (Wosize_val(point) != order) invalid_argument("Gl.map1");
	for (j = 0; j < order; j++)
	    *dpoints++ = Double_val(Field(point,j));
    }
    switch (target) {
    case MLTAG_vertex_3:	targ = GL_MAP1_VERTEX_3; break;
    case MLTAG_vertex_4:	targ = GL_MAP1_VERTEX_4; break;
    case MLTAG_index:	targ = GL_MAP1_INDEX; break;
    case MLTAG_color_4:	targ = GL_MAP1_COLOR_4; break;
    case MLTAG_normal:	targ = GL_MAP1_NORMAL; break;
    case MLTAG_texture_coord_1:	targ = GL_MAP1_TEXTURE_COORD_1; break;
    case MLTAG_texture_coord_2:	targ = GL_MAP1_TEXTURE_COORD_2; break;
    case MLTAG_texture_coord_3:	targ = GL_MAP1_TEXTURE_COORD_3; break;
    case MLTAG_texture_coord_4:	targ = GL_MAP1_TEXTURE_COORD_4; break;
    }
    glMap1d (targ, Double_val(u1), Double_val(u2), order, order, dpoints);
    free (dpoints);
    return Val_unit;
}

value ml_glMap2d (value target, value u1, value u2, value v1, value v2, value points)
{
    int i, order;
    double *dpoints;
    GLenum targ;
    int len = Wosize_val(points);

    if (len == 0) invalid_argument("Gl.map1");
    order = Wosize_val(Field(points,0));
    dpoints = calloc (order*len, sizeof(GLdouble));
    for (i = 0; i < len; i++) {
	int j;
	value point = Field(points,i);
	if (Wosize_val(point) != order) invalid_argument("Gl.map1");
	for (j = 0; j < order; j++)
	    *dpoints++ = Double_val(Field(point,j));
    }
    switch (target) {
    case MLTAG_vertex_3:	targ = GL_MAP1_VERTEX_3; break;
    case MLTAG_vertex_4:	targ = GL_MAP1_VERTEX_4; break;
    case MLTAG_index:	targ = GL_MAP1_INDEX; break;
    case MLTAG_color_4:	targ = GL_MAP1_COLOR_4; break;
    case MLTAG_normal:	targ = GL_MAP1_NORMAL; break;
    case MLTAG_texture_coord_1:	targ = GL_MAP1_TEXTURE_COORD_1; break;
    case MLTAG_texture_coord_2:	targ = GL_MAP1_TEXTURE_COORD_2; break;
    case MLTAG_texture_coord_3:	targ = GL_MAP1_TEXTURE_COORD_3; break;
    case MLTAG_texture_coord_4:	targ = GL_MAP1_TEXTURE_COORD_4; break;
    }
    glMap1d (targ, Double_val(u1), Double_val(u2), order, order, dpoints);
    free (dpoints);
    return Val_unit;
}
