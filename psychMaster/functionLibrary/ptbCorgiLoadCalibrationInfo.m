function [ expInfo ] = ptbCorgiLoadCalibrationInfo( expInfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin ==0
    expInfo = [];
end

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

