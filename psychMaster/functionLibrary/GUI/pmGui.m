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

% Last Modified by GUIDE v2.5 07-Jun-2017 12:24:31

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
    handles.origExpInfo = varargin{2};
    if length(varargin) ==3
        handles.conditionInfo = varargin{3};
    end
end

% Update handles structure
guidata(hObject, handles);

%When the GUI is active we should enable the keyboard and the mouse
ListenChar(0);
if isfield(handles.expInfo, 'screenNum')
    ShowCursor(handles.expInfo.screenNum);
end

if ispref('ptbCorgi','lastParadigmFile')
    lastParadigmFile = getpref('ptbCorgi','lastParadigmFile');
else
    lastParadigmFile = [];
end

handles.sessionInfo.paradigmFile = lastParadigmFile;

if ~exist(handles.sessionInfo.paradigmFile,'file')
    lastParadigmFile = [];
elseif exist(handles.sessionInfo.paradigmFile,'file')~=2
    disp('Paradigm file must be in the matlab path');
else    
    [pathstr, funcName, ext ] = fileparts(handles.sessionInfo.paradigmFile);        
    handles.sessionInfo.paradigmFile = [funcName ext];
    handles.sessionInfo.paradigmPath = pathstr;
    handles.sessionInfo.paradigmFun = str2func(funcName);
    
    
    guidata(hObject,handles);
    loadParadigmFile(hObject);
    handles = guidata(hObject);
end

if ispref('ptbCorgi','lastParticipantId')
    lastParticipantId = getpref('ptbCorgi','lastParticipantId');
else
    lastParticipantId = [];
end

if ispref('ptbCorgi','lastSessionTag')
    lastSessionTag = getpref('ptbCorgi','lastSessionTag');
else
    lastSessionTag = [];
end

set(handles.participantIdText,'String',lastParticipantId);
handles.sessionInfo.participantID = lastParticipantId;

set(handles.sessionTagText,'String',lastSessionTag);
handles.sessionInfo.tag = lastSessionTag;

infoString = [  'v' handles.sessionInfo.ptbCorgiVer ' git SHA: ' handles.sessionInfo.gitHash(1:7)];
set(handles.versionInfoTextBox,'String',infoString);

%Report the size calibration status.
if ~isfield(handles.expInfo, 'sizeCalibInfo')
   set(handles.sizeCalibLoadText,'String','Size Calibration Not Loaded');
   set(handles.sizeCalibLoadText,'BackgroundColor',[1 .2 .2]);
   screenNum = max(Screen('Screens'));
   [w, h]=Screen('DisplaySize',screenNum);
   monitorWidth = w/10; %Convert to cm from mm
    
   set(handles.monWidthText,'String',...
       ['Guessing Monitor Width: ' num2str(monitorWidth) ' cm']);
   set(handles.sizeCalibDateText,'String',['']);


else
    set(handles.sizeCalibLoadText,'String','Size Calibration Loaded');
    set(handles.monWidthText,'String',...
    ['Monitor Width: ' num2str(handles.expInfo.monitorWidth) ' CM']);
 
dateString = datestr(handles.expInfo.sizeCalibInfo.date,'dd-mm-YYYY')
   set(handles.sizeCalibDateText,'String',...
       ['Measured On: ' dateString]);

end

%Report the luminance calibration status.
if ~isfield(handles.expInfo, 'lumCalibInfo')
    set(handles.lumCalibLoadText,'String','Luminance Calibration Not Loaded');
    set(handles.lumCalibLoadText,'BackgroundColor',[1 .2 .2]);
    set(handles.lumCalibDateText,'String',['']);
    
    
else
    set(handles.lumCalibLoadText,'String','Luminance Calibration Loaded');
    
    dateString = datestr(handles.expInfo.lumCalibInfo.date,'dd-mm-YYYY')
    set(handles.lumCalibDateText,'String',...
        ['Measured On: ' dateString]);
    
end


% Update handles structure
guidata(hObject, handles);
movegui('northeast');
%set(handles.runExperimentBtn, 'Value', 1); 
uicontrol(handles.runExperimentBtn) 
% UIWAIT makes pmGui wait for user response (see UIRESUME)
uiwait(handles.pmGuiParentFig);


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
if handles.sessionInfo.userCancelled
    varargout{2} = [];
    varargout{3} = [];
else
    varargout{2} = handles.expInfo;
end

if isfield(handles,'conditionInfo')
    varargout{3} = handles.conditionInfo;
else 
    varargout{3} = [];
end

% The figure can be deleted now
delete(handles.pmGuiParentFig);



% --- Executes on button press in runExperimentBtn.
function runExperimentBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runExperimentBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%pmGui_OutputFcn(hObject, eventdata, handles)

