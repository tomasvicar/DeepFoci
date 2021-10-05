clc;clear all;close all;


resutls_folder = 'C:\Data\Vicar\foci_new';
nuc_masks_folder = 'C:\Data\Vicar\foci_new\data_u87_nhdf_resaved';


reutls_name = 'resutls_a_b_ab_allfolds';
img_types = {'a','b','ab'};


result_names = {};
mask_names = {};
opt_params_names_a = {};
opt_params_names_b = {};
opt_params_names_ab = {};
gt_json_names = {};

for fold = 1:5
    
    results_folder_actual = [resutls_folder '/' reutls_name '_' num2str(fold) '_test'];
    results_folder_actual2 = [resutls_folder '/' reutls_name '_' num2str(fold)];
    
    files_tmp = subdirx([results_folder_actual '/*result.mat']);
    
    
    for file_num = 1:length(files_tmp)
        
        file = files_tmp{file_num};
        
        mask_name = replace( norm_path(file), norm_path(results_folder_actual), norm_path(nuc_masks_folder));
        mask_name = [fileparts(mask_name) '/mask.tif'];
        

        opt_params_name_a = [results_folder_actual2 '/resutls_a.mat'];
        opt_params_name_b = [results_folder_actual2 '/resutls_b.mat'];
        opt_params_name_ab = [results_folder_actual2 '/resutls_ab.mat'];
        
        
        
        result_names = [result_names,file];
        mask_names = [mask_names,mask_name];
        
        opt_params_names_a = [opt_params_names_a,opt_params_name_a];
        opt_params_names_b = [opt_params_names_b,opt_params_name_b];
        opt_params_names_ab = [opt_params_names_ab,opt_params_name_ab];
        
        
        gt_json_name =  replace( norm_path(file), norm_path(results_folder_actual), norm_path(nuc_masks_folder));
        gt_json_name = [fileparts(gt_json_name) '/labels.json'];
        gt_json_names = [gt_json_names, gt_json_name];
    end
    
   
    
    
    
end



counts_manual_a = [];
counts_manual_b = [];
counts_manual_ab = [];

counts_res_a = [];
counts_res_b = [];
counts_res_ab = [];
counts_res_ab_post = [];


dices_a = [];
dices_b = [];
dices_ab = [];
dices_ab_post = [];

file_names =[];
cell_nums = [];


