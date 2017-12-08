#!/bin/tcsh
unset noclobber

set BPMONE = $1
set CORRONE = $2
set CORRTWO = $3
set VERTICLE = $4
set MODIFIEDBEAMLINE = $5

set INFORMATIONFILE = $RDPATH/information.twiasc
set OUTPUTFILE = "modifiedStrengths.dat"
set INPUTELLIPSE = "modifiedEllipseOne.dat"

set ALPHABPM = `grep -w $BPMONE $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(3+verticle)}'`		
set BETAONE = `grep -w $CORRONE $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(5+verticle)}'`		
set BETATWO = `grep -w $CORRTWO $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(5+verticle)}'`		
set BETABPM = `grep -w $BPMONE $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(5+verticle)}'`		
set PSIONE = `grep -w $CORRONE $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(7+verticle)}'`
set PSITWO = `grep -w $CORRTWO $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(7+verticle)}'`	
set PSIBPM = `grep -w $BPMONE $INFORMATIONFILE | awk -v verticle=$VERTICLE '{print $(7+verticle)}'`

# Print twiss information in a form readable to the strength calculator
cat $INPUTELLIPSE | awk -v Abpm=$ALPHABPM -v B1=$BETAONE -v B2=$BETATWO -v Bbpm=$BETABPM -v P1=$PSIONE -v P2=$PSITWO -v Pbpm=$PSIBPM ' {print $1" "$2" "Abpm" "B1" "B2" "Bbpm" "P1" "P2" "Pbpm}' >! "betatronPositions.dat"

echo "determineStrengths.sh - Calculating Quadrupole Strengths"
# calculate necessary kicker strengths and angles to hit each target in the designEllipseOne.dat file - strengths.dat
#javac /a/devuser/erict/workspace/Miscellaneous/src/dxprimeCalculations.java
java -cp $JAVAPATH dxprimeCalculations $OUTPUTFILE