handles.sessionInfo.returnToGui = false;
handles.sessionInfo.userCancelled = false;
guidata(hObject,handles);

%Don't echo keypresses when really running experiment
ListenChar(2);


uiresume(handles.pmGuiParentFig);

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sessionInfo.userCancelled = true;
guidata(hObject,handles);

pmGuiParentFig_CloseRequestFcn(handles.pmGuiParentFig, eventdata, handles);

% --- Executes on button press in chooseParadigmBtn.
function chooseParadigmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseParadigmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


dirToOpen = pwd;
if isfield(handles.sessionInfo,'paradigmPath') && ~isempty(handles.sessionInfo.paradigmPath)
    dirToOpen = handles.sessionInfo.paradigmPath;
end

[handles.sessionInfo.paradigmFile, handles.sessionInfo.paradigmPath] = ...
    uigetfile( {'*.m;*.mat','Paradigm Function (*.m) or Session File (*.mat)';}, ...        
    'Choose the experimental paradigm file', dirToOpen );

if isequal(handles.sessionInfo.paradigmFile,0)
    return;
end

lastParadigmFile = fullfile(handles.sessionInfo.paradigmPath,handles.sessionInfo.paradigmFile);

[~, funcName ] = fileparts(handles.sessionInfo.paradigmFile);
handles.sessionInfo.paradigmFun = str2func(funcName);

setpref('ptbCorgi','lastParadigmFile',lastParadigmFile);

%If we've already loaded a condition delete it and load the new file. 
if isfield(handles,'conditionInfo')
    handles = rmfield(handles,'conditionInfo');
end

guidata(hObject,handles);
loadParadigmFile(hObject);



function loadParadigmFile(hObject)
%This line calls the function handle that defines all the paradigm
%information.  ConditionInfo contains the per condition information.
%expInfo contains important
handles = guidata(hObject);

%Try to load a paradigm file.  There are lots of reasons a paradigm file
%might not be loaded.  Therefore the Try/Catch catches all of them. 
try
   
    
    
    %Read in the paradigm file if condition info isn't already loaded. 
    if ~isfield(handles,'conditionInfo')
        %[handles.conditionInfo, handles.expInfo] = handles.sessionInfo.paradigmFun(handles.origExpInfo);
        [handles.conditionInfo, handles.expInfo] =...
            ptbCorgiLoadParadigm(handles.sessionInfo.paradigmFile,handles.origExpInfo);
    end
    
    set(handles.paradigmFileNameBox,'String',handles.sessionInfo.paradigmFile);
    set(handles.paradigmNameBox,'String',handles.expInfo.paradigmName);
        
    condNameList = {};
    %% Lets create groups. 
    if isfield(handles.expInfo,'conditionGroupingField')
        [ groupingIndices condIdex2GroupIndex ] = ...
            groupConditionsByField( handles.conditionInfo, handles.expInfo.conditionGroupingField );
        %Default to showing the first group 
        condIndices = groupingIndices{1};
        
        groupLabels = getGroupLabels(handles.conditionInfo, handles.expInfo.conditionGroupingField);
        
    else
        groupingIndices = 1:length(handles.conditionInfo);
        condIndices = groupingIndices;
        groupLabels = {'No Groups Defined'}
    end
    
       
    for iCond = 1:length(handles.conditionInfo)
       
        if ~isempty(handles.conditionInfo(iCond).label) %if there's a label use it
            condNameList{iCond} =   handles.conditionInfo(iCond).label;
        else %otherwise create a generic label
            condNameList{iCond} = func2str(handles.conditionInfo(iCond).trialFun);
        end
        
    end
    
    %Now lets order the fieldnames for easy viewing.
    %Putting the Label on top.  This is a bit of a kludgy way to do it
    %
    orderedCond =  orderfields(handles.conditionInfo );
    names = fieldnames(orderedCond);
    labelIdx = find(strcmpi(names,'label'));
    notLabelIdx = find(~strcmpi(names,'label'));
    newPerm =[labelIdx;  notLabelIdx];
    orderedCond =  orderfields(orderedCond,newPerm );
    handles.conditionInfo = orderedCond;
    handles.condNameList = condNameList;
    handles.groupingIndices = groupingIndices;
    
    set(handles.condListbox,'String',condNameList(condIndices));
    set(handles.condGroupListbox,'String',groupLabels);
    
    guidata(hObject,handles)
    
    
    
