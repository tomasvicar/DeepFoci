clc;clear all;close all;



path = 'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path_out='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder';



names=subdir([path '/*3D*.tif']);
names={names(:).name};


rng(5)

q=randperm(length(names),600);

names=names(q);

save('names_foci_sample.mat','names')


 for img_num=1:length(names)
    img_num 
     
    name_data=names{img_num};
    name_data = split(name_data,'\');
    
    path0=join(name_data(1:end-1),'\');
    path0=path0{1};
    name_data=name_data{end};
    
    
    name_data_2d=strrep(name_data,'3D_','2D_');
     
    name_mask=strrep(name_data,'3D_','mask_');
    name_control_seg=strrep(name_data,'3D_','control_seg_');
    name_control_seg=strrep(name_control_seg,'.tif','.png');
    
    
    
    name_control=strrep(name_data,'3D_','control_');
    name_control=strrep(name_control,'.tif','.png');
    
    
    
    
    
    
    
   mkdir([path_out '/' num2str(img_num,'%04.f')])
    
   
  
   copyfile([path0 '/' name_data],[path_out '/' num2str(img_num,'%04.f') '/'  name_data ])
   copyfile([path0 '/' name_data_2d],[path_out '/' num2str(img_num,'%04.f') '/'  name_data_2d ])
   copyfile([path0 '/' name_mask],[path_out '/' num2str(img_num,'%04.f') '/'  name_mask ])
   copyfile([path0 '/' name_control_seg],[path_out '/' num2str(img_num,'%04.f') '/'  name_control_seg ])
   copyfile([path0 '/' name_control],[path_out '/' num2str(img_num,'%04.f') '/'  name_control ])
    
    
 end