clear;
clc;

% set basic info
DATASETPATH = 'E:\107522604\Finance Research\Ayu\ensembleStacking2\dataset\Flora\newDataSet 07 Apr 2020\';
DATASETNAME = 'matchedFirmsT1';

NUMOFNFOLD = 5;
NFOLDSIZE = 10;

% 讀取實驗資料
loadDataName = strcat(DATASETPATH, 'matchedFirmsT1.mat');
load (loadDataName);

watchDogDataSet = double(matchedFirmsT1);

% run n-nfold 
for numofNFold = 1 : NUMOFNFOLD

    % get infomation of risk and normal firms
    distressFirmsSet = getDistressDataset(watchDogDataSet);
    nonDistressFirmsSet = getNormalDataset(watchDogDataSet);
    
    % 10 fold partition for distressFirmsSet firms and nonDistressFirmsSet firms (by index)
    distressFirmsIndex = cvpartition(size(distressFirmsSet,1), 'Kfold', NFOLDSIZE);
    nonDistressFirmsIndex = cvpartition(size(nonDistressFirmsSet,1), 'Kfold', NFOLDSIZE);
    
    for NFoldSize = 1 : NFOLDSIZE
        % prepare training data and testing data (get the complete firm data by index)
        trainingSet = [distressFirmsSet(distressFirmsIndex.training(NFoldSize),:); nonDistressFirmsSet(distressFirmsIndex.training(NFoldSize),:)];
        testingSet = [distressFirmsSet(distressFirmsIndex.test(NFoldSize),:); nonDistressFirmsSet(distressFirmsIndex.test(NFoldSize),:)];
        sampleSet.testingSets{NFoldSize} = testingSet;
        sampleSet.trainingSets{NFoldSize} = trainingSet;
        
        % get distressFirmsSet firms and non distressFirmsSet firms 
        distressFirmsSetofTraining = getDistressDataset(trainingSet);
        nonDistressFirmsSetofTraining = getNormalDataset(trainingSet);
        
        % 10 fold partition for trainingSets sets and validation sets (by index)
        distressFirmsIndexofTraining = cvpartition(size(distressFirmsSetofTraining,1),'kfold',NFOLDSIZE);
        nonDistressFirmsIndexofTraining = cvpartition(size(nonDistressFirmsSetofTraining,1),'kfold',NFOLDSIZE);
        
        
        % n fold of training validation sets
        for NFoldSizeofTraining = 1 : NFOLDSIZE
        
            % preapre trainingSets set and validation set  (get the complete firms data by index)
            sampleSet.trainingValidationSets{NFoldSize}.trainingSets{NFoldSizeofTraining} = [distressFirmsSetofTraining(distressFirmsIndexofTraining.training(NFoldSizeofTraining),1:end) ; nonDistressFirmsSetofTraining(nonDistressFirmsIndexofTraining.training(NFoldSizeofTraining),1:end)];
            sampleSet.trainingValidationSets{NFoldSize}.validationSets{NFoldSizeofTraining} = [distressFirmsSetofTraining(distressFirmsIndexofTraining.test(NFoldSizeofTraining),1:end) ; nonDistressFirmsSetofTraining(nonDistressFirmsIndexofTraining.test(NFoldSizeofTraining),1:end)];
%             answer = [answer ; sampleSet.test{i}(:,1)];
        end
    end
    
    % save file 
    fileName = [DATASETPATH, DATASETNAME, '_', num2str(NFOLDSIZE), 'fold_', num2str(numofNFold), '.mat'];
    save (fileName);
end    
    % delete unused variable
%     clearvars -except NUMOFNFOLD USExpDataset NFOLDSIZE datasetPath datasetName;

