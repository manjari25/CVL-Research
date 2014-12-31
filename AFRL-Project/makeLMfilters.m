function F=makeLMfilters
% Returns the LML filter bank of size 49x49x48 in F. To convolve an
% image I with the filter bank you can either use the matlab function
% conv2, i.e. responses(:,:,i)=conv2(I,F(:,:,i),'valid'), or use the
% Fourier transform.

  SUP=49;                 % Support of the largest filter (must be odd)
  SCALEX=sqrt(2).^[1:3];  % Sigma_{x} for the oriented filters
  NORIENT=6;              % Number of orientations

%   8 LoG and 4 gaussians
  NROTINV=12;
%  18 Gaussian Derivative(First)
  NBAR=length(SCALEX)*NORIENT;
%  18 Gaussian Derivative(Second)
  NEDGE=length(SCALEX)*NORIENT;
%   Total filters
%   NF=NBAR+NEDGE+NROTINV;
  NF=NROTINV;
%   Define F as zeros to begin with
  F=zeros(SUP,SUP,NF);
  hsup=(SUP-1)/2;
  [x,y]=meshgrid([-hsup:hsup],[hsup:-1:-hsup]);
  orgpts=[x(:) y(:)]';

% %   Gaussian first and second derivative filters
%   count=1;
%   for orient=0:NORIENT-1,
%       orient
%     for scale=1:length(SCALEX),
%       SCALEX(scale)
%       angle=pi*orient/NORIENT;  % Not 2pi as filters have symmetry
%       c=cos(angle);s=sin(angle);
%       rotpts=[c -s;s c]*orgpts;
%       F(:,:,count)=makefilter(SCALEX(scale),0,1,rotpts,SUP);
%       F(:,:,count+NEDGE)=makefilter(SCALEX(scale),0,2,rotpts,SUP);
%       count=count+1;
%       
%     end;
%   end;
%  
 %   8 LoG and 4 gaussians
%   count=NBAR+NEDGE+1;
count=1;
  SCALES=sqrt(2).^[1:4];
  for i=1:length(SCALES),
    SCALES(i)
    F(:,:,count)=normalise(fspecial('gaussian',SUP,SCALES(i)));
    F(:,:,count+1)=normalise(fspecial('log',SUP,SCALES(i)));
    F(:,:,count+2)=normalise(fspecial('log',SUP,3*SCALES(i)));
    count=count+3;
  end;
return