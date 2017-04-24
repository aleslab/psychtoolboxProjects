function [ outputMatrix ] = buildMatrixFromField( ptbCorgiData,fieldname )
%buildMatrixFromField Extracts ptbCorgi data and organizes it as a matrix
%function [ outputMatrix ] = buildMatrixFromField( ptbCorgiData,fieldname )
%   
%  Input:
%  ptbCorgiData can 
%   1) ptbCorgiData structure as returned by ptbCorgiDataBrowser or similar
%      [outputMatrix] = buildMatrixFromField(ptbCorgiData,'validTrial') 
%
%   2) A session filename (either single or a concatenated session):
%      [outputMatrix] = buildMatrixFromField('myExp_ppt_20170101.mat','validTrial') 
%
%  fieldname: a string identify the field to be extracted. E.g.:
%             fieldname = 'validTrial';
%             fieldname = 'isResponseCorrect';
%
%  Output:
%  outputMatrix is a nParticipant x nCondition x nTrial x fieldname size


%Load data if we need to.
ptbCorgiData = overloadOpenPtbCorgiData(ptbCorgiData);
%number of participants to loop over. 
nParticipants = ptbCorgiData.nParticipants;

if ~isstr(fieldname)
    error('Fieldname input must be a string')
end


%Let's initialize the matrix
%Now different conditions/participants may have different numbers of trials.
%So as a quick and dirty init for now just initialize with the number of
%trials from the first participant, and first condition.
nTrialsInit = length(ptbCorgiData.participantData(1).sortedTrialData(1).experimentData);
outputMatrix = NaN(nParticipants,ptbCorgiData.nConditions,nTrialsInit,1);


for iPpt = 1:nParticipants,
    
    
    %If the data hasn't been sorted already, lets sort it
    if ~isfield( ptbCorgiData.participantData(1),'sortedTrialData')
        
        thisSortedData = organizeData(ptbCorgiData.participantData(iPpt).sessionInfo,...
            ptbCorgiData.participantData(iPpt).experimentData);
    
    %otherwise just use the sorted data
    else
        thisSortedData = ptbCorgiData.participantData(iPpt).sortedTrialData;
    end
    
    %Now go through each condition.
    for iCond = 1:ptbCorgiData.nConditions
        
        thisExperimentData = thisSortedData(iCond).experimentData;
           
        %Now go through each trial
        for iTrial = 1:length(thisExperimentData),
            
            thisField = thisExperimentData(iTrial).(fieldname);
            %Turn thisField into a column vector to simplify concatenating
            %possibly different sized matrices together.
            thisField = thisField(:);
            %If our matrix isn't large enough extend it for this data
            if size(outputMatrix,4) < length(thisField);
                
                %If it's not the first time through the loop print a
                %warning if the matrix changes size.
                if ~(iPpt ==1 && iCond ==1 && iTrial ==1)
                    warning('ptbCorgi:buildmatrix:diffSize',...
                        'Extracted data from participant: %s, condition: %i, trial: %i has more data, padding rest of matrix with NaN',...
                        ptbCorgiData.participantList{iPpt},iCond,iTrial);
                end
                
                sizeNeededToExtend = length(thisField) - size(outputMatrix,4);
                outputMatrix(:,:,:,end+1:length(thisField)) = ...
                    NaN(nParticipants,ptbCorgiData.nConditions,size(outputMatrix,3),sizeNeededToExtend);
            end
        
            
            %Finaly put the data into the output matrix.
            outputMatrix(iPpt,iCond,iTrial,1:length(thisField)) = thisField;
        end
        
    end
end

end

