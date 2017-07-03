function [ dataInfo ] = gatherInfoFromAllFiles( toLoad )
%gatherInfoFromAllFiles Gathers information about  ptbCorgi datafiles 
%
%[dataInfo] = gatherInfoFromAllFiles( toLoad )
% 
% This function parses and organize sessions from a load of data files.
% It's used to organize files and group things together.
%
% Input:
%
% There are 2 ways to specify what files to load:
%     1) toLoad can be a directory. In which case all data files in the
%        directory and subdirectories are loaded in.
%    
%        Example:
%        [dataInfo] = gatherInfoFromAllFiles( '/path/to/data' )
%
%     2) toLoad can be a cell array of filenames. In which case all the
%     data files are loaded.
%
%        Example:
%        fileList = {'/path/to/data1.mat' ...
%                    '/path/to/data2.mat' };
%        [dataInfo] = gatherInfoFromAllFiles( fileList )
%
% Output:
%
% This function returns a structure with many fields that provide
% information for organizing data:
% ***REMIND US TO describe these they are somewhat explanatory, but might not
% make sense to people***
%        participantSessionList: {1x4 cell}
%     byParticipantParadigmName: {1x4 cell}
%                     fileNames: {1x49 cell}
%                  paradigmList: {1x8 cell}
%           paradigmFileIndices: {1x8 cell}
%                    byParadigm: [1x8 struct]
%               participantList: {1x4 cell}
%               sessionGrouping: {1x4 cell}

if isstr(toLoad)
    fileList = rdir(fullfile(toLoad,'*.mat'));
elseif iscellstr(toLoad)
    %Deal is always a tricky one, here I'm just creating the structure
    %similar to what dir returns.  Just because we use the "isDir" field
    %below.  It's quicker for me to do this now, but it can be hard for
    %people to read the line. 
    [fileList(1:length(toLoad)).name] = deal(toLoad{:});
    [fileList.isdir] = deal(false);
else
    error('ptbCorgi:gatherInfo:inputError', 'error using function, input must either be a string or cell array of strings');    
end

%This is the list of fields to read in from each session file.
fieldsToGather = { ...
    'participantID',...
    'conditionInfo',...
    'sessionDate',...
    };

%When comparing conditions which fields should we ignore. 
conditionFieldsToIgnore = { ...
    'nReps',...
    };

idx=1; %This is lazy and dangerous - JMA
%This loop looks at all files and extracts the session info from each
atLeastOneFileLoaded = false;
for iFile = 1:length(fileList),
    
    if fileList(iFile).isdir==true;
        continue;
    end
    
    thisFile = fileList(iFile).name;
    [thisPath thisName thisExt] = fileparts(thisFile);
    %skip unix world hidden files
    if strncmp(thisName,'.',1)
        display(['skipping file: ' thisFile])
        continue;
    end
    
    %lazy handling of loading the info.
    try
        loadedInfo = load(thisFile,'sessionInfo');
        
        if ~isfield(loadedInfo,'sessionInfo')
            disp(['Not a valid ptbCorgi Session file: ' thisFile]);
            continue
        end
            
        sessionInfo = loadedInfo.sessionInfo;
        
        if isfield(sessionInfo,'isConcatenatedSessionFile') ...
                && sessionInfo.isConcatenatedSessionFile == true
            disp(['Skipping previously concatenated file : ' thisFile]);
            continue
        end
        
        %Now gather the info we need.
        %This uses dynamic field names to simplify (Haha!) the code
        for iField = 1:length(fieldsToGather),
            allSessionInfo(idx).(fieldsToGather{iField}) = sessionInfo.(fieldsToGather{iField});
        end
        
        if isempty(allSessionInfo(idx).conditionInfo)
            allSessionInfo(idx).conditionInfo(1).label = 'ERROR! File Missing ConditionInfo';
        end
        
        %Sometimes structs in structs makes life more difficult.
        %some files don't have a specific name set.  Default to the name of
        %the paradigm function.
        try
            allSessionInfo(idx).paradigmName = sessionInfo.expInfo.paradigmName;
        catch
            allSessionInfo(idx).paradigmName = func2str( sessionInfo.paradigmFun );
        end
        
       
        allSessionInfo(idx).dataFileFullPath = thisFile;
        
        allSessionInfo(idx).dataFileName = [thisName thisExt];
        allSessionInfo(idx).dataFilePath = thisPath;
        idx = idx+1;
        atLeastOneFileLoaded = true;
    catch ME
        continue
    end
    
end

if ~atLeastOneFileLoaded
    dataInfo = [];
    return
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
    dataInfo.byParticipantParadigmName{iPpt} = unique({allSessionInfo(participantSessionList).paradigmName});
    
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
            
            %Remove any fields we want to ignore when comparing conditions
            tf = isfield(condInfo1,conditionFieldsToIgnore);
            condInfo1 = rmfield(condInfo1,conditionFieldsToIgnore(tf));
            
            tf = isfield(condInfo2,conditionFieldsToIgnore);
            condInfo2 = rmfield(condInfo2,conditionFieldsToIgnore(tf));
                
            
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

dataInfo.fullPathFileName        = {allSessionInfo.dataFileFullPath};
dataInfo.fileNames               = {allSessionInfo.dataFileName};
dataInfo.filePath               = {allSessionInfo.dataFilePath};
dataInfo.sessionInfo            = allSessionInfo;


