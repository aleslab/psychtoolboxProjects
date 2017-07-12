function [] = psychMaster(sessionInfo)
%psychMaster Depracted function name
%   This is a wrapper script that allows using "psychMaster" to launch a
%   ptbCorgi experiment.  The name of the script was changed.

warning('psychMaster.m has been deprecated and renamed ptbCorgi.m.  Please run ptbCorgi instead')

if ~exist('sessionInfo','var') || isempty(sessionInfo)
    ptbCorgi();
else
    ptbCorgi(sessionInfo);
end

end

