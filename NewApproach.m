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
% serpentine analysis

% Import sample data/Read video data
videoData = VideoReader("FLIR0206v2.mp4");
vidHeight = videoData.Height;
vidWidth = videoData.Width;

% Cropped values for image - reduces the noice present in the dataset
imageCrop = [140, 240, 100, 200];
colorBar = [25, 200, 303, 303+15];
%% Outomatically find colorbar
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
storedData = struct('colordata',zeros(vidHeight,vidWidth,3), ...
    'colormap',zeros((colorBar(2) - colorBar(1)), (colorBar(4) - colorBar(3)), 3));

% Read frame for frame
% Number of segmentations
nRegions = 20;
numFrames = videoData.NumFrames;
data=zeros(numFrames,nRegions,3);


while(hasFrame(videoData))
    RGBframe = readFrame(videoData);
    nthframe = ceil(videoData.CurrentTime*videoData.FrameRate);

    % Need to crop out the image and the color bar separately.
    % Crop off the surrounding clutter to get the RGB image.
    CroppedRGBFrame = RGBframe(imageCrop(1):imageCrop(2), imageCrop(3):imageCrop(4), :);
    % Crop off the surrounding clutter to get the colorbar.
	CroppedRGBColorBar = RGBframe(colorBar(1):colorBar(2), colorBar(3):colorBar(4), :);

    % OCR (optical character recognition) on the image

    highTempCrop = RGBframe(1:25, 250:size(RGBframe,2), :);
    highTemp = GetNumber(highTempCrop);
    lowTempCrop = RGBframe(200:size(RGBframe, 1), 250:size(RGBframe,2), :);
    lowTemp = GetNumber(lowTempCrop);

    if highTemp < lowTemp
        error('there is a issue in the ocr method')
    end

    % Temperature image
    tempImage = convertToThermalImage(CroppedRGBFrame, CroppedRGBColorBar, highTemp, lowTemp);
    
    histogram(thermalImage, 'Normalization', 'probability');

    %% threshold 
    tempImage2 = tempImage;
    therhold = mean([highTemp, lowTemp]);
    % Get map of where image is less than the threshold
    binaryImage = tempImage2<therhold;
    % Set pixels meeting threshold criteria to black (zeros).
    tempImage2(binaryImage) = 0; % Set to black
    imshow(tempImage2, [])
%%    SEGMENT IMAGE
    if rem(nthframe, 100) == 1
        Aref=RGBframe;
        Alab_ref=rgb2lab(RGBframe); % For normal array image - 3d or more
%         Alab_ref=rgb2lab( repmat(reducedFrame, [1 1 3]) ); % for 2d array image
    end
    
    Alab = rgb2lab(RGBframe);
    
    [L,N] = superpixels(Alab_ref,nRegions,'isInputLab',true);
    BW = boundarymask(L);
%     res = imOverlay(thermalImage, BW, 'cyan')
    imshow(imoverlay(RGBframe,BW,'cyan'), [])
    
    pixelIdxList = label2idx(L);
    meanColor = zeros(N,3);
    [m,n] = size(L);
    for  i = 1:N
        meanColor(i,1) = median(Alab(pixelIdxList{i}));
        meanColor(i,2) = median(Alab(pixelIdxList{i}+m*n));
        meanColor(i,3) = median(Alab(pixelIdxList{i}+2*m*n));
        data(nthframe, i,1) = meanColor(i,1);
        data(nthframe, i,2) = meanColor(i,2) ;
        data(nthframe, i,3) = meanColor(i,3);
    end
    numColors = nRegions;
    [idx,cmap] = kmeans(meanColor,numColors,'replicates',2);
    cmap = lab2rgb(cmap);
    Lout = zeros(size(RGBframe,1),size(RGBframe,2));
    for i = 1:N
        Lout(pixelIdxList{i}) = idx(i);
    end
end


%%
function thermalImage = convertToThermalImage(rgbImage, colorBarImage, highTemp, lowTemp)

% Useful for finding image and color map regions of image.
% imshow(min(frameImage, [], 3), [])
% imshow(max(frameImage, [], 3), [])
% imshow((min(frameImage, [], 3)+max(frameImage, [], 3))/2, [])

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
