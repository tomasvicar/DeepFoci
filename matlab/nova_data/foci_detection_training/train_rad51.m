clc;clear all;close all force;
addpath('../utils')


%% setup
rng(42)
paralel_load = 1;




data_path = 'C:/Data/Vicar/foky_final_cleaning/data_rad51_resaved';
data_path = dir(data_path).folder; % convert to absolute path - requered for loading

model_name = 'detection_model_rad51';


tmp_folder = ['C:/Data/Vicar/foky_final_cleaning/data_rad51_tmpmodels/tmp_' model_name];
mkdir(tmp_folder)
tmp_folder = dir(tmp_folder).folder; % convert to absolute path - requered for loading


data_chanels = {'imgs_53BP1','imgs_gH2AX'}; %define image channels to read
mask_chanels = {'points_RAD51','points_gH2AX','points_53BP1_gH2AX_overlap'}; %define mask channels to read

img_size=[505  681   48]; % define image size

patchSize = [96 96 48];
% patchSize = [64 64 48];
patchPerImage = 1;
% miniBatchSize = 4;
miniBatchSize = 8;
% miniBatchSize = 12;

learnRate = 0.001;
learnRateMult = 0.1;
% stepEpoch = [5 8 10];
stepEpoch = [25 35 40];


tmp_path_train = [tmp_folder '/train'];
tmp_path_valid = [tmp_folder '/valid'];

matReaderData = @(x) matReader(x,'data',data_chanels,data_path,tmp_path_train,img_size);
matReaderMask = @(x) matReader(x,'mask',mask_chanels,data_path,tmp_path_train,img_size);


% get names of all folders with images
file_folders = subdir([data_path '/*imgs_53BP1.mat']);
file_folders = {file_folders(:).name};
file_folders = cellfun(@(x) replace(x,'imgs_53BP1.mat',''),file_folders,'UniformOutput',false);


traing_split_fraction = 0.75;


%% training


in_layers = length(data_chanels);
out_layers = length(mask_chanels);


train_valid_ind = randperm(length(file_folders));
tmp = 1:round(length(file_folders)*traing_split_fraction);

train_ind = train_valid_ind(tmp);
valid_ind = train_valid_ind;
valid_ind(tmp) = [];

file_folders_valid = file_folders(valid_ind);
file_folders_train = file_folders(train_ind);

mkdir(tmp_folder)



