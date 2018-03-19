function spikes = loadUnitSpikes(expt,unit_tag)
%
%
%
%

% Created: SRO - 10/4/11

rdef = RigDefs;

[trodeInd unitInd] = readUnitTag(unit_tag);

spikes = loadvar(fullfile(rdef.Dir.Spikes,expt.sort.trode(trodeInd).spikesfile));
spikes = filtspikes(spikes,0,'assigns',unitInd);