function [NormalDataset] = getNormalDataset(Dataset)

% get all the data if it is normal firm
NormalIndex = (Dataset(:, 1)) == 0;
NormalDataset = Dataset(NormalIndex, :);

end
