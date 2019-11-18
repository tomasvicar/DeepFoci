clc;clear all;close all force;


volLoc='D:\vicar\foci_3d_seg\trenovaci_data_preprocess/train/img';
volds = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderDataC);

lblLoc = 'D:\vicar\foci_3d_seg\trenovaci_data_preprocess/train/lbl';
classNames = ["background","cell"];
pixelLabelID = [0 1];
pxds = pixelLabelDatastore(lblLoc,classNames,pixelLabelID, 'FileExtensions','.mat','ReadFcn',@matReaderMask);



volLoc='D:\vicar\foci_3d_seg\trenovaci_data_preprocess/valid/img';
volds_val = imageDatastore(volLoc,'FileExtensions','.mat','ReadFcn',@matReaderDataC);

lblLoc = 'D:\vicar\foci_3d_seg\trenovaci_data_preprocess/valid/lbl';
classNames = ["background","cell"];
pixelLabelID = [0 1];
pxds_val = pixelLabelDatastore(lblLoc,classNames,pixelLabelID, 'FileExtensions','.mat','ReadFcn',@matReaderMask);



% tbl = countEachLabel(pxds);

% volume = preview(volds);
% label = preview(pxds);

% totalNumberOfPixels = sum(tbl.PixelCount);
% frequency = tbl.PixelCount / totalNumberOfPixels;
% classWeights = 1./frequency;

% img=pxds.readimage(2);
% im=zeros(size(img));
% im(img=="cell")=1;
% imshow4(im);


patchSize = [128 128 48];
patchPerImage = 1;
miniBatchSize = 8;
patchds = randomPatchExtractionDatastore(volds,pxds,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;

patchds_val = randomPatchExtractionDatastore(volds_val,pxds_val,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;



% asdd=patchds.read()

% patchds =pixelLabelImageDatastore(volds,pxds);



% 
% for k=1:53:10000
% 
%     
%     minibatch = patchds.readByIndex(k);
%     inputs = minibatch.InputImage;
%     responses = minibatch.ResponsePixelLabelImage;
% 
%     i=inputs{1};
%     r=responses{1};
%     rr=zeros(size(i),'like',i);
%     rr(r=="cell")=1;
% 
% %     imshow4(cat(2,i,rr))
%     imshow5(i)
%     drawnow;
% end


dsTrain = transform(patchds,@augment3dPatch);

lgraph = createUnet3d([patchSize 3]);

% lgraph = replaceLayer(lgraph,'output',weightedClassification3DLayer(classWeights,'output'));




checkpointPath='../cpt';
mkdir(checkpointPath)

% load('cpt/net_checkpoint__21008__2019_06_22__09_52_06.mat')
% lgraph=layerGraph(net);




options = trainingOptions('adam', ...
    'MaxEpochs',16, ...
    'InitialLearnRate',1e-4, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',6, ...
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


[net,info] = trainNetwork(dsTrain ,lgraph,options);


save('dice_rot_new.mat','net')




















function dataa=matReaderDataC(filename)
    load(filename);
    dataa=reshape(dataa,[128,128,48,3]);

end


function lbll=matReaderMask(filename)
    load(filename);
    lbll(lbll==2)=0;
end

% function c=augment3dPatch(data)
%     data=data;
% end




