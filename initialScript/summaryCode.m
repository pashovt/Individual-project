function [data, nreg] = summaryCode(fileName)

% tic,
[s, numFrames] = imageReader(fileName);
% numFrames = 100;
% toc,
nreg = 20;
% tic,
data = VideoAnalyser(numFrames, s, nreg);
% toc,
DataPlotter(numFrames, nreg, data)

end

function [s, numFrames] = imageReader(fileName)
vidObj = VideoReader(fileName);

numFrames = vidObj.NumFrames;

s(numFrames).colordata = [];
% s(numFrames).colormap = [];

k = 0;
while hasFrame(vidObj)
    k = k+1;
    s(k).colordata = uint8(readFrame(vidObj));
end
end

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