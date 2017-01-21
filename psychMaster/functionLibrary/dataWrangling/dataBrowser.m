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

% Last Modified by GUIDE v2.5 21-Jan-2017 15:29:47

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

% Choose default command line output for dataBrowser
handles.output = hObject;

if ispref('psychMaster','datadir');
    handles.datadir = getpref('psychMaster','datadir');
else
    handles.datadir = [];
end

  
% Update handles structure
guidata(hObject, handles);

loadData(hObject);  

% UIWAIT makes dataBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function loadData(hObject)
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
loadData(hObject);
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
