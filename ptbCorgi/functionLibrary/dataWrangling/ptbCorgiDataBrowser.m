function varargout = ptbCorgiDataBrowser(varargin)
% PTBCORGIDATABROWSER GUI to use to browse and load ptbCorgi projects
%
%      ptbCorgiDataBrowser()
%
%      This function creates a GUI that is used to browse multiple data
%      created by ptbCorgi.  It allows for easily loading multiple
%      particpant datasets, and will create a variable in the matlab
%      containing the loaded data. This function chooses which sessions to
%      group together by looking at condition parameters and will only
%      group together conditions with identical condition parameters (ignoring
%      number of repetitions).
%      It will also optionally concatenate multiple session files and 
%      organize and sort data by condition.
%
%      For use in scripts see also: UIGETPTBCORGIDATA
%
%      Returned data is a structure with the fields:
% 
%     paradigmName    = string containing paradigm name.
%     participantList = a cell array with the participant IDs for those  included in the data
%     nParticipants = number of participants. 
%     conditionInfo = conditionInfo structure from the paradigm that was run.
%     nConditions = number of conditions
% 
%     participantData =  A structure with each element being data loaded from a participant 
%                        (i.e. participantData(1) corresponds to data from participantList{1}).
% 
%          sessionInfo      = sessionInfo structure from ptbCorgi
%          experimentData   = experimentData structure from ptbCorgi
%          participantID    = id for this participant. 
%          sortedTrialData  = Data sorted by condition number as returned from organizeData();

%These comments are created by GUIDE
%      PTBCORGIDATABROWSER, by itself, creates a new PTBCORGIDATABROWSER or raises the existing
%      singleton*.
%
%      H = PTBCORGIDATABROWSER returns the handle to a new PTBCORGIDATABROWSER or the handle to
%      the existing singleton*.
%
%      PTBCORGIDATABROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTBCORGIDATABROWSER.M with the given input arguments.
%
%      PTBCORGIDATABROWSER('Property','Value',...) creates a new PTBCORGIDATABROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ptbCorgiDataBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ptbCorgiDataBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ptbCorgiDataBrowser

% Last Modified by GUIDE v2.5 26-Jun-2017 08:32:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ptbCorgiDataBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @ptbCorgiDataBrowser_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ptbCorgiDataBrowser is made visible.
function ptbCorgiDataBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ptbCorgiDataBrowser (see VARARGIN)

global ptbCorgiMakeDataBrowserModal

if isempty(ptbCorgiMakeDataBrowserModal)
    ptbCorgiMakeDataBrowserModal = false;
end


if ptbCorgiMakeDataBrowserModal && length(varargin)<2
        ptbCorgiMakeDataBrowserModal = false;
end

%TODO: SWitch grom global to something different. 
%Possibly use dbstack to find the name of calling function. 
%[st,i] =dbstack(3)
%
% if ~isempty(st) && strcmp(st(1).name,'uiGetPtbCorgiData')
% end

if ptbCorgiMakeDataBrowserModal == true
    %Sets the button that will close the gui
    uicontrol(handles.loadDataBtn);
    % UIWAIT makes pmGui wait for user response (see UIRESUME)
    
    
    handles.output = [];    
    
    % Turn off any element that isn't appropriate for modal opening
    set(handles.loadDataBtn,'string','Load Data'); %Change load button name to be more clear
    turnTheseOff = [handles.organizeDataCheck handles.text8 handles.outputVarNameEditBox];
    set(turnTheseOff,'HandleVisibility','off');
    
    if isempty(varargin{2}) 
        if ispref('ptbCorgiDataBrowser','lastDataDir')
            handles.datadir = getpref('ptbCorgiDataBrowser','lastDataDir');
        else
            handles.datadir = pwd;
        end
    else   
        handles.datadir = varargin{2};
    end
    
    
    
else    
    % Choose default command line output for ptbCorgiDataBrowser
    handles.output = [];

    if ispref('ptbCorgiDataBrowser','lastDataDir')
        handles.datadir = getpref('ptbCorgiDataBrowser','lastDataDir');
    elseif ispref('ptbCorgi','datadir');
        handles.datadir = getpref('ptbCorgi','datadir');
    else
        handles.datadir = [];
    end
end


        
% Update handles structure
guidata(hObject, handles);

loadDataInfo(hObject);  
%If we want a modal box wait till done now. 
if ptbCorgiMakeDataBrowserModal == true
    % UIWAIT makes pmGui wait for user response (see UIRESUME)
    uiwait(handles.dataBrowserParent);
    
end





