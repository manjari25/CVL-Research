% using EM-BIC to determine the number of Gaussian components
% INPUT: input data matrix X (NxD)
% N: number of data points
% D: dimensionality of the data
% OUTPUT: cell array gmm (Mx3)
% M: number of optimal Gaussian components
% columns are: prior, mean and Sigma (cov matrix)

clear all;
clc
close all

% ====== USER define ========
load Gaussian_4C_3D % load data
figure; plot(X(:,1),X(:,2),'*')
K = [2,3,4,5,8,10]; % Number of Gaussian components you want to test
R = 5; % NUmber of repetition to run
% ================================

BIC = zeros(R,length(K));
obj = cell(R,length(K));

% ==== MAIN PROGRAM =============
figure; 
BIC_best = 1e+9;
for rep = 1:R % number of rep
    cnt_k = 1;
    for k = K % Sweep the number of Gaussian component
        options = statset('MaxIter' ,500); % max iteration = 500
        obj{rep,cnt_k} = gmdistribution.fit(X,k,'Regularize',1e-4,'Options',options);
        BIC(rep,cnt_k)= obj{rep,cnt_k}.BIC;
        % pick the best model
        if BIC(rep,cnt_k) < BIC_best
            rep_best = rep;
            cnt_k_best = cnt_k;
            BIC_best = BIC(rep,cnt_k);
        end
        cnt_k = cnt_k + 1;
    end
    plot(log(BIC(rep,:)),'b'); hold on;
end

% ============= plotting ==============
% plot error bar
BIC_mean = mean(BIC,1);
BIC_std = std(BIC,1);
BIC_min = min(BIC,[],1);
BIC_max = max(BIC,[],1);
figure; hold on;
% errorbar([1:K],BIC_mean,BIC_std);
plot(BIC_mean,'b*-','LineWidth',2);
plot(BIC_min,'r*-','LineWidth',2);
plot(BIC_max,'k*-','LineWidth',2);
set(gca, 'XTick', [1:length(K)],'XTickLabel',K);
legend('mean','min','max');
xlabel('number of components');
ylabel('BIC');
title('BIC+EMGMM');
% print('-depsc','-r200',['BIC_EM_GMM.eps']);

% ============= convert the best GMM obj into cell ============
NComponents = obj{rep_best,cnt_k_best}.NComponents;
gmm = cell(NComponents, 3);
for n = 1:NComponents
    gmm{n,1} = obj{rep_best,cnt_k_best}.PComponents(n); % prior
    gmm{n,2} = obj{rep_best,cnt_k_best}.mu(n,:); % mean
    gmm{n,3} = obj{rep_best,cnt_k_best}.Sigma(:,:,n); % Sigma
end

save GMM_out gmm
