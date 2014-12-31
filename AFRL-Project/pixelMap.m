function [ newPixel ] = pixelMap( pixel, zoom )
%PIXELMAP Summary of this function goes here
%   Detailed explanation goes here
shalf = [0.5,0,0;0,0.5, 0; 0,0,1];
squarter = [0.25,0,0;0,0.25, 0; 0,0,1];
if(zoom==0.5)
    newPixel = shalf*pixel;
elseif(zoom==0.25)
    newPixel = squarter*pixel;
end
newPixel = ceil(newPixel);
end

