function [  ] = combineSessionGui( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fileList = uigetfile('*.mat','Select files to combine','MultiSelect','on')
concatenateSessionFiles(fileList)

end

