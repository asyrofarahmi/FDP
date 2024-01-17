function [DistressDataset] = getDistressDataset(dataSet)

% get all the data if it is distress firm
DistressIndex = (dataSet(:, 1)) == 1;
DistressDataset = dataSet(DistressIndex, :);

end
