/* $Id: ml_gl.c,v 1.51 2007-04-13 02:48:43 garrigue Exp $ */

#ifdef _WIN32
#include <wtypes.h>
#endif
#include <string.h>
#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#ifdef HAS_GLEXT_H
#include <GL/glext.h>
#endif
#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include "ml_raw.h"
#include "gl_tags.h"
#include "ml_gl.h"
#include <assert.h>

#include "ml_state_macros.h"

#if !defined(GL_VERSION_1_4)
#define GL_GENERATE_MIPMAP 0x8191
#endif

#define __ARB_ENABLE TRUE

/* #include <stdio.h> */

void ml_raise_gl(const char *errmsg)
{
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
      gl_exn = caml_named_value("glerror");
  raise_with_string(*gl_exn, (char*)errmsg);
}

void ml_raise_gltag(value tag){
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
      gl_exn = caml_named_value("tagerror");
  raise_with_arg(*gl_exn, tag);
}

value copy_string_check (const char *str)
{
    if (!str) ml_raise_gl("Null string");
    return copy_string ((char*) str);
}

struct record_in {
    value  key; 
    GLenum data;
};

struct record_out {
    GLenum key;
    value  data; 
};

static struct record_in input_table[] = {
#include "gl_tags.c"
};

static struct record_in *tag_table_in = NULL;
static struct record_out *tag_table_out = NULL;

#define TABLE_SIZE (TAG_NUMBER*2+1)

CAMLprim value ml_gl_make_table_in (value unit)
{
    int i;
    unsigned int hash;

    tag_table_in = stat_alloc (TABLE_SIZE * sizeof(struct record_in));
    memset ((char *) tag_table_in, 0, TABLE_SIZE * sizeof(struct record_in));
    for (i = 0; i < TAG_NUMBER; i++) {
	hash = (unsigned long) input_table[i].key % TABLE_SIZE;
	while (tag_table_in[hash].key != 0) {
	    hash ++;
	    if (hash == TABLE_SIZE) hash = 0;
	}
	tag_table_in[hash].key  = input_table[i].key;
	tag_table_in[hash].data = input_table[i].data;
    }
    return Val_unit;
}


CAMLprim value ml_gl_make_table_out (value unit)
{
    int i;
    unsigned int hash;

    tag_table_out = stat_alloc (TABLE_SIZE * sizeof(struct record_out));
    memset ((char *) tag_table_out, 0, TABLE_SIZE * sizeof(struct record_out));
    for (i = 0; i < TAG_NUMBER; i++) {
	hash = (unsigned long) input_table[i].data % TABLE_SIZE;
	while (tag_table_out[hash].key != 0) {
	    hash ++;
	    if (hash == TABLE_SIZE) hash = 0;
	}
	tag_table_out[hash].data = input_table[i].key;
	tag_table_out[hash].key  = input_table[i].data;
    }
    return Val_unit;
}


GLenum GLenum_val(value tag)
{
    unsigned int hash = (unsigned long) tag % TABLE_SIZE;

    if (!tag_table_in) ml_gl_make_table_in (Val_unit);
    while (tag_table_in[hash].key != tag) {
	if (tag_table_in[hash].key == 0) ml_raise_gltag (tag);
	hash++;
	if (hash == TABLE_SIZE) hash = 0;
    }
    /*
    fprintf(stderr, "Converted %ld to %d", Int_val(tag), tag_table_in[hash].data);
    */
    return tag_table_in[hash].data;
}

value Val_GLenum(GLenum e)
{
    unsigned int hash = (unsigned long) e % TABLE_SIZE;

    if (!tag_table_out) ml_gl_make_table_out (Val_unit);
    while (tag_table_out[hash].key != e) {
	if (tag_table_out[hash].key == 0) ml_raise_gl ("Tag not found");
	hash++;
	if (hash == TABLE_SIZE) hash = 0;
    }

    /*
    fprintf(stderr, "Converted %d to %ld", e, tag_table_out[hash].data);
    */
    return tag_table_out[hash].data;
}


ML_2 (glAccum, GLenum_val, Float_val)
ML_2 (glAlphaFunc, GLenum_val, Float_val)

ML_1 (glBegin, GLenum_val)

ML_5 (glBitmap, Int_val, Int_val, Pair(arg3,Float_val,Float_val),
      Pair(arg4,Float_val,Float_val), Void_raw)

ML_2 (glBlendFunc, GLenum_val, GLenum_val)

#ifdef GL_VERSION_1_4
ML_4 (glBlendFuncSeparate, GLenum_val, GLenum_val, GLenum_val, GLenum_val)
#endif

ML_4 (glBlendColor, Float_val, Float_val, Float_val, Float_val)

ML_1 (glBlendEquation, GLenum_val)

CAMLprim value ml_glClipPlane(value plane, value equation)  /* ML */
{
    double eq[4];
    int i;

    for (i = 0; i < 4; i++)
	eq[i] = Double_val (Field(equation,i));
    glClipPlane (GL_CLIP_PLANE0 + Int_val(plane), eq);
    return Val_unit;
}

CAMLprim value ml_glClear(value bit_list)  /* ML */
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
ML_4 (glClearAccum, Float_val, Float_val, Float_val, Float_val)
ML_4 (glClearColor, Double_val, Double_val, Double_val, Double_val)
ML_1 (glClearDepth, Double_val)
ML_1 (glClearIndex, Float_val)
ML_1 (glClearStencil, Int_val)
ML_4 (glColor4d, Double_val, Double_val, Double_val, Double_val)
ML_4 (glColorMask, Int_val, Int_val, Int_val, Int_val)
ML_2 (glColorMaterial, GLenum_val, GLenum_val)
ML_5 (glCopyPixels, Int_val, Int_val, Int_val, Int_val, GLenum_val)
ML_1 (glCullFace, GLenum_val)

ML_1 (glDisable, GLenum_val)
ML_1 (glDepthFunc, GLenum_val)
ML_1 (glDepthMask, Int_val)
ML_2 (glDepthRange, Double_val, Double_val)

CAMLprim value ml_glDrawBuffer (value buffer)
{
    if (Is_block(buffer)) {
	int n = Int_val (Field(buffer,1));
	if (n >= GL_AUX_BUFFERS)
	    ml_raise_gl ("GlFunc.draw_buffer : no such auxiliary buffer");
	glDrawBuffer (GL_AUX0 + n);
    }
    else glDrawBuffer (GLenum_val(buffer));
    return Val_unit;
}

