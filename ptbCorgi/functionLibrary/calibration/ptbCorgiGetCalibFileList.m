function [ calibList ] = ptbCorgiGetCalibFileList( dir2scan )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin<1
    if ispref('ptbCorgi','calibdir')
        dir2scan = getpref( 'ptbCorgi','calibdir');
    else
        dir2scan = pwd;
    end
end

%get the fileList
fileList = dir(fullfile(dir2scan,'*.mat'));
calibList = [];
foundCalibFileIdx = 1;
foundFileList = [];

for iFile = 1:length(fileList)
    
    modeString = [];

    fullFilename = fullfile(dir2scan,fileList(iFile).name);
    
    varlist=whos('-file',fullFilename); %Get list of variables

    if any(strcmp({varlist(:).name},'modeString')) %Check if a modestring is set
        load(fullFilename,'modeString'); %Load the mode string
        foundFileList(foundCalibFileIdx).modeString = modeString;
        foundFileList(foundCalibFileIdx).fullname   = fullFilename;
        foundFileList(foundCalibFileIdx).name       = fileList(iFile).name;
        foundCalibFileIdx = foundCalibFileIdx +1;
    end
    
end

if isempty(foundFileList)
    return;
end

%Gether unique modestrings:
[c,ia,ic] = unique({foundFileList(:).modeString});

%Now loop over the unique modes and setup the file list
for iMode = 1:length(ia)
    calibList(iMode).modeString = c{iMode};
    theseFiles = (ic==iMode);
    calibList(iMode).fullnames  = {foundFileList(theseFiles).fullname};
    calibList(iMode).names  = {foundFileList(theseFiles).name};
end


