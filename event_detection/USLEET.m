%% Initialization
clc; close all; clear;


load("C:\Users\chand\Downloads\Data_Recording\P1_all.mat");

%% Sampling Parameters
Fs = 8000;               % Sampling frequency (Hz)
n = 100 * Fs;            % 100 seconds of data
geo_data = smooth(geo_data(1:n), 5);  % Apply smoothing filter
tm = (0:length(geo_data)-1)/Fs;       % Time vector

%% Plot the Preprocessed Signal
figure;
plot(tm, geo_data)
grid on;
xlabel('Time (sec)');
ylabel('Amplitude (V)');
title('Preprocessed Vibration Signal');

%% Event Segmentation Parameters
tau = 1.2;                    % Gaussian window parameter
window = 0.35;                % Window size in seconds (e.g., 350ms)
wndw_ovrlap = 0.40;           % Overlap fraction
wndw_smpl = window * Fs;      % Window size in samples

num_seg = floor(1 + (length(geo_data) - wndw_smpl) / ...
                (floor((1 - wndw_ovrlap) * wndw_smpl)));

%% Extract Features for Each Event Segment
figure;
for i = 1:num_seg
    start = floor(wndw_smpl * (i - 1) * (1 - wndw_ovrlap)) + 1;
    stop = floor(start + wndw_smpl - 1);
    if stop >= length(geo_data), stop = length(geo_data); end
    
    % Apply Gaussian window
    wght_wndw = length(start:stop);
    weight = gausswin(wght_wndw, tau);
    w_diag = diag(weight);
    sig = w_diag * geo_data(start:stop);
    
    % Extract features
    signal_feat(i,:) = Events_Features_Extraction(Fs, sig);
end

signal_param = signal_feat;

%% Clustering using GMM-EM
Cluster_num = 2;
[clust, cov_mat, mu_mat, phi] = GMM_EM(signal_param, Cluster_num);

% t-SNE for visualization (optional)
Y = tsne(signal_param, 'Algorithm', 'exact', ...
         'Standardize', 0, 'Distance', 'cosine');

%% Visualize Clusters
c1_idx = clust{1};
c2_idx = clust{2};

figure;
plot(signal_param(c1_idx,1), signal_param(c1_idx,2), 'ko', 
     'MarkerFaceColor', 'y', 'MarkerSize', 7);
hold on;
plot(signal_param(c2_idx,1), signal_param(c2_idx,2), 'ko', 
     'MarkerFaceColor', 'g', 'MarkerSize', 7);
legend('Cluster 1', 'Cluster 2');
grid on;
xlabel('x_1');
ylabel('x_2');
title('GMM Clustering Results');
hold off;

fprintf('Press Enter To Continue\n');
pause();

%% Train Binary Classifier using SVM
train_data = [signal_feat(c1_idx,:); signal_feat(c2_idx,:)];
if det(cov_mat(:,:,1)) > det(cov_mat(:,:,2))
    train_label = [ones(length(c1_idx),1); zeros(length(c2_idx),1)];
    lbl_clst1 = 1;
    lbl_clst2 = 0;
else
    train_label = [zeros(length(c1_idx),1); ones(length(c2_idx),1)];
    lbl_clst1 = 0;
    lbl_clst2 = 1;
end

%% Load and Process Blind Data for Inference
% List of participant IDs
persons = {'P1','P2','P3','P4','P5','P6','P7','P8','P9','P10', 
           'P11','P12','P13','P14','P15','P16','P17','P18','P19','P20', 
           'P21','P22','P23','P24','P25','P26','P27','P28','P29','P30', 
           'P31','P32','P33','P34','P35','P36','P37','P38','P39','P40', 
           'P41','P42','P43','P44','P45','P46','P47','P48','P49','P50', 
           'P51','P52','P53','P54','P55','P56','P57','P58','P59','P60', 
           'P61','P62','P63','P64','P65','P66','P67','P68','P69','P70', 
           'P71','P72','P73','P74','P75','P76','P77','P78','P79','P80', 
           'P81','P82','P83','P84','P85','P86','P87','P88','P89','P90', 
           'P91','P92','P93','P94','P95','P96','P97','P98','P99','P100'};

% Process data for each participant
for k = 1:5  % Change to `1:length(persons)` for full test
    fprintf('Extracting features from %s\n', persons{k});
    
    load(sprintf('%s_all.mat', persons{k}));
    geo_data = smooth(geo_data, 5);
    
    tm = (0:length(geo_data)-1)/Fs;
    wndw_smpl = window * Fs;
    num_seg = floor(1 + (length(geo_data) - wndw_smpl) / ...
                    (floor((1 - wndw_ovrlap) * wndw_smpl)));
    
    i = 1;
    iter = 1;
    
    clear Evnt_Ind prdct_clst prob_clust
    
    while iter < length(geo_data)
        start = floor(wndw_smpl * (i - 1) * (1 - wndw_ovrlap)) + 1;
        stop = floor(start + wndw_smpl - 1);
        if stop >= length(geo_data), stop = length(geo_data); end
        
        % Apply Gaussian window
        gaussian_wndw = length(geo_data(start:stop));
        weight = gausswin(gaussian_wndw, tau);
        w_diag = diag(weight);
        sig = w_diag * geo_data(start:stop);
        
        Evnt_Ind(i,:) = [start, stop];
        
        test_data = Events_Features_Extraction(Fs, sig);
        
        % Compute GMM posterior probabilities
        prob_clust(i,1) = mvnpdf(test_data, mu_mat(1,:), cov_mat(:,:,1)) * phi(1);
        prob_clust(i,2) = mvnpdf(test_data, mu_mat(2,:), cov_mat(:,:,2)) * phi(2);
        
        i = i + 1;
        iter = stop;
    end
    
    % Normalize probabilities and assign cluster labels
    prob_clust = prob_clust ./ sum(prob_clust, 2);
    [c, clust_assign] = max(prob_clust, [], 2);
    
    % Threshold low-confidence predictions
    id = find(c < 0.90);
    prdct_clst = zeros(size(clust_assign));
    prdct_clst(clust_assign == 1) = lbl_clst1;
    prdct_clst(clust_assign == 2) = lbl_clst2;
    prdct_clst(id) = 0;
    
    Evnt_Ind = [Evnt_Ind, prdct_clst];
    
    % Final Event Extraction
    Sigma = 4.0;
    [Evnts_loc, footstep_feat] = Event_Extract(Evnt_Ind, geo_data, Sigma, k);
    
    person_feat{k} = footstep_feat;
end
