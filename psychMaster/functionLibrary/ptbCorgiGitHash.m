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
gitHashOnArchive = '$Format:%H$'


thisFile = mfilename('fullpath');
[thisDir, ~, ~] = fileparts(thisFile);

 %Try to get the git commit hash and save it to the expInfo
 %
 %JMA: This only works for a current git repository.
 %TODO: Add a mechanism for including this information in standalone
 %builds.
 [errorStatus,result]= system(['git --exec-path=' thisDir ' rev-parse --verify HEAD']);
 
 %If we're in a git repo grab the current commit hash.
 if ~errorStatus
     %trim off trailing whitespace/line break
     gitHash = strtrim(result);
 elseif ~strcmp(gitHashOnArchive,strtrim(' $ F ormat:%H$ ')
     gitHash = gitHashOnArchive;
 else     
     gitHash = 'HASHERR';
 end
 
end

