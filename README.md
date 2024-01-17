# Financial Distress Prediction
This code is to investigate the distinct attributes in financial ratios (FRs) than combine those attributes for predicting financial distress.
The attributes of FRs are long-term (LT) and short-term (ST).

There are three step to investigate it:
1. Sampling data: 10 cross-validation that run 5 times (randomized the sample 5 times)
2. Run Experiment: Baseline model (M0) combine all FRs, Proposed Model (M1) split FRs into LT and ST
3. Evaluation
-------------------------------------
1. Sampling data
   open folder /matching1to1
   save sample "matchedFirmsT1.xlsx" as "matchedFirmsT1.mat"
   open file "tenFoldSampling.m": adjust the DATASETPATH and DATASETNAME then run the file
   Output: "matchedFirmsT1_10fold_1.mat" to "matchedFirmsT1_10fold_5.mat"
2. Run Experiment:
   open file "main_test.m" and "loadGlobalVariable.m"
   Adjust the DATAPATH, DATASETNAME, LTFEATURESET, STFEATURESET, altmanIndex, thresholdList, and costList
   run "main_test.m"
3. Evaluation
   At the bottom of "main_test.m", we provide codes for evaluating the models
      modelAnalysis = ModelAnalysis(costList, thresholdList, sampleSet{1}.getAllData());
   
      # Draw DET curve with cost=1 only (as in the paper)
      selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], logical(0), stacking, ATLMANSVMBaseline)
       
      # Draw DET curve with all cost ratios and get all metrics.
      # averageM1: column is each cost ratio, row is accuracy, Type 2, Type 1, and miscost
      selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], logical(1), stacking, ATLMANSVMBaseline)
      [~,~,~, averageM1, ~] = modelAnalysis.getCostPackage2(stacking, selectedThres(1,:))
      [~,~,~, averageM0, ~] = modelAnalysis.getCostPackage2(ATLMANSVMBaseline, selectedThres(2,:))

      # Calculate Wilcoxon Test
      pvalue = modelAnalysis.doWilcoxonTest(selectedThres, stacking, ATLMANSVMBaseline)

      
      % load("A:\FDP-LTST\matching1to1\matchedFirmsT1.mat")
      % [predictedLabel_M0, predictedLabel_M1] = mainAnalyzePreRun(ATLMANSVMBaseline, stacking, thresholdList)
      % impact = MainImpactAnalyze(DATASETNAME, predictedLabel_M0, predictedLabel_M1, sampleSet, matchedFirmsT1)
      % [pairProp, pairProp0, pairBase, pairBase0] = impact.mainAnalyze()
      % modelAnalysis.drawGScatter(matchedFirmsT1, matchedFirmsT1,matchedFirmsT1, matchedFirmsT1, matchedFirmsT1)
      % modelAnalysis.drawChart(matchedFirmsT1) %Companies distribution
