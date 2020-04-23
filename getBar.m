function getBar(redChannel)
binimg = im2bw(redChannel(:, end-50:end));
sz = regionprops(binimg);
figure; imshow(binimg, [])
hold on
for ii = 1:numel(sz)
    vals = sz(ii).BoundingBox;
    if any(vals<1)
        vals(vals<1) = 1;
    end
    x = floor(vals(1));
    y = floor(vals(2));
    w = ceil(vals(3));
    h = ceil(vals(4));
    %     row = y:y+h;
    %     column = x:x+w;
    % checker for box comparison
    rectangle('Position', [x,y,w,h],...
        'EdgeColor','r','LineWidth',2 )
end
end