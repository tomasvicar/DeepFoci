clc;clear all;close all force;
addpath('../utils')

    
rng(42)

data_path='../../data_u87_nhdf_resaved_for_training';
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
    
    
    mbq = minibatchqueue(dsTrain,...
    'MiniBatchSize',miniBatchSize,...
    'MiniBatchFcn',@preprocessMiniBatch,...
    'MiniBatchFormat',{'SSSCB','SSSCB'});
    

    mbq_val = minibatchqueue(patchds_val,...
    'MiniBatchSize',miniBatchSize,...
    'MiniBatchFcn',@preprocessMiniBatch,...
    'MiniBatchFormat',{'SSSCB','SSSCB'});
    

    
    lgraph = createUnet3d([patchSize in_layers],out_layers);
    dlnet = dlnetwork(lgraph);
    

    figure();
    lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
    lineLossValid = animatedline('Color',[0 0.4470 0.7410]);
    ylim([0 inf])
    xlabel("Iteration")
    ylabel("Loss")
    grid on


    numEpochs = 10;
    learnRate = 0.001;
    gradDecay = 0.9;
    sqGradDecay = 0.999;
    epsilon = 1e-8;
    plot_train_freq = 10;
    valid_freq = round(0.5 * patchds.NumObservations/miniBatchSize);
    
    iteration = 0;
    start = tic;
    averageGrad = [];
    averageSqGrad = [];
    losses_train = [];

    % Loop over epochs.
    for epoch = 1:numEpochs
        % Shuffle data.
        shuffle(mbq);

        % Loop over mini-batches.

        while hasdata(mbq)
            
            iteration = iteration + 1;
            disp(iteration)
            
            % Read mini-batch of data.
            [dlX, dlY] = next(mbq);
            [gradients,state,loss] = dlfeval(@modelGradients,dlnet,dlX,dlY);
            dlnet.State = state;

            
            
            [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration,learnRate,gradDecay,sqGradDecay);
            
            loss = double(gather(extractdata(loss)));
            
            losses_train = [losses_train,loss];
            
            
            if mod(iteration,plot_train_freq) == 0 || iteration==1
                
                
                D = duration(0,0,toc(start),'Format','hh:mm:ss');
                addpoints(lineLossTrain,iteration,mean(losses_train))
                title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
                drawnow
                
                losses_train = [];
            end
            
            
            if mod(iteration,valid_freq) == 0 || iteration==1
                
                shuffle(mbq_val);

                % Loop over mini-batches.
                losses_valid = [];
                while hasdata(mbq_val)
                    
                    [dlX, dlY] = next(mbq_val);
                    
                    [dlYPred,state] = forward(dlnet,dlX);
                    loss = MSEpixelLoss(dlYPred,dlY);

                    loss = double(gather(extractdata(loss)));
                    
                    losses_valid = [losses_valid,loss]; 
                end
                
                
                D = duration(0,0,toc(start),'Format','hh:mm:ss');
                addpoints(lineLossValid,iteration,mean(losses_valid))
                title("Epoch: " + epoch + ", Elapsed: " + string(D) + '  , iteration per epoch: ' + round(patchds.NumObservations/miniBatchSize) )
                drawnow

                
            end
            
        end

    end


    
    
    break;

end