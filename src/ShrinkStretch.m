function [truth,adjPerformed] = ShrinkStretch(truth,performed)
% find the interbeat intervals for the performed beat
beats = find(performed);
performed = performed(1:beats(end));
interbeats = [];
for ii = 1:length(beats)-1
    interbeats = [interbeats (beats(ii+1) - beats(ii))];
end

% find ratio between end position of truth versus performed
tBeats = find(truth);
pBeats = find(performed);
tru2perf = (tBeats(end) - tBeats(1)) / (pBeats(end) - pBeats(1));

% adjust the interbeat intervals
interbeats = round(interbeats * tru2perf);

% create the adjusted performance vector
adjPerformed = [1];
for ii = 1:length(interbeats)
    adjPerformed = [adjPerformed zeros(1,interbeats(ii)-1) 1];
end

end