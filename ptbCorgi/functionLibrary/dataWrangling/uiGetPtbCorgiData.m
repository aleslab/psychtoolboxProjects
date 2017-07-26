function [ ptbCorgiData ] = uiGetPtbCorgiData( chosenDirectory )
%uiGetPtbCorgiData GUI for opening ptbCorgiData projects
%   [ ptbCorgiData ] = uiGetPtbCorgiData( [chosenDirectory] )
%   Displays a GUI that allows the user to browse ptbCorgi data and load an
%   entire project.
%
%   For use in the command window see also: PTBCORGIDATABROWSER
%
%   Returned data is a structure with the fields:
% 
%     paradigmName    = string containing paradigm name.
%     participantList = a cell array with the participant IDs for those  included in the data
%     nParticipants = number of participants. 
%     conditionInfo = conditionInfo structure from the paradigm that was run.
%     nConditions = number of conditions
% 
%     participantData =  A structure with each element being data loaded from a participant 
%                        (i.e. participantData(1) corresponds to data from participantList{1}).
% 
%          sessionInfo      = sessionInfo structure from ptbCorgi
%          experimentData   = experimentData structure from ptbCorgi
%          participantID    = id for this participant. 
%          [sortedTrialData]= Data sorted by condition number as returned from organizeData();



%Using a silly global variable for this wrapper because dataBrowser is a
%GUIDE created GUI and I can't figure out how to make it modal another way.
global ptbCorgiMakeDataBrowserModal

ptbCorgiMakeDataBrowserModal = true;


if nargin <1 
    chosenDirectory = [];
end

%Another guide issue is that the first argument is used for other callback
%use.
try
    ptbCorgiData = ptbCorgiDataBrowser([],chosenDirectory);
catch ME    
    ptbCorgiMakeDataBrowserModal = false;
    ptbCorgiData = [];
    rethrow(ME)
end
    ptbCorgiMakeDataBrowserModal = false;
end

