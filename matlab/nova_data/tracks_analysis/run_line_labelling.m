clc;clear all; close all force;
addpath('../../utils')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP2';
    };


for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_line_labelling'];
    mkdir(error_folder)
    
    mkdir(error_folder)
    
    results_folder = [data_folder '_line_labelling'];

    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];

    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    for file_num = 1:length(filenames) %254
%         try
        if 1
            disp(file_num)
            filename = filenames{file_num};
            filename_save_res_features = [results_folder, replace(filename,data_folder,'')];
            mkdir(filename_save_res_features )


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
%             channels_check = [channels_check;chanel_names(order)];
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

            filename_save_fociseg = [results_folder_fociseg, replace(filename,data_folder,'')];
            filename_save_oldseg = [results_folder_oldseg, replace(filename,data_folder,'')];
            filename_save_res1= [results_folder_res1, replace(filename,data_folder,'')];


            resized_img_size = [505  681   48];
            img_size = size(data{1});
           
            for channel_num = 1:3
                data{channel_num} = imresize3(single(data{channel_num}),resized_img_size);
            end

            outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 
            detections = jsondecode(fileread([filename_save_res1 'detections.json']));


            detected_points = detections.(outputs_detection_chanels{1});
            if isempty(detected_points)
                detected_points = zeros(0,3);
            end
            if numel(detected_points)==3
                detected_points = detected_points';
            end
            binary_detection = false(size(data{1},[1,2,3]));
            binary_detection(sub2ind(size(data{1},[1,2,3]),...
                detected_points(:,2),...
                detected_points(:,1),...
                detected_points(:,3))) = true;
            detected_points_r = detected_points;
            binary_detection_r = binary_detection;



            detected_points = detections.(outputs_detection_chanels{2});
            if isempty(detected_points)
                detected_points = zeros(0,3);
            end
            if numel(detected_points)==3
                detected_points = detected_points';
            end
            binary_detection = false(size(data{1},[1,2,3]));
            binary_detection(sub2ind(size(data{1},[1,2,3]),...
                detected_points(:,2),...
                detected_points(:,1),...
                detected_points(:,3))) = true;
            detected_points_g = detected_points;
            binary_detection_g = binary_detection;


            detected_points = detections.(outputs_detection_chanels{3});
            if isempty(detected_points)
                detected_points = zeros(0,3);
            end
            if numel(detected_points)==3
                detected_points = detected_points';
            end
            binary_detection = false(size(data{1},[1,2,3]));
            binary_detection(sub2ind(size(data{1},[1,2,3]),...
                detected_points(:,2),...
                detected_points(:,1),...
                detected_points(:,3))) = true;
            detected_points_rg = detected_points;
            binary_detection_rg = binary_detection;

            app = line_labeller(data,detected_points_rg);
            while isvalid(app)
                pause(0.1); 
            end



        end

    end
end
