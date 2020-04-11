function DaveApproach(RGBframe, nthframe)

if rem(nthframe, 100) == 1
%     Aref=RGBframe;
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