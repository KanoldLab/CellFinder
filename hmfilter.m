function [avgfilteredImage filteredImages] = hmfilter(I, sigma)
if nargin < 2
    sigma = 1;
end
filteredImages=zeros(size(I));
for i = 1:size(I,3)
    I_temp = I(:,:,i);
    I_temp = im2double(I_temp);
    I_temp = log(1 + I_temp);
    M = 2*size(I_temp,1);
    N = 2*size(I_temp,2);
    [X, Y] = meshgrid(1:N,1:M);
    centerX = ceil(N/2);
    centerY = ceil(M/2);
    gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
    H = exp(-gaussianNumerator./(2*sigma.^2));
    H=1-H;
    H = fftshift(H);
    Ir = padarray(I_temp,[ceil(size(I_temp,1)/2) ceil(size(I_temp,2)/2)],'symmetric');
    If = fft2(Ir, M, N);
    Iout = real(ifft2(H.*If));
    Iout = Iout(ceil(size(I_temp,1)/2)+1:size(Iout,1)-ceil(size(I_temp,1)/2), ...
        ceil(size(I_temp,2)/2)+1:(size(Iout,2)-ceil(size(I_temp,2)/2)));
    filteredImages(:,:,i) = exp(Iout) - 1;
end
avgfilteredImage = squeeze(mean(filteredImages,3));