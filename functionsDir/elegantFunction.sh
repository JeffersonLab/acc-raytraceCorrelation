#!/bin/tcsh
unset noclobber

set CORRONE = `echo $1 | awk '{print $1}'`
set CORRSTRENGTHONE = `echo $1 | awk '{print $2}'`
set CORRTWO = `echo $1 | awk '{print $3}'`
set CORRSTRENGTHTWO = `echo $1 | awk '{print $4}'`
set MODIFIEDBEAMLINE = `echo $1 | awk '{print $5}'`
set TRIAL = `echo $1 | awk '{print $6}'`
set VERTICLE = `echo $1 | awk '{print $7}'`

perl $FPATH/modifyCorrector.pl $RDPATH/$MODIFIEDBEAMLINE.lte $ELEGANTPATH/temp.lte $CORRONE $CORRSTRENGTHONE >& /dev/null
perl $FPATH/modifyCorrector.pl $ELEGANTPATH/temp.lte $ELEGANTPATH/$MODIFIEDBEAMLINE$TRIAL.lte $CORRTWO $CORRSTRENGTHTWO >& /dev/null

$FPATH/modifyElegant.sh $MODIFIEDBEAMLINE $TRIAL

# Run elegant on the modified data
(cd $ELEGANTPATH; elegant $MODIFIEDBEAMLINE$TRIAL.ele > /dev/null)

# Save the Cx and Cy values to file
sdds2stream -col=s,ElementName,Cx,Cxp,Cy,Cyp "$ELEGANTPATH/$MODIFIEDBEAMLINE$TRIAL.cen" >! "$ELEGANTPATH/centroidValues$TRIAL.dat"