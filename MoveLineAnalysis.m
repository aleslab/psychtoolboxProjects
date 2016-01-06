cd C:\Users\aril\Documents\Data
load('MoveLine_looming_AL_20160106_144936'); %30 valid trials
%load('MoveLine_looming_al_20151218_161153'); %A mix of invalid and valid trials, 19 total.

%Need to find a way to exclude rows in the struct that are for invalid trials.

responseTable = struct2table(experimentData);
invalidTrialsInTable = ismissing(responseTable(:,2));


%validResponseTable = struct2table(experimentData); %table of only the valid responses

correctTrials = validResponseTable.condNumber(validResponseTable.isResponseCorrect);
cond1correct = nnz(correctTrials==1);
cond2correct = nnz(correctTrials==2);
cond3correct = nnz(correctTrials==3);
cond4correct = nnz(correctTrials==4);
cond5correct = nnz(correctTrials==5);
cond6correct = nnz(correctTrials==6);

allTrials = [validResponseTable.condNumber];
allcond1trials = nnz(allTrials==1);
allcond2trials = nnz(allTrials==2);
allcond3trials = nnz(allTrials==3);
allcond4trials = nnz(allTrials==4);
allcond5trials = nnz(allTrials==5);
allcond6trials = nnz(allTrials==6);

cond1PercentCorrect = cond1correct/allcond1trials;
cond2PercentCorrect = cond2correct/allcond2trials;
cond3PercentCorrect = cond3correct/allcond3trials;
cond4PercentCorrect = cond4correct/allcond4trials;
cond5PercentCorrect = cond5correct/allcond5trials;
cond6PercentCorrect = cond6correct/allcond6trials;

allPercentageValues = [cond3PercentCorrect cond2PercentCorrect cond1PercentCorrect cond4PercentCorrect cond5PercentCorrect cond6PercentCorrect];
condVelocities = [0.8 0.9 0.95 1.05 1.1 1.2];

%condition 1 is 95% of null
%condition 2 is 90% of null
%condition 3 is 80% of null
%condition 4 is 105% of null
%condition 5 is 110% of null
%condition 6 is 120% of null

% plot percentages in the order: 3 2 1 4 5 6

figure
plot(condVelocities, allPercentageValues, '-xk');
axis([0.80 1.20 0 1]);
set(gca, 'YTick', 0:0.1:1);
set(gca, 'YTickLabel', 0:10:100);
xlabel('Velocity as a percentage of the null');
ylabel('Percentage correct');

