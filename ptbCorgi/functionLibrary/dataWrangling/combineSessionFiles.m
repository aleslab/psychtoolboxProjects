function [sessionInfo, experimentData  ] = combineSessionFiles( filesToConcatenate, outputDir)
%combineSessionFiles Concatenates sessionfiles into 1 file. 
% 
%function [sessionInfo, experimentData  ] = combineSessionFiles( filesToConcatenate, [outputDir])
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


[sessionInfo experimentData] = loadMultipleSessionFiles(filesToConcatenate);
    
nFiles = length(filesToConcatenate);

if isfield(sessionInfo.expInfo,'paradigmName') && ~isempty(sessionInfo.expInfo.paradigmName),
    filePrefix = sessionInfo.expInfo.paradigmName;
else
    filePrefix = func2str(sessionInfo.paradigmFun);
end

saveFilename = [ filePrefix '_' ...
            sessionInfo.participantID '_combo_' num2str(nFiles) '_sessions_' ...
            datestr(now,'yyyymmdd_HHMMSS') '.mat'];

if nargin == 1
    outputDir = fileparts(filesToConcatenate{1});
end

saveFilename = fullfile(outputDir,saveFilename);

save(saveFilename,'sessionInfo','experimentData');



