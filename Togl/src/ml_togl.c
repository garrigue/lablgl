/* $Id: ml_togl.c,v 1.6 2000-04-18 00:24:07 garrigue Exp $ */

#include <stdlib.h>
#include <GL/gl.h>
#include <tcl.h>
#include <tk.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include "togl.h"
#include "ml_gl.h"
#include "togl_tags.h"

extern Tcl_Interp *cltclinterp; /* The Tcl interpretor */
extern void tk_error (char *message); /* Raise TKerror */

int TOGLenum_val(value tag)
{
    switch(tag)
    {
#include "togl_tags.c"
    }
    invalid_argument ("Unknown Togl tag");
}

value ml_Togl_Init (value unit)  /* ML */
{
    if (Togl_Init(cltclinterp) == TCL_ERROR) tk_error ("Togl_Init failed");
    return Val_unit;
}

/* Does not register the structure with Caml !
static value Val_togl (struct Togl *togl)
{
    value wrapper = alloc(1,No_scan_tag);
    Field(wrapper,0) = (value) togl;
    return wrapper;
}
*/

enum {
     CreateFunc = 0,
     DisplayFunc,
     ReshapeFunc,
     DestroyFunc,
     TimerFunc,
     OverlayDisplayFunc,
     RenderFunc,
     LastFunc
};

static value *callbacks = NULL;

#define CALLBACK(func) \
static void callback_##func (struct Togl *togl) \
{ callback (Field(*callbacks, func), Val_addr(togl)); }
#define CALLBACK_const(func) \
static void callback_##func (const struct Togl *togl) \
{ callback (Field(*callbacks, func), Val_addr(togl)); }

#define ENABLER(func) \
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
CALLBACK_const (RenderFunc)

ENABLER (CreateFunc)
ENABLER (DisplayFunc)
ENABLER (ReshapeFunc)
ENABLER (DestroyFunc)
ENABLER (TimerFunc)
ENABLER (OverlayDisplayFunc)

ML_0 (Togl_ResetDefaultCallbacks)
ML_1 (Togl_PostRedisplay, Addr_val)
ML_1 (Togl_SwapBuffers, Addr_val)
ML_1_ (Togl_Ident, Addr_val, copy_string)
ML_1_ (Togl_Width, Addr_val, Val_int)
ML_1_ (Togl_Height, Addr_val, Val_int)

value ml_Togl_LoadBitmapFont (value togl, value font)  /* ML */
{
    char *fontname;

    if (Is_block(font)) fontname = String_val (Field(font,0));
    else switch (font) {
    case MLTAG_fixed_8x13:	fontname = TOGL_BITMAP_8_BY_13; break;
    case MLTAG_fixed_9x15:	fontname = TOGL_BITMAP_9_BY_15; break;
    case MLTAG_times_10:	fontname = TOGL_BITMAP_TIMES_ROMAN_10; break;
    case MLTAG_times_24:	fontname = TOGL_BITMAP_TIMES_ROMAN_24; break;
    case MLTAG_helvetica_10:	fontname = TOGL_BITMAP_HELVETICA_10; break;
    case MLTAG_helvetica_12:	fontname = TOGL_BITMAP_HELVETICA_12; break;
    case MLTAG_helvetica_18:	fontname = TOGL_BITMAP_HELVETICA_18; break;
    }
    return Val_int (Togl_LoadBitmapFont (Addr_val(togl), fontname));
}

ML_2 (Togl_UnloadBitmapFont, Addr_val, Int_val)
ML_2 (Togl_UseLayer, Addr_val, TOGLenum_val)
ML_1 (Togl_ShowOverlay, Addr_val)
ML_1 (Togl_HideOverlay, Addr_val)
ML_1 (Togl_PostOverlayRedisplay, Addr_val)
ML_1_ (Togl_ExistsOverlay, Addr_val, Val_int)
ML_1_ (Togl_GetOverlayTransparentValue, Addr_val, Val_int)

value ml_Togl_DumpToEpsFile (value togl, value filename, value rgbFlag)
{
    if (callbacks == NULL) callbacks = caml_named_value ("togl_callbacks");
    if (Togl_DumpToEpsFile(Addr_val(togl), String_val(filename),
			   Int_val(rgbFlag), callback_RenderFunc)
	== TCL_ERROR)
	tk_error ("Dump to EPS file failed");
    return Val_unit;
}
