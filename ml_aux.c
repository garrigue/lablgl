/* $Id: ml_aux.c,v 1.6 1998-01-12 05:20:02 garrigue Exp $ */

#include <GL/gl.h>
#include "glaux.h"
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "ml_gl.h"

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