for file_num = 1:length(result_names)
    
    disp([num2str(file_num)  '/' num2str(length(result_names))])
    
    result_name = result_names{file_num};
    mask_name = mask_names{file_num};
    opt_params_name_a =  opt_params_names_a{file_num};
    opt_params_name_b =  opt_params_names_b{file_num};
    opt_params_name_ab =  opt_params_names_ab{file_num};
    gt_json_name = gt_json_names{file_num};
    
    size_v = [505  681   48];
    
    mask = imread(mask_name);
    mask = bwlabeln(mask);
    mask = imresize3(mask,size_v,'nearest');
    
    result = load(result_name);
    result = result.mask_predicted;

    opt_params_a = load(opt_params_name_a);
    opt_params_a = opt_params_a.opt_results.XAtMinObjective;
    
    opt_params_b = load(opt_params_name_b);
    opt_params_b = opt_params_b.opt_results.XAtMinObjective;
    
    opt_params_ab = load(opt_params_name_a);
    opt_params_ab = opt_params_ab.opt_results.XAtMinObjective;
        
    %% read RES
    
    resuls_a = result(:,:,:,1);
    res_points = detect(resuls_a,opt_params_a.T,opt_params_a.h,opt_params_a.d);
    resuls_a = false(size(resuls_a));
    positions_linear = sub2ind(size(resuls_a),res_points(:,2),res_points(:,1),res_points(:,3));
    resuls_a(positions_linear) = true;
    

    resuls_b = result(:,:,:,2);
    res_points = detect(resuls_b,opt_params_b.T,opt_params_b.h,opt_params_b.d);
    resuls_b = false(size(resuls_b));
    positions_linear = sub2ind(size(resuls_b),res_points(:,2),res_points(:,1),res_points(:,3));
    resuls_b(positions_linear) = true;
    
    
    resuls_ab = result(:,:,:,3);
    res_points = detect(resuls_ab,opt_params_b.T,opt_params_b.h,opt_params_b.d);
    resuls_ab = false(size(resuls_ab));
    positions_linear = sub2ind(size(resuls_ab),res_points(:,2),res_points(:,1),res_points(:,3));
    resuls_ab(positions_linear) = true;
    
    
    
    
    factor = 2;
    d_t = 10;
    
    [r,c,v] = ind2sub(size(resuls_a),find(resuls_a));
    v = v * factor;
    pos1 = [r,c,v];
    
    [r,c,v] = ind2sub(size(resuls_b),find(resuls_b));
    v = v * factor;
    pos2 = [r,c,v];





    D = pdist2(pos1,pos2);
    D(D>d_t)=Inf;


    [assignment,cost]=munkres(D);

    new_points = [];
    for ass_ind = 1:length(assignment)
        ass = assignment(ass_ind);
        if ass ==0
            continue; 
        end

        new_point = int32((pos1(ass_ind,:) + pos2(ass,:))/2);

        new_point(3) = int32(round(new_point(3)/factor));


        new_points = [new_points;new_point];

    end

    resuls_ab_post = false(size(resuls_b));

    if ~isempty(new_points)
        positions_linear = sub2ind(size(resuls_ab_post),new_points(:,1),new_points(:,2),new_points(:,3));
        resuls_ab_post(positions_linear) = true;
    end
    

    
    
    %% read GT
    lbls = jsondecode(fileread(gt_json_name));
    
    factor = [0.5000    0.5000    0.9600];
    shape_new = [505   681    48];
    
    positions_53BP1 = lbls.points_53BP1;
    positions_gH2AX = lbls.points_gH2AX;
    
    if isempty(positions_53BP1)
        positions_53BP1 = zeros(0,3);
    end
    if isempty(positions_gH2AX)
        positions_gH2AX = zeros(0,3);
    end
    
    positions_53BP1_resize = round(positions_53BP1.*repmat(factor,[size(positions_53BP1,1),1]));
    positions_gH2AX_resize = round(positions_gH2AX.*repmat(factor,[size(positions_gH2AX,1),1]));
    
    
    
    mask_points_a = false(shape_new);
    mask_points_b = false(shape_new);
    
    shape_new_tmp = shape_new([2 1 3]);
    
    tmp = positions_53BP1_resize;
    if ~isempty(tmp)
        
        for k = 1:3
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp > shape_new_tmp(k),:) = [];
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp < 1 ,:) = [];
        end
        if ~isempty(tmp)
            positions_linear_53BP1 = sub2ind(shape_new,tmp(:,2),tmp(:,1),tmp(:,3));
            mask_points_a(positions_linear_53BP1) = true;
        end
    end
    
    
    tmp = positions_gH2AX_resize;
    if ~isempty(tmp)
        
        for k = 1:3
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp > shape_new_tmp(k),:) = [];
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp < 1 ,:) = [];
        end
        if ~isempty(tmp)
            positions_linear_gH2AX = sub2ind(shape_new,tmp(:,2),tmp(:,1),tmp(:,3));
            mask_points_b(positions_linear_gH2AX) = true;
        end
    end
    
    
    
    factor = 2;
    d_t = 10;
    
    [r,c,v] = ind2sub(size(mask_points_a),find(mask_points_a));
    v = v * factor;
    pos1 = [r,c,v];
    
    [r,c,v] = ind2sub(size(mask_points_b),find(mask_points_b));
    v = v * factor;
    pos2 = [r,c,v];





    D = pdist2(pos1,pos2);
    D(D>d_t)=Inf;


    [assignment,cost]=munkres(D);

    new_points = [];
    for ass_ind = 1:length(assignment)
        ass = assignment(ass_ind);
        if ass ==0
            continue; 
        end

        new_point = int32((pos1(ass_ind,:) + pos2(ass,:))/2);

        new_point(3) = int32(round(new_point(3)/factor));


        new_points = [new_points;new_point];

    end

     mask_points_ab = false(size(mask_points_b));

    if ~isempty(new_points)
        positions_linear = sub2ind(size(mask_points_ab),new_points(:,1),new_points(:,2),new_points(:,3));
        mask_points_ab(positions_linear) = true;
    end

    %% evaluate
