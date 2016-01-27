function sizeCalibInfo=calibrateSize()
%CALIBRATESIZE  Use this to calibrate monitor pixel sizes.
%   [] = psychMaster()

try
    %Open a window
    expInfo = openExperiment();
    Screen('TextSize',expInfo.curWindow, 14);
    
    rectSize = round(min(expInfo.screenRect(3:4))/4); %make a rect half of the window size
    calibSquare = [expInfo.center(1) - rectSize, expInfo.center(2) - rectSize, ...
        expInfo.center(1) + rectSize, expInfo.center(2) + rectSize];
    
    instructions = 'Measure the height and width of the square in centimeters\n If they''re not the same seek professional help\nPress any key to quit';
    
    DrawFormattedTextStereo(expInfo.curWindow, instructions,0,0,[255, 0, 0, 255]);
    Screen('FrameRect',expInfo.curWindow,[],calibSquare);
    Screen('Flip', expInfo.curWindow);
    KbStrokeWait;
    
    %save info that goes with this calibration
    sizeCalibInfo.description = 'Contains monitor size calibration information';
    sizeCalibInfo.date = now;    
    sizeCalibInfo.computer = Screen('Computer');
    %Ok, so HI-DPI displays like retina macs make life oh so fun.  The
    %physical pixels on the display are not equal to the graphical pixels
    %used for rendering.  Need to keep track of this. 
    sizeCalibInfo.modeInfo = Screen('Resolution', expInfo.screenNum); %This gets the screen mode
    [width, height]=Screen('WindowSize', expInfo.screenNum); %This gets the actual pixels the mode is using
    sizeCalibInfo.monitorPixelWidth= width;
    sizeCalibInfo.expInfo = expInfo;
    sizeCalibInfo.calibSquare = calibSquare;
    sizeCalibInfo.squarePixWidth    = 2*rectSize;
    
    closeExperiment;
    
    userResponse = inputdlg('What was the size of the square in centimeters? ');
    
    sizeCalibInfo.measuredSizeCM = str2num(userResponse{1});
    sizeCalibInfo.pixPerCm = sizeCalibInfo.squarePixWidth/sizeCalibInfo.measuredSizeCM;
    
    sizeCalibInfo.monitorWidth =    sizeCalibInfo.monitorPixelWidth/sizeCalibInfo.pixPerCm;
    
    modeString = ['_' num2str(sizeCalibInfo.modeInfo.width) 'x' num2str(sizeCalibInfo.modeInfo.height) ...
        '_' num2str(sizeCalibInfo.modeInfo.hz) 'Hz_' num2str(sizeCalibInfo.modeInfo.pixelSize) 'bpp_'];
    
    filename = ['pm_size_' modeString datestr(now,'yyyymmdd_HHMMSS') '.mat'];
    
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
    
    save(saveFilename,'sizeCalibInfo')
         
    
catch
    
    disp('caught')
    errorMsg = lasterror;
    closeExperiment;
    psychrethrow(psychlasterror);
    
end;


end

