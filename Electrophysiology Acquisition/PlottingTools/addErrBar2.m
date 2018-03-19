function hErr = addErrBar2(x,y,err_p,err_m,errType,hax,hl)
% function hErr = addErrBar2(x,y,err_p,err_m,errType,hax,hl)
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

% Created: SRO - 6/26/12


if nargin < 5 || isempty(errType)
    errType = 'y';
end

if nargin < 6 || isempty(hax)
    hax = gca;
end

if nargin < 7 || isempty(hl)
    hl = [];
end

if strcmp(errType,'x')
    xtmp = x;
    x = y;
    y = xtmp;
end

% Compute +/- error value
yp = err_p;
ym = err_m;

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
