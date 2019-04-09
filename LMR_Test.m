
clear ;
close all;
initialization;  %run it only at the first time
addpath('Trained_Model');
addpath('TestData');
tic
%%
        fn_l = '120_l.JPG';
        fn_r = '120_r.JPG';
        Ia = imread(fn_l);
        Ib = imread(fn_r);
        load 120.mat;
        
%         fn_l = '14_a.JPG';
%         fn_r = '14_b.JPG';
%         Ia = imread(fn_l);
%         Ib = imread(fn_r);
%         load 14_20.mat;
        
%         fn_l = 'church1.JPG';
%         fn_r = 'church2.JPG';
%         Ia = imread(fn_l);
%         Ib = imread(fn_r);
%         load church.mat;      
        

%         fn_l = 'fox1.JPG';
%         fn_r = 'fox2.JPG';
%         Ia = imread(fn_l);
%         Ib = imread(fn_r);
%         load fox_1_2.mat;

%%

if size(Ia,3)==1
    Ia = repmat(Ia,[1,1,3]);
end
if size(Ib,3)==1
    Ib = repmat(Ib,[1,1,3]);
end

[wa,ha,~] = size(Ia);
[wb,hb,~] = size(Ib);
maxw = max(wa,wb);maxh = max(ha,hb);
Ib(wb+1:maxw, :,:) = 0;
Ia(wa+1:maxw, :,:) = 0;
Xt = X';Yt = Y';
[N,~] = size(X);
close all

%%
preserve = 1:size(Xt,2);
ifinlier = zeros(N,1);
ifinlier(CorrectIndex) = 1;
groundTruth = ifinlier;
%% 提取领域特征
Klist=[2,3,4, 5,6,7,...
       8,9,10,11,12,...
       13,15,18,20,25,...
       ];
x=[];y=[];
% [feature]=NFCnew(Xt,Yt,Klist);
[feature]=MPC(Xt,Yt,Klist);
x=[x;feature];y=[y;groundTruth];

%% Test By SVM
% load ('svmStruct.mat')
% testVal = svmclassify(svmStruct,x);
% ind     = find( testVal==1 );
%% TEST by Random Forest
% load('RF.mat');
% [Predict_label,Scores] = predict(Mdl, x);
% testVal = Scores(:,1) <= Scores(:,2);
% ind = find( testVal==1 );
%% Test By BPNN

load('Net.mat')
testVal0 = net(x.').';
testVal = testVal0(:,1) >testVal0(:,2);
ind = find( testVal==1 );

%% results
Running_time=toc;
[inlier_num,inlierRate,precision_rate,Recall_rate]=evaluatePR(X,CorrectIndex,ind);
f1=2*precision_rate*Recall_rate./(precision_rate+Recall_rate);
[FP,FN] = plot_matches(Ia, Ib, X, Y, ind, CorrectIndex);
plot_4c(Ia,Ib,X,Y,ind,CorrectIndex);

disp('********* Test Results ************')
fprintf('Inlier_Rate   = %.4f\n',inlierRate);
fprintf('Precision_Rate= %.4f\n',precision_rate);
fprintf('Recall_Rate   = %.4f\n',Recall_rate);
fprintf(['Running_Time  = %.4f','ms\n'],Running_time*1000);
disp('***********************************')
