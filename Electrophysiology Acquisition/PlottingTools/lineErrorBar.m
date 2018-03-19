function [hlData hlErr] = lineErrorBar(xdata,ydata,err,hax,color)
% function lineErrorBar(xdata,ydata,eb)
%
%
%
%

% Created: SRO - 5/16/11


if ~isempty(err)
    eBarM = ydata - err;
    eBarP = ydata + err;
end

hlData = line('XData',xdata,'YData',ydata,'Color',color,'LineWidth',2,'Parent',hax);

if ~isempty(err)
    hlErr(1) = line('XData',xdata,'YData',eBarM,'Color',color,'LineWidth',0.75,'Parent',hax);
    hlErr(2) = line('XData',xdata,'YData',eBarP,'Color',color,'LineWidth',0.75,'Parent',hax);
end