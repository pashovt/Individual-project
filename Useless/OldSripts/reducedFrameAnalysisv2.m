function reducedFrameAnalysisv2(ImageRaw, method)
GrayImage = rgb2gray(ImageRaw);
[~,threshold] = edge(GrayImage,method);

fudgeFactor = 0.5;
BWs = edge(GrayImage,method,threshold * fudgeFactor);
figure; imshow(BWs); title('Edge only')
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]);

BWdfill = imfill(BWsdil,'holes');

seD = strel('diamond',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);

figure;
subplot(1, 2, 2);
% figure; imshow(labeloverlay(GrayImage,BWsdil))
imshow(labeloverlay(GrayImage,BWdfill)); title('overlayed edge detection')
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
imshow(Segout2); title('darkened gray image')

end