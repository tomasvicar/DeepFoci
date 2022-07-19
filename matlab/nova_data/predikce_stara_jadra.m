clc;clear all;close all;
rmpath('../utils')
rmpath('../nuclei_segmentation_training')
addpath('../utils_old')
addpath('../3DNucleiSegmentation_training')


data_folders = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };

outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 

load('dice_rot_new.mat','net')

for_uniques = {};
wholes = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_stara_jadra'];
    mkdir(error_folder)
    
    results_folder = [data_folder '_net_results_oldseg'];
    results_folder_res1 = [data_folder '_net_results'];
    results_folder_examle = [data_folder '_example'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 1:length(filenames)
%         try
        if 1
            disp(file_num)
 
        
            filename = filenames{file_num};
        
            filename_save = [results_folder, replace(filename,data_folder,'')];
            mkdir(filename_save)
            if exist([filename_save 'nuclei_semgentaton.tif'],'file')
                disp('continue')
                continue;
            end

            filename_save_examle= [results_folder_examle, replace(filename,data_folder,'')];
            mkdir(filename_save_examle)

            filename_save_res1= [results_folder_res1, replace(filename,data_folder,'')];
            
            clear data;clear a;clear b;clear c;clear mask;clear mask_orig;

            try 
                data = read_ics_3_files(filename);
            catch exception
                save([error_folder '/' num2str(file_num) '.mat'])
                continue
            end
            if length(size(data{1}))

            end



            [a,b,c]=preprocess_filters(data{1},data{2},data{3},1);

            [a,b,c]=preprocess_norm_resize(a,b,c);
            
            mask_orig=predict_by_parts(a,b,c,net);
            
            
            
            mask=split_nuclei_hard(mask_orig);
            mask=balloon(mask,[20 20 8]);
            shape=[5,5,3];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<=1;
            mask=imerode(mask,sphere);

            
            detections = jsondecode(fileread([filename_save_res1 'detections.json']));
            
            close all;
            figure;
            imshow(squeeze(max(cat(4,a,b,c),[],3))+0.5) ;
            hold on
            visboundaries(max(mask,[],3))
            for out_chanel_index = 1:3
                detected_points=detections.(outputs_detection_chanels{out_chanel_index});
                if isempty(detected_points)
                    detected_points = zeros(0,3);
                end
                if numel(detected_points)==3
                    detected_points = detected_points';
                end
                factor = [337  454   48] ./ [505  681   48];
                detected_points = detected_points .* repmat(factor,[size(detected_points,1),1]);
                plot(detected_points(:,1),detected_points(:,2),'*')
            end
            print([filename_save_examle 'example'],'-dpng')


            imwrite_uint16_3D([filename_save 'nuclei_semgentaton_unprocessed.tif'],uint16(mask_orig*65535))

            imwrite_uint16_3D([filename_save 'nuclei_semgentaton.tif'],uint16(mask))

%        catch exception
%             save([error_folder '/' num2str(file_num) '.mat'])

       end


   end


end


u = unique(for_uniques);

