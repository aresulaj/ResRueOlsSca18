function rgb = colors(k)
%
%
%
%
% Put in an index and get a color


c = {[0.1 0.1 0.1],     % Black
    [0 1 0],            % Green
    [0 0 1],            % Blue
    [1 0 1],            % Magenta
    [222/255 125/255 0],            % Magenta
    [0.3 0.3 0.3],      % Gray
    [0.7 0.7 0.7],      % Light gray
    [1 0.25 0.25],      % Red
    [1 0.5 0]};

k = mod(k-1,length(c))+1;


rgb = c{k};