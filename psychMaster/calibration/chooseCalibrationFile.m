function [fh] = chooseCalibrationFile()


if ispref('ptbCorgi','sizeCalibrationFile');
    sizeFile = getpref('ptbCorgi','sizeCalibrationFile');
else
    sizeFile = '';
end

sizeColor=fileColor(sizeFile);
 
if ispref('ptbCorgi','lumCalibrationFile');
    lumFile = getpref('ptbCorgi','lumCalibrationFile');
else
    lumFile = '';
end

lumColor = fileColor(lumFile);

    fh = figure('Visible','on','Units','normalized');
    
    uicontrol(fh,'Style','text',...
        'String','Size Calibration File:',...
        'Units','normalized','Position',[.1 .8 .25 .1]);
    
    sizeStringHandle = uicontrol(fh,'Style','edit',...
        'String',sizeFile,...
        'Units','normalized','Position',[.1 .75 .8 .075],...
        'BackgroundColor', sizeColor,'callback',@validateFile);
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Choose Size Calibration File',...
        'Units','normalized','Position',[.1 .62 .4 .1],...
        'callback',@chooseSizeFile);
    
    
    lumStringHandle = uicontrol(fh,'Style','edit',...
        'String',lumFile,...
        'Units','normalized','Position',[.1 .55 .8 .075],...
        'BackgroundColor', sizeColor,'callback',@validateFile);
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Choose Luminance Calibration File',...
        'Units','normalized','Position',[.1 .42 .4 .1],...
        'callback',@chooseLumFile);
    
    
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Save Settings',...
        'Units','normalized','Position',[.1 0 .4 .1],...
        'callback',@saveSettings);
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Cancel',...
        'Units','normalized','Position',[.5 0 .4 .1],...
        'callback',@closeGui);
    
    
    function validateSizeFile()        
       
        sizeFile = get(sizeStringHandle,'String');
        bgColor = [0.9400 0.9400 0.9400];
        try
            sizeInfo = load(sizeFile);
            monitorWidth=sizeInfo.monitorWidth;
        catch ME
            rethrow(ME);
            bgColor = [1 0 0];
        end

        set(sizeStringHandle,'BackgroundColor',bgColor);
        
    end

    function validateLumFile()
       
        lumFile = get(lumStringHandle,'String');
        bgColor = [0.9400 0.9400 0.9400];
      
        try
            lumInfo = load(lumFile);
            gammaT=lumInfo.gammaTable;
        catch ME
            rethrow(ME);
            bgColor = [1 0 0];
        end
        
        set(lumStringHandle,'BackgroundColor',bgColor);
        
    end

    function chooseSizeFile(varargin)
        
    [filename, pathname, filterindex] = ...
        uigetfile('*.mat', 'Pick a size calibration file:');
    
    set(sizeStringHandle,'String',fullfile(pathname,filename));
    validateSizeFile();
    
    end

    function chooseLumFile(varargin)
        
    [filename, pathname, filterindex] = ...
        uigetfile('*.mat', 'Pick a luminance calibration file:');
    
    set(lumStringHandle,'String',fullfile(pathname,filename));
    validateLumFile();
    
    end

    function saveSettings(varargin)
        
        setpref('ptbCorgi','sizeCalibrationFile',get(sizeStringHandle,'String'));
        setpref('ptbCorgi','lumCalibrationFile',get(lumStringHandle,'String'));
        closeGui();
     
    end

    function closeGui(varargin)
        
        delete(fh);
    end

    function bgColor = fileColor(inputFile)
        if ~exist(inputFile,'file')
            bgColor = [1 0 0];
        else
            bgColor = [0.9400 0.9400 0.9400];
        end
    end

end
