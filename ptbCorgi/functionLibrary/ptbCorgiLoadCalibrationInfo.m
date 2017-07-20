function [ expInfo ] = ptbCorgiLoadCalibrationInfo( expInfo )
%ptbCorgiLoadCalibrationInfo Loads stored calibration information. 
%   [ expInfo ] = ptbCorgiLoadCalibrationInfo( expInfo )
%
%This handles loading calibration information that is set from
%ptbCorgiSetup(). It uses the matlab prefefrence 
%getpref('ptbCorgi','calibrationFile') to find which file to load. Then it
%adds the appropriate fields from the file into the expInfo structure. 
%
%
%
%Deprecated is using two files for calibration. This function still
%implements loading of the separate size/luminance files. 
%

if nargin ==0
    expInfo = [];
end

if ispref('ptbCorgi','calibrationFile')
    calibFile = getpref('ptbCorgi','calibrationFile');
    
    if ~exist(calibFile,'file')
        disp('<><><><><><> PTBCORGI <><><><><><><>')
        disp(['Cannot find calibration file: ' calibFile])
    else
        calibInfo = load(calibFile); %loads the variables
        
        foundCalibData = false; %Check 
        if isfield(calibInfo,'sizeCalibInfo')
            expInfo.monitorWidth = calibInfo.sizeCalibInfo.monitorWidth;
            expInfo.sizeCalibInfo = calibInfo.sizeCalibInfo;
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Loading Size Calibration from: ' calibFile])
            foundCalibData = true;
        end
        
        if isfield(calibInfo,'lumCalibInfo')
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Loading Luminance Calibration from: ' calibFile])
            expInfo.gammaTable = calibInfo.lumCalibInfo.gammaTable;
            expInfo.lumCalibInfo = calibInfo.lumCalibInfo;
            foundCalibData = true;
        end
        
        if ~foundCalibData
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['No Calibration info found in file: ' calibFile])
        end                        
    end        
else    
  %Load size calibration:
    if ispref('ptbCorgi','sizeCalibrationFile');
        sizeFile = getpref('ptbCorgi','sizeCalibrationFile');
        if ~exist(sizeFile,'file')
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Cannot find calibration file: ' sizeFile])
        else
            sizeCalibInfo = load(sizeFile); %loads the variable sizeCalibInfo
            expInfo.monitorWidth = sizeCalibInfo.monitorWidth;
            expInfo.sizeCalibInfo = sizeCalibInfo;
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Loading Size Calibration from: ' sizeFile])
        end
    else
        disp('<><><><><><> PTBCORGI <><><><><><><>')
        disp('NO SIZE CALIBRATION HAS BEEN SETUP. Guessing monitor size')
        screenNum = max(Screen('Screens'));
        [w, h]=Screen('DisplaySize',screenNum);
        expInfo.monitorWidth = w/10; %Convert to cm from mm        
   
        
    end
    
    %Load luminance calibration:
    if ispref('ptbCorgi','lumCalibrationFile');
        luminanceFile = getpref('ptbCorgi','lumCalibrationFile');
        if ~exist(luminanceFile,'file') %a calibration is set but doesn't exist.
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Cannot find calibration file: ' luminanceFile])
            
        else %we found the file, now load it.
            lumInfo = load(luminanceFile);
            disp('<><><><><><> PTBCORGI <><><><><><><>')
            disp(['Loading Size Calibration from: ' luminanceFile])
            expInfo.gammaTable = lumInfo.gammaTable;
            expInfo.lumCalibInfo = lumInfo;
        end
    else
        disp('<><><><><><> PTBCORGI <><><><><><><>')
        disp('NO LUMINANCE CALIBRATION HAS BEEN SETUP. Using Identiy LUT')
        
    end
    

end


if ~isfield(expInfo,'monitorWidth')
    disp('<><><><><><> PTBCORGI <><><><><><><>')
    disp('NO SIZE CALIBRATION HAS BEEN SETUP. Guessing monitor size')
    screenNum = max(Screen('Screens'));
    [w, h]=Screen('DisplaySize',screenNum);
    expInfo.monitorWidth = w/10; %Convert to cm from mm
end


