function [sessionInfo, experimentData  ] = loadMultipleSessionFiles( filesToLoad)
%loadMultipleSessionFiles Loads multiple ptbCorgi session files
% 
%function [sessionInfo, experimentData  ] = loadMultipleSessionFiles( filesToLoad)
%
%This function loads multiple individual session files into returns 1 usable session
%file with all trial data together. 
%
%fileToLoad is a cell array with a list of filenames
%
%NOTE: DO NOT USE IF conditions are different. Not many sanity tests in place yet. 
%It is up to the user to pick a valid set of files to concatenate. 
%

nFiles = length(filesToLoad);

%First load all the files and grab the session dates        
for iFile = 1:nFiles
    
    try    
        allFileData(iFile) = load(filesToLoad{iFile});
    catch ME
        disp(['Error loading file: ' filesToLoad{iFile} ]);
        rethrow(ME)
    end
    
    sessionTimes(iFile) = allFileData(iFile).sessionInfo.sessionDate;   
end


%Now sort all the sessions by increasing time order. 
[sessionTimes, sessionSort] = sort(sessionTimes);
allFileData = allFileData(sessionSort);
filesToLoad = filesToLoad(sessionSort);

%Now with things sorted lets concatenate the data.
nTrials = length([allFileData.experimentData]);
experimentData = struct([]);
trialToSessionIdx = [];
allDiaries = {};
for iFile =1:nFiles,

    allFileData(iFile).experimentData;
    nTrialsPerSession(iFile) = length(allFileData(iFile).experimentData);
    trialToSessionIdx = cat(1,trialToSessionIdx,repmat(iFile,nTrialsPerSession(iFile),1));
    experimentData = cat(2,experimentData,allFileData(iFile).experimentData);
    allDiaries{iFile} = allFileData(iFile).sessionInfo.diary;
end

%Use the first session as the template session info
sessionInfo                   = allFileData(1).sessionInfo;
sessionInfo = rmfield(sessionInfo,'diary');
sessionInfo.allDiaries        = allDiaries;
sessionInfo.trialToSessionIdx = trialToSessionIdx;
sessionInfo.nTrialsPerSession = nTrialsPerSession;
sessionInfo.sessionTimes      = sessionTimes;
sessionInfo.sessionDate       = 'Concatenated Sessions';
sessionInfo.sessionFileList   = filesToLoad;
sessionInfo.isConcatenatedSessionFile  = true;