clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';

load('unet_detection/test3_value_aug_mult')


counts={};

bad=0;
all=0;


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

    count=[];
    
    

    for img_num=1:length(names)
        img_num
    
        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        
        save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
        save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
        
        
        save_unet_foci_detection_res_points=strrep(name,'3D_','unet_foci_detection_res_points');
        save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');
        
        

        load(save_unet_foci_detection_res_points)
%         'unet_foci_detection_res_points'
        
        

        mask=imread(mask_name_split);
        
        mask_foci=imread(name_mask_foci)>0;
        
        lbl_mask=bwlabeln(mask);
        
        tmp=unet_foci_detection_res_points;
        value=lbl_mask(sub2ind(size(lbl_mask),tmp(:,2),tmp(:,1),tmp(:,3)));
        value_foci=mask_foci(sub2ind(size(mask_foci),tmp(:,2),tmp(:,1),tmp(:,3)));
        
        drawnow;
        

        for kk=1:max(value(:))
            count=[count,sum(value==kk)];
        end
        
        bad=bad+sum((value_foci==0)&(value>0))
        all=all+length(value)
    end
    
    
    counts=[counts,count];


end





x=[];
y=[];

for k=1:length(counts)
    
    tmp=counts{k};
    x=[x,k*ones(1,length(tmp))];
    y=[y,tmp];
    
    
end

boxplot(y,x)








