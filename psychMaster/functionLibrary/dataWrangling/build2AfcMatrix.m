function [ nCorrect nTrials ] = buildNafcMatrix( varargin )
%buildNafcMatrix Pulls out data from ptbCorgiData structure
%function [ nCorrect nTrials ] = build2AfcMatrix( [See Help] )
%   This function pulls out information from a ptbCorgiData structure and
%   makes matrices of the number of correct and number of trials. This
%   makes nAfc psychophysics analysis and data plotting easier. 
% 
%   Input: 
%   Several different inputs are allowed:
%   1) ptbCorgiData structure as returned by ptbCorgiDataBrowser or similar
%      [nC nT] = buildNafcMatrix(ptbCorgiData) 
%
%   2) A session filename (either single or concatenated):
%      [nC nT] = buildNafcMatrix('myExp_ppt_20170101.mat') 
%
%   3) Using the contents of a session file:
%      [nC nT] = buildNafcMatrix(sessionInfo,experimentData) 
%
%   Output:
%   These are matrices sized nParticipants x nConditions
%     nCorrect = Number of trials participant was correct
%     nTrials  = Total number of trials participant responded
%



ptbCorgiData = overloadOpenPtbCorgiData(varargin{:});

%loop over participants
nParticipants = ptbCorgiData.nParticipants;



nCorrect     = NaN(nParticipants,ptbCorgiData.nConditions);
nTrials = NaN(nParticipants,ptbCorgiData.nConditions);

for iPpt = 1:nParticipants,
    
    
    %If the data hasn't been sorted already, lets sort it
    if ~isfield( ptbCorgiData.participantData(1),'sortedTrialData')
        
        thisSortedData = organizeData(ptbCorgiData.participantData(iPpt).sessionInfo,...
            ptbCorgiData.participantData(iPpt).experimentData);
    
    %otherwise just use the sorted data
    else
        thisSortedData = ptbCorgiData.participantData(iPpt).sortedTrialData;
    end
    
    for iCond = 1:ptbCorgiData.nConditions
        
        thisData = thisSortedData(iCond).experimentData;
        
        %Not use of [] to turn elements of structure into vector
        nCorrect(iPpt,iCond) = sum([thisData.isResponseCorrect]);
        nTrials(iPpt,iCond)  = length([thisData.isResponseCorrect]);
        
    end
end

