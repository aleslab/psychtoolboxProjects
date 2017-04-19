function [ ptbCorgiData ] = overloadOpenPtbCorgiData( varargin )
%overloadOpenPtbCorgiData Implements input overloading for ptbCorgiData
%   This is a quick function to implement some overloading.
%   This should get folded into a more data loading method


thisSortedData =[];
try
    
    if nargin == 1
        
        %If input is a string try loading it
        if isstr(varargin{1})
           
            load(varargin{1});
            %If it's a valid ptbCorgi sesssion file it will have the
            %sessionInfo and experimentData structures
            thisSortedData = organizeData(sessionInfo,experimentData);
            
        elseif isstruct(varargin{1})
            ptbCorgiData = varargin{1};
            return;
        end
        
    elseif nargin == 2
        sessionInfo = varargin{1};
        experimentData = varargin{2};
        thisSortedData = organizeData(sessionInfo,experimentData);
        
    end
    
    %Now lets build a ptbCorgiData structure:
if ~isempty(thisSortedData)
    
    ptbCorgiData.paradigmName         = sessionInfo.expInfo.paradigmName;
    ptbCorgiData.participantList      = { sessionInfo.participantID };
    ptbCorgiData.participantErrorList = {};
    ptbCorgiData.nParticipants        = 1;
    ptbCorgiData.conditionInfo        = sessionInfo.conditionInfo;
    ptbCorgiData.nConditions          = length(sessionInfo.conditionInfo);
    ptbCorgiData.participantData.sessionInfo      = sessionInfo;
    ptbCorgiData.participantData.experimentData   = experimentData;
    ptbCorgiData.participantData.participantID    = sessionInfo.participantID;
    ptbCorgiData.participantData.sortedTrialData  = thisSortedData;
    return;
end
    
%If we've reached this point we haven't created ptbCorgiData. Throw error
error('Error loading data')

catch ME
    rethrow(ME)
    error('Error loading data')
end

end

