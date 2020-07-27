function distoredRegions = getBoxes(videoData)

val = 25;
frameReadingAreaX = [val videoData.Height-val];
frameReadingAreaY = [val videoData.Width-val];
data(videoData.NumFrames).data = struct();
distoredRegions = ones(videoData.Height, videoData.Width);
while(hasFrame(videoData))
    % read the next frame
    RGBframe = readFrame(videoData);
    % find which frame has been read
    nthframe = ceil(videoData.CurrentTime*videoData.FrameRate);


    bw = im2bw(RGBframe);

    % find both black and white regions
    stats = [regionprops(bw); regionprops(not(bw))];
    
    counter1 = 0;
    for jj = 1:numel(stats)
        if not(frameReadingAreaX(1) < stats(jj).Centroid(2) && ...
                stats(jj).Centroid(2) < frameReadingAreaX(2) && ...
                frameReadingAreaY(1) < stats(jj).Centroid(1) && ...
                stats(jj).Centroid(1) < frameReadingAreaY(2))
            if stats(jj).Area > 5
                counter1 = counter1 + 1;
            end
        end
    end
    
    newstats(counter1).Area = 0;
    newstats(counter1).Centroid = 0;
    newstats(counter1).BoundingBox = 0;
    counter2 = 1;
    for jk = 1:numel(stats)
        if not(frameReadingAreaX(1) < stats(jk).Centroid(2) && ...
                stats(jk).Centroid(2) < frameReadingAreaX(2) && ...
                frameReadingAreaY(1) < stats(jk).Centroid(1) && ...
                stats(jk).Centroid(1) < frameReadingAreaY(2))
            if stats(jk).Area > 5
                newstats(counter2) = stats(jk);
                counter2 = counter2 + 1;
            end
        end
    end
    data(nthframe).data = newstats;
end

d = zeros(videoData.NumFrames, 1);
for k = 1:numel(data)
    d(k) = size(data(k).data, 2);
end

dt = data(find(d>0, 1)).data;

% enlarger regions
for ii = 1:numel(dt)
    vals = [dt(ii).BoundingBox(1), ... % x
        dt(ii).BoundingBox(2), ... % y
        dt(ii).BoundingBox(3), ... % w
        dt(ii).BoundingBox(4)]; % h
    if any(vals<1) 
        vals(vals<1) = 1;
    end
    x = floor(vals(1));
    y = floor(vals(2));
    w = ceil(vals(3));
    h = ceil(vals(4));
    row = y:y+h;
    column = x:x+w;
    distoredRegions(row, column) = 0;
    % checker for box comparison
%     imshow(distoredRegions, [])
%     rectangle('Position', [dt(ii).BoundingBox(1),dt(ii).BoundingBox(2),dt(ii).BoundingBox(3),dt(ii).BoundingBox(4)],...
%         'EdgeColor','r','LineWidth',2 )
end
end