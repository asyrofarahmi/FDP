clear ALL;
clc;

% 10 fold data and feature set path and file name
DATAPATH = 'A:\FDP-LTST\matching1to1\';
% DATAPATH = 'A:\FDP-LTST\matching1to2New\';
% DATAPATH = 'A:\FDP-LTST\matching1to3New\';
% DATAPATH = 'A:\FDP-LTST\matching1toAll\';
DATASETNAME = 'matchedFirmsT1_10fold';
% DATASETNAME = 'matched1to2New_10fold';
% DATASETNAME = 'matched1to3_10fold';
% DATASETNAME = 'matching1toAll_10fold';

% informations of model
KFOLD = 10;
RANDDATA = 5
LTFEATURESET = 10;%long term feature set : Z2
STFEATURESET = [9,11:13];%short term feature set : Z1, Z3, Z4, Z5
altmanIndex = 9:13;
sampleSet = cell(1, 5);

% ------------------------------------------------------ STACKING
stacking = cell(1,RANDDATA);
% ------------------------------------------------------ LONGTERM
ATLMANSVMLong = cell(1, RANDDATA);
% ------------------------------------------------------ SHORTTERM
ATLMANSVMShort = cell(1,RANDDATA);
% ------------------------------------------------------ BASELINE
ATLMANSVMBaseline = cell(1,RANDDATA);
%-------------------------------------------------Threshold and costlist
thresholdList = linspace(0, 1, 100);
costList =[1 1.5 1.8 2 2.5 2.8 3 3.5 4 4.5];

for setIter = 1:RANDDATA
    fileName = sprintf('%s_%d', DATASETNAME, setIter);
    % initialized
    % ------------------------------------------------------Base LONGTERM
    ATLMANSVMLong{setIter} = SVMModel(KFOLD, thresholdList, 'SVMlong');
    % ------------------------------------------------------Base SHORTTERM
    ATLMANSVMShort{setIter} = SVMModel(KFOLD, thresholdList, 'SVMshort');
    % ------------------------------------------------------BASELINE
    ATLMANSVMBaseline{setIter} = SVMModel(KFOLD, thresholdList, 'M0 SVM');
    % ------------------------------------------------------PROPOSED
    stacking{setIter} = stackingEnsemble(KFOLD, thresholdList, 'M1 Stacking SVM');

    
    % load data
    sampleSet{setIter} = DataSet(KFOLD, DATAPATH, fileName);
    for foldIter = 1:10
        %% baseLearner for LONGTERM
        feature = LTFEATURESET;
        ATLMANSVMLong{setIter}.trainModelandRecord(sampleSet{setIter}.getTrainingSets(foldIter), feature, foldIter);
        ATLMANSVMLong{setIter}.testRecordedModelwithThreshold(sampleSet{setIter}.getTestingSets(foldIter),foldIter);
        
        %% baseLearner for SHORT TERM
        feature = STFEATURESET;
        ATLMANSVMShort{setIter}.trainModelandRecord(sampleSet{setIter}.getTrainingSets(foldIter), feature, foldIter);
        ATLMANSVMShort{setIter}.testRecordedModelwithThreshold(sampleSet{setIter}.getTestingSets(foldIter),foldIter);
                
        %% SVM Baseline
        feature = altmanIndex;
        ATLMANSVMBaseline{setIter}.trainModelandRecord(sampleSet{setIter}.getTrainingSets(foldIter), feature, foldIter);
        ATLMANSVMBaseline{setIter}.testRecordedModelwithThreshold(sampleSet{setIter}.getTestingSets(foldIter),foldIter);
        
        %% stacking
        stacking{setIter}.updatebaseLearner(ATLMANSVMLong{setIter},ATLMANSVMShort{setIter});
        stacking{setIter}.trainMetaLearnerRecord(sampleSet{setIter}, foldIter);
        stacking{setIter}.testRecordedModel(sampleSet{setIter}.getTestingSets(foldIter), foldIter);
    end
end

modelAnalysis = ModelAnalysis(costList, thresholdList, sampleSet{1}.getAllData());
selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], logical(0), stacking, ATLMANSVMBaseline)
[~,~,~, averageM1, ~] = modelAnalysis.getCostPackage2(stacking, selectedThres(1,:))
[~,~,~, averageM0, ~] = modelAnalysis.getCostPackage2(ATLMANSVMBaseline, selectedThres(2,:))

selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], logical(1), stacking, ATLMANSVMBaseline)
pvalue = modelAnalysis.doWilcoxonTest(selectedThres, stacking, ATLMANSVMBaseline)
