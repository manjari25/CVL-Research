%%%%% Compute and save SIFT Descriptors of the train images
% SIFT descriptor of images
SIFTDesc = [];
% Read train image
trainImgs = dir('trainImgs/*.jpg');
for i=1:size(trainImgs,1)
    I = imread(strcat('trainImgs/',trainImgs(i).name));
    image(I);
    % Compute SIFT descriptors
    I = single(rgb2gray(I));
   fc = [100;100;10;0] ;
[f,d] = vl_sift(I,'frames',fc,'orientations') ;
    % Vizualize SIFT descriptors
    h1 = vl_plotframe(f) ;
    h2 = vl_plotframe(f(:,sel)) ;
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','y','linewidth',2) ;
    % Overlay SIFT decriptors
%     h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
%     set(h3,'color','g') ;
      % Save features to array
      SIFTDesc = [SIFTDesc,d];    
end
% Save features to file
save('SIFTDescriptors','SIFTDesc');