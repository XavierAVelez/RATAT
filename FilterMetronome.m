function [metroList] = FilterMetronome(y,Fs, eNum)

bandpassSpecs = fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2,C', ...
    750,1700,1750,1850,1900,Fs);
bandpassSpecs.Stopband1Constrained = true;
bandpassSpecs.Astop1 = 80;
bandpassSpecs.Stopband2Constrained = true;
bandpassSpecs.Astop2 = 80;

bandpassFilt = design(bandpassSpecs, 'Systemobject', true);

%fvtool(bandpassFilt);
y = bandpassFilt(y);
y = abs(y(:,1));

step = 44;
fileList = zeros(floor(size(y,1)/ step), 1);

threshold = median(y(:,1)) * 200;

j = 1;
for i=1:step:size(y,1)-step
    iter = y(i:i+step-1);
    if any(iter >= threshold)
        fileList(j) = 1;
    end
    j = j + 1;
end

fileList = fileList(2:end);
metros = find(fileList);
metroList = zeros(length(fileList), 1);

if (eNum >= 5 && eNum <= 8)
    posF = metros(1);
    posS = posF + round(105840/(4*step));
    while posF <= length(metroList)
        metroList(posF) = 0.5;
        for ii = 1:3
            if posS <= length(metroList)
                metroList(posS) = 0.25;
                posS = posS + round(105840/(4*step));
            end
        end
        posF = posF + round(105840/step);
        posS = posF + round(105840/(4*step));
    end

else
    posF = metros(1);
    posS = posF + round(52440/(2*step));
    while posF <= length(metroList)
        metroList(posF) = 0.5;
        if posS <= length(metroList)
            metroList(posS) = 0.25;
        end
    
        posF = posF + round(52440/step);
        posS = posS + round(52440/step);
    end
end

end