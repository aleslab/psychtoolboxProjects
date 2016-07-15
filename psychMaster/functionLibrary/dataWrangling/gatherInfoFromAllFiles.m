function [ dataInfo ] = gatherInfoFromAllFiles( directory )
%gatherInfoFromAllFiles Gathers information about  ptbCorgi datafiles 
%
%[dataInfo] = gatherInfoFromAllFiles( directory )


fileList = dir(fullfile(directory,'*.mat'));


fieldsToGather = { ...
    'participantID',...
    'conditionInfo',...
    'sessionDate',...
    };

idx=1; %This is lazy and dangerous - JMA
%This loop looks at all files and extracts the session info from each
for iFile = 1:length(fileList),
    
    if fileList(iFile).isdir==true;
        continue;
    end
    
    thisFile = fullfile(directory,fileList(iFile).name);

    %skip unix world hidden files
    if strncmp(thisFile,'.',1)
        display(['skipping folder: ' thisFile])
        continue;
    end

    %lazy handling of loading the info.
    try
        load(thisFile,'sessionInfo');
    catch
        continue
    end
    
    %Now gather the info we need.
    %This uses dynamic field names to simplify (Ha!) the code
    for iField = 1:length(fieldsToGather),        
        allSessionInfo(idx).(fieldsToGather{iField}) = sessionInfo.(fieldsToGather{iField});
    end
    
    %Sometimes structs in structs makes life more difficult.
    %some files don't have a specific name set.  Default to the name of
    %the paradigm function. 
    try
        allSessionInfo(idx).paradigmName = sessionInfo.expInfo.paradigmName;
    catch
        allSessionInfo(idx).paradigmName = func2str( sessionInfo.paradigmFun );
    end
    
    
   allSessionInfo(idx).dataFile = thisFile;
   idx = idx+1;
end

%Now we're going to organize things into various lists that will make
%organization simpler.  Not trying to be efficient/clever about this code
%Just brute force and duplicate things. 
nSessions = length(allSessionInfo);

%Now gather all the indiviudal participants
[participantList] = unique({allSessionInfo.participantID});
%Now find the sessions for each participant
for iPpt = 1:length(participantList),
    
    participantSessionList = strcmp(participantList{iPpt},{allSessionInfo.participantID});
    %Change this form a logical index to numeric. Easier for people to
    %understand, and more useful for gui control. 
    participantSessionList = find(participantSessionList);
    dataInfo.participantSessionList{iPpt} = participantSessionList;
    dataInfo.participantParadigmList{iPpt} = unique({allSessionInfo(participantSessionList).paradigmName});
    
    %Now lets go through each session find all sessions with identical
    %conditions. This loop compares all conditions.   There is tricky
    %indexing going on because this loop is a subset, but the whole session
    %list contains other participants too. 
    %If there are 4 conditions:
    %First compare 1 -> 2 3 4
    %Then compare  2 -> 3 4.  (already compared 1 and 2).
    conditionComparison = false(nSessions);
    
    for iPptSess = 1:length(participantSessionList)
    
        sessIdx1 = participantSessionList(iPptSess);
        
        
        for iComp = (iPptSess+1): length(participantSessionList),
            
            %Now compare the two sessions:
            
            sessIdx2 = participantSessionList(iComp);
            condInfo1 = allSessionInfo(sessIdx1).conditionInfo;
            condInfo2 = allSessionInfo(sessIdx2).conditionInfo;
            
            conditionComparison(sessIdx1,sessIdx2) = isequal(condInfo1,condInfo2);
            conditionComparison(sessIdx2,sessIdx1) = conditionComparison(sessIdx1,sessIdx2); 
                
            
        end
        
        conditionComparison(sessIdx1,sessIdx1) = true;
        
    end
    
    %This is a crazy line.  It determines the number of different
    %experiments the participant has done.  There's probably a more
    %straightforward way of doing this. But because I think in linear algebra
    %Rank makes total sense to me. The rank of the matrix tells
    %you how many unique groupings of sessions there are. -JMA
    nGroupings = rank(double(conditionComparison(participantSessionList,participantSessionList)));  
    
    sessionGrouping{iPpt} = unique(conditionComparison,'rows');
end


dataInfo.participantList = participantList;
dataInfo.filelist        = {allSessionInfo.dataFile};
dataInfo.sessionGrouping = sessionGrouping;



