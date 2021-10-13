clc;clear all;close all;
addpath('../utils')

resutls_folder = 'C:\Data\Vicar\foci_new';
nuc_masks_folder = 'C:\Data\Vicar\foci_new\data_u87_nhdf_resaved';
foci_seg_folder = 'C:\Data\Vicar\foci_new\data_u87_nhdf_foci_seg_tmp'; 



reutls_name = 'resutls_a_b_ab_allfolds';
img_types = {'a','b','ab'};
gpu = 1;

result_names = {};
mask_names = {};
opt_params_names_a = {};
opt_params_names_b = {};
opt_params_names_ab = {};
gt_json_names = {};

for fold = 1:7
    
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
        
        gt_json_name =  replace( norm_path(file), norm_path(results_folder_actual), norm_path(nuc_masks_folder));
        gt_json_name = [fileparts(gt_json_name) '/labels.json'];
        
        
        if any(strcmp(gt_json_names,gt_json_name))
            continue
            
        end
        
        
        result_names = [result_names,file];
        mask_names = [mask_names,mask_name];
        
        opt_params_names_a = [opt_params_names_a,opt_params_name_a];
        opt_params_names_b = [opt_params_names_b,opt_params_name_b];
        opt_params_names_ab = [opt_params_names_ab,opt_params_name_ab];
        
        
        
        gt_json_names = [gt_json_names, gt_json_name];
    end
    
   
    
    
    
end

counts_res_a = [];
counts_res_b = [];
counts_res_ab = [];
counts_res_ab_post = [];

blues_under = [];
blues_under_div_back = [];
blues_nuc = [];


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
    mask0 = mask;
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
    

    
    
    
    
    
    
    a = imread(replace(mask_name,'mask.tif','data_53BP1.tif'));
    b = imread(replace(mask_name,'mask.tif','data_gH2AX.tif'));
    c = imread(replace(mask_name,'mask.tif','data_DAPI.tif'));
    
    
    [a,b,~]=preprocess_filters(a,b,c,gpu);
    
    
    resuls_ab_post_big = imresize3(resuls_ab_post,size(a),'nearest');
    
    a=norm_percentile(a,0.00001);
    b=norm_percentile(b,0.00001);

    ab=a.*b;
    ab_uint_whole=uint8(mat2gray(ab)*255).*uint8(mask0);
    
    result=zeros(size(ab_uint_whole),'uint16');

        
    s = regionprops(mask0>0,'BoundingBox');
    bbs = cat(1,s.BoundingBox);
    
    for cell_num =1:size(bbs,1)

        bb=round(bbs(cell_num,:));
        ab_uint = ab_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);

        tic
        %    try
        r=vl_mser(ab_uint,'MinDiversity',0.1,...
            'MaxVariation',0.8,...
            'Delta',1,...
            'MinArea', 50/ numel(ab_uint),...
            'MaxArea',2400/ numel(ab_uint));
        %     catch
        %         r=[] ;
        %     end

        M = zeros(size(ab_uint),'uint16') ;
        for x=1:length(r)
            s = vl_erfill(ab_uint,r(x)) ;
            M(s) = M(s) + 1;
        end

        shape=[9,9,3];
        [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

        
        ab_maxima = resuls_ab_post_big(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        
        
        
        pom=-double(ab_uint);
        pom=imimposemin(pom,ab_maxima);
        wab_krajeny=watershed(pom)>0;
        wab_krajeny(M==0)=0;
        wab_krajeny=imfill(wab_krajeny,'holes');

        wab_krajeny_orez=wab_krajeny;
        tmp=~wab_krajeny_orez;
        %             shape0=size(tmp);
        %             tmp=imresize3(uint8(tmp),[shape0(1)*3,shape0(2)*3,shape0(3)],'nearest')>0;
        %             D = bwdist(tmp);
        D=bwdistsc(tmp,[1,1,3]);
        D=imhmax(D,1);
        %             D=imresize3(D,shape0,'linear');
        wab_krajeny_orez=(watershed(-D)>0) & wab_krajeny_orez;


        L=bwlabeln(wab_krajeny_orez);
        s=regionprops3(L,ab_maxima,'MaxIntensity');
        s = s.MaxIntensity;
        for k=1:length(s)
            if s(k)==0
                L(L==k)=0;
            end
        end
        wab_krajeny=L>0;

        

        result(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1)=wab_krajeny;


    end
    
       
    
    foci_seg_name = replace(mask_name,norm_path(nuc_masks_folder),norm_path(foci_seg_folder));
    foci_seg_name = [fileparts(foci_seg_name) '/foci_seg.tif'];
    mkdir(fileparts(foci_seg_name));
    
    imwrite_uint16_3D(foci_seg_name,result) 
    
    
    
    c = imresize3(c,size_v);
    
    foci_seg_mask = imresize3(result,size_v,'nearest');
    
    
    
    N = max(mask(:));
    for nuc_num = 1:N
       

        tmp = c(mask==nuc_num);
        blue_nuc = mean(tmp(:));
        
        tmp = c((mask==nuc_num) & (foci_seg_mask>0));
        blue_under = mean(tmp(:));
        
        
        tmp = c((mask==nuc_num) & (foci_seg_mask==0));
        blue_under_div_back = blue_under/mean(tmp(:));
        
        
        blues_under = [blues_under,blue_under];
        blues_under_div_back = [blues_under_div_back,blue_under_div_back];
        
        
        tmp = double(mask==nuc_num).*double(resuls_a);
        count_res_a = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_b);
        count_res_b = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_ab);
        count_res_ab = sum(tmp(:));
        tmp = double(mask==nuc_num).*double(resuls_ab_post);
        count_res_ab_post = sum(tmp(:));
        
        
        

        counts_res_a = [counts_res_a,count_res_a];
        counts_res_b = [counts_res_b,count_res_b];
        counts_res_ab = [counts_res_ab,count_res_ab];
        counts_res_ab_post = [counts_res_ab_post,count_res_ab_post];



        file_names =[file_names,result_name];
        cell_nums = [cell_nums,nuc_num];
        
        
        blues_nuc = [blues_nuc,blue_nuc];

        
    end
    
    
end




save('../../blue_under_foci.mat')


