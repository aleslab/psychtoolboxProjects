function img = createGabor(radiusPix, sigmaPix, cyclesPerSigma, contrast, phase, orient)
% 
% img = mrUtilGabor(radiusPix, sigmaPix, cyclesPerSigma, [contrast=0.25], [phase=0],[orient=0])
%
% Make a gobor image. Orientation (0=vertical) and phase are in degrees.
% E.g.: 
%   img = mrUtilGabor(200, 100, 2);
%   image(img); truesize; colormap gray(256);
%
% Also see the end of this file for more examples.
% 
% HISTORY:
% 2006.01 RFD wrote it.
% 2006.11.07 RFD: added drift demo.
% 2015.10 JMA: modified for new purpose.


if(~exist('contrast','var') | isempty(contrast))
    contrast = 0.25;
end
if(~exist('phase','var') | isempty(phase))
    phase = 0;
end
if(~exist('orient','var') | isempty(orient))
    orient = 0;
end

orient = (pi/180)*orient; %Convert degrees to radians.
phase  = (pi/180)*phase;

sigmasPerImage = 2*radiusPix/sigmaPix;
[x,y] = meshgrid(-radiusPix:radiusPix,-radiusPix:radiusPix);
imgPix = size(x,1);
% cycles per pixel
sf = (sigmasPerImage*cyclesPerSigma)/imgPix*2*pi;
% a = cos(orient)*sf;
% b = sin(orient)*sf;

xp = x*cos(orient)-y*sin(orient);
%yp = x*sin(orient)+y*cos(orient);

spatialWindow = exp(-((x/sigmaPix).^2)-((y/sigmaPix).^2));
img = spatialWindow.*contrast.*sin(sf*xp+phase);
img = img/2+.5;

return;


% Other compression methods don't seem to work