%images are divided into 4 parts - reader can read just 1/4 of image
create_4_tmpfiles_for_each(file_folders_train,data_path,tmp_path_train);
volds = imageDatastore(tmp_path_train,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
volds_gt = imageDatastore(tmp_path_train,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);


create_4_tmpfiles_for_each(file_folders_valid,data_path,tmp_path_valid);
volds_val = imageDatastore(tmp_path_valid,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderData);
volds_gt_val = imageDatastore(tmp_path_valid,'FileExtensions','.mat','IncludeSubfolders',1,'ReadFcn',matReaderMask);


%%%%%read test
% img=volds_gt.readimage(22);
% figure()
% imshow(max(img(:,:,:,1),[],3))
% 
% img=volds.readimage(22);
% figure();
% imshow(max(img(:,:,:,1),[],3))




patchds = randomPatchExtractionDatastore(volds,volds_gt,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;


patchds_val = randomPatchExtractionDatastore(volds_val,volds_gt_val,patchSize,'PatchesPerImage',patchPerImage);
patchds.MiniBatchSize = miniBatchSize;


%%%%%%%%%read test pathes
% minibatch = patchds.readByIndex(9);
% x = minibatch.InputImage;
% x = x{1};
% y = minibatch.ResponseImage;
% y = y{1};
% 
% figure()
% imshow(max(x(:,:,:,1),[],3))
% figure()
% imshow(max(y(:,:,:,1),[],3))



dsTrain = transform(patchds,@augment3dPatch);
dsValid = transform(patchds,@augment3dPatch_valid); 


disp('minibatchqueue train')
mbq = minibatchqueue(dsTrain,...
'MiniBatchSize',miniBatchSize,...
'DispatchInBackground',paralel_load,...
'MiniBatchFcn',@preprocessMiniBatch,...
'MiniBatchFormat',{'SSSCB','SSSCB'});

disp('minibatchqueue valid')
mbq_val = minibatchqueue(dsValid,...
'MiniBatchSize',miniBatchSize,...
'DispatchInBackground',paralel_load,...
'MiniBatchFcn',@preprocessMiniBatch,...
'MiniBatchFormat',{'SSSCB','SSSCB'});


% lgraph = createUnet3d([patchSize in_layers],out_layers);
% dlnet = dlnetwork(lgraph);
dlnet = load('detection_model.mat');
dlnet = dlnet.dlnet;

figure();
lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
lineLossValid = animatedline('Color',[0 0.4470 0.7410]);
ylim([0 inf])
xlabel("Iteration")
ylabel("Loss")
grid on




%     stepEpoch = [10 13 15];
numEpochs = stepEpoch(end);

gradDecay = 0.9;
sqGradDecay = 0.999;
epsilon = 1e-8;
plot_train_freq = 40;
valid_freq = round(2 * patchds.NumObservations/miniBatchSize);

iteration = 0;
start = tic;
averageGrad = [];
averageSqGrad = [];
losses_train = [];


grad_fcn = @modelGradients;

disp('start training')

% Loop over epochs.
for epoch = 1:numEpochs
    
    if any(epoch == stepEpoch)
        learnRate = learnRate*learnRateMult;
    end
    
    % Shuffle data.
    shuffle(mbq);

    % Loop over mini-batches.
    while hasdata(mbq)
        
        iteration = iteration + 1;
        disp(iteration)
        
        % Read mini-batch of data.
        [dlX, dlY] = next(mbq);
        
        [gradients,state,loss] = dlfeval(grad_fcn,dlnet,dlX,dlY);
        dlnet.State = state;

        [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration,learnRate,gradDecay,sqGradDecay);
        
        loss = double(gather(extractdata(loss)));
        
        losses_train = [losses_train,loss];
        
        
        
        if mod(iteration,plot_train_freq) == 0
            
            
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
                
                tic
                [dlX, dlY] = next(mbq_val);
                toc
                
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

save('tmp')
print([model_name '_train_curve'],'-dpng')

load("tmp.mat")

%% evaluate valid data

tmp_folder_valid_results = [tmp_folder '_valid_results'];


files_valid = file_folders_valid;
files_valid = cellfun(@(x) [x '0'], files_valid,UniformOutput=false);

files_valid_result = {};
for file_num = 1:length(files_valid)
    
    disp(['evaluation valid  '  num2str(file_num)  '/' num2str(length(files_valid))])
    
    file  = files_valid{file_num};
    data = matReaderData(file);

    predicted = predict_by_parts(data,out_layers,dlnet,patchSize);
     
    results_name = replace( norm_path(file), norm_path(data_path), norm_path(tmp_folder_valid_results));

    results_path = fileparts(results_name);
    
    results_name = [results_path '/result.mat'];
    
    mkdir(results_path)
    
    save(results_name,'predicted')
    
    files_valid_result = [files_valid_result,results_name];
end




%% postprocessing optimization

T = optimizableVariable('T',[0.6,8.5]);
h = optimizableVariable('h',[0.1,9.9]);
d = optimizableVariable('d',[2,25]);

vars = [T,h,d];
 
for evaluate_index = 1:out_layers

    fun = @(x) -evaluate_detection_all(files_valid,files_valid_result,evaluate_index,matReaderMask,x.T,x.h,x.d);

    opt_results = bayesopt(fun,vars,'NumSeedPoints',5,'MaxObjectiveEvaluations',25,'UseParallel',false);


    optimal_params.(mask_chanels{evaluate_index}) = opt_results.XAtMinObjective;


end



save([model_name '.mat'],'dlnet','optimal_params')

