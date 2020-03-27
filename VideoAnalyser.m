function [data, Lout] = VideoAnalyser(numFrames, s, nreg)
data=zeros(numFrames,nreg,3);

take_ref2 = 1:100:numFrames;
Alab_ref2(length(take_ref2)).colordata = [];
for ii=1:length(take_ref2)
    Alab_ref2(ii).colordata = rgb2lab(s(take_ref2(ii)).colordata);
end

for nframe = 1:numFrames
    
    Alab = rgb2lab(s(nframe).colordata);
    
%     [L,N] = superpixels(Alab_ref,nreg,'isInputLab',true);
    [L,N] = superpixels(Alab_ref2(find(nframe >= take_ref2, 1, 'last')).colordata,nreg,'isInputLab',true);
    BW = boundarymask(L);
    %f1=figure();
    imshow(imoverlay(s(nframe).colordata,BW,'cyan'))
    pixelIdxList = label2idx(L);
    meanColor = zeros(N,3);
    [m,n] = size(L);
    tic,
    for  i = 1:N
        meanColor(i,1) = median(Alab(pixelIdxList{i}));
        meanColor(i,2) = median(Alab(pixelIdxList{i}+m*n));
        meanColor(i,3) = median(Alab(pixelIdxList{i}+2*m*n));
        data(nframe, i,1) = meanColor(i,1); 
        data(nframe, i,2) = meanColor(i,2) ;
        data(nframe, i,3) = meanColor(i,3); 
    end
    toc,
    numColors = nreg;
    [idx,cmap] = kmeans(meanColor,numColors,'replicates',2);
    cmap = lab2rgb(cmap);
    Lout = zeros(size(s(nframe).colordata,1),size(s(nframe).colordata,2));
    for j = 1:N
        Lout(pixelIdxList{j}) = idx(j);
    end
    %f2=figure();

    %imshow(label2rgb(Lout))
    %f3=figure();

    %imshow(Lout,cmap)
end
end