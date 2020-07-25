% Calculates the pixel granularity which is the actual metric value 
% of an individual pixel. The granularity value is qual to the 
% IFOV (instantaneous field of view) in horizontal and vertical direction
% IFOVH = 2 · d · tan(first lens angle/2)/Heigth of frame
% IFOVV = 2 · d · tan(second lens angle/2)/Width of frame
% Where d is the distance from the camere to the specimen
function output = PixelGranularityCalculator(d, varargin)

% first lens angle
FlensAng = 24;
% Second lens angle
SlensAng = 18;
% Height of the frame
Height = 320;
% Width of the frame
Width = 240;
IFOVH = 2*d*tan(FlensAng/2)/Height;
IFOVV = 2*d*tan(SlensAng/2)/Width;

output.IFOVH = IFOVH;
output.IFOVV = IFOVV;

if IFOVH == IFOVV
    output.Granularity = IFOVH;
end

end