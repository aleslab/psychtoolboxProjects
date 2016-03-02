%cd /Users/Abigail/Documents/psychtoolboxProjects/psychMaster/Data
cd C:\Users\aril\Documents\Data
%Need to automate loading and loop it so that multiple files can be
%analysed at once.
load('');

message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
ParOrNonPar = input(message);
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
correctTrials = validCondNumber(correctResponsesLogical); %the conditions of each individual correct response
correctTrialConditions = unique(correctTrials); %the conditions for which a correct response was made
condCorrectNumbers = histc(correctTrials, correctTrialConditions); %the total number of correct responses for each condition 
depthCorrectNumbers = condCorrectNumbers(1:7);

% %Finding the total number of trials for each condition for the valid trials
%allTrials = validCondNumber;
allTrialConditions = unique(validCondNumber); %the conditions for which any response was made
allTrialNumbers = histc(validCondNumber, allTrialConditions); %the total number of responses for each condition
depthTrialNumbers = allTrialNumbers(1:7);
allCorrectPercentages = (condCorrectNumbers./allTrialNumbers)*100; %creates a double of the percentage correct responses for every condition

if length(allTrialNumbers) > 7
allDepthPercentageCorrect = allCorrectPercentages(1:7);
allLateralPercentageCorrect = allCorrectPercentages(8:14);
else
    allDepthPercentageCorrect = allCorrectPercentages;
end

conditionFirstSectionVelocities = [sessionInfo.conditionInfo.velocityCmPerSecSection1];
FirstVelocities = unique(conditionFirstSectionVelocities);
%get rid of negative sign as it doesn't matter which direction the condition was here.
if min(FirstVelocities) < 0;
    normalisedFirstVelocities = FirstVelocities*-1;
    orderedVelocities = fliplr(normalisedFirstVelocities);
else
    normalisedFirstVelocities = FirstVelocities;
    orderedVelocities = normalisedFirstVelocities;
end
%% Psychometric function fitting adapted from PAL_PFML_Demo

tic

%Use the Logistic function
PF = @PAL_CumulativeNormal;  

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
 
%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 20:.01:35;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;  %ditto

%Perform fit
disp('Fitting function.....');
[paramsValues, LL, exitflag] = PAL_PFML_Fit(orderedVelocities,depthCorrectNumbers, ...
    depthTrialNumbers,searchGrid,paramsFree,PF);

disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);

%Number of simulations to perform to determine standard error
B=400;                  

disp('Determining standard errors.....');

if ParOrNonPar == 1
    [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(...
        orderedVelocities, depthTrialNumbers, paramsValues, paramsFree, B, PF, ...
        'searchGrid', searchGrid);
else
    [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapNonParametric(...
        orderedVelocities, depthCorrectNumbers, depthTrialNumbers, [], paramsFree, B, PF,...
        'searchGrid',searchGrid);
end

disp('done:');
message = sprintf('Standard error of Threshold: %6.4f',SD(1));
disp(message);
message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
disp(message);

%Number of simulations to perform to determine Goodness-of-Fit
B=1000;

disp('Determining Goodness-of-fit.....');

[Dev, pDev] = PAL_PFML_GoodnessOfFit(orderedVelocities, depthCorrectNumbers, depthTrialNumbers, ...
    paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid);

disp('done:');

%Put summary of results on screen
message = sprintf('Deviance: %6.4f',Dev);
disp(message);
message = sprintf('p-value: %6.4f',pDev);
disp(message);
 
%Create simple plot
ProportionCorrectObserved=depthCorrectNumbers./depthTrialNumbers; 
StimLevelsFineGrain=[min(orderedVelocities):max(orderedVelocities)./1000:max(orderedVelocities)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
figure('name','Maximum Likelihood Psychometric Function Fitting');
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 .7 0],'linewidth',4);
plot(orderedVelocities,ProportionCorrectObserved,'-k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',orderedVelocities);
axis([min(orderedVelocities) max(orderedVelocities) .4 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');

toc