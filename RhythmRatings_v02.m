function [eRating] = RhythmRatings_v02(truth,performed,thresh)
%zero pad to make both vectors the same length
if size(truth,1) > performed
    performed = [performed zeros(1,size(truth,2)-size(performed,2))];
else
    truth = [truth zeros(1,size(performed,2)-size(truth,2))];
end

% set a tolerance of samples on either direction (deafult 100ms each way)
sampleTol = thresh;
nZerP = find(performed);
coeffs = zeros(1,3);
for ii = 1:sum(performed)
    tempVec = truth(nZerP(ii)-sampleTol:nZerP(ii)+sampleTol);
    if sum(tempVec) ~= 0
        coeffs(1) = coeffs(1) + 1;
    else
        coeffs(2) = coeffs(2) + 1;
    end
end

nZerT = find(truth);
for ii = 1:sum(truth)
    tempVec = performed(nZerT(ii)-sampleTol:nZerT(ii)+sampleTol);
    if sum(tempVec) == 0
        coeffs(3) = coeffs(3) + 1;
    end
end

eRating = coeffs(1) ./ sum(coeffs);
eRating = eRating(1);

end