%Participants are straight forward.  Each participant needs a unique
%participantID.
%Paradigms are not straight forward.  It's possible to use the same
%paradigmName and have completely different condition options.  So I'm
%going to now find "unique" experiments based on comparing the condition
%parameters. 

%Now lets go through each session find all sessions with identical
%conditions. This loop compares all conditions.   There is tricky
%indexing going on because this loop is a subset, but the whole session
%list contains other participants too.
%If there are 4 conditions:
%First compare 1 -> 2 3 4
%Then compare  2 -> 3 4.  (already compared 1 and 2).
conditionComparison = false(nSessions);

for sessIdx1 = 1:nSessions
    
    for sessIdx2 = (sessIdx1+1): nSessions,
        
        %Now compare the two sessions:
        condInfo1 = allSessionInfo(sessIdx1).conditionInfo;
        condInfo2 = allSessionInfo(sessIdx2).conditionInfo;
        
        %Remove any fields we want to ignore when comparing conditions
        %And order the conditions in ascii order so a simple permutation
        %doesn't cause the comparison to fail. 
        tf = isfield(condInfo1,conditionFieldsToIgnore);
        condInfo1 = orderfields(rmfield(condInfo1,conditionFieldsToIgnore(tf)));
        
        tf = isfield(condInfo2,conditionFieldsToIgnore);
        condInfo2 = orderfields(rmfield(condInfo2,conditionFieldsToIgnore(tf)));
        
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
nDiffParadigms = rank(double(conditionComparison(participantSessionList,participantSessionList)));

dataInfo.paradigmSessionGroupings = unique(conditionComparison,'rows');
%Another tricky bit.  Finding the first non-zero 
[row firstCol] = max(dataInfo.paradigmSessionGroupings,[],2);
dataInfo.paradigmList = {allSessionInfo(firstCol).paradigmName};

    
%dataInfo.paradigmList    = unique([dataInfo.byParticipantParadigmName{:}]);
%Now find the participants for each paradigm
for iParadigm = 1:length(dataInfo.paradigmList),
    
    thisParadigm = dataInfo.paradigmList{iParadigm};
    
%    thisParadigmFileIndices = strcmp(thisParadigm,{allSessionInfo.paradigmName});
    
    thisParadigmFileIndices = dataInfo.paradigmSessionGroupings(iParadigm,:);
    
    %Change this form a logical index to numeric. Easier for people to
    %understand, and more useful for gui control, but trivially slower for small lists. 
    thisParadigmFileIndices  = find(thisParadigmFileIndices);
    dataInfo.paradigmFileIndices{iParadigm} = thisParadigmFileIndices;
    
    dataInfo.byParadigmParticipantList{iParadigm} = unique({allSessionInfo(thisParadigmFileIndices).participantID});
    
    
%  
%     dataInfo.byParadigm(iParadigm).paradigmName = thisParadigm;
%     dataInfo.byParadigm(iParadigm).participantList = {}; 
%     dataInfo.byParadigm(iParadigm).byParticipant = [];
%     % Loop through participants and check if they've done this paradigm.
%     for iPpt = 1:length(participantList),            
%         %Did they do this paradigm?
%         if any(strcmp(thisParadigm,dataInfo.byParticipantParadigmName{iPpt}));  
%             %This is some dangerous growing of indices within a loop
%             %
%             dataInfo.byParadigm(iParadigm).participantList{end+1} = participantList{iPpt};
%             dataInfo.byParadigm(iParadigm).byParticipant(end+1).name = participantList{iPpt};
%             
%             fileIndices = intersect(dataInfo.participantSessionList{iPpt},dataInfo.paradigmFileIndices{iParadigm});
%             dataInfo.byParadigm(iParadigm).byParticipant(end).fileIndices = fileIndices;
%             dataInfo.byParadigm(iParadigm).byParticipant(end).fileNames = dataInfo.fileNames(fileIndices);
%             dataInfo.byParadigm(iParadigm).byParticipant(end).sessionInfo = dataInfo.sessionInfo(fileIndices);
% 
%         end
%     end
%     
dataInfo.byParadigm(iParadigm).participantList = dataInfo.byParadigmParticipantList{iParadigm};

for iPpt = 1:length(dataInfo.byParadigm(iParadigm).participantList),

    thisPptId = dataInfo.byParadigm(iParadigm).participantList{iPpt};
    pptIdx = strcmp(thisPptId,participantList);
    
    fileIndices = intersect(dataInfo.participantSessionList{pptIdx},dataInfo.paradigmFileIndices{iParadigm});
    
    dataInfo.byParadigm(iParadigm).byParticipant(iPpt).name = thisPptId;
    dataInfo.byParadigm(iParadigm).byParticipant(iPpt).fileIndices = fileIndices;
    dataInfo.byParadigm(iParadigm).byParticipant(iPpt).fileNames = dataInfo.fullPathFileName(fileIndices);
    dataInfo.byParadigm(iParadigm).byParticipant(iPpt).sessionInfo = dataInfo.sessionInfo(fileIndices);
end



end

dataInfo.participantList = participantList;

dataInfo.sessionGrouping = sessionGrouping;



