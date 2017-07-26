function [conditionInfo,expInfo] = pdgm_orientation_2afc_groupExample(expInfo)
%This is an example paradigm file that implements an orienatation
%discrimination task. 


%Instead of copy/pasting settings we can use other paradigm files to
%initialize the settings.  This is useful if you have a series of
%experiments that all use some common settings. Common things are instructions
%and fixation crosses. 
%In this case instead of copying the entire orientation discrimination
%experiment into this file we're just calling the function to initialize
%this experiment.  That way this code can focus on the specifics for making
%groups of conditions
[conditionInfo, expInfo] = pdgm_orientation_2afc(expInfo);
conditionTemplate = conditionInfo(1); %Take the first condition as the template


%Now we'll build up the conditions
%First we create a list of orientations
%These are negative (-) because a negative orientation change is clockwise
%That makes the task consistent with the instructions. If the 2nd stimulus
%is clockwise (negative) from 1st press 'j'. 
orientationDeltaList = linspace(-1,-10,10); 

%Next we'll setup a list of contrasts using a log spacing of contrasts 
%with 3 values from 5% to 95%. 
%NB: logspace matlab is incosistent with other matlab functions, Example it
%is base 10, log is base e.
contrastList = logspace(log10(.05),log10(.95),3);


%Now lets take the template condition created above and create our set of
%conditions. This will create a fully crossed experiment with all
%orientation changes repeated for each contrast level.
%When crossing the conditions are created with the first list changing
%quickly. That is, for the below example it creates 10 orienations at the
%first contrast level, then 10 and the next contrast
conditionInfo = createConditionsFromParamList(conditionTemplate,'crossed',...
   'targetDelta',orientationDeltaList, 'contrast',contrastList);

%Finally, in order for ptbCorgi to know how to group conditions we need to
%define the grouping field.  In this case we are going to group conditions
%by contrast. 
expInfo.conditionGroupingField = 'contrast';



end












