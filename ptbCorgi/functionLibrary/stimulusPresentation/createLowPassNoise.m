function img = createLowPassNoise(imageSizePix, smoothingSigmaPix, windowSigmaPix, centerX,centerY)
% 
%function img = createLowPassNoise(imageSizePix, smoothingSigmaPix, windowSigmaPix, centerX,centerY)
%
%imageSizePix = 
%

if nargin<2
    error('Must at minumum specify image size and guassian sigma');
end



if(~exist('centerX','var') || isempty(centerX))
    centerX = 0;
end

if(~exist('centerY','var') || isempty(centerY))
    centerY = 0;
end

%This uses a trick to easily scramble phases 
%Making the correct random fft matrix is a little tricky because 
%fourier transforms of real images have symmetry
%It's easier just to take the fourier transform of a white noise image
%White noise has a flat power spectrum and uniform phase spectrum
randomImage = randn(imageSizePix);
fftImage = fft2(randomImage);

%Now create low pass amplitude spectrurm

fftSigma = imageSizePix/(smoothingSigmaPix*2*pi);

freqFilt = ifftshift(createGaussian(imageSizePix,fftSigma));
filtFft  = freqFilt.*real(fftImage) + 1i*freqFilt.*imag(fftImage);
img      = ifft2(filtFft,'symmetric');

%If want noise windowd do it now:
if(exist('windowSigmaPix','var') && ~isempty(windowSigmaPix))

    imWindow = createGaussian(imageSizePix,windowSigmaPix,1,centerX,centerY);
    img=imWindow.*img;
end

img = img./max(abs(img(:)));



return;

