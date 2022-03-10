clc;clear all;close all force;
addpath('../utils')
% 
% 
% %% setup
% rng(42)
% paralel_load = 1;
% 
% 
% 
% 
% 
% data_path = '../../data_zenodo/part1_resaved/nucleus_segmentation';
% data_path = dir(data_path).folder; % convert to absolute path - requered for loading
% 
% model_name = 'segmentation_model';
% 
% 
% tmp_folder = ['../../data_zenodo/tmp_' model_name];
% mkdir(tmp_folder)
% tmp_folder = dir(tmp_folder).folder; % convert to absolute path - requered for loading
% 
% 
% img_size=[505  681   48]; % define image size
% 
% % patchSize = [96 96 48];
% patchSize = [64 64 48];
% patchPerImage = 1;
% miniBatchSize = 4;
% % miniBatchSize = 8;
% 
% learnRate = 0.001;
% learnRateMult = 0.1;
% stepEpoch = [2,3];
% 
% matReaderData = @(x) matReader(x,'data',data_path,tmp_folder,img_size);
% matReaderMask = @(x) matReader(x,'mask',data_path,tmp_folder,img_size);
% 
% 
% % get names of all imgs and masks
% img_names = subdir([data_path '/*data_*.mat']);
% img_names = {img_names(:).name};
% 
% 
% 
% in_layers = 3;
% out_layers = 1;
% 
% 
% %% training
% 
% 
% %images are divided into 4 parts - reader can read just 1/4 of image
% img_names = cellfun(@(x) replace(x,'.mat',''),img_names,'UniformOutput',false);
% create_4_tmpfiles_for_each(img_names,data_path,tmp_folder);
% 
% tmp_path_train = [tmp_folder '/train'];
% 
% volds = imageDatastore(tmp_path_train,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
% volds_gt = imageDatastore(tmp_path_train,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
% 
% tmp_path_valid = [tmp_folder '/valid'];
% 
% volds_val = imageDatastore(tmp_path_valid,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
% volds_gt_val = imageDatastore(tmp_path_valid,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);
% 
% 
% %%%%%read test
% % img=volds_gt.readimage(22);
% % figure()
% % imshow(max(img(:,:,:,1),[],3))
% % 
% % img=volds.readimage(22);
% % figure();
% % imshow(max(img(:,:,:,1),[],3))
% % imshow5(img);
% 
% 
% patchds = randomPatchExtractionDatastore(volds,volds_gt,patchSize,'PatchesPerImage',patchPerImage);
% patchds.MiniBatchSize = miniBatchSize;
% 
% 
% patchds_val = randomPatchExtractionDatastore(volds_val,volds_gt_val,patchSize,'PatchesPerImage',patchPerImage);
% patchds.MiniBatchSize = miniBatchSize;
% 
% 
% %%%%%%%%%read test pathes
% % minibatch = patchds.readByIndex(9);
% % x = minibatch.InputImage;
% % x = x{1};
% % y = minibatch.ResponseImage;
% % y = y{1};
% % 
% % figure()
% % imshow(max(x(:,:,:,1),[],3))
% % figure()
% % imshow(max(y(:,:,:,1),[],3))
% 
% 
% 
% dsTrain = transform(patchds,@augment3dPatch);
% dsValid = transform(patchds,@augment3dPatch_valid); 
% 
% 
% disp('minibatchqueue train')
% mbq = minibatchqueue(dsTrain,...
% 'MiniBatchSize',miniBatchSize,...
% 'DispatchInBackground',paralel_load,...
% 'MiniBatchFcn',@preprocessMiniBatch,...
% 'MiniBatchFormat',{'SSSCB','SSSCB'});
% 
% disp('minibatchqueue valid')
% mbq_val = minibatchqueue(dsValid,...
% 'MiniBatchSize',miniBatchSize,...
% 'DispatchInBackground',paralel_load,...
% 'MiniBatchFcn',@preprocessMiniBatch,...
% 'MiniBatchFormat',{'SSSCB','SSSCB'});
% 
% 
% lgraph = createUnet3d([patchSize in_layers],out_layers);
% dlnet = dlnetwork(lgraph);
% 
% 
% figure();
% lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
% lineLossValid = animatedline('Color',[0 0.4470 0.7410]);
% ylim([0 inf])
% xlabel("Iteration")
% ylabel("Loss")
% grid on
% 
% 
% 
% 
% %     stepEpoch = [10 13 15];
% numEpochs = stepEpoch(end);
% 
% gradDecay = 0.9;
% sqGradDecay = 0.999;
% epsilon = 1e-8;
% plot_train_freq = 40;
% valid_freq = round(2 * patchds.NumObservations/miniBatchSize);
% 
% iteration = 0;
% start = tic;
% averageGrad = [];
% averageSqGrad = [];
% losses_train = [];
% 
% 
% grad_fcn = @modelGradients;
% 
% disp('start training')
% 
% % Loop over epochs.
% for epoch = 1:numEpochs
%     
%     if any(epoch == stepEpoch)
%         learnRate = learnRate*learnRateMult;
%     end
%     
%     % Shuffle data.
%     shuffle(mbq);
% 
%     % Loop over mini-batches.
%     while hasdata(mbq)
%         
%         iteration = iteration + 1;
%         disp(iteration)
%         
%         % Read mini-batch of data.
%         [dlX, dlY] = next(mbq);
%         
%         [gradients,state,loss] = dlfeval(grad_fcn,dlnet,dlX,dlY);
%         dlnet.State = state;
% 
%         [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration,learnRate,gradDecay,sqGradDecay);
%         
%         loss = double(gather(extractdata(loss)));
%         
%         losses_train = [losses_train,loss];
%         
%         
%         
%         if mod(iteration,plot_train_freq) == 0
%             
%             
%             D = duration(0,0,toc(start),'Format','hh:mm:ss');
%             addpoints(lineLossTrain,iteration,mean(losses_train))
%             title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
%             drawnow
%             
%             losses_train = [];
%         end
%         
%         
%         if mod(iteration,valid_freq) == 0 || iteration==1
%             
%             shuffle(mbq_val);
% 
%             % Loop over mini-batches.
%             losses_valid = [];
%             while hasdata(mbq_val)
%                 
%                 tic
%                 [dlX, dlY] = next(mbq_val);
%                 toc
%                 
%                 [dlYPred,state] = forward(dlnet,dlX);
%                 loss = dicePixelClassificationLoss(dlYPred,dlY);
% 
%                 loss = double(gather(extractdata(loss)));
%                 
%                 losses_valid = [losses_valid,loss]; 
%             end
%             
%             
%             D = duration(0,0,toc(start),'Format','hh:mm:ss');
%             addpoints(lineLossValid,iteration,mean(losses_valid))
%             title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
%             drawnow
% 
%             
%         end
%         
%     end
% 
% end
% 
% 
% save('tmp.mat')

load('tmp.mat')


%% evaluate valid data

tmp_folder_valid_results = [tmp_folder '_valid_results'];

files_valid = subdir([data_path '/valid']);
files_valid = {files_valid(:).name};
files_valid = cellfun(@(x) [x '0'], files_valid,UniformOutput=false);

files_valid_result = {};
for file_num = 1:length(files_valid)
    
    disp(['evaluation valid  '  num2str(file_num)  '/' num2str(length(files_valid))])
    
    file  = files_valid{file_num};
    data = matReaderData(file);

    mask_predicted = predict_by_parts(data,out_layers,dlnet,patchSize);
    
    results_name = replace( norm_path(file), norm_path(data_path), norm_path(tmp_folder_valid_results));

    results_path = fileparts(results_name);
    
    results_name = [results_path '/result.mat'];
    
    mkdir(results_path)
    
    save(results_name,'mask_predicted')
    
    files_valid_result = [files_valid_result,results_name];
end