% --- Outputs from this function are returned to the command line.
function varargout = ptbCorgiDataBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global ptbCorgiMakeDataBrowserModal
% The figure can be deleted now
if ptbCorgiMakeDataBrowserModal == true
    delete(handles.dataBrowserParent);
end


%This function loads and gathers information from all the data files
function loadDataInfo(hObject)
%Load the data from the data directory.
handles = guidata(hObject);

if isempty(handles.datadir) || isequal(handles.datadir,0)
    return
end

set(handles.dataDirText,'String','Loading.......');
drawnow;
[ handles.dataInfo ] = gatherInfoFromAllFiles( handles.datadir );
set(handles.dataDirText,'String',handles.datadir);

if isempty(handles.dataInfo)
    resetLists(hObject);
    return
end


set(handles.listbox1,'String',handles.dataInfo.paradigmList)
handles.selPdgm = 1;
set(handles.listbox2,'String',handles.dataInfo.byParadigm(handles.selPdgm).participantList);

handles.selPpt = 1;
fileNames = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileNames;
set(handles.listbox3,'String',fileNames);

handles.selSession = 1;
handles.selCondition = 1;
sessionIdx = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileIndices(handles.selSession);
conditionLabels = {handles.dataInfo.sessionInfo(sessionIdx).conditionInfo.label};
set(handles.listbox4,'String',conditionLabels);

set(handles.participantIdEditText,'String',...
    handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).name)

set(handles.listbox1,'Value',handles.selPdgm);
set(handles.listbox2,'Value',handles.selPpt);
set(handles.listbox3,'Value',handles.selSession);
set(handles.listbox4,'Value',handles.selCondition);
set(handles.listbox1,'Enable','on');
set(handles.listbox2,'Enable','on');
set(handles.listbox3,'Enable','on');
set(handles.listbox4,'Enable','on');

set(handles.extractCodeMenu,'enable','On')
% Update handles structure
guidata(hObject, handles);


function resetLists(hObject);
handles = guidata(hObject);

set(handles.listbox1,'String',{});
set(handles.listbox2,'String',{});
set(handles.listbox3,'String',{});
set(handles.listbox4,'String',{});

set(handles.listbox1,'Value',[]);
set(handles.listbox2,'Value',[]);
set(handles.listbox3,'Value',[]);
set(handles.listbox4,'Value',[]);

set(handles.listbox1,'Enable','off');
set(handles.listbox2,'Enable','off');
set(handles.listbox3,'Enable','off');
set(handles.listbox4,'Enable','off');
% Update handles structure
guidata(hObject, handles);



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

handles.selPdgm = get(hObject,'Value');
handles.dataInfo.byParadigm(handles.selPdgm).participantList;
set(handles.listbox2,'String',handles.dataInfo.byParadigm(handles.selPdgm).participantList);
set(handles.listbox2,'Value',1);
handles.selPpt = 1;
handles.selSession = 1;
handles.selCondition = 1;
fileNames = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileNames;
set(handles.listbox3,'String',fileNames);
set(handles.listbox3,'Value',handles.selSession);

sessionIdx = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileIndices(handles.selSession);
conditionLabels = {handles.dataInfo.sessionInfo(sessionIdx).conditionInfo.label};
set(handles.listbox4,'String',conditionLabels);
set(handles.listbox4,'Value',handles.selCondition);

set(handles.participantIdEditText,'String',...
    handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).name)

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
contents = cellstr(get(hObject,'String'));
handles.selPpt = get(hObject,'Value');
%pptIdx = find(strcmp(selectedParticipant, handles.dataInfo.participantList));
fileNames = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileNames;
handles.selSession = 1;
handles.selCondition = 1;

set(handles.listbox3,'String',fileNames);
set(handles.listbox3,'Value',handles.selSession);

sessionIdx = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileIndices(handles.selSession);
conditionLabels = {handles.dataInfo.sessionInfo(sessionIdx).conditionInfo.label};
set(handles.listbox4,'String',conditionLabels);
set(handles.listbox4,'Value',handles.selCondition);

set(handles.participantIdEditText,'String',...
    handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).name)

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
handles.selSession = get(hObject,'Value');
handles.selCondition = 1;

sessionIdx = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileIndices(handles.selSession);
conditionLabels = {handles.dataInfo.sessionInfo(sessionIdx).conditionInfo.label};
set(handles.listbox4,'String',conditionLabels);
set(handles.listbox4,'Value',handles.selCondition);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lastDir = [];
if ispref('ptbCorgiDataBrowser','lastDataDir')
    lastDir = getpref('ptbCorgiDataBrowser','lastDataDir');
end

