clc;clear all;close all force;
addpath('../utils')

    
rng(42)

data_path='C:\Users\vicar\Desktop\foky_new_tmp\data_resave';

folds = 4;

matReaderData = @(x) matReader(x,'data',{'a','b','c'});
matReaderMask = @(x) matReader(x,'mask',{'a','b'});

files = subdirx([data_path '/*data_53BP1.mat']);
perm = randperm(length(files));


for cv_index = 1:folds

    N = length(perm);
    tmp = 1+round(N/folds*(cv_index-1)):round(N/folds*(cv_index));
    train_valid_ind = perm(tmp);
    test_ind = perm;
    test_ind(tmp) = [];
    tmp = 1:round(length(train_valid_ind)*0.9);
    train_ind = train_valid_ind(tmp);
    valid_ind = train_valid_ind;
    valid_ind(tmp) = [];

    volds = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
    volds = create_4_for_each(volds,files(train_ind),data_path);

    volds_gt = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
    volds_gt = create_4_for_each(volds_gt,files(train_ind),data_path);

    volds_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
    volds_val = create_4_for_each(volds_val,files(valid_ind),data_path);

    volds_gt_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
    volds_gt_val = create_4_for_each(volds_gt_val,files(valid_ind),data_path);


    
    
    % img=volds_gt.readimage(2);
    % imshow5(img);


    % patchSize = [128 128 48];
    patchSize = [96 96 48];
    patchPerImage = 2;%%%%%%%%
    miniBatchSize = 8;
    patchds = randomPatchExtractionDatastore(volds,volds_gt,patchSize,'PatchesPerImage',patchPerImage);
    patchds.MiniBatchSize = miniBatchSize;


    patchds_val = randomPatchExtractionDatastore(volds_val,volds_gt_val,patchSize,'PatchesPerImage',patchPerImage);
    patchds.MiniBatchSize = miniBatchSize;



    drawnow;
    minibatch = patchds.readByIndex(1);
    
    
    

    % for k=1:5:30
    % 
    %     
    %     minibatch = patchds.readByIndex(k);
    %     inputs = minibatch.InputImage;
    %     responses = minibatch.ResponseImage;
    % 
    %     i=inputs{1};
    %     r=responses{1};
    %     
    % %     rr=repmat(r,[1,1,1,3]);
    % 
    %     imshow5(cat(2,i+0.5,r*30))
    %     drawnow;
    % end


    dsTrain = transform(patchds,@augment3dPatch);

    lgraph = createUnet3d([patchSize 3]);



    checkpointPath='../../cpt';
    mkdir(checkpointPath)



    options = trainingOptions('adam', ...
        'MaxEpochs',7, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',3, ...
        'LearnRateDropFactor',0.1, ...
        'Plots','training-progress', ...
        'GradientDecayFactor',0.9, ...
        'SquaredGradientDecayFactor',0.99, ...
        'L2Regularization', 1e-8, ...
        'Shuffle', 'every-epoch', ...
        'CheckpointPath',checkpointPath,...
        'ValidationData',patchds_val, ...
        'ValidationFrequency',300, ...
        'MiniBatchSize',miniBatchSize);

    disp('train_start')
    [net,info] = trainNetwork(dsTrain ,lgraph,options);


    save('test3_value_aug_mult.mat','net','info')





end