ML_4 (glDrawPixels, Int_val, Int_val, GLenum_val, Type_void_raw)

ML_1 (glEdgeFlag, Int_val)
ML_1 (glEnable, GLenum_val)
ML_0 (glEnd)
ML_1 (glEvalCoord1d, Double_val)
ML_2 (glEvalCoord2d, Double_val, Double_val)
ML_3 (glEvalMesh1, GLenum_val, Int_val, Int_val)
ML_5 (glEvalMesh2, GLenum_val, Int_val, Int_val, Int_val, Int_val)
ML_1 (glEvalPoint1, Int_val)
ML_2 (glEvalPoint2, Int_val, Int_val)


ML_3 (glFeedbackBuffer, Int_val, GLenum_val, (GLfloat*)Addr_raw)

CAMLprim value ml_glFog (value param) /* ML */
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
      for (i = 0; i < 4; i++) params[i] = Float_val(Field(Field(param,1),i));
	glFogfv(GL_FOG_COLOR, params);
	break;
    case MLTAG_coordinate_source:
      glFogi(GL_FOG_COORDINATE_SOURCE, GLenum_val(Field(param,1)));
    }
    return Val_unit;
}

#ifdef GL_VERSION_1_4
ML_1(glFogCoordd, Double_val)
#endif

ML_0 (glFlush)
ML_0 (glFinish)
ML_1 (glFrontFace, GLenum_val)
ML_3 (glFrustum, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val), Pair(arg3,Double_val,Double_val))

ML_1_ (glGetString, GLenum_val, copy_string_check)
ML_2 (glGetDoublev, GLenum_val, Double_raw)

CAMLprim value ml_glGetError(value unit)
{
    switch (glGetError()) {
    case GL_NO_ERROR:       return MLTAG_no_error;
    case GL_INVALID_ENUM:   return MLTAG_invalid_enum;
    case GL_INVALID_VALUE:  return MLTAG_invalid_value;
    case GL_INVALID_OPERATION:  return MLTAG_invalid_operation;
    case GL_STACK_OVERFLOW: return MLTAG_stack_overflow;
    case GL_STACK_UNDERFLOW: return MLTAG_stack_underflow;
    case GL_OUT_OF_MEMORY:  return MLTAG_out_of_memory;
#if defined(GL_VERSION_1_2) || defined(GL_TABLE_TOO_LARGE)
    case GL_TABLE_TOO_LARGE: return MLTAG_table_too_large;
#endif
    default: ml_raise_gl("glGetError: unknown error");
    }
}
	
CAMLprim value ml_glHint (value target, value hint)
{
    GLenum targ = 0U;

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

ML_1 (glIndexMask, Int_val)
ML_1 (glIndexd, Double_val)
ML_0 (glInitNames)
ML_1_ (glIsEnabled, GLenum_val, Val_int)

CAMLprim value ml_glLight (value n, value param)  /* ML */
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
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    case MLTAG_spot_direction:
	for (i = 0; i < 3; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    default:
	params[0] = Float_val (Field(param, 1));
    }
    glLightfv (GL_LIGHT0 + Int_val(n), GLenum_val(Field(param,0)), params);
    return Val_unit;
}

CAMLprim value ml_glLightModel (value param)  /* ML */
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
		       Int_val(Field(param,1)));
	break;
    case MLTAG_two_side:
	glLightModeli (GL_LIGHT_MODEL_TWO_SIDE,
		       Int_val(Field(param,1)));
	break;
    case MLTAG_color_control:
#ifdef GL_VERSION_1_2
	switch (Field(param,1))
        {
          case MLTAG_separate_specular_color:
        	glLightModeli (GL_LIGHT_MODEL_COLOR_CONTROL,
		               GL_SEPARATE_SPECULAR_COLOR);
                break;
           case MLTAG_single_color:
        	glLightModeli (GL_LIGHT_MODEL_COLOR_CONTROL,
		               GL_SINGLE_COLOR);
                break;
        }
#else
        ml_raise_gl ("Parameter: GL_LIGHT_MODEL_COLOR_CONTROL not available");
#endif
	break;
    }
    return Val_unit;
}

ML_1 (glLineWidth, Float_val)
ML_2 (glLineStipple, Int_val, Int_val)
ML_1 (glLoadName, Int_val)
ML_0 (glLoadIdentity)
ML_1 (glLoadMatrixd, Double_raw)

#ifdef GL_VERSION_1_3
ML_1 (glLoadTransposeMatrixd, Double_raw)
#else
CAMLprim void ml_glLoadTransposeMatrixd (value raw)
{
    ml_raise_gl ("Function: glLoadTransposeMatrixd not available");
}
#endif
ML_1 (glLogicOp, GLenum_val)

CAMLprim value ml_glMap1d (value target, value *u, value order, value raw)
{
    int ustride = 0;
    GLenum targ = 0U;

    switch (target) {
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
    }
    glMap1d (targ, Double_val(u[0]), Double_val(u[1]),
	     ustride, Int_val(order), Double_raw(raw));
    return Val_unit;
}

CAMLprim value ml_glMap2d (value target, value u, value uorder,
                           value v, value vorder, value raw)
{
    int ustride = 0;
    GLenum targ = 0U;

    switch (target) {
    case MLTAG_vertex_3:
	targ = GL_MAP2_VERTEX_3; ustride = 3; break;
    case MLTAG_vertex_4:
	targ = GL_MAP2_VERTEX_4; ustride = 4; break;
    case MLTAG_index:
	targ = GL_MAP2_INDEX; ustride = 1; break;
    case MLTAG_color_4:
	targ = GL_MAP2_COLOR_4; ustride = 4; break;
    case MLTAG_normal:
	targ = GL_MAP2_NORMAL; ustride = 3; break;
    case MLTAG_texture_coord_1:
	targ = GL_MAP2_TEXTURE_COORD_1; ustride = 1; break;
    case MLTAG_texture_coord_2:
	targ = GL_MAP2_TEXTURE_COORD_2; ustride = 2; break;
    case MLTAG_texture_coord_3:
	targ = GL_MAP2_TEXTURE_COORD_3; ustride = 3; break;
    case MLTAG_texture_coord_4:
	targ = GL_MAP2_TEXTURE_COORD_4; ustride = 4; break;
    }
    glMap2d (targ, Double_val(Field(u,0)), Double_val(Field(u,1)), ustride,
	     Int_val(uorder), Double_val(Field(v,0)), Double_val(Field(v,1)),
	     Int_val(uorder)*ustride, Int_val(vorder), Double_raw(raw));
    return Val_unit;
}

