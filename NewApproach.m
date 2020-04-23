close all
clear
clc
format shortG;
format compact;
fileName = 'FLIR0206v2.mp4';
set(0,'DefaultFigureWindowStyle','docked')
% data = summaryCode(fileName);


% Import sample data/Read video data
videoData = VideoReader("FLIR0206v2.mp4");
vidHeight = videoData.Height;
vidWidth = videoData.Width;

% Noise boxes that are to be ignored during the image processing 
distoredRegions = getBoxes(videoData);
videoData.CurrentTime = 0;
sampleFrame = read(videoData, 1);
secondDistoredRegions = edge(rgb2gray(sampleFrame), 'sobel', 0.25);
distoredRegions(secondDistoredRegions==1) = 0;
colorScaleRegion = secondDistoredRegions(:, end-50:end);

%%
% bw = im2bw(colorScaleRegion);
% 
% % find both black and white regions
% stats = regionprops(bw); %[regionprops(bw); regionprops(not(bw))];
% 
% imshow(bw, [])
% hold on 
% for ii = 1:numel(stats)
%     vals = stats(ii).BoundingBox;
%     if any(vals<1)
%         vals(vals<1) = 1;
%     end
%     x = floor(vals(1));
%     y = floor(vals(2));
%     w = ceil(vals(3));
%     h = ceil(vals(4));
% %     row = y:y+h;
% %     column = x:x+w;
%     % checker for box comparison
%     rectangle('Position', [x,y,w,h],...
%         'EdgeColor','r','LineWidth',2 )
% end
%% Thicken the boundary of the colorbar 
% use morphological analysis with vertical and horizontal struc element
% (strel) with size of 5 or 10 pixels
% then apply box allocation
% Cropped values for colorbar 
colorBar = [25, 200, 303, 303+15];

% Number of frames
numFrames = videoData.NumFrames;
% Number of segmentations
nRegions = 20;

% Storage variables
% storedData(numFrames) = struct('colordata',zeros(vidHeight,vidWidth,3), ...
%     'colormap',zeros((colorBar(2) - colorBar(1)), (colorBar(4) - colorBar(3)), 3));
storedData(numFrames) = struct('colordata', 0, 'colormap',0);
% second storage variable
data=zeros(numFrames,nRegions,3);


% Read frame for frame
while(hasFrame(videoData))


    % read the next frame
    RGBframe = readFrame(videoData);
    % find which frame has been read
    nthframe = ceil(videoData.CurrentTime*videoData.FrameRate);

    % for scaller plot or similar to the curve fitting one
    xv = 1:size(RGBframe, 1);
    yv = 1:size(RGBframe, 2);
    grayImage = rgb2gray(RGBframe);
    %     plot3(xv,yv,grayImage)
    
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

    DistoredRegions = edge(rgb2gray(RGBframe), 'sobel', 0.25);
    colorRegion = DistoredRegions(:, end-50:end);
    topCorner = colorRegion(1:50, :);
    bottomCorner = colorRegion(end-50:end, :);
    imshow(imdilate(topCorner, strel('disc', 2)))
    imshow(bottomCorner)
    imdilate(topCorner, strel('disc', 2))
    % Cropping out the colorbar and undestorted image
    %% TO CHANGE the crop for the undestored image
    % Undestorted image
    CroppedRGBFrame = RGBframe(imageCrop(1):imageCrop(2), imageCrop(3):imageCrop(4), :);
    % Colorbar
	CroppedRGBColorBar = RGBframe(colorBar(1):colorBar(2), colorBar(3):colorBar(4), :);

    % Cropping the section where high temp reading is
    highTempCrop = RGBframe(1:25, 250:size(RGBframe,2), :);
    % Cropping the section where low temp reading is
    lowTempCrop = RGBframe(200:size(RGBframe, 1), 250:size(RGBframe,2), :);
    % OCR (optical character recognition) on the image
    % Find the value for the high temp based on the image
    highTemp = GetTempNumber(highTempCrop);
    % Find the value for the low temp based on the image
    lowTemp = GetTempNumber(lowTempCrop);

    % checks if the OCR method has worked succefully and has returned wrong
    % values
    if highTemp < lowTemp
        error('there is a issue in the ocr method')
    end

    % Generates an image that contains the temperature values of each pixel
    % based on the colorbar
    tempImage = convertToThermalImage(CroppedRGBFrame, CroppedRGBColorBar, highTemp, lowTemp);

    threshold = highTemp; ...(lowTemp+highTemp)/1.5;
    pos = find(tempImage>threshold-0.5 & tempImage<threshold+0.5);
    row = rem(pos(1), size(RGBframe, 1));
    col = ceil(pos(1)/size(RGBframe, 2));
    highLevelExposure = imbinarize(rgb2gray(RGBframe), ...
        double(rgb2gray(RGBframe(row, col, :)))/255);
    originalBinary = imbinarize(rgb2gray(RGBframe));

    figure; imshow(highLevelExposure)
    figure; imshow(originalBinary)

    figure; imcontour(originalBinary)
    figure; imcontour(highLevelExposure)
%     figure; imhist(originalBinary)
%     figure; imhist(grayImage)
%     figure; imhist(RGBframe)
    figure; imshow(RGBframe)
    
    %% apply edge to lab image
    frameName = './frames/frame1.jpg';
    methods = {'sobel'};
    for ii = 1:length(methods)
        reducedFrameAnalysis(frameName, methods{ii})
    end
    
    roipoly
    
    sample_region = [50 100 50 100]; % region of interest
    x = RGBframe;
    cform = makecform('srgb2lab');
    lab_x = applycform(x, cform);
    
    a = lab_x(:, :, 2);
    b = lab_x(:, :, 3);
    color_markers = repmat(0, [6, 2]); % 6 - number of regions
    for cc = 1:6
        color_markers(cc, 1) = mean2(a(sample_region(:,:,cc)));
        color_markers(cc, 2) = mean2(b(sample_region(:,:,cc)));
    end
%%    SEGMENT IMAGE


end


%% Generates an image that contains the temperature values 
% for each pixel based on the colorbar inside the frame image
function thermalImage = convertToThermalImage(rgbImage, colorBarImage, highTemp, lowTemp)

% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, not the low temperatures.
storedColorMap = flipud(storedColorMap);

% Convert the subject/sample from a pseudocolored RGB image to a grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);

% Now we need to define the temperatures at the end of the colored temperature scale.
% You can read these off of the image, since we can't figure them out without doing OCR on the image.

% Scale the indexed gray scale image so that it's actual temperatures in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

end
