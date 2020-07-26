% Image Processing Toolbox (Version 7.1)
% Signal Processing (Version 7.2)

% functions to use
adaptthresh
imcontour
bwperim
regionprops
% Region Growing – activecontour() 
    % https://uk.mathworks.com/discovery/image-segmentation.html
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


%% Check
edit ./initialScript/summaryCode.m
GetTempNumber

%% STEP 0 - Clearning the code and test


% Methodology
% 
% DONE - Step 1 - Data acquisition 
%      Import data
%      Read frame for frame and perform the analysis based on the frames 
%          while ignoring the noise regions
%      2 variables
% Step 2 - Image restoration
%     Noise removal
%     Box identification
%     Finding the location of all the default boxes
%     Identify regions of high level noise (video readings - temperature 
%         bar, temperature limits, etc.) using object detection
%     Store the location of the noise regions
% Step 3 - Image enchantement
%     Enhance the image quality by enhancing the colors (higher contrast)
%         Make it linear so the corrolation doesnt become too complicated
%     No need to enhance the thermal scale since the enhanced image will be  
%         a differnt variable
% Step 4 - Morphological Processing
%     To improve the quality of the image. For example erode and dilate 
%         gray scale image
% Step 5 - Segmentation
%     Using edge detection with the Sobel operator
%     Using automatically assigned and calculated threshold value for the 
%         intensity of pixels
%     Additional morphological processing
%     Add fillings to the holes
%     Classification of defects - clustering methods
%         K Nearest Neighbours(KNN) algorithm 
% Object Recognition
%     Continuously monitor the changes around the areas of the 
%         classified defects
%     Identify if the classified defects are real based on the 
%         thermal cooling
% Representation and description
%     Show correlation between the pixels inside the classified defects 
%         to show the likely structure of the feature and possible 
%         provide data on its depth

%% FOR NOW
% edge detection with specific threshold (from the thermal image)
    % basic morphological processing
    % further image segmentation for depicting large clusters
% Color threshold app
% improve edge detection method with thresholding and binarization of image
% https://uk.mathworks.com/products/computer-vision.html 
    % Feature detection and extraction
    % Segmentation & shape fitting
    % Semantine segmentation
% 3d plot temperatureImage
% Improve mask
% https://www.youtube.com/watch?v=ZTbGlriKFtU
    % Try on figure 3 or 4:
    % imopen – erosion and dilation
    % imclose – dilation and erosion
    % imtophat
    % imbothat
    % https://uk.mathworks.com/help/images/morphological-dilation-and-erosion.html
    % imfill
    % bwlabel
% edge detection - test different edge methods
    % reducedFrameAnalysis
    % https://uk.mathworks.com/videos/edge-detection-with-matlab-119353.html
% approach 1
    % https://uk.mathworks.com/videos/color-based-segmentation-with-live-image-acquisition-68771.html
% K - mean clustering
    % https://uk.mathworks.com/help/images/color-based-segmentation-using-k-means-clustering.html
% Marker-Controlled Watershed Segmentation
    % https://uk.mathworks.com/help/images/marker-controlled-watershed-segmentation.html
% frameAnalysis function - look at how to improve edge detection
    % https://uk.mathworks.com/help/images/ref/edge.html
% Salient Object Detection Evaluation
    % https://uk.mathworks.com/matlabcentral/fileexchange/42767-salient-object-detection-evaluation
% Entropy based Saliency detection
    % https://uk.mathworks.com/matlabcentral/fileexchange/44041-entropy-based-saliency-detection
% Region Contrast Saliency
    % https://uk.mathworks.com/matlabcentral/fileexchange/47447-region-contrast-saliency
% Image Descriptors / Features and Saliency Maps
    % https://uk.mathworks.com/matlabcentral/fileexchange/28344-image-descriptors-features-and-saliency-maps
% Salient Object Detection Evaluation
    % https://uk.mathworks.com/matlabcentral/fileexchange/42767-salient-object-detection-evaluation?focused=3791883&tab=function
% ROI selection for saliency maps
    % https://uk.mathworks.com/matlabcentral/fileexchange/43558-roi-selection-for-saliency-maps
% Zhenzhou threshold selection
    % https://uk.mathworks.com/matlabcentral/fileexchange/56371-zhenzhou-threshold-selection
% Texture Segmentation Using Gabor Filters
    % https://uk.mathworks.com/content/dam/mathworks/tag-team/Objects/p/88395_93008v00_Texture_Gabor_Filters_2016.pdf
% Kapur’s Entropy- thersholding
    % file:///C:/Users/hprs9/Downloads/entropy-21-00318.pdf
    % https://www.researchgate.net/publication/331968510_Kapur's_Entropy_for_Color_Image_Segmentation_Based_on_a_Hybrid_Whale_Optimization_Algorithm
% K- and Fuzzy c-Means for Color Segmentation
% serpentine analysis
% colorDistinguish.m
    % https://uk.mathworks.com/matlabcentral/answers/183480-color-thresholdig-convert-rgb-to-binary-consider-the-value-of-red-green-and-bue
%

% mask explanation
mask = L < 0;
light_blue = [.6 .6 1];
overlay = imoverlay(rgb, mask, light_blue);

% Idea
% get temperature bar
% extract min and max temp
% make temperature image
% binarize image and make the 0 to 1 scale to min to max temp

    
%% Extra info
% You just simply need to modify the low and high temperature, 
% and adjust the row and column where the image and colorbar are taken from.

% From image processing point of view, channel split functions can segregate 
% the RGB channels, and you can simply use the Red channel image for 
% your purpose.


% You need to analyze the original grayscale image, not the rgb 
% pseudocolored image. To verify you should look at pixel values and 
% compare the intensity at that location with the temp measured with 
% another device, like a thermometer, and use on individuals known to 
% have, or not have, fever.
% To apply pseudocolors, use the colormap() function. There are a variety 
% of built-in colormaps you can choose from, in addition to building your 
% own custom colormap.
    