ML_bc6 (ml_glMap2d)

ML_2 (glMapGrid1d, Int_val, Pair(arg2,Double_val,Double_val))
ML_4 (glMapGrid2d, Int_val, Pair(arg2,Double_val,Double_val),
      Int_val, Pair(arg4,Double_val,Double_val))

CAMLprim value ml_glMaterial (value face, value param)  /* ML */
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

ML_1 (glMatrixMode, GLenum_val)
ML_1 (glMultMatrixd, Double_raw)

#ifdef GL_VERSION_1_3
ML_1 (glMultTransposeMatrixd, Double_raw)
#else
CAMLprim void ml_glMultTransposeMatrixd (value raw)
{
  ml_raise_gl ("Function: glMultTransposeMatrixd not available");
}
#endif 

ML_3 (glNormal3d, Double_val, Double_val, Double_val)

ML_1 (glPassThrough, Float_val)

CAMLprim value ml_glPixelMapfv (value map, value raw)
{
    glPixelMapfv (GLenum_val(map), Int_val(Size_raw(raw))/sizeof(GLfloat),
		  Float_raw(raw));
    return Val_unit;
}

ML_3 (glOrtho, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val), Pair(arg3,Double_val,Double_val))

ML_1 (glPixelStorei, Pair(arg1,GLenum_val,Int_val))

CAMLprim value ml_glPixelTransfer (value param)
{
    GLenum pname = GLenum_val (Field(param,0));

    switch (pname) {
    case GL_MAP_COLOR:
    case GL_MAP_STENCIL:
    case GL_INDEX_SHIFT:
    case GL_INDEX_OFFSET:
	glPixelTransferi (pname, Int_val (Field(param,1)));
	break;
    default:
	glPixelTransferf (pname, Float_val (Field(param,1)));
    }
    return Val_unit;
}

ML_2 (glPixelZoom, Float_val, Float_val)
ML_1 (glPointSize, Float_val)
#ifdef GL_VERSION_1_4
ML_2 (glPointParameterf, GLenum_val, Float_val)
#endif
ML_2 (glPolygonOffset, Float_val, Float_val)
ML_2 (glPolygonMode, GLenum_val, GLenum_val)
ML_1 (glPolygonStipple, (unsigned char *)Byte_raw)
ML_0 (glPopAttrib)
ML_0 (glPopMatrix)
ML_0 (glPopName)

CAMLprim value ml_glPushAttrib (value list)
{
    GLbitfield mask = 0;

    while (list != Val_int(0)) {
	switch (Field(list,0)) {
	case MLTAG_accum_buffer:mask |= GL_ACCUM_BUFFER_BIT; break;
	case MLTAG_color_buffer:mask |= GL_COLOR_BUFFER_BIT; break;
	case MLTAG_current:	mask |= GL_CURRENT_BIT; break;
	case MLTAG_depth_buffer:mask |= GL_DEPTH_BUFFER_BIT; break;
	case MLTAG_enable:	mask |= GL_ENABLE_BIT; break;
	case MLTAG_eval:	mask |= GL_EVAL_BIT; break;
	case MLTAG_fog:		mask |= GL_FOG_BIT; break;
	case MLTAG_hint:	mask |= GL_HINT_BIT; break;
	case MLTAG_lighting:	mask |= GL_LIGHTING_BIT; break;
	case MLTAG_line:	mask |= GL_LINE_BIT; break;
	case MLTAG_list:	mask |= GL_LIST_BIT; break;
	case MLTAG_pixel_mode:	mask |= GL_PIXEL_MODE_BIT; break;
	case MLTAG_point:	mask |= GL_POINT_BIT; break;
	case MLTAG_polygon:	mask |= GL_POLYGON_BIT; break;
	case MLTAG_polygon_stipple:mask |= GL_POLYGON_STIPPLE_BIT; break;
	case MLTAG_scissor:	mask |= GL_SCISSOR_BIT; break;
	case MLTAG_stencil_buffer:mask |= GL_STENCIL_BUFFER_BIT; break;
	case MLTAG_texture:	mask |= GL_TEXTURE_BIT; break;
	case MLTAG_transform:	mask |= GL_TRANSFORM_BIT; break;
	case MLTAG_viewport:	mask |= GL_VIEWPORT_BIT; break;
	}
	list = Field(list,1);
    }
    glPushAttrib (mask);
    return Val_unit;
}

ML_0 (glPushMatrix)
ML_1 (glPushName, Int_val)

CAMLprim value ml_glRasterPos(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glRasterPos2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glRasterPos3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glRasterPos4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}

CAMLprim value ml_glReadBuffer (value buffer)
{
    if (Is_block(buffer)) {
	int n = Int_val (Field(buffer,1));
	if (n >= GL_AUX_BUFFERS)
	    ml_raise_gl ("GlFunc.read_buffer : no such auxiliary buffer");
	glReadBuffer (GL_AUX0 + n);
    }
    else glReadBuffer (GLenum_val(buffer));
    return Val_unit;
}

CAMLprim value ml_glReadPixels(value x, value y, value w, value h, value format , value raw)  /* ML */
{
  glPixelStorei(GL_PACK_SWAP_BYTES, 0);
  glPixelStorei(GL_PACK_ALIGNMENT, 1);
  glReadPixels(Int_val(x),Int_val(y),Int_val(w),Int_val(h),GLenum_val(format),
	       Type_void_raw(raw));
  return Val_unit;
}

ML_bc6 (ml_glReadPixels)
ML_2 (glRectd, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val))
ML_1_ (glRenderMode, GLenum_val, Val_int)
ML_4 (glRotated, Double_val, Double_val, Double_val, Double_val)
ML_3 (glScaled, Double_val, Double_val, Double_val)

