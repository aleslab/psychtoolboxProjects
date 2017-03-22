function [ gitHash ] = ptbCorgiGitHash(  )
%ptbCorgiGitHash Finds the git SHA hash that identifies the git commit
%function [ gitHash ] = ptbCorgiGitHash()
%   This function returns the SHA hash corresponding to the git commit for
%   the software. It tries in the following order:
%
%   1) If a git repository, uses git to grab the current hash.
%   2) If code was exported from git, a constant string containing the
%      githash for the export should exist. Use that
%   3) If neither is true return 'HASHERR'

%This special identifier will make the git software replace the string 
%the git hash when the code is "archived" or exported for a release.
gitHashOnArchive = '$Format:%H$';

%Using a silly white space addition to stop git from interpreting the
%string as something to replace with the githash. That way we can double
%check that the string was actually replaced.
checkString = ' $ F ormat:%H$ ';
checkString = checkString(~isspace(checkString));

thisFile = mfilename('fullpath');
[thisDir, ~, ~] = fileparts(thisFile);


 %Try to get the git commit hash 
 % Check if thisFile is tracked in a git repository
 
 [repoCheckError,repoCheckResult] = system(['git status ' thisFile ' --porcelain'])
 
 %If we're in a git repository, try and load the hash
 if ~repoCheckError
     [hashCheckError,hashCheckResult] = system(['git --exec-path=' thisDir ' rev-parse --verify HEAD --porcelain'])
 end
 
 %If we're in a git repo grab the current commit hash.
 if ~repoCheckError && ~hashCheckError
     %trim off trailing whitespace/line break
     gitHash = strtrim(hashCheckResult);
     
     %Using a silly white space addition to stop git from interpreting the
     %string as something to replace with the githash.
 elseif ~strcmp(gitHashOnArchive,checkString);
     gitHash = gitHashOnArchive;
 else     
     gitHash = 'HASHERR';
 end
 
end

