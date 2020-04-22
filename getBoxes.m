function data = getBoxes(videoData)

val = 25;
frameReadingAreaX = [val videoData.Height-val];
frameReadingAreaY = [val videoData.Width-val];
videoData.NumFrames
data(videoData.NumFrames, :) = 0;

while(hasFrame(videoData))
    % read the next frame
    RGBframe = readFrame(videoData);
    % find which frame has been read
    nthframe = ceil(videoData.CurrentTime*videoData.FrameRate)


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
    
    newstats(counter1, :) = 0;
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
    data(nthframe) = newstats;
end
end