ML_4 (glScissor, Int_val, Int_val, Int_val, Int_val)
ML_2 (glSampleCoverage, Float_val, Bool_val)

ML_2 (glSelectBuffer, Int_val, (GLuint*)Addr_raw)
ML_3 (glSecondaryColor3d, Double_val, Double_val, Double_val)
ML_1 (glShadeModel, GLenum_val)
ML_3 (glStencilFunc, GLenum_val, Int_val, Int_val)
ML_1 (glStencilMask, Int_val)
ML_3 (glStencilOp, GLenum_val, GLenum_val, GLenum_val)

ML_1 (glTexCoord1d, Double_val)
ML_2 (glTexCoord2d, Double_val, Double_val)
ML_3 (glTexCoord3d, Double_val, Double_val, Double_val)
ML_4 (glTexCoord4d, Double_val, Double_val, Double_val, Double_val)

CAMLprim value ml_glTexEnv (value target, value param)
{
    value params = Field(param,1);
    GLfloat color[4];
    int i;
    int t = GL_TEXTURE_ENV;

#ifdef GL_VERSION_1_4
    switch(target) {
    case MLTAG_filter_control:
        t = GL_TEXTURE_FILTER_CONTROL;
	break;
    }
#endif

    switch (Field(param,0)) {
    case MLTAG_mode:
	glTexEnvi (t, GL_TEXTURE_ENV_MODE, GLenum_val(params));
	break;
    case MLTAG_color:
	for (i = 0; i < 4; i++) color[i] = Float_val(Field(params,i));
	glTexEnvfv (t, GL_TEXTURE_ENV_COLOR, color);
	break;
    case MLTAG_combine_rgb:
        glTexEnvi (t, GL_COMBINE_RGB, GLenum_val(params));
        break;
    case MLTAG_combine_alpha:
        glTexEnvi (t, GL_COMBINE_ALPHA, GLenum_val(params));
        break;
    case MLTAG_source0_rgb:
        glTexEnvi (t, GL_SOURCE0_RGB, GLenum_val(params));
        break;
    case MLTAG_source1_rgb:
        glTexEnvi (t, GL_SOURCE1_RGB, GLenum_val(params));
        break;
    case MLTAG_source2_rgb:
        glTexEnvi (t, GL_SOURCE2_RGB, GLenum_val(params));
        break;
    case MLTAG_operand0_rgb:
        glTexEnvi (t, GL_OPERAND0_RGB, GLenum_val(params));
        break;
    case MLTAG_operand1_rgb:
        glTexEnvi (t, GL_OPERAND1_RGB, GLenum_val(params));
        break;
    case MLTAG_operand2_rgb:
        glTexEnvi (t, GL_OPERAND2_RGB, GLenum_val(params));
        break;
    case MLTAG_source0_alpha:
        glTexEnvi (t, GL_SOURCE0_ALPHA, GLenum_val(params));
        break;
    case MLTAG_source1_alpha:
        glTexEnvi (t, GL_SOURCE1_ALPHA, GLenum_val(params));
        break;
    case MLTAG_source2_alpha:
        glTexEnvi (t, GL_SOURCE2_ALPHA, GLenum_val(params));
        break;
    case MLTAG_operand0_alpha:
        glTexEnvi (t, GL_OPERAND0_ALPHA, GLenum_val(params));
        break;
    case MLTAG_operand1_alpha:
        glTexEnvi (t, GL_OPERAND1_ALPHA, GLenum_val(params));
        break;
    case MLTAG_operand2_alpha:
        glTexEnvi (t, GL_OPERAND2_ALPHA, GLenum_val(params));
        break;
    }
    return Val_unit;
}

CAMLprim value ml_glTexGen (value coord, value param)
{
    value params = Field(param,1);
    GLdouble point[4];
    int i;

    if (Field(param,0) == MLTAG_mode)
	glTexGeni (GLenum_val(coord), GL_TEXTURE_GEN_MODE, GLenum_val(params));
    else {
	for (i = 0; i < 4; i++) point[i] = Double_val(Field(params,i));
	glTexGendv (GLenum_val(coord), GLenum_val(Field(param,0)), point);
    }
    return Val_unit;
}

CAMLprim value ml_glTexImage1D (value proxy, value level, value internal,
                                value width, value border, value format,
                                value data)
{
    glTexImage1D (proxy == Val_int(1)
		  ? GL_PROXY_TEXTURE_1D : GL_TEXTURE_1D,
		  Int_val(level), GLenum_val(internal), Int_val(width),
		  Int_val(border), GLenum_val(format),
		  Type_raw(data), Void_raw(data));
    return Val_unit;
}

ML_bc7 (ml_glTexImage1D)

CAMLprim value ml_glTexImage2D (value target, value level, value internal,
                                value width, value height, value border,
                                value format, value data)
{
    /* printf("p=%x,l=%d,i=%d,w=%d,h=%d,b=%d,f=%x,t=%x,d=%x\n", */
  glTexImage2D (GLenum_val(target),
		Int_val(level), GLenum_val(internal), Int_val(width),
		Int_val(height), Int_val(border), GLenum_val(format),
		Type_raw(data), Void_raw(data));
    /*  flush(stdout); */
    return Val_unit;
}

ML_bc8 (ml_glTexImage2D)

CAMLprim value ml_glTexImage3D (value proxy, value level, value internal,
                                value width, value height, value depth,
				value border, value format, value data)
{
    glTexImage3D (proxy == Val_int(1)
		  ? GL_PROXY_TEXTURE_3D : GL_TEXTURE_3D,
		  Int_val(level), GLenum_val(internal), Int_val(width),
		  Int_val(height), Int_val(depth), 
		  Int_val(border), GLenum_val(format),
		  Type_raw(data), Void_raw(data));
    return Val_unit;
}

ML_bc9 (ml_glTexImage3D)

