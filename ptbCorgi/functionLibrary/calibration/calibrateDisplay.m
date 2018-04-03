function [] = calibrateDisplay(varargin)
% calibrateDisplay GUI to facilitate display calibration
% [] = calibrateDisplay(varargin)
%
% This is a GUI that helps do luminance and size calibration. 


lumCalibInfo      =[];
sizeCalibInfo     =[];

if nargin>=1
    modeToCalibrate = varargin{1};
else
    screenNum = max(Screen('screens'));
    modeToCalibrate = Screen('resolution',screenNum)
    modeToCalibrate.screenNum = screenNum;
    modeToCalibrate.useBitsSharp = false;
end
modeString = [num2str(modeToCalibrate.width) 'x' num2str(modeToCalibrate.height) ...
            '_' num2str(modeToCalibrate.hz) 'Hz_' num2str(modeToCalibrate.pixelSize) 'bpp'];
 
        
expInfo.screenNum = modeToCalibrate.screenNum;
expInfo.requestedResolution = modeToCalibrate;
        
computerName = ptbCorgiGetComputerName();

fh = figure('Visible','on','Units','normalized','Position',[.1 .1 .7 .6]);

ah = axes('Visible','on','Units','normalized','Position',[.1 .2 .6 .7]);

%Mode title
uicontrol(fh,'Style','text',...
    'String',['Calibrating Video Mode: ' modeString],...
    'Units','normalized','Position',[.15 .92 .5 .05],...
    'fontsize',20);

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

yStartPos = yStartPos-.19;

btnDelta = .075;
%Measure Size Button
uicontrol(fh,'Style','pushbutton',...
    'String','Measure Size',...
    'Units','normalized','Position',[.81 yStartPos .15 .075],...
    'callback',@measureSize);

yStartPos = yStartPos-.1;
%Set number of measurements
uicontrol(fh,'Style','text',...
    'String','Number of luminance levels:',...
    'Units','normalized','Position',[.81 yStartPos .15 .05]);

lumNumberBoxH = uicontrol(fh,'Style','edit',...
    'String','64',...
    'Units','normalized','Position',[.81 yStartPos-.03 .15 .05]);

yStartPos = yStartPos-.15;
%Meaure Luminance Button
uicontrol(fh,'Style','pushbutton',...
    'String','Measure Luminance',...
    'Units','normalized','Position',[.81 yStartPos .15 .075],...
    'callback',@measureCB);

%Fit Luminance Button
uicontrol(fh,'Style','pushbutton',...
    'String','Fit Data',...
    'Units','normalized','Position',[.81 yStartPos-1*btnDelta .15 .075],...
    'callback',@fitCB)

%Test Luminance Calibration Button
uicontrol(fh,'Style','pushbutton',...
    'String','Test Calibration',...
    'Units','normalized','Position',[.81 yStartPos-2*btnDelta .15 .075],...
    'callback',@testCB);

%Load Calibration Button
uicontrol(fh,'Style','pushbutton',...
    'String','Load Previous Measurments',...
    'Units','normalized','Position',[.81 yStartPos-3*btnDelta .15 .075],...
    'callback',@loadCB);



