function rgb = grays(k)
%
%
%
%
% Put in an index and get gray value


c = {[0 0 0],
    [0.2 0.2 0.2],
    [0.4 0.4 0.4],
    [0.6 0.6 0.6],
    [0.7 0.7 0.7],
    [0.8 0.8 0.8],
    [0.9 0.9 0.9],
    };

c = flipud(c);

rgb = c{k};