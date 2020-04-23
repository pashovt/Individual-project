function [binaryImage, message] = reducedColorDevider(RGBframe)
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

% green image
[binaryImage, message] = binaryExtraction(greenChannel, redChannel, blueChannel, ['green', 'red', 'blue']);

end


function [binaryImage, message] = binaryExtraction(mainColorChannel, ...
    secondColorChannel, thirdColorChannel, order)
binaryImage = binarization(mainColorChannel);
% Get the mean of the red and blue channel
% within the white pixels of the binary image using one method.
secondColorMean = mean(secondColorChannel(binaryImage));
thirdColorMean = mean(thirdColorChannel(binaryImage));

% Get the mean of the green channel
% within the white pixels of the binary image using one method.
measurements = regionprops(binaryImage, mainColorChannel, 'MeanIntensity');
mainColorMean = measurements.MeanIntensity;

message = sprintf('The mean %.\f intensity = %.2f.\nThe %.\f mean = %.2f.\nThe mean %.\f intensity = %.2f.',...
    order(1), mainColorMean, order(2), secondColorMean, order(3), thirdColorMean);
end


function binaryImage = binarization(Channel)
% Create a binary image
binaryImage = Channel > 13;
% Fill holes
binaryImage = imfill(binaryImage, 'holes');
% Get rid of small specks.
binaryImage = bwareaopen(binaryImage, 10000);
end

