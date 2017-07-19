function [  ] = extractCodeFromDatafile( inputFile, outputDirectory )
%extractCodeFromDatafile Writes out all code files from a ptbCorgi datafile
%[] = extractCodeFromDatafile( inputFile, [outputDirectory] )
%   
%     This function will load a ptbCorgi datafile and extracts the saved
%     code in the datafile, and writes out all the mfiles that were saved.
%
%SEE also: writeFilesFromBackup()  backupExecutedFiles()

if nargin == 0
    help('extractCodeFromDatafile')
    return;
end

if nargin == 1 || isempty(outputDirectory)
    [pathstr] = fileparts(inputFile)
    outputDirectory = fullfile(pathstr,'extractOutput');
end

ptbCorgiData = load(inputFile);

writeFilesFromBackup(ptbCorgiData.sessionInfo.mfileBackup,outputDirectory)

end

