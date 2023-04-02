function [tRating, truth] = TimingRatings(truth,perf,metro,eNum,thresh)
% find the first clap in perf
claps = find(perf);
firstClap = claps(1);

% find the closest main metro tick to the first clap
ticks = find(metro);
diff = 300;
for ii = 1:length(ticks)
    if abs(firstClap - ticks(ii)) < diff
        closest = ticks(ii);
        diff = abs(firstClap - ticks(ii));
    end
end

% align truth with that metro tick
tClaps = find(truth);
numZeros = tClaps(1) - 1;
truth = [zeros(1,closest-numZeros-1) truth];

% adjust truth start for syncopation in exercises 16, 17, 28, and 29
step = 44;
if eNum == 16 || eNum == 17 || eNum == 28 || eNum == 29
    if metro(closest) == 0.5
        truth = [zeros(1, round(52440/(4*step))) truth];
    elseif metro(closest) == 0.25
        truth = truth(round(52440/(4*step)):end);
    end
end

% plot of the performed claps, truth claps, and metronome (for debugging)
%{
figure(1);
plot(perf);
hold on;
plot(truth);
hold on;
plot(metro);
hold off;
%}

% find distance matrix between truth and metro
tClaps = find(truth);
mTicks = find(metro);
tMat = mTicks - tClaps;

% find distance matrix between perf and metro
pClaps = find(perf);
pMat = mTicks - pClaps;

% make tMat and pMat the same size
sizeDiff = size(tMat,2) - size(pMat,2);
if sizeDiff > 0
    pMat = [pMat zeros(size(pMat,1), sizeDiff)];
elseif sizeDiff < 0
    tMat = [tMat zeros(size(tMat,1), abs(sizeDiff))];
end

% perform a standard similarity test and normalize to a score of 0-1
diffMat = abs(tMat-pMat);
diffVec = diffMat(1,:);
tRating = sum(diffVec(:) <= thresh) / length(diffVec);

end