close all;
clear all;
clc;
tic;
% Variables
cow = 'trainImgs/118_1889.jpg';
I = rgb2gray(im2double(imread(cow)));
cowHalf = imresize(I,0.5);
cowQuarter = imresize(I,0.25);
stwice = [2,0,0;0,2,0; 0,0,1];
squarter = [0.25,0,0;0,0.25, 0; 0,0,1];
% I = imresize(cowQuarter,0.5)

%% COWHALF.JPG
% % LoG filters
% [logS, responses] = makeLoGFilters(cowHalf);
% [scale,index,score]=maximalResponse(responses,logS);
% figure, imshow(cowHalf);
% hold on;
% % Pick top 100 maximal responses and corresponding scales
% [scoreSorted] = topKZone(score,100);
% mask=scoreSorted;
% mask(mask>0)=1;
% scaleSorted = mask.*scale;
% [r,c,v] = find(scaleSorted);
% for i=1:size(r,1)
%     plot(c(i,1),r(i,1),'xy');
%     ellipse(v(i,1),v(i,1),0,c(i,1),r(i,1),'g');
% end
% hold off;
%% COW.JPG
% LoG filters
[ logS, responses] = makeLoGFilters(I);
[scale,index,score]=maximalResponse(responses,logS);
% figure, imshow(I);
% hold on;
% Pick top 100 maximal responses and corresponding scales
% [scoreSorted] = topKZone(score,30);
% mask=scoreSorted;
% mask(mask>0)=1;
% scaleSorted = mask.*scale;
% [r,c,v] = find(scaleSorted);
% for i=1:size(r,1)
%     pixel = [c(i,1);r(i,1);1];
%     npixel=ceil(stwice*pixel);
%     c(i,1)=npixel(1,1);
%     r(i,1)=npixel(2,1);
% end
% for i=1:size(r,1)
%     ellipse(scale(r(i,1),c(i,1)),scale(r(i,1),c(i,1)),0,c(i,1),r(i,1),'g');
%     plot(c(i,1),r(i,1),'xy');
% end
% hold off;
%% COWQUARTER.JPG
% % LoG filters
% [logS, responses] = makeLoGFilters(cowQuarter);
% [scale,index,score]=maximalResponse(responses,logS);
% figure, imshow(cowQuarter);
% hold on;
% % Pick top 100 maximal responses and corresponding scales
% % [scoreSorted] = topKZone(score,20);
% % mask=scoreSorted;
% % mask(mask>0)=1;
% % scaleSorted = mask.*scale;
% % [r,c,v] = find(scaleSorted);
% for i=1:size(r,1)
%     pixel = [c(i,1);r(i,1);1];
%     npixel=ceil(squarter*pixel);
%     c(i,1)=npixel(1,1);
%     r(i,1)=npixel(2,1);
% end
% for i=1:size(r,1)
%     plot(c(i,1),r(i,1),'xy');
%     ellipse(scale(r(i,1),c(i,1)),scale(r(i,1),c(i,1)),0,c(i,1),r(i,1),'g');
% end
% hold off;

% Get feature vector at each pixel for same scale as maximal response of
% LoG
[gR, dx1R, dy1R, dx2R, dy2R]=filterResponses(I,scale);
features(:,:,1) = gR;
features(:,:,2) = dx1R;
features(:,:,3) = dy1R;
features(:,:,4) = dx2R;
features(:,:,5) = dy2R;

% K-means on the feature vector to get clusters out

% Pseudo inverse of the filterbank

% Convert cluster center to image patch representation

toc;