clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 15;

%===============================================================================
% Get the name of the image the user wants to use.
baseFileName = 'image.png'; % Base file name with no folder prepended (yet).
% Get the full filename, with path prepended.
% folder = pwd; % Change to whatever folder the image lives in.
% fullFileName = fullfile(folder, baseFileName);  % Append base filename to folder to get the full file name.
% fprintf('Transforming image "%s" to a thermal image.\n', fullFileName);


load('frameData.mat')
%===============================================================================
% Read in a demo image.
rgbImage = frame;
% rgbImage = imread(fullFileName);
% Display the pseudocolored RGB image.
subplot(2, 2, 1);
imshow(rgbImage, []);
axis on;
caption = sprintf('Original Pseudocolor Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo();
drawnow;

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')

%=========================================================================================================
% Get the color map 
storedColorMap = jet(256);

% Convert the subject/sample from a pseudocolored RGB image to a grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);
% Display the indexed image.
subplot(2, 2, 2);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Thermal Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

%=========================================================================================================
% Now we need to define the temperatures at the end of the colored temperature scale.
% You can read these off of the image, since we can't figure them out without doing OCR on the image.
% Define the temperature at the top end of the scale.
% This will probably be the high temperature.
highTemp = 25.9;
% Define the temperature at the dark end of the scale
% This will probably be the low temperature.
lowTemp = 12.6;

% Scale the indexed gray scale image so that it's actual temperatures in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

% Display the thermal image.
subplot(2, 2, 3);
imshow(thermalImage, []);
axis on;
colorbar;
title('Floating Point Thermal (Temperature) Image', 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');

% Let user mouse around and see temperatures on the GUI under the temperature image.
hp = impixelinfo();
hp.Units = 'normalized';
hp.Position = [0.45, 0.03, 0.25, 0.05];

%=========================================================================================================
% Get and display the histogram of the thermal image.
subplot(2, 2, 4);
histogram(thermalImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Temperature', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency', 'FontSize', fontSize, 'Interpreter', 'None');

fprintf('Done!  Thanks Image Analyst!\n');