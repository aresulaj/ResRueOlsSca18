function setAxes(hax,nrow,ncol,ind,params,hfig)
%
%
%
%
%

% Renamed, modified version of setaxesOnaxesmatrix (BA)
%
% function setaxesOnaxesmatrix(hAxes,nrow,ncol,ind,params,fid)
% like axesmatrix, but sets existing hAxes to matrix positions rather than
% creating them
% BA


fld = {'matpos','figmargin','matmargin','cellmargin'};
def_val = {[0 0 1 1],[0.06 0.03 0.025 0],[0 0 0 0],[0.01 0.01 0.04 0.04]};   % [LEFT RIGHT TOP BOTTOM]


if nargin < 4 || isempty(ind)
    ind = 1:prod(size(hax));  
end

if nargin < 5 || isempty(params)
    for i = 1:length(fld)
        params.(fld{i}) = def_val{i};
    end
end

if nargin < 6 || isempty(hfig)
    hfig = gcf;   
end

for i = 1:length(fld)
    if ~isfield(params,fld{i}) || isempty(params.(fld{i}))
        params.(fld{i}) = def_val{i};
    end
end


% Calculate [width height] of each cell in matrix
MATE = [(params.matpos(3)*1-(sum(params.figmargin ([1:2]))+sum(params.matmargin ([1:2]))))/ncol...
    (params.matpos(4)*1-(sum(params.figmargin ([3:4]))+sum(params.matmargin ([3:4]))))/nrow];

for i = 1:length(ind)
    
    % Calculate C and R from index
    R = ceil(ind(i)/ncol);
    C = mod(ind(i),ncol)+ ~mod(ind(i),ncol)*ncol;
    
    if R > nrow || C> ncol
        error('ind exceeds matrix size');
    end
    
    axpos = [(C-1)*MATE(1)+params.matpos(1)+params.cellmargin(1)+params.figmargin(1)+params.matmargin(1)...
        1-(params.figmargin(3)+params.matpos(2)+params.matmargin(3)+(R)*MATE(2)-params.cellmargin(4)) ...
        MATE(1)-params.cellmargin(2) MATE(2)-params.cellmargin(3)];
    
    set(hax(i),'Position',axpos,'Parent',hfig);
end