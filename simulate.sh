#!/bin/tcsh
unset noclobber

#* Description: Main file used to perform all control optimization funcntions. Generates a Unit Circle, transforms to a betatron ellipse,calculates the strengths necessary to trace the points on the ellipse,
#* Description: Adds strenght error if necessary, traces the betatron ellipse given the calculated strengths, performs SVD pseudoinverse to determine transformation matrices,
#* Description: Calculates CHI2DOF for those transformation matrices, identifies problematic quadrupole, then optimizes the quadrupole strength to correct the beams orbit
#* Argument: N - Number of orbits to include in the simulation
#* Argument: SEED - Seed used to generate consistent random numbers. Should be set to 0 to not use a seed
#* Argument: CORR1 - Name of the first quadrupole which is manipulated to trace out each orbit
#* Argument: CORR2 - Name of the second quadrupole which is manipulated to trace out each orbit
#* Argument: BPM1 - Name of the BPM whose Twiss parameters are used for the initial inverse Floquet Transformation
#* Argument: DESIGNBEAMLINE - Name of the unmodified 'design' beamline
#* Argument: MODIFIEDBEAMLINE - Name of the beamline which will have components modified throughout the process - ele, lte
#* Argument: STRENGTHERROR - Percentage that the strength of a given quadrupole will be modified by. EX, -1 means change the sign on the strength
#* Example: ./simulate.sh N=10, seed=5, corr1=MBT1S01V, corr2=MBT1SO2V, bpm1=IPM1S03, designBeamline=unkicked, modifiedBeamline=modified, strengthError=-1,;
#* Further Comments: Variables stored within a script are all upper case, however variables passed in from the command line assume camel casing
#* Main Output: Quadrupole strength change values

# Store variables as command input or defaults
set N = `$FPATH/setArg.sh N 10 $argv`
set SEED = `$FPATH/setArg.sh seed 5 $argv`
set CORR1 = `$FPATH/setArg.sh corr1 MBT1S01V $argv`
set CORR2 = `$FPATH/setArg.sh corr2 MBT1S02V $argv`
set BPM1 = `$FPATH/setArg.sh bpm1 IPM1S03 $argv`
set DESIGNBEAMLINE = `$FPATH/setArg.sh designBeamline unkicked $argv`
set MODIFIEDBEAMLINE = `$FPATH/setArg.sh modifiedBeamline modified $argv`
set VERTICLE = `echo $CORR1 | grep -c "V"`
set STRENGTHERROR = `$FPATH/setArg.sh strengthError -1 $argv`
set TESTQUAD = `$FPATH/setArg.sh testQuad MQB1A29 $argv`
set REFERENCEBPM = `$FPATH/setArg.sh referenceBPM IPM1R02 $argv`

# Remove all excess data files from the main directory, and auxillary folders in preparation for a new run
$FPATH/cleanUp.sh
set S = `$FPATH/pullS.sh $BPM1 $DESIGNBEAMLINE`

# Print all of the above variables to the terminal
echo "\nN = $N\nSeed = $SEED\ncorr1 = $CORR1\ncorr2 = $CORR2\nbpm1 = $BPM1\ndesignBeamline = $DESIGNBEAMLINE\nmodifiedBeamline = $MODIFIEDBEAMLINE\nverticle = $VERTICLE\nstrengthError = $STRENGTHERROR\ntestQuad = $TESTQUAD\nreferenceBPM = $REFERENCEBPM\n"

# Generate a unit circle and perform a floquet transformation at the specified bpm
# Output: $MODIFIEDBEAMLINE"EllipseOne.dat" - Coordinate pairs of design betatron ellipse
$FPATH/setup.sh $BPM1 $N $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE $S

# Using the twiss parameters at the given BPM, determine the strengths needed to trace the design ellipse
# Output: $MODIFIEDBEAMLINE"Strengths.dat"
$FPATH/determineStrengths.sh $BPM1 $CORR1 $CORR2 $VERTICLE $MODIFIEDBEAMLINE