CAMLprim value ml_glTexParameter (value target, value param)
{
    GLenum targ = GLenum_val(target);
    GLenum pname = GLenum_val(Field(param,0));
    value params = Field(param,1);
    GLfloat color[4];
    int i;

    switch (pname) {
    case GL_TEXTURE_BORDER_COLOR:
	for (i = 0; i < 4; i++) color[i] = Float_val(Field(params,i));
	glTexParameterfv (targ, pname, color);
	break;
    case GL_TEXTURE_MIN_LOD:
    case GL_TEXTURE_MAX_LOD:
    case GL_TEXTURE_LOD_BIAS:
    case GL_TEXTURE_PRIORITY:
	glTexParameterf (targ, pname, Float_val(params));
	break;
    case GL_GENERATE_MIPMAP:
#ifdef GL_VERSION_1_4
        glTexParameteri (targ, pname, Int_val(params));
#else
        ml_raise_gl ("Parameter: GL_GENERATE_MIPMAP not available"); 
#endif
        break;
    case GL_TEXTURE_BASE_LEVEL:
    case GL_TEXTURE_MAX_LEVEL:
        glTexParameteri (targ, pname, Int_val(params));
	break;
    default:
	glTexParameteri (targ, pname, GLenum_val(params));
	break;
    }
    return Val_unit;
}

ML_2 (glGenTextures, Int_val, UInt_raw)
ML_2 (glBindTexture, GLenum_val, Nativeint_val)

CAMLprim value ml_glDeleteTexture (value texture_id)
{
    GLuint id = Nativeint_val(texture_id);
    glDeleteTextures(1,&id);
    return Val_unit;
}

ML_3 (glTranslated, Double_val, Double_val, Double_val)

CAMLprim value ml_glVertex(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glVertex2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glVertex3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glVertex4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}


ML_4 (glViewport, Int_val, Int_val, Int_val, Int_val)

#ifdef GL_VERSION_1_4
ML_2 (glWindowPos2d, Double_val, Double_val)
ML_3 (glWindowPos3d, Double_val, Double_val, Double_val)
#endif


/* List functions */

ML_1_ (glIsList, Int_val, Val_int)
ML_2 (glDeleteLists, Int_val, Int_val)
ML_1_ (glGenLists, Int_val, Val_int)
ML_2 (glNewList, Int_val, GLenum_val)
ML_0 (glEndList)
ML_1 (glCallList, Int_val)
ML_1 (glListBase, Int_val)

CAMLprim value ml_glCallLists (value indexes)  /* ML */
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

/* Multitexture functions  -------------------------------- */
/* 
   To speed up the calls, we don't use the Glenum_val translation facility, 
   and do the work in the ml module directly 
*/

ML_1(glActiveTexture, Int_val)
ML_1(glClientActiveTexture, Int_val)

ML_2(glMultiTexCoord1d, Int_val, GLdouble_val)
ML_2(glMultiTexCoord1f, Int_val, GLfloat_val)
ML_2(glMultiTexCoord1i, Int_val, GLint_val)
ML_2(glMultiTexCoord1s, Int_val, GLshort_val)

ML_3(glMultiTexCoord2d, Int_val, GLdouble_val, GLdouble_val)
ML_3(glMultiTexCoord2f, Int_val, GLfloat_val, GLfloat_val)
ML_3(glMultiTexCoord2i, Int_val, GLint_val, GLint_val)
ML_3(glMultiTexCoord2s, Int_val, GLshort_val, GLshort_val)

ML_4(glMultiTexCoord3d, Int_val, GLdouble_val, GLdouble_val, GLdouble_val)
ML_4(glMultiTexCoord3f, Int_val, GLfloat_val, GLfloat_val, GLfloat_val)
ML_4(glMultiTexCoord3i, Int_val, GLint_val, GLint_val, GLint_val)
ML_4(glMultiTexCoord3s, Int_val, GLshort_val, GLshort_val, GLshort_val)

ML_5(glMultiTexCoord4d, Int_val, GLdouble_val, GLdouble_val, GLdouble_val, GLdouble_val)
ML_5(glMultiTexCoord4f, Int_val, GLfloat_val, GLfloat_val, GLfloat_val, GLfloat_val)
ML_5(glMultiTexCoord4i, Int_val, GLint_val, GLint_val, GLint_val, GLint_val)
ML_5(glMultiTexCoord4s, Int_val, GLshort_val, GLshort_val, GLshort_val, GLshort_val)

ML_2(glMultiTexCoord1dv, Int_val, GLdoublePtr_val)
ML_2_ARRAY(glMultiTexCoord1fv, Int_val, GLfloat, Double_field)
ML_2_ARRAY(glMultiTexCoord1iv, Int_val, GLint, Field)
ML_2_ARRAY(glMultiTexCoord1sv, Int_val, GLshort, Field)

ML_2(glMultiTexCoord2dv, Int_val, GLdoublePtr_val)
ML_2_ARRAY(glMultiTexCoord2fv, Int_val, GLfloat, Double_field)
ML_2_ARRAY(glMultiTexCoord2iv, Int_val, GLint, Field)
ML_2_ARRAY(glMultiTexCoord2sv, Int_val, GLshort, Field)

ML_2(glMultiTexCoord3dv, Int_val, GLdoublePtr_val)
ML_2_ARRAY(glMultiTexCoord3fv, Int_val, GLfloat, Double_field)
ML_2_ARRAY(glMultiTexCoord3iv, Int_val, GLint, Field)
ML_2_ARRAY(glMultiTexCoord3sv, Int_val, GLshort, Field)

ML_2(glMultiTexCoord4dv, Int_val, GLdoublePtr_val)
ML_2_ARRAY(glMultiTexCoord4fv, Int_val, GLfloat, Double_field)
ML_2_ARRAY(glMultiTexCoord4iv, Int_val, GLint, Field)
ML_2_ARRAY(glMultiTexCoord4sv, Int_val, GLshort, Field)

/* Interleaved functions ---------------------------------- */

ML_3(glInterleavedArrays, GLenum_val, Int_val, Void_raw)

/* ColorTable functions ----------------------------------- */

ML_5(glColorTable, GLenum_val, GLenum_val, Int_val, GLenum_val, Type_void_raw)

/* replace target parameter with a constant value, since that's what the functions expect
   and that the ml code passes it also, no need to check */
#define gl_histogram(x) GL_HISTOGRAM
#define gl_minmax(x) GL_MINMAX

