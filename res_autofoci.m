
function dice = res_autofoci(T_oep,T,d,th,how_many,all_res)
%         try
%     % 0 - 0.001
%         T_oep = 4.0980e-06;
%         T=0.5;
%         d=10;
%         th=5;
        
        
        proj='max';
    %     proj='mean';
        max_in ='r';
    %     max_in ='g';


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

    %     img_num

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

            load(['../tmp_autofoci/' num2str(index_tmp) '.mat'])


            if strcmp(proj,'max')
                aa=aa_max;
                bb=bb_max;
            elseif strcmp(proj,'mean')
                aa=aa_mean;
                bb=bb_mean;
            else
                errror('wrong proj selection')
            end




            if strcmp(max_in,'r')
                img_to_maxdet=aa;
            elseif strcmp(max_in,'g')
                img_to_maxdet=bb;
            else
                errror('wrong max_in selection')
            end

            img_to_maxdet=mask_proj.*img_to_maxdet;
            img_to_maxdet_dil = imdilate(img_to_maxdet,strel('disk',d));
            bw=imregionalmax(img_to_maxdet_dil);
            points=zeros(size(bw));
            s = regionprops(bw>0,'centroid');
            centroids = round(cat(1, s.Centroid));
            for kp=1:size(centroids,1)
                points(centroids(kp,2),centroids(kp,1))=1;
            end


            r_th_im = imtophat(aa,strel('disk',th));
            g_th_im = imtophat(bb,strel('disk',th));

            r_lc_im = conv2(aa,LoG,'same');
            g_lc_im = conv2(bb,LoG,'same');



            s = regionprops(bw>0,'centroid');
            centroids = round(cat(1, s.Centroid));
            locmax_num = size(centroids,1);

            areas=zeros(size(aa));
            C_r=zeros(1,locmax_num);
            C_g=zeros(1,locmax_num);
            r_th=zeros(1,locmax_num);
            g_th=zeros(1,locmax_num);
            r_lc=zeros(1,locmax_num);
            g_lc=zeros(1,locmax_num);
            r_nucl = ones(1,locmax_num)*mean(mean(aa(mask_proj)));
            g_nucl = ones(1,locmax_num)*mean(mean(bb(mask_proj)));

            img_to_maxdet_mean=mean(mean(aa(mask_proj)));

            [Y,X]=meshgrid(1:size(aa,2),1:size(aa,1));

            for k = 1:locmax_num

                bw=img_to_maxdet>((1-T)*img_to_maxdet(centroids(k,2),centroids(k,1)) + (T)*img_to_maxdet_mean );
                L=bwlabel(bw);

                bw=L==L(centroids(k,2),centroids(k,1));

                centx = mean(X(bw));
                centy = mean(Y(bw));
                r2=(X(bw)-centx).^2 + (Y(bw)-centy).^2;

                Ir=aa(bw);
                C_r(k)= 1/sum(r2.*Ir);
                Ig=bb(bw);
                C_g(k)= 1/sum(r2.*Ig);

                r_th(k)=max(r_th_im(bw));
                g_th(k)=max(g_th_im(bw));

                r_lc(k)=max(r_lc_im(bw));
                g_lc(k)=max(g_lc_im(bw));


            end

            OEP_r =  r_th./r_nucl.*r_lc.*C_r;
            OEP_g =  g_th./g_nucl.*g_lc.*C_g;

            w=std(aa(mask_proj))/std(bb(mask_proj));

            OEP = OEP_r.^w .* OEP_g.^(1/w);

            use = OEP>T_oep;

            use = find(use);
            for u = use
                output(bbb(2)+centroids(u,2),bbb(1)+centroids(u,1)) = 1;
            end
        end

    %     figure()
    %     imshow(max(a,[],3),[]);
    %     figure()
    %     imshow(output,[]);


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
