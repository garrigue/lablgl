#!/bin/sh
# Generate gl_constants.idl and glu_constants.idl.

gl_dir=/usr/include/GL   

echo "Making commands"
grep typedef $gl_dir/gl.h | \
    grep -v '\<void\>' | \
    perl -pe 's/typedef\s+(.*)\s+(\S+)\s*;.*$/s\/\2\/\1\/g/' | \
    perl -pe 's/\bGL/gl_/g' \
    > commands

# This is not really general, but should be fine for our case.
for header in gl glu glut ; do
    constants="$header"_constants
    echo "Making $constants.idl"
    cat $gl_dir/$header.h | \
        grep '#define' | \
        tr 'A-Z' 'a-z' | \
        perl -pe 's/\/\*.*\*\///g' | \
        perl -pe 's/\#define\s+(\S+)\s+(\S+)$/let \1 = \2;;\n/' | \
        perl -pe 's/\(void\*\)//g' | \
        perl -ne 'print if ! /&/' | \
        perl -ne 'print if ! /glut_stroke/i ' | \
        perl -ne 'print if ! /glut_bitmap/i ' | \
        grep '^let.*;;' \
        > $constants.ml
    ocamlc -i $constants.ml 2>&1 | grep -v "I.O error" > $constants.mli 
    cat $constants.mli | \
        perl -ne 'chop; print "quote(mli, \"$_\")\n";' \
        > $constants.idl
    cat $constants.ml | perl -ne 'chop; print "quote(ml, \"$_\")\n";' \
        >> $constants.idl
done

