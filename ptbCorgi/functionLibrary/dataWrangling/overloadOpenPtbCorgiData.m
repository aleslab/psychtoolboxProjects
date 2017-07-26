function [ ptbCorgiData ] = overloadOpenPtbCorgiData( varargin )
%overloadOpenPtbCorgiData Implements input overloading for ptbCorgiData
%
%[ ptbCorgiData ] = overloadOpenPtbCorgiData( varargin )
%  This is an important function that abstracts loading datafiles into a
%  single place and implements multiple ways to load data. It will sort and
%  organize data to make project level management simpler. 
%
%  There are multiple ways to specify the input data:
%
%   1) ptbCorgiData structure as returned by ptbCorgiDataBrowser or
%   similar. This may seem silly, but it allows people to preload data in
%   scripts and call multiple functions without repeated loading data. That
%   enables this one function to be used in many functions to handle data
%   loading. 
%
%      [ptbCorgiData] = overloadOpenPtbCorgiData(ptbCorgiData) 
%
%   2) A single session filename (either single or a concatenated session):
%      [ptbCorgiData] = overloadOpenPtbCorgiData('myExp_ppt_20170101.mat'); 
%
%   3) A cell array of session files:
%      fileList = {'/path/to/data1.mat' ...
%                    '/path/to/data2.mat' };
%     [ptbCorgiData] = overloadOpenPtbCorgiData(fileList);
%
%   4) Using the contents of a session file:
%    [ptbCorgiData] = overloadOpenPtbCorgiData(sessionInfo,experimentData);
%
%   5) An empty input launches the databrowser GUI:
%      [ptbCorgiData] = overloadOpenPtbCorgiData();
%
%  Output is a ptbCorgiData structure see HELP TO BE WRITTEN for
%  description
%

%TODO: Decide if errors should throw errors or return empty arrays. 

thisSortedData =[];

try
    
    %Here's a nasty if/else block for dealing with different input arguments. 
    if nargin == 0 || isempty(varargin{1}) 
        ptbCorgiData = uiGetPtbCorgiData();
        return;
    elseif nargin == 1
        
        %If input is a string try loading it
        if isstr(varargin{1})
            
            load(varargin{1});
            %If it's a valid ptbCorgi sesssion file it will have the
            %sessionInfo and experimentData structures
            thisSortedData = organizeData(sessionInfo,experimentData);
            
        elseif iscellstr(varargin{1})
            ptbCorgiData = loadFileList( varargin{1});
            return;
        elseif isstruct(varargin{1})
            ptbCorgiData = varargin{1};
            return;
        else
            error('ptbCorgi:overloadOpen:incorrectInput','Input is not in a recognized format')
        end
        
    elseif nargin == 2
        sessionInfo = varargin{1};
        experimentData = varargin{2};
        thisSortedData = organizeData(sessionInfo,experimentData);
    else
        error('ptbCorgi:overloadOpen:incorrectInput','Input is not in a recognized format')
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
    error('Unkown error loading data')
    
catch ME %This is a silly try/catch block because it doesn't do anything
    rethrow(ME)
end

end

function ptbCorgiData = loadFileList( toLoad)

%First need to organize all the files:
[ dataInfo ] = gatherInfoFromAllFiles( toLoad );

%Let's check if we've detected more than one paradigm:
if length(dataInfo.paradigmList) >1
    warning('ptbCorgi:loadPbCorgiData:tooManyParadigms',...
        'Found more than one paradigm in files to load, will still continue but datasets may not be from the same experiments')
end

nParadigm = length(dataInfo.paradigmList);
for iParadigm = 1:nParadigm,
    
    %Now lets go through and load the data.
    nPpt = length(dataInfo.byParadigm(iParadigm).participantList);
    
    for iPpt = 1:nPpt
        
        fileList = dataInfo.byParadigm(iParadigm).byParticipant(iPpt).fileNames;
        
        %try to load the data, use this to allow recovery if there's a
        %problem with only some of the participants.
        try
            %First load the data files for this participant, then set the name,
            %and finaly sort and organize the trial data.
            [loadedData(iPpt).sessionInfo, loadedData(iPpt).experimentData] = loadMultipleSessionFiles(fileList);
            loadedData(iPpt).participantID = dataInfo.byParadigm(iParadigm).byParticipant(iPpt).name;
            loadedData(iPpt).sortedTrialData = organizeData(loadedData(iPpt).sessionInfo,loadedData(iPpt).experimentData);
            validParticipantData(iPpt) = true;
        catch ME %If there was a problem with this participant document the problem and go to the next
            disp(['Error loading data from participant: ' ...
                dataInfo.byParadigm(iParadigm).byParticipant(iPpt).name]);
            loadedData(iPpt).errorInfo = ME;
            loadedData(iPpt).message = 'Error loading data';
            loadedData(iPpt).errorLoadingParticipant = true;
            loadedData(iPpt).participantID = dataInfo.byParadigm(iParadigm).byParticipant(iPpt).name;
            validParticipantData(iPpt) = false;
        end
    end
end


participantErrors = loadedData(~validParticipantData);
loadedData = loadedData(validParticipantData);

if ~any(validParticipantData)
    warning('None of the participants had valid data')
    return;
end


ptbCorgiData.paradigmName         = [dataInfo.paradigmList{:}];
ptbCorgiData.participantList      = {loadedData(:).participantID};
ptbCorgiData.participantErrorList = {participantErrors(:).participantID};
ptbCorgiData.nParticipants        = length(ptbCorgiData.participantList);
ptbCorgiData.conditionInfo        = loadedData(1).sessionInfo.conditionInfo;
ptbCorgiData.nConditions          = length(loadedData(1).sessionInfo.conditionInfo);
ptbCorgiData.participantData      = loadedData;

end



