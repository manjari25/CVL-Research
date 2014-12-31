close all;
clear all;
clc;
tic;
%% Variables
cow = 'trainImgs/118_1889.jpg';
I = rgb2gray(im2double(imread(cow))); 
cowHalf = imresize(I,0.5);
cowQuarter = imresize(I,0.25);
stwice = [2,0,0;0,2,0; 0,0,1];
squarter = [0.25,0,0;0,0.25, 0; 0,0,1];
s=2;
scalea = [1,s,s^2,s^3,s^4];
sigma = [scalea,3.*scalea];
logS = sort(sigma);
pixel = [288;280;1];

%% COW.JPG
% LoG filters
[responses] = makeLoGFilters(I, logS);
% [avgScale] = interpolateScale(responses,0);
[scale,index,score]=maximalResponse(responses,logS,1);
% Get feature vector at each pixel for same scale as maximal response of
% LoG
[logR, gR, dx1R, dy1R, dx2R, dy2R]=filterResponses(I,scale,0,0);
features1(:,:,1) = logR;
features1(:,:,2) = gR;
features1(:,:,3) = dx1R;
features1(:,:,4) = dy1R;
features1(:,:,5) = dx2R;
features1(:,:,6) = dy2R;
f1=features1(pixel(2,1),pixel(1,1),:);
score(pixel(2,1),pixel(1,1))
%% COWHALF.JPG
% LoG filters
[responses] = makeLoGFilters(cowHalf, logS);
[scale,index,score]=maximalResponse(responses,logS,1);
% Get feature vector at each pixel for same scale as maximal response of
% LoG
[logR, gR, dx1R, dy1R, dx2R, dy2R]=filterResponses(I,scale,0,0);
features2(:,:,1) = logR;
features2(:,:,2) = gR;
features2(:,:,3) = dx1R;
features2(:,:,4) = dy1R;
features2(:,:,5) = dx2R;
features2(:,:,6) = dy2R;
[npixel]=pixelMap(pixel,0.5);
f2=features2(npixel(2,1),npixel(1,1),:);
score(npixel(2,1),npixel(1,1))
%% COWQUARTER.JPG
% LoG filters
[responses] = makeLoGFilters(cowQuarter,logS);
[scale,index,score]=maximalResponse(responses,logS,1);
% Get feature vector at each pixel for same scale as maximal response of
% LoG
[logR, gR, dx1R, dy1R, dx2R, dy2R]=filterResponses(I,scale,0,0);
features3(:,:,1) = logR;
features3(:,:,2) = gR;
features3(:,:,3) = dx1R;
features3(:,:,4) = dy1R;
features3(:,:,5) = dx2R;
features3(:,:,6) = dy2R;
[npixel]=pixelMap(pixel,0.25);
f3=features3(npixel(2,1),npixel(1,1),:);
score(npixel(2,1),npixel(1,1))
% K-means on the feature vector to get clusters out

% Pseudo inverse of the filterbank

% Convert cluster center to image patch representation

toc;