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

# Store base variables as command input or defaults
set NUMBEROFSEEDS = $1
set REFERENCEBPM = $2

set FIRSTQUAD = `sed -n -e '/'$REFERENCEBPM'/,$p' $RDPATH/sInformation.dat | grep -m 1 "MQ" | awk '{print $2}'`
set LASTQUAD = `cat $RDPATH/quadList.dat | tail -1`

set FIRSTQUADLINENUMBER = `grep -n $FIRSTQUAD $RDPATH/quadList.dat | cut -f1 -d:`
set LASTQUADLINENUMBER = `grep -n $LASTQUAD $RDPATH/quadList.dat | cut -f1 -d:`

rm "$RDPATH/monteCarloSeeds.dat" >& /dev/null; touch "$RDPATH/monteCarloSeeds.dat"
foreach i (`seq $NUMBEROFSEEDS`)
	set RANDOMNUMBER = `shuf -i $FIRSTQUADLINENUMBER-$LASTQUADLINENUMBER -n 1`
	set RANDOMQUAD = `cat $RDPATH/quadList.dat | head -$RANDOMNUMBER | tail -1`
	echo "$RANDOMQUAD $i" >> "$RDPATH/monteCarloSeeds.dat"
end

gedit "$RDPATH/monteCarloSeeds.dat"
