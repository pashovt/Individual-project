function numbers = GetTempNumber(image)
% https://uk.mathworks.com/matlabcentral/answers/377444-why-ocr-function-doesn-t-recognize-the-numbers
if size(image, 3) == 3 % rgb image 
    ii = rgb2gray(image);
    ii(ii>0 & ii <220) = 0;
    BW = imdilate(ii,strel('disk',1));
    ocrResults = ocr(BW,'CharacterSet','.0123456789','TextLayout','word');
elseif size(image, 1) % gray image
    ii = image;
    %BWdfill = imfill(ii,'holes');
end
ocrResults = ocr(ii,'CharacterSet','.0123456789','TextLayout','word');
numbers = ocrResults(:).Text;
numbers = str2double(deblank(numbers));

decimalCheck = num2str(numbers);
if ~contains(decimalCheck, '.')
    newnumber = strcat(decimalCheck(1:end-1), '.', decimalCheck(end));
    numbers = str2double(newnumber);
end
    
end