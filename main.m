%% System Config
format shortG;
format compact;
% set(0,'DefaultFigureWindowStyle','docked')


filename = 'FLIR0206v2.mp4';
main_operator = 'to crop';
% main(filename, main_operator)


%% Step 0: Get data
vidObj = VideoReader(filename);
% Video properties
Height = vidObj.Height;
Width = vidObj.Width;
numFrames = vidObj.NumFrames;

sampleFrame = read(vidObj, 1);

%% Cropped values
colorBarCrop = [31, 200, ceil(mean([306, 306+9])), ceil(mean([306, 306+9]))];
imageCrop = [90, 210, 1, 300];

%% Storage variables
storedData(numFrames) = struct(...
    'colordata', zeros((imageCrop(2) - imageCrop(1)), (imageCrop(4) - imageCrop(3)), 3), ...
    'colormap', zeros((colorBar(2) - colorBar(1)), (colorBar(4) - colorBar(3)), 3), ...
    'MaxTemp', zeros(numFrames), ...
    'MinTemp', zeros(numFrames) ...
    );
% storedData = populateStruct(vidObj, storedData);
% Old stript
% empty_struct = container(Height, Width);
% populated_struct = populateStruct(vidObj, empty_struct);

%% Pointer noise position
% [pointerOutliner, distoredRegions] = pointerNoise(vidObj);
load pointerNoise.mat % pointerOutliner
load distoredRegions.mat
%% Analysis
% read the next frame
% RGBframe = readFrame(vidObj);
% find which frame has been read
% nthframe = ceil(vidObj.CurrentTime*vidObj.FrameRate);

%% Extraction of colorbar before corruption during the application the median filter
% Colorbar
CroppedRGBColorBar = sampleFrame(colorBarCrop(1):colorBarCrop(2), ...
    colorBarCrop(3):colorBarCrop(4), :);

%% Removes pointer from the frame using 
channelSize = size(sampleFrame(:,:,1));
channelLength = channelSize(1)*channelSize(2);
pos = find(pointerOutliner==0);

for channel=1:size(sampleFrame, 3)
    FirstImageFilter = medfilt2(sampleFrame(:,:,channel));
    SecondImageFilter = medfilt2(FirstImageFilter);
    ThirdImageFilter = medfilt2(SecondImageFilter);
    sampleFrame(channelLength*(channel-1)+pos) = ...
        ThirdImageFilter(pos);
end

%% Image Crop of the RGB
% Undestorted image
noPointer = sampleFrame;
sampleFrame = noPointer;
% image crop
CroppedRGBFrame = sampleFrame(imageCrop(1):imageCrop(2), ...
    imageCrop(3):imageCrop(4), :);

% blackened image
r = [1:imageCrop(1)-1, imageCrop(2)+1:size(sampleFrame, 1)];
c = [1:(imageCrop(3)-1), imageCrop(4)+1:size(sampleFrame,2)];
sampleFrame(1:imageCrop(1)-1,:,:) = 0;
sampleFrame(imageCrop(2)+1:size(sampleFrame, 1),:,:) = 0;
sampleFrame(:,1:(imageCrop(3)-1),:) = 0;
sampleFrame(:,imageCrop(4)+1:size(sampleFrame,2),:) = 0;
imshow(sampleFrame)


pos = find(~distoredRegions);
for channel=1:size(sampleFrame, 3)
    sampleFrame(channelLength*(channel-1)+pos) = 0;
end
imshow(sampleFrame)

% thresholding
[binaryMask, thresholdedImage] = HSVMask(sampleFrame);
[BW2,maskedImage2] = segmentImageLine(rgb2gray(sampleFrame));
[BW,maskedImage] = segmentImageDisk(rgb2gray(sampleFrame));
figure;
subplot(2,2,1); imshow(sampleFrame)
subplot(2,2,2); imshow(thresholdedImage)
subplot(2,2,3); imshow(maskedImage2)
subplot(2,2,4); imshow(maskedImage)

