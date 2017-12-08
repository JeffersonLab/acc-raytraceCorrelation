#!/bin/tcsh
unset noclobber

# Store variables as command input or defaults
set N = `setArg.sh N 10 $argv`
set SEED = `setArg.sh seed 5 $argv`
set CORR1 = `setArg.sh corr1 MBT1S01V $argv`
set CORR2 = `setArg.sh corr2 MBT1S02V $argv`
set BPM1 = `setArg.sh bpm1 IPM1S03 $argv`
set DESIGNBEAMLINE = `setArg.sh designBeamline unkicked $argv`
set MODIFIEDBEAMLINE = `setArg.sh modifiedBeamline modified $argv`
set VERTICLE = `echo $CORR1 | grep -c "V"`
set BPMERROR = `setArg.sh bpmError x $argv`
set STRENGTHERROR = `setArg.sh strengthError -1 $argv`

cleanUp.sh $DESIGNBEAMLINE $MODIFIEDBEAMLINE
set S = `pullS.sh $BPM1 $DESIGNBEAMLINE`

echo "\nN = $N\nSeed = $SEED\ncorr1 = $CORR1\ncorr2 = $CORR2\nbpm1 = $BPM1\ndesignBeamline = $DESIGNBEAMLINE\nmodifiedBeamline = $MODIFIEDBEAMLINE\nverticle = $VERTICLE\nbpmError = $BPMERROR\nstrengthError = $STRENGTHERROR\n"

# Generate a unit circle and perform a floquet transformation at the specified bpm - *EllipseOne.dat
setup.sh $BPM1 $N $DESIGNBEAMLINE $VERTICLE $S

# Using the twiss parameters at the given BPM, determine the strengths needed to trace the design ellipse - *Strengths.dat
determineStrengths.sh $BPM1 $CORR1 $CORR2 $VERTICLE $MODIFIEDBEAMLINE

# Add scalar error to Quadrupole Strengths if applicable - Edit *-centroidValues.dat
if ($STRENGTHERROR != x) then
	echo "addStrengthError.sh - Adding strength error"
	set NEWQUADSTRENGTH = `addStrengthError.sh MQB1A29 $STRENGTHERROR $MODIFIEDBEAMLINE $SEED`
endif

# Using the design strengths, trace the ellipse and determine the centroid values - *CentroidValues.dat
runParallelElegant.sh $N $MODIFIEDBEAMLINE $CORR1 $CORR2 $VERTICLE

# Determine the transformation matrix M for the modified ellipses - modified.mat
runParallelPseudoinverse.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE

# Calculate the CHI2DOF between each of the M matrix elements - comparison*.fin
runParallelCompareM.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE



#./plotPhase.sh $BPM1 $N $VERTICLE,
#./plotM.sh M=3,title=Pre-Corrected Chi2dof of M,
#./findOutlier.sh 3 remove
#./plotM.sh M=3,title=Outlier removed Pre-Corrected Chi2dof of M,

#./plotParabola.sh N=50,

if ($STRENGTHERROR != x) then
	echo "Target strength = $NEWQUADSTRENGTH"
	echo "Function"
	function.sh MQB1A29 $NEWQUADSTRENGTH "IPM1R02" $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE
	echo "runParallelCompareM"
	runParallelCompareM.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE
	echo "Find Outlier"
	findOutlier.sh 3 remove
#	./plotM.sh M=3,title=Fixed Chi2dof of M with outlier removed,
	echo "Optimize"
	optimize.sh MQB1A29 "IPM1R02" $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE
	echo "runParallelCompareM"
	runParallelCompareM.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE
	echo "FindOutlier"
	findOutlier.sh 3 remove
#	./plotM.sh M=3,title=Optimized Chi2dof of M with outlier removed,
endif