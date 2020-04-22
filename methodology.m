% STEP 0 - Clearning the code and test


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