function [ verStr, verStruct] = ptbCorgiVersion()
%ptbCorgiVersion Return version information for ptbCorgi
%   [ verStr, verStruct] = ptbCorgiVersion()
%
% Generates a string/structure with the current ptbCorgiVersion. Modeled
% after PsychtoolboxVersion.
%
% PtbCorgi versions are coded with "semantic versioning". See http://semver.org
% Briefly for a version: X.Y.Z-label
% X - Major release number - Changes which may cause some incompatibility
% Y - Minor Release number - Feature additions 
% Z - Patch release number - Bugfixes
% label - Optional label used for things like "dev" for work in progress
% Output:
% verStr - String, e.g. "0.32.0-dev"
% verStruct
% verStruct.major - Major release 
% verStruct.minor = 32;
% verStruct.patch = 0;
% verStruct.label = '-dev';
% verStruct.gitHash = Output of ptbCorgiGitHash();


verStruct.major = 0;
verStruct.minor = 33;
verStruct.patch = 0;
verStruct.label = '';
verStruct.gitHash = ptbCorgiGitHash();
verStr = sprintf('%i.%i.%i%s',verStruct.major,verStruct.minor,verStruct.patch,verStruct.label);



end

