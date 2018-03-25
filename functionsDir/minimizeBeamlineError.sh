#!/bin/tcsh
unset noclobber
unset COLORS

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
set N = `$FPATH/setArg.sh N 10 $argv`
set SEED = `$FPATH/setArg.sh seed 5 $argv`
set CORR1 = `$FPATH/setArg.sh corr1 MBT1S01V $argv`
set CORR2 = `$FPATH/setArg.sh corr2 MBT1S02V $argv`
set BPM1 = `$FPATH/setArg.sh bpm1 IPM1S03 $argv`
set DESIGNBEAMLINE = `$FPATH/setArg.sh designBeamline unkicked $argv`
set MODIFIEDBEAMLINE = `$FPATH/setArg.sh modifiedBeamline modified $argv`
set VERTICLE = `echo $CORR1 | grep -c "V"`

# These variables are only referenced if there is optimization needed
set STRENGTHERROR = `$FPATH/setArg.sh strengthError x $argv`
set TESTQUAD = `$FPATH/setArg.sh testQuad MQB1A29 $argv`

# Set variables controlling changeVResponse.sh script behavior
set CHANGEM = `$FPATH/setArg.sh changeM 3 $argv`
set GENERATE = `$FPATH/setArg.sh generate 0 $argv`
set TOLERANCE = `$FPATH/setArg.sh tolerance 1 $argv`
set MAXTRIALS = `$FPATH/setArg.sh maxTrials 5 $argv`

set MONTECARLO = `$FPATH/setArg.sh monteCarlo x $argv`

if ($MONTECARLO != x) then
	while (`wc -l "$RDPATH/monteCarloSeeds.dat" | awk '{print $1}'` > 0)
		set TESTQUAD = `cat "$RDPATH/monteCarloSeeds.dat" | head -1 | tail -1 | awk '{print $1}'`
		set SEED = `cat "$RDPATH/monteCarloSeeds.dat" | head -1 | tail -1 | awk '{print $2}'`
		
		echo "*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/$TESTQUAD-$SEED*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/" | tee -a "$RDPATH/testLog.fin"
		$FPATH/correct.sh $N $SEED $CORR1 $CORR2 $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE $STRENGTHERROR $TESTQUAD $CHANGEM $GENERATE $TOLERANCE $MAXTRIALS | tee -a "$RDPATH/testLog.fin"

		#Remove the minimization attempt that just finished
		cutLineOffTopOrBottom.sh top 1 "$RDPATH/monteCarloSeeds.dat"
	end	
else
	$FPATH/correct.sh $N $SEED $CORR1 $CORR2 $BPM1 $DESIGNBEAMLINE $MODIFIEDBEAMLINE $VERTICLE $STRENGTHERROR $TESTQUAD $CHANGEM $GENERATE $TOLERANCE $MAXTRIALS
endif
