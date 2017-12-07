function [ isShadowed, shadowedFileList ] = checkForShadowedFiles( dirToCheck )
%checkForShadowedFiles Checks all *.m files for shadowed copies
%   [ isShadowed, shadowedFileList ] = checkForShadowedFiles( [dirToCheck] )
%
%   Multiple copies of the same matlab file in different directories can
%   create confusion. checkForShadowedFiles checks all *.m files in the current
%   directory and subdirectories for other copies on the matlab path.
%
%   Usage: 
%   [ isShadowed, shadowedFileList ] = checkForShadowedFiles( [dirToCheck] )
%   
%   Inputs:
%   dirToCheck = [pwd] Optional directory name to check 
%
%   Output:
%   isShadowed = Flag set to true if any shadowed files found. 
%   shadowedFileList = A cell array of filenames that are shadowed on the path. May
%                      contain duplicates.
%
%   Example:
% 
%  [ isShadowed, shadowedFileList ] = checkForShadowedFiles( )
%
% isShadowed =
% 
%      1
% 
% 
% shadowedFileList = 
% 
%     '/Users/ales/git/analysis/pmGui.m'
%     '/Users/ales/git/analysis/nAfc/pmGui.m'
%     '/Users/ales/git/psychtoolboxProjects/psychMaster/functionLibrary/GUI/pmGui.m'
%     '/Users/ales/git/analysis/nAfc/ptbCorgi.m'
%     '/Users/ales/git/psychtoolboxProjects/psychMaster/ptbCorgi.m'
%     '/Users/ales/git/analysis/pmGui.m'
%     '/Users/ales/git/analysis/nAfc/pmGui.m'
%     '/Users/ales/git/psychtoolboxProjects/psychMaster/functionLibrary/GUI/pmGui.m'
%     '/Users/ales/git/analysis/responseSimulation/jacobianest.m'
%     '/Users/ales/Documents/MATLAB/Toolboxes/Adaptive Robust Numerical Differentiatio...'

%If you don't set a directory check the current directory
if nargin ==0 || isempty(dirToCheck)
    dirToCheck = pwd;
end

[isShadowed, shadowedFileList] = checkThisDir( dirToCheck);


    function [isShadowed, shadowedFileList] = checkThisDir( dirName)
        
        fileList = dir( dirName);
        isShadowed = false; 
        shadowedFileList = {};
        for iFile = 1:length(fileList)
            filename = fileList(iFile).name;
            
            
            %Don't check current '.'  or parent '..'
            if strcmp(filename,'.')  || strcmp(filename,'..')
                continue;
            end
            
            
            if fileList(iFile).isdir
                %Lets do a bit of recursion to check subdirectories.                
                [isShadowedSubDir, fileLocations] = checkThisDir(filename);
                
                isShadowed = isShadowedSubDir | isShadowed;
                shadowedFileList = [shadowedFileList; fileLocations ];
                continue;
            end
            
            [pathStr name ext] = fileparts(filename);
            
            if ~strcmpi(ext,'.m')
                continue;
            end
            
            fileLocations = which(filename,'-all');
            
            if length(fileLocations)>1
                isShadowed = true;
                shadowedFileList = [shadowedFileList; fileLocations ];
            end
            
        end
    end

end

