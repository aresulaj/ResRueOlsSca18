function plotWaveformParameters(ua)
%
%
%
%

% Created: SRO - 5/26/11

% Extract spike parameters
tpratio = [];
tp_time = [];
width = [];
all_avgwaves = [];
for i = 1:length(ua)
    tpratio = [tpratio; ua(i).waveform.troughpeakratio];
    tp_time = [tp_time; ua(i).waveform.tp_time];
    width = [width; ua(i).waveform.width];
    all_avgwaves = [all_avgwaves ua(i).waveform.avgwave];
end

% Plot data
hfig = portraitFigSetup; addSaveFigTool(hfig);
ax(1) = axes('Parent',hfig,'Position',[0.12 0.65 0.35 0.2]);
xlabel('trough-peak time (ms)'); ylabel('trough-peak ratio');
l(1) = line('XData',tp_time,'YData',tpratio,'LineStyle','none','Marker','o');
ax(2) = axes('Parent',hfig,'Position',[0.54 0.65 0.35 0.2]);
xlabel('width (ms)'); ylabel('trough-peak ratio');
l(2) = line('XData',width,'YData',tpratio,'LineStyle','none','Marker','o');

% Histograms
ax(3) = axes('Parent',hfig,'Position',[0.54 0.33 0.35 0.2]);
hist(ax(3),width,20); box off
ax(4) = axes('Parent',hfig,'Position',[0.12 0.33 0.35 0.2]);
hist(ax(4),tp_time,20); box off

defaultAxes(ax);



