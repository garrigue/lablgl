#!/bin/sh -x
# c2ml.sh -ijt 2003
bname=`echo $1 | sed 's/\.c$//'`

# Add GL and GLU typedefs
tmpc=`tempfile --suffix .c`
cat /usr/include/GL/gl{,u}.h | grep typedef > $tmpc
cat $bname.c >> $tmpc
echo "open ALL_GL" > $bname.ml
c2ml $tmpc | \
    grep -v 'type GL.*$' | \
    grep -v 'type .*_GLUfuncptr.*$' | \
    perl -pe 's/glutInit\s*\(.*\)\s*;.*$/glutInit2();/' | \
    perl -pe 's#let main argc argv\s*=#let main () =#' | \
    perl -pe 's#(\s*)glutCreateWindow\s*\(\s*argv.\(0\)\s*\)\s*;#\1glutCreateWindow2(Sys.argv.(0));#' | \
    uniq \
    >> $bname.ml
echo "
let _ = main ()" >> $bname.ml
if test "x$EDITOR" = x ; then vi $bname.ml ; else $EDITOR $bname.ml ; fi
tmpml=`tempfile --suffix .ml`
if camlp4 pa_o.cmo pr_o.cmo $bname.ml > $tmpml; then 
    mv $tmpml $bname.ml
fi

