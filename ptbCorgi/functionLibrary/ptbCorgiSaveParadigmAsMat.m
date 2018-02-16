function [ success ] = ptbCorgiSaveParadigmAsMat( expInfo,conditionInfo,filename, addedInfo )
%ptbCorgiSaveParadigmAsMat Save a paradigm as a .mat file
%   [ success ] = ptbCorgiSaveParadigmAsMat( expInfo,conditionInfo,filename, [addedInfo] )
%
%Saves paradigm information as a .mat file suitable to be loaded by
%ptbCorgiLoadParadigm().
%
%Arguments:
%expInfo: Experiment info struct 
%conditionInfo: Condition info struct 
%filename: filename to save
%addedInfo: optional parameter that will be saved in the fileInfo struct in the file.
%
%Output:
%success: Flag set to true for success, false for failure. 
%
%See Also: ptbCorgiLoadParadigm

fileInfo.ptbCorgiVersion = ptbCorgiVersion();
fileInfo.timeCreatedNum  = now();
fileInfo.timeCreatedHuman  = datestr(now);

%If more info to include put it here. 
if nargin==4    
    fileInfo.addedInfo      = addedInfo;
end


try
    save(filename,'fileInfo','expInfo','conditionInfo');
    success = true;
    return;
catch ME
    success = false;
    warning('Caught Error:');
    disp(getReport(ME));
    return;
end

end

