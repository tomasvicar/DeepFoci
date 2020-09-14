
function dice = res_cellprofiler(d,th,how_many,all_res)




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

    for img_num=1:how_many
        if all_res
            img_num
        
        end

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

        

        LoG = [...
            -2,-4,-4,-4,-2
            -4,0,10,0,-4
            -4,10,32,10,-4
            -4,0,10,0,-4
            -2,-4,-4,-4,-2
            ];

        output=zeros(size(mask,1),size(mask,2));
        for cell_num =1:size(bbs,1)
            
            if all_res
                disp('load')
            end
            
            index_tmp=index_tmp+1;

            bbb=round(bbs(cell_num,:));

    %         a_crop = a(bbb(2):bbb(2)+bbb(5)-1,bbb(1):bbb(1)+bbb(4)-1,bbb(3):bbb(3)+bbb(6)-1);
    %         b_crop = b(bbb(2):bbb(2)+bbb(5)-1,bbb(1):bbb(1)+bbb(4)-1,bbb(3):bbb(3)+bbb(6)-1);
    %         mask_crop = mask_L(bbb(2):bbb(2)+bbb(5)-1,bbb(1):bbb(1)+bbb(4)-1,bbb(3):bbb(3)+bbb(6)-1)==cell_num;
    %         aa_max=max(a_crop,[],3);
    %         bb_max=max(b_crop,[],3);
    %         aa_mean=mean(a_crop,3);
    %         bb_mean=mean(b_crop,3);
    %         mask_proj=max(mask_crop,[],3);
    %         
    %         save(['../tmp_autofoci/' num2str(index_tmp) '.mat'],'aa_max','bb_max','aa_mean','bb_mean','mask_proj')

            load(['../tmp_autofoci/' num2str(index_tmp) '.mat'],'aa_max','bb_max','mask_proj')



            ab=aa_max.*bb_max;


            if all_res
                disp('th')
            end
            ab_th = imtophat(ab,strel('disk',th));
            
            
            img_to_maxdet=mask_proj.*ab_th;
            
            if all_res
                disp('dil')
            end
            img_to_maxdet_dil = imdilate(img_to_maxdet,strel('disk',d));
            bw1=imregionalmax(img_to_maxdet_dil);
            ab_th_norm=mat2gray(ab_th);
            bw2=ab_th_norm>graythresh(ab_th_norm(mask_proj));
            
            bw=bw1.*bw2.*mask_proj;
            
            
            if all_res
                disp('cent')
            end
            points=zeros(size(bw));
            s = regionprops(bw>0,'centroid');
            centroids = round(cat(1, s.Centroid));
            
            
            tmp2=centroids(:,2)+bbb(2);
            tmp1=centroids(:,1)+bbb(1);
            
            tmp2(tmp2>size(output,1))=size(output,1);
            tmp1(tmp1>size(output,2))=size(output,2);
            tmp2(tmp2<1)=1;
            tmp1(tmp1<1)=1;
            centroids(:,2)=tmp2;
            centroids(:,1)=tmp1;
            
            if img_num==33
                drawnow;
            end

            ind = sub2ind(size(output),centroids(:,2),centroids(:,1));
            
            output(ind) = 1;
            
%             for u = 1:size(centroids,1)
%                 output(bbb(2)+centroids(u,2),bbb(1)+centroids(u,1)) = 1;
%             end
            


        end

        if img_num==33
            dice_res_ja=[dice_res_ja,0];
            dice_res_jarda=[dice_res_jarda,0];
        else
            
  
    %     figure()
    %     imshow(max(a,[],3),[]);
    %     figure()
    %     imshow(output,[]);
    
        if all_res
                disp('eval1')
        end


        [y,x]=find(output);
        res=[x,y];

        load(name_gt_ja)
        gt_ja=tecky;

        load(name_gt_jarda)
        gt_jarda=tecky;



        d=matches_distance(res,gt_ja);
        dice=(2*d)/(size(res,1)+size(gt_ja,1));
        dice_res_ja=[dice_res_ja,dice];
        fp=[fp,max(size(res,1)-d,0)];
        fn=[fn,max(size(gt_ja,1)-d,0)];


        if all_res
                disp('eval2')
        end
        
        d=matches_distance(res,gt_jarda);
        dice=(2*d)/(size(res,1)+size(gt_jarda,1));
        dice_res_jarda=[dice_res_jarda,dice];

        end
        
        d=matches_distance(gt_ja,gt_jarda);
        dice=(2*d)/(size(gt_ja,1)+size(gt_jarda,1));
        dice_ja_jarda=[dice_ja_jarda,dice];

        if all_res
                disp(dice_res_jarda(end))
        end

        med_dice=median(dice_res_ja);
        med_fp=median(fp);
        med_fn=median(fn);

        drawnow;

       

    end


    dice = (mean(dice_res_ja) + mean(dice_res_jarda))/2;
    
    if all_res
        dice = {dice_res_ja,dice_res_jarda,dice_ja_jarda};
    end
%     
%     catch ME
% 
%         drawnow 
%         disp('chybka')
%         disp([T_oep,T,d,th,how_many])
%         dice=0;
% 
%     end
%     
    
end
