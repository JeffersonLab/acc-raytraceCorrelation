#!/bin/tcsh
unset noclobber

# Generate all $DESIGNBEAMLINE and $MODIFIEDBEAMLINE files
./cleanUp.sh unkicked modified > /dev/null

# Store variables as command input or defaults
set N = 10
set SEED = 5
set CORR1 = MBT1S01V
set CORR2 = MBT1S02V
set BPM1 = IPM1S03
set DESIGNBEAMLINE = unkicked
set MODIFIEDBEAMLINE = modified
set VERTICLE = `echo $CORR1 | grep -c "V"`
set BPMERROR = x
set S = `./pullS.sh $BPM1`

set QUAD = $1
set QUADSTRENGTH = $2


# Generate a unit circle and perform a floquet transformation at the specified bpm - *EllipseOne.dat
./setup.sh $BPM1 $N $DESIGNBEAMLINE $VERTICLE $S > /dev/null

# Using the twiss parameters at the given BPM, determine the strengths needed to trace the design ellipse - *Strengths.dat
./determineStrengths.sh $BPM1 $CORR1 $CORR2 $VERTICLE $MODIFIEDBEAMLINE > /dev/null

# Change the strength of CORR to CORRSTRENGTH in the MODIFIEDBEAMLINE.lte file
perl modifyQuad.pl "$MODIFIEDBEAMLINE.lte" "temp.lte" $QUAD $QUADSTRENGTH > /dev/null
mv "temp.lte" "$MODIFIEDBEAMLINE.lte"

# Using the design strengths, trace the ellipse and determine the centroid values - *CentroidValues.dat
./parallelExample.sh $N $MODIFIEDBEAMLINE $CORR1 $CORR2 $VERTICLE > /dev/null

# Determine the transformation matrix M for the modified ellipses - modified.mat
./runParallelPseudoinverse.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE > /dev/null

# Calculate the CHI2DOF between each of the M matrix elements - comparison*.fin
./runParallelCompareM.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE > /dev/null

./sumM.sh >! "sumChi2DOF.dat"

cat "sumChi2DOF.dat"
