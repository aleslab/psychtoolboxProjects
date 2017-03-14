function [ ] = writeFilesFromBackup( mfileBackup, outputDirectory )
%writeFilesFromBackup write out all the files from a backup.
%[ ] = writeFilesFromBackup( mfileBackup, outputDirectory )
%
%   This function will write out the files backed up in a ptbCorgi
%   mfileBackup structure.

if nargin<=1 || isempty(outputDirectory)
    %If no input put files in a default locations, not the current
    %directory to keep thing tidy.
    outputDirectory = fullfile(pwd,'extractOutput');
end

if ~exist(outputDirectory,'dir')
    mkdir(outputDirectory);
end

nFiles = length(mfileBackup);

%First do 1 loop through to check if any file already exists
%As a safety precaution the initial version of this code will not overwrite
%existing files
for iFile = 1:nFiles,

    filename = fullfile(outputDirectory,[mfileBackup(iFile).name '.m']);
    if exist(filename,'file')
        error(['Error file exists, stopping now to avoid overwriting existing files. Filename ' filename]);
    end
    
end

%Ok, now lets loop through and write out the files.
for iFile = 1:nFiles,

    filename = fullfile(outputDirectory,[mfileBackup(iFile).name '.m']);
    writeFile(filename, mfileBackup(iFile).content);
    
end

end


function writeFile(filename,content)

[fid] = fopen(filename,'w');

fprintf(fid,'%s',content);
fclose(fid);
end
