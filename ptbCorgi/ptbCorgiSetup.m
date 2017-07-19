function [] = ptbCorgiSetup()



%Code to make ptbCorgiSetup Singleton:
%Search if the figure exists
h = findall(0,'tag','ptbCorgiSetup');
%If we found the figure bring the focus to front and don't spawn another
%figure. 
if ~(isempty(h))
    figure(h)
    return;
end;

luminanceCalibInfo=[];
sizeCalibInfo     =[];
calibFilenames    = {};

settingsChanged = false; %boolean to set if any setting values have changed

setupPath();
computerName = ptbCorgiGetComputerName();



fh = figure('Visible','on','Units','normalized','Position',[.1 .2 .55 .6],'tag','ptbCorgiSetup');

set(fh,'menu','none','name','ptbCorgiSetup','NumberTitle','off');

uicontrol(fh,'Style','pushbutton',...
    'String','Close',...
    'Units','normalized','Position',[.81 0.05 .15 .05],...
    'callback',@closeSetup);

uicontrol(fh,'Style','pushbutton',...
    'String','Save and Close',...
    'Units','normalized','Position',[.66 0.05 .15 .05],...
    'callback',@saveSetup);


yStartPos = .91;

%Computer Name
uicontrol(fh,'Style','text',...
    'String','Computer Name:',...
    'Units','normalized','Position',[.81 yStartPos .15 .05]);

nameTextBoxHandle = uicontrol(fh,'Style','edit',...
    'String',computerName,...
    'Units','normalized','Position',[.81 yStartPos-.03 .15 .05]);

uicontrol(fh,'Style','pushbutton',...
    'String','Change Name',...
    'Units','normalized','Position',[.81 yStartPos-.09 .15 .05],...
    'callback',@changeComputerName);

%-------------------
%Directories
baseDir = '';
if ispref('ptbCorgi','base')
    baseDir = getpref('ptbCorgi','base');
    if ~exist(baseDir,'dir')        
        rmpref('ptbCorgi','base');
    end
end

%Setup the base dir automatically
if ~exist(baseDir,'dir')
    fprintf('Cannot find base dir: %s\n',baseDir);
    baseDir = fileparts(which('ptbCorgi.m'));
    fprintf('Setting base dir preference to: %s\n',baseDir);
    setpref('ptbCorgi','base',baseDir);
end

dataDir = '';
if ispref('ptbCorgi','datadir');
    dataDir = getpref('ptbCorgi','datadir');
    if ~exist(dataDir,'dir')
        rmpref('ptbCorgi','datadir');
    end
end

if ~exist(dataDir,'dir')
    dataDir = '';
end

calibDir = '';
if ispref('ptbCorgi','calibdir');
    calibDir = getpref('ptbCorgi','calibdir');
    if ~exist(calibDir,'dir')
        rmpref('ptbCorgi','calibdir');
    end
end

if ~exist(calibDir,'dir')
    calibDir = '';
end

