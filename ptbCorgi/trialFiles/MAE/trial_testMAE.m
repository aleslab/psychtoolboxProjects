function [trialData] = trial_testMAE(expInfo, conditionInfo)
% is it the same to superimpose gabors and drifting gratings??????

drawFixation(expInfo, expInfo.fixationInfo);
Screen('Flip', expInfo.curWindow);
WaitSecs(0.1);
drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.validTrial = true;
trialData.abortNow   = false;
trialData.trialStartTime = t;
trialData.response = 999;



% Query frame duration: We use it later on to time 'Flips' properly for an
% animation with constant framerate:
ifi = Screen('GetFlipInterval', expInfo.curWindow);


% Enable alpha-blending, set it to a blend equation useable for linear
% superposition with alpha-weighted source. This allows to linearly
% superimpose gabor patches in the mathematically correct manner, should
% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
% the 'DrawTextures' can be used to modulate the intensity of each pixel of
% the drawn patch before it is superimposed to the framebuffer image, ie.,
% it allows to specify a global per-patch contrast value:
Screen('BlendFunction', expInfo.curWindow, GL_SRC_ALPHA, GL_ONE);

% Create a special texture drawing shader for masked texture drawing:
% Compared to previous demos, we apply the aperture to the grating texture
% while drawing the grating texture, ie. in a single drawing pass, instead
% of applying it in a 2nd pass after the grating has been drawn already.
% This is simpler and faster than the dual-pass method. For this, we store
% the grating pattern in the luminance channel of a single texture, and the
% alpha-mask in the alpha channel of *the same texture*. During drawing, we
% apply a special texture filter shader (created via
% MakeTextureDrawShader()). This shader allows to treat the alpha channel
% separate from the luminance or rgb channels of a texture: It applies the
% alpha channel "as is", but applies some shift to the luminance or rgb
% channels of the texture.
glsl = MakeTextureDrawShader(expInfo.curWindow, 'SeparateAlphaChannel');
    

% Sine gratings
% [x,y]=meshgrid(-s:s, -s:s);
% angle=0*pi/180; % 0 deg orientation = vertical
% f=0.1*2*pi; % cycles/pixel
% a=cos(angle)*f;
% b=sin(angle)*f;
% m=sin(a*x+b*y);
% % figure;imshow(m)


% create a grating (simplified version with no orientation y)
texsize=100; % Half-Size of the grating image.
f=0.05; % Grating cycles/pixel
fr=f*2*pi;
p=ceil(1/f); % pixels/cycle, rounded up.
x = meshgrid(-texsize:texsize + p, -texsize:texsize);
grating = cos(fr*x);
figure;imshow(grating)

% % to add aphase:
% phase = 0 * pi/180;
% grating = cos(f*x + phase);

% % Create circular aperture for the alpha-channel:
% x = meshgrid(-s:s, -s:s);
% gratingAlpha = cos(f*x);
% 
% % Set 2nd channel (the alpha channel) of 'grating'
% grating(:,:,2) = 0;
% grating(1:2*s+1, 1:2*s+1, 2) = gratingAlpha;
    
    
% Build drawable texture from gabor matrix: We set the 'floatprecision' flag to 2,
% so it is internally stored with 32 bits of floating point precision and
% sign. This allows for effectively 8 million (23 bits) of contrast levels
% for both the positive- and the negative "half-lobe" of the patch -- More
% than enough precision for any conceivable display system:
% gratingtex=Screen('MakeTexture', expInfo.curWindow, m, [], [], 2);
gratingtex = Screen('MakeTexture', expInfo.curWindow, grating, [], [], [], [], glsl);


ycoord = expInfo.center(2) - (2 * expInfo.ppd);
xcoord = expInfo.center(1) + (2 * expInfo.ppd);
% Definition of the drawn source rectangle on the screen:
visiblesize = 2*texsize+1;
srcRect=[xcoord ycoord xcoord+visiblesize ycoord+visiblesize];

% Screen('DrawTexture', expInfo.curWindow, gratingtex, texrect, location, [], [], 0.5);
% vbl = Screen('Flip', expInfo.curWindow);

% % Done. Flip one video refresh after the last 'Flip', ie. try to
% % update the display every video refresh cycle if you can.
% % This is the same as Screen('Flip', win);
% % but the provided explicit 'when' deadline allows PTB's internal
% % frame-skip detector to work more accurately and give a more
% % meaningful report of missed deadlines at the end of the script. Not
% % important for this demo, but here just in case you didn't know ;-)
% vbl = Screen('Flip', expInfo.curWindow, vbl + 0.5 * ifi);


% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding!
p = 1/f; % pixels/cycle

% Speed of grating in cycles per second:
cyclespersecond=1;
waitframes = 1;
waitduration = waitframes * ifi;
% Translate requested speed of the gratings (in cycles per second) into
% a shift value in "pixels per frame", assuming given waitduration:
shiftperframe = cyclespersecond * p * waitduration;
  
    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl = Screen('Flip', expInfo.curWindow);
    tstart = vbl;

i=0;
while ~KbCheck
    % Shift the grating by "shiftperframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    yoffset = mod(i*shiftperframe,p);
    i=i+1;
    
    % Draw grating texture
    Screen('DrawTexture', expInfo.curWindow, gratingtex, srcRect, [], [], [], [], [], [], [], [0, yoffset, 0, 0]);
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', expInfo.curWindow, vbl + (waitframes - 0.5) * ifi);
end

% get response: direction of MAE
if trialData.validTrial
    trialData.respScreenTime =Screen('Flip',expInfo.curWindow);
    % check for key press
    while trialData.response==999 % && (GetSecs < trialData.respScreenTime + conditionInfo.maxToAnswer -ifi/2)
        [keyDown, secs, keyCode] = KbCheck;
        if keyDown
            if keyCode(KbName('LeftArrow'))
                trialData.response = 'LeftArrow';
                trialData.rt = secs - trialData.respScreenTime;
            elseif keyCode(KbName('RightArrow'))
                trialData.response = 'LeftArrow';
                trialData.rt = secs - trialData.respScreenTime;
            else
                if keyCode(KbName('ESCAPE'))
                    trialData.abortNow   = true;
                end
                trialData.validTrial = false;break;
            end
        end
    end
    FlushEvents('keyDown');
end

if trialData.response==999 % no response
    trialData.validTrial = false;
end

drawFixation(expInfo, expInfo.fixationInfo);
t = Screen('Flip', expInfo.curWindow);
trialData.trialEndTime = t;


end
