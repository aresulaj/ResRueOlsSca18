function p = lum2pixVal(l)
% function p = lum2pixVal(l)
% 
% INPUT
%   l: luminance
%   a: Scaling factor for power law relation
%   b: gamma exponent
%
% OUTPUT
%   p: pixel value
%

% Modified: Shawn R Olsen - 2/26/11

rigSpecific;

try
    p = round(exp(log(l/a)/b));     % a and b
catch
    keyboard
end

if p > 255
    p = 225;
end

if p < 0
    p = 0;
end