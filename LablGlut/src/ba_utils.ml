open Bigarray

let float_ba_of_array a =
    let n = (Array.length a) in
    let ba = Array1.create float32 c_layout n in
    for i = 0 to n-1 do
        ba.{i} <- a.(i)
    done;
    ba

let int_ba_of_array a =
    let n = (Array.length a) in
    let ba = Array1.create int c_layout n in
    for i = 0 to n-1 do
        ba.{i} <- a.(i)
    done;
    ba

let float_ba_of_array2 m =
    let r = (Array.length m) in
    let c = Array.length m.(0) in
    let ba = Array2.create float32 c_layout r c in
    for i = 0 to r-1 do
        for j=0 to c-1 do
            ba.{i,j} <- m.(i).(j)
        done
    done;
    ba;;
                                                                                  
let int_ba_of_array2 m =
    let r = (Array.length m) in
    let c = Array.length m.(0) in
    let ba = Array2.create int c_layout r c in
    for i = 0 to r-1 do
        for j=0 to c-1 do
            ba.{i,j} <- m.(i).(j)
        done
    done;
    ba;;

let ubyte_ba_of_array2 m = 
    let r = (Array.length m) in
    let c = Array.length m.(0) in
    let ba = Array2.create int8_unsigned c_layout r c in
    for i = 0 to r-1 do
        for j=0 to c-1 do
            ba.{i,j} <- m.(i).(j)
        done
    done;
    ba;;

let float_ba_of_array3 a =
    let n1 = Array.length a in
    let n2 = Array.length a.(0) in
    let n3 = Array.length a.(0).(0) in
    let ba = Array3.create float32 c_layout n1 n2 n3 in
    for i = 0 to n1-1 do
        for j=0 to n2-1 do
            for k = 0 to n3-1 do
                ba.{i,j,k} <- a.(i).(j).(k)
            done
        done
    done;
    ba;;

let make_luminance_image w h = 
    Array3.create int8_unsigned c_layout h w 1

let make_rgb_image w h = 
    Array3.create int8_unsigned c_layout h w 3

let make_rgba_image w h = 
    Array3.create int8_unsigned c_layout h w 4

let flatten_ba2 ba =
    let n1 = Array2.dim1 ba in
    let n2 = Array2.dim2 ba in
    reshape_1 (genarray_of_array2 ba) (n1 * n2)

let flatten_ba3 ba =
    let n1 = Array3.dim1 ba in
    let n2 = Array3.dim2 ba in
    let n3 = Array3.dim3 ba in
    reshape_1 (genarray_of_array3 ba) (n1 * n2 * n3)

let flatten_image = flatten_ba3

