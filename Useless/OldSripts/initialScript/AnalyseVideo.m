nreg=20
data=zeros(numFrames,nreg,3);



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
    A=s(nframe).cdata;
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