cMat_perc = [];
FDR_FOR = {};

for i = 1:size(cMat,1)
for j = 1:size(cMat,2)
cMat_perc(i,j) = cMat{i,j}(2)/cMat{i,j}(1);
end
end

for i = 1:size(zTD,1)
    for j = 2:size(zTD,2)
        FDR_FOR{i,j}(1) = zTD{i,j}(4)/zTD{i,j}(3);
        FDR_FOR{i,j}(2) = zTD{i,j}(6)/zTD{i,j}(5);
    end
end

ct2_9 = vertcat(zTD{:,6});
a = sum(ct2_9,1);
ct2_FDR = a(4)./a(3);
ct2_FOR = a(6)./a(5);