saveBtnH= uicontrol(fh,'Style','pushbutton',...
    'String','Save Settings',...
    'Units','normalized','Position',[.81 .1 .15 .1],...
    'callback',@saveCB,'enable','off');







    function measureSize(varargin)
        %Measure monitor values
        sizeCalibInfo = calibrateSize(expInfo);
        
        set(saveBtnH,'enable','on')
        figure(fh);
        
    end

    function measureCB(varargin)
        
        %If we've already run a luminance measurment delete it before giong
        %on. 
        if isfield(expInfo,'gammaTable')
            expInfo = rmfield(expInfo,'gammaTable');
        end
        if isfield(expInfo,'lumCalibInfo')
            expInfo = rmfield(expInfo,'lumCalibInfo');
        end
        %Measure monitor values                
        nValuesToMeasure = str2double( get(lumNumberBoxH,'string'))
        lumCalibInfo = measureMonitorLuminance(expInfo,nValuesToMeasure);
        nValues = size(lumCalibInfo.allCIExyY,1);
        plot(ah,linspace(0,1,nValues),lumCalibInfo.meanCIExyY(:,3),'o');
        hold on;
        ylabel('cd/m^2')
        
    end

    function loadCB(varargin)
        filename=uigetfile();
        allCalibInfo = load(filename);
        lumCalibInfo = allCalibInfo.lumCalibInfo;
        nValues = size(lumCalibInfo.allCIExyY,1);
        plot(ah,linspace(0,1,nValues),lumCalibInfo.meanCIExyY(:,3),'o');
        hold on;
        ylabel('cd/m^2')
    end

    function fitCB(varargin)
        
         nValues = size(lumCalibInfo.allCIExyY,1);
         displayValues=linspace(0,1,nValues)';
        %Fit measured data to generate a full gamma table.
        %type = 1 is Fit a simple power function
        [gammaFit,gammaInputFit,fitComment,gammaParams]=FitDeviceGamma(...
            lumCalibInfo.meanCIExyY(:,3),displayValues,1,lumCalibInfo.clutSize);
        fitX=linspace(0,1,lumCalibInfo.clutSize);
        %Invert the gamma fit to linearize the output.
        inverseGamma = InvertGammaTable(linspace(0,1,lumCalibInfo.clutSize)',gammaFit,lumCalibInfo.clutSize);
        plot(ah,fitX,gammaFit*lumCalibInfo.meanCIExyY(end,3));
        
        lumCalibInfo.gammaFit     = gammaFit;
        lumCalibInfo.gammaInputFit= gammaInputFit;
        lumCalibInfo.fitComment   = fitComment;
        lumCalibInfo.gammaParams  = gammaParams;
        lumCalibInfo.inverseGamma = inverseGamma;
        lumCalibInfo.gammaTable = repmat(inverseGamma,1,3);
        
        expInfo.gammaTable = lumCalibInfo.gammaTable;
        expInfo.lumCalibInfo = lumCalibInfo;
        
        set(saveBtnH,'enable','on')
        
    end

    function testCB(varargin)
        
 
        luminanceTest = measureMonitorLuminance(expInfo);
        
        nValues = size(luminanceTest.allCIExyY,1);
        plot(ah,linspace(0,1,nValues),luminanceTest.meanCIExyY(:,3),'x');

    end

    function changeComputerName(varargin)
        computerName = get(nameTextBoxHandle,'string');
    end


    function saveCB(varargin)
        %Save the data
        %
%         modeString = [num2str(lumCalibInfo.modeInfo.width) 'x' num2str(lumCalibInfo.modeInfo.height) ...
%             '_' num2str(lumCalibInfo.modeInfo.hz) 'Hz_' num2str(lumCalibInfo.modeInfo.pixelSize) 'bpp_'];
%         
        filename = [computerName '_' modeString '_' datestr(now,'yyyymmdd_HHMMSS') '.mat'];
        
        if ispref('ptbCorgi','calibdir');
            calibdir = getpref('ptbCorgi','calibdir');
        elseif ispref('ptbCorgi','base');
            calibdir = fullfile(getpref('ptbCorgi','base'),'calibrationData');
        else
            calibdir = '';
        end
        
        setpref('ptbCorgi','computerName',computerName);
        
        saveFilename = fullfile(calibdir,filename);
        calibdir
        if ~exist(calibdir,'dir')
            mkdir(calibdir)
        end
        
        sizeVarName = '';
        lumVarName = '';
        if ~isempty(lumCalibInfo)
            lumCalibInfo.computerName =  computerName;
            lumVarName = 'lumCalibInfo';
        end
        
        if ~isempty(sizeCalibInfo)
            sizeCalibInfo.computerName =  computerName;
            sizeVarName = 'sizeCalibInfo';
        end
        
        fileInfo.type = 'Calibration'
        fileInfo.createdTime = datestr(now,'YYYY-mm-dd hh:MM PM');
        fileInfo.ptbCorgiVer = ptbCorgiVersion();
        save(saveFilename,lumVarName,sizeVarName,'modeString','fileInfo')
    end

end



