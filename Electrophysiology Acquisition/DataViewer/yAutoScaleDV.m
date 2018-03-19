function yAutoScaleDV(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified:

% Get handles for DataViewer plot objects
temp = getappdata(handles.hDataViewer,'handlesPlot');
hAllAxes = temp(1,:);
hPlotLines = temp(2,:);
hRasters = temp(3,:);
dvplot = getappdata(handles.hDataViewer,'dvplot');
PlotVectorOn = dvplot.pvOn;

% Display data
globalLim = [-0.001 0.001];
for i = PlotVectorOn'  % Must be row vector for this notation to work
    temp = get(hPlotLines(i),'YData');
    if min(temp) == max(temp)
        break
    end
    if 0
        yLim = [min([temp globalLim(1)]) max([temp globalLim(2)])];
    else
        yLim = [min(temp) max(temp)];
    end
    set(hAllAxes(i),'YLim',yLim);
    % Update ticks
    setAxisTicks(hAllAxes(i));
end

% set(hAllAxes,'YLim',yLim);
