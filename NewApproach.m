% Sample data
% Read imaging data
% Analyse video data
% analyse frame for frame
% image segment - find approapriate method
% Devide the different segments to diffetent figure for better visualisation
% Plot vertical difference in comparison to the different segments - construct the image based on vertical reading in 3D plot
% Roll the analysis
% Extract needed thermal parameters
% Continuasly follow the change on a plot - something like plot data m file
% 
% 
% 
% 
% serpentine analysis
% Plot final data



%% Load imaging file
videoData = VideoReader("FLIR0206v2.mp4");
% hasFrame	Determine if video frame is available to read
% read	Read one or more video frames
% readFrame	Read next video frame

vidHeight = videoData.Height;
vidWidth = videoData.Width;

% s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%     'colormap',[]);

%% Cut to top and right side (from the analysis) where the readings are
% Crop colorbar and video readings data on top
% image render

% % Ideal 1:
% Get color bar
% cut unwated area of image
% Refer each pixel to a temp value
%
%% Read frame for frame
% Number of segmentations
nRegions = 20;
numFrames = videoData.NumFrames;
data=zeros(numFrames,nRegions,3);

while(hasFrame(videoData))
    frame = readFrame(videoData);
    cutFrame = frame(30:end-27,1:end-17,:);
    plot3(cutFrame(:,:,1),cutFrame(:,:,2),cutFrame(:,:,3))
    imshow(cutFrame)
%%  
    grayImage = imread(filepath); % Load image
    thresholdValue= 128; % Set threshold value to whatever you want
    % Get map of where image is less than the threshold
    binaryImage = grayImage < thresholdValue;
    % Set pixels meeting threshold criteria to black (zeros).
    grayImage (binaryImage) = 0; % Set to black
    
%%    
    Aref=s(10).cdata;
    Alab_ref=rgb2lab(Aref)
    take_ref=0
    for nframe = 1:numFrames
        if take_ref<1
            take_ref=100
            Aref=s(nframe).cdata;
            Alab_ref=rgb2lab(Aref)
        end
        
        take_ref=take_ref-1
        
        nframe

        [L,N] = superpixels(Alab_ref,nreg,'isInputLab',true);
        BW = boundarymask(L);

        imshow(imoverlay(A,BW,'cyan'))
        
        pixelIdxList = label2idx(L);
        meanColor = zeros(N,3);
        [m,n] = size(L);
        Alab = rgb2lab(s(nframe).cdata);
        for  i = 1:N
            meanColor(i,1) = median(Alab(pixelIdxList{i}));
            meanColor(i,2) = median(Alab(pixelIdxList{i}+m*n));
            meanColor(i,3) = median(Alab(pixelIdxList{i}+2*m*n));
            data(nframe, i,1) = meanColor(i,1);
            data(nframe, i,2) = meanColor(i,2) ;
            data(nframe, i,3) = meanColor(i,3);
        end
        numColors = nreg;
        [idx,cmap] = kmeans(meanColor,numColors,'replicates',2);
        cmap = lab2rgb(cmap);
        Lout = zeros(size(A,1),size(A,2));
        for i = 1:N
            Lout(pixelIdxList{i}) = idx(i);
        end
        %f2=figure();
        
        %imshow(label2rgb(Lout))
        %f3=figure();
        
        %imshow(Lout,cmap)
    end
    
    imshow(frame);
end




