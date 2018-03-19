function trk = makeObjCodeMat(trk,fld)
%
%
%
%

% Created: SRO - 6/17/12


if nargin < 2 || isempty(fld)
    fld = {'object_type','object_contrast','object_angle'};
end

% Determine whether field exists and is not empty
fld = fld(end:-1:1);
tmp = isfield(trk,fld);
fld = fld(tmp);
clear tmp

for i = 1:length(fld)
    if ~iscell(trk.(fld{i}))
        trk.(fld{i}) = {trk.(fld{i})};
    end
    if isempty(trk.(fld{i}){1})
        tmp(i) = 0;
    else
        tmp(i) = 1;
    end
end
tmp = logical(tmp);
fld = fld(tmp);

trk.code.order = fld;

if  trk.forage   % Consider changing name of this flag
    
    n_groups = length(trk.(fld{1}));
    obj_code = [];
    for g = 1:n_groups;
        for i = 1:length(fld)
            t.(fld{i}) = trk.(fld{i}){g};
        end
        tmp = [];
        for i = 1:length(fld)
            if i == 1
                tmp = t.(fld{i})';
            else
                tmp_base = [tmp NaN(size(tmp(:,1)))];
                tmp = [];
                for n = 1:length(t.(fld{i}))
                    tmp_base(:,i) = t.(fld{i})(n)*ones(size(tmp_base(:,i)));
                    tmp = [tmp; tmp_base];
                end
            end
        end
        obj_code = [obj_code; tmp];
    end
    
else   % For older code where each parameter of object was specified
    for m = 1:length(trk.object_contrast{1})
        for n = 1:length(fld)
            obj_code(m,n) = trk.(fld{n}){1}(m);
        end
    end
end

trk.code.params = obj_code;


