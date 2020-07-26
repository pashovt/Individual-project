% Demo to check a 7 segment display.
% By ImageAnalyst
% clc;    % Clear the command window.
% close all;  % Close all figures (except those of imtool.)
% imtool close all;  % Close all imtool figures.
% clear;  % Erase all existing variables.
% workspace;  % Make sure the workspace panel is showing.
fontSize = 14;

% Read in a standard MATLAB gray scale demo image.
% folder = 'C:\Users\Esther\Documents\Temporary';
% baseFileName = '7segmentdisplay.jpg';
% Get the full filename, with path prepended.
% fullFileName = fullfile(folder, baseFileName);
% if ~exist(fullFileName, 'file')
%   % Didn't find it there.  Check the search path for it.
%   fullFileName = baseFileName; % No path this time.
%   if ~exist(fullFileName, 'file')
%     % Still didn't find it.  Alert user.
%     errorMessage = sprintf('Error: %s does not exist.', fullFileName);
%     uiwait(warndlg(errorMessage));
%     return;
%   end
% end
rgbImage = lowTempCrop;
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows columns numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 2, 1);
imshow(rgbImage, []);
title('Original Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);

% Display the original color image.
subplot(2, 2, 2);
imshow(redChannel, []);
title('Red Channel', 'FontSize', fontSize);
subplot(2, 2, 3);
imshow(greenChannel, []);
title('Green Channel', 'FontSize', fontSize);
subplot(2, 2, 4);
imshow(blueChannel, []);
title('Blue Channel', 'FontSize', fontSize);

% Extract just the segments and not the numbers.
figure;
binaryImage = ~(redChannel < 200) & (blueChannel < 200);
% subplot(2, 2, 1);
imshow(binaryImage, []);
axis on;
drawnow;
hold on;
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% Now define locations to check.
row1 = 35;
row2 = 110;
row3 = 175;
row4 = 260;
row5 = 330;
col1 = 70;
col2 = 175;
col3 = 275;

% Plot boxes around there to check.
title('Checking Image Inside Red Boxes', 'FontSize', fontSize);
boxWidth = 30;
% First check top segment.
row = row1;
col = col2;
boxX = [col col+boxWidth col+boxWidth col col];
boxY = [row row row + boxWidth, row + boxWidth, row];
plot(boxX, boxY, 'ro-');
imageInsideBox = binaryImage(row:row + boxWidth, col:col+boxWidth)
% Determine if there are any pixels set inside that box.
segmentState(1) = any(imageInsideBox(:))

% Now check upper left segment.
row = row2;
col = col1;
boxX = [col col+boxWidth col+boxWidth col col];
boxY = [row row row + boxWidth, row + boxWidth, row];
plot(boxX, boxY, 'ro-');
imageInsideBox = binaryImage(row:row + boxWidth, col:col+boxWidth)
% Determine if there are any pixels set inside that box.
segmentState(2) = any(imageInsideBox(:))

% Now check lower right segment.
row = row4;
col = col3;
boxX = [col col+boxWidth col+boxWidth col col];
boxY = [row row row + boxWidth, row + boxWidth, row];
plot(boxX, boxY, 'ro-');
imageInsideBox = binaryImage(row:row + boxWidth, col:col+boxWidth)
% Determine if there are any pixels set inside that box.
segmentState(6) = any(imageInsideBox(:))