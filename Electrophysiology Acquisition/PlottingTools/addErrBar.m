function hErr = addErrBar(x,y,err,errType,hax,hl)
% function hErr = addErrBar(x,y,err,errType,hax,hl)
%
% INPUT
%   x: XData for data line
%   y: YData for data line
%   err: Error bar values
%   errType: Add error bars to either 'x' or 'y' values
%   hax: Handle to parent axes for data line
%   hl: Handle to data line
%
% OUTPUT
%   hErr: Handle to error bar line

% Created: SRO - 5/25/11


if nargin < 4 || isempty(errType)
    errType = 'y';
end

if nargin < 5 || isempty(hax)
    hax = gca;
end

if nargin < 6 || isempty(hl)
    hl = [];
end

if strcmp(errType,'x')
    xtmp = x;
    x = y;
    y = xtmp;
end

% Compute +/- error value
yp = y + err;
ym = y - err;

% Make y values vector
ny = NaN(3*length(yp),1);
ny(1:3:end) = ym;
ny(2:3:end) = yp;

% Make x values vector
nx = NaN(size(ny));
nx(1:3:end) = x;
nx(2:3:end) = x;

% Plot error bars
switch  errType
    case 'y'
        hErr = line('XData',nx,'YData',ny,'Parent',hax);
    case 'x'
        hErr = line('XData',ny,'YData',nx,'Parent',hax);
end

% Format error bars
if ~isempty(hl)
    set(hErr,'Color',get(hl,'Color'));
end
