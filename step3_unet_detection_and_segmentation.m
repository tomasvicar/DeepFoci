clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';

gpu=1;


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;




for folder_num=1:length(folders)

    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};


    load('dice_rot_new.mat')
    
    if folder_num<6
        continue
    end
        


    for img_num=1:length(names)
       img_num

       name=names{img_num};


       [a,b,c]=read_3d_rgb_tif(name);




    end
    
    
end




