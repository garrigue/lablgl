#!/bin/sh -x
# c2ml.sh -ijt 2003
bname=`echo $1 | sed 's/\.c$//'`

# Add GL and GLU typedefs
tmpc=`tempfile --suffix .c`
cat /usr/include/GL/gl{,u}.h | grep typedef > $tmpc
cat $bname.c >> $tmpc
c2ml $tmpc | \
    grep -v 'type GL.*$' | \
    grep -v 'type .*_GLUfuncptr.*$'  > $bname.ml
if test "x$EDITOR" = x ; then vi $bname.ml; else $EDITOR $bname.ml ; fi
tmpml=`tempfile --suffix .ml`
if camlp4 pa_o.cmo pr_o.cmo $bname.ml > $tmpml; then 
    # Get the header comments from the original source file and add them to 
    # the new .ml file.
    (c2ml -topcomments $bname.c; \
     cat $tmpml) >  $bname.ml
fi

