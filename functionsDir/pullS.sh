#!/bin/tcsh
unset noclobber

#* Description: Used to print the S coordinate of a given BPM
#* Argument: $1 - BPM - Name of the BPM whose S coordinate is needed
#* Argument: $2 - DESIGNBEAMLINE - Root name of the unmodified beamline
#* Example: set S = `$FPATH/pullS.sh $BPM1 $DESIGNBEAMLINE`

set BPM = $1
set DESIGNBEAMLINE = $2

grep -w $BPM ~/git/JeffersonLabWork/rawDataDir/sInformation.dat | awk '{print $1}'


