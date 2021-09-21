clc;clear all;close all force;
addpath('../utils')

    
rng(42)

data_path='D:\vicar\foci_new\data_u87_nhdf_resaved_for_training';

folds = 5;

matReaderData = @(x) matReader(x,'data',{'a','b','c'},'norm_perc');
in_layers = 3;
matReaderMask = @(x) matReader(x,'mask',{'a','b'},'norm_no');
out_layers = 2;

files = subdirx([data_path '/*data_53BP1.mat']);





for fold = 1:folds

    [files_test,files_train_valid] = subfolder_based_split(files,fold,folds);
    
    [files_valid,files_train] = subfolder_based_split(files_train_valid,1,6);
   
    
    
    
    
    

    volds = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
    volds = create_4_for_each(volds,files_train,data_path);

    volds_gt = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
    volds_gt = create_4_for_each(volds_gt,files_train,data_path);

    volds_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
    volds_val = create_4_for_each(volds_val,files_valid,data_path);

    volds_gt_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
    volds_gt_val = create_4_for_each(volds_gt_val,files_valid,data_path);


    
    
%     img=volds_gt.readimage(22);
% %     imshow5(img);
%     figure()
%     imshow(max(img(:,:,:,1),[],3))
%     
% 
%     img=volds.readimage(22);
% %     imshow5(img);
%     figure();
%     imshow(max(img(:,:,:,1),[],3))
    

    % patchSize = [128 128 48];
    patchSize = [96 96 48];
    patchPerImage = 1;
    miniBatchSize = 8;
    patchds = randomPatchExtractionDatastore(volds,volds_gt,patchSize,'PatchesPerImage',patchPerImage);
    patchds.MiniBatchSize = miniBatchSize;


    patchds_val = randomPatchExtractionDatastore(volds_val,volds_gt_val,patchSize,'PatchesPerImage',patchPerImage);
    patchds.MiniBatchSize = miniBatchSize;



%     minibatch = patchds.readByIndex(66);
%     x = minibatch.InputImage;
%     x = x{1};
%     y = minibatch.ResponseImage;
%     y = y{1};
% 
%     figure()
%     imshow(max(x(:,:,:,1),[],3))
%     figure()
%     imshow(max(y(:,:,:,1),[],3))


    dsTrain = transform(patchds,@augment3dPatch);

    
    lgraph = createUnet3d([patchSize in_layers],out_layers);



    checkpointPath='../../cpt';
    mkdir(checkpointPath)

    
    options = trainingOptions('adam', ...
        'MaxEpochs',10, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',5, ...
        'LearnRateDropFactor',0.1, ...
        'Plots','training-progress', ...
        'GradientDecayFactor',0.9, ...
        'SquaredGradientDecayFactor',0.99, ...
        'L2Regularization', 1e-6, ...
        'Shuffle', 'every-epoch', ...
        'CheckpointPath',checkpointPath,...
        'ValidationData',patchds_val, ...
        'ValidationFrequency',round(patchds.NumObservations/miniBatchSize), ...
        'MiniBatchSize',miniBatchSize);

    disp('train_start')
    [net,info] = trainNetwork(dsTrain ,lgraph,options);


    save('net_test0.mat','net','info')



    break;

end