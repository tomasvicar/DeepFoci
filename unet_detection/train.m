clc;clear all;close all force;
addpath('../utils')

data_path='D:\vicar\foci_foci\example_folder';



split_val=240;

volds = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',@matReaderData);
Files=volds.Files;
Files_new={};
for k=1:length(Files)
    file=Files{k};
    if contains(file,'unet_foci_detection_data')&&(str2num(file(end-37:end-34))<split_val)
       for k=1:4
           tmp=[file num2str(k)];
           Files_new=[Files_new,tmp];
           a=1;
           save(tmp,'a')
       end
    end
end
volds.Files=Files_new;


volds_gt = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',@matReaderMask);
Files=volds_gt.Files;
Files_new={};
for k=1:length(Files)
    file=Files{k};
    if contains(file,'unet_foci_detection_mask')&&(str2num(file(end-37:end-34))<split_val)
       for k=1:4
           tmp=[file num2str(k)];
           Files_new=[Files_new,tmp];
           a=1;
           save(tmp,'a')
       end
    end
end
volds_gt.Files=Files_new;


volds_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',@matReaderData);
Files=volds_val.Files;
Files_new={};
for k=1:length(Files)
    file=Files{k};
    if contains(file,'unet_foci_detection_data')&&(str2num(file(end-37:end-34))>=split_val)
       for k=1:4
           tmp=[file num2str(k)];
           Files_new=[Files_new,tmp];
           a=1;
           save(tmp,'a')
       end
    end
end
volds_val.Files=Files_new;


volds_gt_val = imageDatastore(data_path,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',@matReaderMask);
Files=volds_gt_val.Files;
Files_new={};
for k=1:length(Files)
    file=Files{k};
    if contains(file,'unet_foci_detection_mask')&&(str2num(file(end-37:end-34))>=split_val)
       for k=1:4
           tmp=[file num2str(k)];
           Files_new=[Files_new,tmp];
           a=1;
           save(tmp,'a')
       end
    end
end
volds_gt_val.Files=Files_new;



% img=volds_gt.readimage(2);
% imshow5(img);


patchSize = [128 128 48];
patchPerImage = 2;%%%%%%%%
miniBatchSize = 8;
patchds = randomPatchExtractionDatastore(volds,volds_gt,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;


patchds_val = randomPatchExtractionDatastore(volds_val,volds_gt_val,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;





 
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
    'ValidationData',patchds_val, ...
    'ValidationFrequency',500, ...
    'GradientThreshold',3,...
    'GradientThresholdMethod','l2norm',...
    'MiniBatchSize',miniBatchSize);

disp('train_start')
[net,info] = trainNetwork(dsTrain ,lgraph,options);


save('dice_rot_new.mat','net')




















