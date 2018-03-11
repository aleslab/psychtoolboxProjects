function img = createLowPassNoise(imageSizePix, windowSigmaPix, )
% 
%function img = createGaussian(imageSizePix, sigmaPix, maxValue, centerX,centerY)
%
%imageSizePix = 
%

if nargin<2
    error('Must specify image size and guassian sigma');
end


%This uses a trick to easily scramble phases 
%Making the correct random fft matrix is a little tricky because 
%fourier transforms of real images have symmetry
%It's easier just to take the fourier transform of a white noise image
%White noise has a flat power spectrum and uniform phase spectrum
randomImage = randn(imageSizePix);
fftImage = fft2(randomImage);
outPhase=angle(fftImage);


%Now create low pass amplitude spectrurm

fftSigma = imageSizePix/(sigmaPix*2*pi);

outAmp = abs(fftImage).*ifftshift(createGaussian(imageSizePix,fftSigma));



%reconstruct the scrambled image from its complex valued matrix
img=ifft2(outAmp.*exp(1i.*outPhase),'symmetric');


return;

