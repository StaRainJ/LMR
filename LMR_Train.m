clear ;
close all;
initialization;  % run it only at the first time
addpath('trainingData');
x=[];y=[];
%% ******** Training Set Construction **********************
tic;
  for j=1:10 
[CorrectIndex,X,Y]=LoadTrainData(j);% Import putative matches and groundtruth

x1 = X; y1 = Y;
[N,~] = size(x1);
Xt = X';Yt = Y';
preserve = 1:size(Xt,2);
ifinlier = zeros(N,1);
ifinlier(CorrectIndex) = 1;
groundTruth = ifinlier;

% % %  Match Representations Construction 
Klist = [2,3,4, 5,6,7,...
         8,9,10,11,12,...
         13,15,18,20,25,...
        ];
[feature] = MPC(Xt,Yt,Klist);
 x = [x;feature];
 y = [y;groundTruth];
  end
inlierNum  = length(find(y==1)) ; 
outlierNum = length(y)-inlierNum;
fprintf('The Number of Inlier is£º%d\n',inlierNum);
fprintf('The Number of Outlier is£º%d\n',outlierNum);

%% ******* Training *************
%% using Random Forest

% Mdl = TreeBagger(20, x, y,'Method','classification');%,'OOBPrediction','On'
% [Predict_label,Scores] = predict(Mdl, x);
% trainValue = Scores(:,1) <= Scores(:,2);
%  view(Mdl.Trees{1},'Mode','graph');
%  save ./Trained_Model/RFnew Mdl

%% using SVM
%     options.MaxIter=50000;
%     
%     svmStruct = svmtrain(x,y,'Options', options,'Kernel_Function','linear','boxconstraint',1,'method','SMO');
% %   svmStruct = svmtrain(x,y,'Options', options,'Kernel_Function','rbf','RBF_Sigma',0.2,'boxconstraint',1,'method','SMO','kktviolationlevel',0);   
% 
%     trainValue = svmclassify(svmStruct,x);
%     save ./Trained_Model/svmStructNew svmStruct;
%% using BPNN

A = zeros(size(x,2),2);
B = [48 10 2];
A(:,1) = 0;
A(:,2) = 1;
net = newff(A,B,{'tansig','tansig','logsig'},'trainscg');
yy  = [y, 1-y];
net.trainParam.epochs   = 5000;            
net.trainParam.min_grad = 1e-5;
net = train(net,x',yy','useParallel','yes');

trainValue = net(x.').';
trainValue = trainValue(:,1) > trainValue(:,2);
save ./Trained_Model/NETnew  net

%% training results 
% % % %ÑµÁ·Îó²î
train_error     = y-trainValue;
train_num_error = sum(abs(train_error));
train_correct_rate = 1 - train_num_error / length(trainValue);
toc
disp('Number of training errors:');
disp(train_num_error);
disp('Training accuracy:');
disp(train_correct_rate);
% run LMR_Test
