%% Footstep Dataset Creation Script
% This script creates a dataset of footstep features by combining and processing
% individual footstep recordings from multiple participants.
%
% The script can create datasets with different numbers of concatenated footsteps
% to analyze how the number of steps affects classification performance.
%
% Author: [Your Name]
% Date: [Date]

% Clear workspace and close figures
clc, clear, close all;

% Load preprocessed feature database
load('Wooden_8prsn_feat_db1_denoise.mat');

%% Combine all footstep features
% Initialize feature array
footstep_feat = [];

% Combine features from all participants
for i = 1:size(person_feat, 2)
    footstep_feat = [footstep_feat; person_feat{i}];
end

%% Create labels for each footstep
% Initialize label array
label = [];

% Assign labels based on participant ID
for i = 1:size(person_feat, 2)
    label = [label; i * ones(size(person_feat{i}, 1), 1)];
end

% Append labels to feature matrix
footstep_feat = [footstep_feat, label];

%% Save combined dataset
save('1_footsteps_feat_wood_db1.mat', 'footstep_feat');

%% Create datasets with different numbers of concatenated footsteps
% Define number of footsteps to concatenate
no_of_footstep = [2, 3, 5, 7, 10];

% Process each concatenation size
for x = 1:length(no_of_footstep)
    % Load base dataset
    load('1_footsteps_feat_SF_8prsn_500_10%.mat');
    
    % Initialize new feature array
    new_feat = [];
    m = no_of_footstep(x);
    
    fprintf('\n================= Creating features for %d footsteps =================\n', m);
    
    % Process each participant's data
    for k = 1:8  % Change to size(person_feat,2) for full dataset
        feat = [];
        ind = find(footstep_feat(:, end) == k);
        id = inf;
        j = ind(1);
        i = 1;
        
        % Concatenate consecutive footsteps
        while (id >= m)
            start = j;
            stop = start + m - 1;
            
            % Calculate mean features for the concatenated footsteps
            feat(i,:) = mean(footstep_feat(start:stop,:));
            
            j = stop + 1;
            i = i + 1;
            id = ind(end) - stop;
        end
        
        % Append participant's features
        new_feat = [new_feat; feat];
    end
    
    % Save concatenated dataset
    one_footstep_feat = footstep_feat;
    footstep_feat = [];
    footstep_feat = new_feat;
    no_of_feat = size(footstep_feat, 2) - 1;
    filename = sprintf('%d_footsteps_feat_SF_8prsn_500_10%%.mat', m);
    
    fprintf('------ Saving file %s ------\n', filename);
    save(filename, 'footstep_feat');
end





