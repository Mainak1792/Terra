%% Dataset Creation Script
% This script creates a dataset by combining multiple recordings from different
% participants walking on different surfaces (wooden and cement).
%
% Author: [Your Name]
% Date: [Date]

% Clear workspace and close figures
clc, clear all, close all;

% Initialize empty cell array for participant IDs
persons = {};

% Set distance parameter (in meters)
mtr = 1.5;

% Initialize dataset array
dataset_original = [];

% Process each participant's data
for j = 1:length(persons)
    % Initialize temporary data array
    data = [];
    
    % Process each recording session (4 sessions per participant)
    for i = 1:4
        % Construct filename for wooden surface recordings
        filename = sprintf('%s_Wooden_%i.mat', persons{j}, i);
        load(filename);
        
        % Append current recording to temporary data
        tempdata = geo_data;
        data = [data; tempdata];
    end
    
    % Append participant's data to main dataset
    dataset_original = [dataset_original, data];
    
    % Save combined data for cement surface analysis
    geo_data = data;
    dataname = sprintf('%s_Cement', persons{j});
    save(dataname, 'geo_data');
end

% Note: The following section is commented out as it was used for
% processing cement surface data separately
% for j = 1:length(persons)
%    filename = sprintf('D:\Python\WoodenLab\%s_Cement_4o5mtr.mat', persons{j})
%    load(filename)
% end