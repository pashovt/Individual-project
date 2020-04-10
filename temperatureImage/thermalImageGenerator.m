function thermalImageGenerator(frameImage, nframe, imageCrop, barCrop, highTemp, lowTemp)
fontSize = 15;

% Useful for finding image and color map regions of image.
% imshow(min(frameImage, [], 3), [])
% imshow(max(frameImage, [], 3), [])
% imshow((min(frameImage, [], 3)+max(frameImage, [], 3))/2, [])

% Need to crop out the image and the color bar separately.
% Get the crop parameters for image
imageRow1 = imageCrop(1);
imageRow2 = imageCrop(2);
imageCol1 = imageCrop(3);
imageCol2 = imageCrop(4);
% Crop off the surrounding clutter to get the RGB image.
rgbImage = frameImage(imageRow1 : imageRow2, imageCol1 : imageCol2, :);

% Get crop parameters for colorbar
colorBarRow1 = barCrop(1);
colorBarRow2 = barCrop(2);
colorBarCol1 = barCrop(3);
colorBarCol2 = barCrop(4);
% Crop off the surrounding clutter to get the colorbar.
colorBarImage = frameImage(colorBarRow1 : colorBarRow2, colorBarCol1 : colorBarCol2, :);


% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, not the low temperatures.
storedColorMap = flipud(storedColorMap);

% Convert the subject/sample from a pseudocolored RGB image to a grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);
% Display the indexed image.
subplot(2, 3, 1);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Thermal Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Now we need to define the temperatures at the end of the colored temperature scale.
% You can read these off of the image, since we can't figure them out without doing OCR on the image.

% Scale the indexed gray scale image so that it's actual temperatures in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

% Display the thermal image.
subplot(2, 3, 2);
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

% Get and display the histogram of the thermal image.
subplot(2, 3, 3);
histogram(thermalImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Temperature', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency', 'FontSize', fontSize, 'Interpreter', 'None');


% Transform the frame number to a string
frameNum = num2str(nframe);

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', strcat('Frame number : ', frameNum), 'NumberTitle', 'Off')

end