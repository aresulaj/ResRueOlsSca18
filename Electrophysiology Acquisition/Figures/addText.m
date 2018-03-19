function hAnn = addText(str,position,hFig)
%
% INPUT
%   str: text string
%   position: position in normalized units
%   hFig: handle to figure
% OUTPUT
%   hAnn: handle to annotation object

% Created: 10/20/10 - SRO


if nargin < 2
    position = [0.895 0.007 0.1 0.022];
end

if nargin < 3
    hFig = gcf;
end

hAnn = annotation(hFig,'textbox',position,'String',str,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0 0 0],'FontSize',8,'FitBoxToText','on');