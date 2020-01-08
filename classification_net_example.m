clc;clear all;close all force;
% addpath('utils')
% addpath('3DNucleiSegmentation_training')
% 
% load('names_foci_sample.mat')
% names_orig=names;
% 
% % names=subdir('..\example_folder\*3D_*.tif');
% % names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% % names=subdir('F:\example_folder\*3D_*.tif');
% names={names(:).name};
% 
% gpu=1;
% 
% 
% 
% 
% 
% try
%     
%     rmdir('../tmp', 's')
% catch
%     
% end
% 
% 
% mkdir('../tmp')
% mkdir('../tmp/train')
% mkdir('../tmp/test')
% mkdir('../tmp/train/0')
% mkdir('../tmp/train/1')
% mkdir('../tmp/test/0')
% mkdir('../tmp/test/1')
% 
% 
% train_counter=0;
% test_counter=0;
% 
% for img_num=1:170
%     
%     img_num
%     
%     name=names{img_num};
%     
%     name_orig=names_orig{img_num};
%     
%     name_mask=strrep(name,'3D_','mask_');
%     mask_name_split=strrep(name,'3D_','mask_split');
%     
%     
%     name_mask_foci=strrep(name,'3D_','mask_foci_');
%     
%     
%     save_control_seg=strrep(name,'3D_','control_seg_foci');
%     save_control_seg=strrep(save_control_seg,'.tif','');
%     
%     save_manual_label=strrep(name,'3D_','manual_label_');
%     save_manual_label=strrep(save_manual_label,'.tif','.mat');
%     
%     
%     save_features=strrep(name,'3D_','features_window_');
%     save_features=strrep(save_features,'.tif','.mat');
%     
%     
%     
%     
%     load(save_manual_label)
%     
%     load(save_features)
%     
%     if img_num<120
%         
%         for k=1:length(widnowa)
%             train_counter=train_counter+1;
%             
%             window_k=cat(4,widnowa{k},widnowb{k});
%             
%             save(['../tmp/train/' num2str(labels(k)) '/' num2str(train_counter,'%06.f') '.mat'],'window_k')
%             
%             
%         end
%         
%     else
%         for k=1:length(widnowa)
%             test_counter=test_counter+1;
%             
%             window_k=cat(4,widnowa{k},widnowa{k});
%             
%             save(['../tmp/test/' num2str(labels(k)) '/' num2str(test_counter,'%06.f') '.mat'],'window_k')
%             
%         end
%     end
%     
%     
% end
% 




volLoc='../tmp/train';
volds_train = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData,'LabelSource','foldernames','IncludeSubfolders',1);



volLoc='../tmp/train';
volds_val = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData,'LabelSource','foldernames','IncludeSubfolders',1);


% max_val=-Inf;
% min_val=Inf;
% for k=1:5000
%     [data,info]=read(volds_train);
% 
%     if max_val<max(data(:))
%         max_val=max(data(:));
%     end
%     if min_val>min(data(:))
%         min_val=min(data(:));
%     end
%     
% end
% 
% min_val
% max_val





% countEachLabel(volds_train)

filters=16;
layers = [
    image3dInputLayer([64 64 16 2],'Normalization','none')
    
    convolution3dLayer(3,filters,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters,'Padding','same')
    reluLayer
    batchNormalizationLayer
    
    maxPooling3dLayer(2,'Stride',2)
    
   
    convolution3dLayer(3,filters*2,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters*2,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters*2,'Padding','same')
    reluLayer
    batchNormalizationLayer
    
    
    maxPooling3dLayer(2,'Stride',2)
    
    
    convolution3dLayer(3,filters*4,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters*4,'Padding','same')
    reluLayer
    batchNormalizationLayer
    convolution3dLayer(3,filters*4,'Padding','same')
    reluLayer
    batchNormalizationLayer
    
    
    fullyConnectedLayer(2)
    reluLayer
    softmaxLayer
    classificationLayer];


checkpointPath='../tmp2';
mkdir(checkpointPath);
miniBatchSize=128;


options = trainingOptions('adam', ...
    'MaxEpochs',13, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',4, ...
    'LearnRateDropFactor',0.1, ...
    'Plots','training-progress', ...
    'GradientDecayFactor',0.9, ...
    'SquaredGradientDecayFactor',0.99, ...
    'L2Regularization', 1e-8, ...
    'Shuffle', 'every-epoch', ...
    'CheckpointPath',checkpointPath,...
    'ValidationData',volds_train, ...
    'ValidationFrequency',500, ...
    'GradientThreshold',3,...
    'GradientThresholdMethod','l2norm',...
    'MiniBatchSize',miniBatchSize);



[net,info] = trainNetwork(volds_train,layers,options);




