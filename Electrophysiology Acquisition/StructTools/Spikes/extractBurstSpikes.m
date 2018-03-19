function [bSpikes tSpikes] = extractBurstSpikes(spikes)
%
%
%
%
%

% Created: SRO - 10/14/11


stimes = spikes.unwrapped_times;

% Preceded by ISI >= 100 ms
tmp = [0 diff(stimes)];
sPre = tmp > 0.1;

% Followed by ISI <= 4 ms
tmp = diff(stimes);
sPost = [tmp 0];
sPost = sPost <= 0.004 & sPost > 0;

% Find first spike in burst
fSpike = sPre & sPost;
fSpikeInd = find(fSpike);

% Find all burst spikes
bSpike = [];
for i = 1:length(fSpikeInd)
    bSpike(end+1:end+2) = [fSpikeInd(i) fSpikeInd(i)+1];
    bInd = 1;
    go = 1;
    while go && (fSpikeInd(i)+bInd) < length(sPost)
        
        if sPost(fSpikeInd(i)+bInd)
            bSpike(end+1) = fSpikeInd(i)+bInd;
            bInd = bInd+1;
        else
            go = 0;
        end
    end
end

% Find fields that have same length as spiketimes
reqLength = length(spikes.spiketimes);
fieldList = fieldnames(spikes);

% Extract spikes with burst index from spike
bSortvector = zeros(1,reqLength);
bSortvector(bSpike) = 1;
bSortvector = logical(bSortvector);
tSortvector = ~bSortvector;

% Fix case where reqLength == 1
if reqLength == 1
    rmFields = {'params','info','sweeps','labels'};
    for i = 1:length(rmFields)
        fieldList(strcmp(rmFields{i},fieldList)) = '';
    end
end

% Use logical vector to extract spikestimes, trials, etc.
for i = 1:length(fieldList)
    if ismember(reqLength,size(spikes.(fieldList{i})));
        switch fieldList{i}
            case 'waveforms'
                bSpikes.(fieldList{i}) = spikes.(fieldList{i})(bSortvector,:,:);
                tSpikes.(fieldList{i}) = spikes.(fieldList{i})(tSortvector,:,:);
            otherwise
                bSpikes.(fieldList{i}) = spikes.(fieldList{i})(bSortvector);      % Using dynamic field names
                tSpikes.(fieldList{i}) = spikes.(fieldList{i})(tSortvector);      % Using dynamic field names
        end
    end
end