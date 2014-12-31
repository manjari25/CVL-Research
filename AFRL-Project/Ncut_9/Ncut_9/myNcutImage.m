function [SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W]= NcutImage(I,nbSegments);
 
if nargin <2,
   nbSegments = 10;
end

load('WHue.mat');

W = adjacencyMatrixHue;

[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(W,nbSegments);

%% generate segmentation label map using super pixel image size
nr = size(W,1);
nc=nr;

SegLabel = zeros(nr,nc);
for j=1:size(NcutDiscrete,2),
    SegLabel = SegLabel + j*reshape(NcutDiscrete(:,j),nr,nc);
end