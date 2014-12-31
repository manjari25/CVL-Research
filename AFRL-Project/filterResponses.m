function [ logResponses, gaussianResponses, der1Responsesx, der1Responsesy, der2Responsesx, der2Responsesy ] = filterResponses( I, scale, pixel, mode )
% Given Image and appropriate scale of each pixel/pixel and its appropriate scale, function outputs
% normalized gaussian, 1st derivate and 2nd derivative response)
% mode=0 - Image
% mode=1 - At custom pixel
if (mode==0)
    uscale = unique(scale);
    usz = size(uscale,1);
    for j=1:usz
        % For each unique scale in the image build a filter and convolve it
        % with image
        [r,c] = find(scale==uscale(j));
        nsz = size(r,1);
        gF = fspecial('gaussian',193,uscale(j));%uscale(j)^2.*
        logF = uscale(j)^2.*fspecial('log',193,uscale(j));
        [dx1F, dy1F] = gaussDeriv2D(uscale(j),193,96);
        [dx2F, dy2F] = gaussDeriv2DS(uscale(j),193,96);
        % Scale normalize the derivatives
%         dx1F = dx1F.*uscale(j)^2; 
%         dy1F = dy1F.*uscale(j)^2; 
%         dx2F = dx2F.*uscale(j)^2; 
%         dy2F = dy2F.*uscale(j)^2;
        responselog = imfilter(I,logF,'replicate');
        responseg = imfilter(I,gF,'replicate');
        responsedx1 = imfilter(I,dx1F,'replicate');
        responsedy1 = imfilter(I,dy1F,'replicate');
        responsedx2 = imfilter(I,dx2F,'replicate');
        responsedy2 = imfilter(I,dy2F,'replicate');
        % For each pixel set response as feature
        for i=1:nsz
            logResponses(r(i),c(i)) = responselog(r(i),c(i));
            gaussianResponses(r(i),c(i)) = responseg(r(i),c(i));
            der1Responsesx(r(i),c(i)) = responsedx1(r(i),c(i));
            der1Responsesy(r(i),c(i)) = responsedy1(r(i),c(i));
            der2Responsesx(r(i),c(i)) = responsedx2(r(i),c(i));
            der2Responsesy(r(i),c(i)) = responsedy2(r(i),c(i));
        end
    end
else
    %%%%%% have to complete writing this code %%%%%%
    gF = fspecial('gaussian',193,scale);
    [g1xF,g1yF] = gaussDeriv2D(scale,193,96);
    [g2xF,g2yF] = gaussDeriv2DS(scale,193,96);
    resp = imfilter(I,gF,'replicate');
    gr = resp(pixel(2,1),pixel(1,1));
    resp = imfilter(I,g1xF,'replicate');
    g1xr = resp(pixel(2,1),pixel(1,1));
    resp = imfilter(I,g1yF,'replicate');
    g1yr = resp(pixel(2,1),pixel(1,1));
    resp = imfilter(I,g2xF,'replicate');
    g2xr = resp(pixel(2,1),pixel(1,1));
    resp = imfilter(I,g2yF,'replicate');
    g2yr = resp(pixel(2,1),pixel(1,1));

end

