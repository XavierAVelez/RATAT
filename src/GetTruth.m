%% File
%{
Filename: GetTruth.m
Written By: Xavier Velez
Version: 0.1
Created On: 7/15/2022
Last Updated: 7/17/2022
%}
function truthArray = GetTruth()
    %% Read in Audio
    [y, Fs] = audioread("analyze\Master_Truth.mp3");
    numClaps = [3, 3, 4, 2, 5, 6, 4, 6, 6, 7, 5, 6, 6, 6, 5, 2, 4, 5, 6, 5, 7, 8, 8, 8, 9, 8, 8, 8, 8, 10];

    %% Filter Audio and Extract Beats
    fpass = [600, 900];
    y = bandpass(y, fpass, Fs);

    % run signal through a 2nd order HPF w/ fc = 2100Hz
    fc = 2100;
    filterOrder = 2;

    w0 = 2*fc/Fs;
    [b,a] = butter(filterOrder,w0,'high');
    y = filter(b,a,y);

    % run signal through a 2nd order LPF w/ fc = 2900Hz
    % this is JIC a high frequency sound interrupts a sample file
    fc = 2900;
    filterOrder = 2;

    w0 = 2*fc/Fs;
    [b,a] = butter(filterOrder,w0,'low');
    y = filter(b,a,y);

    % take the fast fourier transform of the filtered signal
    Y = fft(y);

    % amplify the claps by a factor of 500
    threshold = 0.075;
    for i=1:[size(Y),1]
        if abs(real(Y(i,1))) > threshold
            Y(i) = Y(i) .* 500;
        end
    end

    % take the inverse FFT to get the audio signal back
    y = ifft(Y);
    y = abs(y);

    % convert the signal into a 1D list of zeros and ones
    step = 44;
    fileList = zeros(floor(size(y,1)/ step), 1);

    threshold = median(y(:,1)) * 50;
    j = 1;
    for i=1:step:size(y,1)
        iter = y(i:i+step-1);
        if any(iter >= threshold)
            fileList(j) = 1;
        end
        j = j + 1;
    end

    figure(31);
    plot(fileList);

    %% Separate the beats, save to a CSV and return
    truthArray = cell(30,1);
    
    holdPlace = 2;
    for ii = 1:30
        numBeats = numClaps(ii);
        listWrite = [];
        beatCount = 0;
        startWrite = false;
        count = 45;
        for jj = holdPlace+1:1:size(fileList)
            if fileList(jj) == 1 && fileList(jj-1) == 0 && count > 40
                listWrite = [listWrite 1];
                beatCount = beatCount + 1;
                startWrite = true;
                count = 0;
            elseif startWrite
                listWrite = [listWrite 0];
                count  = count + 1;
            end

            if beatCount == numClaps(ii)
                holdPlace = jj + 40;
                break;
            end
        end

        truthArray{ii} = listWrite;
    end

    save matfiles/GetTruth truthArray
end

