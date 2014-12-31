% Last Edit: 12/16/14
function [ logResponses ] = logFilterResponses(I, scales )
%GENERATELOGFILTERS Generates and returns log filters at given scales
%and returns the responses different scales
%Input = scales = [scale1,scale2,scale3..] 
    for i=1:size(scales,2)
        logF = (scales(1,i)^2).*(fspecial('log',193,scales(1,i)));
        logResponses(:,:,i) = imfilter(I,logF,'replicate');
    end
end