uicontrol(fh,'Style','text',...
    'String','Base Directory:','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .91 .15 .05]);

baseDirHandle = uicontrol(fh,'Style','edit',...
    'String',baseDir,'HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .88 .4 .05]);

uicontrol(fh,'Style','pushbutton',...
    'String','Choose ptbCorgi base directory','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .825 .25 .05],...
    'callback',@chooseBaseDir);

yPad = .02;

uicontrol(fh,'Style','text',...
    'String','Directory to save data:','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .77-yPad .25 .05]);

dataDirHandle = uicontrol(fh,'Style','edit',...
    'String',dataDir,'HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .74-yPad .4 .05]);

uicontrol(fh,'Style','pushbutton',...
    'String','Choose Data Directory','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 .685-yPad .25 .05],...
    'callback',@chooseDataDir);

yPos = .63-yPad*2;
uicontrol(fh,'Style','text',...
    'String','Directory to save calibration:','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 yPos .3 .05]);

calibDirHandle = uicontrol(fh,'Style','edit',...
    'String',calibDir,'HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 yPos-.03 .4 .05]);

uicontrol(fh,'Style','pushbutton',...
    'String','Choose Calibration Directory','HorizontalAlignment','left',...
    'Units','normalized','Position',[.35 yPos-.08 .25 .05],...
    'callback',@chooseCalibDir);




%--------
%device
deviceIdx = 1;
deviceList = {'None','Bits Sharp'};
validateBitsVisible = 'off';
useBitsSharp = false;

if ispref('ptbCorgi','useBitsSharp');
    
    useBitsSharp = getpref('ptbCorgi','useBitsSharp');    
    if useBitsSharp
        deviceIdx = 2;
        deviceList = {'None','Bits Sharp *ptbCorgi*'};
        validateBitsVisible='on';
    end    
end


yPos = .4;
devicePopupH = uicontrol(fh,'Style','popupmenu',...
    'String',deviceList,'Value',deviceIdx,...
    'Units','normalized','Position',[.1 yPos 0.2 .05],...
    'callback',@selectDevice);

uicontrol(fh,'Style','text','String','Output Device',...
    'Units','normalized','Position',[0 yPos 0.1 .05])

% uicontrol(fh,'Style','pushbutton',...
%     'String','Validate Bits Sharp',...
%     'Units','normalized','Position',[0 .2 0.3 .05],...
%     'visible',validateBitsVisible,'callback',@validateBitsSharp);


%---------------------
%Resolution

[screenPref resPref hzPref bitDepthPref] = getPtbCorgiMonPref();
calibList = ptbCorgiGetCalibFileList(calibDir);

%Setup the screen selection popup.
%TODO: Fix for when monitor disappears when monitors are off
screenHandleList = Screen('screens');
screenLabelList = cellstr(num2str(screenHandleList(:)));

selScreenIdx = find(screenHandleList==screenPref);

selScreenNum = screenHandleList(selScreenIdx);

%screenNumberList{selScreenIdx} = [screenNumberList{selScreenIdx} ' *ptbCorgi*'];

resList = Screen('resolutions',selScreenNum);


%Setup the resolution popup
curRes= Screen('resolution',selScreenNum);
allRes  = getAllResolutionStr();
availRes= getUniqueResolutionsStr();

selResIdx = find(strcmp(availRes,resPref)); %Selected Default resolution
selResString = availRes{selResIdx};
curResIdx = find(strcmp(num2str([curRes.width curRes.height],'%dx%d'),availRes));

resLabels=availRes;
resLabels{curResIdx} = [resLabels{curResIdx} ' *Current Active*'];
resLabels{selResIdx} = [resLabels{selResIdx} ' *ptbCorgi*'];


frameRateList = getUniqueFrameRateStr();
frameRateLabels = frameRateList;
selFrameRateIdx = find(strcmp(frameRateList,num2str(hzPref)));
frameRateLabels{selFrameRateIdx} = [frameRateList{selFrameRateIdx} '*'];

bitDepthList  = getUniqueBitDepthStr();
bitDepthLabels = bitDepthList;


%Init Resolution Controls. 
yPos = .88;
popWidth = .2;

uicontrol(fh,'Style','text',...
    'String','Video Mode Settings','HorizontalAlignment','center',...
    'Units','normalized','Position',[0 .91 .3 .05]);

screenPopupH = uicontrol(fh,'Style','popupmenu',...
    'String',screenLabelList,'Value',selScreenIdx,...
    'Units','normalized','Position',[.1 yPos popWidth .05],...
    'callback',@changeScreen);

uicontrol(fh,'Style','text','String','Screen Number',...
    'Units','normalized','Position',[0 yPos 0.1 .05])


resPopupH = uicontrol(fh,'Style','popupmenu',...
    'String',resLabels,'Value',selResIdx,...
    'Units','normalized','Position',[.1 yPos-.04 popWidth .05],...
    'callback',@changeResolution);

uicontrol(fh,'Style','text','String','Resolution',...
    'Units','normalized','Position',[0 yPos-.04 0.1 .05])


frameRatePopupH = uicontrol(fh,'Style','popupmenu',...
    'String',frameRateLabels,'Value',selFrameRateIdx,...
    'Units','normalized','Position',[.1 yPos-.08 popWidth .05],...
    'callback',@changeFrameRate);

uicontrol(fh,'Style','text','String','Refresh',...
    'Units','normalized','Position',[0 yPos-.08 0.1 .05])


bitDepthPopupH = uicontrol(fh,'Style','popupmenu',...
    'String',bitDepthList,...
    'Units','normalized','Position',[.1 yPos-.12 popWidth .05]);

uicontrol(fh,'Style','text','String','Bit Depth',...
    'Units','normalized','Position',[0 yPos-.12 0.1 .05])

uicontrol(fh,'Style','pushbutton',...
    'String','Calibrate Selected Mode',...
    'Units','normalized','Position',[0 yPos-.18 0.3 .05],...
    'callback',@calibrateMode);


calibFileListH = uicontrol(fh,'Style','listbox',...
    'String',{'None'},...
    'Units','normalized','Position',[0.01 yPos-.42 0.29 .15]);

uicontrol(fh,'Style','text','HorizontalAlignment','left',...
'String', 'Calibration Files for Selected Mode',...
    'Units','normalized','Position',[0 yPos-.25 0.3 .035])


uicontrol(fh,'Style','pushbutton',...
    'String','Save Mode Selections as default',...
    'Units','normalized','Position',[0 .2 0.3 .05],...
    'callback',@setPtbCorgiModePref);


updateCalibFileList();


    function chooseBaseDir(varargin)
        
        startpath=which('ptbcorgi.m');
        [startpath] = fileparts(startpath);
        [dirname] = ...
            uigetdir(startpath,'Pick Base Dir');
        
        
        if dirname == 0 
            return;
        else                       
            set(baseDirHandle,'String',dirname);
            settingsChanged = true;
        end 
            
        
    end


    function chooseDataDir(varargin)
        
        startpath=which('ptbcorgi.m');
        [startpath] = fileparts(startpath);
        [dirname] = ...
            uigetdir(startpath,'Pick Data Dir');
        
        if dirname == 0
            return;
        else
            set(dataDirHandle,'String',dirname);
            settingsChanged = true;
        end
                
    end

    function chooseCalibDir(varargin)
        
        startpath=which('ptbcorgi.m');
        
        [startpath] = fileparts(startpath);
        [dirname] = ...
            uigetdir(startpath,'Pick Calibration Dir');
        
        
        if dirname == 0
            return;
        else
            set(calibDirHandle,'String',dirname);
            settingsChanged = true;
        end
        
        calibDir = dirname;
        calibList = ptbCorgiGetCalibFileList(calibDir);
        updateCalibFileList();
    end

    function selectDevice(hObject,callbackdata)
      
        deviceIdx = get(hObject,'value');
        
        if deviceIdx == 2
            useBitsSharp = true;
        else
            useBitsSharp = false;
        end
        
        
    end
        

    function [screenPref resPref hzPref bitDepthPref]=getPtbCorgiMonPref()        
        
        if ispref('ptbCorgi','resolution');
            res = getpref('ptbCorgi','resolution');
            screenPref = res.screenNum;
            resPref = num2str([res.width res.height],'%dx%d');
            hzPref    = res.hz;
            bitDepthPref = res.pixelSize;            
        else
            screenPref= max(Screen('screens'));
            curRes    = Screen('resolution',screenPref);
            resPref   = num2str([curRes.width curRes.height],'%dx%d');
            hzPref    = curRes.hz;
            bitDepthPref = curRes.pixelSize;
%             screenPref= [];
%             resPref   = '';
%             hzPref    = [];
%             bitDepthPref = [];
        end
        
        
    end

    function changeComputerName(varargin)
        computerName = get(nameTextBoxHandle,'string');
    end

 

    %Build video mode structure from selection.
    function res = getSelVideoModeStruct()
        
        [scan] = sscanf(selResString,'%dx%d');
        res.width = scan(1);
        res.height = scan(2);
        
        bitDepthSelIdx  = get(bitDepthPopupH,'value');
        bitDepthStrings = get(bitDepthPopupH,'string');
        res.pixelSize = str2double(bitDepthStrings(bitDepthSelIdx));
        
        frameRateSelIdx = get(frameRatePopupH,'value');
        res.hz = str2double(frameRateList(frameRateSelIdx));
        res.screenNum = selScreenNum;
    end

    function allRes= getAllResolutionStr()

        resList = Screen('resolutions',selScreenNum);

        %Dense bit that creates a 2 column matrix with the unique resolutions
        allResolutions = [resList(:).width; resList(:).height]'; %Concat width and height
        allRes = strtrim(cellstr(num2str(allResolutions,'%dx%d'))); %Format string
        

    end

    function uniqueRes= getUniqueResolutionsStr()
        allResolutions = getAllResolutionStr();
        uniqueRes= unique(allResolutions);%Sort and remove duplicates        
    end

    
    function uniqueFrameRate = getUniqueFrameRateStr()
        
        matchingResIdx = strcmp(availRes{selResIdx},allRes);
        uniqueHz = flipud(unique([resList(matchingResIdx).hz]','sorted','rows'));
        uniqueFrameRate = strtrim(cellstr(num2str(uniqueHz)));
    end

    function uniqueBitDepth = getUniqueBitDepthStr()
        
        matchingResIdx = strcmp(availRes{selResIdx},allRes);
        
        selHz = str2num(frameRateList{selFrameRateIdx});
        
        matchingFrameRateIdx = [ resList(:).hz]==selHz;
        matchingIdx = matchingResIdx(:) & matchingFrameRateIdx(:);

        uniqueBitDepth=flipud(unique([resList(matchingIdx).pixelSize]','sorted','rows'));
        uniqueBitDepth=strtrim(cellstr(num2str(uniqueBitDepth)));
    end


    function changeScreen(varargin)
        
        selScreenIdx = get(screenPopupH,'value');
        selScreenNum = screenHandleList(selScreenIdx);
        
        
        %Setup the resolution popup
        curRes= Screen('resolution',selScreenNum);
        allRes  = getAllResolutionStr();
        availRes= getUniqueResolutionsStr();
        
        curResIdx = find(strcmp(num2str([curRes.width curRes.height],'%dx%d'),availRes));
        selResIdx = find(strcmp(availRes,resPref)); %Selected Default resolution
        selResString = availRes{selResIdx};
        resLabels=availRes;
        resLabels{curResIdx} = [resLabels{curResIdx} ' *Current Active*'];
        resLabels{selResIdx} = [resLabels{selResIdx} ' *ptbCorgi*'];
        
        %resLabels{selResIdx} = [resLabels{selResIdx} ' *ptbCorgi*'];
        set(resPopupH,'string',resLabels,'value',selResIdx)

        changeResolution();
        
        
        
        
    end


    function changeResolution(varargin)
        
        selResIdx = get(resPopupH,'value');%What resolution was selected
        selResString = availRes{selResIdx};
        
        frameRateList = getUniqueFrameRateStr();
        frameRateLabels = frameRateList;
        selFrameRateIdx = find(strcmp(frameRateList,num2str(hzPref)));
        frameRateLabels{selFrameRateIdx} = [frameRateList{selFrameRateIdx} '*'];

        
        set(frameRatePopupH,'string',frameRateLabels);
        changeFrameRate();
        
    end

    function changeFrameRate(hObject,callbackdata)
        
        selFrameRateIdx = get(frameRatePopupH,'value');
        
        bitDepthList  = getUniqueBitDepthStr();
        bitDepthLabels = bitDepthList;
        
        set(bitDepthPopupH,'string',bitDepthLabels);        
        selBitDepthIdx = get(bitDepthPopupH,'value');
        
        updateCalibFileList();
    end
   
    function calibrateMode(hObject,callbackdata)
        
        res = getSelVideoModeStruct();
        res.useBitsSharp = useBitsSharp;
        calibrateDisplay(res);
        calibList = ptbCorgiGetCalibFileList(calibDir);
        updateCalibFileList();
    end

    function updateCalibFileList(hObject,callbackdata)
        
        modeString = generateModeString(getSelVideoModeStruct());
        calibListIdx = [];
        if ~isempty(calibList)
            calibListIdx = find( strcmp({calibList(:).modeString},modeString));
        end
        
        currentActiveCalibFile = '';
        if ispref('ptbCorgi','calibrationFile'),
            currentActiveCalibFile = getpref('ptbCorgi','calibrationFile');
        end
        
        
        listBoxLabels = {'None'};
        calibFilenames = listBoxLabels;
        selFile = 1;
        if ~isempty(calibListIdx)
            listBoxLabels = calibList(calibListIdx).names;                        
            listBoxLabels = {'None', listBoxLabels{:}};
            
            calibFilenames = listBoxLabels;
            
            %Append the calibration directory to the filename list
            %This makes sure the full path string is set
            fullPathList = strcat([calibDir filesep],listBoxLabels);
            chosenFileListIdx = strcmp(currentActiveCalibFile,fullPathList);
            
            %If one of the files on the list is the current active one
            %label it with *ptbCorgi* and set it as active. 
            if any(chosenFileListIdx)
                listBoxLabels{chosenFileListIdx} = ...
                    ['*ptbCorgi* ' listBoxLabels{chosenFileListIdx}];
                selFile = find(chosenFileListIdx);
            end
        end
        
        
        set(calibFileListH,'string',listBoxLabels);
        set(calibFileListH,'value',selFile);
    end

    function modeString=generateModeString(res)
                
        modeString = [num2str(res.width) 'x' num2str(res.height) ...
            '_' num2str(res.hz) 'Hz_' num2str(res.pixelSize) 'bpp'];

        
    end

    function calibrationFile = getSelectedCalibrationFile()
                
        calibSelected = get(calibFileListH,'value');       
        calibrationFile = fullfile(calibDir, calibFilenames{calibSelected});
        
        
        if strcmpi('calibrationFile','none')
            calibrationFile = '';
        end
        
    end


    function setPtbCorgiModePref(varargin)
        

        res = getSelVideoModeStruct();        
        calibrationFile = getSelectedCalibrationFile();
       
        setpref('ptbCorgi','resolution',res);
        setpref('ptbCorgi','calibrationFile',calibrationFile);        
        setpref('ptbCorgi','useBitsSharp',useBitsSharp);

        if useBitsSharp
            deviceIdx = 2;
            deviceList = {'None','Bits Sharp *ptbCorgi*'};
            validateBitsVisible='on';
            set( devicePopupH,'value',deviceIdx,'string',deviceList);
        end

        [screenPref resPref hzPref bitDepthPref]=getPtbCorgiMonPref();
        changeScreen();
    end


    function setupPath()
        
        
        %find where this function is being called from.
        thisFile = mfilename('fullpath');
        [thisDir, ~, ~] = fileparts(thisFile);
        
        %For now just grab this and all subdirectories
        newPath2Add = genpath(thisDir);
        
        %Now let's find the directories that are missing and add only them
        %to the path.
        %Why not just add all sub directories to the path and let matlab
        %auto prune redundancies? Well, that always brings the added
        %directoreis top of the path. Which _may_ not be wanted from the
        %user.
        subDirCell = regexp(newPath2Add, pathsep, 'split');
        pathCell = regexp(path, pathsep, 'split');
        
        for iSub = 1:length(subDirCell)
            
            thisFolder = subDirCell{iSub};
            
            %If thisFolder doesn't match any of the directories on the path
            %add it to the path.
            if  ~isempty(thisFolder) && ~any(strcmp(thisFolder, pathCell))
                msg = sprintf('Adding to path: %s',thisFolder);
                disp(msg);
                addpath(thisFolder);
                
            end
            
        end
        
    end

    function closeSetup(hObject,callbackdata)
        
        
        if settingsChanged
            
            
        end
        
        close(fh);
        return;
    end


    function saveSetup(hObject, callbackdata)
        
        
        
        baseDirName = get(baseDirHandle,'String');
        setpref('ptbCorgi','base',baseDirName);
        
        dataDirName = get(dataDirHandle,'String');
        setpref('ptbCorgi','datadir',dataDirName);
        
        calibDirName = get(calibDirHandle,'String');
        setpref('ptbCorgi','calibdir',calibDirName);
        
        setpref('ptbCorgi','computerName',computerName);
        
        
        setPtbCorgiModePref();
        
        close(fh);
        return;
    end


    function resetSetup(hObject,callbackdata)
        
        response = questdlg('Warning this will reset all ptbCorgi settings!',...
            'Reset ptbCorgi settings','Reset','Cancel','Cancel');
        
        if strcmp(response,'Reset')
            rmpref('ptbCorgi');
            rmpref('ptbCorgiDataBrowser');
        end
        
        
        
    end



    function addIndicatorToDropDownMenu()
        resLabels=availRes;
        resLabels{curResIdx} = [resLabels{curResIdx} ' *Current Active*'];
        resLabels{selResIdx} = [resLabels{selResIdx} ' *ptbCorgi*'];
        
        
        
    end

end

