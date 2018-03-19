function setXYsameLimit(hax)
%
%
%
%

% Created: SRO - 6/16/11



xlim = get(hax,'XLim');
ylim = get(hax,'YLim');

all = [xlim ylim];
minL = min(all);
maxL = max(all);
lim = [minL maxL];


set(hax,'Xlim',lim,'YLim',lim);