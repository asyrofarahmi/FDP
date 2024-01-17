classdef SVMModel < handle & ModelToolkit
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        KFOLD;
        DISCRIPTION;
        model;
        testingResult;
        confusionMatrix;
        prob; 
        thresholdList;
        featureSet;
        featureWeightSet;
    end
    
    methods
        
        % Purpose: initializing the SVMModel (basic info, ex: kfold, thresholdList, discription, ...)
        % Input: KFold (10 folds)
        %        thresholdList (100 thresholds)
        %        discription (abbreviation of the model)
        % Output: obj (SVMModel object)
        function obj = SVMModel(KFold,  thresholdList, discription)
            obj.KFOLD = KFold;
            obj.prob = cell(1, KFold);
            obj.testingResult = cell(1, KFold);
            obj.thresholdList = thresholdList;
            obj.DISCRIPTION = discription;
            obj.featureSet = cell(1, obj.KFOLD);
            obj.featureWeightSet = cell(1, obj.KFOLD);
            obj.confusionMatrix = [];
            obj.model = cell(1, obj.KFOLD);
        end
        
        % Purpose: train SVM model and record the model and featureSet and featureWeight
        % Input: trainingSet (training Set of current Fold)
        %        featureSet (featureSet of current fold)
        %        curFold (current fold number)
        % Output: model (trained model of current fold)
        function model = trainModelandRecord(obj, trainingSet, featureSet, curFold)
           
