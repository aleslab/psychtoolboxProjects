function img = createGaussian(imageSizePix, sigmaPix, maxValue, centerX,centerY)
% 
%function img = createGaussian(imageSizePix, sigmaPix, maxValue, centerX,centerY)
%
%imageSizePix = 
%

if nargin<2
    error('Must specify image size and guassian sigma');
end

if(~exist('maxValue','var') | isempty(maxValue))
    maxValue = 1;
end

if(~exist('centerX','var') || isempty(centerX))
    centerX = 0;
end


if(~exist('centerY','var') || isempty(centerY))
    centerY = 0;
end

pixCoord = linspace(-imageSizePix/2,imageSizePix/2,imageSizePix);

[x,y] = meshgrid(pixCoord,pixCoord);

x=x-centerX;
y=y-centerY;

img = (1/(sigmaPix*sqrt(2*pi)))*exp(-0.5*(  (x/sigmaPix).^2 + (y/sigmaPix).^2 ) );

img = maxValue*(img./max(img(:)));
return;