SET_1_4F(ColorTableParameterfv, COLOR_TABLE_SCALE, GLenum_val)
SET_1_4F(ColorTableParameterfv, COLOR_TABLE_BIAS, GLenum_val)
ML_5(glCopyColorTable, GLenum_val, GLenum_val, Int_val, Int_val, Int_val)
ML_5(glColorSubTable, GLenum_val, Int_val, Int_val, GLenum_val, Type_void_raw)
ML_5(glCopyColorSubTable, GLenum_val, Int_val, Int_val, Int_val, Int_val)
ML_4(glHistogram, gl_histogram, Int_val, GLenum_val, Bool_val)
ML_3(glMinmax, gl_minmax, GLenum_val, Bool_val)
ML_1(glResetMinmax, gl_minmax)

/* ConvolutionFilter functions ---------------------------- */

#define gl_convolution_1d(x) GL_CONVOLUTION_1D
#define gl_convolution_2d(x) GL_CONVOLUTION_2D
#define gl_separable_2d(x) GL_SEPARABLE_2D

ML_5(glConvolutionFilter1D, gl_convolution_1d, GLenum_val, Int_val, GLenum_val, Type_void_raw)
ML_6(glConvolutionFilter2D, gl_convolution_2d, GLenum_val, Int_val, Int_val, GLenum_val, Type_void_raw)
ML_bc6(ml_glConvolutionFilter2D)
ML_7(glSeparableFilter2D, gl_separable_2d, GLenum_val, Int_val, Int_val, GLenum_val, Type_void_raw, Void_raw)
ML_bc7(ml_glSeparableFilter2D)
ML_5(glCopyConvolutionFilter1D, gl_convolution_1d, GLenum_val, Int_val, Int_val, Int_val)
ML_6(glCopyConvolutionFilter2D, gl_convolution_2d, GLenum_val, Int_val, Int_val, Int_val, Int_val)
ML_bc6(ml_glCopyConvolutionFilter2D)

SET_1_ENUM(ConvolutionParameteriv,CONVOLUTION_BORDER_MODE,GLenum_val)
SET_1_4F(ConvolutionParameterfv,CONVOLUTION_FILTER_SCALE, GLenum_val)
SET_1_4F(ConvolutionParameterfv,CONVOLUTION_FILTER_BIAS, GLenum_val)

/* State functions ---------------------------------------- */

CAMLprim value ml_glGetBoolean(value arg1) {
  GLboolean b;
  glGetBooleanv(GLenum_val(arg1), &b);
  return Val_bool(b);
}


CAMLprim value ml_glGetInteger(value arg1) {
  int i;
  glGetIntegerv(GLenum_val(arg1), &i);
  return Val_int(i);
}

CAMLprim value ml_glGetFloat(value arg1) {
  float f;
  value ret = caml_alloc(Double_wosize,Double_tag);
  glGetFloatv(GLenum_val(arg1), &f);
  Store_double_val(ret,(double)f);
  return ret;
}

CAMLprim value ml_glGetDouble(value arg1) {
  double d;
  value ret = caml_alloc(Double_wosize,Double_tag);
  glGetDoublev(GLenum_val(arg1), &d);
  Store_double_val(ret,d);
  return ret;
}

ML_2_ARRAY_(glGetIntegerv, GLenum_val, GLint, Store_field)
ML_2_ARRAY_(glGetFloatv, GLenum_val, GLfloat, Store_double_field)
/* ML_2_ARRAY_(glGetDoublev, GLenum_val, GLdouble, Store_double_field) */
ML_2_ARRAY_(glGetBooleanv, GLenum_val, GLboolean, Store_field)

CAMLprim value ml_glGetClipPlane(value arg) {
  GLdouble p[4];
  value ret;
  glGetClipPlane(Int_val(arg),p);
  ret = caml_alloc_tuple(4);
  Store_tuple_double_val(ret,0,p[0]);
  Store_tuple_double_val(ret,1,p[1]);
  Store_tuple_double_val(ret,2,p[2]);
  Store_tuple_double_val(ret,3,p[3]);
  return ret;
}

/* 
/ this code works, but we'd rather move as much logic out of the C functions
// into the ocaml modules, to benefit from the boxing facilities built in the 
// language, as well as any optimization implemented in the future 

CAMLprim value ml_glGetLight(value arg1, value arg2){
  GLenum pname = GLenum_val(arg2);
  int    num   = Int_val(arg1);
  float p[4];
  value v = Val_unit;
  value ret = caml_alloc_tuple(2);
  Field(ret,0) = arg2;
  
  switch (arg2){
  case MLTAG_ambient:
  case MLTAG_diffuse:
  case MLTAG_specular:
  case MLTAG_position:
    glGetLightfv(num,pname,p);
    v = caml_alloc_tuple(4);
    Store_tuple_double_val(v,0,p[0]);
    Store_tuple_double_val(v,1,p[1]);
    Store_tuple_double_val(v,2,p[2]);
    Store_tuple_double_val(v,3,p[3]);
    Field(ret,1) = v;
    return ret;
  case MLTAG_spot_direction:
    glGetLightfv(num,pname,p);
    v = caml_alloc_tuple(3);
    Store_tuple_double_val(v,0,p[0]);
    Store_tuple_double_val(v,1,p[1]);
    Store_tuple_double_val(v,2,p[2]);
    Store_field(ret,1,v);
    return ret;
  case MLTAG_spot_exponent:
  case MLTAG_spot_cutoff:
  case MLTAG_constant_attenuation:
  case MLTAG_linear_attenuation:
  case MLTAG_quadratic_attenuation:
    glGetLightfv(num,pname,p);
    Store_tuple_double_val(ret,1,p[0]);
    return ret;
  }
  assert(0);
}

CAMLprim value ml_glGetMaterial(value arg1, value arg2){
  GLenum face  = GLenum_val(arg1);
  GLenum pname = GLenum_val(arg2);
  float p[4];
  value ret = Val_unit;

  switch (arg1){
  case MLTAG_ambient:
  case MLTAG_diffuse:
  case MLTAG_ambient_and_diffuse:
  case MLTAG_specular:
  case MLTAG_emission:
    ret = caml_alloc_tuple(2);
    Field(ret,0) = arg2;
    Field(ret,1) = caml_alloc_tuple(4);
    glGetMaterialfv(face,pname,p);
    Store_double_field(Field(ret,1),0,p[0]);
    Store_double_field(Field(ret,1),1,p[1]);
    Store_double_field(Field(ret,1),2,p[2]);
    Store_double_field(Field(ret,1),3,p[3]);
    return ret;
  case MLTAG_color_indexes:
    ret = caml_alloc_tuple(2);
    Field(ret,0) = arg2;
    Field(ret,1) = caml_alloc_tuple(3);
    glGetMaterialfv(face,pname,p);
    Store_double_field(Field(ret,1),0,p[0]);
    Store_double_field(Field(ret,1),1,p[1]);
    Store_double_field(Field(ret,1),2,p[2]);
    return ret;
  case MLTAG_shininess:
    glGetMaterialfv(face,pname,p);
    ret = caml_alloc_tuple(2);
    Field(ret,1) = arg2;
    Store_double_val(Field(ret,1),*p);
    return ret;
  }
  assert(0);
}
*/


