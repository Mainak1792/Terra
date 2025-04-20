function [feat] = Events_Features_Extraction(Fs, sig)
% EVENTS_FEATURES_EXTRACTION Extracts time and frequency domain features from footstep signals
%
% This function extracts both time and frequency domain features from footstep
% signal segments. The features are used for footstep pattern classification.
%
% INPUTS:
%   Fs  - Sampling frequency (Hz)
%   sig - Signal segment (vector)
%
% OUTPUT:
%   feat - Feature vector containing:
%          Time domain features:
%          - Standard Deviation
%          - Kurtosis
%          - Root Mean Square (RMS)
%          - 25th Percentile (1st Quartile)
%          Frequency domain features:
%          - Power in frequency bands [40-80 Hz]
%          - Power in frequency bands [80-120 Hz]
%          - Power in frequency bands [120-160 Hz]
%
% Author: [Your Name]
% Date: [Date]

i = 1;

%% Time Domain Features
% Standard deviation - measures signal variability
feat(i) = std(sig);         i = i + 1;

% Kurtosis - measures the "tailedness" of the signal distribution
feat(i) = kurtosis(sig);    i = i + 1;

% Root Mean Square - measures signal energy
feat(i) = rms(sig);         i = i + 1;

% 25th percentile - measures lower quartile of signal distribution
feat(i) = quantile(sig, 0.25); i = i + 1;

% Optional additional features (uncomment to include)
% feat(i) = mean(sig);      i = i + 1;    % Mean
% feat(i) = norm(sig, 2);   i = i + 1;    % L2 norm
% feat(i) = -sum(sig.^2 .* log(sig.^2 + eps)); i = i + 1; % Shannon energy

%% Frequency Domain Features
% Compute FFT with zero-padding for better frequency resolution
L = length(sig);
NFFT = 8 * 2^nextpow2(L);           % Zero-padding for FFT resolution
fft_sig = fft(sig, NFFT) / L;       % FFT computation
fft_sig = 2 * abs(fft_sig(1:NFFT/2+1)); % One-sided magnitude spectrum
f = Fs/2 * linspace(0, 1, NFFT/2+1);    % Frequency vector

% Extract power in selected frequency bands
step = 40;  % Frequency band width (Hz)
for band = 1:3
    start_freq = 40 + (band-1)*step;
    end_freq = start_freq + step;
    
    % Find indices for the frequency band
    band_idx = find(f >= start_freq & f < end_freq);
    
    % Calculate power in the band
    feat(i) = sum(fft_sig(band_idx).^2); i = i + 1;
end

end

