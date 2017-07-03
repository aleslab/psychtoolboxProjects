function [ conditionInfo, expInfo ] = ptbCorgiLoadParadigm( paradigmFile, expInfo )
%ptbCorgiLoadParadigm Load ptbCorgi paradigm definition
%   [ conditionInfo, expInfo ] = ptbCorgiLoadParadigm( [see help text] )
%
%Implements loading paradigm files from multiple formats:
%
%Examples:
%1) Paradigm Function:
%If the paradigm is defined using a function you can pass in either a
%handle to the function or the name of the m file that defines the
%function:
%[ conditionInfo, expInfo ] = ptbCorgiLoadParadigm(@ParadigmFunction)
%[ conditionInfo, expInfo ] = ptbCorgiLoadParadigm('ParadigmFunction.m')
%
%2) Session File:
%If the paradigm if 
%[ conditionInfo, expInfo ] = ptbCorgiLoadParadigm('sessionFile.mat')



%If we pass in a character array it can either be an m file or a mat file
if ischar(paradigmFile)
    
    if ~exist(paradigmFile,'file')
        error('ptbCorgi:loadParadigm:fileNotFound',...
            'Error file not found: %s',paradigmFile);
    end
    
    [filePath, fileName, fileExt] = fileparts(paradigmFile);
    
    
    %If it's an m file turn it into a function handle:
    if strcmp(fileExt,'.m')
        paradigmFile = str2func(fileName);
    elseif ~strcmp(fileExt,'.mat')
        error('ptbCorgi:loadParadigm:inputError',...
            'File must be either *.m or *.mat');
    end
    
end


%If it's a function handle execute the function to create the paradigm.
%We can just execute the function to load the paradigm.
if isa(paradigmFile,'function_handle')
    msg = sprintf('Loading paradigm using funtion %s()', func2str(paradigmFile));
    disp(msg);
    %Call the function
    if nargin < 2
        [ conditionInfo, expInfo ] = paradigmFile();
    else
        [ conditionInfo, expInfo ] = paradigmFile(expInfo);
    end
    
    %Mat files are a bit more complicated.
    %since mat files contain a preloaded paradigm some things might have been
    %specific to the machine that originally loaded the paradigm
elseif strcmpi(fileExt,'.mat')
    
    msg = sprintf('Loading paradigm using file: %s', paradigmFile);
    disp(msg);
    
%     if nargin ==2 && ~isempty(expInfo)
%         warning('ptbCorgi:loadParadigm:expInfoIgnored',...
%             'expInfo argument ignored when loading .mat paradigm');
%     end
    %define fields we will overwrite when loading a paradigm from a saved
    %session. These are fields we don't want to use for the new session.
    %That's because a previous session may have been run on a different
    %system and we don't want to inherent things like calibration settings.
    
    %We will use the current calibration settings instead of the saved
    %state.
    fieldsToRemove = {...
        'monitorWidth',...
        'sizeCalibInfo',...
        'gammaTable',...
        'lumCalibInfo',...
        };
    
    loadedFile = load(paradigmFile);
    
    %If it is a ptbCorgi session file take the appropriate fields
    if isfield(loadedFile,'sessionInfo')
        
        
        conditionInfo = loadedFile.sessionInfo.conditionInfo;
        
        
        %If we have this field the session files have the expInfo as set by
        %the paradigm file before openExperiment adds its defaults.
        if isfield(loadedFile.sessionInfo,'expInfoBeforeOpenExperiment')        
            pdgmExpInfo = loadedFile.sessionInfo.expInfoBeforeOpenExperiment;             
        else %
            pdgmExpInfo = loadedFile.sessionInfo.expInfo;
            warning('ptbCorgi:loadParadigm:oldSession',...
            'Session created prior to v0.32.0, loading all settings from session, not just those set by paradigm file');
        end
        
        %Remove any of the fields to remove if they exist.
        fieldIdx = isfield(pdgmExpInfo,fieldsToRemove);
        pdgmExpInfo = rmfield(pdgmExpInfo,fieldsToRemove(fieldIdx));
        
        expInfo = updateStruct(expInfo,pdgmExpInfo);
        %If this is a paradigm .mat file assume the condiitionInfo and expInfo
        %are set correctly and take as is.
    elseif isfield(loadedFile,'conditionInfo')
        
        %Minimum spec is a conditionInfo field.
        conditionInfo = loadedFile.conditionInfo;
        
        %If there is an expInfo load it too.
        if isfield(loadedFile,'expInfo')
            expInfo = loadedFile.expInfo;
        end
        
    else
        error('ptbCorgi:loadParadigm:fileError',...
            'Paradigm specification not found in file: %s',paradigmFile);
    end
    
end


% else
%     error('ptbCorgi:loadParadigm:inputError',...
%         'Error input variables not recognized');
% end


conditionInfo = validateConditions(expInfo,conditionInfo);

end

