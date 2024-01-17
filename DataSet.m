classdef DataSet < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public )
        PATH;
        FILENAME;
        KFOLD;
        kFoldDataset;
        trainingSets;
        testingSets;
        % trainingSets and validationData is 10 fold of trainData
        % use for derive training dataset for metadata (stacking)
        % and prevent information leak
        trainingSetsofTrainingValidationSets;
        validationSets;
    end
    
    methods
        function obj = DataSet(kfold,path , fileName)
            obj.KFOLD = kfold;
            obj.setPATH(path);
            obj.setFILENAME(fileName);
            obj.loadData();
        end
        %% get/set function
        function setFILENAME(obj,fileName)
            obj.FILENAME = fileName;
        end
        function setPATH(obj, path)
            obj.PATH = path;
        end
        function loadData(obj)
            loadDataName = sprintf('%s/%s', obj.PATH, obj.FILENAME);
            load(loadDataName, 'sampleSet');
            obj.setkFoldDataset(sampleSet);
            obj.setTrainingSets(sampleSet.trainingSets);
            obj.setTestingSets(sampleSet.testingSets);
            obj.setTrainingValidationSets(sampleSet);
        end
        function setkFoldDataset(obj, sampleSet)
            obj.kFoldDataset = sampleSet;
        end
        function setTrainingSets(obj, trainingSets)
            obj.trainingSets = trainingSets;
        end
        function output=getTrainingSets(obj, curFold)
            output = obj.trainingSets{curFold};
        end
        function setTestingSets(obj, testingSets)
            obj.testingSets = testingSets;
        end
        function output=getTestingSets(obj, curFold)
            output = obj.testingSets{curFold};
        end
        function setTrainingValidationSets(obj,sampleSet)
            obj.trainingSetsofTrainingValidationSets = cell(1, obj.KFOLD);
            obj.validationSets = cell(1,obj.KFOLD);
            for i = 1:obj.KFOLD
                obj.trainingSetsofTrainingValidationSets{i} = sampleSet.trainingValidationSets{i}.trainingSets;
                obj.validationSets{i} = sampleSet.trainingValidationSets{i}.validationSets;
            end
        end
        function output = getTrainingSetsofTrainingValidationSets(obj, curFold, subFold)
            output = obj.trainingSetsofTrainingValidationSets{curFold}{subFold};
        end
        function output = getValidationSets(obj, curFold, subFold)
            output = obj.validationSets{curFold}{subFold};
        end
        function output = getAllData(obj)
            output = obj.kFoldDataset;
        end
        
   
        
    end
end
