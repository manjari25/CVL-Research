% Last Edit: 12/17/14
function [ SPIAvg ] = generateAverageRGBforSuperPixelImage( I, Splabel)
%generateAverageRGBforSuperPixelImage Computes average RGB of the superpixel 
%image

% Define size of the input image
N = size(I,1);
M = size(I,2);

%Original image R,G,B
IR = I(:,:,1);
IG = I(:,:,2);
IB = I(:,:,3);

%Superpixel image R,G,B
IAvgR = zeros(N,M);
IAvgG = zeros(N,M);
IAvgB = zeros(N,M);

%number of labels
nlabels = max(max(Splabel));

%For each label(superpixel)
for i = 1:nlabels
    %Generate mask
    mask=Splabel;
    mask(mask~=i)=0;
    
    %Use mask to compute average R
    temp = (IR & mask).*IR;
    avgR = sum(sum(temp))/nnz(temp);
    tempR=temp;
    tempR(tempR~=0)=avgR;
    IAvgR = IAvgR+tempR;
    
    %Use mask to compute average G
    temp = (IG & mask).*IG;
    avgG = sum(sum(temp))/nnz(temp);
    tempG=temp;
    tempG(tempG~=0)=avgG;
    IAvgG = IAvgG+tempG;
    
    %Use mask to compute average B
    temp = (IB & mask).*IB;
    avgB = sum(sum(temp))/nnz(temp);
    tempB=temp;
    tempB(tempB~=0)=avgB;
    IAvgB = IAvgB+tempB;
end
SPIAvg(:,:,1) = IAvgR;
SPIAvg(:,:,2) = IAvgG;
SPIAvg(:,:,3) = IAvgB;

end

