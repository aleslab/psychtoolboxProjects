function [nx, ny, textbounds] = DrawFormattedTextStereo(win, tstring, sx, sy, color, wrapat, flipHorizontal, flipVertical, vSpacing, righttoleft, winRect)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
%
%  Drop in replacement wrapper for DrawFormattedText that is stereo aware. 
%  If the current window is a stereo buffer it draws text into both eye buffers 
%  if it's not it just draws monocularly as usual.

info = Screen('GetWindowInfo', win)

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