imshow(imoverlay(thresholdedImage,maskedImage,'cyan'))
imshow(imoverlay(maskedImage,maskedImage2,'cyan'))
% The best choice
imshow(imoverlay(maskedImage2,maskedImage,'cyan'))


pos2 = find(maskedImage2==0);
for channel=1:size(sampleFrame, 3)
    sampleFrame(channelLength*(channel-1)+pos2) = 0;
end
imshow(sampleFrame)

% [temperatureImageMap, indColorMap] = convertToThermalImage(...
%     sampleFrame, CroppedRGBColorBar, ...
%     highTemp, lowTemp);
g = rgb2gray(sampleFrame);
surf(g)
contour3(g)

%% RGB image analysis

%% usage of multiple filters on the rgb image - FAILURE
sampleFrame = noPointer;
for channel=1:size(sampleFrame, 3)
%     GaussianFilter = imgaussfilt(sampleFrame(:,:,channel));
    sampleFrame(:, :, channel) = medfilt2(sampleFrame(:,:,channel));
%     ThirdImageFilter = medfilt2(SecondImageFilter);
%     sampleFrame(:, :, channel) = GaussianFilter;
end
imshow(sampleFrame)

%% Temperature extaction
colorScaleRegion = sampleFrame(5:235, end-40:end-3);

% OCR (optical character recognition) on the image
% Find the value for the high temp based on the image
highTemp = GetTempNumber(colorScaleRegion(1:20,:));
% Find the value for the low temp based on the image
lowTemp = GetTempNumber(colorScaleRegion(end-20:end,:));

% checks if the OCR method has worked succefully and has returned wrong
% values
if highTemp < lowTemp
    error('there is a issue in the ocr method')
end

% Generates an image that contains the temperature values of each pixel
% based on the colorbar
[temperatureImageMap, indColorMap] = convertToThermalImage(...
    CroppedRGBFrame, CroppedRGBColorBar, ...
    highTemp, lowTemp);

imshow(ind2rgb(CroppedRGBFrame, indColorMap))


%% Proves the need for removal of the backgound and the data boxes
% showcases the need for additional processing
greenChannel = sampleFrame(:,:,3);
% Create a binary image
binaryImage = greenChannel > 13;
% Fill holes
binaryImage = imfill(binaryImage, 'holes');
% Get rid of small particles less than 10000 pixels in area.
binaryImage = bwareaopen(binaryImage, 10000);
figure; imshow(binaryImage)
title(strcat('Frame ', num2str(nthframe)))    

% pure binary image
originalBinary = imbinarize(rgb2gray(sampleFrame));
imshow(originalBinary)
title('normal binary image')

% imsharpen failure
figure;
subplot(1,2,1); imshow(sampleFrame); title('original frame')
subplot(1,2,2); imshow(imsharpen(sampleFrame)); title('sharpened frame')
figure; imshow(sampleFrame-imsharpen(sampleFrame))

% Find Threshold and Segmentation failure of adaptthresh
% Read image into the workspace. 
I = rgb2gray(sampleFrame);
% Use |adaptthresh| to determine threshold to use in binarization operation.
T = adaptthresh(I, 0.2);
% Convert image to binary image, specifying the threshold value.
BW = imbinarize(I,T);
% Display the original image with the binary version, side-by-side.
figure
imshowpair(I, BW, 'montage')

Iblur = imgaussfilt(sampleFrame,5);
imshow(Iblur)


%% Populate the empty strucure from container function with frame 
% data from the video
function empty_struct = populateStruct(video, empty_struct)
while hasFrame(video)
    nthframe = ceil(video.CurrentTime*video.FrameRate);
    empty_struct(nthframe).colordata = readFrame(video);
    % save the frame as a .jpg image
    % imwrite(empty_struct(nthframe).colordata, strcat(...
    %     './frames/frame', num2str(nthframe), '.jpg'));
end
end