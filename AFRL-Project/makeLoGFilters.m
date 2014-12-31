function [ responses ] = makeLoGFilters( I,logS )
% Given Image I, outputs filter response and scales of the filter used
    for i=1:size(logS,2)
        logF = (logS(1,i)^2).*(fspecial('log',193,logS(1,i)));
        responses(:,:,i) = imfilter(I,logF,'replicate');
    end
end

