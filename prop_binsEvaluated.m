q = [18
0
145
340
0
630]; % number of bins evaluated for each type (from LabCert Eval Progress spreadsheet)
totBins = [size(labeledBins{1,3},1),...
size(labeledBins{1,4},1),...
size(labeledBins{1,5},1),...
size(labeledBins{1,6},1),...
size(labeledBins{1,7},1),...
size(labeledBins{1,8},1)]'; % number of bins labeled each type (from DailyTotals files)
z = round((q./totBins*100),1); % proportion of bins evaluated