function data = loadvar(filename)
% function varname = loadvar(filename)
%   Loads variable in stored in filename.mat. Allows assign new variable
%   name to loaded variable.
%
% INPUT
%   filename: .mat file to be loaded
%
% OUTPUT
%   data: Data stored as variable in filename.mat
%
%   Created: 5/15/10 - SRO

try
    s = load(filename);
    if ~isempty(s)
        f = fieldnames(s);
        f = f{1};
        data = s.(f);
    end
catch
    data=[];
end
