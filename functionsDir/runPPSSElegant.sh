#!/bin/tcsh
unset noclobber

# Read in inputs #TODO FIX N VALUE
#set N = 5
#set MODIFIEDBEAMLINE = $2
#set CORRONE = $3
#set CORRTWO = $4
#set VERTICLE = $5


# Store variables as command input or defaults
set N = `$FPATH/setArg.sh N 10 $argv`
set SEED = `$FPATH/setArg.sh seed 5 $argv`
set CORRONE = `$FPATH/setArg.sh corr1 MBT1S01V $argv`
set CORRTWO = `$FPATH/setArg.sh corr2 MBT1S02V $argv`
set BPM1 = `$FPATH/setArg.sh bpm1 IPM1S03 $argv`
set DESIGNBEAMLINE = `$FPATH/setArg.sh designBeamline unkicked $argv`
set MODIFIEDBEAMLINE = `$FPATH/setArg.sh modifiedBeamline modified $argv`
set VERTICLE = `echo $CORRONE | grep -c "V"`
set BPMERROR = `$FPATH/setArg.sh bpmError x $argv`
set STRENGTHERROR = `$FPATH/setArg.sh strengthError -1 $argv`


rm elegantFile.ppss >& /dev/null; touch elegantFile.ppss
rm -r elegantPPSSDir >& /dev/null; mkdir elegantPPSSDir

# Build script file
@ x = 1
while ($x <= $N)
	
	set LINE = `cat modifiedStrengths.dat | head -$x | tail -1`
	set CORRSTRENGTHONE = `echo $LINE | awk '{print $1}'`
	set CORRSTRENGTHTWO = `echo $LINE | awk '{print $2}'`

	echo "$CORRONE $CORRSTRENGTHONE $CORRTWO $CORRSTRENGTHTWO $MODIFIEDBEAMLINE $x $VERTICLE" >> elegantFile.ppss

	@ x += 1
end

ppss -f elegantFile.ppss -c "$FPATH/elegantFunction.sh "

exit

# Run scripts

@ x = 1
while ($x <= $N)
	mkdir "Dir$x"
	
	cp "$MODIFIEDBEAMLINE.lte" "Dir$x/$MODIFIEDBEAMLINE.lte"
	cp "$MODIFIEDBEAMLINE.ele" "Dir$x/$MODIFIEDBEAMLINE.ele"
	cp "modifyCorrector.pl" "Dir$x/modifyCorrector.pl"

	set LINE = `cat modifiedStrengths.dat | head -$x | tail -1`
	set CORRSTRENGTHONE = `echo $LINE | awk '{print $1}'`
	set CORRSTRENGTHTWO = `echo $LINE | awk '{print $2}'`

	cd "Dir$x"
	
	if (`expr $x % 10` == 0 || $x == $N) echo "Launching Elegant Call #$x"

	(elegantFunction.sh $CORRONE $CORRSTRENGTHONE $CORRTWO $CORRSTRENGTHTWO $MODIFIEDBEAMLINE $x $VERTICLE &)
	
	cd ..
	@ x += 1
end

# Recompile