GET_1_4F(GetLightfv,AMBIENT,Int_val)
GET_1_4F(GetLightfv,DIFFUSE,Int_val)
GET_1_4F(GetLightfv,SPECULAR,Int_val)
GET_1_4F(GetLightfv,POSITION,Int_val)

GET_1_3F(GetLightfv,SPOT_DIRECTION,Int_val)

GET_1_F(GetLightfv,SPOT_EXPONENT,Int_val)
GET_1_F(GetLightfv,SPOT_CUTOFF,Int_val)
GET_1_F(GetLightfv,CONSTANT_ATTENUATION,Int_val)
GET_1_F(GetLightfv,LINEAR_ATTENUATION,Int_val)
GET_1_F(GetLightfv,QUADRATIC_ATTENUATION,Int_val)

GET_1_4F(GetMaterialfv,AMBIENT,GLenum_val)
GET_1_4F(GetMaterialfv,DIFFUSE,GLenum_val)
GET_1_4F(GetMaterialfv,AMBIENT_AND_DIFFUSE,GLenum_val)
GET_1_4F(GetMaterialfv,SPECULAR,GLenum_val)
GET_1_4F(GetMaterialfv,EMISSION,GLenum_val)
GET_1_3F(GetMaterialfv,COLOR_INDEXES,GLenum_val)
GET_1_F(GetMaterialfv,SHININESS,GLenum_val)

/* replace target with GL_TEXTURE_ENV */
#define gl_tex_env(x) GL_TEXTURE_ENV
#define gl_filter_control(x) GL_TEXTURE_FILTER_CONTROL

GET_1_ENUM(GetTexEnviv,TEXTURE_ENV_MODE,gl_tex_env)
GET_1_ENUM(GetTexEnviv,COMBINE_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,COMBINE_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE0_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE1_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE2_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND0_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND1_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND2_RGB,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE0_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE1_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,SOURCE2_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND0_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND1_ALPHA,gl_tex_env)
GET_1_ENUM(GetTexEnviv,OPERAND2_ALPHA,gl_tex_env)
GET_1_4F(GetTexEnvfv,TEXTURE_ENV_COLOR,gl_tex_env)
GET_1_3F(GetTexEnvfv,RGB_SCALE,gl_tex_env)
GET_1_3F(GetTexEnvfv,ALPHA_SCALE,gl_tex_env)

#ifdef GL_VERSION_1_4
GET_1_F(GetTexEnvfv,TEXTURE_LOD_BIAS,gl_filter_control)
#endif

GET_1_ENUM(GetTexGeniv,TEXTURE_GEN_MODE,GLenum_val)
GET_1_4F(GetTexGenfv,OBJECT_PLANE,GLenum_val)
GET_1_4F(GetTexGenfv,EYE_PLANE,GLenum_val)

GET_1_4F(GetTexParameterfv,TEXTURE_BORDER_COLOR,GLenum_val)
GET_1_B(GetTexParameteriv,GENERATE_MIPMAP,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_MAG_FILTER,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_MIN_FILTER,GLenum_val)
GET_1_F(GetTexParameterfv,TEXTURE_PRIORITY,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_WRAP_R,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_WRAP_S,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_WRAP_T,GLenum_val)
GET_1_F(GetTexParameterfv,TEXTURE_MIN_LOD,GLenum_val)
GET_1_F(GetTexParameterfv,TEXTURE_MAX_LOD,GLenum_val)
GET_1_I(GetTexParameteriv,TEXTURE_BASE_LEVEL,GLenum_val)
GET_1_I(GetTexParameteriv,TEXTURE_MAX_LEVEL,GLenum_val)
#ifdef GL_VERSION_1_4
GET_1_F(GetTexParameterfv,TEXTURE_LOD_BIAS,GLenum_val)
GET_1_ENUM(GetTexParameteriv,DEPTH_TEXTURE_MODE,GLenum_val)
GET_1_ENUM(GetTexParameteriv,TEXTURE_COMPARE_MODE,GLenum_val)
#endif

GET_2_I(GetTexLevelParameteriv,TEXTURE_WIDTH,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_HEIGHT,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_DEPTH,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_BORDER,GLenum_val,Int_val)
GET_2_ENUM(GetTexLevelParameteriv,TEXTURE_INTERNAL_FORMAT,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_COMPONENTS,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_RED_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_GREEN_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_BLUE_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_ALPHA_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_LUMINANCE_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_INTENSITY_SIZE,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_DEPTH_SIZE,GLenum_val,Int_val)
GET_2_B(GetTexLevelParameteriv,TEXTURE_COMPRESSED,GLenum_val,Int_val)
GET_2_I(GetTexLevelParameteriv,TEXTURE_COMPRESSED_IMAGE_SIZE,GLenum_val,Int_val)


int format_size(GLenum format){
  switch(format){

  case GL_RGBA:
  case GL_BGRA:
    return 4;
  case GL_RGB:
  case GL_BGR:
    return 3;
  case GL_LUMINANCE_ALPHA:
    return 2;
  }
  return 1;
}

