function [expInfo] = drawFixation(expInfo, fixationInfo)
%function [expInfo] = drawFixation(expInfo, [fixationInfo])
%This function is used to draw fixation markers.
% Since it is called throughout the experiment it can also be used to draw
% other things that should be on screen in the intertrial interval. For
% example we have implemented a frame to aid fixation in the stereo mode.
%
% fixationInfo is a structure that can have multiple elements to draw
% complicated fixation patterns. If it is not set defaults to using
% expInfo.fixationInfo
%
% 
% type -  [''] Empty will not draw anything
%         'cross' A standard fixation cross with the following fields:
%             size         - [variable] The size (full width) in degrees of the cross
%             lineWidthPix - [1] line width in pixels
%             color        - [0] Color of the lines
%             loc          - [0 0] horizontal and vertical location from center
% 
%         'dot' A standard fixation dot with the following fields:
%             size         - [variable] The size in degrees of the dot radius
%             color        - [0] Color of the dot
%             loc          - [0 0] horizontal and vertical location from center
%
%         'square' A square box. 
%             size         - [variable] The size (full width) in degrees of
%                            the square
%             lineWidthPix - [1] line width in pixels
%             color        - [0] Color of the lines
% 
% 
%         'noiseFrame' A white noise texture around the edges of the screen
%                      used to aid fixation lock in stereo modes. 
%             size         - [variable] The size (full width) in degrees of
%                            the square
%
% Examples:
% 
% Draw a black cross with lines 2 pixels wide:
%
% fixationInfo(1).type  = 'cross';
% fixationInfo(1).size  = .5;
% fixationInfo(1).lineWidthPix = 2;
% fixationInfo(1).color = 0;
%
% Default fixation for when using a stereo mdoe is a 2-element fixation 
% pattern cross with a noise frame at the edge of the screen:
%
% fixationInfo(1).type = 'cross';
% fixationInfo(2).type = 'noiseFrame';
% fixationInfo(2).size = 100;

if nargin ==1
    fixationInfo = expInfo.fixationInfo;
end

nElements = length(fixationInfo);

%fixationInfo can be a structure with multiple fixation element
for iElement = 1:nElements
    
    %We need to do different things for stereo rendering
    if expInfo.stereoMode == 0;
        expInfo = drawFixationMono(expInfo,fixationInfo(iElement));
    else
        expInfo = drawFixationStereo(expInfo,fixationInfo(iElement));
    end
    
end


end




function [expInfo] = drawFixationMono(expInfo,fixationInfo)


if  ~isfield(fixationInfo,'lineWidthPix') || isempty(fixationInfo.lineWidthPix)
    fixationInfo.lineWidthPix = 1; %the line width of the fixation elements
end

if ~isfield(fixationInfo,'color') || isempty(fixationInfo.color)
    fixationInfo.color = 0; %the color of the fixation elements.
end

