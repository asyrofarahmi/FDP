classdef (Abstract) ensemble < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
        KFOLD;
        baseLearnerList;
        ConfusionMatrix;
        DISCRIPTION;
    end
    
    methods
        output = testModel(obj);
    end
    
end

