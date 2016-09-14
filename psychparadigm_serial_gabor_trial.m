function [conditionInfo,expInfo] = psychparadigm_serial_gabor_trial(expInfo)
expInfo.paradigmName = 'randomtrack';

% use kbQueue's as they have high performance
expInfo.useKbQueue = false;
expInfo.enablePowermate = true;
expInfo.viewingDistance = 57;
if expInfo.enablePowermate
dev = PsychHID('devices');

for iDev = 1:length(dev)

    if  dev(iDev).vendorID== 1917 && dev(iDev).productID == 1040
         expInfo.powermateId = iDev;
         break;
    end
end