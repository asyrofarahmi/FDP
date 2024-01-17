%numThresholdSignificance = 16 %Threshold size which Type 1 Error (FNR) has more significance different for proposed
%1 year 29:64 = 36, 2 year 11:22 = 12
predictedLabel_M0={}
predictedLabel_M1={}
check={}
check0={}
curThresh = 1
curRunFold = 1
fold = 10
run = 5
curConfMet = 0
for rangeThresh = 43:43
    for curRunData =  1:run %1~5
        for curFold =  1:fold   %1~10
            for curProb = 1:size(ATLMANSVMBaseline{curRunData}.prob{curFold},1)
                %For Yawen's code, use (curProb,2). For Dinda's. use (curProb,1)
                if ATLMANSVMBaseline{curRunData}.prob{curFold}(curProb,1) >= thresholdList(rangeThresh)
                    predictedLabel_M0{curThresh}{curRunFold}(curProb,1) = 1;
                else
                    predictedLabel_M0{curThresh}{curRunFold}(curProb,1) = 0;
                end
                %%
                if stacking{curRunData}.prob{curFold}(curProb,1) >= thresholdList(rangeThresh)
                    predictedLabel_M1{curThresh}{curRunFold}(curProb,1) = 1;
                else
                    predictedLabel_M1{curThresh}{curRunFold}(curProb,1) = 0;
                end
                %%
    %             disp(predictedLabel_M0{curThresh}{curFold}(curProb,1))                
            end
            curConfMet = rangeThresh + (100*(curFold-1)) 
            check0 {curThresh}(:,curRunFold) = ATLMANSVMBaseline{curRunData}.confusionMatrix(:,curConfMet)
            check {curThresh}(:,curRunFold) = stacking{curRunData}.ConfusionMatrix(:,curConfMet)
            curRunFold = curRunFold + 1
        end
    end
    curThresh = curThresh + 1
    curRunFold = 1
end