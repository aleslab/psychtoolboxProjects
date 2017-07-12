function [ verStr, verStruct] = ptbCorgiVersion()
%ptbCorgiVersion Return version information for ptbCorgi
%   Detailed explanation goes here

verStruct.major = 0;
verStruct.minor = 32;
verStruct.point = 0;
verStruct.flavor = '-dev';
verStruct.gitHash = ptbCorgiGitHash();
verStr = sprintf('%i.%i.%i%s',verStruct.major,verStruct.minor,verStruct.point,verStruct.flavor);



end

