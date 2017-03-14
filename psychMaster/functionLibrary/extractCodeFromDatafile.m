function [  ] = extractCodeFromDatafile( inputFile, outputDirectory )
%extractCodeFromDatafile Writes out all code files from a ptbCorgi datafile
%[] = extractCodeFromDatafile( inputFile, [outputDirectory] )
%   Detailed explanation goes here


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

