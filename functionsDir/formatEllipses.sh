#!/bin/tcsh
unset noclobber
# Arguments: $BPMONE $BPMTWO

set BPMONE = $1
set BPMTWO = $2
set TRIAL = $3

set FILEONE = "$CENTROIDPATH/$BPMONE-centroidValues.dat"
set FILETWO = "$CENTROIDPATH/$BPMTWO-centroidValues.dat"

# Reformat the data in a MATLAB readable way
cat $FILETWO | awk '{print $1"\n"$2}' >! $ELLIPSEPATH/ellipseA$TRIAL.fin
cat $FILEONE | awk '{print $1", "$2", 0, 0\n0, 0, "$1", "$2}' >! $ELLIPSEPATH/ellipseB$TRIAL.fin
