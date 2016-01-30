function [] = calibrateLuminance()

luminanceCalibInfo=[]

fh = figure('Visible','on','Units','normalized');

ah = axes('Visible','on','Units','normalized','Position',[.1 .2 .7 .7]);

uicontrol(fh,'Style','pushbutton',...
    'String','Measure Luminance',...
    'Units','normalized','Position',[.81 .9 .15 .1],...
    'callback',@measureCB);


uicontrol(fh,'Style','pushbutton',...
    'String','Fit Data',...
    'Units','normalized','Position',[.81 .8 .15 .1],...
    'callback',@fitCB);


uicontrol(fh,'Style','pushbutton',...
    'String','Test Calibration',...
    'Units','normalized','Position',[.81 .7 .15 .1],...
    'callback',@testCB);


saveBtnH= uicontrol(fh,'Style','pushbutton',...
    'String','Save Settings',...
    'Units','normalized','Position',[.81 .5 .15 .1],...
    'callback',@saveCB,'enable','off');






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


    function saveCB(varargin)
        %Save the data
        %
        modeString = ['_' num2str(luminanceCalibInfo.modeInfo.width) 'x' num2str(luminanceCalibInfo.modeInfo.height) ...
            '_' num2str(luminanceCalibInfo.modeInfo.hz) 'Hz_' num2str(luminanceCalibInfo.modeInfo.pixelSize) 'bpp_'];
        
        filename = ['pm_luminance_' modeString datestr(now,'yyyymmdd_HHMMSS') '.mat'];
        
        if ispref('psychMaster','calibdir');
            calibdir = getpref('psychMaster','calibdir');
        elseif ispref('psychMaster','base');
            calibdir = fullfile(getpref('psychMaster','base'),'calibrationData');
        else
            calibdir = '';
        end
        
        
        saveFilename = fullfile(calibdir,filename);
        
        if ~exist(calibdir,'dir')
            mkdir(calibdir)
        end
        
        save(saveFilename,'-struct','luminanceCalibInfo')
    end

end



