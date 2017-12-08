#!/bin/tcsh
unset noclobber

# Store variables as command input or defaults
set BPMONE = `echo $1 | awk '{print $1}'`
set BPMTWO = `echo $1 | awk '{print $2}'`
set S = `echo $1 | awk '{print $3}'`
set TRIAL = `echo $1 | awk '{print $4}'`

# Reformat ellipseA.dat and ellipseB.dat in a MATLAB readable way - ellipseA.fin ellipseB.fin
$FPATH/formatEllipses.sh $BPMONE $BPMTWO $TRIAL

# Perform SVD and pseduo inverse on the matrixes - ellipseA2.fin
python $FPATH/determineTransformationMatrix.py $TRIAL $ELLIPSEPATH

echo `cat $ELLIPSEPATH/ellipseC$TRIAL.fin` >! $ELLIPSEPATH/temp$TRIAL.dat
set DETERMINANT = `cat $ELLIPSEPATH/temp$TRIAL.dat | awk '{print ($1*$4 - $2*$3)}'`

echo "$BPMTWO $S `cat $ELLIPSEPATH/ellipseC$TRIAL.fin` Determinant: $DETERMINANT" >! "$ELLIPSEPATH/mValues$TRIAL.dat"

rm $ELLIPSEPATH/ellipse*$TRIAL.fin $ELLIPSEPATH/temp$TRIAL.dat >& /dev/null
