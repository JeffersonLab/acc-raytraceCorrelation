#!/bin/tcsh

unset noclobber
touch quadraticStrengths.dat

set QUAD = `./setArg.sh quad MQB1A29 $argv`
set BPM = `./setArg.sh bpm IPM1A36 $argv`
set LEFTBOUND = `./setArg.sh leftBound -30 $argv`
set RIGHTBOUND = `./setArg.sh rightBound 30 $argv`
set N = `./setArg.sh N 30 $argv`
set M = `./setArg.sh M 3 $argv`
set SEED = `./setArg.sh seed 0 $argv`
set DESIGNBEAMLINE = unkicked
set MODIFIEDBEAMLINE = modified
set DESIGNFILE = $DESIGNBEAMLINE".matasc"
set MODIFIEDFILE = $MODIFIEDBEAMLINE".mat"
set MODIFIEDVALUE = `grep $BPM $MODIFIEDFILE | awk -v M=$M '{print $(2+M)}'`

javac /a/devuser/erict/workspace/Miscellaneous/src/generateQuadraticStrengths.java
java -cp /a/devuser/erict/workspace/Miscellaneous/src/ generateQuadraticStrengths $QUAD $LEFTBOUND $RIGHTBOUND $N $DESIGNBEAMLINE.lte quadraticStrengths.dat

rm quadraticCHI2DOF.dat >& /dev/null
foreach x (`awk '{print $1}' quadraticStrengths.dat`)
	#Change the one quad strength
	java -cp /a/devuser/erict/workspace/Miscellaneous/src/ changeQuadStrength $QUAD $x $DESIGNBEAMLINE.lte $DESIGNBEAMLINE.lte2
	mv $DESIGNBEAMLINE.lte2 $DESIGNBEAMLINE.lte
	elegant $DESIGNBEAMLINE.ele >& /dev/null
	
	sdds2stream -col=ElementName,s,R11,R12,R21,R22,R33,R34,R43,R44 $DESIGNBEAMLINE.mat >! $DESIGNBEAMLINE.matasc
	set DESIGNVALUE = `grep $BPM $DESIGNFILE | awk -v M=$M '{print $(2+M)}'`
	echo "$DESIGNVALUE $MODIFIEDVALUE" | awk -v X=$x '{print X" "($1 - $2)^2}' | tee -a quadraticCHI2DOF.dat
end

./plot.sh quadraticCHI2DOF.dat title=CHI2DOF parabola of $QUAD, xAxisLabel=Strength, yAxisLabel=CHI2DOF,


#javac /a/devuser/erict/workspace/Miscellaneous/src/changeQuadStrength.java

