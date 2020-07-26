fileName = 'FLIR0206v2.mp4';

videoObj = VideoReader(fileName);

while(hasFrame(videoObj))
    frame = readFrame(videoObj);
    nthframe = ceil(videoObj.CurrentTime*videoObj.FrameRate);
    imwrite(frame, strcat('./frames/frame', num2str(nthframe), '.jpg'));
end