%Check if we've gotten stuck with a bad preference that isn't a string. 
if ~ischar(lastDir)
    lastDir = [];
end
    
dirName = uigetdir(lastDir);

%If the  user presses cancel than don't do anything. 
if dirName == 0
    return;
end

handles.datadir = dirName;
setpref('ptbCorgiDataBrowser','lastDataDir',dirName)
% Update handles structure
guidata(hObject, handles);
loadDataInfo(hObject);


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inspectConditionBtn.
function inspectConditionBtn_Callback(hObject, eventdata, handles)
% hObject    handle to inspectConditionBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCondition = get(handles.listbox4,'Value');

diffFieldNameList = {};
sessionIdx = handles.dataInfo.byParadigm(handles.selPdgm).byParticipant(handles.selPpt).fileIndices(handles.selSession);
conditionInfo = handles.dataInfo.sessionInfo(sessionIdx).conditionInfo;

for iCond = 1:length(conditionInfo),
    if iCond == selectedCondition
        continue;
    end
    
    fieldnames = findStructDifferences(...
        conditionInfo(selectedCondition),conditionInfo(iCond));
    
    %Tricky use of grouping operator: []  
    %for concatenating cell arrays [cell1 cell2] works
    %unique() removes duplicates.
    diffFieldNameList = unique([diffFieldNameList fieldnames ]);
end


[hPropsPane, editedConditionInfo] =propertiesGUI( conditionInfo(selectedCondition),diffFieldNameList);


% --- Executes on button press in loadDataBtn.
function loadDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = guidata(hObject);



% if get(handles.loadAllFilesRadio,'Value')==1
%     
%     filesToLoad =
% else
iParadigm = get(handles.listbox1,'Value');
contents = get(handles.listbox1,'String');
paradigmName = contents{iParadigm};

nPpt = length(handles.dataInfo.byParadigm(iParadigm).participantList);


if get(handles.loadAllPptRadio,'Value')==1
  selectedPpt = 1:nPpt;
else
  selectedPpt = get(handles.listbox2,'Value');
end

% end



for iPpt = 1:length(selectedPpt)

    %this is annoying way to index and make subset. 
    fullPptListIdx = selectedPpt(iPpt);
    
    if get(handles.loadAllFilesRadio,'Value')==1
         fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).fileNames;
    else
        selectedFiles = get(handles.listbox3,'Value');
        fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).fileNames(selectedFiles);
    end
          
    %try t0 load the data
    try
        [loadedData(iPpt).sessionInfo, loadedData(iPpt).experimentData] = loadMultipleSessionFiles(fileList);
        loadedData(iPpt).participantID = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).name;
        
        if get(handles.organizeDataCheck,'Value')==1
            loadedData(iPpt).sortedTrialData = organizeData(loadedData(iPpt).sessionInfo,loadedData(iPpt).experimentData);
        end
        
        validParticipantData(iPpt) = true;
    catch ME
        disp(['Error loading data from participant: ' ...
            handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).name]);
        loadedData(iPpt).errorInfo = ME;
        loadedData(iPpt).message = 'Error loading data';
        loadedData(iPpt).errorLoadingParticipant = true;
        loadedData(iPpt).participantID = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).name;
        validParticipantData(iPpt) = false;
    end
    
    
end

participantErrors = loadedData(~validParticipantData);
loadedData = loadedData(validParticipantData);

if ~any(validParticipantData)
    warning('None of the participants had valid data')
    return;
end


handles.output.paradigmName    = paradigmName;
handles.output.participantList = {loadedData(:).participantID};
handles.output.participantErrorList = {participantErrors(:).participantID};

handles.output.nParticipants = length(handles.output.participantList);
handles.output.conditionInfo = loadedData(1).sessionInfo.conditionInfo;
handles.output.nConditions = length(loadedData(1).sessionInfo.conditionInfo);
handles.output.participantData = loadedData;
handles.output.partipantErrorData = participantErrors;

global ptbCorgiMakeDataBrowserModal
% The figure can be deleted now
if ptbCorgiMakeDataBrowserModal == true    
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.dataBrowserParent);

else
    outputVarName = get(handles.outputVarNameEditBox,'String');
    assignin('base',outputVarName,handles.output);
end






function outputVarNameEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to outputVarNameEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputVarNameEditBox as text
%        str2double(get(hObject,'String')) returns contents of outputVarNameEditBox as a double


% --- Executes during object creation, after setting all properties.
function outputVarNameEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputVarNameEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in organizeDataCheck.
function organizeDataCheck_Callback(hObject, eventdata, handles)
% hObject    handle to organizeDataCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of organizeDataCheck


