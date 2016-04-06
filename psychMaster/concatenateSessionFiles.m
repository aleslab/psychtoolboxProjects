function [  ] = concatenateSessionFiles( filesToConcatenate, outputDir)
%concatenateSessionFiles Concatenates sessionfiles into 1 file. 
% 
%function [  ] = concatenateSessionFiles( filesToConcatenate, [outputDir])
%
%This function concatenates individual session files into 1 usable session
%file with all trial data together. 
%
%filesToConcatenate is a cell array with a list of filenames
%outputDir is an optional argument of where to save the concatenated file
%          if not given will default to outputing in the directory of the
%          first file in the list. 
%
%NOTE: DO NOT USE IF conditions are different. Not many sanity tests in place yet. 
%It is up to the user to pick a valid set of files to concatenate. 
%

nFiles = length(filesToConcatenate);

load(filesToConcatenate{1})

if isfield(sessionInfo.expInfo,'paradigmName') && ~isempty(sessionInfo.expInfo.paradigmName),
    filePrefix = sessionInfo.expInfo.paradigmName;
else
    filePrefix = func2str(sessionInfo.paradigmFun);
end

saveFilename = [ filePrefix '_' ...
            sessionInfo.participantID '_' num2str(nFiles) '_file_cat' ...
            datestr(now,'yyyymmdd_HHMMSS') '.mat'];

if nargin == 1
    outputDir = fileparts(filesToConcatenate{1});
end

saveFilename = fullfile(outputDir,saveFilename);

%First load all the files and grab the session dates        
for iFile = 1:nFiles
    
    try    
        allFileData(iFile) = load(filesToConcatenate{iFile});
    catch ME
        disp(['Error loading file: ' filesToConcatenate{iFile} ]);
        rethrow(ME)
    end
    
    sessionTimes(iFile) = allFileData(iFile).sessionInfo.sessionDate;   
end


%Now sort all the sessions by increasing time order. 
[sessionTimes, sessionSort] = sort(sessionTimes);
allFileData = allFileData(sessionSort);
filesToConcatenate = filesToConcatenate(sessionSort);

%Now with things sorted lets concatenate the data.
nTrials = length([allFileData.experimentData]);
experimentData = struct([])
trialToSessionIdx = [];
allDiares = {};
for iFile =1:nFiles,

    allFileData(iFile).experimentData
    nTrialsPerSession(iFile) = length(allFileData(iFile).experimentData);
    trialToSessionIdx = cat(1,trialToSessionIdx,repmat(iFile,nTrialsPerSession(iFile),1));
    experimentData = cat(2,experimentData,allFileData(iFile).experimentData);
    allDiaries{iFile} = allFileData(iFile).sessionInfo.diary;
end

%Use the first session as the template session info
sessionInfo                   = allFileData(1).sessionInfo;
sessionInfo = rmfield(sessionInfo,'diary')
sessionInfo.allDiaries        = allDiaries;
sessionInfo.trialToSessionIdx = trialToSessionIdx;
sessionInfo.nTrialsPerSession = nTrialsPerSession;
sessionInfo.sessionTimes      = sessionTimes;
sessionInfo.sessionDate       = 'Concatenated Sessions';
sessionInfo.sessionFileList   = filesToConcatenate;
sessionInfo.isConcatenatedSessionFile  = true;


save(saveFilename,'sessionInfo','experimentData');
