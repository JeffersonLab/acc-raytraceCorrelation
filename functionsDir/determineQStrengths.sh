#!/bin/tcsh
unset noclobber

set DESIGNBEAMLINE = $1
set OUTPUTFILE = $2

#javac /a/devuser/erict/workspace/Miscellaneous/src/determineQStrengths.java
java -cp $JAVAPATH determineQStrengths "$DESIGNBEAMLINE.lte" $OUTPUTFILE