% --- Executes on button press in loadSelectedFilesRadio.
function loadSelectedFilesRadio_Callback(hObject, eventdata, handles)
% hObject    handle to loadSelectedFilesRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadSelectedFilesRadio

if get(hObject,'Value') == get(hObject,'Max')
    set(handles.loadAllPptRadio,'Value', 0);
    set(handles.loadSelectedPptRadio,'Value', 1);
end


% --- Executes on button press in loadAllPptRadio.
function loadAllPptRadio_Callback(hObject, eventdata, handles)
% hObject    handle to loadAllPptRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadAllPptRadio

if get(handles.loadSelectedFilesRadio,'Value') == 1,
    set(handles.loadAllPptRadio,'Value', 0);
    set(handles.loadSelectedPptRadio,'Value', 1);
    f = errordlg('Loading single file requires loading single participant','Selection Error')
end


% --- Executes when user attempts to close dataBrowserParent.
function dataBrowserParent_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to dataBrowserParent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end



function participantIdEditText_Callback(hObject, eventdata, handles)
% hObject    handle to participantIdEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of participantIdEditText as text
%        str2double(get(hObject,'String')) returns contents of participantIdEditText as a double


% --- Executes during object creation, after setting all properties.
function participantIdEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to participantIdEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in changeAndSaveBtn.
function changeAndSaveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to changeAndSaveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


iParadigm = get(handles.listbox1,'Value');
contents = get(handles.listbox1,'String');
paradigmName = contents{iParadigm};
newPptId = get(handles.participantIdEditText,'String');

nPpt = length(handles.dataInfo.byParadigm(iParadigm).participantList);


selectedPpt = get(handles.listbox2,'Value');
contents = get(handles.listbox2,'String');
selectedPptId = contents{selectedPpt};

% end



if get(handles.loadAllFilesRadio,'Value')==1
    fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(selectedPpt).fileIndices;
else
    selectedFiles = get(handles.listbox3,'Value');
    fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(selectedPpt).fileIndices(selectedFiles);
end

fileList = handles.dataInfo.fullPathFileName(fileList);

for iFile = 1:length(fileList)

    thisFileData = load(fileList{iFile});
    thisFileData.sessionInfo.isEdited = true;
    thisFileData.sessionInfo.previousPptId = selectedPptId;
    thisFileData.sessionInfo.participantID = newPptId;
    
    save(fileList{iFile},'-struct','thisFileData')
    
end

resetLists(hObject);
loadDataInfo(hObject);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function extractCodeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to extractCodeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedFiles = get(handles.listbox3,'Value');
content = get(handles.listbox3,'String');
inputFile = content{selectedFiles};

%Pull off the extension from the file.
[pathstr, filename, ext ] = fileparts(inputFile);

%Lets put things in a directory with the same name as the datafile.
outputDataDir = fullfile(handles.datadir,['code_' filename]);

extractCodeFromDatafile(inputFile,outputDataDir);




 


% --- Executes on button press in printCodeBtn.
function printCodeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to printCodeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


iParadigm = get(handles.listbox1,'Value');
contents = get(handles.listbox1,'String');
paradigmName = contents{iParadigm};

nPpt = length(handles.dataInfo.byParadigm(iParadigm).participantList);


if get(handles.loadAllPptRadio,'Value')==1
  selectedPpt = 1:nPpt;
else
  selectedPpt = get(handles.listbox2,'Value');
end

% end


fullFileList = {};
for iPpt = 1:length(selectedPpt)

    %this is annoying way to index and make subset. 
    fullPptListIdx = selectedPpt(iPpt);
    
    if get(handles.loadAllFilesRadio,'Value')==1
         fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).fileNames;
    else
        selectedFiles = get(handles.listbox3,'Value');
        fileList = handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).fileNames(selectedFiles);
    end
       
    %Concatenate this set of files to the list.  
    fullFileList(end+1: end+length(fileList)) = fileList;
    
end

%Next let's build up some code to load these files. 
disp('%***BEGIN Code autogenerated by ptbCorgiDataBrowser() BEGIN***')
disp(' filesToLoad = { ...');
for iFile = 1 : length(fullFileList)
    thisLine = sprintf( ' ''%s'';...', fullFileList{iFile});
    disp(thisLine);
end
disp('};');
disp('ptbCorgiData = overloadOpenPtbCorgiData( filesToLoad );');
disp('%***END Code autogenerated by ptbCorgiDataBrowser() END***')


% --- Executes during object creation, after setting all properties.
function printCodeBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printCodeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



global ptbCorgiMakeDataBrowserModal
if ptbCorgiMakeDataBrowserModal
set(hObject,'Visible','off')
end
