clc;clear all;close all;
addpath('../utils')
addpath('../nuclei_segmentation_training')



data_folder = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
% data_folder = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
% data_folder = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
% data_folder = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
error_folder = split(data_folder,'\');
error_folder = error_folder{end};
mkdir(error_folder)

results_folder = [data_folder '_net_results'];

filenames = subdir([data_folder '/*01.ics']);
filenames = {filenames(:).name};
filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);



resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;  %image is normalized into this percentile range
patchSize = [96 96 48];

minimal_nuclei_size = 10000;
minimal_hole_size = 10000;
mask_dilatation=[14 14 5];
h=2;



dlnet_segmentation = load('../nuclei_segmentation_training/segmentation_model.mat','dlnet');
dlnet_segmentation = dlnet_segmentation.dlnet;
dlnet_segmentation = dlnet_segmentation.dlnet;


dlnet_detection = load('../foci_detection_training/detection_model.mat');
parameters_detection = dlnet_detection.optimal_params;
dlnet_detection = dlnet_detection.dlnet;
outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

% tmp_files = dir('*.mat');
% tmp_files = {tmp_files(:).name};
% tmp_files = cellfun(@(x) str2num(replace(x,'.mat','')),tmp_files);

for file_num = 1:length(filenames)
    try
        disp(file_num)
        disp(file_num)
        disp(file_num)
        disp(file_num)

        
    
        filename = filenames{file_num};
    
        filename_save = [results_folder, replace(filename,data_folder,'')];

%         if exist([filename_save 'nuclei_semgentaton.tif'],'file')
%             continue;
%         end

        mkdir(filename_save)


        %%%% dodelani kanalu
        name_fov_file = [filename 'fov.txt'];
        chanel_names={};
        fid = fopen(name_fov_file);
        tline = 'dfdf';
        while ischar(tline)
            if contains(tline,'Name=')
                chanel_names=[chanel_names tline(6:end)];
            end
            tline = fgetl(fid);
        end
        fclose(fid);

        if contains(lower(chanel_names{1}),'gh2ax')
            continue
        elseif contains(lower(chanel_names{2}),'gh2ax')
            
        else
            save([error_folder '/channelproblem' num2str(file_num) '.mat'])
            continue;
        end
        %%%% dodelani kanalu

        data = read_ics_3_files(filename);

        %%%% dodelani kanalu
        data = data([2,1,3]);
        %%%% dodelani kanalu
    
        for k = 1:length(data)
    
            tmp = single(data{k});
    
            tmp = imresize3(tmp,resized_img_size);
        
            tmp = norm_percentile_nocrop(tmp,normalization_percentile);
    
            data{k} = tmp;
        end
    
        data = cat(4,data{:});
    
%         mask_predicted = predict_by_parts(data,1,dlnet_segmentation,patchSize);
%         mask_split = split_nuclei(mask_predicted>0.5,minimal_nuclei_size,minimal_hole_size,h);
%         result_nuclei_segmentation = balloon(mask_split,mask_dilatation);
    
        
    
    
        predicted_detection = predict_by_parts(data(:,:,:,1:2),3,dlnet_detection,patchSize);
    
        detected_points_all = struct();
        binary_detection_all = struct();
        for out_chanel_index = 1:length(outputs_detection_chanels)
            params = parameters_detection.(outputs_detection_chanels{out_chanel_index});
            detected_points = detect(predicted_detection(:,:,:,out_chanel_index),params.T,params.h,params.d);
            detected_points_all.(outputs_detection_chanels{out_chanel_index}) = detected_points;
        end
    
       
    
    
        json_data = jsonencode(detected_points_all);
        fileID = fopen([filename_save 'detections.json'],'w');
        fprintf(fileID, json_data);
        fclose(fileID);
    
%     
%         imwrite_uint16_3D([filename_save 'nuclei_semgentaton_unprocessed.tif'],uint16(mask_predicted*65535))
%     
%         for outputs_detection_chanels_ind = 1:length(outputs_detection_chanels)
%             cn = outputs_detection_chanels{outputs_detection_chanels_ind};
%             imwrite_uint16_3D([filename_save 'detection_unprocessed_' cn '.tif'],uint16(predicted_detection(:,:,:,outputs_detection_chanels_ind)*65535))
%         end
%         imwrite_uint16_3D([filename_save 'nuclei_semgentaton.tif'],result_nuclei_segmentation)

    catch exception
        save([error_folder '/' num2str(file_num) '.mat'])

    end


end

