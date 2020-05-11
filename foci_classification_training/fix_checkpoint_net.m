clc;clear all;close all force;
addpath('utils')
addpath('3DNucleiSegmentation_training')

load('names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names={names(:).name};

gpu=1;






volLoc='../tmp/train';
volds_train = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData,'LabelSource','foldernames','IncludeSubfolders',1);



volLoc='../tmp/test';
volds_val = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData_test,'LabelSource','foldernames','IncludeSubfolders',1);





% load('velke_aug_norm_net_checkpoint__8360__2020_01_14__17_52_49.mat')
load('velke_aug_nonorm_net_checkpoint__19000__2020_01_15__13_39_47.mat')


net=layerGraph(net);

checkpointPath='../tmp3';
mkdir(checkpointPath);
miniBatchSize=64;

options = trainingOptions('sgdm', ...
    'MaxEpochs',1, ...
    'InitialLearnRate',1e-12, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',0.1, ...
    'L2Regularization', 1e-8, ...
    'Shuffle', 'every-epoch', ...
    'CheckpointPath',checkpointPath,...
    'ValidationData',volds_val, ...
    'Plots','training-progress', ...
    'ValidationFrequency',10, ...
    'MiniBatchSize',miniBatchSize);



[net,info] = trainNetwork(volds_train,net,options);

% print('nonorm', '-depsc' ) 
% print('nonorm', '-dpng' ) 
% savefig('nonorm.fig' )


% save('fix_velke_aug_norm_net_checkpoint__8360__2020_01_14__17_52_49.mat','net')
save('fix_velke_aug_nonorm_net_checkpoint__19000__2020_01_15__13_39_47.mat','net')


