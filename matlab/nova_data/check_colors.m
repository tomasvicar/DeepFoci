clc;clear all;close all;
% rmpath('../utils')
% rmpath('../nuclei_segmentation_training')
% addpath('../utils_old')
% addpath('../3DNucleiSegmentation_training')

rmpath('../utils_old')
rmpath('../3DNucleiSegmentation_training')
addpath('../utils')



data_folders = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };

outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;  %image is normalized into this percentile range

names_all = {};
chanels_all = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_check_colors'];
%     mkdir(error_folder)
    
    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 1:length(filenames)
        try
%         if 1
            disp(file_num)

            filename = filenames{file_num};


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

            if length(chanel_names)<3
                continue;
            end


            names_all = [names_all;filename];
            chanels_all = [chanels_all;chanel_names];

        
            
        
       catch exception
%             save([error_folder '/' num2str(file_num) '.mat'])

       end


   end


end

T = cell2table(chanels_all);
TT = cell2table(names_all);

TTT = [TT,T];

