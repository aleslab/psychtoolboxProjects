function [] = calibrateLuminance()

luminanceCalibInfo=[];
sizeCalibInfo     =[];


computerName = ptbCorgiGetComputerName();

fh = figure('Visible','on','Units','normalized','Position',[.1 .1 .7 .6]);

ah = axes('Visible','on','Units','normalized','Position',[.1 .2 .7 .7]);

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

yStartPos = yStartPos-.25;

btnDelta = .075;
%Measure Size Button
uicontrol(fh,'Style','pushbutton',...
    'String','Measure Size',...
    'Units','normalized','Position',[.81 yStartPos .15 .075],...
    'callback',@measureSize);

%Meaure Luminance Button
uicontrol(fh,'Style','pushbutton',...
    'String','Measure Luminance',...
    'Units','normalized','Position',[.81 yStartPos-btnDelta .15 .075],...
    'callback',@measureCB);

%Fit Luminance Button
uicontrol(fh,'Style','pushbutton',...
    'String','Fit Data',...
    'Units','normalized','Position',[.81 yStartPos-2*btnDelta .15 .075],...
    'callback',@fitCB)

%Test Luminance Calibration Button
uicontrol(fh,'Style','pushbutton',...
    'String','Test Calibration',...
    'Units','normalized','Position',[.81 yStartPos-3*btnDelta .15 .075],...
    'callback',@testCB);



saveBtnH= uicontrol(fh,'Style','pushbutton',...
    'String','Save Settings',...
    'Units','normalized','Position',[.81 .2 .15 .1],...
    'callback',@saveCB,'enable','off');







    function measureSize(varargin)
        %Measure monitor values
        sizeCalibInfo = calibrateSize();
        
        
    end

    function measureCB(varargin)
        %Measure monitor values
        luminanceCalibInfo = measureMonitorLuminance();
        nValues = size(luminanceCalibInfo.allCIExyY,1);
        plot(ah,linspace(0,1,nValues),luminanceCalibInfo.meanCIExyY(:,3),'o');
        hold on;
        ylabel('cd/m^2')
        
    end

    function fitCB(varargin)
        
         nValues = size(luminanceCalibInfo.allCIExyY,1);
         displayValues=linspace(0,1,nValues)';
        %Fit measured data to generate a full gamma table.
        %type = 1 is Fit a simple power function
        [gammaFit,gammaInputFit,fitComment,gammaParams]=FitDeviceGamma(...
            luminanceCalibInfo.meanCIExyY(:,3),displayValues,1,luminanceCalibInfo.clutSize);
        fitX=linspace(0,1,luminanceCalibInfo.clutSize);
        %Invert the gamma fit to linearize the output.
        inverseGamma = InvertGammaTable(linspace(0,1,luminanceCalibInfo.clutSize)',gammaFit,luminanceCalibInfo.clutSize);
        plot(ah,fitX,gammaFit*luminanceCalibInfo.meanCIExyY(end,3));
        
        luminanceCalibInfo.gammaFit     = gammaFit;
        luminanceCalibInfo.gammaInputFit= gammaInputFit;
        luminanceCalibInfo.fitComment   = fitComment;
        luminanceCalibInfo.gammaParams  = gammaParams;
        luminanceCalibInfo.inverseGamma = inverseGamma;
        luminanceCalibInfo.gammaTable = repmat(inverseGamma,1,3);
        
        set(saveBtnH,'enable','on')
        
    end

    function testCB(varargin)
        
        luminanceTest = measureMonitorLuminance(luminanceCalibInfo.inverseGamma);
        nValues = size(luminanceTest.allCIExyY,1);
        plot(ah,linspace(0,1,nValues),luminanceTest.meanCIExyY(:,3),'x');

    end

    function changeComputerName(varargin)
        computerName = get(nameTextBoxHandle,'string');
    end


    function saveCB(varargin)
        %Save the data
        %
        modeString = [num2str(luminanceCalibInfo.modeInfo.width) 'x' num2str(luminanceCalibInfo.modeInfo.height) ...
            '_' num2str(luminanceCalibInfo.modeInfo.hz) 'Hz_' num2str(luminanceCalibInfo.modeInfo.pixelSize) 'bpp_'];
        
        filename = ['luminance_' computerName '_' modeString datestr(now,'yyyymmdd_HHMMSS') '.mat'];
        
        if ispref('ptbCorgi','calibdir');
            calibdir = getpref('ptbCorgi','calibdir');
        elseif ispref('ptbCorgi','base');
            calibdir = fullfile(getpref('ptbCorgi','base'),'calibrationData');
        else
            calibdir = '';
        end
        
        setpref('ptbCorgi','computerName',computerName);
        luminanceCalibInfo.computerName =  computerName;
        saveFilename = fullfile(calibdir,filename);
        
        if ~exist(calibdir,'dir')
            mkdir(calibdir)
        end
        
        save(saveFilename,'-struct','luminanceCalibInfo')
    end

end



