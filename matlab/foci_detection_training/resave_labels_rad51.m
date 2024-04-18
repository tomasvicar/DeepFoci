clc;clear all;close all;
addpath('../utils')


data_path = 'C:\Data\Vicar\foci_rad51_retrain\data\NANOREP_labeling_new';
data_path_orig = 'C:\Data\Vicar\foci_rad51_retrain\data\NANOREP';
save_path = 'C:\Data\Vicar\foci_rad51_retrain\data\NANOREP_labeling_new_mask_resave';

fnames = subdir([data_path '/result*.mat']);
pattern = 'result\d{3}\.mat';
fnames = fnames(arrayfun(@(f) ~isempty(regexp(f.name, pattern, 'once')), fnames));


[uniqueFolders, ~, idx] = unique({fnames.folder});
fnames_groups = arrayfun(@(u) {fnames(idx == u).name}, 1:numel(uniqueFolders), 'UniformOutput', 0);


for folder_num = 1:length(fnames_groups)
    
    fnames_group = fnames_groups{folder_num};
    folder_name = fileparts(fnames_group{1});

    fname_data = [replace(folder_name, data_path, data_path_orig) '/'];
    data = read_ics_3_files(fname_data);
    [chanel_names] = get_channel_names(fname_data);
    
    order = [0,0,0];
    if (contains(lower(chanel_names{1}),'53bp1')||contains(lower(chanel_names{1}),'rad51'))
        order(1) = 1;
    elseif (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
        order(1) = 2;
    elseif (contains(lower(chanel_names{3}),'53bp1')||contains(lower(chanel_names{3}),'rad51'))  
        order(1) = 3;
    else
        error('fsfdsfsd')
    end

    if contains(lower(chanel_names{1}),'gh2ax')
        order(2) = 1;
    elseif contains(lower(chanel_names{2}),'gh2ax')
        order(2) = 2;
    elseif contains(lower(chanel_names{3}),'gh2ax') 
        order(2) = 3;
    else
        error('fsfdsfsd')
    end

    if (contains(lower(chanel_names{1}),'dapi')||contains(lower(chanel_names{1}),'topro'))
        order(3) = 1;
    elseif (contains(lower(chanel_names{2}),'dapi')||contains(lower(chanel_names{2}),'topro'))
        order(3) = 2;
    elseif (contains(lower(chanel_names{3}),'dapi')||contains(lower(chanel_names{3}),'topro'))  
        order(3) = 3;
    else
        error('fsfdsfsd')
    end
   
    data = data([2,1,3]);
    data = data(order);

    disp(chanel_names(order));

    points_RAD51 = [];
    points_gH2AX = [];
    for cell_num = 1:length(fnames_group)
        fname_result = fnames_group{cell_num};
        fname_orig = replace(fname_result, 'result', 'cell_orig');
        

        lbl = load(fname_result);
        orig = load(fname_orig);

        
        points = lbl.points_R + orig.bb(1:3);
        binar_selected_points = lbl.binaryResuslts_R;
        points_RAD51 = [points_RAD51; points(binar_selected_points,:)];
        points = lbl.points_G + orig.bb(1:3);
        binar_selected_points = lbl.binaryResuslts_G;
        points_gH2AX = [points_gH2AX; points(binar_selected_points,:)];

    end

    % rgb_2d=cat(3,norm_percentile(max(data{1},[],3),0.001),norm_percentile(max(data{2},[],3),0.001),norm_percentile(max(data{3},[],3),0.001));
    % rgb_2d_side1=cat(3,norm_percentile(squeeze(max(data{1},[],1)),0.001),norm_percentile(squeeze(max(data{2},[],1)),0.001),norm_percentile(squeeze(max(data{3},[],1)),0.001));
    % rgb_2d_side2=cat(3,norm_percentile(squeeze(max(data{1},[],2)),0.001),norm_percentile(squeeze(max(data{2},[],2)),0.001),norm_percentile(squeeze(max(data{3},[],2)),0.001));
    % 
    % figure()
    % imshow(rgb_2d)
    % hold on
    % plot(points_RAD51(:,1), points_RAD51(:,2), 'r*')
    % plot(points_gH2AX(:,1), points_gH2AX(:,2), 'g*')
    % 
    % figure()
    % imshow(rgb_2d_side1)
    % hold on
    % plot(points_RAD51(:,3), points_RAD51(:,1), 'r*')
    % plot(points_gH2AX(:,3), points_gH2AX(:,1), 'g*')


    save_folder = [save_path, '/',  num2str(folder_num,'%03.f') '/'];
    mkdir(save_folder)
    imwrite_uint16_3D([save_folder 'data_RAD51.tif'],data{1})
    imwrite_uint16_3D([save_folder 'data_gH2AX.tif'],data{2})
    imwrite_uint16_3D([save_folder 'data_DAPI.tif'],data{3})

    data = struct;
    data.points_RAD51 = points_RAD51;
    data.points_gH2AX = points_gH2AX;
    
    filename = [save_folder 'labels.json'];

    fid = fopen(filename, 'w');
    json_data = jsonencode(data);
    fprintf(fid, json_data);
    fclose(fid);
    

end