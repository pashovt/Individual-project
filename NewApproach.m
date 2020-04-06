%% Load imaging file
videoData = VideoReader("FLIR0206v2.mp4");
% hasFrame	Determine if video frame is available to read
% read	Read one or more video frames
% readFrame	Read next video frame

%% Cut to top and right side (from the analysis) where the readings are
% Crop colorbar and video readings data on top

%% Read frame for frame
while(hasFrame(videoData))
    frame = readFrame(videoData);

    
    imshow(frame);
end