%Switchyard to determine what to draw.
switch lower(fixationInfo.type)
    
    
    case 'cross'
        
        if ~isfield(fixationInfo,'size') || isempty(fixationInfo.size)
            fixationInfo.size = 20/expInfo.ppd; %Default cross size is 10 
            %pixels for backwards compatability. -- AL: Each arm of the 
            %cross was 10 pixels previously, so the line size for drawing 
            %the horizontal and vertical lines to make the cross was 20 pixels. 
            %With 10 pixels as the size the fixation cross is too small, so 
            %I've changed it to 20 so that it is consistent with how my experiment was run previously.
        end
        
        fixCrossPix    = expInfo.ppd*fixationInfo.size;
        fixCoords = [-fixCrossPix fixCrossPix 0 0;... %fixation cross x coordinates
            0 0 -fixCrossPix fixCrossPix]; %fixation cross y coordinates
        if ~isfield(fixationInfo,'loc') || isempty(fixationInfo.loc)
            fixLocation = expInfo.center;
        else %fixationInfo.loc should contain 2 values for horiz and vert deviation from centre
            fixLocation = [expInfo.center(1)+expInfo.ppd*fixationInfo.loc(1) expInfo.center(2)+expInfo.ppd*fixationInfo.loc(2)];
        end
        Screen('DrawLines', expInfo.curWindow, fixCoords, fixationInfo.lineWidthPix, ...
            fixationInfo.color, fixLocation, 0);
        
    case 'dot'
        
        if ~isfield(fixationInfo,'size') || isempty(fixationInfo.size)
            fixationInfo.size = 10/expInfo.ppd;
        end
        
        fixCrossPix    = expInfo.ppd*fixationInfo.size;
        fixCoords = [-fixCrossPix -fixCrossPix fixCrossPix fixCrossPix]; 
        if ~isfield(fixationInfo,'loc') || isempty(fixationInfo.loc)
            fixLocation = CenterRectOnPoint(fixCoords,expInfo.center(1),expInfo.center(2));
        else %fixationInfo.loc should contain 2 values for horiz and vert deviation from centre
            fixLocation = CenterRectOnPoint(fixCoords,expInfo.center(1)+expInfo.ppd*fixationInfo.loc(1), expInfo.center(2)+expInfo.ppd*fixationInfo.loc(2));
        end
        Screen('FillOval', expInfo.curWindow, fixationInfo.color, fixLocation);
    
    
    case 'square'
        %Consider changing this code to a framerect instead of lines for
        %simplicity.
        %Earlier version used "boxSize" to set the box size.
        %new version unifies parameter names so "size" 
        if ~isfield(fixationInfo,'size') || isempty(fixationInfo.size)
            if isfield(fixationInfo,'boxSize') && ~isempty(fixationInfo.boxSize)
                fixationInfo.size = fixationInfo.boxSize;
            else
                fixationInfo.size = 30/expInfo.ppd; %Default box size is 30 pixels for backwards compatability.
            end
        end
        
        sizePix = expInfo.ppd*fixationInfo.size;
        leftPointX = expInfo.center(1) - sizePix; %x centre is expInfo.center(1)
        rightPointX = expInfo.center(1) + sizePix;
        PointY1 = expInfo.center(2) + sizePix; %y centre is expInfo.center(2)
        PointY2 = expInfo.center(2) - sizePix;
        
        boxXcoords = [leftPointX leftPointX ...
            rightPointX rightPointX ...
            leftPointX rightPointX ...
            leftPointX rightPointX];
        
        boxYcoords = [PointY1 PointY2 ...
            PointY1 PointY2 ...
            PointY1 PointY1 ...
            PointY2 PointY2];
        boxCoords = [boxXcoords; boxYcoords];
        
        Screen('DrawLines', expInfo.curWindow, boxCoords, fixationInfo.lineWidthPix, ...
            fixationInfo.color);
        
        %% apeture drawing
        
    case 'noiseframe'
        
        
        [screenXpixels, screenYpixels] = Screen('WindowSize', expInfo.curWindow);
        
        if ~isfield(fixationInfo,'size') || isempty(fixationInfo.size)
            fixationInfo.size = 100/expInfo.ppd; %Default box size is 100 pixels for backwards compatability.
        end
        
        texWidthPix = round(expInfo.ppd*fixationInfo.size);
        
        if ~isfield(expInfo,'fixationTextures') || isempty(expInfo.fixationTextures)
            
            
            priorSeed = rng; %Save the current rng seed
            rng(1); %setting the random seed of this file to 1 so that the normally
            %distributed random matrix generated by randn for the left, right, top
            %and bottom rectangle textures below will not change.
            leftRectMat = randn([screenYpixels, texWidthPix]);
            rightRectMat = randn([screenYpixels, texWidthPix]);
            topHorzMat = randn([texWidthPix, screenXpixels]);
            bottomHorzMat = randn([texWidthPix, screenXpixels]);
            
            
            leftRectTexture = Screen('MakeTexture', expInfo.curWindow, leftRectMat);
            rightRectTexture = Screen('MakeTexture', expInfo.curWindow, rightRectMat);
            topHorzTexture = Screen('MakeTexture', expInfo.curWindow, topHorzMat);
            bottomHorzTexture = Screen('MakeTexture', expInfo.curWindow, bottomHorzMat);
            expInfo.fixationTextures = [leftRectTexture; rightRectTexture; topHorzTexture; bottomHorzTexture];
            rng(priorSeed);            % restore the generator settings
        end
        
        leftRectLocation = [0 0 texWidthPix screenYpixels];
        rightRectLocation = [(screenXpixels-texWidthPix) 0 screenXpixels screenYpixels];
        topRectLocation = [0 0 screenXpixels texWidthPix]; %this draws the top rectangle along the entire length of the top of the screen
        bottomRectLocation = [0 (screenYpixels-texWidthPix) screenXpixels screenYpixels];
        allLocations = [leftRectLocation; rightRectLocation; topRectLocation; bottomRectLocation]';
        
        Screen('DrawTextures', expInfo.curWindow, expInfo.fixationTextures, [], [allLocations]);
        
end


end








function [expInfo] = drawFixationStereo(expInfo,fixationInfo)
%Currently this function just draws things at 0 screen disparity by calling
%the mono fixation drawing code twice, once for each stereo buffer.

Screen('SelectStereoDrawBuffer', expInfo.curWindow, 0);
expInfo = drawFixationMono(expInfo,fixationInfo);
Screen('SelectStereoDrawBuffer', expInfo.curWindow, 1);
expInfo = drawFixationMono(expInfo,fixationInfo);

end







