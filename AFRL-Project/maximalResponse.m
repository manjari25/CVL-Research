% Last Edit: 12/16/14
function [ scale, score, index ] = maximalResponse( responses, logS, interpolation )
% Given filter responses and scale of filters used, outputs maximal score,
% scale of this score and the index of the filter
% interpolation=0 - no interpolation
% interpolation=1 - interpolate two maximal values to get precise scale
    nrr = size(responses,1);
    nrc = size(responses,2);
    if (interpolation==0)
        [score,index]=max(abs(responses),[],3);
        for i=1:nrr
            for j=1:nrc
                scale(i,j) = logS(index(i,j));
            end
        end
    elseif (interpolation==1)
        % Get Maximum
       [score,index]=max(abs(responses),[],3);
       for i=1:nrr
           for j=1:nrc
               scale(i,j) = logS(index(i,j));
           end
       end
       % Get Second Maximum        
       for i=1:nrr
           for j=1:nrc
            a = abs(responses(i,j,:));
            b = sort(a(:),'descend');
            c = (a>=b(2)).*a;
            c(c==max(c,[],3))=0;
            [score2(i,j), index(i,j)] = max(c,[],3);
           end
       end
       for i=1:nrr
            for j=1:nrc
                scale2(i,j) = logS(index(i,j));
            end
       end
        % Set scale = interpolated scale value        
        avgScale = (scale+scale2)./2;
        scale=avgScale;
    end
end

