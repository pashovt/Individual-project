close all
clear
clc
format long g;
format compact;
fileName = 'FLIR0206v2.mp4';
% data = summaryCode(fileName);

%% Methodology
% Import sample data
% Read video data
% Analyse data frame for frame
    % Approach 1
        % Recognise min and max temperature for the frame
        % Convert image to heat image
        % Image segment - find approapriate method
    % Approach 2
        % Identify pixel with different thermal value
            % Grid
        % Check emissivity
%
%
% Bad ideas
    % Devide the different segments to diffetent figure for better visualisation
    % Plot vertical difference in comparison to the different segments - construct the image based on vertical reading in 3D plot
%
%
% Extract needed thermal parameters
% Continuasly follow the change on a plot - something like plot data m file
% 
% 
% 
% 

% Import sample data/Read video data
videoData = VideoReader("FLIR0206v2.mp4");
vidHeight = videoData.Height;
vidWidth = videoData.Width;

% Cropped values for image - reduces the noice present in the dataset
imageCrop = [140, 240, 100, 200];
colorBar = [25, 200, 303, 303+15];
%% TODO - Automatically find colorbar and the remaining noise components
% https://uk.mathworks.com/matlabcentral/answers/35243-detecting-rectangle-shape-in-an-image
% img = imread('rect.jpg');
% bw = im2bw(img);
% 
% % find both black and white regions
% stats = [regionprops(bw); regionprops(not(bw))]
% 
% % show the image and draw the detected rectangles on it
% imshow(bw); 
% hold on;
% 
% for i = 1:numel(stats)
%     rectangle('Position', stats(i).BoundingBox, ...
%     'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
% end


% creates a storable variable
% storedData = struct('colordata',zeros(vidHeight,vidWidth,3), ...
%     'colormap',zeros((colorBar(2) - colorBar(1)), (colorBar(4) - colorBar(3)), 3));

% Read frame for frame
% Number of segmentations
nRegions = 20;
numFrames = videoData.NumFrames;
data=zeros(numFrames,nRegions,3);


while(hasFrame(videoData))
    % read the next frame
    RGBframe = readFrame(videoData);
    % find which frame has been read
    nthframe = ceil(videoData.CurrentTime*videoData.FrameRate);

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
    highLevelExposure = imbinarize(rgb2gray(RGBframe), double(rgb2gray(RGBframe(row, col, :)))/255, 'ForegroundPolarity', 'dark');
    imshow(highLevelExposure)
    imshow(RGBframe)
    
    frameName = './frames/frame1.jpg';
    methods = {'sobel', 'Prewitt', 'Roberts', 'log', 'zerocross', 'Canny', 'approxcanny'};
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
