clc, clear all, close all;
%%
load(['P1_P5_STD_KUR_MSE_Q1_person_feat_2.mat'])



footstep_feat = [];
labels=[];

for i = 1:5
    i
    footstep_feat = [footstep_feat ; person_feat{i}];
    labels = [labels; i*ones(size(person_feat{i},1),1)];
    
    
end

footstep_feat = [footstep_feat, labels];

%%

