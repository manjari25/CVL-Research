% MyNcut
% sp_demo.m
%
% See instructions in README.
% Clear workspace
clear all;
close all;
clc;

% Add path for imncut routines
if ~exist('cncut')
    addpath('C:\Users\Manjari\Documents\MATLAB\superpixels64\yu_imncut');
end

% Add paths for pb detectors
addpath('segbench/Detectors/');
addpath('segbench/Filters/');
addpath('segbench/Gradients/');
addpath('segbench/Textons/');
addpath('segbench/Util/');

% Directory to save superpixel adjacncy matrix
saveDir = 'SegmentationBenchmark/spixelData/';
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

% Read
I = im2double(imread('C:\Users\Manjari\Documents\MATLAB\trainImgs\10_9_s.bmp'));

N = size(I,1);
M = size(I,2);

% Number of superpixels coarse/fine.
N_sp=200;%200
N_sp2=1000;%1000
% Number of eigenvectors.
N_ev=40;%40


% ncut parameters for superpixel computation
diag_length = sqrt(N*N + M*M);
par = imncut_sp;
par.int=0;
% sigma for computing affinity from intervening contour
par.pb_ic=1;
par.sig_pb_ic=0.05;
par.sig_p=ceil(diag_length/50);
par.verbose=0;
% neighbour hood radius
par.nb_r=ceil(diag_length/60);
% offset for regularization
par.rep = -0.005;  % stability?  or proximity?
par.sample_rate=0.2;
% number of eigenvectors
par.nv = N_ev;
% Number of superpixels coarse
par.sp = N_sp;

% Intervening contour using mfm-pb
fprintf('running PB\n');
[emag,ephase] = pbWrapper(I,par.pb_timing);
emag = pbThicken(emag);
par.pb_emag = emag;
par.pb_ephase = ephase;
clear emag ephase;

st=clock;
fprintf('Ncutting...');
[Sp,Seg] = imncut_sp(I,par);
fprintf(' took %.2f minutes\n',etime(clock,st)/60);

I_sp = segImage(I,Sp);
I_seg = segImage(I,Seg);
figure;
subplot(1,4,1);
imshow(I);
subplot(1,4,2);
imshow(I_seg);
subplot(1,4,3);
imshow(I_sp);

st=clock;
fprintf('Fine scale superpixel computation...');
Sp2 = clusterLocations(Sp,ceil(N*M/N_sp2));
fprintf(' took %.2f minutes\n',etime(clock,st)/60);


I_sp2 = segImage(I,Sp2);      

subplot(1,4,4);
imshow(I_sp2);
figure, imshow(I_sp2);
% Superpixel Image averaging(Average Image)

Ihsv = rgb2hsv(I);
figure, imshow(I);
Ihue = Ihsv(:,:,1);
Isat = Ihsv(:,:,2);
Ival = Ihsv(:,:,3);    
IHueR = [];

IAvghue = zeros(N,M);
IAvgsat = zeros(N,M);
IAvgval = zeros(N,M);

superpixelLabel = Sp2;
nlabels = max(max(superpixelLabel));
for i = 1:nlabels
    mask=superpixelLabel;
    mask(mask~=i)=0;
    temp = (Ihue & mask).*Ihue;
    avgH = sum(sum(temp))/nnz(temp);
    IHueR = [IHueR;avgH];
    temphue=temp;
    temphue(temphue~=0)=avgH;
    IAvghue = IAvghue+temphue;
    
    
    temp = (Isat & mask).*Isat;
    avgS = sum(sum(temp))/nnz(temp);
    tempsat=temp;
    tempsat(tempsat~=0)=avgS;
    IAvgsat = IAvgsat+tempsat;
    
    temp = (Ival & mask).*Ival;
    avgV = sum(sum(temp))/nnz(temp);
    tempval=temp;
    tempval(tempval~=0)=avgV;
    IAvgval = IAvgval+tempval;       
end
Ihsv(:,:,1) = IAvghue;
Ihsv(:,:,2) = IAvgsat;
Ihsv(:,:,3) = IAvgval;

figure, imshow(hsv2rgb(Ihsv));

% Superpixel Adjacency matrix
D = pdist(IHueR);
adjacencyMatrixHue = squareform(D);

save('WH',adjacencyMatrixHue);

   



