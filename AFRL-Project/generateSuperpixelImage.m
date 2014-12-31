% Last Edit: 12/15/14
function [ SPlabel, centroids ] = generateSuperpixelImage( I, NSupPixCoarse, NSupPixFine, NEigenVectors )
%GENERATESUPERPIXELIMAGE Generates superpixel image and returns superpixel 
%image and cluster centroids of the different superpixels

if ~exist('cncut')
    addpath('C:\Users\Manjari\Documents\MATLAB\superpixels64\yu_imncut');
end

% Add paths for pb detectors
addpath('superpixels64/segbench/Detectors/');
addpath('superpixels64/segbench/Filters/');
addpath('superpixels64/segbench/Gradients/');
addpath('superpixels64/segbench/Textons/');
addpath('superpixels64/segbench/Util/');

% Add path for superpixel clusterLocations function
addpath('superpixels64')

% Define size of the input image
N = size(I,1);
M = size(I,2);

% Number of superpixels coarse/fine
N_sp=NSupPixCoarse;%200
N_sp2=NSupPixFine;%1000

% Number of eigenvectors.
N_ev=NEigenVectors;%40

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
% Sp = Coarse superpixel image, Seg = Eigen Vector initial cut image :
% Labels
[Sp,Seg] = imncut_sp(I,par);
fprintf(' took %.2f minutes\n',etime(clock,st)/60);

% I_seg = draws inital cut of n eigen vectors, I_sp = draws coarse
% superpixels
I_sp = segImage(I,Sp);
I_seg = segImage(I,Seg);

figure;
subplot(1,4,1);
imshow(I);
title('Original Image');
subplot(1,4,2);
imshow(I_seg);
title('Nv segments');
subplot(1,4,3);
imshow(I_sp);
title('Coarse Segments');

%Fine scale super pixel computation
st=clock;
fprintf('Fine scale superpixel computation...');
[Sp2, centroids] = clusterLocations(I, Sp,ceil(N*M/N_sp2));
fprintf(' took %.2f minutes\n',etime(clock,st)/60);

%I_sp2 = draws the fine scale superpixels
I_sp2 = segImage(I,Sp2);

%Return the labelled superpixel image, the superpixel image
SPlabel = Sp2;
subplot(1,4,4);
imshow(I_sp2);
title('Fine segments');
end