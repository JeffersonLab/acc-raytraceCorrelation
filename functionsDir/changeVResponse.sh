#!/bin/tcsh
unset noclobber

#* Description:
#* Argument: - 
#* Argument: - 
#* Argument: - 
#* Argument: - 
#* Argument: - 
#* Example: 
#* Further Comments: 
#* Further Comments: 
#* Main Output:

# Set variables from command line arguments
set N = `$FPATH/setArg.sh N 10 $argv`
set SEED = `$FPATH/setArg.sh seed 5 $argv`
set CORR1 = `$FPATH/setArg.sh corr1 MBT1S01V $argv`
set CORR2 = `$FPATH/setArg.sh corr2 MBT1S02V $argv`
set BPM1 = `$FPATH/setArg.sh bpm1 IPM1S03 $argv`
set DESIGNBEAMLINE = `$FPATH/setArg.sh designBeamline unkicked $argv`
set MODIFIEDBEAMLINE = `$FPATH/setArg.sh modifiedBeamline modified $argv`
set CHANGEM = `$FPATH/setArg.sh changeM 3 $argv`

set DESIGNLATTICE = "$RDPATH/$DESIGNBEAMLINE.lte"
set DESIGNTWISSFILE = "$RDPATH/$DESIGNBEAMLINE.twi"

# Remove all excess data files from the main directory, and auxillary folders in preparation for a new run
$FPATH/cleanUp.sh "change"

# Searches through the given lattice file for the quadrupole with the largest absolute strength, and adds one percent of that strength to all other quadrupoles on the same beamline
# Output: $CHANGEPATH/"quadStrengths.dat"
$FPATH/determineQStrengths.sh $DESIGNLATTICE $CHANGEPATH/"quadStrengths.dat"

# Determine how many quadrupoles exist on the given beamline
@ THRESHOLD = `sdds2stream -col=ElementName $DESIGNTWISSFILE | grep -c "MQ"`

# For each Quadrupole in the design twiss file, determine the chi2dof response from changing its design strength to the modified one in $CHANGEPATH/"quadStrengths.dat"
@ x = 1
foreach i (`sdds2stream -col=ElementName $DESIGNTWISSFILE | grep "MQ"`)
	
	echo "********************************************Determining Sum CHI2DOF for $i********************************************"

	set STRENGTH = `cat $CHANGEPATH/"quadStrengths.dat" | head -$x | tail -1`
	$JPATH/simulate.sh "N=$N, seed=$SEED, corr1=$CORR1, corr2=$CORR2, bpm1=$BPM1, designBeamline=$DESIGNBEAMLINE, modifiedBeamline=$MODIFIEDBEAMLINE, change=1, changeQuad=$i, changeQuadStrength=$STRENGTH, changeM=$CHANGEM,"

	@ x += 1
end

exit

set DONECOUNT = `ls cDir* | grep -c "sumChi2DOF.dat"`

while ($DONECOUNT != $THRESHOLD)
	echo "Done count: $DONECOUNT / $THRESHOLD"
	set DONECOUNT = `ls cDir* | grep -c "sumChi2DOF.dat"`
	sleep 5
end

echo "$DONECOUNT Done!"

rm "response.dat" >& /dev/null
touch "response.dat"
foreach i (`sdds2stream -col=ElementName $DESIGNBEAMLINE.twi | grep "MQ"`)
	cat "cDir$i/sumChi2DOF.dat" | awk -v bpm=$i '{print bpm" "$1}' >> "response.dat"
end

gedit "response.dat"

#rm -r cDir* >& /dev/null
