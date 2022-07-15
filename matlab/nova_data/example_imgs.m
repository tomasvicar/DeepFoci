clc;clear all;close all;
addpath('../utils')
addpath('../nuclei_segmentation_training')


data_folders = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;
outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    
    
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_example'];
    mkdir(error_folder)
    
    results_folder = [data_folder '_net_results'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);
    
    
    
    
    
    for file_num = 25:length(filenames)
        while 1
%         try
        
            filename = filenames{file_num};
            filename_save = [results_folder, replace(filename,data_folder,'')];
           
        
            data = read_ics_3_files(filename);
        
            for k = 1:length(data)
        
                tmp = single(data{k});
        
                tmp = imresize3(tmp,resized_img_size);
            
                tmp = norm_percentile_nocrop(tmp,normalization_percentile);
        
                data{k} = tmp;
            end
        
            data = cat(4,data{:});


            result_nuclei_segmentation = imread([filename_save 'nuclei_semgentaton.tif']);


            detections = jsondecode(fileread([filename_save 'detections.json']));
 

            figure;
            imshow(squeeze(max(data,[],3))+0.5) ;
            hold on
            visboundaries(max(result_nuclei_segmentation,[],3))
            for out_chanel_index = 1:3
                detected_points=detections.(outputs_detection_chanels{out_chanel_index});
                plot(detected_points(:,1),detected_points(:,2),'*')
            end

            drawnow;


        

    
%         catch exception
%             save([error_folder '/' num2str(file_num) '.mat'])
    
        end
    
    
    end


end
