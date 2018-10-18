function adjustMotion()

check = 0; % check config 1 or not 0
% adjust duty cycle or spacing
rng('shuffle');
KbName('UnifyKeyNames');

% get input variables
prompt = {'Output prefix', 'subject''s number'};
defaults = {'adjustMotion','01'};
answer = inputdlg(prompt, 'adjustMotion', 1, defaults);
[outputname, SubjNum] = deal(answer{:});
TIMENOW = fix(clock);
outputname = [outputname '-' SubjNum '-' num2str(TIMENOW(1)) num2str(TIMENOW(2),'%.2d') num2str(TIMENOW(3),'%.2d') '-' num2str(TIMENOW(4))  num2str(TIMENOW(5)) '.txt'];
resultFile = fopen(['DataAdjustMotion' filesep outputname] ,'a');

subj = str2num(SubjNum);
sca


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Screen initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HozResol = 1280;
VerResol = 1024;
monitorWidth = 37.5; % 33.8??
freq_moniteur = 85;
% load calibration file
%load('ptbstimjeeves_1280x1024_85Hz_24bpp_20180403_112434.mat', 'sizeCalibInfo');
viewingDistance = 57;
PsychDefaultSetup(2)
% Set the background to the background value.
screenNum = max(Screen('Screens'));
bckgnd = 0.5;
defaultWindowRect = [0 0 720 720];
%This uses the new "psychImaging" pipeline.
[w, wRect] = PsychImaging('OpenWindow', screenNum, bckgnd,defaultWindowRect);
% PsychColorCorrection('SetEncodingGamma', win, 1/expInfo.lumCalibInfo.gammaParams);

W=wRect(RectRight);
H=wRect(RectBottom);
refreshrate = FrameRate(w); %FrameRate(w)

if check == 1 % Verifications de la configuration
    if W ~= HozResol; clear screen; error('Pas la bonne resolution horizontale'); end;
    if H ~= VerResol; clear screen; error('Pas la bonne resolution verticale'); end;
    if round(refreshrate) ~= freq_moniteur; clear screen; error('Pas la bonne frequence d''affichage, regler le moniteur'); end;
    topPriority = MaxPriority(w); %Determines safest top priorty level for the current system.
    Priority(topPriority); %Sets the priority.
end

monRefresh = 1/refreshrate;
centerx = (wRect(3)-wRect(1))/2;
centery = (wRect(4)-wRect(2))/2;
monitorPeriodSecs = 1/round(monRefresh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% SCALE + location stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pixelWidth, pixelHeight]=Screen('WindowSize', w);
pixPerDeg = (pixelWidth/2)  *   (1/atand( (monitorWidth/2) / viewingDistance));
rectCross = [0 0 0.5 0.5] * pixPerDeg;
rectStim = [0 0 0.5 10] * pixPerDeg;
xcoord = -0.3 * pixPerDeg;
ycoord = 5.5 * pixPerDeg;

HideCursor;
black = BlackIndex(screenNum);

%%% specify stimulus variables
nbRepet = 10; % get 10 adjustment values

motion = [0.6 1 2]; % eccentricity from the other stim in motion condition (xStim = xloc + xMotion)
testedFreq = [85/32 85/16 85/8]; % in Hz this is the onset of the single stimulus

condNb = 1;
for testFq=1:length(testedFreq)
    for tt = 1:length(motion)
        condition(condNb,:) = [testedFreq(testFq) motion(tt)];
        condNb = condNb+1;
    end
end




Screen('FillOval',w,black,CenterRectOnPoint(rectCross,centerx,centery));
t=Screen('Flip', w);
escape=0;
for repet = 1:nbRepet
    if escape
        break;
    end
    order = Shuffle(1:length(condition));
    for cc=1:length(condition)
        if escape
            break;
        end
        %%% VEP parameters
        stimFreq = condition(order(cc),1);
        stimDC = 0.5;
        eccMotion = xcoord + condition(order(cc),2) * pixPerDeg;
        cycle = 1;
        
        framesPerCycle = 1/stimFreq * round(refreshrate);
        framesOn = round(stimDC * framesPerCycle);
        framesOff = framesPerCycle - framesOn;
        pressSpace = 1;
        WaitSecs(0.5);
        
        while pressSpace && escape == 0
            [keyIsDown, secs, keyCode]=KbCheck;
            if keyIsDown
                if keyCode(KbName('space'))
                    pressSpace = 0;
                    break
                elseif keyCode(KbName('escape'))
                    escape=1;
                    break;
                elseif  keyCode(KbName('leftarrow'))
                    framesOn = framesOn +1;framesOff = framesOff -1;
                    if framesOn>framesPerCycle
                        framesOn = framesOn-1;framesOff = framesOff +1;Beeper
                    end
                elseif  keyCode(KbName('rightarrow'))
                    framesOn = framesOn -1;framesOff = framesOff +1;
                    if framesOn==0
                        framesOn = framesOn+1;framesOff = framesOff -1;Beeper
                    end
                end
            end
            
            Screen('FillOval',w,black,CenterRectOnPoint(rectCross,centerx,centery));
            %%% stim ON
            if mod(cycle,2)==1 % in motion
                Screen('FillRect', w, black,CenterRectOnPoint(rectStim,centerx+eccMotion,centery+ycoord));
                cycle = 2;
            else
                Screen('FillRect', w, black,CenterRectOnPoint(rectStim,centerx+xcoord,centery+ycoord));
                cycle = 1;
            end
            t=Screen('Flip', w, t + framesOff * monRefresh - monRefresh/2);
            %%% stim OFF
            Screen('FillRect', w, bckgnd);
            Screen('FillOval',w,black,CenterRectOnPoint(rectCross,centerx,centery));
            t=Screen('Flip', w, t + framesOn * monRefresh - monRefresh/2 );
            
        end
        cycleDuration = 1/stimFreq;
        timeStimOn = monitorPeriodSecs * framesOn;
        timeStimOff = monitorPeriodSecs * framesOff;
        fprintf(resultFile,'%d\t%f\t%f\t%f\t%d\t%d\t%d\t%f\t%f\t%f\n',subj,stimFreq,stimDC,eccMotion,framesPerCycle,framesOn,framesOff,cycleDuration,timeStimOn,timeStimOff);
    end
end


fclose(resultFile);
ShowCursor;
sca;


end
