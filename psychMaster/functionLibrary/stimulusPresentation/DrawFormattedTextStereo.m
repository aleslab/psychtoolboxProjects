function [nx, ny, textbounds] = DrawFormattedTextStereo(win, tstring, sx, sy, color, wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
%
%  Drop in replacement wrapper for DrawFormattedText that is stereo aware. 
%  If the current window is a stereo buffer it draws text into both eye buffers 
%  if it's not it just draws monocularly as usual.

if isempty(tstring)
    return;
end

info = Screen('GetWindowInfo', win);

% Process Inputs and Initialize Defaults
nargs = 11;
for k = nargin:nargs-1
    switch k
        case 0
            win = [];
        case 1
            tstring = [];
        case 2
            sx = [];
        case 3
            sy = [];
        case 4
            color = [];
        case 5
            wrapat = [];
        case 6
            flipHorizontal = [];
        case 7
            flipVertical = [];
        case 8
            vSpacing=[];
        case 9
            righttoleft=[];
        case 10
            winRect = [];
            
 
        otherwise
    end
end
 %color, wrapat, flipHorizontal, 
if info.StereoMode == 0;
[nx, ny, textbounds]= DrawFormattedText(win, tstring, sx, sy, color, ...
    wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect);
else
     % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', win, 0);
    DrawFormattedText(win, tstring, sx, sy, color, ...
        wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect);
    Screen('SelectStereoDrawBuffer', win, 1);
    [nx, ny, textbounds]= DrawFormattedText(win, tstring, sx, sy, color, ...
        wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect);
    
    if info.StereoDrawBuffer == 0 || info.StereoDrawBuffer == 1
        Screen('SelectStereoDrawBuffer', win, info.StereoDrawBuffer);
    end
end



end

