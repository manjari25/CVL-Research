function [ gaussianResponses ] = makeGaussianFilters( I, scale )
% Given Image and appropriate scale of each pixel, function outputs
% normalized gaussian response for the image
    nir = size(I,1);
    nic = size(I,2);
    gaussianResponses = zeros(nir,nic);
    for i=1:nir
        for j=1:nic
            gF = scale^2.*fspecial('gaussian',193,scale(i,j));
            response = imfilter(I,gF,'replicate');
            gaussianResponses(i,j) = response(i,j);
        end
    end
end