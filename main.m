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
colorBarCrop = [30, 200, ceil(mean([306, 306+9])), ceil(mean([306, 306+9]))];
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
% pointerOutliner = pointerNoise(vidObj);
load pointerNoise.mat % pointerOutliner

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

% failure of division of image and removal of pointer
rgbImage = sampleFrame;
colorBarImage = sampleFrame(colorBarCrop(1):colorBarCrop(2), ...
    colorBarCrop(3):colorBarCrop(4), :);

% Failure of rgb to 2d, median * 3 and 2d to rgb
% rgb to 2d
% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,size(colorBarImage,2)/2,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, 
% not the low temperatures.
storedColorMap = flipud(storedColorMap);
% Convert the subject/sample from a pseudocolored RGB image to a 
% grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);

FirstImageFilter = medfilt2(indexedImage);
SecondImageFilter = medfilt2(FirstImageFilter);
ThirdImageFilter = medfilt2(SecondImageFilter);
% 2d to rgb
BluredRGBImage = ind2rgb(indexedImage, storedColorMap);
sampleFrame(pointerOutliner==0) = BluredRGBImage(pointerOutliner==0);

figure;
subplot(1,2,1); imshow(BluredRGBImage); title('Blured frame')
subplot(1,2,2); imshow(sampleFrame); title('Pointer removed')

% difference between rgb2ind image and the gray image - great image quality
% difference
figure;
subplot(1,2,1); imshow(indexedImage)
subplot(1,2,2); imshow(rgb2gray(sampleFrame))

% pointer removed from gray image
FirstImageFilter = medfilt2(rgb2gray(sampleFrame));
SecondImageFilter = medfilt2(FirstImageFilter);
ThirdImageFilter = medfilt2(SecondImageFilter);
figure;
subplot(1,3,1); imshow(FirstImageFilter); title('Blured frame')
subplot(1,3,2); imshow(SecondImageFilter); title('Pointer removed')
subplot(1,3,3); imshow(ThirdImageFilter); title('Pointer removed')


%% Image Crop of the RGB
% Undestorted image
CroppedRGBFrame = sampleFrame(imageCrop(1):imageCrop(2), ...
    imageCrop(3):imageCrop(4), :);
noPointer = sampleFrame;

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


%% Create an emptry strucure that will hause the video frame data
% NOT USED
function structure = container(Height, Width)
structure = struct('colordata',zeros(Height,Width,3,'uint8'),...
    'colormap',[]);
end

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