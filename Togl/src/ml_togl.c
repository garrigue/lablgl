/* $Id: ml_togl.c,v 1.1 1998-01-12 09:27:26 garrigue Exp $ */

#include <stdlib.h>
#include <GL/gl.h>
#include <tcl.h>
#include <tk.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include "togl.h"
#include "ml_gl.h"
#include "tk_tags.h"

extern Tcl_Interp *cltclinterp; /* The Tcl interpretor */
extern void tk_error (char *message); /* Raise TKerror */

int TOGLenum_val(value tag)
{
    switch(tag)
    {
#include "togle_tags.c"
    }
    invalid_argument ("Unknown Togl tag");
}

value ml_Togl_Init (value unit)  /* ML */
{
    if (Togl_Init(cltclinterp) == TCL_ERROR) tk_error ("Togl_Init failed");
    return Val_unit;
}

/* Does not register the structure with Caml ! */
static value Val_togl (struct Togl *togl)
{
    value wrapper = alloc(1,No_scan_tag);
    Field(wrapper,0) = (value) togl;
    return wrapper;
}

#define Togl_val(togl) ((struct Togl *) Field(togl,0))

enum {
     CreateFunc = 0,
     DisplayFunc,
     ReshapeFunc,
     DestroyFunc,
     TimerFunc,
     OverlayDisplayFunc,
     LastFunc
};

static value *callbacks = NULL;

#define CALLBACK(func) \
static void callback_##func (struct Togl *togl) \
{ callback (Field(*callbacks, func), Val_togl(togl)); }
#define ENABLER(func)
value ml_Togl_##func (value unit) \
{ if (callbacks == NULL) callbacks = caml_named_value ("togl_callbacks"); \
  Togl_##func (callback_##func); \
  return Val_unit; }

CALLBACK (CreateFunc)
CALLBACK (DisplayFunc)
CALLBACK (ReshapeFunc)
CALLBACK (DestroyFunc)
CALLBACK (TimerFunc)
CALLBACK (OverlayDisplayFunc)
CALLBACK (RenderFunc)

ENABLER (CreateFunc)
ENABLER (DisplayFunc)
ENABLER (ReshapeFunc)
ENABLER (DestroyFunc)
ENABLER (TimerFunc)
ENABLER (OverlayDisplayFunc)

ML_void (Togl_ResetDefaultCallbacks)
ML_togl (Togl_PostRedisplay)
ML_togl (Togl_SwapBuffers)
ML_togl_string (Togl_Ident)
ML_togl_int (Togl_Width)
ML_togl_int (Togl_Height)

value ml_Togl_LoadBitmapFont (value togl, value font)  /* ML */
{
    char *fontname;

    if (Is_block(font)) fontname = String_val (Field(font,0));
    else fontname = Togl_enum_val (font);
    return Val_int (Togl_LoadBitmapFont (Togl_val(togl), fontname));
}

ML_togl_int_ (Togl_UnloadBitmapFont)
ML_togl_TOGLenum_ (Togl_UseLayer)
ML_togl (Togl_ShowOverlay)
ML_togl (Togl_HideOverlay)
ML_togl (Togl_PostOverlayRedisplay)
ML_togl_int (Togl_ExistsOverlay)
ML_togl_int (Togl_GetOverlayTransparentValue)

value ml_Togl_DumpToEpsFile (value togl, value filename, value rgbFlag)
{
    if (callbacks == NULL) callbacks = caml_named_value ("togl_callbacks");
    if (Togl_DumpToEpsFile(Togl_val(togl), String_val(filename),
			   Int_val(rgbFlag), callbackRenderFunct)
	== TCL_ERROR)
	tk_error ("Dump to EPS file failed");
    return Val_unit;
}
