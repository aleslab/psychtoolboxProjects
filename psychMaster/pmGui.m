function varargout = pmGui(varargin)
% PMGUI MATLAB code for pmGui.fig
%      PMGUI, by itself, creates a new PMGUI or raises the existing
%      singleton*.
%
%      H = PMGUI returns the handle to a new PMGUI or the handle to
%      the existing singleton*.
%
%      PMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PMGUI.M with the given input arguments.
%
%      PMGUI('Property','Value',...) creates a new PMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pmGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pmGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pmGui

% Last Modified by GUIDE v2.5 20-Feb-2016 06:51:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pmGui_OpeningFcn, ...
                   'gui_OutputFcn',  @pmGui_OutputFcn, ...
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


% --- Executes just before pmGui is made visible.
function pmGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pmGui (see VARARGIN)

% Choose default command line output for pmGui
handles.output = hObject;
if length(varargin)>0
    handles.sessionInfo = varargin{1};
    handles.expInfo = varargin{2};

end

% Update handles structure
guidata(hObject, handles);

if ispref('psychMaster','lastParadigmFile')
    lastParadigmFile = getpref('psychMaster','lastParadigmFile');
else
    lastParadigmFile = [];
end

handles.sessionInfo.paradigmFile = lastParadigmFile;

if ~exist(handles.sessionInfo.paradigmFile,'file')
    lastParadigmFile = [];
elseif exist(handles.sessionInfo.paradigmFile,'file')~=2
    error('Paradigm file must be in the matlab path')
else    
    [pathstr, funcName, ext ] = fileparts(handles.sessionInfo.paradigmFile);        
    handles.sessionInfo.paradigmFile = [funcName ext];
    handles.sessionInfo.paradigmPath = pathstr;
    handles.sessionInfo.paradigmFun = str2func(funcName);
    
    
    guidata(hObject,handles);
    loadParadigmFile(hObject);
    handles = guidata(hObject);
end

if ispref('psychMaster','lastParticipantId')
    lastParticipantId = getpref('psychMaster','lastParticipantId');
else
    lastParticipantId = [];
end
set(handles.participantIdText,'String',lastParticipantId);
handles.sessionInfo.participantID = lastParticipantId;


% Update handles structure
guidata(hObject, handles);
% UIWAIT makes pmGui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pmGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%Not sure 
handles = guidata(hObject);

varargout{1} = handles.sessionInfo;
varargout{2} = handles.expInfo;
varargout{3} = handles.conditionInfo;
% The figure can be deleted now
delete(handles.figure1);



% --- Executes on button press in runExperimentBtn.
function runExperimentBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runExperimentBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%pmGui_OutputFcn(hObject, eventdata, handles)

handles.sessionInfo.returnToGui = false;
handles.sessionInfo.userCancelled = true;
guidata(hObject,handles);

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sessionInfo.userCancelled = true;
guidata(hObject,handles);

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

% --- Executes on button press in chooseParadigmBtn.
function chooseParadigmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseParadigmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[handles.sessionInfo.paradigmFile, handles.sessionInfo.paradigmPath] = ...
    uigetfile('*.m','Choose the experimental paradigm file',pwd)
lastParadigmFile = fullfile(handles.sessionInfo.paradigmPath,handles.sessionInfo.paradigmFile);

[~, funcName ] = fileparts(handles.sessionInfo.paradigmFile);
handles.sessionInfo.paradigmFun = str2func(funcName);

setpref('psychMaster','lastParadigmFile',lastParadigmFile);

guidata(hObject,handles);
loadParadigmFile(hObject);



function loadParadigmFile(hObject)
%This line calls the function handle that defines all the paradigm
%information.  ConditionInfo contains the per condition information.
%expInfo contains important
handles = guidata(hObject);

try
    [handles.conditionInfo, handles.expInfo] = handles.sessionInfo.paradigmFun(handles.expInfo);
    set(handles.paradigmFileNameBox,'String',handles.sessionInfo.paradigmFile);
    set(handles.paradigmNameBox,'String',handles.expInfo.paradigmName);
    
    handles.conditionInfo = validateConditions(handles.conditionInfo);
    condNameList = {};
    for iCond = 1:length(handles.conditionInfo)        
        condNameList{iCond} = func2str(handles.conditionInfo(iCond).trialFun);
    end
    
    set(handles.condListbox,'String',condNameList);
    
    guidata(hObject,handles)
    
    
    
catch ME
    disp('<><><><><><> PSYCH MASTER <><><><><><><>')
    disp('ERROR Loading Paradigm File')
    disp('<><><><><><> PSYCH MASTER <><><><><><><>')
    rethrow(ME)
end


function participantIdText_Callback(hObject, eventdata, handles)
% hObject    handle to participantIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of participantIdText as text
%        str2double(get(hObject,'String')) returns contents of participantIdText as a double

handles.sessionInfo.participantID = get(hObject,'String');
setpref('psychMaster','lastParticipantId',handles.sessionInfo.participantID);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function participantIdText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to participantIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%eventdata is a new/not well documented matlab feature .
%This is probably fragile.
%JMA
if strcmp(eventdata.EventName,'Close');
    handles.sessionInfo.userCancelled = true;
    guidata(hObject,handles);
end

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on selection change in condListbox.
function condListbox_Callback(hObject, eventdata, handles)
% hObject    handle to condListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns condListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from condListbox


% --- Executes during object creation, after setting all properties.
function condListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condListbox (see GCBO)
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

selectedCondition = get(handles.condListbox,'Value');

diffFieldNameList = {};

for iCond = 1:length(handles.conditionInfo),
    if iCond == selectedCondition
        continue;
    end
    
    fieldnames = findStructDifferences(...
        handles.conditionInfo(selectedCondition),handles.conditionInfo(iCond));
    
    %Tricky use of grouping operator: []  
    %for concatenating cell arrays [cell1 cell2] works
    %unique() removes duplicates.
    diffFieldNameList = unique([diffFieldNameList fieldnames ]);
end


propertiesGUI( handles.conditionInfo(selectedCondition),diffFieldNameList);


% --- Executes on button press in testCondBtn.
function testCondBtn_Callback(hObject, eventdata, handles)
% hObject    handle to testCondBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCondition = get(handles.condListbox,'Value')

handles.conditionInfo = handles.conditionInfo(selectedCondition);
handles.conditionInfo(1).nReps = 1;
handles.sessionInfo.returnToGui = true;
handles.sessionInfo.userCancelled = false;
guidata(hObject,handles)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)
