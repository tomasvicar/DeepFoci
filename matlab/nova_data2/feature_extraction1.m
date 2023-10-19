clc;clear all;close all;
addpath('../utils')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP2';
    };


for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_feature_extraction1'];
    mkdir(error_folder)
    
    mkdir(error_folder)
    
    results_folder = [data_folder '_feature_extraction1'];

    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];

    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    for file_num = 1:length(filenames) %254
        try
%         if 1
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


           
            segmentation = imread([filename_save_oldseg 'nuclei_semgentaton.tif']);
            segmentation = bwlabeln(segmentation);
            segmentation = imresize3(segmentation, resized_img_size,'Method','nearest');

            result_irif_segmentation = imread([filename_save_fociseg 'foci_semgentaton.tif']);

            voxel_size_um=[0.1650,0.1650,0.3] .* (img_size ./ resized_img_size);
            tmp = img_size ./ resized_img_size;
            z_resize_faktor=1.8182 * (tmp(1)/tmp(3));
            voxel_volume_um = voxel_size_um(1) * voxel_size_um(2) * voxel_size_um(3);
            

%             data = single(cat(3,max(data{1},[],3),max(data{2},[],3),max(data{3},[],3)));
%             data(:,:,1) = norm_percentile(data(:,:,1),0.0001);
%             data(:,:,2) = norm_percentile(data(:,:,2),0.0001);
%             data(:,:,3) = norm_percentile(data(:,:,3),0.0001);
%             imshow(data,[])
%             hold on;
%             segmentation = max(segmentation,[],3);
%             visboundaries(segmentation>0)
%             result_irif_segmentation = max(result_irif_segmentation,[],3);
%             visboundaries(result_irif_segmentation>0)
%             plot(detected_points_r(:,1),detected_points_r(:,2),'r*')
%             plot(detected_points_g(:,1),detected_points_g(:,2),'g*')
%             plot(detected_points_rg(:,1),detected_points_rg(:,2),'b*')
%             drawnow;

            L_res = bwlabeln(result_irif_segmentation);

            r_table = regionprops3(L_res,data{1},'MaxIntensity','MeanIntensity');
            r_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityR';
            r_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityR';

            g_table = regionprops3(L_res,data{2},'MaxIntensity','MeanIntensity');
            g_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityG';
            g_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityG';

            b_table = regionprops3(L_res,data{3},'MaxIntensity','MeanIntensity');
            b_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityB';
            b_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityB';
            
            rg_table = regionprops3(L_res,data{1} .* data{2},'MaxIntensity','MeanIntensity');
            rg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityRG';
            rg_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityRG';


            seg_table = regionprops3(L_res,segmentation,'MaxIntensity');
            seg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensity_seg';

            N = max(L_res(:));
            correltaion = zeros(N,1);
            for k = 1:N
                tmp_r = data{1}(L_res==k);
                tmp_g = data{2}(L_res==k);
                correltaion(k) = corr(tmp_r(:),tmp_g(:));
            end
            rg_table = addvars(rg_table,correltaion,'NewVariableNames','Correltaion');

            shape=size(L_res);
            L_res_resize=imresize3(L_res,[shape(1),shape(2),round(shape(3)*z_resize_faktor)],'nearest');
            shape_table = regionprops3(L_res_resize,'Volume','Solidity','SurfaceArea','EigenValues');


            if isempty(shape_table.EigenValues)
                tmp = [];
            else
                tmp = cellfun(@(x) x(1),shape_table.EigenValues);
            end
            shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues1');
            if isempty(shape_table.EigenValues)
                tmp = [];
            else
                tmp = cellfun(@(x) x(2),shape_table.EigenValues);
            end
            shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues2');
            if isempty(shape_table.EigenValues)
                tmp = [];
            else
                tmp = cellfun(@(x) x(3),shape_table.EigenValues);
            end
            shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues3');
            shape_table = removevars(shape_table,'EigenValues');

            
            shape_table.Volume = shape_table.Volume*(voxel_size_um(1)^3);
            shape_table.Properties.VariableNames{'Volume'}='VolumeUm';
            
            shape_table.SurfaceArea = shape_table.SurfaceArea*(voxel_size_um(1)^2);
            shape_table.Properties.VariableNames{'SurfaceArea'}='SurfaceAreaUm';
            
            shape_table.EigenValues1 = shape_table.EigenValues1*(voxel_size_um(1));
            shape_table.Properties.VariableNames{'EigenValues1'}='EigenValues1Um';
            
            shape_table.EigenValues2 = shape_table.EigenValues2*(voxel_size_um(1));
            shape_table.Properties.VariableNames{'EigenValues2'}='EigenValues2Um';
            
            shape_table.EigenValues3 = shape_table.EigenValues3*(voxel_size_um(1));
            shape_table.Properties.VariableNames{'EigenValues3'}='EigenValues3Um';
            
            features_foci_table  = [r_table,g_table,b_table,rg_table,shape_table,seg_table];




            nuc_features_table = regionprops3(segmentation,'Volume');
            nuc_features_table = addvars(nuc_features_table,nuc_features_table.Volume*voxel_volume_um,'NewVariableNames','VolumeUmNuc');

            r_table  = regionprops3(segmentation,data{1},'MaxIntensity','MeanIntensity');
            r_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityR';
            r_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityR';


            g_table = regionprops3(segmentation,data{2},'MaxIntensity','MeanIntensity');
            g_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityG';
            g_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityG';

            b_table   = regionprops3(segmentation,data{3},'MaxIntensity','MeanIntensity');
            b_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityB';
            b_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityB';

            rg_table   = regionprops3(segmentation,data{1}.*data{2},'MaxIntensity','MeanIntensity');
            rg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityRG';
            rg_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityRG';


            nuc_features_table = [nuc_features_table,r_table,g_table,b_table,rg_table];

            


            data{1} = preprocess_filters(data{1},1);
            data{2} = preprocess_filters(data{2},1);
            data{3} = preprocess_filters(data{3},1);


            lin_ind_r = sub2ind(size(data{1},[1,2,3]),...
                detected_points_r(:,2),...
                detected_points_r(:,1),...
                detected_points_r(:,3));

            lin_ind_g = sub2ind(size(data{1},[1,2,3]),...
                detected_points_g(:,2),...
                detected_points_g(:,1),...
                detected_points_g(:,3));

            lin_ind_rg = sub2ind(size(data{1},[1,2,3]),...
                detected_points_rg(:,2),...
                detected_points_rg(:,1),...
                detected_points_rg(:,3));

            
            r_value = data{1}(lin_ind_r);
            r_segm = segmentation(lin_ind_r);
            
            g_value = data{2}(lin_ind_g);
            g_segm = segmentation(lin_ind_g);

            tmp = data{1} .* data{2};
            rg_value = tmp(lin_ind_rg);
            rg_segm = segmentation(lin_ind_rg);

            detection_table_r = table(r_value,r_segm);
            detection_table_g = table(g_value,g_segm);
            detection_table_rg = table(rg_value,rg_segm);


            save([filename_save_res_features 'extracted_features.mat'],...
                'features_foci_table', 'nuc_features_table',...
                'detection_table_r', 'detection_table_g', 'detection_table_rg')

        catch exception
            save([error_folder '/' num2str(file_num) '.mat'])
        end

    end
end
