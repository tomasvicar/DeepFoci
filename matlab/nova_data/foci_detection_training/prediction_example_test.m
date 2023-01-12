clc;clear all;close all;
addpath('../utils')


names_53BP1 = {...
%     "C:/Data/Vicar/foky_final_cleaning/FOR ANALYSIS/Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení_resaved_labeled/RAD51 + gH2AX/FB_1,25 Gy_24h PI pěkné/rawdata/0004/data_RAD51.tif",
    "C:/Data/Vicar/foky_final_cleaning/FOR ANALYSIS/Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení_resaved_labeled/RAD51 + gH2AX/FB_1,25 Gy_24h PI pěkné/rawdata/0017/data_RAD51.tif",
    };


results_folder = '../tmp';
mkdir(results_folder)


resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;  %image is normalized into this percentile range
patchSize = [96 96 48];

minimal_nuclei_size = 10000;
minimal_hole_size = 10000;
mask_dilatation=[14 14 5];
h=2;


MinDiversity = 0.1;
MaxVariation = 0.95;
Delta = 1;
MinArea = 8;
MaxArea = 1000;



%% load nets

dlnet_detection = load('../foci_detection_training/detection_model_rad51.mat');
parameters_detection = dlnet_detection.optimal_params;
dlnet_detection = dlnet_detection.dlnet;
outputs_detection_chanels = {'points_RAD51','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

filenames.imgs_53BP1 = names_53BP1;
filenames.imgs_gH2AX = cellfun(@(x) replace(x,'53BP1','gH2AX'),filenames.imgs_53BP1,'UniformOutput',false);
filenames.imgs_DAPI = cellfun(@(x) replace(x,'53BP1','DAPI'),filenames.imgs_53BP1,'UniformOutput',false);

for img_num = 1:length(filenames.imgs_53BP1)

    fields = fieldnames(filenames);

    data_all = {};
    for field_num = 1:length(fields)
        field = fields{field_num};

        img_filename = filenames.(field){img_num};

        data = single(imread(img_filename));

        img_size = size(data);

        data = imresize3(data,resized_img_size);

        data = norm_percentile_nocrop(data,normalization_percentile);
        
        data_all = [data_all,data];
    end


    data = cat(4,data_all{:});
    data_all = [];

   
    %% IRIF detection
    predicted_detection = predict_by_parts(data(:,:,:,1:2),3,dlnet_detection,patchSize);

    detected_points_all = struct();
    binary_detection_all = struct();
    for out_chanel_index = 1:length(outputs_detection_chanels)
        params = parameters_detection.(outputs_detection_chanels{out_chanel_index});
        detected_points = detect(predicted_detection(:,:,:,out_chanel_index),params.T,params.h,params.d);
        detected_points_all.(outputs_detection_chanels{out_chanel_index}) = detected_points;

        
        binary_detection = false(size(data,[1,2,3]));
        binary_detection(sub2ind(size(data,[1,2,3]),...
            detected_points(:,2),...
            detected_points(:,1),...
            detected_points(:,3))) = true;
        
        binary_detection_all.(outputs_detection_chanels{out_chanel_index}) = binary_detection;
    end

    
    
    

    figure;
    imshow(squeeze(max(data,[],3))+0.5) ;
    hold on
    for out_chanel_index = 1:3
        detected_points=detected_points_all.(outputs_detection_chanels{out_chanel_index});
        plot(detected_points(:,1),detected_points(:,2),'*')
    end
    drawnow;


end