function value = getFromTable(table,field)

iRow = strcmp(table(:,1),field);

if any(iRow)
    value = table(iRow,2);
    if iscell(value)
        value = value{1};
    end
else
%     disp(['The field,' ' ' field ', was not found in track table'])
    value = '';
end


