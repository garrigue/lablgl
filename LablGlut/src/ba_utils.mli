val float_ba_of_array :
  float array ->
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t
val float_ba_of_matrix :
  float array array ->
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t
val int_ba_of_matrix :
  int array array ->
  (int, Bigarray.int_elt, Bigarray.c_layout) Bigarray.Array1.t
val ubyte_ba_of_matrix :
  int array array ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
