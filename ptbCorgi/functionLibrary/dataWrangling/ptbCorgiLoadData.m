function [ ptbCorgiData ] = ptbCorgiLoadData( varargin )
%overloadOpenPtbCorgiData Implements input overloading for ptbCorgiData
%
%[ ptbCorgiData ] = overloadOpenPtbCorgiData( varargin )
%  This is an important function that abstracts loading datafiles into a
%  single place and implements multiple ways to load data. It will sort and
%  organize data to make project level management simpler. 
%
%  There are 4 ways to specify the input data:
%   1) ptbCorgiData structure as returned by ptbCorgiDataBrowser or
%   similar. This is here to allow people to preload data and not do
%   anything with it. 
%      [ptbCorgiData] = overloadOpenPtbCorgiData(ptbCorgiData) 
%
%   2) A single session filename (either single or a concatenated session):
%      [ptbCorgiData] = overloadOpenPtbCorgiData('myExp_ppt_20170101.mat') 
%
%   3) A cell array of session files:
%   fileList = {'/path/to/data1.mat' ...
%                    '/path/to/data2.mat' };
%     [ptbCorgiData] = overloadOpenPtbCorgiData(fileList);
%
%   4) Using the contents of a session file:
%     [ptbCorgiData] = overloadOpenPtbCorgiData(sessionInfo,experimentData)
%
%  Output is a ptbCorgiData structure see HELP TO BE WRITTEN for
%  description
%

%Note: this is currently just a synonymn for overloadOpenPtbCorgiData
ptbCorgiData = overloadOpenPtbCorgiData(varargin{:});


