%% System Config
format shortG;
format compact;
% set(0,'DefaultFigureWindowStyle','docked')


filename = "FLIR0206v2.mp4";
main_operator = "to crop";
% main(filename, main_operator)


%% Step 0: Get data
vidObj = VideoReader(filename);
% Video properties
Height = vidObj.Height;
Width = vidObj.Width;
numFrames = vidObj.NumFrames;

sampleFrame = read(vidObj, 1);

%% Cropped values
colorBarCrop = [30, 200, 306, 306+9];
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

%% TO REMOVE POINTER FROM THE FRAME

%% Cropped Images
% Undestorted image
CroppedRGBFrame = sampleFrame(imageCrop(1):imageCrop(2), ...
    imageCrop(3):imageCrop(4), :);
% Colorbar
CroppedRGBColorBar = sampleFrame(colorBarCrop(1):colorBarCrop(2), ...
    colorBarCrop(3):colorBarCrop(4), :);

%% Temperature extaction
%% CHANGE COLOR BOX
figure; imshow(rgb2ind(frame, 64))
figure; imshow(rgb2ind(frame, 128))
figure; imshow(rgb2ind(frame, 256))
figure; imshow(rgb2ind(frame, 512))
figure; imshow(rgb2ind(frame, 1024))
figure; imshow(rgb2ind(frame, 2048))

BW = edge(rgb2gray(sampleFrame), 'sobel');
colorScaleRegion = BW(:, end-40:end);
% imshow(colorScaleRegion)

% Cropping the section where high temp reading is
highTempCrop = colorScaleRegion;
% Cropping the section where low temp reading is
lowTempCrop = colorScaleRegion;
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