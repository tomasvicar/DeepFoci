clc;clear all;close all force;
addpath('../utils')

p = gcp('nocreate');
if isempty(p)
    parpool()
end
    
rng(42)

data_path='../../data_u87_nhdf_resaved_for_training_norm_nofilters';
folds = 5;

data_chanels = {'a','b'};
matReaderData = @(x) matReader(x,'data',data_chanels,'norm_perc');
mask_chanels = {'a','b'};
matReaderMask = @(x) matReader(x,'mask',mask_chanels,'norm_no');
model_name = 'a_b';



paralel_load = 1;


files = subdirx([data_path '/*data_53BP1.mat']);
in_layers = length(data_chanels);
out_layers = length(mask_chanels);



for fold = 1:folds
    
    tmp_folder = ['../../tmp_' model_name '_' num2str(fold)];
    mkdir(tmp_folder)
    

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
    dsValid = transform(patchds,@augment3dPatch_valid); 
    
    
%     disp('minibatchqueue train')
%     mbq = minibatchqueue(dsTrain,...
%     'MiniBatchSize',miniBatchSize,...
%     'DispatchInBackground',paralel_load,...
%     'MiniBatchFcn',@preprocessMiniBatch,...
%     'MiniBatchFormat',{'SSSCB','SSSCB'});
% 
%     disp('minibatchqueue valid')
%     mbq_val = minibatchqueue(dsValid,...
%     'MiniBatchSize',miniBatchSize,...
%     'DispatchInBackground',paralel_load,...
%     'MiniBatchFcn',@preprocessMiniBatch,...
%     'MiniBatchFormat',{'SSSCB','SSSCB'});
% 
%     
%     lgraph = createUnet3d([patchSize in_layers],out_layers);
%     dlnet = dlnetwork(lgraph);
%     
% 
%     figure();
%     lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
%     lineLossValid = animatedline('Color',[0 0.4470 0.7410]);
%     ylim([0 inf])
%     xlabel("Iteration")
%     ylabel("Loss")
%     grid on
% 
% 
%     numEpochs = 60;
%     learnRate = 0.001;
%     learnRateMult = 0.1;
%     stepEpoch = 20;
%     
%     gradDecay = 0.9;
%     sqGradDecay = 0.999;
%     epsilon = 1e-8;
%     plot_train_freq = 10;
%     valid_freq = round(0.5 * patchds.NumObservations/miniBatchSize);
%     
%     iteration = 0;
%     start = tic;
%     averageGrad = [];
%     averageSqGrad = [];
%     losses_train = [];
%     
% %     tic
% % %     grad_fcn = dlaccelerate(@modelGradients);
% % %     clearCache(grad_fcn)
% %     toc
%     grad_fcn = @modelGradients;
% 
%     disp('start training')
%     
%     % Loop over epochs.
%     for epoch = 1:numEpochs
%         
%         if mod(epoch,stepEpoch) == 0
%             learnRate = learnRate*learnRateMult;
%         end
%         
%         % Shuffle data.
%         shuffle(mbq);
% 
%         % Loop over mini-batches.
% 
%         while hasdata(mbq)
%             
%             iteration = iteration + 1;
%             disp(iteration)
%             
%             % Read mini-batch of data.
%             tic
%             [dlX, dlY] = next(mbq);
%             toc
%             
%             [gradients,state,loss] = dlfeval(grad_fcn,dlnet,dlX,dlY);
%             dlnet.State = state;
% 
%             [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration,learnRate,gradDecay,sqGradDecay);
%             
%             loss = double(gather(extractdata(loss)));
%             
%             losses_train = [losses_train,loss];
%             
% %             toc
%             
%             
%             if mod(iteration,plot_train_freq) == 0
%                 
%                 
%                 D = duration(0,0,toc(start),'Format','hh:mm:ss');
%                 addpoints(lineLossTrain,iteration,mean(losses_train))
%                 title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
%                 drawnow
%                 
%                 losses_train = [];
%             end
%             
%             
%             if mod(iteration,valid_freq) == 0 || iteration==1
%                 
%                 shuffle(mbq_val);
% 
%                 % Loop over mini-batches.
%                 losses_valid = [];
%                 while hasdata(mbq_val)
%                     
%                     tic
%                     [dlX, dlY] = next(mbq_val);
%                     toc
%                     
%                     [dlYPred,state] = forward(dlnet,dlX);
%                     loss = MSEpixelLoss(dlYPred,dlY);
% 
%                     loss = double(gather(extractdata(loss)));
%                     
%                     losses_valid = [losses_valid,loss]; 
%                 end
%                 
%                 
%                 D = duration(0,0,toc(start),'Format','hh:mm:ss');
%                 addpoints(lineLossValid,iteration,mean(losses_valid))
%                 title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
%                 drawnow
% 
%                 
%             end
%             
%         end
% 
%     end
% 
%     save('tmp_net1.mat','dlnet','files_test')
%     
%     break
    
    
%     for file_num = 1:length(files_test)
%         file  = files_test(file_num);
%         
%         
%     
%     end
    

    load('tmp_net1.mat','dlnet','files_test')
    

    for file_num = 1:length(files_test)
        
        file  = files_test{file_num};
        data = matReaderData([file num2str(0)]);
        mask = matReaderMask([file num2str(0)]);

        mask_predicted = predict_by_parts_foci_new(data,out_layers,dlnet,patchSize);

    end
    
    

    break
end