/* $Id: ml_tk.c,v 1.1 1998-01-09 09:11:39 garrigue Exp $ */

#include <stdlib.h>
#include <GL/gl.h>
#include "tk.h"
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "ml_gl.h"
#include "tk_tags.h"

value ml_tkSetRGBMap (value array)  /* ML */
{
    int size, i;
    float *rgb;

    size = Wosize_val (array);
    rgb = (float *) calloc (3 * size, sizeof(float));
    for (i = 0; i < size; i++) {
	*rgb[i] = Float_val (Field(Field(array, i), 0));
	*rgb[size+i] = Float_val (Field(Field(array, i), 1));
	*rgb[size*2+i] = Float_val (Field(Field(array, i), 2));
    }
    tkSetRGBMap (size, rgb);
    free (rgb);
    return Val_unit;
}

value ml_tkSetOverlayMap (value array)  /* ML */
{
    int size, i;
    float *rgb;

    size = Wosize_val (array);
    rgb = (float *) calloc (3 * size, sizeof(float));
    for (i = 0; i < size; i++) {
	*rgb[i] = Float_val (Field(Field(array, i), 0));
	*rgb[size+i] = Float_val (Field(Field(array, i), 1));
	*rgb[size*2+i] = Float_val (Field(Field(array, i), 2));
    }
    tkSetOverlayMap (size, rgb);
    free (rgb);
    return Val_unit;
}
