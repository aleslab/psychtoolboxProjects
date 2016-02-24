cd /Users/Abigail/Documents/psychtoolboxProjects/psychMaster/Data
%cd C:\Users\aril\Documents\Data
%Need to automate loading and loop it so that multiple files can be
%analysed at once.
load('MoveLine_combined_away_ALp_20160222_154924');

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

% %Finding the total number of trials for each condition for the valid trials
%allTrials = validCondNumber;
allTrialConditions = unique(validCondNumber); %the conditions for which any response was made
allTrialNumbers = histc(validCondNumber, allTrialConditions); %the total number of responses for each condition

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


%Drawing the graph of percentage "the condition was faster" responses
figure
plot(orderedVelocities, allDepthPercentageCorrect, '-xk');
axis([min(orderedVelocities) max(orderedVelocities) 0 100]);
set(gca, 'Xtick', (min(orderedVelocities)):2.5:(max(orderedVelocities)));
xlabel('Velocity of the first section (cm/s)');
ylabel('Percentage correct responses');
title('towards');

if length(allTrialNumbers) > 7
figure
plot(orderedVelocities, allLateralPercentageCorrect, '-xk');
axis([min(orderedVelocities) max(orderedVelocities) 0 100]);
set(gca, 'Xtick', (min(orderedVelocities)):2.5:(max(orderedVelocities)));
xlabel('Velocity of the first section (cm/s)');
ylabel('Percentage correct responses');
title('lateral');
end