%     
%     figure()
%     imshow(max(resuls_a,[],3),[])
%     title('res a')
%     figure()
%     imshow(max(resuls_b,[],3),[])
%     title('res b')
%     figure()
%     imshow(max(resuls_ab,[],3),[])
%     title('res ab')
%     figure()
%     imshow(max(resuls_ab_post,[],3),[])
%     title('res ab post')
%     figure()
%     imshow(max(mask,[],3),[])
%     
%     
%     figure()
%     imshow(max(mask_points_a,[],3),[])
%     title('res a')
%     figure()
%     imshow(max(mask_points_b,[],3),[])
%     title('res b')
%     figure()
%     imshow(max(mask_points_ab,[],3),[])
%     title('res ab')
%     
%     
%     drawnow;
    
    N = max(mask(:));
    for nuc_num = 1:N
        
        tmp = double(mask==nuc_num).*double(mask_points_a);
        count_manual_a = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(mask_points_b);
        count_manual_b = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(mask_points_ab);
        count_manual_ab = sum(tmp(:));
        
        tmp = double(mask==nuc_num).*double(resuls_a);
        count_res_a = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_b);
        count_res_b = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_ab);
        count_res_ab = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_ab_post);
        count_res_ab_post = sum(tmp(:));
        
        tmp = (double(mask==nuc_num).*double(mask_points_a)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        gt_points = cat(2,r,c,v);
        tmp = (double(mask==nuc_num).*double(resuls_a)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        res_points = cat(2,r,c,v);
        dice_a = dice_points(gt_points,res_points);
        
        
        tmp = (double(mask==nuc_num).*double(mask_points_b)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        gt_points = cat(2,r,c,v);
        tmp = (double(mask==nuc_num).*double(resuls_b)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        res_points = cat(2,r,c,v);
        dice_b = dice_points(gt_points,res_points);
        
        
        tmp = (double(mask==nuc_num).*double(mask_points_ab)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        gt_points = cat(2,r,c,v);
        tmp = (double(mask==nuc_num).*double(resuls_ab)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        res_points = cat(2,r,c,v);
        dice_ab = dice_points(gt_points,res_points);
        
        
        tmp = (double(mask==nuc_num).*double(mask_points_ab)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        gt_points = cat(2,r,c,v);
        tmp = (double(mask==nuc_num).*double(resuls_ab_post)) > 0;
        [r,c,v] = ind2sub(size(tmp),find(tmp));
        res_points = cat(2,r,c,v);
        dice_ab_post = dice_points(gt_points,res_points);
        
        
        counts_manual_a = [counts_manual_a,count_manual_a];
        counts_manual_b = [counts_manual_b,count_manual_b];
        counts_manual_ab = [counts_manual_ab,count_manual_ab];

        counts_res_a = [counts_res_a,count_res_a];
        counts_res_b = [counts_res_b,count_res_b];
        counts_res_ab = [counts_res_ab,count_res_ab];
        counts_res_ab_post = [counts_res_ab_post,count_res_ab_post];


        dices_a = [dices_a,dice_a];
        dices_b = [dices_b,dice_b];
        dices_ab = [dices_ab,dice_ab];
        dices_ab_post = [dices_ab_post,dice_ab_post];

        file_names =[file_names,result_name];
        cell_nums = [cell_nums,nuc_num];
        
        
        
        
    end
    
    
end



save('../../tmp_count.mat')




