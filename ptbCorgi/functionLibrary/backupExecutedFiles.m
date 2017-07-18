function [ mfileBackup ] = backupExecutedFiles( )
%backupExecutedFiles Finds previously executed mfiles and loads them
%[ mfileBackup ] = backupExecutedFiles( )
%   This function is used to load/backup functions/files that have been run
%   recently. Uses matlab "inmem" to get a list and parses that list for
%   functions that are not part of MATLAB or Psychtoolbox. It returns a
%   structure that contains the filename and contents of each of these
%   files. 
%
% Output:
%   mfileBackup - A structure, with each element being one is a matlab structure with fields:
%    name   = Name of the file
%   content = The contents of the mfile. 


   
%Exclude mfiles in these directories.
%We don't need MATLAB functions or psychtoolbox functions
ptbDir    = PsychtoolboxRoot;
matlabDir = matlabroot;
excludeDirs = {ptbDir,matlabDir};
    

[mFilesInMem] = inmem('-completenames');

%setup a vector to select the files to backup.
fileSelection = true(size(mFilesInMem));

for iDir = 1 : length(excludeDirs)
    thisDir = excludeDirs{iDir};
    
    %Find the files in an excluded directory 
    files2Exclude = strncmp(thisDir,mFilesInMem,length(thisDir));
    %Exclude the files using boolean logic keep files NOT excluded
    fileSelection = fileSelection & ~files2Exclude; 

end

mfiles = mFilesInMem(fileSelection);
%Now loop through all the files and save them
for iFile = 1:length(mfiles)
    [~,name] = fileparts(mfiles{iFile});
    mfileBackup(iFile).name = name;
    mfileBackup(iFile).content = fileread(mfiles{iFile});
end
