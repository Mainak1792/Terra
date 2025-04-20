function [Event_loc, Features] = Event_Extract(Evnt_Prdctd, signal, sigma, prsn)
% EVENT_EXTRACT Extracts footstep events from a continuous signal
%
% This function processes a continuous signal to extract individual footstep
% events using a combination of event detection and windowing techniques.
%
% INPUTS:
%   Evnt_Prdctd - Matrix containing predicted event information [start, stop, label]
%   signal      - Raw continuous signal data
%   sigma       - Window parameter for event extraction
%   prsn        - Person ID for logging purposes
%
% OUTPUTS:
%   Event_loc   - Vector marking the location of detected events
%   Features    - Matrix containing extracted footstep features
%
% Author: [Your Name]
% Date: [Date]

% Initialize parameters
fs = 8000;  % Sampling frequency (Hz)
tm = (0:length(signal)-1)/fs; 
new_sig = zeros(size(signal,1),1);
Event_loc = zeros(size(signal,1),1);

% Find indices of detected events (label = 1)
Detctd_Evnt_idx = find(Evnt_Prdctd(:,3) == 1);
j = 1;
iter = 1;

% Set footstep window length
footfall_len = 1500;
Sig = zeros(1,footfall_len);
k = 1:footfall_len;

% Process each detected event
while j < length(Detctd_Evnt_idx)
    fprintf('\n================= Person %d and Event %d =================\n', prsn, iter)
    
    % Find consecutive event indices
    stp = 0;
    while (Detctd_Evnt_idx(j+1) == Detctd_Evnt_idx(j)+1)
        j = j + 1;
        stp = stp + 1;
        if j == length(Detctd_Evnt_idx)
            break;
        end
    end
    
    % Get event boundaries
    Evnt_Start = Evnt_Prdctd(Detctd_Evnt_idx(j-stp),1);
    Evnt_Stop = Evnt_Prdctd(Detctd_Evnt_idx(j),2);  
    
    % Find maximum amplitude point within event
    [~, mn] = max(abs(signal(Evnt_Start:Evnt_Stop)));
    mn = mn + Evnt_Start;
    
    % Apply Tukey window for smooth extraction
    wndw = tukeywin(footfall_len, 0.5);
    
    % Calculate window boundaries
    strt = mn - 400;
    stop = strt + footfall_len-1;
    
    % Handle edge cases
    if strt < 1
        strt = 1;
        wndw = wndw(1:stop-strt+1);
    end
    
    if stop >= length(signal)
        stop = length(signal);
        wndw = wndw(1:stop-strt+1);
    end
    
    % Apply window and extract signal
    w_diag = diag(wndw);
    sig = (signal(strt:stop));
    Sig(:,1:length(sig)) = w_diag*sig;
    
    % Store event length and features
    evnt_len(iter,:) = sum(Sig ~= 0);  
    Features(iter,:) = Sig;
    Event_loc(mn,:) = 0.5;
    
    % Visualization code (commented out)
    % ... [Previous visualization code remains commented] ...
    
    j = j + 1;
    iter = iter + 1;
end

end

