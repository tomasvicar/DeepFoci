clc;clear all;close all;
% rmpath('../utils')
% rmpath('../nuclei_segmentation_training')
% addpath('../utils_old')
% addpath('../3DNucleiSegmentation_training')

rmpath('../utils_old')
rmpath('../3DNucleiSegmentation_training')
addpath('../utils')



data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'Z:\000000-My Documents\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };

outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;  %image is normalized into this percentile range

for_uniques = {};
wholes = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = error_folder{end};
    mkdir(error_folder)
    
    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 31:3:length(filenames)
%         try
        if 1

            if exist([error_folder '/' num2str(file_num) '.mat'])
                continue
            end

            filename = filenames{file_num};

            disp(file_num);
            disp(filename);
        
            
        
            filename_save_fociseg = [results_folder_fociseg, replace(filename,data_folder,'')];
            mkdir(filename_save_fociseg)
%             filename_save_examle_fociseg= [results_folder_examle_fociseg, replace(filename,data_folder,'')];
%             mkdir(filename_save_examle_fociseg)

            filename_save_oldseg = [results_folder_oldseg, replace(filename,data_folder,'')];
            filename_save_res1= [results_folder_res1, replace(filename,data_folder,'')];

        
            data = read_ics_3_files(filename);
            for channel_num = 1:3
                data{channel_num} = imresize3(single(data{channel_num}),resized_img_size);
                data{channel_num} = norm_percentile_nocrop(data{channel_num},normalization_percentile);
            end

            detected_points_all = jsondecode(fileread([filename_save_res1 'detections.json']));
           
            result_nuclei_segmentation = imread([filename_save_oldseg 'nuclei_semgentaton.tif']);
            result_nuclei_segmentation = imresize3(result_nuclei_segmentation, resized_img_size,'Method','nearest');

%             result_irif_segmentation = imread([filename_save_fociseg 'foci_semgentaton.tif']);

            
%             figure;
%             imshow(squeeze(max(data,[],3))+0.5) ;
%             hold on
%             visboundaries(max(result_nuclei_segmentation,[],3))
% 
%             figure;
%             imshow(squeeze(max(data,[],3))+0.5) ;
%             hold on
%             visboundaries(max(result_irif_segmentation,[],3))
% 
            close all;
            f = figure;
            imshow(squeeze(max(cat(4,data{1},data{2},data{3}),[],3))+0.5) ;
            hold on
            colors = {'r','g','y'};
            for out_chanel_index = 1:3
                detected_points=detected_points_all.(outputs_detection_chanels{out_chanel_index});
                plot(detected_points(:,1),detected_points(:,2),'*','Color',colors{out_chanel_index})
            end

            
            uiwait(f);
            




%        catch exception
%             save([error_folder '/' num2str(file_num) '.mat'])

       end


   end


end


u = unique(for_uniques);

