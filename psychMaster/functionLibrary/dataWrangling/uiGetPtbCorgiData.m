function [ ptbCorgiData ] = uiGetPtbCorgiData( chosenDirectory )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Using a silly global variable for this wrapper because dataBrowser is a
%GUIDE created GUI and I can't figure out how to make it modal another way.
global ptbCorgiMakeDataBrowserModal

ptbCorgiMakeDataBrowserModal = true;

if nargin <1 || isempty(chosenDirectory)
    chosenDirectory = pwd;
end

%Another guide issue is that the first argument is used for other callback
%use.
ptbCorgiData = ptbCorgiDataBrowser([],chosenDirectory);

ptbCorgiMakeDataBrowserModal = false;

end

