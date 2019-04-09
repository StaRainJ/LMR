function [CorrectIndex,X,Y] = LoadTrainData(j)

X = []; Y = []; CorrectIndex = [];

    if j==1 
        load wall2_1.mat;
    elseif j==2
        load wash_1.5.mat;
    elseif j==3
        load 73.mat;
    elseif j==4
        load 27_20.mat;
    elseif j==5
        load trees2_1.3.mat;
    elseif j==6
        load mex_1.mat;
    elseif j==7
        load Tshirt.mat; 
    elseif j==8
        load 5_20.mat;
    elseif j==9
        load mybook2_1.mat;
    elseif j==10
        load bottle2_1.mat;
     end