function [fh] = chooseCalibrationFile()


if ispref('psychMaster','sizeCalibrationFile');
    sizeFile = getpref('psychMaster','sizeCalibrationFile');
else
    sizeFile = '';
end

if ~exist(sizeFile,'file')
    sizeColor = [1 0 0];
else
    sizeColor = [0.9400 0.9400 0.9400];
end
    
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
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Save Settings',...
        'Units','normalized','Position',[.1 0 .4 .1],...
        'callback',@saveSettings);
    
    uicontrol(fh,'Style','pushbutton',...
        'String','Cancel',...
        'Units','normalized','Position',[.5 0 .4 .1],...
        'callback',@closeGui);
    
    
    function validateFile()        
        sizeFile = get(sizeStringHandle,'String')
        
        if ~exist(sizeFile,'file')
            sizeColor = [1 0 0];
        else
            sizeColor = [0.9400 0.9400 0.9400];
        end
        
        set(sizeStringHandle,'BackgroundColor',sizeColor);
        
    end

    function chooseSizeFile(varargin)
        
    [filename, pathname, filterindex] = ...
        uigetfile('*.mat', 'Pick a size calibration file:');
    
    set(sizeStringHandle,'String',fullfile(pathname,filename));
    validateFile();
    
    end

    function saveSettings(varargin)
        
        setpref('psychMaster','sizeCalibrationFile',get(sizeStringHandle,'String'));
        closeGui();
     
    end

    function closeGui(varargin)
        
        delete(fh);
    end
end
