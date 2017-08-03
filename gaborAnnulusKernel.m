function [ kernelReal, kernelImag ] = gaborAnnulusKernel( size, lambda, sigma, radius )
%GABORANNULUSKERNEL Generates two annulus kernels - real and imag
%   size    - kernel size
%   lambda  - wavelength (ie. selected f0 from paper = 1/lambda)
%   sigma   - gaussian deviation (around radius)
%   radius  - donut radius
 
%If you make use of this technique then please cite the following paper:
% A. Rhodes and L. Bai. Circle Detection Using a Gabor Annulus. Proceedings of the 22nd British Machine Vision Conference. Dundee, UK, 2011.

    if mod(size,2) == 0
        size = floor(size/2);
        [X,Y] = meshgrid(-size:1:size-1, -size:1:size-1);
    else
        size = floor(size/2);
        [X,Y] = meshgrid(-size:1:size, -size:1:size);
    end
    A=(2*pi*(sigma^2));
    R = sqrt(X.^2 + Y.^2);
    kernelReal = (1 / A) * exp (-1 * pi * (((R-radius).^2)/sigma^2)) .* (cos(((R - radius) .* 2 * pi)/lambda));
    kernelImag = (1 / A) * exp (-1 * pi * (((R-radius).^2)/sigma^2)) .* (sin(((R - radius) .* 2 * pi)/lambda));

end