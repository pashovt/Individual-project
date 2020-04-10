% clc;    % Clear the command window.
% close all;  % Close all figures (except those of imtool.)
% workspace;  % Make sure the workspace panel is showing.
% format long g;
% format compact;
fontSize = 16;
% 
% %===============================================================================
% % Get the name of the image the user wants to use.
baseFileName = 'image.jpeg';
folder = pwd;
fullFileName = fullfile(folder, baseFileName);

% Check if file exists.
if ~exist(fullFileName, 'file')
	% The file doesn't exist -- didn't find it there in that folder.
	% Check the entire search path (other folders) for the file by stripping off the folder.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

%=======================================================================================
% Read in demo image.
rgbImage = imread(baseFileName); ...frame;
% Get the dimensions of the image.
[rows, columns, numberOfColorChannels] = size(rgbImage)

% Display image.
subplot(2, 2, 1);
imshow(rgbImage, []);
impixelinfo;
axis on;
caption = sprintf('Original Color Image\n%s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo(); % Set up status line to see values when you mouse over the image.

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;

hsvImage = rgb2hsv(rgbImage);
mask = hsvImage(:, :, 2) < 0.2;

% Display the image.
subplot(2, 2, 2);
imshow(mask, []);
caption = sprintf('Color Segmentation Mask Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;
axis('on', 'image');
drawnow;

% Erode to separate from teh background.
se = strel('disk', 51, 0);
mask = imerode(mask, se);
% Get rid of white background
mask = imclearborder(mask);
% Fill holes
mask = imfill(mask, 'holes');
% Take largest blob
mask = bwareafilt(mask, 1);
% Display the image.
subplot(2, 2, 3);
imshow(mask, []);
title('Final Segmentation', 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;

% Get an image of the masked part
grayImage = rgbImage(:, :, 2); % Take green channel.
% Erase fingers
grayImage(~mask) = mean(grayImage(~mask));
% Crop to mask's bounding box.
[maskRows, maskColumns] = find(mask);
row1 = min(maskRows);
row2 = max(maskRows);
col1 = min(maskColumns);
col2 = max(maskColumns);
grayImage = grayImage(row1:row2, col1:col2);

% Display the image.
subplot(2, 2, 4);
imshow(grayImage, []);
title('Final Image', 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;

ocrObject = ocr(grayImage)
characters = strtrim(ocrObject.Text)

% Tell user the answer.
caption = sprintf('Final Image.  The characters are %s', characters);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
message = sprintf('Done!\nThe characters are %s', characters)
uiwait(helpdlg(message));

