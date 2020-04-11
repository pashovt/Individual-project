clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 14;
%===============================================================================
% Read in a color demo image.
folder = 'D:\Temporary Stuff';
baseFileName = 'USM16.jpg';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
  % Didn't find it there.  Check the search path for it.
  fullFileName = baseFileName; % No path this time.
  if ~exist(fullFileName, 'file')
    % Still didn't find it.  Alert user.
    errorMessage = sprintf('Error: %s does not exist.', fullFileName);
    uiwait(warndlg(errorMessage));
    return;
  end
end
rgbImage = imread(fullFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(3, 3, 1);
imshow(rgbImage);
title('Original Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);

% Extract the individual red, green, and blue color channels.
hsv = rgb2hsv(rgbImage);
hImage = hsv(:, :, 1);
sImage = hsv(:, :, 2);
vImage = hsv(:, :, 3);
% Display the images
subplot(3, 3, 4);
imshow(hImage, []);
title('Hue Image', 'FontSize', fontSize);
subplot(3, 3, 5);
imshow(sImage, []);
title('Saturation Image', 'FontSize', fontSize);
subplot(3, 3, 6);
imshow(vImage, []);
title('Value Image', 'FontSize', fontSize);

% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(hImage);
subplot(3, 3, 7); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Hue image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(sImage);
subplot(3, 3, 8); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Saturation image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(vImage);
subplot(3, 3, 9); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Value image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Manually threshold the images usinghttp://www.mathworks.com/matlabcentral/fileexchange/29372-thresholding-an-image
% [lowThreshold, highThreshold] = threshold(.1, .9, vImage);
% Get a binary image by thresholding and combining the different channels.
hueBinary = hImage > 0.2 | hImage < 0.1;
saturationBinary = sImage > 0.22;
valueBinary = vImage > 0.28 & vImage < 0.9;
binaryImage = hueBinary & saturationBinary & valueBinary;
% Clear up by getting rid of particles less than 400 pixels in area.
binaryImage = bwareaopen(binaryImage, 400);
% Fill any holes in the blobs.
binaryImage = imfill(binaryImage, 'holes');
subplot(3, 3, 2);
imshow(binaryImage, []);
axis on;
title('Cells Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);

% Label each blob with 8-connectivity, so we can make measurements of it
[labeledImage, numberOfBlobs] = bwlabel(binaryImage, 8);
% Apply a variety of pseudo-colors to the regions.
coloredLabelsImage = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); 
% Display the pseudo-colored image.
subplot(3, 3, 3);
imshow(coloredLabelsImage);
title('Labeled Image', 'FontSize', fontSize);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'all')
numberOfBlobs = size(blobMeasurements, 1)