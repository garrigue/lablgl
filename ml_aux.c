/* $Id: ml_aux.c,v 1.3 1998-01-07 08:52:31 garrigue Exp $ */

#include <GL/gl.h>
#include "aux.h"
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "variants.h"
#include "ml_gl.h"

ML_string(auxInitWindow)

#include <stdio.h>

value ml_auxInitDisplayMode(value list)  /* ML */
{
    GLint mode = 0;
    
    while (list != Val_int(0))
    {
	switch (Field(list, 0))
	{
	case MLTAG_rgb: mode |= AUX_RGB; break;
	case MLTAG_rgba: mode |= AUX_RGBA; break;
	case MLTAG_index: mode |= AUX_INDEX; break;
	case MLTAG_single: mode |= AUX_SINGLE; break;
	case MLTAG_double: mode |= AUX_DOUBLE; break;
	case MLTAG_depth: mode |= AUX_DEPTH; break;
	case MLTAG_accum: mode |= AUX_ACCUM; break;
	case MLTAG_stencil: mode |= AUX_STENCIL; break;
	}
	list = Field(list, 1);
    }
/*    fprintf (stderr, "Mode: %x", mode);
      flush (stderr); */
    auxInitDisplayMode (mode);
    return Val_unit;
}

value ml_auxInitPosition(value x, value y, value w, value h)  /* ML */
{
    auxInitPosition(Int_val(x),Int_val(y),Int_val(w),Int_val(h));
    return Val_unit;
}

static void reshape_func(GLsizei w, GLsizei h)
{
    static value * reshape_func = NULL;

    if (reshape_func == NULL)
	reshape_func = caml_named_value ("reshape_func");
    callback2 (Field(*reshape_func, 0), Val_int(w), Val_int(h));
}

value ml_auxReshapeFunc(value unit)  /* ML */
{
    auxReshapeFunc (reshape_func);
    return Val_unit;
}

static void key_func()
{
    static value * key_func = NULL;

    if (key_func == NULL)
	key_func = caml_named_value ("key_func");
    callback (Field(*key_func, 0), Val_unit);
}

value ml_auxKeyFunc(value key_desc)  /* ML */
{
    GLint key = 0;

    if (Is_block(key_desc)) key = Int_val(Field(key_desc, 1));
    else switch (key_desc)
    {
    case MLTAG_return: key = AUX_RETURN; break;
    case MLTAG_escape: key = AUX_ESCAPE; break;
    case MLTAG_space: key = AUX_SPACE; break;
    case MLTAG_left: key = AUX_LEFT; break;
    case MLTAG_up: key = AUX_UP; break;
    case MLTAG_right: key = AUX_RIGHT; break;
    case MLTAG_down: key = AUX_DOWN; break;
    }
    auxKeyFunc (key, key_func);
    return Val_unit;
}

static void mouse_func(AUX_EVENTREC *event)
{
    static value * mouse_func = NULL;

    if (mouse_func == NULL)
	mouse_func = caml_named_value ("mouse_func");
    callback2 (Field(*mouse_func, 0),
	      Val_int(event->data[AUX_MOUSEX]),
	      Val_int(event->data[AUX_MOUSEY]));
}

value ml_auxMouseFunc(value button, value mode)  /* ML */
{
    GLint b, m;

    switch (button)
    {
    case MLTAG_left: b = AUX_LEFTBUTTON; break;
    case MLTAG_middle: b = AUX_MIDDLEBUTTON; break;
    case MLTAG_right: b = AUX_RIGHTBUTTON; break;
    }
    switch (mode)
    {
    case MLTAG_up: m = AUX_UP; break;
    case MLTAG_down: m = AUX_DOWN; break;
    }
    auxMouseFunc (b, m, mouse_func);
    return Val_unit;
}

value ml_auxSetOneColor(value index, value red, value green, value blue)  /* ML */
{
    auxSetOneColor (Int_val(index),
		    Float_val(red),
		    Float_val(green),
		    Float_val(blue));
    return Val_unit;
}

ML_float(auxWireSphere)
ML_float(auxSolidSphere)
ML_float(auxWireCube)
ML_float(auxSolidCube)
ML_float3(auxWireBox)
ML_float3(auxSolidBox)
ML_float2(auxWireTorus)
ML_float2(auxSolidTorus)
ML_float2(auxWireCylinder)
ML_float2(auxSolidCylinder)
ML_float(auxWireIcosahedron)
ML_float(auxSolidIcosahedron)
ML_float(auxWireOctahedron)
ML_float(auxSolidOctahedron)
ML_float(auxWireTetrahedron)
ML_float(auxSolidTetrahedron)
ML_float(auxWireDodecahedron)
ML_float(auxSolidDodecahedron)
ML_float2(auxWireCone)
ML_float2(auxSolidCone)
ML_float(auxWireTeapot)
ML_float(auxSolidTeapot)

static void idle_func()
{
    static value * idle_func = NULL;

    if (idle_func == NULL)
	idle_func = caml_named_value ("idle_func");
    callback (Field(*idle_func, 0), Val_unit);
}

value ml_auxIdleFunc(value bool)  /* ML */
{
    if (bool == Val_true) auxIdleFunc (idle_func);
    else auxIdleFunc (NULL);
    return Val_unit;
}

static void display_func()
{
    static value * display_func = NULL;

    if (display_func == NULL)
	display_func = caml_named_value ("display_func");
    callback (Field(*display_func, 0), Val_unit);
}

value ml_auxMainLoop(value unit)  /* ML */
{
    auxMainLoop (display_func);
    return Val_unit;
}
