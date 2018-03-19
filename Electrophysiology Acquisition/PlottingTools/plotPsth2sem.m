function [hPsth hSem] = plotPsth2sem(n,sem,centers,hAxes,color,bSmooth)
% function [hPsth hSem] = plotPsth2sem(n,sem,centers,hAxes,color,bSmooth)
%
%
%
%
%

% Created: SRO - 6/22/11

if nargin < 4 || isempty(hAxes)
    hAxes = axes;
end

if nargin < 5 || isempty(color)
    color = colors(1);
end

if nargin < 6 || isempty(bSmooth)
    bSmooth = 0;
end

if bSmooth
    hPsth = line('XData',centers(1:end),'YData',smooth(n(1:end),3),...
        'Parent',hAxes,'LineWidth',1.5,'Color',color);
else
    hPsth = line('XData',centers,'YData',n,...
        'Parent',hAxes,'LineWidth',1.5,'Color',color);
    hSem = addErrBar(centers,n,sem,'y',hAxes,hPsth);
end


% Set default axes properties
if sum(n) == 0
    maxN = 0.1;
elseif isempty(n);
    maxN = 0.1;
else
    maxN = max(n);
end
if ~isnan(maxN)
    axis([0 max(centers(1:end)) 0 maxN])
end
set(hAxes,'TickDir','out','FontSize',8)
xlabel(hAxes,'seconds')
ylabel(hAxes,'spikes/s')