function obj_code = findObjCode(trk,obj)
%
%
%
%

fld = trk.code.order;

for i = 1:length(fld)
    tmp = strfind(fld{i},'_');
    fld{i} = fld{i}(tmp+1:end);
end

for i = 1:length(fld)
    
    params(i) = obj.(fld{i});
    
end

obj_code = findMatchingRow(trk.code.params,params);