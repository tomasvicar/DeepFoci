clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='D:\Users\vicar\foci_part';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';


% load('fix_velke_aug_norm_net_checkpoint__8360__2020_01_14__17_52_49.mat');

% load('rf_all_06860.mat');

% load('rf_half_06778.mat');

% load('rf_norm_06883.mat');



load('foci_classification_training/global_norm_net_small_grow_add.mat')


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:length(folders)
    
    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};

    for img_num=1:length(names)

        img_num

        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');
        
        
        name_2D=strrep(name,'3D_','2D_');


        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        save_manual_label=strrep(name,'3D_','manual_label_');
        save_manual_label=strrep(save_manual_label,'.tif','.mat');


        save_features=strrep(name,'3D_','features_');
        save_features=strrep(save_features,'.tif','.mat');

            
    save_features=strrep(name,'3D_','features_window_');
%     save_features=strrep(name,'3D_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    features_norm_vals=strrep(name,'3D_','features_norm_vals_');
    features_norm_vals=strrep(features_norm_vals,'.tif','.mat');
        
        
    save_control_final=strrep(name,'3D_','control_final_net_');
    save_control_final=strrep(save_control_final,'.tif','');


    save_results_final=strrep(save_control_final,'control_','results_');
    save_results_final=[save_results_final '.mat'];
        

        clear features cell_num
        
        load(save_features)
    
        load(save_features_for_celnum)


        load(save_features)
        
        load(features_norm_vals)
        
        binaryResuslts=zeros(1,length(widnowa));
        for k=1:length(widnowa)
            
            normA=norm_vals.globalA(k);
            normB=norm_vals.globalB(k);
            normA=normA{1};
            normB=normB{1};
            
            wa=(widnowa{k}-normA(1))/(normA(2)-normA(1));
            
            wb=(widnowb{k}-normB(1))/(normB(2)-normB(1));
            
            
            window_k=cat(4,wa,wb);
            

            window_k=window_k(4:end-4,4:end-4,2:end-2,:);
    
    
            window_k=single(mat2gray(window_k,[0,1]));



            
            
            YPred = predict(net,window_k);
            
            binaryResuslts(k)=double(YPred(2));
            
        end
        


        
        mask=imread(mask_name_split);
        
        rgb_2d=imread(name_2D);
        
        mask_foci=imread(name_mask_foci)>0;
        
        mask_2d_split1=mask_2d_split(mask,3);

        
   
        
        
        rgb_2d=cat(3,norm_percentile(rgb_2d(:,:,1),0.005),norm_percentile(rgb_2d(:,:,2),0.005),norm_percentile(rgb_2d(:,:,3),0.005));
        
        close all
        imshow(mat2gray(double(rgb_2d)))
        hold on
%         visboundaries(sum( mask_foci,3)>0,'LineWidth',0.5,'Color','r','EnhanceVisibility',0)
        visboundaries(mask_2d_split1,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
        s = regionprops( mask_foci>0,'Centroid');
        maxima = round(cat(1, s.Centroid));
        if ~isempty(maxima)
            plot(maxima(:,1), maxima(:,2), 'b*','MarkerSize',3)
            plot(maxima(find(binaryResuslts>0.5),1), maxima(find(binaryResuslts>0.5),2), 'ro','MarkerSize',3)
            plot(maxima(find(binaryResuslts>0.5),1), maxima(find(binaryResuslts>0.5),2), 'g*','MarkerSize',3)
        end
        name_orig_tmp=split(name,'\');
        name_orig_tmp=join(name_orig_tmp(end-3:end),'\');
        title(name_orig_tmp)
        drawnow;
        print(save_control_final,'-dpng')

        
        
        save(save_results_final,'binaryResuslts')
        
    end
    
end