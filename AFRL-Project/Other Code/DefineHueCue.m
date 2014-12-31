function [ output_args ] = DefineHueCue( I, Sp2 )
% Computes hue cue of the superpixel image and save similarity matrix
% Also compute superpixel image averaging(Average Image)

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

% Save to disk
save('WH',adjacencyMatrixHue);

end

