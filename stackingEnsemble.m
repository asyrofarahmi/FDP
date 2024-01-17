classdef stackingEnsemble < handle & ensemble
    % design to solve one set of baselearner in one stacking ensemble
    % to keep it simple, which mean that we have 5 times of 10 fold to test,
    % so we have 5 stacking ensemble.
    % so that data structure of the dataSet, the base learner and the stacking ensemble
    % can keep the same;
    % you must training base model first, than you can train meta learner
    properties
        KFOLD;
        baseLearnerList;
        ConfusionMatrix;
        DISCRIPTION;
        metaTrainList;
        thresholdList;
        trainingError;
        metaModelList;
        prob;
    end
    
    methods
        function obj = stackingEnsemble(kfold, thresholdList, discription)
            obj.KFOLD = kfold;
            obj.thresholdList = thresholdList;
            obj.DISCRIPTION = discription;
          %  obj.baseLearnerList = cell(1, length(varargin));
            
            obj.baseLearnerList = {};
            
            obj.ConfusionMatrix = [];%zeros(3, length(thresholdList)*obj.KFOLD);
            obj.trainingError = zeros(3, obj.KFOLD);
            obj.metaTrainList = cell(1, obj.KFOLD);
            obj.metaModelList = cell(1,obj.KFOLD);
            obj.prob = cell(1,obj.KFOLD);
        end
        function updatebaseLearner(obj, varargin)
            for i = 1:length(varargin)
                obj.baseLearnerList{i} = varargin{i};
            end
        end
        function trainMetaLearnerRecord(obj, dataset, curFold)
            metaTrainList=[];
            for i = 1:obj.KFOLD
                % prepare training data for meta learner
                training = dataset.getTrainingSetsofTrainingValidationSets(curFold, i);
                validation = dataset.getValidationSets(curFold, i);
                probAll =[];
                for j = 1:length(obj.baseLearnerList)
                    model = obj.baseLearnerList{j}.trainModel(training, obj.baseLearnerList{j}.getFeatureSet(curFold));
                    [~,~,prob]=obj.baseLearnerList{j}.testModel(validation, obj.baseLearnerList{j}.getFeatureSet(curFold), model);
                    probAll = [probAll prob];
                end
                metaTrainList = [metaTrainList; validation(:, 1) probAll];
            end
            obj.metaTrainList{curFold} = metaTrainList;
             % train meta learner
                % we can take any of base learner model to train meta model
                % because in my experiment, all of the model we select to
                % use LSVM model.
                % when we want to expend our experiment to use other model
                % as meta learner, we need to redesign this part.
                model = obj.baseLearnerList{1}.trainModel(metaTrainList, 2:size(metaTrainList, 2));
                obj.metaModelList{curFold} = model;
        end
        
        function obj = testRecordedModel(obj, testData, curFold)
            % test base model
            prob={};
            for i = 1:length(obj.baseLearnerList)
                [~, prob{i}]=obj.baseLearnerList{i}.testRecordedModelwithThreshold(testData, curFold);
            end
            
            % derive meta input
            metaTest = testData(:, 1);
            for i = 1:length(obj.baseLearnerList)
                metaTest = [metaTest prob{i}];
            end
            
            % result
            [confusionMatrix, ~, probResult] = obj.baseLearnerList{1}.testModelwithThreshold(metaTest, 2:size(metaTest, 2), obj.metaModelList{curFold});
            obj.ConfusionMatrix = [obj.ConfusionMatrix confusionMatrix];
            obj.prob{curFold} = probResult;
        end
        function output = getConfusionMatrixList(obj)
            output = obj.ConfusionMatrix;
        end
    end
    
end

