#ifndef _ml_glu_
#define _ml_glu_

GLenum GLUenum_val(value tag);

#if !defined(GLU_VERSION_1_2) && !defined(GLU_TESS_WINDING_RULE)
#define GLU_TESS_WINDING_RULE
#define GLU_TESS_WINDING_ODD
#define GLU_TESS_WINDING_NONZERO
#define GLU_TESS_WINDING_POSITIVE
#define GLU_TESS_WINDING_NEGATIVE
#define GLU_TESS_WINDING_ABS_GEQ_TWO
#define GLU_TESS_BOUNDARY_ONLY
#define GLU_TESS_TOLERANCE
#endif

#endif
