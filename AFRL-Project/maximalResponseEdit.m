function [ scale, index, score ] = maximalResponseEdit( responses, logS, pixel)
% Given filter responses and scale of filters used, outputs maximal score,
% scale of this score and the index of the filter
    r = pixel(2,1);
    c = pixel(1,1);
%     figure;
%     hold on;
%     for i=1:10
%         plot(logS(1,i),abs(responses(r,c,i)),'--or','LineWidth',2);
%     end
    % Maximal absolute response 
    [score,index]=max(abs(responses),[],3);
    nrr = size(responses,1);
    nrc = size(responses,2);
    for i=1:nrr
        for j=1:nrc
            scale(i,j) = logS(index(i,j));
        end
    end
%     plot(scale(r,c),abs(responses(r,c,index(r,c))),'xb','LineWidth',2);
end