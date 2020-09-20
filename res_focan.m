
function dice = res_focan(c,median_size,d,how_many,all_res)

%     try


    % load('../names_foci_sample.mat')
    % names_orig=names;

    % names=subdir('../..\example_folder\*3D_*.tif');
    % names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
    % names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
    % names=subdir('F:\example_folder\*3D_*.tif');
    % names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
    % names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif\*data_*.tif');
    % names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif2\*data_*.tif');
    names=subdir('../man_nahodny_vzorek_tif/*data_*.tif');

    names={names(:).name};


    gpu=1;



    dice_res_ja=[];
    fp=[];
    fn=[];
    dice_res_jarda=[];
    dice_ja_jarda=[];

    mkdir('../tmp_autofoci')
    index_tmp=0;
    
     counts_res=[];
    counts_ja=[];
    counts_jarda=[];

    for img_num=1:how_many
        

        img_num

        name=names{img_num};
%         name

    %     name_orig=names_orig{img_num};

        name_mask=strrep(name,'data_','mask_');
        mask_name_split=strrep(name,'data_','mask_split');


        name_mask_foci=strrep(name,'data_','mask_foci_');


        save_control_seg=strrep(name,'data_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        save_manual_label=strrep(name,'data_','manual_label_');
        save_manual_label=strrep(save_manual_label,'.tif','.mat');


    %     save_features=strrep(name,'data_','features_window_');
        save_features=strrep(name,'data_','features_window2_');
        save_features=strrep(save_features,'.tif','.mat');


        save_features_for_celnum=strrep(name,'data_','features_cellnum_');
        save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');


        save_unet_foci_detection_mask=strrep(name,'data_','unet_foci_detection_mask');
        save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');


        save_unet_foci_detection_data=strrep(name,'data_','unet_foci_detection_data');
        save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');


        save_unet_foci_detection_res=strrep(name,'data_','unet_foci_detection_res');
        save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');

        save_unet_foci_detection_res_points=strrep(name,'data_','unet_foci_detection_res_points');
        save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');


        save_unet_foci_segmentation_res=strrep(name,'data_','unet_foci_segmentation_res');


        save_final_results_unet_control=strrep(name,'data_','final_results_unet_control');
        save_final_results_unet_control=strrep(save_final_results_unet_control,'.tif','');



        name_gt_ja=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_ja');
        name_gt_ja=strrep(name_gt_ja,'.tif','_tecky.mat');

        name_gt_jarda=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_jarda');
        name_gt_jarda=strrep(name_gt_jarda,'.tif','_tecky.mat');



    %     [a,b,c]=read_3d_rgb_tif(name);


        mask=imread(mask_name_split);

        mask_L=bwlabeln(mask);
        s = regionprops(mask_L,'BoundingBox');
        bbs = cat(1,s.BoundingBox);

        
        load(name_gt_ja)
        tecky(tecky<1)=1;
        

        gt_img_ja=zeros(size(mask,1),size(mask,2));
        
        if ~isempty(tecky)
            tmp=tecky(:,2);
            tmp(tmp>size(mask,1))=size(mask,1);
            tecky(:,2)=tmp;
            tmp=tecky(:,1);
            tmp(tmp>size(mask,2))=size(mask,2);
            tecky(:,1)=tmp;

            gt_ja=tecky;
            
            ind = sub2ind(size(gt_img_ja),gt_ja(:,2),gt_ja(:,1));
        else
            ind=[];
        end
            
        gt_img_ja(ind) = 1;

        
        
        load(name_gt_jarda)
        tecky(tecky<1)=1;
       
                
        gt_img_jarda=zeros(size(mask,1),size(mask,2));
        
        if ~isempty(tecky)
            tmp=tecky(:,2);
            tmp(tmp>size(mask,1))=size(mask,1);
            tecky(:,2)=tmp;
            tmp=tecky(:,1);
            tmp(tmp>size(mask,2))=size(mask,2);
            tecky(:,1)=tmp;

            gt_jarda=tecky;

            
            ind = sub2ind(size(gt_img_jarda),gt_jarda(:,2),gt_jarda(:,1));
        else
            ind=[];
        end
        
            
        gt_img_jarda(ind) = 1;

        output=zeros(size(mask,1),size(mask,2));
        for cell_num =1:size(bbs,1)
            
            index_tmp=index_tmp+1;

            bbb=round(bbs(cell_num,:));

            
              gt_img_jarda_crop = gt_img_jarda(bbb(2):bbb(2)+bbb(5)-1,bbb(1):bbb(1)+bbb(4)-1);
            gt_img_ja_crop = gt_img_ja(bbb(2):bbb(2)+bbb(5)-1,bbb(1):bbb(1)+bbb(4)-1);

    
            load(['../tmp_focan/' num2str(index_tmp) '.mat'],'mask_crop','ab_crop','ab_max','ab_min')
            
            
            ab_crop = mat2gray(ab_crop,[ab_max,ab_min]);
            

            tmp = imgaussfilt3(ab_crop,[median_size median_size median_size/3]);

%            tmp = gather(imgaussfilt3(gpuArray(ab_crop),[median_size median_size median_size/3]));

            
            bw = ab_crop>(tmp+c);

            shape=[d,d,round(d/3)];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
            

            dilated=imdilate(uint8(255*ab_crop),sphere);
            

            ab_maxima=imregionalmax(dilated);  
            ab_maxima=ab_maxima.*bw.*mask_crop;


            s = regionprops(ab_maxima>0,'Centroid');
            centroids = round(cat(1, s.Centroid));
           

            for u= 1:size(centroids,1)
                output(bbb(2)+centroids(u,2),bbb(1)+centroids(u,1)) = 1;
            end
            
            
            counts_res=[counts_res,size(centroids,1)];
            counts_ja=[counts_ja,sum(gt_img_ja_crop(:))];
            counts_jarda=[counts_jarda,sum(gt_img_jarda_crop(:))];

        end

    %     figure()
%         imshow(max(a,[],3),[]);
    %     figure()
    %     imshow(output,[]);
%         output = max(output,[],3);

        [y,x]=find(output);
        res=[x,y];



        d=matches_distance(res,gt_ja);
        dice=(2*d)/(size(res,1)+size(gt_ja,1));
        dice_res_ja=[dice_res_ja,dice];
        fp=[fp,max(size(res,1)-d,0)];
        fn=[fn,max(size(gt_ja,1)-d,0)];


        d=matches_distance(res,gt_jarda);
        dice=(2*d)/(size(res,1)+size(gt_jarda,1));
        dice_res_jarda=[dice_res_jarda,dice];

        d=matches_distance(gt_ja,gt_jarda);
        dice=(2*d)/(size(gt_ja,1)+size(gt_jarda,1));
        dice_ja_jarda=[dice_ja_jarda,dice];


    %     dice_res_jarda(end)

        med_dice=median(dice_res_ja);
        med_fp=median(fp);
        med_fn=median(fn);

        drawnow;



    end


    dice = (mean(dice_res_ja) + mean(dice_res_jarda))/2;
    
    if isnan(dice)
        dice=0;
    end
    
    if all_res
        dice = {dice_res_ja,dice_res_jarda,dice_ja_jarda,counts_res,counts_ja,counts_jarda};
    end
    
    
    
%     
%     catch ME
% 
%         drawnow 
% 
% 
%     end
%     
    
end
