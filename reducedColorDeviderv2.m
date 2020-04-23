function [binaryImage, meanIntensity] = reducedColorDeviderv2(RGBframe)
% Reduced version of the colorDevider function for extracting the binaty
% green image. It returns the most accurate value of the size of features 
% present in the frame.
% The prove for it can be seen using the colorDevider function
% The message output contains the mean values for the different color
% channels

% Extract the individual red, green, and blue color channels.
redChannel = RGBframe(:, :, 1);
% getBar(redChannel)
greenChannel = RGBframe(:, :, 2);
% getBar(greenChannel)
blueChannel = RGBframe(:, :, 3);
% getBar(blueChannel)

% Create a binary image
binaryImage = greenChannel > 13;
% Fill holes
binaryImage = imfill(binaryImage, 'holes');
% Get rid of small specks.
binaryImage = bwareaopen(binaryImage, 10000);


redMean = mean(redChannel(binaryImage));
blueMean = mean(blueChannel(binaryImage));
measurements = regionprops(binaryImage, greenChannel, 'MeanIntensity');
greenMean = measurements.MeanIntensity;

meanIntensity.red = redMean;
meanIntensity.green = greenMean;
meanIntensity.blue = blueMean;

end
