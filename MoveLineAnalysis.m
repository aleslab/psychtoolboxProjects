%cd C:\Users\aril\Documents\Data %lilac room
cd /Users/aril/Documents/psychtoolboxProjects/psychMaster/Data %macbook pro
%Need to automate loading and loop it so that multiple files can be
%analysed at once.

load('MoveLine_cd_AL_20160119_152249.mat');

ResponseTable = struct2table(experimentData); %The data struct is converted to a table

%excluding invalid trials
wantedData = ~(ResponseTable.validTrial == 0); %creates a logical of which trials in the data table were valid
validGivenResponse = ResponseTable.givenResponse(wantedData); %the responses (f or j) for the valid trials
validCondNumber = ResponseTable.condNumber(wantedData); %the condition number of the valid trials
validNullFirst = ResponseTable.nullFirst(wantedData); %whether the null condition was first for the valid trials. 
%0 = test first; 1 = null first.

%may need to convert f and j (first stimulus and second stimulus) to 0 and
%1 so that you can index what is going on. f = 0, j = 1. 
jResponses = strcmp(validGivenResponse, 'j');
jResponseCondNumber = validCondNumber(jResponses);
jResponseNullFirst = validNullFirst(jResponses);
jResponseCondFirst = ~validNullFirst(jResponses);
jResponseNullFirstCondNumber = jResponseCondNumber(jResponseNullFirst);
jResponseCondFirstCondNumber = jResponseCondNumber(jResponseCondFirst);
totalJResponses = length(jResponseCondNumber);

fResponses = ~jResponses;
fResponseCondNumber = validCondNumber(fResponses);
fResponseNullFirst = validNullFirst(fResponses);
fResponseCondFirst = ~validNullFirst(fResponses);
fResponseNullFirstCondNumber = fResponseCondNumber(fResponseNullFirst);
fResponseCondFirstCondNumber = fResponseCondNumber(fResponseCondFirst);
totalFResponses = length(fResponseCondNumber);
%null first j responses

nullFirstJResponsescond1 = nnz(jResponseNullFirstCondNumber==1);
nullFirstJResponsescond2 = nnz(jResponseNullFirstCondNumber==2);
nullFirstJResponsescond3 = nnz(jResponseNullFirstCondNumber==3);
nullFirstJResponsescond4 = nnz(jResponseNullFirstCondNumber==4);
nullFirstJResponsescond5 = nnz(jResponseNullFirstCondNumber==5);
nullFirstJResponsescond6 = nnz(jResponseNullFirstCondNumber==6);
nullFirstJResponsescond7 = nnz(jResponseNullFirstCondNumber==7);

%condition first j responses

condFirstJResponsescond1 = nnz(jResponseCondFirstCondNumber==1);
condFirstJResponsescond2 = nnz(jResponseCondFirstCondNumber==2);
condFirstJResponsescond3 = nnz(jResponseCondFirstCondNumber==3);
condFirstJResponsescond4 = nnz(jResponseCondFirstCondNumber==4);
condFirstJResponsescond5 = nnz(jResponseCondFirstCondNumber==5);
condFirstJResponsescond6 = nnz(jResponseCondFirstCondNumber==6);
condFirstJResponsescond7 = nnz(jResponseCondFirstCondNumber==7);

%null first f responses

nullFirstFResponsescond1 = nnz(fResponseNullFirstCondNumber==1);
nullFirstFResponsescond2 = nnz(fResponseNullFirstCondNumber==2);
nullFirstFResponsescond3 = nnz(fResponseNullFirstCondNumber==3);
nullFirstFResponsescond4 = nnz(fResponseNullFirstCondNumber==4);
nullFirstFResponsescond5 = nnz(fResponseNullFirstCondNumber==5);
nullFirstFResponsescond6 = nnz(fResponseNullFirstCondNumber==6);
nullFirstFResponsescond7 = nnz(fResponseNullFirstCondNumber==7);

%condition first f responses

condFirstFResponsescond1 = nnz(fResponseCondFirstCondNumber==1);
condFirstFResponsescond2 = nnz(fResponseCondFirstCondNumber==2);
condFirstFResponsescond3 = nnz(fResponseCondFirstCondNumber==3);
condFirstFResponsescond4 = nnz(fResponseCondFirstCondNumber==4);
condFirstFResponsescond5 = nnz(fResponseCondFirstCondNumber==5);
condFirstFResponsescond6 = nnz(fResponseCondFirstCondNumber==6);
condFirstFResponsescond7 = nnz(fResponseCondFirstCondNumber==7);

%all conditions total numbers
allcond1 = nnz(validCondNumber==1);
allcond2 = nnz(validCondNumber==2);
allcond3 = nnz(validCondNumber==3);
allcond4 = nnz(validCondNumber==4);
allcond5 = nnz(validCondNumber==5);
allcond6 = nnz(validCondNumber==6);
allcond7 = nnz(validCondNumber==7);

%conditions 1-3 are slower than the null. Therefore if they are responding
%to the faster stimulus, if the condition was first, we would expect them to
%respond 'j' to indicate the second stimulus, but if the null was first, 
%we would expect them to respond 'f'. Therefore:

cond1percentCondFaster = (condFirstJResponsescond1 + nullFirstFResponsescond1)/allcond1;
cond2percentCondFaster = (condFirstJResponsescond2 + nullFirstFResponsescond2)/allcond2;
cond3percentCondFaster = (condFirstJResponsescond3 + nullFirstFResponsescond3)/allcond3;

%conditions 4-7 are greater than or equal to the null. Therefore if they
%are responding to the faster stimulus, we would expect an f response if
%the condition was first and a j response if the null was first. 

cond4percentCondFaster = (condFirstFResponsescond4 + nullFirstJResponsescond4)/allcond4;
cond5percentCondFaster = (condFirstFResponsescond5 + nullFirstJResponsescond5)/allcond5;
cond6percentCondFaster = (condFirstFResponsescond6 + nullFirstJResponsescond6)/allcond6;
cond7percentCondFaster = (condFirstFResponsescond7 + nullFirstJResponsescond7)/allcond7;

conditionFasterPercentages = [cond1percentCondFaster cond2percentCondFaster ...
    cond3percentCondFaster cond4percentCondFaster cond5percentCondFaster ...
    cond6percentCondFaster cond7percentCondFaster];
condVelocities = [0.8 0.9 0.95 1 1.05 1.1 1.2];
%Creating a graph of the percentage correct responses against the 
%velocities as a percentage of the null.
figure
plot(condVelocities, conditionFasterPercentages, '-xk');
axis([0.80 1.20 0 1]);
set(gca, 'YTick', 0:0.1:1);
set(gca, 'YTickLabel', 0:10:100);
xlabel('Velocity as a percentage of the null');
ylabel('Percentage "condition faster" responses');

