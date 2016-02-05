cd /Users/Abigail/Documents/psychtoolboxProjects/psychMaster/Data
%Need to automate loading and loop it so that multiple files can be
%analysed at once.
load('MoveLine_combined_towards_ALp_20160205_115232'); %combined towards data file
%load('MoveLine_looming_towards_ALp_20160205_125604'); %looming towards data file
%load('MoveLine_cd_towards_ALp_20160205_131315'); %cd towards data file
%load('MoveLine_combined_away__20160205_134719'); %combined away data file
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
allTrials = [validCondNumber];
allcond1trials = nnz(allTrials==1);
allcond2trials = nnz(allTrials==2);
allcond3trials = nnz(allTrials==3);
allcond4trials = nnz(allTrials==4);
allcond5trials = nnz(allTrials==5);
allcond6trials = nnz(allTrials==6);
allcond7trials = nnz(allTrials==7);

%In conditions 1-3, the null was the faster stimulus. So for "percentage
%condition is faster" we want the trials that were the incorrect responses.

cond1wrong = allcond1trials - cond1correct;
cond2wrong = allcond1trials - cond2correct;
cond3wrong = allcond1trials - cond3correct;

%Percentage condition was faster responses

cond1per = cond1wrong/allcond1trials;
cond2per = cond2wrong/allcond2trials;
cond3per = cond3wrong/allcond3trials;
cond4per = cond4correct/allcond4trials;
cond5per = cond5correct/allcond5trials;
cond6per = cond6correct/allcond6trials;
cond7per = cond7correct/allcond7trials;

allpercentages = [cond1per cond2per cond3per cond4per cond5per cond6per cond7per];

allvelocities = [0.8 0.9 0.95 1 1.05 1.1 1.2];

%Drawing the graph of percentage "the condition was faster" responses
figure
plot(allvelocities, allpercentages, '-xk');
axis([0.80 1.20 0 1]);
set(gca, 'YTick', 0:0.1:1);
set(gca, 'YTickLabel', 0:10:100);
xlabel('Velocity as a fraction of the null');
ylabel('Percentage "condition was faster" responses');

figure

allcondcorrect = [cond1correct cond2correct cond3correct cond4correct cond5correct cond6correct cond7correct];

plot(allvelocities, allcondcorrect, '-ok');
axis([0.80 1.20 0 30]);
xlabel('Velocity as a fraction of the null');
ylabel('Correct responses for each condition');

