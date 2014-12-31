close all;
clear all;
clc;
tic;
% Variables
cow = 'trainImgs/checkerIm.bmp';
I = im2double(imread(cow));
cowTwice = imresize(I,2);
cowHalf = imresize(I,0.5);
cowQuarter = imresize(I,0.25);
shalf = [0.5,0,0;0,0.5, 0; 0,0,1];
squarter = [0.25,0,0;0,0.25, 0; 0,0,1];
s=2;
scalea = [1,s,s^2,s^3,s^4];
sigma = [scalea,3.*scalea];
logS = sort(sigma);
pixel = [5;5;1];
%% COW.JPG
% LoG filters
[responses] = makeLoGFilters(I,logS);
[scale,index,score]=maximalResponseEdit(responses,logS, pixel);
[gr,g1xr,g1yr,g2xr,g2yr]=featureConstruction(I,pixel,scale(pixel(2,1),pixel(1,1)));
feature = abs([scale(pixel(2,1),pixel(1,1)),score(pixel(2,1),pixel(1,1)),gr,g1xr,g1yr,g2xr,g2yr])
figure, imshow(I);
hold on;
    plot(pixel(2,1),pixel(1,1),'kx','LineWidth',2);
    ellipse(scale(pixel(2,1),pixel(1,1)),scale(pixel(2,1),pixel(1,1)),0,pixel(2,1),pixel(1,1),'g');
    ellipse(scale(pixel(2,1),pixel(1,1)),scale(pixel(2,1),pixel(1,1)),0,pixel(2,1),pixel(1,1),'g');
hold off;
%% COWHALF.JPG
% LoG filters
npixel = shalf*pixel;
npixel = ceil(npixel);
[responses] = makeLoGFilters(cowHalf,logS);
[scale,index,score]=maximalResponseEdit(responses,logS, npixel);
[gr,g1xr,g1yr,g2xr,g2yr]=featureConstruction(cowHalf,npixel,scale(npixel(2,1),npixel(1,1)));
feature = abs([scale(npixel(2,1),npixel(1,1)),score(npixel(2,1),npixel(1,1)),gr,g1xr,g1yr,g2xr,g2yr])
figure, imshow(cowHalf);
hold on;
    plot(npixel(2,1),npixel(1,1),'kx','LineWidth',2);
    ellipse(scale(npixel(2,1),npixel(1,1)),scale(npixel(2,1),npixel(1,1)),0,npixel(2,1),npixel(1,1),'g');
    ellipse(scale(npixel(2,1),npixel(1,1)),scale(npixel(2,1),npixel(1,1)),0,npixel(2,1),npixel(1,1),'g');
hold off;
%% COWQUARTER.JPG
% LoG filters
npixel = squarter*pixel;
npixel = ceil(npixel);
[responses] = makeLoGFilters(cowQuarter,logS);
[scale,index,score]=maximalResponseEdit(responses,logS, npixel);
[gr,g1xr,g1yr,g2xr,g2yr]=featureConstruction(cowQuarter,npixel,scale(npixel(2,1),npixel(1,1)));
feature = abs([scale(npixel(2,1),npixel(1,1)),score(npixel(2,1),npixel(1,1)),gr,g1xr,g1yr,g2xr,g2yr])
figure, imshow(cowQuarter);
hold on;
    plot(npixel(2,1),npixel(1,1),'kx','LineWidth',2);
    ellipse(scale(npixel(2,1),npixel(1,1)),scale(npixel(2,1),npixel(1,1)),0,npixel(2,1),npixel(1,1),'g');
    ellipse(scale(npixel(2,1),npixel(1,1)),scale(npixel(2,1),npixel(1,1)),0,npixel(2,1),npixel(1,1),'g');
hold off;
toc;