function [binaryImage, message] = colorDevider(RGBframe)
% performing the below analysis it was concluded that the green image
% returns the most accurate value for locating the defects present in the
% frame

fontSize = 20;

% Display the original color image.
subplot(2, 3, 2);
imshow(RGBframe);
title('Original Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% Extract the individual red, green, and blue color channels.
redChannel = RGBframe(:, :, 1);
% getBar(redChannel)
greenChannel = RGBframe(:, :, 2);
% getBar(greenChannel)
blueChannel = RGBframe(:, :, 3);
% getBar(blueChannel)

% red image
% [binaryImage, message] = binaryExtraction(redChannel, greenChannel, blueChannel, [2, 3, 4], ['red', 'green', 'blue'], fontSize);
% green image
[binaryImage, message] = binaryExtraction(greenChannel, redChannel, blueChannel, [2, 3, 5], ['green', 'red', 'blue'], fontSize);
% blue image
% [binaryImage, message] = binaryExtraction(blueChannel, redChannel, greenChannel, [2, 3, 6], ['blue', 'red', 'green'], fontSize);


end


function [binaryImage, message] = binaryExtraction(mainColorChannel, secondColorChannel, thirdColorChannel, pos, order, fontSize)
binaryImage = binarization(mainColorChannel, pos, fontSize);
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


function binaryImage = binarization(Channel, pos, fontSize)
% Create a binary image
binaryImage = Channel > 13;
% Fill holes
binaryImage = imfill(binaryImage, 'holes');
% Get rid of small specks.
binaryImage = bwareaopen(binaryImage, 10000);
subplot(pos(1), pos(2), pos(3));
imshow(binaryImage);
title('Binary Image', 'FontSize', fontSize);
end

