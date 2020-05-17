clc;clear all;close all force;
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

load('../names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
% names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names={names(:).name};


gpu=1;
data_tmp_dir='../../tmp_img_norm_small';
checkpointPath='../../tmp2';


% 
% 
% try
%     
%     rmdir(data_tmp_dir, 's')
% catch
%     
% end
% 
% 
% mkdir(data_tmp_dir)
% mkdir([data_tmp_dir '/train'])
% mkdir([data_tmp_dir '/test'])
% mkdir([data_tmp_dir '/train/0'])
% mkdir([data_tmp_dir '/train/1'])
% mkdir([data_tmp_dir '/test/0'])
% mkdir([data_tmp_dir '/test/1'])
% 
% 
% train_counter=0;
% test_counter=0;
% 
% for img_num=1:300
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
% %     save_features=strrep(name,'3D_','features_window2_');
%     save_features=strrep(save_features,'.tif','.mat');
%     
%     features_norm_vals=strrep(name,'3D_','features_norm_vals_');
%     features_norm_vals=strrep(features_norm_vals,'.tif','.mat');
%     
%     
%     
%     load(save_manual_label)
%     
%     load(save_features)
%     
%     
%     load(features_norm_vals)
%     
%     if img_num<240
%         
%         for k=1:length(widnowa)
%             train_counter=train_counter+1;
%             
%             normA=norm_vals.globalA(k);
%             normB=norm_vals.globalB(k);
%             normA=normA{1};
%             normB=normB{1};
%             
%             wa=(widnowa{k}-normA(1))/(normA(2)-normA(1));
%             
%             wb=(widnowb{k}-normB(1))/(normB(2)-normB(1));
%             
%             window_k=cat(4,wa,wb);
%             
%             save([data_tmp_dir '/train/' num2str(labels(k)) '/' num2str(train_counter,'%06.f') '.mat'],'window_k')
%             
%             
%         end
%         
%     else
%         for k=1:length(widnowa)
%             test_counter=test_counter+1;
%             
%             
%             normA=norm_vals.globalA(k);
%             normB=norm_vals.globalB(k);
%             normA=normA{1};
%             normB=normB{1};
%             
%             wa=(widnowa{k}-normA(1))/(normA(2)-normA(1));
%             
%             wb=(widnowb{k}-normB(1))/(normB(2)-normB(1));
%             
%             window_k=cat(4,wa,wb);
%             
%             
%             save([data_tmp_dir '/test/' num2str(labels(k)) '/' num2str(test_counter,'%06.f') '.mat'],'window_k')
%             
%         end
%     end
%     
%     
% end
% 




volLoc=[data_tmp_dir '/train'];
volds_train = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData,'LabelSource','foldernames','IncludeSubfolders',1);



volLoc=[data_tmp_dir '/test'];
volds_val = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderData_test,'LabelSource','foldernames','IncludeSubfolders',1);




filters1=12;
filters2=24;
filters3=36;
layers = [
    image3dInputLayer([64 64 16 2],'Normalization','none','Name','input')
    
    convolution3dLayer(3,filters1,'Padding','same','Name','c11')
    reluLayer('Name','relu11')
    batchNormalizationLayer('Name','bn11')
    convolution3dLayer(3,filters1,'Padding','same','Name','c12')
    reluLayer('Name','relu12')
    batchNormalizationLayer('Name','bn12')
    convolution3dLayer(3,filters1,'Padding','same','Name','c13')
    reluLayer('Name','relu13')
    batchNormalizationLayer('Name','bn13')
    additionLayer(2,'Name','add1')
    
    maxPooling3dLayer(2,'Stride',2,'Name','pool1')
    
    convolution3dLayer(3,filters2,'Padding','same','Name','c21')
    reluLayer('Name','relu21')
    batchNormalizationLayer('Name','bn21')
    convolution3dLayer(3,filters2,'Padding','same','Name','c22')
    reluLayer('Name','relu22')
    batchNormalizationLayer('Name','bn22')
    convolution3dLayer(3,filters2,'Padding','same','Name','c23')
    reluLayer('Name','relu23')
    batchNormalizationLayer('Name','bn23')
    additionLayer(2,'Name','add2')
    
    maxPooling3dLayer(2,'Stride',2,'Name','pool2')
    
   
    convolution3dLayer(3,filters3,'Padding','same','Name','c31')
    reluLayer('Name','relu31')
    batchNormalizationLayer('Name','bn31')
    convolution3dLayer(3,filters3,'Padding','same','Name','c32')
    reluLayer('Name','relu32')
    batchNormalizationLayer('Name','bn32')
    convolution3dLayer(3,filters3,'Padding','same','Name','c33')
    reluLayer('Name','relu33')
    batchNormalizationLayer('Name','bn33')
    additionLayer(2,'Name','add3')
    
%     maxPooling3dLayer(2,'Stride',2,'Name','pool3')
    
    convolution3dLayer(3,filters3,'Padding','same','Name','cxx')
    
    fullyConnectedLayer(100,'Name','fc1')
    reluLayer('Name','relufc1')
%     dropoutLayer(0.5,'Name','dofc1')
    fullyConnectedLayer(100,'Name','fc2')
    reluLayer('Name','relufc2')
    fullyConnectedLayer(2,'Name','fc3')
    softmaxLayer('Name','sm')
    classificationLayer('Name','class')];

layers=layerGraph(layers);
layers = connectLayers(layers,'bn11','add1/in2');
layers = connectLayers(layers,'bn21','add2/in2');
layers = connectLayers(layers,'bn31','add3/in2');
% layers = connectLayers(layers,'pool3','add4/in2');





mkdir(checkpointPath);
miniBatchSize=64;


options = trainingOptions('adam', ...
    'MaxEpochs',28, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',12, ...
    'LearnRateDropFactor',0.1, ...
    'SquaredGradientDecayFactor',0.99, ...
    'L2Regularization', 1e-8, ...
    'Shuffle', 'every-epoch', ...
    'CheckpointPath',checkpointPath,...
    'ValidationData',volds_val, ...
    'Plots','training-progress', ...
    'GradientThreshold',3,...
    'GradientThresholdMethod','l2norm',...
    'GradientDecayFactor',0.9, ...
    'ValidationFrequency',200, ...
    'MiniBatchSize',miniBatchSize);



[net,info] = trainNetwork(volds_train,layers,options);

% print('nonorm', '-depsc' ) 
% print('nonorm', '-dpng' ) 
% savefig('nonorm.fig' )
save('global_norm_net_small_grow_add.mat','net','info')
