clc;clear all;close all;
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='D:\Users\vicar\foci_part';

path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';


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


        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');




        save_features=strrep(name,'3D_','features_norm_vals_');
        save_features=strrep(save_features,'.tif','.mat');



        [a,b,c]=read_3d_rgb_tif(name);


        [a,b,c]=preprocess_filters(a,b,c,gpu);






        perc=0.0001;

        global_a=[double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
        global_b=[double(prctile(b(:),perc*100)) double(prctile(b(:),100-perc*100))];
        global_c=[double(prctile(c(:),perc*100)) double(prctile(c(:),100-perc*100))];


        mask=imread(mask_name_split);


        mask_foci=imread(name_mask_foci)>0;
        lbl_foci=bwlabeln(mask_foci);


        clear mask_foci

        lbl_mask=bwlabeln(mask);
        lbl_mask=imresize3(lbl_mask,size(a),'nearest');

        tmp_cell_a={};
        tmp_cell_b={};
        tmp_cell_c={};

        perc=0.0001*0.01;

        N=max(lbl_mask(:));
        for k=1:N
            tmp_cell_a=[tmp_cell_a, [double(prctile(a(lbl_mask==k),perc*100)) double(prctile(a(lbl_mask==k),100-perc*100))]];
            tmp_cell_b=[tmp_cell_b, [double(prctile(b(lbl_mask==k),perc*100)) double(prctile(b(lbl_mask==k),100-perc*100))]];
            tmp_cell_c=[tmp_cell_c, [double(prctile(c(lbl_mask==k),perc*100)) double(prctile(c(lbl_mask==k),100-perc*100))]];
        end
        norm_vals = regionprops3(lbl_foci,lbl_mask,'MaxIntensity');
        norm_vals.Properties.VariableNames={'cellNum'};
        cell_nums=[norm_vals{:,:}];

        cell_nums(cell_nums==0)=1;

        global_a=repmat({global_a},[length(cell_nums),1]);
        global_b=repmat({global_b},[length(cell_nums),1]);
        global_c=repmat({global_c},[length(cell_nums),1]);

        norm_vals = addvars(norm_vals,global_a,'NewVariableNames','globalA');
        norm_vals = addvars(norm_vals,global_b,'NewVariableNames','globalB');
        norm_vals = addvars(norm_vals,global_c,'NewVariableNames','globalC');

        tmp=[tmp_cell_a(cell_nums)]';
        tmp=reshape(tmp,length(tmp),1);
        norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellA');
        tmp=[tmp_cell_b(cell_nums)]';
        tmp=reshape(tmp,length(tmp),1);
        norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellB');
        tmp=[tmp_cell_c(cell_nums)]';
        tmp=reshape(tmp,length(tmp),1);
        norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellC');


        save(save_features,'norm_vals')


    end
    
end
    
    
    
