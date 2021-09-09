clc;clear all;close all;
addpath('utils')

orig_data_path = 'D:\foky_testovaci_data\orig';
labeled_path = 'D:\foky_testovaci_data\znacena';
save_folder = '../data_test';

gpu=0;


orig_filenames = subdirx([orig_data_path '/*01.ics']);

labled_filenames = subdirx([labeled_path '/*' 'result*.mat']);
pos = regexp(labled_filenames,'result\d\d\d\.mat$');
labled_filenames = labled_filenames(cellfun(@(x) ~isempty(x),pos));




labled_filenames_pahts = cellfun(@(x) fileparts(x),labled_filenames,'UniformOutput',false);

unique_folders = unique(labled_filenames_pahts);
for unique_folder = unique_folders
    
    unique_folder_labled = unique_folder{1};
    unique_folder_orig = replace(unique_folder_labled,labeled_path,orig_data_path);
    
    
    orig_filename = orig_filenames(cellfun(@(x)  contains(x,unique_folder_orig), orig_filenames));
    labeled_filenames_allcells = labled_filenames(cellfun(@(x)  contains(x,unique_folder_labled), labled_filenames));
    
    
    path_tmp = fileparts(replace(replace(orig_filename,orig_data_path,save_folder),'\rawdata',''));
    mkdir(path_tmp)
    control_save_name = [path_tmp '/control.png'];
    data_save_name = [path_tmp '/data.tif']; 
    lbls_save_name = [path_tmp '/labels.json']; 
    mask_save_name = [path_tmp '/mask.tif'];
    
    
    
    [a,b,c]=read_ics_3_files(char(orig_filename));
    
    if isempty(labeled_filenames_allcells)
        
        save(['../errors/' replace(replace(datestr(now),' ','_'),':','_') 'no_cells.mat'],'orig_filename')

    end
    
    
    
    for_json = [];
    for_json.points_53BP1 = zeros(0,3);
    for_json.points_gH2AX = zeros(0,3);
    
    
    for labeled_cell_num = 1:length(labeled_filenames_allcells)
        labeled_filename_allcells = labeled_filenames_allcells{labeled_cell_num};
        labeled_filename_allcells_input = replace(labeled_filename_allcells,'result','cell');
        
        
        lbls = load(labeled_filename_allcells);
        input = load(labeled_filename_allcells_input); 
        
        bb = input.bb;
        bb_corner = round(bb(1:3));
        
        
        tmp = round(lbls.points_R);
        points_R = tmp(lbls.binaryResuslts_R>0,:);
        points_R = points_R + bb_corner ;
        for_json.points_53BP1 = [for_json.points_53BP1;points_R];
        
        tmp = round(lbls.points_G);
        points_G = tmp(lbls.binaryResuslts_G>0,:);
        points_G = points_G + bb_corner ;
        for_json.points_gH2AX = [for_json.points_gH2AX;points_G];
        
        
    end
       
    json_data = jsonencode(for_json) ;
    
    fileID = fopen(lbls_save_name,'w');
    fprintf(fileID, json_data);
    fclose(fileID);
    
    

    imwrite_uint16_3D(replace(data_save_name,'data.tif','data_53BP1.tif'),a)
    imwrite_uint16_3D(replace(data_save_name,'data.tif','data_gH2AX.tif'),b)
    imwrite_uint16_3D(replace(data_save_name,'data.tif','data_DAPI.tif'),c)

    

%     ax = imread(replace(data_save_name,'data.tif','data_53BP1.tif'));
%     bx = imread(replace(data_save_name,'data.tif','data_gH2AX.tif'));
%     cx = imread(replace(data_save_name,'data.tif','data_DAPI.tif'));

    
%     tmp=cat(4,a,b,c);
%     imwrite_uint16_4D(data_save_name,tmp) %%nefunguje - dá 48 obrázky
%                 
%     [ax,bx,cx] = read_3d_rgb_tif(data_save_name);
%     tic
%     bfsave_volume_XYCZT(data_save_name,tmp) %%%funguje ale velke
%     tmp2 = bfopen_volume_XYCZT(data_save_name);
%     toc
    
    
     mask = imread([fileparts(labeled_filename_allcells) '/mask.tif']);
    imwrite_uint16_3D(mask_save_name,mask)      
    
    
%     [af,bf,cf]=preprocess_filters(a,b,c,gpu);

    
    ap = imgaussfilt(medfilt2(max(a,[],3),[3,3],'symmetric'),1);
    bp = imgaussfilt(medfilt2(max(b,[],3),[3,3],'symmetric'),1);
    cp = imgaussfilt(medfilt2(max(c,[],3),[3,3],'symmetric'),1);
    
    

    color_proj = cat(3,norm_percentile(ap,0.001),norm_percentile(bp,0.001),norm_percentile(cp,0.001));
    
    
    
    hold off
    imshow(color_proj,[])
    hold on
    visboundaries(max(mask,[],3))
    tmp = for_json.points_gH2AX;
    plot(tmp(:,1),tmp(:,2),'gx')
    tmp = for_json.points_53BP1;
    plot(tmp(:,1),tmp(:,2),'r+')
    print(control_save_name,'-dpng')
    drawnow;
    
    
    
    
    
end