# Add scalar error to Quadrupole Strengths if applicable
if ($STRENGTHERROR != x) then
	echo "addStrengthError.sh - Adding strength error"
	set NEWQUADSTRENGTH = `$FPATH/addStrengthError.sh $TESTQUAD $STRENGTHERROR $MODIFIEDBEAMLINE $SEED`
endif

# Using the design strengths, trace the ellipse and determine the centroid values
# Output: centroidValuesDir/*BPM*CentroidValues.dat
$FPATH/runPPSSElegant.sh $N $MODIFIEDBEAMLINE $CORR1 $CORR2 $VERTICLE

# Use a Singular Value Decomposition Pseudoinverse to generate the two sets of transportation matrices
# Output: $DESIGNBEAMLINE.matasc $MODIFIEDBEAMLINE.mat
$FPATH/runPPSSPseudoinverse.sh $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE

# Sanity check to ensure that modified values do not vary wildly from the design
$FPATH/sanityCheck.sh $MODIFIEDBEAMLINE"EllipseOne.dat" $BPM1"CentroidValues.dat" $BPM1 $N $VERTICLE #"plot"

# Output: $CHI2PATH/comparisons.fin
$FPATH/runPPSSCompareM.sh $BPM1 $DESIGNBEAMLINE.matasc $MODIFIEDBEAMLINE.mat
#$FPATH/catPPSSOutput.sh

#TODO possibly add another sanity check here plotting the parabola and M values

if ($STRENGTHERROR != x) then

	#TODO copy any necessary files into the optimization directory
	cp $RDPATH/$DESIGNBEAMLINE.lte $OPTIMIZEPATH/$DESIGNBEAMLINE.lte
	cp $RDPATH/$DESIGNBEAMLINE.ele $OPTIMIZEPATH/$DESIGNBEAMLINE.ele
	mv $MODIFIEDBEAMLINE.mat $OPTIMIZEPATH/$MODIFIEDBEAMLINE.mat

	echo "Target strength = $NEWQUADSTRENGTH"
	echo "function.sh - Setting $TESTQUAD to $NEWQUADSTRENGTH to determine ideal chi2dof"
	$FPATH/function.sh $TESTQUAD $NEWQUADSTRENGTH $REFERENCEBPM $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE

	#Re-calculating Transportation matrix comparisons
	# Output: $CHI2PATH/comparisons.fin
	$FPATH/runPPSSCompareM.sh $BPM1 $OPTIMIZEPATH/$DESIGNBEAMLINE.matasc $OPTIMIZEPATH/$MODIFIEDBEAMLINE.mat

	echo "findOutlier.sh - Finding and removing outlier before optimization"
	$FPATH/findOutlier.sh 3 $CHI2PATH/comparisons.fin remove

	echo "optimize.sh - Optimizing Beamline"
	$FPATH/optimize.sh $TESTQUAD $REFERENCEBPM $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE "$FPATH/function.sh"

#	./plotM.sh M=3,title=Fixed Chi2dof of M with outlier removed,
	$FPATH/runPPSSCompareM.sh $BPM1 $OPTIMIZEPATH/$DESIGNBEAMLINE.matasc $OPTIMIZEPATH/$MODIFIEDBEAMLINE.mat
	
	echo "findOutlier.sh - Finding and removing outlier after optimization"
	$FPATH/findOutlier.sh 3 $CHI2PATH/comparisons.fin remove
#	./plotM.sh M=3,title=Optimized Chi2dof of M with outlier removed,
endif

#TODO MAKE SURE THIS CALL IS CORRECT
#TODO comment changeVResponse.sh
#$FPATH/changeVResponse.sh #TODO add proper arguments

#TODO comment determineQuadStrength.sh
#$FPATH/determineQuadStrengths.sh #TODO add proper arguments

#$FPATH/plot.sh #TODO add proper arguments $BETATRONFILE title=Initial Betatron Ellipse, xAxisLabel=X, yAxisLabel=xPrime,
