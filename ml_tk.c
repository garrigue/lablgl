/* $Id: ml_tk.c,v 1.4 1998-01-12 05:20:03 garrigue Exp $ */

#include <stdlib.h>
#include <GL/gl.h>
#include "gltk.h"
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include "ml_gl.h"
#include "tk_tags.h"

extern void invalid_argument (char *) Noreturn;

int TKenum_val(value tag)
{
    switch(tag)
    {
#include "tk_tags.c"
    }
    invalid_argument ("Unknown TK tag");
}

/* ML_void_bool (tkInitDisplay) */

value ml_tkInitDisplayMode(value list)  /* ML */
{
    GLint mode = 0;
    
    for ( ; list != Val_int(0); list = Field(list, 1))
	mode |= TKenum_val (Field(list, 0));
    tkInitDisplayMode (mode);
    return Val_unit;
}

/*
ML_TKenum (tkInitDisplayModePolicy)
ML_int_bool (tkInitDisplayModeID)
*/
ML_int4 (tkInitPosition)
ML_string_bool (tkInitWindow)
ML_void (tkCloseWindow)
ML_void (tkQuit)
/* ML_TKenum_bool (tkSetWindowLevel) */
ML_void (tkSwapBuffers)
ML_void (tkExec)

static void expose_func(GLsizei w, GLsizei h)
{
    static value * expose_func = NULL;

    if (expose_func == NULL)
	expose_func = caml_named_value ("expose_func");
    callback2 (Field(*expose_func, 0), Val_int(w), Val_int(h));
}

value ml_tkExposeFunc(value unit)  /* ML */
{
    tkExposeFunc (expose_func);
    return Val_unit;
}

static void reshape_func(GLsizei w, GLsizei h)
{
    static value * reshape_func = NULL;

    if (reshape_func == NULL)
	reshape_func = caml_named_value ("reshape_func");
    callback2 (Field(*reshape_func, 0), Val_int(w), Val_int(h));
}

value ml_tkReshapeFunc(value unit)  /* ML */
{
    tkReshapeFunc (reshape_func);
    return Val_unit;
}

static void display_func()
{
    static value * display_func = NULL;

    if (display_func == NULL)
	display_func = caml_named_value ("display_func");
    callback (Field(*display_func, 0), Val_unit);
}

value ml_tkDisplayFunc(value unit)  /* ML */
{
    tkDisplayFunc (display_func);
    return Val_unit;
}

static GLenum changes = GL_TRUE;

value ml_tkNoChanges (value unit)  /* ML */
{
    changes = GL_FALSE;
    return Val_unit;
}

static GLenum key_func(int key, GLenum mode)
{
    static value * key_func = NULL;
    value ml_key = MLTAG_return;
    value ml_mode = Val_int(0);
    value tmp;

    if (key_func == NULL)
	key_func = caml_named_value ("key_down_func");
    Begin_roots2(ml_key,ml_mode);
    switch (key)
    {
    case TK_RETURN: ml_key = MLTAG_return; break;
    case TK_ESCAPE: ml_key = MLTAG_escape; break;
    case TK_SPACE: ml_key = MLTAG_space; break;
    case TK_LEFT: ml_key = MLTAG_left; break;
    case TK_UP: ml_key = MLTAG_up; break;
    case TK_RIGHT: ml_key = MLTAG_right; break;
    case TK_DOWN: ml_key = MLTAG_down; break;
    default:
	ml_key = alloc_tuple(2);
	Field(ml_key, 0) = MLTAG_char;
	Field(ml_key, 1) = Val_int(key);
    }
    if (mode & TK_SHIFT) {
	tmp = ml_mode;
	ml_mode = alloc(2,0);
	Field(ml_mode,0) = MLTAG_shift;
	Field(ml_mode,1) = tmp;
    }
    if (mode & TK_CONTROL) {
	tmp = ml_mode;
	ml_mode = alloc(2,0);
	Field(ml_mode,0) = MLTAG_control;
	Field(ml_mode,1) = tmp;
    }
    changes = GL_TRUE;
    callback2 (Field(*key_func, 0), ml_key, ml_mode);
    End_roots ();
    return changes;
}

value ml_tkKeyDownFunc(value unit)  /* ML */
{
    tkKeyDownFunc (key_func);
    return Val_unit;
}

