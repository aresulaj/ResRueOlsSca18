function varargout = plotCategories(data,xTickLabel,errorbars,yLabel,hAxes,varargin)
% function varargout = plotCategories(data,xTickLabel,errorbars,yLabel,hAxes)
%
% INPUT
%   data: Vector of data points
%   xTickLabel: A cell array where xLabel{n} is the string label for the nth point.
%   errorbars: single value for +/- error bar
%   yLabel: Label for y-axis
%   hAxes: Handle to axes
%
% OUTPUT
%   varargout{1} = hLine;
%   varargout{2} = hAxes;
% 

% Created: 5/16/10 - SRO

if ~isempty(varargin)
    suppressYscaling = varargin{1};
else
    suppressYscaling = 1;
end

if nargin < 3
    yLabel = '';
    hAxes = axes;
    errorbars = zeros(length(data));
elseif nargin < 4
    yLabel = '';
    hAxes = axes;
elseif nargin < 5
    hAxes = axes;
end

if isempty(hAxes)
    hAxes = axes;
end

eb = errorbars;

if isempty(eb)
    eb = zeros(size(data));
end

% axesGray(hAxes);
defaultAxes(hAxes);

xticks = 1:length(data);

% Plot line
hLine = line('Parent',hAxes,'XData',xticks,'YData',data);

% Plot error bars
for i = 1:length(data)
   xtemp =  [xticks(i) xticks(i)];
    ytemp = [data(i)-eb(i) data(i)+eb(i)];
    tempLine(i) = line('Parent',hAxes,'XData',xtemp,'YData',ytemp);
end


% Set properties
set(hLine,'Marker','.','LineWidth',1.5,'Color',[0.1 0.1 0.1]);
set(tempLine,'Marker','none','LineWidth',1.25,'Color',[0.1 0.1 0.1]);

% Set x-axis ticks
maxval = max(data);
if isnan(maxval) || (maxval == 0)
    maxval = 1;
end
set(hAxes,'XTickLabel',xTickLabel,'XTick',xticks,...
    'XLim',[min(xticks)-0.5 max(xticks)+0.5]);

if ~suppressYscaling
    set(hAxes,'YLim',[0 maxval*1.2]);
end

% Set y-axis label
set(get(hAxes,'YLabel'),'String',yLabel);


% Output
hErr = tempLine;
varargout{1} = hLine;
varargout{2} = hErr;
varargout{3} = hAxes;


