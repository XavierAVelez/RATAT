%% File
%{
Filename: FilterSignal.m
Written By: Xavier Velez
Version: 0.4
Created On: 9/26/2022
%}


function [finalList, rawList] = FilterSignal_v04(y,Fs,threshFactor)
% implements a 500 order bandpass filter with a passband from [700 1000]
% Hz.
bandpassSpecs = fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2,C', ...
    500,600,700,1000,1100,Fs);
bandpassSpecs.Stopband1Constrained = true;
bandpassSpecs.Astop1 = 80;
bandpassSpecs.Stopband2Constrained = true;
bandpassSpecs.Astop2 = 80;

bandpassFilt = design(bandpassSpecs, 'Systemobject', true);

% filters the input audio signal
%fvtool(bandpassFilt);
y = bandpassFilt(y);

% takes the STFT and power spectrum derived from the FFT
% used for debugging and presentation visuals
%{
[s,f,t] = stft(abs(y(:,1)),Fs);
figure(2);
waterfall(t,f,abs(s));
xlabel('Time');
xlim([0 8])
ylabel('Frequency');
ylim([-1e4 1e4]);
zlabel('Short Time Fourier Transform');
zlim([0 0.1]);

% take the FFT of the signal
Y = fft(y);
L = length(Y);

% plot power spectrum of FFT
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

figure(2);
plot(f,P1);
title("Single-Sided Amplitude Spectrum of audio");
xlabel("f (Hz)");
ylabel("|P1(f)|");
%}

% convert the signal into a 1D list of zeros and ones
y = abs(y(:,1));
step = 44;
fileList = zeros(floor(size(y,1)/ step), 1);

% uses scaled median thresholding
% threshFactor comes from the knob in the GUI
threshold = median(y(:,1)) * threshFactor;

j = 1;
for i=1:step:size(y,1)-step
    iter = y(i:i+step-1);
    if any(iter >= threshold)
        fileList(j) = 1;
    end
    j = j + 1;
end

% sets the first one value found as the clap and makes all other ones in
% the clap zero.
finalList = [];
rawList = [];
startWrite = false;
count = 100;
for ii = 2:size(fileList)
    if fileList(ii) == 1 && fileList(ii-1) == 0 && count > 85
        finalList = [finalList 1];
        rawList = [rawList 1];
        startWrite = true;
        count = 0;
    elseif startWrite
        finalList = [finalList 0];
        rawList = [rawList 0];
        count = count + 1;
    else
        rawList = [rawList 0];
    end
end

end

