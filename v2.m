sz = regionprops(RGBframe);
imshow(RGBframe, [])
hold on
for ii = 1:numel(sz)
    vals = sz(ii).BoundingBox;
    if any(vals<1)
        vals(vals<1) = 1;
    end
    x = floor(vals(1));
    y = floor(vals(2));
    w = ceil(vals(3));
    h = ceil(vals(4));
    %     row = y:y+h;
    %     column = x:x+w;
    % checker for box comparison
    rectangle('Position', [x,y,w,h],...
        'EdgeColor','r','LineWidth',2 )
end

fontSize = 20;

rgbImage = imread(fullFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 3, 1);
imshow(rgbImage);
title('Original Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);

% Display the color channels
subplot(2, 3, 4);
imshow(redChannel);
title('Red Channel Image', 'FontSize', fontSize);subplot(2, 3, 2);
subplot(2, 3, 5);
imshow(greenChannel);
title('Green Channel Image', 'FontSize', fontSize);subplot(2, 3, 2);
subplot(2, 3, 6);
imshow(blueChannel);
title('Blue Channel Image', 'FontSize', fontSize);

% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(greenChannel);
% Suppress pure black so we can see the histogram.
pixelCount(1) = 0;
subplot(2, 3, 2);
bar(pixelCount);
grid on;
title('Histogram of Green Channel', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

% Create a binary image
binaryImage = greenChannel > 13;
% Fill holes
binaryImage = imfill(binaryImage, 'holes');
% Get rid of small specks.
binaryImage = bwareaopen(binaryImage, 10000);
subplot(2, 3, 3);
imshow(binaryImage);
title('Binary Image', 'FontSize', fontSize);

% Get the mean of the red and blue channel
% within the white pixels of the binary image using one method.
redMean = mean(redChannel(binaryImage))
blueMean = mean(blueChannel(binaryImage))

% Get the mean of the green channel
% within the white pixels of the binary image using one method.
measurements = regionprops(binaryImage, greenChannel, 'MeanIntensity');
greenMean = measurements.MeanIntensity

message = sprintf('The mean red intensity = %.2f.\nThe green mean = %.2f.\nThe mean blue intensity = %.2f.',...
    redMean, greenMean, blueMean);
uiwait(helpdlg(message));


DistoredRegions = edge(rgb2gray(RGBframe), 'sobel', 0.25);
colorRegion = DistoredRegions(:, end-50:end);
topCorner = colorRegion(1:50, :);
bottomCorner = colorRegion(end-50:end, :);
imshow(imdilate(topCorner, strel('disc', 2)))
imshow(bottomCorner)
imdilate(topCorner, strel('disc', 2))