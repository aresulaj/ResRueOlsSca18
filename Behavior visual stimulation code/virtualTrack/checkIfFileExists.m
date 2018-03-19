function fname = checkIfFileExists(fname)

while ~isempty(dir(fname)) % augment filename by 1 until a file of the same name doesn't exist
    tmp = findstr(fname,'_'); tmp2 = findstr(fname,'.');
    if isempty(tmp2); stmp2 = ''; else stmp2 = fname(tmp2:end); end
    if isempty(tmp)       fname = [fname(1:tmp2-1) '_1' stmp2];
    elseif tmp+1==tmp2;  fname = [fname(1:tmp2-2) '_1' stmp2];
    else    fname = [fname(1:tmp(end)) num2str(str2num(fname(tmp(end)+1:tmp2-1))+1) stmp2]; end
end