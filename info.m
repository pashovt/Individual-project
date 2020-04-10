%% push grey image for segmentation

%% image (number recognition) - extraction of the limits for the temperature scale


%% Make a further crop - middle of the image where low noise can be seen
%% Plot a fitted curve on the further crop image for polynomial 5x5

% mask explanation
mask = L < 0;
light_blue = [.6 .6 1];
overlay = imoverlay(rgb, mask, light_blue);

%% Info
maxTemp = max(temperatureImage(:))

% hasFrame	Determine if video frame is available to read
% read	Read one or more video frames
% readFrame	Read next video frame


% You just simply need to modify the low and high temperature, 
% and adjust the row and column where the image and colorbar are taken from.

% From image processing point of view, channel split functions can segregate 
% the RGB channels, and you can simply use the Red channel image for 
% your purpose.


% You need to analyze the original grayscale image, not the rgb 
% pseudocolored image. To verify you should look at pixel values and 
% compare the intensity at that location with the temp measured with 
% another device, like a thermometer, and use on individuals known to 
% have, or not have, fever.
% To apply pseudocolors, use the colormap() function. There are a variety 
% of built-in colormaps you can choose from, in addition to building your 
% own custom colormap.

