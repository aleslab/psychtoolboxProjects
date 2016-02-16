cd /Users/Abigail/Documents/psychtoolboxProjects/psychMaster/Data
%cd C:\Users\aril\Documents\Data
%Need to automate loading and loop it so that multiple files can be
%analysed at once.
load('');
ResponseTable = struct2table(experimentData); %The data struct is converted to a table

%excluding invalid trials
wantedData = ~(ResponseTable.validTrial == 0); %creates a logical of which trials in the data table were valid
validIsResponseCorrect = ResponseTable.isResponseCorrect(wantedData); %
validCondNumber = ResponseTable.condNumber(wantedData);
if iscell(validIsResponseCorrect) %if this is a cell because there were invalid responses
    correctResponsesArray = cell2mat(validIsResponseCorrect); %convert to an array 
    correctResponsesLogical = logical(correctResponsesArray); %then convert to a logical
else
    correctResponsesLogical = logical(validIsResponseCorrect); %immediately convert to a logical
end

%Calculating the number of correct responses for each condition for the
%valid trials
correctTrials = validCondNumber(correctResponsesLogical);
cond1correct = nnz(correctTrials==1);
cond2correct = nnz(correctTrials==2);
cond3correct = nnz(correctTrials==3);
cond4correct = nnz(correctTrials==4);
cond5correct = nnz(correctTrials==5);
cond6correct = nnz(correctTrials==6);
cond7correct = nnz(correctTrials==7);

%Finding the total number of trials for each condition for the valid trials
allTrials = validCondNumber;
allcond1trials = nnz(allTrials==1);
allcond2trials = nnz(allTrials==2);
allcond3trials = nnz(allTrials==3);
allcond4trials = nnz(allTrials==4);
allcond5trials = nnz(allTrials==5);
allcond6trials = nnz(allTrials==6);
allcond7trials = nnz(allTrials==7);

%Percentage condition was correct response

cond1per = (cond1correct/allcond1trials)*100;
cond2per = (cond2correct/allcond2trials)*100;
cond3per = (cond3correct/allcond3trials)*100;
cond4per = (cond4correct/allcond4trials)*100;
cond5per = (cond5correct/allcond5trials)*100;
cond6per = (cond6correct/allcond6trials)*100;
cond7per = (cond7correct/allcond7trials)*100;

allPercentageCorrect = [cond1per cond2per cond3per cond4per cond5per cond6per cond7per];

allFirstSectionVelocities = [sessionInfo.conditionInfo.velocityCmPerSecSection1];
%So you look at the speed rather than the velocity -- get rid of negative
%sign as it doesn't matter which direction the condition was here and it'll flip the
%graph if it's there.
if min(allFirstSectionVelocities) < 0;
    normalisedFirstSectionVelocities = allFirstSectionVelocities*-1;
else
    normalisedFirstSectionVelocities = allFirstSectionVelocities;
end
%Drawing the graph of percentage "the condition was faster" responses
figure
plot(normalisedFirstSectionVelocities, allPercentageCorrect, '-xk');
axis([min(normalisedFirstSectionVelocities) max(normalisedFirstSectionVelocities) 0 100]);
xlabel('Velocity of the first section (cm/s)');
ylabel('Percentage correct responses');
title('AL combined towards');
