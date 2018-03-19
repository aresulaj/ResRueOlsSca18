function [hl hfit herr hax] = plotCrf(c,r,cfit,errBar,hax,color)
% function [hl hfit herr hax] = plotCrf(c,r,cfit,errBar,hax,color)
%
% INPUT
%   c:
%   r:
%   cfit:
%   errBar:
%   hax:
%   color: 
%
% OUTPUT
%   hl: Handle to contrast response data line

% Created: SRO - 6/16/11



if nargin < 3 || isempty(cfit)
    cfit = 0;
end

if nargin < 4 || isempty(errBar)
    errBar = [];
end

if nargin < 5 || isempty(hax)
    hax = axes;
end

if nargin < 6 || isempty(color)
    color = [0 0 0];
end

% Plot data
hl = line('Parent',hax,'XData',c,'YData',r,'Marker','o','MarkerFaceColor',color,...
    'Color',color);

% Add fit
if isnumeric(cfit)
    if cfit
        % Compute fit 
        cfit = [];
    end
end

if strcmp(class(cfit),'cfit')
    % Plot supplied fit
    if max(c) <= 1
    xfit = linspace(min(c),1,25)';
    else
        xfit = linspace(min(c)*0.9,max(c)*1.1,50);
    end
    yfit = feval(cfit,xfit);
    hfit = line('Parent',hax,'XData',xfit,'YData',yfit,'Color',color); 
    set(hl,'LineStyle','none');
end
    

% Add error bars
if ~isempty(errBar)
    herr = addErrBar(c,r,errBar,'y',hax);
else
    herr = [];
end

% Format axis and add labels
xlabel('contrast');
ylabel('spikes/s');
defaultAxes(hax);




