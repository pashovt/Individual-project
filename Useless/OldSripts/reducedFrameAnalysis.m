% bwperim
% Outlines perimeter of objects in binary image
% https://uk.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html

function reducedFrameAnalysis(frameImage, method)
ImageRaw = imread(frameImage);
GrayImage = rgb2gray(ImageRaw);
[~,threshold] = edge(GrayImage,method);
% [~,threshold] = edge(GrayImage,'sobel');
% [~,threshold] = edge(GrayImage,'Prewitt');
% [~,threshold] = edge(GrayImage,'Roberts');
% [~,threshold] = edge(GrayImage,'log');
% [~,threshold] = edge(GrayImage,'zerocross');
% [~,threshold] = edge(GrayImage,'Canny');
% [~,threshold] = edge(GrayImage,'approxcanny');

fudgeFactor = 0.5;
BWs = edge(GrayImage,method,threshold * fudgeFactor);
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]);
% imshow(BWsdil)
% title('Dilated Gradient Mask')

BWdfill = imfill(BWsdil,'holes');
% imshow(BWdfill)
% title('Binary Image with Filled Holes')

seD = strel('diamond',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);

figure;
subplot(1, 2, 2);
% figure; imshow(labeloverlay(GrayImage,BWsdil))
imshow(labeloverlay(GrayImage,BWdfill))
% figure; imshow(labeloverlay(GrayImage,BWfinal))


% BWoutline1 = bwperim(BWsdil);
% Segout1 = GrayImage; 
% Segout1(BWoutline1) = 255; 
% figure; imshow(Segout1)
% 
BWoutline2 = bwperim(BWdfill);
Segout2 = GrayImage; 
Segout2(BWoutline2) = 255; 
subplot(1, 2, 1);
imshow(Segout2)
% 
% BWoutline3 = bwperim(BWfinal);
% Segout3 = GrayImage; 
% Segout3(BWoutline3) = 255; 
% figure; imshow(Segout3)

% Copyright 2004-2013 The MathWorks, Inc.

end