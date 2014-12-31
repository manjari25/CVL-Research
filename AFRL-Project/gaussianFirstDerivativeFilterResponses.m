function [gaussianFirstDerivativeResponses] = gaussianFirstDerivativeFilterResponses(I, correctScale)
% Responses of first derivative directional gaussians
gaussianFirstDerivativeResponses = zeros(size(I,1),size(I,2),4);
    for i=1:size(I,1)
        for j=1:size(I,2)
        [Gx,Gy] = gaussFirstDerivativeBasis( correctScale(i,j), 2*ceil(3*correctScale(i,j))+1, ceil(3*correctScale(i,j)));
        % Define directional gaussian derivatives
        DD1 = cosd(0).*Gx+sind(0).*Gy;
        DD2 = cosd(45).*Gx+sind(45).*Gy;
        DD3 = cosd(90).*Gx+sind(90).*Gy;
        DD4 = cosd(135).*Gx+sind(135).*Gy;
        % Responses
        response = imfilter(I,DD1,'replicate');
        gaussianFirstDerivativeResponses(i,j,1) = response(i,j);
        response = imfilter(I,DD2,'replicate');
        gaussianFirstDerivativeResponses(i,j,2) = response(i,j);
        response = imfilter(I,DD3,'replicate');
        gaussianFirstDerivativeResponses(i,j,3) = response(i,j);
        response = imfilter(I,DD4,'replicate');
        gaussianFirstDerivativeResponses(i,j,4) = response(i,j);
        end
    end
end

