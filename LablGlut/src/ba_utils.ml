open Bigarray

let float_ba_of_array a =
    let n = (Array.length a) in
    let ba = Array1.create float32 c_layout n in
    for i = 0 to n-1 do
        ba.{i} <- a.(i)
    done;
    ba

let float_ba_of_matrix m =
    let r = (Array.length m) in
    let c = Array.length m.(0) in
    let ba = Array1.create float32 c_layout (r*c) in
    for i = 0 to r-1 do
        for j=0 to c-1 do
            ba.{i*c+j} <- m.(i).(j)
        done
    done;
    ba;;
                                                                                  
let int_ba_of_matrix m =
    let r = (Array.length m) in
    let c = Array.length m.(0) in
    let ba = Array1.create int c_layout (r*c) in
    for i = 0 to r-1 do
        for j=0 to c-1 do
            ba.{i*c+j} <- m.(i).(j)
        done
    done;
    ba;;



