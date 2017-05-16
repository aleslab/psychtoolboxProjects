function [ analysisInfo, ptbCorgiData ] = ptbCorgiAnalyzeEachParticipant( analysisInfo,ptbCorgiData )
%ptbCorgiAnalyze Facilitate data analysis by repeating for each participant

%
%   Detailed explanation goes here


% error/warning handling here

if isfield(analysisInfo,'results')
    warning('analysisInfo contains previous results.  These may be changed by the current analysis')
    analysisInfo = rmfield(analysisInfo,'results');
end

%

%Load data if we need to.
ptbCorgiData = overloadOpenPtbCorgiData(ptbCorgiData);
nParticipants = ptbCorgiData.nParticipants;

%settings = rmfield(analysisInfo, 'ptbCorgiData');
settings = analysisInfo;
%code to validate previous analysis here%

for iPpt = 1:nParticipants,
    
    %If no results history exists set one up, and put everything into
    %the first structure. 
    if ~isfield(ptbCorgiData.participantData(iPpt),'analysisHistory')
        ptbCorgiData.participantData(iPpt).analysisHistory = struct();
        resultIdx = 1;
    else %If previous analysis exists add the current analysis to the structure
        resultIdx = length(ptbCorgiData.participantData(iPpt).analysisHistory)+1;
    end
    
    %If no results exist make an empty field. FOr simplyfing merge code. 
    if ~isfield(ptbCorgiData.participantData(iPpt),'analysisResults')
        ptbCorgiData.participantData(iPpt).analysisResults = struct();
    end
    
    %Record what the settings were for this analysis.
    ptbCorgiData.participantData(iPpt).analysisHistory(resultIdx).settings = ...
        settings;
    
    %Use the chosen function to analyze the data. 
    if nargout(analysisInfo.function) > 0 
        results = analysisInfo.function(analysisInfo.funcOptions,...
            ptbCorgiData.participantData(iPpt));
    else
        analysisInfo.function(analysisInfo.funcOptions,...
            ptbCorgiData.participantData(iPpt));
        results.message = sprintf('Function %s does not return results',...
            func2str(analysisInfo.function));
    end
    
    
    %To be able to chain multuple analysis together and keep track of
    %history results and be able to access the results for future analysis
    %we store them in the participantData field.
    %analysisHistory stores the whole history of anlaysis run. 
    ptbCorgiData.participantData(iPpt).analysisHistory(resultIdx).results = ...
        results;
    %analysisResults holds the current results merged/overwritting into any previous
    %results
    ptbCorgiData.participantData(iPpt).analysisResults = ...
         updateStruct( ptbCorgiData.participantData(iPpt).analysisResults,results);
     
    %For ease of accessing place the current resul
    analysisInfo.results(iPpt) = ptbCorgiData.participantData(iPpt).analysisResults;
    
end

end


