clc;clear all;close all force;
addpath('../utils')


%% setup
src_path = '../../data_zenodo/part2';
dst_paht = '../../data_zenodo/part2_resaved';


% load filenames for 53BP1, gH2AX and DAPI  - modify based on your data
names_53BP1 = subdir([src_path '/data_53BP1.tif']);
filenames.imgs_53BP1 = {names_53BP1(:).name};
filenames.imgs_gH2AX = cellfun(@(x) replace(x,'53BP1','gH2AX'),filenames.imgs_53BP1,'UniformOutput',false);
filenames.imgs_DAPI = cellfun(@(x) replace(x,'53BP1','DAPI'),filenames.imgs_53BP1,'UniformOutput',false);
json_labels = cellfun(@(x) replace(x,'data_53BP1.tif','labels.json'),filenames.imgs_53BP1,'UniformOutput',false);

gpu = 1; % use gpu for filtering? 

resized_img_size = [505  681   48]; %image is resized to this size

normalization_percentile = 0.0001;  %image is normalized into this percentile range


%% resaving 
for img_num = 1:length(filenames.imgs_53BP1)

    %% resave images
    fields = fieldnames(filenames);
    for field_num = 1:length(fields)
        field = fields{field_num};

        img_filename = filenames.(field){img_num};

        data = single(imread(img_filename));

        img_size = size(data);

        data = imresize3(data,resized_img_size);

        data = norm_percentile_nocrop(data,normalization_percentile);

        img_filename = replace(img_filename,'\','/');
        dst_folder = fileparts(replace(img_filename,src_path,dst_paht));
        mkdir(dst_folder)
        
        save([dst_folder '/' field '.mat'],'data','-v7.3')


    end



    %% resave labels to binary masks
    resize_factor = resized_img_size./img_size; % points must be updated based on image size change

    lbls_filename = json_labels{img_num};
    lbls = jsondecode(fileread(lbls_filename));

    z_scale_factor = 2;
    lbls.points_53BP1_gH2AX_overlap = get_overlaped_points(lbls.points_53BP1,lbls.points_gH2AX);%%%%%% get overlaped points
    

    fields = fieldnames(lbls);
    for field_num = 1:length(fields)
        field = fields{field_num};
        positions = lbls.(field);

        if isempty(positions)
            positions = zeros(0,3);
        end
        positions_resized = round(positions.*repmat(resize_factor,[size(positions,1),1]));

        positions_resized = positions_resized(:,[2,1,3]);

        data = false(resized_img_size);


        if ~isempty(positions_resized)
            %check in point is not outside image
            for k = 1:3
                tmp = positions_resized(:,k);
                positions_resized(tmp > resized_img_size(k),:) = [];
                tmp = positions_resized(:,k);
                positions_resized(tmp < 1 ,:) = [];
            end
            
            % create binary mask
            if ~isempty(positions_resized)
                positions_linear= sub2ind(resized_img_size,positions_resized(:,1),positions_resized(:,2),positions_resized(:,3));
                data(positions_linear) = true;
            end
        end
        
        lbls_filename = replace(lbls_filename,'\','/');
        dst_folder = fileparts(replace(lbls_filename,src_path,dst_paht));
        mkdir(dst_folder)
        
        save([dst_folder '/' field '.mat'],'data','-v7.3')

    end


end