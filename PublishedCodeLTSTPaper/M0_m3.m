M_data = {};
M0_data = {};
M1_data = {};
M10_data = {};
M11_data = {};
allMdata =  [];
allM0data = [];
allM1data = [];
allM10data = [];
allM11data = [];
datasetName = 'matchedFirmsT1'; 
% 
for t = 1:size(predictedLabel_M1,1) %threshold
    curFold = 0;
    for i=1:5 %dataset
        filename = strcat('A:\FDP-LTST\matching1to1\', datasetName, '_10fold_', num2str(i), '.mat');
        load(filename, 'sampleSet'); %load(filename, 'fold');
        for j = 1:10 %fold
        a = 0; 
        b = 0;
        c = 0; d=0;e=0;
        curFold = curFold+1;
            for k = 1:size(predictedLabel_M0{t}{curFold},1)/2 %46/2=23 Number of Bankrupt (Not included Normal company)
%         startCompany = size(predictedLabel_M0{t}{curFold},1)/2 + 1
%         for k = startCompany:size(predictedLabel_M0{t}{curFold},1) %46/2=23 Number of Normal (Not included Bankrupt company)
                M0_result = predictedLabel_M0{t}{curFold}(k,1);
                M1_result = predictedLabel_M1{t}{curFold}(k,1);
                if M0_result==1 && M1_result==0
                    a = a+1;
%                     M0_data{t}{curFold}(a,:) = [t,curFold,fold.testData{j}(k,:)];
                    M0_data{t}{curFold}(a,:) = [t,curFold, sampleSet.testingSets{j}(k,:), M0_result, M1_result];
                end
                if M0_result==0 && M1_result==1 %M1_result==1 %
                    b = b+1;
%                     M1_data{t}{curFold}(b,:) = [t,curFold,fold.testData{j}(k,:)];
                    M1_data{t}{curFold}(b,:) = [t,curFold, sampleSet.testingSets{j}(k,:), M0_result, M1_result];
                end
                if M0_result==1 %&& M1_result==0%=0
                    c = c+1;
                    M10_data{t}{curFold}(c,:) = [t,curFold, sampleSet.testingSets{j}(k,:), M0_result, M1_result ];
                end
                if M1_result==1  %M0_result==1 && M1_result==1
                    d = d+1;
                    M11_data{t}{curFold}(d,:) = [t,curFold, sampleSet.testingSets{j}(k,:), M0_result, M1_result ];
                end
                e=e+1;
                M_data{t}{curFold}(e,:) = [t,curFold, sampleSet.testingSets{j}(k,:), M0_result, M1_result ];
            end
            %Kalau dibikin else if nanti ab==0, m1data nya lolos. 
            if a == 0
                M0_data{t}{curFold} = [];
            end            
            if b == 0
                M1_data{t}{curFold} = [];
            end
            if c == 0
                M10_data{t}{curFold} = [];
            end
            if d == 0
                M11_data{t}{curFold} = [];
            end
            if e == 0
                M_data{t}{curFold} = [];
            end
        end
    end
end

for i = 1:size(predictedLabel_M0,2)
    for j = 1:50
        if isempty(M0_data{i}{j}) == 0
            allM0data = [allM0data;M0_data{i}{j}];
        end
        if isempty(M1_data{i}{j}) == 0
            allM1data = [allM1data;M1_data{i}{j}];
        end
        if isempty(M10_data{i}{j}) == 0
            allM10data = [allM10data;M10_data{i}{j}];
        end
        if isempty(M11_data{i}{j}) == 0
            allM11data = [allM11data;M11_data{i}{j}];
        end
        if isempty(M_data{i}{j}) == 0
            allMdata = [allMdata;M_data{i}{j}];
        end
    end
end

idCIK=4; idYear=6;
[~,idx] = sortrows(allMdata(:,[idCIK,idYear])); % sort just the first column
temp1 = allMdata(idx,:); 
CIKM = unique(temp1(:,[idCIK,idYear :end]),'rows','stable'); 
[~,idx] = sortrows(allM0data(:,[idCIK,idYear])); % sort just the first column
temp2 = allM0data(idx,:); 
CIKM0 = unique(temp2(:,[idCIK,idYear :end]),'rows','stable'); 
[~,idx] = sortrows(allM1data(:,[idCIK,idYear])); % sort just the first column
temp3 = allM1data(idx,:); 
CIKM1 = unique(temp3(:,[idCIK,idYear :end]),'rows','stable'); 
[~,idx] = sortrows(allM10data(:,[idCIK,idYear])); % sort just the first column
temp4 = allM10data(idx,:); 
CIKM10 = unique(temp4(:,[idCIK,idYear :end]),'rows','stable'); 
[~,idx] = sortrows(allM11data(:,[idCIK,idYear])); % sort just the first column
temp5 = allM11data(idx,:); 
CIKM11 = unique(temp5(:,[idCIK,idYear :end]),'rows','stable'); 

liM0 = ismember(CIKM0, CIKM1,'rows');
liM1 = ismember(CIKM1, CIKM0, 'rows');
liM10 = ismember(CIKM10, CIKM0, 'rows');
liM11 = ismember(CIKM11, CIKM1, 'rows');
uniqueCIKM0 = CIKM0(liM0 == 0,:);
uniqueCIKM1 = CIKM1(liM1 == 0,:);
uniqueCIKM10 = CIKM10(liM10 == 0,:);
uniqueCIKM11 = CIKM11(liM11 == 0,:);

liMZ = ismember(uniqueCIKM10, uniqueCIKM11, 'rows');
liMZZ = ismember(uniqueCIKM11, uniqueCIKM10, 'rows');
uniqueCIKMZ = uniqueCIKM10(liMZ == 1,:);
uniqueCIKMZZ = uniqueCIKM11(liMZZ == 1,:);

