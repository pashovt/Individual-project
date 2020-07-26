function thermalImage = convertToThermalImage(rgbImage, colorBarImage, ...
    highTemp, lowTemp)
% Generates an image that contains the temperature values 
% for each pixel based on the colorbar inside the frame image

% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, 
% not the low temperatures.
storedColorMap = flipud(storedColorMap);

% Convert the subject/sample from a pseudocolored RGB image to a 
% grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);

% Now we need to define the temperatures at the end of the colored 
% temperature scale. You can read these off of the image, since we 
% can't figure them out without doing OCR on the image.

% Scale the indexed gray scale image so that it's actual temperatures 
% in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

end
