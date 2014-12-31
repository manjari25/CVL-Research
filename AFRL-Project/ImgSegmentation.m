% Clear workspace
clear all;
close all;
clc;

tic;

% Read image, convert to HSV, define other variables
I = double(imread('1.bmp'));
IHSV = rgb2hsv(I);
IHue = IHSV(:,:,1).*360;
IHueR = [];
nr = size(I,1);
nc = size(I,2);
np = nc*nr;

% Compute superpixels size(3x5 window). Arrange as superpixels. Average Hue
snr = nr/3;
snc = nc/5;
snp = snr*snc;



% Rasterize Hue for each superpixel
for i=1:nr
    IHueR = [IHueR;IHue(i,:)'];
end
toc;
tic;
% Compute Hue cue similarity using Euclidiean distance
D = pdist(IHueR,'euclidean');
CHue = squareform(D);
toc;

tic;
% Compute SIFT descriptor for each pixel
[f,d] = vl_sift(single(rgb2gray(I)));
toc;

% Define similarity matrix for SIFT 

% Compute sigma parameter for Hue

% Compute sigma parameter for SIFT

% Model EM with BIC for both cues

% Adjust Similarity matrices and compute weight matrix for Ncut

% Ncut image segmentation

% Stability Value