%           libsvmOption = strcat( '-q -s 0 -t 0 -b 1 -w0 1 -w1',32 ,num2str(parameter.penalty));
            libsvmOption = sprintf('-q -s 0 -b 1 -t 0 -w0 1 -w1 1');
            model =  svmtrain(trainingSet(:,1), trainingSet(:, featureSet), libsvmOption);
            w=(model.SVs' * model.sv_coef).^2;
            obj.featureWeightSet{curFold} = w';
            obj.model{curFold} = model;
            obj.featureSet{curFold} = featureSet;
        end
        
        % Purpose: test the model of current fold (this method is used when testing the base learner model of stacking)
        % Input: validationSets (validationSets of current fold)
        %        curFold (current fold number)
        function testRecordedModel(obj, validationSets, curFold)
            
            featureSet = obj.featureSet{curFold};
%             Featureset = [39:42]
            Model = obj.model{curFold};
            [result, ~, probResult] = svmpredict(validationSets(:, 1), validationSets(:, featureSet), Model, '-b 1' );
            obj.testingResult{curFold} = result;
            obj.prob{curFold} = probResult;
            obj.confusionMatrix(:, curFold) = obj.calculateConfusionMatrix(validationSets(:, 1), result);
        end
        
        % Purpose: train SVM Model
        % Input: trainingValidationSet (trainingValidationSet of current model)
        %        featureSet (feature set of current model)
        % Output: model (SVMModel model)
        function model = trainModel(obj, trainingValidationSet, featureSet)
           
                libsvmOption = sprintf('-q -s 0 -b 1 -t 0');
            
            model =  svmtrain(trainingValidationSet(:,1), trainingValidationSet(:, featureSet), libsvmOption);
        end
        
        % Purpose: test SVM model
        % Input: testingSet (testingSet of current model)
        %        featureSet (feature set of current model)
        %        model (current model)
        % Output: confusionMatrix (confusionMatrix which containing accuracy, typeI, typeII for each threshold in each fold)
        %         result (testing results)
        %         probRresult (probability results)
        function [confusionMatrix, results, probResults ]= testModel(obj, testingSet, featureSet, model)
            [results, ~, probResults] = svmpredict(testingSet(:, 1), testingSet(:, featureSet), model, '-b 1' );
            confusionMatrix=obj.calculateConfusionMatrix(testingSet(:, 1), results);
        end
        
        % Purpose: calculate confusionMatrix
        % Input: label (label of the testingSet)
        %        testingResult (current model)
        % Output: output ( accuracy, typeI, typeII of current threshold in each fold)
        function output = calculateConfusionMatrix(obj, label, testingResult)
            correctCount = 0; %判斷正常的總數
            typeIICount = 0;     %答案是危機被誤判成正常總數
            typeICount = 0;     %答案是正常被誤判成危機總數
            numOfTestingData = numel(label); %有幾筆testingData
            numOfNormalAns = 0; %正常答案有幾個
            numOfDistressAns = 0; %危機答案有幾個
            %訓練執行計算FAR&FRR筆數
            for v = 1:numOfTestingData
                
                if ( label(v) == 0 ) %正常答案
                    numOfNormalAns = numOfNormalAns + 1;
                else % 危機答案
                    numOfDistressAns = numOfDistressAns + 1;
                end
                
                if ( label(v) == 0 && testingResult(v) == 1 ) %正常判成危機
                    typeIICount = typeIICount + 1;
                elseif ( label(v) == 1 && testingResult(v) == 0 ) %危機判成正常
                    typeICount = typeICount + 1;
                else %判斷正常
                    correctCount = correctCount + 1;
                end
            end
            accuracy = correctCount / numOfTestingData;
            typeI = typeICount / numOfDistressAns;
            typeII = typeIICount / numOfNormalAns;
            output = [accuracy; typeI; typeII];
        end
        
        
        function [result, probResult]=testRecordedModelwithThreshold(obj, testingSet, curFold)
%             get the fetureSet of the current fold
            featureSet = obj.featureSet{curFold};
            
            % get the model of the current fold
            Model = obj.model{curFold};
            curTime = (curFold-1)*length(obj.thresholdList)+1; % calculate the current index to put the result list (acc, typeI, typeII)
            
             % test model
            [result, ~, probResult] = svmpredict(testingSet(:, 1), testingSet(:, featureSet), Model, '-b 1' );
            
            % decide the result by the probability with thresholds
            for piter = 1:length(obj.thresholdList)
                
                % get the current threshold
                threshold = obj.thresholdList(piter);
                thresholdResults = [];
                
                % decide the result 
                for thresholdIter = 1:size(probResult)
                    
                    if probResult(thresholdIter, 1)> threshold
                        thresholdResults(thresholdIter, 1) = 1;
                    else
                        thresholdResults(thresholdIter, 1) = 0;
                    end
                end
                
                % record the result list base on the current threshold 
                obj.testingResult{curFold}=[obj.testingResult{curFold} thresholdResults];
                % recored the probability (bankruptcy) result list
                % generated by the model
                obj.prob{curFold} = probResult;
                % get confusionMatrix 
                obj.confusionMatrix(:, curTime) = obj.calculateConfusionMatrix(testingSet(:, 1), thresholdResults);
                curTime = curTime + 1;
            end
            
        end
        
        % Purpose: test model with thresholds
        % Input: testingData (testing data of current model)
        %        featureSet (feature set of current model)
        %        model (current model)
        % Output: confusionMatrix (confusionMatrix which containing accuracy, typeI, typeII for each threshold in each fold)
        %         resultList (testing results)
        %         probRresult (probability results)
        function [confusionMatrix, results, probResults ]= testModelwithThreshold(obj, testingData, featureSet, model)
%             curTime = (curFold-1)*length(obj.thresholdList)+1; % calculate the current index to put the result list (acc, typeI, typeII)
            [result, ~, probResults] = svmpredict(testingData(:, 1), testingData(:, featureSet), model, '-b 1' );
            for piter = 1:length(obj.thresholdList)
                threshold = obj.thresholdList(piter);
                resultsbyThreshold = [];
                for thresholdIter = 1:size(probResults)
                    
                    if probResults(thresholdIter, 1)>= threshold
                        resultsbyThreshold(thresholdIter, 1) = 1;
                    else
                        resultsbyThreshold(thresholdIter, 1) = 0;
                    end
                end
                results{piter} = resultsbyThreshold;
                confusionMatrix(:, piter) = obj.calculateConfusionMatrix(testingData(:, 1), resultsbyThreshold);    
            end
%             confusionMatrix=obj.getConfusionMatrix(testData(:, 1), resultT);
        end
        
        % Purpose: get confusionMatrix
        % Output: confusionMatrix (confusionMatrix)
        function [confusionMatrix] = getConfusionMatrixList(obj)
            confusionMatrix = obj.confusionMatrix;
        end
        
        % Purpose: get featureSet of current fold
        % Output: featureSet (feature set)
        function featureSet = getFeatureSet(obj, curFold)
            featureSet = obj.featureSet{curFold};
        end
    end
end
    
