#include <GL/glut.h>
#include <stdio.h>
#include <stdlib.h>

#include <caml/mlvalues.h>
#include <caml/callback.h>

static void ocaml_gl_warning(const char msg[])
{
    fprintf(stderr, "OCaml Open GL warning : %s", msg);
    fflush(stderr);
}

value ocaml_glClear (
    value will_clear_color_buffer, 
    value will_clear_depth_buffer)
{
    GLbitfield mask = 0;
    mask |= (Bool_val(will_clear_color_buffer) ? GL_COLOR_BUFFER_BIT : 0);
    mask |= (Bool_val(will_clear_depth_buffer) ? GL_DEPTH_BUFFER_BIT : 0);
    glClear(mask);
    return Val_unit;
}

value ocaml_glClearColor (value r, value g, value b, value a)
{
    glClearColor(Double_val(r), Double_val(g), Double_val(b), Double_val(a));
    return Val_unit;
}

value ocaml_glBegin (value primitive_type)
{
    switch( Int_val(primitive_type) )
    {
        case 0: glBegin(GL_POINTS); break;
        case 1: glBegin(GL_LINES); break;
        case 2: glBegin(GL_LINE_LOOP); break;
        case 3: glBegin(GL_LINE_STRIP); break;
        case 4: glBegin(GL_TRIANGLES); break;
        case 5: glBegin(GL_TRIANGLE_STRIP); break;
        case 6: glBegin(GL_TRIANGLE_FAN); break;
        case 7: glBegin(GL_QUADS); break;
        case 8: glBegin(GL_QUAD_STRIP); break;
        case 9: glBegin(GL_POLYGON); break;
        default:
            ocaml_gl_warning("Unrecognized primitive type in ocaml_glBegin()\n"); 
    }
    return Val_unit;
}

value ocaml_glVertex3d (value vx, value vy, value vz)
{
    double x,y,z;
    x = Double_val(vx);
    y = Double_val(vy);
    z = Double_val(vz);
    glVertex3d(x,y,z);
    return Val_unit;
}

value ocaml_glVertex2d (value vx, value vy)
{
    double x,y;
    x = Double_val(vx);
    y = Double_val(vy);
    glVertex2d(x,y);
    return Val_unit;
}


value ocaml_glColor3d (value r, value g, value b)
{
    glColor3d(Double_val(r), Double_val(g), Double_val(b));
    return Val_unit;
}

// TexCoord

// Normal

value ocaml_glEnd ()
{
    glEnd();
    return Val_unit;
}

value ocaml_glFlush ()
{
    glFlush();
    return Val_unit;
}

value ocaml_glViewport (value vx, value vy, value vwidth, value vheight)
{
    int x,y,w,h;
    x=Int_val(vx);
    y=Int_val(vy);
    w=Int_val(vwidth);
    h=Int_val(vheight);
    glViewport(x, y, w, h);
    return Val_unit;
}

value ocaml_glMatrixMode (value mode)
{
    int imode = Int_val(mode);
    switch(imode)
    {
        case 0: glMatrixMode(GL_MODELVIEW); break;
        case 1: glMatrixMode(GL_PROJECTION); break;
        case 2: glMatrixMode(GL_TEXTURE); break;
        default:
            ocaml_gl_warning("Unrecognized mode in ocaml_glMatrixMode()\n");
    }
    return Val_unit;
}

value ocaml_glLoadIdentity ()
{
    glLoadIdentity();
    return Val_unit;
}

value ocaml_glShadeModel (value model)
{
    switch(Int_val(model))
    {
        case 0: glShadeModel(GL_FLAT); break;
        case 1: glShadeModel(GL_SMOOTH); break;
        default:
            ocaml_gl_warning("Unrecognized mode in ocaml_glShadeModel()\n");
    }
    return Val_unit;
}

value native_ocaml_glOrtho(
        value left, value right, value bot, value top, value znear, value zfar)
{
    glOrtho(Double_val(left), Double_val(right), Double_val(bot), Double_val(top),
        Double_val(znear), Double_val(zfar));
    return Val_unit;
}

value bytecode_ocaml_glOrtho(value * args, int num_args)
{
    native_ocaml_glOrtho(args[0], args[1], args[2], args[3], args[4], args[5]);
    return Val_unit;
}