CAMLprim value ml_glGetTexImage(value vtarget, value vlod, value vformat, value vkind){
  GLenum target = GLenum_val(vtarget);
  int    lod    = Int_val(vlod);
  GLenum format = GLenum_val(vformat);
  GLenum kind   = GLenum_val(vkind);

  value  ret    = caml_alloc_tuple(4);
  value  data;
  int width,height,depth;
  
  // get some info about the image to compute the needed space
  glGetTexLevelParameteriv(target, lod, GL_TEXTURE_WIDTH, &width);
  glGetTexLevelParameteriv(target, lod, GL_TEXTURE_HEIGHT, &height);
  glGetTexLevelParameteriv(target, lod, GL_TEXTURE_DEPTH, &depth);

  data = ml_raw_alloc(vkind,Val_int(width * height * depth * format_size(format)));

  glGetTexImage(target,lod,format,kind,Void_raw(data));

  Field(ret,0) = data;
  Field(ret,1) = Val_int(width);
  Field(ret,2) = Val_int(height);
  Field(ret,3) = Val_int(depth);

  return ret;
}

CAMLprim value ml_glGetCompressedTexImage(value vtarget, value vlod) {
  GLenum target = GLenum_val(vtarget);
  int    lod    = Int_val(vlod);

  value  data;
  int    width;

  /* get some info about the image to compute the needed space */
  glGetTexLevelParameteriv(target, lod, GL_TEXTURE_COMPRESSED_IMAGE_SIZE, &width);

  data = ml_raw_alloc(MLTAG_ubyte,Val_int(width));

  glGetCompressedTexImage(target,lod,Void_raw(data));

  return data;
}

CAMLprim value ml_glGetPolygonStipple(value unit){

  const int width = 32, height = 32;
  value data = ml_raw_alloc(MLTAG_bitmap,Val_int(width * height));
  glGetPolygonStipple(Void_raw(data));
  return data;
}

/* imaging subset */

CAMLprim value ml_glGetColorTable(value vtarget, value vformat, value vkind){
  GLenum target = GLenum_val(vtarget);
  GLenum format = GLenum_val(vformat);
  GLenum kind   = GLenum_val(vkind);

  int   width;
  value data;

  glGetColorTableParameteriv(target,GL_COLOR_TABLE_WIDTH, &width);
  data = ml_raw_alloc(vkind, Val_int(width * format_size(format)));
  glGetColorTable(target,format,kind,Void_raw(data));
  return data;
}

CAMLprim value ml_glGetConvolutionFilter(value vtarget, value vformat, value vkind){
  GLenum target = GLenum_val(vtarget);
  GLenum kind   = GLenum_val(vkind);
  GLenum format = GLenum_val(vformat);
  value  ret = caml_alloc_tuple(3);

  int   width;
  int   height;
  value data;

  glGetConvolutionParameteriv(target,GL_CONVOLUTION_WIDTH, &width);
  glGetConvolutionParameteriv(target,GL_CONVOLUTION_HEIGHT, &height);
  data = ml_raw_alloc(vkind, Val_int(width * height * format_size(format)));
  glGetConvolutionFilter(target,format,kind,Void_raw(data));

  Field(ret,0) = data;
  Field(ret,1) = Val_int(width);
  Field(ret,2) = Val_int(height);
  return ret;
}

CAMLprim value ml_glGetSeparableFilter(value vtarget, value vformat, value vkind){
  GLenum target = GLenum_val(vtarget);
  GLenum kind   = GLenum_val(vkind);
  GLenum format = GLenum_val(vformat);
  value  ret = caml_alloc_tuple(4);

  int   width;
  int   height;
  value data1, data2;

  glGetConvolutionParameteriv(target,GL_CONVOLUTION_WIDTH, &width);
  glGetConvolutionParameteriv(target,GL_CONVOLUTION_HEIGHT, &height);
  data1 = ml_raw_alloc(vkind, Val_int(width * format_size(format)));
  data2 = ml_raw_alloc(vkind, Val_int(height * format_size(format)));
  glGetSeparableFilter(target,format,kind,Void_raw(data1),Void_raw(data2), NULL);

  Field(ret,0) = data1;
  Field(ret,1) = Val_int(width);
  Field(ret,2) = data2;
  Field(ret,3) = Val_int(height);
  return ret;
}


GET_1_ENUM(GetColorTableParameteriv,COLOR_TABLE_FORMAT,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_WIDTH,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_RED_SIZE,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_GREEN_SIZE,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_BLUE_SIZE,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_ALPHA_SIZE,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_LUMINANCE_SIZE,GLenum_val)
GET_1_I(GetColorTableParameteriv,COLOR_TABLE_INTENSITY_SIZE,GLenum_val)
GET_1_4F(GetColorTableParameterfv,COLOR_TABLE_SCALE,GLenum_val)
GET_1_4F(GetColorTableParameterfv,COLOR_TABLE_BIAS,GLenum_val)

GET_1_I(GetHistogramParameteriv,HISTOGRAM_WIDTH,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_FORMAT,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_RED_SIZE,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_GREEN_SIZE,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_BLUE_SIZE,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_ALPHA_SIZE,GLenum_val)
GET_1_I(GetHistogramParameteriv,HISTOGRAM_LUMINANCE_SIZE,GLenum_val)
GET_1_B(GetHistogramParameteriv,HISTOGRAM_SINK,GLenum_val)

GET_1_ENUM(GetMinmaxParameteriv,MINMAX_FORMAT,gl_minmax)
GET_1_B(GetMinmaxParameteriv,MINMAX_SINK,gl_minmax)




#define GET_PRIM(cname, type, count, conv1, setter)		\
  CAMLprim value ml_##cname##_##count(value arg1) {		\
    type p[count];						\
    int i;							\
    value ret = caml_alloc_tuple(count);			\
    cname(conv1(arg1),p);					\
    for (i = 0; i < count; i++)					\
      setter(ret,i,p[i]);					\
    return ret;							\
  }

GET_PRIM(glGetDoublev,double,4,GLenum_val,Store_tuple_double_val);
GET_PRIM(glGetDoublev,double,3,GLenum_val,Store_tuple_double_val);
GET_PRIM(glGetDoublev,double,2,GLenum_val,Store_tuple_double_val);

GET_PRIM(glGetIntegerv,int,4,GLenum_val,Store_field);
GET_PRIM(glGetIntegerv,int,2,GLenum_val,Store_field);


CAMLprim value ml_glGetEnum(value pname){
  GLint p;
  value ret = caml_alloc_tuple(2);
  glGetIntegerv(GLenum_val(pname),&p);
  Field(ret,0) = pname;
  Field(ret,1) = Val_GLenum(p);
  return ret;
}