static GLenum mouse_down_func(int x, int y, GLenum button)
{
    static value * mouse_down_func = NULL;
    value ml_button = Val_unit;
    value tmp;

    Begin_roots1(ml_button);
    if (button & TK_LEFTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_left;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_MIDDLEBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_middle;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_RIGHTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_right;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (mouse_down_func == NULL)
	mouse_down_func = caml_named_value ("mouse_down_func");
    changes = GL_TRUE;
    callback3 (Field(*mouse_down_func, 0), Val_int(x), Val_int(y), ml_button);
    End_roots ();
    return changes;
}

value ml_tkMouseDownFunc(value unit)  /* ML */
{
    tkMouseDownFunc (mouse_down_func);
    return Val_unit;
}

static GLenum mouse_up_func(int x, int y, GLenum button)
{
    static value * mouse_up_func = NULL;
    value ml_button = Val_unit;
    value tmp;

    Begin_roots1(ml_button);
    if (button & TK_LEFTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_left;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_MIDDLEBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_middle;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_RIGHTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_right;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (mouse_up_func == NULL)
	mouse_up_func = caml_named_value ("mouse_up_func");
    changes = GL_TRUE;
    callback3 (Field(*mouse_up_func, 0), Val_int(x), Val_int(y), ml_button);
    End_roots();
    return changes;
}

value ml_tkMouseUpFunc(value unit)  /* ML */
{
    tkMouseUpFunc (mouse_up_func);
    return Val_unit;
}

static GLenum mouse_move_func(int x, int y, GLenum button)
{
    static value * mouse_move_func = NULL;
    value ml_button = Val_unit;
    value tmp;

    Begin_roots1(ml_button);
    if (button & TK_LEFTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_left;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_MIDDLEBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_middle;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (button & TK_RIGHTBUTTON) {
	tmp = alloc (2,0);
	Field(tmp,0) = MLTAG_right;
	Field(tmp,1) = ml_button;
	ml_button = tmp;
    }
    if (mouse_move_func == NULL)
	mouse_move_func = caml_named_value ("mouse_move_func");
    changes = GL_TRUE;
    callback3 (Field(*mouse_move_func, 0), Val_int(x), Val_int(y), ml_button);
    End_roots();
    return changes;
}

value ml_tkMouseMoveFunc(value unit)  /* ML */
{
    tkMouseMoveFunc (mouse_move_func);
    return Val_unit;
}

static void idle_func()
{
    static value * idle_func = NULL;

    if (idle_func == NULL)
	idle_func = caml_named_value ("idle_func");
    callback (Field(*idle_func, 0), Val_unit);
}

value ml_tkIdleFunc(value unit)  /* ML */
{
    tkIdleFunc (idle_func);
    return Val_unit;
}

ML_void_int (tkGetColorMapSize)

value ml_tkGetMouseLoc (value unit)  /* ML */
{
    int x,y;
    value pair;

    tkGetMouseLoc (&x, &y);
    pair = alloc_tuple(2);
    Field(pair,0) = x;
    Field(pair,1) = y;
    return pair;
}

value ml_tkSetOneColor(value index, value red, value green, value blue)  /* ML */
{
    tkSetOneColor (Int_val(index),
		   Float_val(red),
		   Float_val(green),
		   Float_val(blue));
    return Val_unit;
}

ML_int2 (tkSetFogRamp)
ML_void (tkSetGreyRamp)


value ml_tkSetRGBMap (value array)  /* ML */
{
    int size, i;
    float *rgb;

    size = Wosize_val (array);
    rgb = (float *) calloc (3 * size, sizeof(float));
    for (i = 0; i < size; i++) {
	rgb[i] = Float_val (Field(Field(array, i), 0));
	rgb[size+i] = Float_val (Field(Field(array, i), 1));
	rgb[size*2+i] = Float_val (Field(Field(array, i), 2));
    }
    tkSetRGBMap (size, rgb);
    free (rgb);
    return Val_unit;
}

/*
value ml_tkSetOverlayMap (value array)
{
    int size, i;
    float *rgb;

    size = Wosize_val (array);
    rgb = (float *) calloc (3 * size, sizeof(float));
    for (i = 0; i < size; i++) {
	rgb[i] = Float_val (Field(Field(array, i), 0));
	rgb[size+i] = Float_val (Field(Field(array, i), 1));
	rgb[size*2+i] = Float_val (Field(Field(array, i), 2));
    }
    tkSetOverlayMap (size, rgb);
    free (rgb);
    return Val_unit;
}
*/
