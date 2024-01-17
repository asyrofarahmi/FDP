classdef (Abstract) ModelToolkit < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  (Abstract)
        KFOLD;
        model;
        confusionMatrix;
        DISCRIPTION;
        prob;
        thresholdList;
    end
    
    methods
        output=trainModel(obj)
        output=testModel(obj)
        output=getConfusionMatrix(obj)
    end
    
end

