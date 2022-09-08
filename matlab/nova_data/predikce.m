clc;clear all;close all;
addpath('../utils')
addpath('../nuclei_segmentation_training')
addpath('../foci_detection_training')

data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


for_uniques = {};
wholes = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    
    
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_prediction_colorfix'];

    listing = subdir([error_folder '/*.mat']);

    for error_num = 1:length(listing)
        error_name = listing(error_num).name;
        
        load(error_name,'filename')

        tmp = split(filename,'\');
        whole = join(tmp(end-5:end-1),'\');
        whole = whole{1};
        for_unique = join(tmp(end-5:end-3),'\');
        for_unique = for_unique{1};

        for_uniques = [for_uniques,for_unique];
        wholes = [wholes,whole];
    end


end





channels_check = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_dodelavky'];
    mkdir(error_folder)

    
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
%         if 1
            disp(file_num)

    
            
        
            filename = filenames{file_num};

            if ~any(cellfun(@(x) contains(filename,x), wholes))
                continue;
            end
        
            filename_save = [results_folder, replace(filename,data_folder,'')];
    
    %         if exist([filename_save 'nuclei_semgentaton.tif'],'file')
    %             continue;
    %         end
    
            mkdir(filename_save)
    
    
            %%%% dodelani kanalu
            if exist([filename 'fov.txt'],'file')
                name_fov_file = [filename 'fov.txt'];
            elseif exist([filename 'roi.txt'],'file')
                name_fov_file = [filename 'roi.txt'];
            else
                error('no textfile')
            end
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

            if length(chanel_names)~=3
                save([error_folder '/' num2str(file_num) 'no_channels.mat'])
                continue
            end
    
%             disp(chanel_names)
%             if contains(lower(chanel_names{1}),'gh2ax') && (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
%                 disp('chanels ok')
%                 channels_check = [channels_check;chanel_names([2,1,3])];
%                 continue
%             end
           
            order = [0,0,0];
            if (contains(lower(chanel_names{1}),'53bp1')||contains(lower(chanel_names{1}),'rad51'))
                order(1) = 1;
            elseif (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
                order(1) = 2;
            elseif (contains(lower(chanel_names{3}),'53bp1')||contains(lower(chanel_names{3}),'rad51'))  
                order(1) = 3;
            else
                save([error_folder '/channelproblem' num2str(file_num) '.mat'])
                continue;
            end

            if contains(lower(chanel_names{1}),'gh2ax')
                order(2) = 1;
            elseif contains(lower(chanel_names{2}),'gh2ax')
                order(2) = 2;
            elseif contains(lower(chanel_names{3}),'gh2ax') 
                order(2) = 3;
            else
                save([error_folder '/channelproblem' num2str(file_num) '.mat'])
                continue;
            end

            if (contains(lower(chanel_names{1}),'dapi')||contains(lower(chanel_names{1}),'topro'))
                order(3) = 1;
            elseif (contains(lower(chanel_names{2}),'dapi')||contains(lower(chanel_names{2}),'topro'))
                order(3) = 2;
            elseif (contains(lower(chanel_names{3}),'dapi')||contains(lower(chanel_names{3}),'topro'))  
                order(3) = 3;
            else
                save([error_folder '/channelproblem' num2str(file_num) '.mat'])
                continue;
            end
            disp('corrected order:')
            disp(chanel_names(order))
            channels_check = [channels_check;chanel_names(order)];
            %%%% dodelani kanalu
    
            clear data;clear a;clear b;clear c;clear predicted_detection;
            try
                data = read_ics_3_files(filename);
            catch exception
                save([error_folder '/' num2str(file_num) '.mat'])
                continue;
            end
            if length(size(data{1}))~=3
                save([error_folder '/' num2str(file_num) 'size_error.mat']) 
                continue
            end
    
            %%%% dodelani kanalu
            data = data([2,1,3]);
            data = data(order);
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

end

