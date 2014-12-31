clear all;
close all;
clc;

disp('Ncut Image Segmentation demo');

I = imread_ncut('C:\Users\Manjari\Documents\MATLAB\trainImgs\118_1891.jpg',640,480);

%% Nuct eigen vectors and discrete segmentation
nbSegments = 5;
disp('computing Ncut eigenvectors ...');
tic;
[SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W]= myNcutImage(I,nbSegments);
toc;

%% display the segmentation
figure(1);clf
bw = edge(SegLabel,0.01);
J1=showmask(I,imdilate(bw,ones(2,2))); imagesc(J1);axis off
disp('This is the segmentation, press Enter to continue...');
pause;

%% display Ncut eigenvectors
figure(2);clf;set(gcf,'Position',[100,500,200*(nbSegments+1),200]);
[nr,nc,nb] = size(I);
for i=1:nbSegments
    subplot(1,nbSegments,i);
    imagesc(reshape(NcutEigenvectors(:,i) , nr,nc));axis('image');axis off;
end
disp('This is the Ncut eigenvectors...');
disp('The demo is finished.');

