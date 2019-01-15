%master script for data challenge
%----------------------------------------
%----------------------------------------
clear
close all
clc


%data guide:
%sim: similarity results
%train_feat: features constructed from similar training plant data
%test_feat: features constructed from test plant data
%train_feat_reduce: principal component matrix explaining ~95% of variance
%test_feat_reduce: principal component matrix trimmed to same width as train_feat_reduce
%knn: classifier object for a given fault
%predict: true/false prediction for a given fault
%time: time stamps at the end of feature windows


testplants=[41,42,43,45,46,47,48,49,53,54,56,57,58,69,60];

%similarity results
%----------------------------------------
%test data most similar: [plant, component, sensor]
data.sim{41,1}=[41,1,1];
data.sim{42,1}=[42,6,1];
data.sim{43,1}=[43,4,1];
data.sim{45,1}=[45,1,1];
data.sim{46,1}=[46,4,1];
data.sim{47,1}=[47,6,1];
data.sim{48,1}=[48,10,1];
data.sim{49,1}=[49,4,1];
data.sim{53,1}=[53,4,1];
data.sim{54,1}=[54,4,1];
data.sim{56,1}=[56,6,1];
data.sim{57,1}=[57,7,1];
data.sim{58,1}=[58,7,1];
data.sim{59,1}=[59,3,1];
data.sim{60,1}=[60,6,1];
%train data most similar: [plant, component, sensor]
data.sim{41,2}=[39,5,1];
data.sim{42,2}=[40,3,1];
data.sim{43,2}=[30,1,1];
data.sim{45,2}=[21,6,1];
data.sim{46,2}=[35,2,1];
data.sim{47,2}=[15,4,1];
data.sim{48,2}=[5,3,1];
data.sim{49,2}=[15,3,1];
data.sim{53,2}=[30,5,1];
data.sim{54,2}=[15,3,1];
data.sim{56,2}=[15,3,1];
data.sim{57,2}=[6,8,1];
data.sim{58,2}=[6,8,1];
data.sim{59,2}=[6,8,1];
data.sim{60,2}=[2,12,1];


%Optimizable Script Parameters
%----------------------------------------
Windows=110;%window size
tol=95;%cumulative explained variance by retained principle components 
NumNeighborsF1=5; %number of neighbors for kNN classifier regarding fault 1
NumNeighborsF2=5;
NumNeighborsF3=5;
NumNeighborsF4=5;
NumNeighborsF5=5;

% for 
PlantNum=41;
fprintf('beginning plant %d',PlantNum)
%feature construction
%----------------------------------------
%requires featcon_PCS.m
%requires that CombPlant#.mat training plant files are in local directory
%inputs:
%   -MainData: cell containing most similar tuples for each test plant
%   -PlantNum: plant choice in question 
%   -Windows: test window size, in number of data points
tic
[data.train_feat{PlantNum},data.response{PlantNum},~]=featcon_PCS(data.sim,PlantNum,Windows,true);%calculate training features for similar plant
[data.test_feat{PlantNum},~,data.time{PlantNum}]=featcon_PCS(data.sim,PlantNum,Windows,false);%calculate test features on current plant
fprintf('feature construction complete for  plant %d',PlantNum)
toc

%feature transformation and reduction(PCA)
%----------------------------------------
%requires feat_PCA.m, featcon_time.m, featcon_freq.m, featcon_peaks.m
%inputs: 
%   -featcon: constructed feature matrix from featcon_PCS or featcon_PZ
%   -tol: maximum explained variance(%) e.g. 95
%   -TrainPlantNum: number of training plant used for feature reduction
%outputs: 
%   -reduced_feat: reduced feature matrix after PCA
%   -coeff: coefficient matrix
%   -score: score matrix (features x coefficients)
%   -fault_codes:
tic
[data.train_feat_reduce{PlantNum},data.coeff{PlantNum},data.maxfeat{PlantNum}]=feat_PCA(data.train_feat{PlantNum},tol); %report [reduced training feature matrix, coeff matrix, number of principal components kept]
reducedtestfeat=data.test_feat{PlantNum}*data.coeff{PlantNum}; %convert test data to princ. comps.
data.test_feat_reduce{PlantNum}=reducedtestfeat(:,1:min(data.maxfeat{PlantNum}));%trim princ. comp. matrix to same length as training data
fprintf('feature transformation complete for plant %d',PlantNum)
toc

%classifier generation
%----------------------------------------
%select choice of number of neighbors for each classifier
tic
data.knn{PlantNum,1}=fitcknn(data.train_feat_reduce{PlantNum},data.response{PlantNum}(:,1),'NumNeighbors',NumNeighborsF1);
data.knn{PlantNum,2}=fitcknn(data.train_feat_reduce{PlantNum},data.response{PlantNum}(:,2),'NumNeighbors',NumNeighborsF2);
data.knn{PlantNum,3}=fitcknn(data.train_feat_reduce{PlantNum},data.response{PlantNum}(:,3),'NumNeighbors',NumNeighborsF3);
data.knn{PlantNum,4}=fitcknn(data.train_feat_reduce{PlantNum},data.response{PlantNum}(:,4),'NumNeighbors',NumNeighborsF4);
data.knn{PlantNum,5}=fitcknn(data.train_feat_reduce{PlantNum},data.response{PlantNum}(:,5),'NumNeighbors',NumNeighborsF5);
fprintf('classifier training complete for plant %d',PlantNum)
toc

%classification
%----------------------------------------
%convert array to table
T=array2table(data.test_feat_reduce{PlantNum});
tic
data.predict{PlantNum,1}=predict(data.knn{PlantNum,1},T{:,:});
data.predict{PlantNum,2}=predict(data.knn{PlantNum,2},T{:,:});
data.predict{PlantNum,3}=predict(data.knn{PlantNum,3},T{:,:});
data.predict{PlantNum,4}=predict(data.knn{PlantNum,4},T{:,:});
data.predict{PlantNum,5}=predict(data.knn{PlantNum,5},T{:,:});
fprintf('classification complete for plant %d',PlantNum)
toc

%conversion to output format
%----------------------------------------
%requires Convert_format.m
%saves csv: '[PlantNum]predict.csv'
%Inputs: 
%   -pred_out: 6 column matrix: [time, F1 true/false prediction,...F5
%       true/false prediction]
%   -plant num: test plant number
tic

convertinput_predict=horzcat(data.predict{PlantNum,1},data.predict{PlantNum,2},data.predict{PlantNum,3},data.predict{PlantNum,4},data.predict{PlantNum,5});%convert fault codes from cell to one 5 column matrix
%convertinput_time=cell2mat(data.time{PlantNum});%convert time vector to matrix
convertinput_total=horzcat(data.time{PlantNum}(Windows:length(data.time{PlantNum})),convertinput_predict);

% scoreFun(convertinput_total,Data_actual)

%convertinput_total=horzcat(convertinput_time,convertinput_predict);%form six column input matrix to Convert_format function
Convert_format(convertinput_total,PlantNum);%write csv file and save output format
fprintf('classification results saved for plant %d',PlantNum)

toc




% end
