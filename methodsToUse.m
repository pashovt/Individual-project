% Image Processing Toolbox (Version 7.1)
% Signal Processing (Version 7.2)

% functions to use
adaptthresh
imcontour

%% Usamentiaga et al. (2013) - NIS
% image enhancement - removes background and leaves intact the amplitude
% DFT (Discrete Fourier Transform)
% spherical strel with 5 as a radius

%% Grys 2018
% FC (unsharp filter) and RIFC (two-dimensional Gaussian kernel (2-D discrete convolution))
% Otsu to calculate the optimal threshold for the segmentation
Morphological processing
fuzzy clustering

% Koprowski and Wilczy?ski 2018
% gray image
% Medain filter to a convolutional mask
% Stabilization:
    % - gyroscopic methods 
    % - detection of features such as object contours, edges or vertices 
        % and then calculation of the correlation between the 
        % i-th image and the first one (i 2 (2,I)).
% active contour model 
    % - region based
    % - edge based
% accomodate otsu to optimise the image enhancement


Serpentine
affine transformation – creates a shifted view of the image
FFT – (discrete Fourier transform) for analysing the first and second harmonics of the image 
Followed by a harmonic selection based on which harmonic prevails from the value of the FFT 

harmonics allow for the automatic determination of the local minima of the points of contact between two, three, and more heat sources