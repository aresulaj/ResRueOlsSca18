function spikes = filtspikesTime(spikes,time_window)
%
%
%
%
%

% Created: SRO - 10/4/11


spikes = makeTempField(spikes,'spiketimes',time_window,'between');
spikes = filtspikes(spikes,0,'temp',1);