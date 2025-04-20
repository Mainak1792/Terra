function [clust, cov_mat, mu_mat, phi] = GMM_EM(signal_param, clusters)
% GMM_EM Implements Gaussian Mixture Model clustering using Expectation-Maximization
%
% This function performs clustering using a Gaussian Mixture Model (GMM)
% with Expectation-Maximization (EM) algorithm. It's used for footstep
% pattern classification.
%
% INPUTS:
%   signal_param - Matrix of feature vectors (samples x features)
%   clusters     - Number of clusters to identify
%
% OUTPUTS:
%   clust       - Cell array containing indices of samples in each cluster
%   cov_mat     - Covariance matrices for each Gaussian component
%   mu_mat      - Mean vectors for each Gaussian component
%   phi         - Mixing coefficients (prior probabilities) for each component
%
% Author: [Your Name]
% Date: [Date]

%% ---------- Parameter Initialization ------------------
[row, col] = size(signal_param);
num_clusters = clusters;

% Randomly select initial cluster centers
rand_idx = randperm(row, num_clusters);

% Initialize mixing coefficients (equal weights)
phi = (1/num_clusters) * ones(1, num_clusters);

% Initialize mean vectors and covariance matrices
mu_mat = zeros(num_clusters, size(signal_param, 2));
cov_mat = cov(signal_param);

% Set initial means to randomly selected samples
for i = 1:num_clusters
    mu_mat(i,:) = signal_param(rand_idx(i),:);
    cov_mat(:,:,i) = cov(signal_param);
end

%% Optimization through Expectation and Maximization 
iter = 1000;
err = inf;

while err > 1e-12
    %% Expectation Step
    prvs_mu = mu_mat;
    
    % Calculate responsibilities (posterior probabilities)
    for j = 1:length(phi)
        w(:,j) = phi(j) * mvnpdf(signal_param, mu_mat(j,:), cov_mat(:,:,j));
    end   
    
    % Normalize responsibilities
    w = w ./ repmat(sum(w,2), 1, size(w,2));
    w(isnan(w)) = 0;

    %% Maximization Step
    % Update mixing coefficients
    phi = sum(w,1) ./ size(w,1);
    
    % Update mean vectors
    mu_mat = w' * signal_param;
    mu_mat = mu_mat ./ repmat((sum(w,1))', 1, size(mu_mat,2));
    
    % Update covariance matrices
    for j = 1:length(phi)
        vari = repmat(w(:,j), 1, size(signal_param,2)) .* ...
               (signal_param - repmat(mu_mat(j,:), size(signal_param,1), 1));
        cov_mat(:,:,j) = (vari' * vari) / sum(w(:,j),1) + 0.0001 * eye(size(signal_param,2));
    end
    
    % Check convergence
    err = abs(norm(mu_mat,2) - norm(prvs_mu,2));
end

%% Final Cluster Assignment
[c, estimate] = max(w, [], 2);

% Return cluster indices
clust = {find(estimate==1), find(estimate==2)};

end

