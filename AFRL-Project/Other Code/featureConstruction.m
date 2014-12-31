function [ gr,g1xr,g1yr,g2xr,g2yr ] = featureConstruction(I, pixel, scale )
%FEATURECONSTRUCTION Summary of this function goes here
%   Detailed explanation goes here
gF = (fspecial('gaussian',193,scale));%scale^2.*
[g1xF,g1yF] = gaussDeriv2D(scale,193,96);
[g2xF,g2yF] = gaussDeriv2DS(scale,193,96);
resp = imfilter(I,gF,'replicate');
gr = resp(pixel(2,1),pixel(1,1));
resp = imfilter(I,(g1xF),'replicate');
g1xr = resp(pixel(2,1),pixel(1,1));
resp = imfilter(I,(g1yF),'replicate');
g1yr = resp(pixel(2,1),pixel(1,1));
resp = imfilter(I,(g2xF),'replicate');
g2xr = resp(pixel(2,1),pixel(1,1));
resp = imfilter(I,(g2yF),'replicate');
g2yr = resp(pixel(2,1),pixel(1,1));
end

