function main(filename, coller_type)

vid = VideoReader(filename);

numFrames = vidObj.NumFrames;

Height = vidObj.Height;
Width = vidObj.Width;
empty_struct = container(Height, Width);
populated_struct = populateStruct(vid, empty_struct);

frame = read(vid, 1);
if coller_type == "to crop"

    imshow(frame)
    
    
end

end

% Create an emptry strucure that will hause the video frame data
function structure = container(Height, Width)
structure = struct('colordata',zeros(Height,Width,3,'uint8'),...
    'colormap',[]);
end

% Populate the empty strucure from container function with frame 
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

%% TO CHECK
function [data, Lout] = VideoAnalyser(numFrames, s, nreg)
data=zeros(numFrames,nreg,3);

take_ref = 1:100:numFrames;

for nframe = 1:numFrames
    if find(take_ref==nframe)
       Aref=s(nframe).colordata;
       Alab_ref=rgb2lab(Aref);
    end
    
    A=s(nframe).colordata;
    Alab = rgb2lab(A);
    [L,N] = superpixels(Alab_ref,nreg,'isInputLab',true);
    BW = boundarymask(L);
    %f1=figure();
    imshow(imoverlay(A,BW,'cyan'))
    pixelIdxList = label2idx(L);
    meanColor = zeros(N,3);
    [m,n] = size(L);
    for  i = 1:N
        meanColor(i,1) = median(Alab(pixelIdxList{i}));
        meanColor(i,2) = median(Alab(pixelIdxList{i}+m*n));
        meanColor(i,3) = median(Alab(pixelIdxList{i}+2*m*n));
        data(nframe, i,1) = meanColor(i,1); 
        data(nframe, i,2) = meanColor(i,2) ;
        data(nframe, i,3) = meanColor(i,3); 
    end
    numColors = nreg;
%     idx = kmeans(meanColor,numColors,'replicates',2);
    [idx,cmap] = kmeans(meanColor,numColors,'replicates',2);
    cmap = lab2rgb(cmap);
    Lout = zeros(size(A,1),size(A,2));
    for j = 1:N
        Lout(pixelIdxList{j}) = idx(j);
    end
%     f2=figure();
% 
%     imshow(label2rgb(Lout))
%     f3=figure();
% 
%     imshow(Lout,cmap)
end
end

function DataPlotter(numFrames, nreg, data)
figure;
grid on
hold on
% c = linspace(0,1,nreg);
rgb=jet(nreg);
% tic,
for N = 1:nreg
%     c(N)
%     rgb(N,:)
    scatter(linspace(0,1,numFrames), data(:,N,1),25,rgb(N,:));
end
% toc,
end


%% More to check
% Import sample data/Read video data
videoData = VideoReader("FLIR0206v2.mp4");
vidHeight = videoData.Height;
vidWidth = videoData.Width;

%% Noise regions
% Noise boxes that are to be ignored during the image processing 
distoredRegions = getBoxes(videoData);
videoData.CurrentTime = 0;
sampleFrame = read(videoData, 1);
secondDistoredRegions = edge(rgb2gray(sampleFrame), 'sobel', 0.25);
%% Add a strel (possible a disc) to fill the gaps
distoredRegions(secondDistoredRegions==1) = 0;
imshow(distoredRegions)
title('noise regions')

%%
colorScaleRegion = secondDistoredRegions(:, end-50:end);
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
imageCrop = [140, 240, 100, 200];

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
    figure; imshow(RGBframe); title('raw frame')
    %% binary green channel image
    % gets binary image from the green channel
    [binaryImage, meanIntensity] = reducedColorDeviderv2(RGBframe);
    figure; imshow(binaryImage)
    title(strcat('Frame ', num2str(nthframe)))
    
%     % for scaller plot or similar to the curve fitting one
%     xv = 1:size(RGBframe, 1);
%     yv = 1:size(RGBframe, 2);
%     grayImage = rgb2gray(RGBframe);
%     %     plot3(xv,yv,grayImage)
    
    

%     DistoredRegions = edge(rgb2gray(RGBframe), 'sobel', 0.25);
%     colorRegion = DistoredRegions(:, end-50:end);
%     topCorner = colorRegion(1:50, :);
%     bottomCorner = colorRegion(end-50:end, :);
%     imshow(imdilate(topCorner, strel('disc', 2)))
%     imshow(bottomCorner)
%     imdilate(topCorner, strel('disc', 2))
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

    figure; 
    subplot(1,2,1); imshow(highLevelExposure); title('high exposure binary image')
    subplot(1,2,2); imshow(originalBinary); title('normal binary image')

%     % contour image
%     figure; 
%     subplot(1,2,1); imcontour(originalBinary)
%     subplot(1,2,2); imcontour(highLevelExposure)
%     figure; imshow(RGBframe)
    
    
%     reducedFrameAnalysis(frameName, 'sobel')
    reducedFrameAnalysisv2(RGBframe, 'sobel')
    
    %% To test
    
%     % %% apply edge to lab image
%     imshow(rgb2lab(RGBframe))
%     % try bounding box
%     imshow(rgb2hsv(RGBframe))
%     imshow(rgb2ycbcr(RGBframe))
%     
%     
%     rgb2lab(RGBframe)
%     roipoly
%     
%     sample_region = [50 100 50 100]; % region of interest
%     x = RGBframe;
%     cform = makecform('srgb2lab');
%     lab_x = applycform(x, cform);
%     
%     a = lab_x(:, :, 2);
%     b = lab_x(:, :, 3);
%     color_markers = repmat(0, [6, 2]); % 6 - number of regions
%     for cc = 1:6
%         color_markers(cc, 1) = mean2(a(sample_region(:,:,cc)));
%         color_markers(cc, 2) = mean2(b(sample_region(:,:,cc)));
%     end
% %%    SEGMENT IMAGE


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

%% Labelling of binary image
% Label each blob with 8-connectivity, so we can make measurements of it
[labeledImage, numberOfBlobs] = bwlabel(binaryImage, 8);
% Apply a variety of pseudo-colors to the regions.
coloredLabelsImage = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); 
% Display the pseudo-colored image.
subplot(3, 3, 3);
imshow(coloredLabelsImage);
title('Labeled Image', 'FontSize', fontSize);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'all')
numberOfBlobs = size(blobMeasurements, 1)