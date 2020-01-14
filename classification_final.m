clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='D:\Users\vicar\foci_part';


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:25
    
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

        save_features_cellnum=strrep(name,'3D_','features_cellnum_');
        save_features_cellnum=strrep(save_features_cellnum,'.tif','.mat');
        
        
        save_features_window=strrep(name,'3D_','features_');
        save_features_widnow=strrep(save_features_window,'.tif','.mat');
        
        save_features_window2=strrep(name,'3D_','features_');
        save_features_widnow2=strrep(save_features_window2,'.tif','.mat');
        
        
        
        load()
        
        
        
        
        
        
        
        rgb_2d=imread(name_2D);
        
        mask_foci=imread(name_mask_foci)>0;
        
        mask_2d_split1=mask_2d_split(mask,3);

        
        
        close all
        imshow(rgb_2d)
        hold on
        visboundaries(sum( mask_foci,3)>0,'LineWidth',0.5,'Color','r','EnhanceVisibility',0)
        visboundaries(mask_2d_split1,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
        s = regionprops( mask_foci>0,'Centroid');
        
        maxima = round(cat(1, s.Centroid));
        if ~isempty(maxima)
            plot(maxima(:,1), maxima(:,2), 'b*')
            plot(maxima(find(binaryResuslts),1), maxima(find(binaryResuslts),2), 'ro')
            plot(maxima(find(binaryResuslts),1), maxima(find(binaryResuslts),2), 'g*')
        end
        name_orig_tmp=split(name,'\');
        name_orig_tmp=join(name_orig_tmp(end-3:end),'\');
        title(name_orig_tmp)
        drawnow;

        
        
        
        
        
    end
    
end