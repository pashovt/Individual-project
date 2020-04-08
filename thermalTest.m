clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 15;

%===============================================================================
% Get the name of the image the user wants to use.
baseFileName = 'thermal_image.png'; % Assign the one on the button that they clicked on.
% Get the full filename, with path prepended.
% folder = pwd
% fullFileName = fullfile(folder, baseFileName);

load('frameData.mat')
%===============================================================================
% Read in a demo image.
% originalRGBImage = imread(fullFileName);
originalRGBImage = frame;
% Display the image.
subplot(2, 3, 1);
imshow(originalRGBImage, []);
axis on;
caption = sprintf('Original Pseudocolor Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

grayImage = min(originalRGBImage, [], 3); % Useful for finding image and color map regions of image.

% Crop off the surrounding clutter to get the colorbar.
colorBarImage = imcrop(originalRGBImage, [303, 25, 15, 200]);
 b = colorBarImage(:,:,3);

% Crop off the surrounding clutter to get the RGB image.
rgbImage = imcrop(originalRGBImage, [1, 30, size(frame, 2)-25, size(frame, 1)]);

% Get the dimensions of the image.  
% numberOfColorBands should be = 3.
[rows, columns, numberOfColorChannels] = size(rgbImage);
% Display the image.
subplot(2, 3, 2);
imshow(rgbImage, []);
axis on;
caption = sprintf('Cropped Pseudocolor Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
hp = impixelinfo();

% Display the colorbar image.
subplot(2, 3, 3);
imshow(colorBarImage, []);
axis on;
caption = sprintf('Cropped Colorbar Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 

% Get the color map.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255

% Convert from an RGB image to a grayscale, indexed, thermal image.
indexedImage = rgb2ind(rgbImage, storedColorMap);
% Display the thermal image.
subplot(2, 3, 4);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Thermal Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Get the histogram of the indexed image
subplot(2, 3, 5:6);
histogram(indexedImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Gray Scale', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency', 'FontSize', fontSize, 'Interpreter', 'None');