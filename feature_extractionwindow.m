clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';



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

%         name_orig=names_orig{img_num};

        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');


        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        save_manual_label=strrep(name,'3D_','manual_label_');
        save_manual_label=strrep(save_manual_label,'.tif','.mat');


%         save_features=strrep(name,'3D_','features_window_');
        save_features=strrep(name,'3D_','features_window2_');
        save_features=strrep(save_features,'.tif','.mat');


        [a,b,~]=read_3d_rgb_tif(name);

        ab=a.*b;




         mask_foci=imread(name_mask_foci)>0;

         lbl_foci=bwlabeln(mask_foci);

              clear mask_foci
     
     
%     sizes=[71 71 19];
    sizes=[101 101 19];
     
    widnowa=get_window(a,lbl_foci,sizes);
    widnowb=get_window(b,lbl_foci,sizes);

    save(save_features,'widnowa','widnowb')
     

    end
    
end
    
    
    