catch ME
    disp('<><><><><><> PTBCORGI <><><><><><><>')
    disp('ERROR Loading Paradigm File, check your paradigm file')
    disp('The following report should help diagnose what is wrong:')
    disp(' ')
    disp(getReport(ME))
    
    handles.sessionInfo.paradigmFile = '';
    handles.expInfo.paradigmName = '';
    set(handles.paradigmFileNameBox,'String',handles.sessionInfo.paradigmFile);
    set(handles.paradigmNameBox,'String',handles.expInfo.paradigmName);
    
    set(handles.condListbox,'String',{});
end


function participantIdText_Callback(hObject, eventdata, handles)
% hObject    handle to participantIdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of participantIdText as text
%        str2double(get(hObject,'String')) returns contents of participantIdText as a double

handles.sessionInfo.participantID = get(hObject,'String');
setpref('ptbCorgi','lastParticipantId',handles.sessionInfo.participantID);
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







% --- Executes when user attempts to close pmGuiParentFig.
function pmGuiParentFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to pmGuiParentFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%eventdata is a new/not well documented matlab feature .
%This is probably fragile.
%JMA
% if strcmp(eventdata.EventName,'Close');

handles.sessionInfo.userCancelled = true;
guidata(hObject,handles);

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

%selectedCondition = get(handles.condListbox,'Value');
%to implement grouping we need to abstract the condition index outside of
%the listbox:
selectedCondition = getConditionIndex(handles);

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


[hPropsPane, editedConditionInfo] =propertiesGUI( handles.conditionInfo(selectedCondition),diffFieldNameList);

%Check if any fields were changed.  Do a bit of cleaning.
%The editor can provide strings instead of numbers.  In most cases we want
%a number. Therefore if the string is a valid number lets replace it. 
%Also, check to see if the "label" field was changed.  If it was update the
%GUI
changedFieldList = findStructDifferences(handles.conditionInfo(selectedCondition), editedConditionInfo);

if ~isempty( changedFieldList )
    for iChanged = 1:length(changedFieldList)
        
        thisValue = editedConditionInfo.(changedFieldList{iChanged});
        if isstr(thisValue)
            [thisValue2Num,OK]=str2num(thisValue);
            if OK
                editedConditionInfo.(changedFieldList(iChanged)) = thisValue2Num;
            end
        end
        
        %Was the label changed?
        if strcmpi(changedFieldList{iChanged},'label')
            condNameList=get(handles.condListbox,'String');
            condNameList{selectedCondition} = thisValue;
            set(handles.condListbox,'String',condNameList);
        end
    end
    
    editedConditionInfo.label = ['*' editedConditionInfo.label '*']
    %Finaly update the conditionInfo
    handles.conditionInfo(selectedCondition) = editedConditionInfo;
    
    %and Mark the condition as changed
    condNameList=get(handles.condListbox,'String');
    condNameList{selectedCondition} = editedConditionInfo.label;
    set(handles.condListbox,'String',condNameList);
    
    guidata(hObject,handles)
end

function conditionIndex = getConditionIndex(handles)
    
    groupIndex     = get(handles.condGroupListbox,'Value');
    condListIndex  = get(handles.condListbox,'Value');
    conditionIndex = handles.groupingIndices{groupIndex}(condListIndex);
    



% --- Executes on button press in testCondBtn.
function testCondBtn_Callback(hObject, eventdata, handles)
% hObject    handle to testCondBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedCondition = get(handles.condListbox,'Value')
%Backup the preloaded conditions before selecting the test condition. 
handles.sessionInfo.backupConditionInfo = handles.conditionInfo;

handles.conditionInfo = handles.conditionInfo(selectedCondition);
handles.conditionInfo(1).nReps = 1;
handles.sessionInfo.returnToGui = true;
handles.sessionInfo.userCancelled = false;
clear(func2str(handles.conditionInfo.trialFun));
guidata(hObject,handles)
uiresume(handles.pmGuiParentFig);
%pmGuiParentFig_CloseRequestFcn(handles.pmGuiParentFig, eventdata, handles);



function sessionTagText_Callback(hObject, eventdata, handles)
% hObject    handle to sessionTagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sessionTagText as text
%        str2double(get(hObject,'String')) returns contents of sessionTagText as a double

handles.sessionInfo.tag = get(hObject,'String');
setpref('ptbCorgi','lastSessionTag',handles.sessionInfo.tag);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function sessionTagText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sessionTagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in condGroupListbox.
function condGroupListbox_Callback(hObject, eventdata, handles)
% hObject    handle to condGroupListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns condGroupListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from condGroupListbox
groupIndex = get(hObject,'Value');

condIndices = handles.groupingIndices{groupIndex};

set(handles.condListbox,'String',handles.condNameList(condIndices));
set(handles.condListbox,'Value',1);

% --- Executes during object creation, after setting all properties.
function condGroupListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condGroupListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
