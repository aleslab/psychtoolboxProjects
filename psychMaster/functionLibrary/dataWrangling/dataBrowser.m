function varargout = dataBrowser(varargin)
% DATABROWSER MATLAB code for dataBrowser.fig
%      DATABROWSER, by itself, creates a new DATABROWSER or raises the existing
%      singleton*.
%
%      H = DATABROWSER returns the handle to a new DATABROWSER or the handle to
%      the existing singleton*.
%
%      DATABROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABROWSER.M with the given input arguments.
%
%      DATABROWSER('Property','Value',...) creates a new DATABROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataBrowser

% Last Modified by GUIDE v2.5 24-Jan-2017 11:30:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @dataBrowser_OutputFcn, ...
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


% --- Executes just before dataBrowser is made visible.
function dataBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataBrowser (see VARARGIN)

global ptbCorgiMakeDataBrowserModal
if isempty(ptbCorgiMakeDataBrowserModal)
    ptbCorgiMakeDataBrowserModal = false;
end




if ptbCorgiMakeDataBrowserModal == true
    %Sets the button that will close the gui
    uicontrol(handles.loadDataBtn);
    % UIWAIT makes pmGui wait for user response (see UIRESUME)
    
    handles.output = [];
    handles.datadir = varargin{2};
    
else    
    % Choose default command line output for dataBrowser
    handles.output = hObject;
    if ispref('psychMaster','datadir');
        handles.datadir = getpref('psychMaster','datadir');
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
function varargout = dataBrowser_OutputFcn(hObject, eventdata, handles) 
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

if isempty(handles.datadir)
    return
end

set(handles.dataDirText,'String',handles.datadir);
[ handles.dataInfo ] = gatherInfoFromAllFiles( handles.datadir );

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

set(handles.listbox1,'Value',handles.selPdgm);
set(handles.listbox2,'Value',handles.selPpt);
set(handles.listbox3,'Value',handles.selSession);
set(handles.listbox4,'Value',handles.selCondition);
set(handles.listbox1,'Enable','on');
set(handles.listbox2,'Enable','on');
set(handles.listbox3,'Enable','on');
set(handles.listbox4,'Enable','on');

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

dirName = uigetdir();
handles.datadir = dirName;
% Update handles structure
guidata(hObject, handles);
loadDataInfo(hObject);
% Update handles structure
guidata(hObject, handles);


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
handles = guidata(hObject);



% if get(handles.loadAllFilesRadio,'Value')==1
%     
%     filesToLoad =
% else
iParadigm = get(handles.listbox1,'Value');

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
    catch ME
        disp(['Error loading data from participant: ' ...
            handles.dataInfo.byParadigm(iParadigm).byParticipant(fullPptListIdx).name]);
        loadedData(iPpt).errorInfo = ME;
        loadedData(iPpt).message = 'Error loading data';
        loadedData(iPpt).errorLoadingParticipant = true;
    end
    
    
end

global ptbCorgiMakeDataBrowserModal
% The figure can be deleted now
if ptbCorgiMakeDataBrowserModal == true
    handles.output = loadedData;
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.dataBrowserParent);

else
    outputVarName = get(handles.outputVarNameEditBox,'String');
    assignin('base',outputVarName,loadedData);
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
