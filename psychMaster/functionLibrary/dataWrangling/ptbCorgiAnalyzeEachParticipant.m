function [ output_args ] = ptbCorgiAnalyzeEachParticipant( analysisInfo )
%ptbCorgiAnalyze Facilitate data analysis by repeating for each participant

%
%   Detailed explanation goes here


% error handling

%

%Load data if we need to.
analysisInfo.ptbCorgiData = overloadOpenPtbCorgiData(analysisInfo.ptbCorgiData);
nParticipants = analysisInfo.ptbCorgiData.nParticipants;


for iPpt = 1:nParticipants,
    
    
    analysisInfo.function(analysisInfo.funcOptions,...
        analysisInfo.ptbCorgiData.participantData(iPpt));
    
    
end

end


