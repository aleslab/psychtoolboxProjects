cd C:\Users\aril\Documents\Data
%Need to automate loading and loop it so that multiple files can be
%analysed at once.
load('MoveLine_looming_AL_20160106_144936'); %30 valid trials
%load('MoveLine_looming_AL_20160108_134723'); % 33 trials total; 30 valid trials

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

%Finding the total number of trials for each condition for the valid trials
allTrials = [validCondNumber];
allcond1trials = nnz(allTrials==1);
allcond2trials = nnz(allTrials==2);
allcond3trials = nnz(allTrials==3);
allcond4trials = nnz(allTrials==4);
allcond5trials = nnz(allTrials==5);
allcond6trials = nnz(allTrials==6);

%Calculating the percentage correct for each condition 
cond1PercentCorrect = cond1correct/allcond1trials;
cond2PercentCorrect = cond2correct/allcond2trials;
cond3PercentCorrect = cond3correct/allcond3trials;
cond4PercentCorrect = cond4correct/allcond4trials;
cond5PercentCorrect = cond5correct/allcond5trials;
cond6PercentCorrect = cond6correct/allcond6trials;

% all of the percentage correct values for each condition from 80% of null
% on the left to 120% of the null on the right. percentages in the 
%order: 3 2 1 4 5 6
allPercentageValues = [cond3PercentCorrect cond2PercentCorrect cond1PercentCorrect cond4PercentCorrect cond5PercentCorrect cond6PercentCorrect];
condVelocities = [0.8 0.9 0.95 1.05 1.1 1.2];

%condition 1 is 95% of null
%condition 2 is 90% of null
%condition 3 is 80% of null
%condition 4 is 105% of null
%condition 5 is 110% of null
%condition 6 is 120% of null

%Creating a graph of the percentage correct responses against the 
%velocities as a percentage of the null.
figure
plot(condVelocities, allPercentageValues, '-xk');
axis([0.80 1.20 0 1]);
set(gca, 'YTick', 0:0.1:1);
set(gca, 'YTickLabel', 0:10:100);
xlabel('Velocity as a percentage of the null');
ylabel('Percentage correct responses');


%creating a graph of the percentage correct responses against the
%percentage difference from the velocity of the null.

%condition 1 and 4 are 5% different

fivePerDiffCorrect = cond1correct + cond4correct;
fivePerDiffTotalTrials = allcond1trials + allcond4trials;
fivePerDiffPercentageCorrect = fivePerDiffCorrect/fivePerDiffTotalTrials;

%condition 2 and 5 are 10% different

tenPerDiffCorrect = cond2correct + cond5correct;
tenPerDiffTotalTrials = allcond2trials + allcond5trials;
tenPerDiffPercentageCorrect = tenPerDiffCorrect/tenPerDiffTotalTrials;

%condition 3 and 6 are 20% different

twentyPerDiffCorrect = cond3correct + cond6correct;
twentyPerDiffTotalTrials = allcond3trials + allcond6trials;
twentyPerDiffPercentageCorrect = twentyPerDiffCorrect/twentyPerDiffTotalTrials;

combPercentageTotalValues = [fivePerDiffPercentageCorrect tenPerDiffPercentageCorrect twentyPerDiffPercentageCorrect];
differenceFromNullPercentage = [5 10 20];

figure
plot(differenceFromNullPercentage, combPercentageTotalValues, '-xk');
axis([0 20 0 1]);
set(gca, 'XTick', 0:5:20);
set(gca, 'YTick', 0:0.1:1);
set(gca, 'YTickLabel', 0:10:100);
xlabel('Percentage velocity difference compared to the null condition');
ylabel('Percentage correct responses');

%need to save the original data and the values calculated from it in a file
%along with the plots.
