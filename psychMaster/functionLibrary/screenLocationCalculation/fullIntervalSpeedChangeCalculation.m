%% accelerating depth and lateral slow

ASlownull = 27.2;
BSlownull = 18.0;

ASlowtest = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];
BSlowtest = [18.0 15.8 13.5 11.3 9.01 6.76 4.50];

for iSlow = 1:length(ASlowtest)
    
    fullSlowIntervalChange(iSlow) = ((ASlowtest(iSlow) - BSlowtest(iSlow)) - (ASlownull - BSlownull))/ASlowtest(iSlow);
    
end

%% accelerating depth and lateral fast

AFastnull = 69.5;
BFastnull = 30.1;

AFasttest = [69.5 78.1 86.8 95.5 104.1 112.8 121.4];
BFasttest = [30.1 26.4 22.6 18.8 15.1 11.3 7.53];

for iFast = 1:length(AFasttest)
    
    fullFastIntervalChange(iFast) = ((AFasttest(iFast) - BFasttest(iFast)) - (AFastnull - BFastnull))/AFasttest(iFast);
    
end