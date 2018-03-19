
function ind = findMatchingRow(mat,vec)


for i = 1:size(mat,1)
    if all(mat(i,:) == vec)
        break
    end
end
ind = i;