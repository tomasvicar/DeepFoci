% clc;clear all;close all force;
% 
% % dbstop if error
% % dbclear if error
% addpath('../utils')
% addpath('../3DNucleiSegmentation_training')
% 
% load('../man_nahodny_vzorek_tif/names_used.mat')
% 
% 
% names=subdir('../man_nahodny_vzorek_tif/*data_*.tif');
% names={names(:).name};
% 
% 
% 
% for img_num=1:100
%     
%     img_num
%     
%     name=names{img_num};
%     
%     
%         
%     name_gt_ja=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_ja');
%     name_gt_ja=strrep(name_gt_ja,'.tif','_tecky.mat');
%     
%     name_gt_jarda=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_jarda');
%     name_gt_jarda=strrep(name_gt_jarda,'.tif','_tecky.mat');
%     
%     
%     load(name_gt_ja)
%     gt_ja=tecky;
%     
%     load(name_gt_jarda)
%     gt_jarda=tecky;
%     
%     if ~isempty(gt_ja)
%         expert1_x=gt_ja(:,1);
%         expert1_y=gt_ja(:,2);
%     else
%         expert1_x=[];
%         expert1_y=[];
%     end
%     
%     if ~isempty(gt_jarda)
%         expert2_x=gt_jarda(:,1);
%         expert2_y=gt_jarda(:,2);
%     else
%         expert2_x=[];
%         expert2_y=[];
%     end
%     
%     max_len=max(size(gt_ja,1),size(gt_jarda,1));
%     
%     expert1_x(size(expert1_x,1)+1:max_len)=nan;
%     expert1_y(size(expert1_y,1)+1:max_len)=nan;
%     expert2_x(size(expert2_x,1)+1:max_len)=nan;
%     expert2_y(size(expert2_y,1)+1:max_len)=nan;
%     
%     expert1_x=expert1_x(:);
%     expert1_y=expert1_y(:);
%     expert2_x=expert2_x(:);
%     expert2_y=expert2_y(:);
%     
%     T=table(expert1_x,expert1_y,expert2_x,expert2_y);
%     
%     save_name=replace(name,'man_nahodny_vzorek_tif','data_zenodo/foci_evaluation_dataset');
%     copyfile(name,save_name)
%     
%     writetable(T,replace(save_name,'.tif','_pos.csv'))
%     
%     drawnow;
%     
% end


% 
% 
% 
% clc;clear all; close all force;
% 
% names_orig={};
% load('nuclei_labeler/names.mat')
% names_orig=[names_orig,names(1:170)];
% load('nuclei_labeler/names2.mat')
% names_orig=[names_orig,names];
% 
% addpath('utils')
% folder1='D:/foky/3d_segmentace_data/data_na_labely';
% folder2='D:/foky/3d_segmentace_data/data_na_labely2';
% 
% names1=subdir([folder1 '/mask_norm_*']);
% names1={names1.name};
% 
% names2=subdir([folder2 '/mask_norm_*']);
% names2={names2.name};
% 
% names=[names1 names2];
% 
% rng(1)
% 
% p = randperm(length(names));
% 
% names=names(p);
% names_orig=names_orig(p);
% 
% test_id=1:30;
% valid_id=31:40;
% train_id=41:1000;
% 
% 
% cisla=[];
% pahts={};
% 
% citac = -1;
% for kk=1:length(names)
%     kk
%     if kk==274
%        disp('preskakuju')%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%        continue
%     end
%     
%     citac=citac+1;
%     
%     if sum(kk==train_id)>0
%         data_type='train';
%         
%     elseif sum(kk==valid_id)>0
%         data_type='valid';
%         
%     elseif sum(kk==test_id)>0
%         data_type='test';
%             
%     else
%         error('xxxx')
%     end
%         
%     name_orig = names_orig{kk};
%     
%     name_mask=names{kk};
%     name=strrep(name_mask,'\mask_norm_','\data_');
%         
%     
%     info=imfinfo(name);
%     a=zeros(info(1).Height,info(1).Width,length(info));
%     b=zeros(info(1).Height,info(1).Width,length(info));
%     c=zeros(info(1).Height,info(1).Width,length(info));
%     
%     
%     data_shape=[info(1).Height,info(1).Width,length(info)];
%     
%     
%     info=imfinfo(name_mask);
%     mask=zeros(info(1).Height,info(1).Width,length(info));
%     for k=1:length(info)
%         rgb=imread(name_mask,k);
%         mask(:,:,k)=rgb;
%     end
%     
%     mask=imresize3(mask,[337  454   48],'nearest');
%     
%     
%     vel=[13 13 5];
%     [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
%     sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
%     
%     
%     mask_tmp=zeros(size(mask))>0;
%     mask_tmp2=uint8(zeros(size(mask)));
%     for k=1:4
%         cells0=mask==k;
%         cells=imerode(imclose(cells0,sphere),sphere);
% %         imshow4(cat(2,cells,cells0))
% 
%         cells = bwareaopen(cells,6000);
% 
%         mask_tmp(cells)=1;
%         mask_tmp2(imdilate(cells,sphere))=2;
%     end
%     mask_tmp2(mask_tmp>0)=1;
%     mask=mask_tmp2;
%     
%     
%     mask(mask==2)=0;
%     mask=balloon(mask>0,[20 20 8]);
%     
%     
%     mask=bwlabeln(mask,6);
%     mask=uint16(imresize3(mask,data_shape,'nearest'));
%     
%     
%     imwrite_uint16_3D(['D:/foky/data_zenodo/nucleus_segmentation/' data_type '/mask_' num2str(citac,'%03d') '.tif'],mask)
%     
%     
%     copyfile(name,['D:/foky/data_zenodo/nucleus_segmentation/' data_type '/data_' num2str(citac,'%03d') '.tif'])
%     
%     
%     cisla=[cisla,citac];
%     pahts=[pahts,name_orig];
% 
%     
% end
% 
% 
% 
% 
% 
% file_id=cisla(:);
% pahts=pahts(:);
% 
% 
% pacient = {};
% time = {};
% falk_id={};
% for k = 1:length(pahts)
%     
%     path= pahts{k};
%     
%     parts = split(path,'\');
%     
%     if endsWith(path,'.tif')
%         p1 = parts{end-3};
%         p2 = parts{end-1};
%         
%     else
%         p1 = parts{end-5};
%         p2 = parts{end-3};
% 
%         
%     end
%     
%     
%     
%     if endsWith(path,'.tif')
%     
%         p1 = split(p1,{' ','_'});
%         
%         p1=p1{2};
%     else
%         p1= replace(p1,'Pacient ','');
%     
%         p1 = split(p1,{' ','_'});
%         
%         p1=p1{1};
%     end
%     
%     if contains(p2,'2h')
%        t = '2';
%        
%     elseif contains(p2,'8h')
%          t = '8';
%          
%     elseif contains(p2,'1h')
%          t = '1';
%         
%     elseif contains(p2,'24h')
%         t = '24';
%         
%     elseif contains(p2,'30m')
%         t = '0.5';
%         
%     elseif contains(p2,'nonIR')||contains(p2,'kontrola')||contains(p2,'KO')||contains(p2,'non')
%         t = ' ';
%         
%     elseif contains(p2,'5m')
%         t = '5min';
%         
%     elseif contains(p2,'4h')
%         t = '4';
%         
%     else
%         disp(p2)
%         error('chybka')
%      
%     end
%     
%     p2 = split(p2,{'-','_',' '});
%     p2 = [p2{1} '-' p2{2}];
%     
%     
%     pacient = [pacient,p1];
%     time = [time,t ];
%     
%     falk_id = [falk_id,p2];
%     
% end
% 
% pacient=pacient';
% time=time';
% falk_id = falk_id';
% 
% 
% T=table(file_id,pahts,time,pacient,falk_id);
% 
% 
% 
% writetable(T,'D:/foky/data_zenodo/nucleus_segmentation/data_description.xlsx')














clc;clear all; close all force;

load('names_foci_sample.mat')
names_orig=names;

addpath('utils')
folder='Z:/999992-nanobiomed/Konfokal/18-11-19 - gH2AX jadra/data_vsichni_pacienti/example_folder_used';

names1=subdir([folder '/3D_*']);
names={names1.name};



% test_id=1:30;
valid_id=241:300;
train_id=1:240;


cisla=[];
pahts={};

citac = -1;
for kk=1:length(names)
    kk
    
    
    citac=citac+1;
    
    if sum(kk==train_id)>0
        data_type='train';
        
    elseif sum(kk==valid_id)>0
        data_type='valid';
        
    elseif sum(kk==test_id)>0
        data_type='test';
            
    else
        error('xxxx')
    end
        
    name_orig = names_orig{kk};
    
    name=names{kk};
    
    name_mask = strrep(name,'\3D_','\manual_label_');
    name_mask = strrep(name_mask,'.tif','.mat');   
    
    load(name_mask);
    
    info=imfinfo(name);
    a=zeros(info(1).Height,info(1).Width,length(info));
    b=zeros(info(1).Height,info(1).Width,length(info));
    c=zeros(info(1).Height,info(1).Width,length(info));
    
    
    data_shape=[info(1).Height,info(1).Width,length(info)];
    
  
    positions_resize=round(positions);
    
    mask_points_foci=false(data_shape);
    
    use=labels>0;
    positions_linear=sub2ind(data_shape,positions_resize(use,2),positions_resize(use,1),positions_resize(use,3));
    mask_points_foci(positions_linear)=true;
    
    
    
    imwrite_uint16_3D(['D:/foky/data_zenodo/foci_detection/' data_type '/mask_' num2str(citac,'%03d') '.tif'],mask_points_foci)
    
    
    copyfile(name,['D:/foky/data_zenodo/foci_detection/' data_type '/data_' num2str(citac,'%03d') '.tif'])
    
    
    cisla=[cisla,citac];
    pahts=[pahts,name_orig];

    
end





file_id=cisla(:);
pahts=pahts(:);


pacient = {};
time = {};
falk_id={};
for k = 1:length(pahts)
    
    path= pahts{k};
    
    parts = split(path,'\');
    
    if endsWith(path,'.tif')
        p1 = parts{end-3};
        p2 = parts{end-1};
        
    else
        p1 = parts{end-5};
        p2 = parts{end-3};

        
    end
    
    
    
    if endsWith(path,'.tif')
    
        p1 = split(p1,{' ','_'});
        
        p1=p1{2};
    else
        p1= replace(p1,'Pacient ','');
    
        p1 = split(p1,{' ','_'});
        
        p1=p1{1};
    end
    
    if contains(p2,'2h')
       t = '2';
       
    elseif contains(p2,'8h')
         t = '8';
         
    elseif contains(p2,'1h')
         t = '1';
        
    elseif contains(p2,'24h')||contains(p2,'24 h')
        t = '24';
        
    elseif contains(p2,'30m')
        t = '0.5';
        
    elseif contains(p2,'nonIR')||contains(p2,'kontrola')||contains(p2,'KO')||contains(p2,'non')
        t = ' ';
        
    elseif contains(p2,'5m')
        t = '5min';
        
    elseif contains(p2,'4h')
        t = '4';
        
    else
        disp(p2)
        error('chybka')
     
    end
    
    p2 = split(p2,{'-','_',' '});
    p2 = [p2{1} '-' p2{2}];
    
    
    pacient = [pacient,p1];
    time = [time,t ];
    
    falk_id = [falk_id,p2];
    
end

pacient=pacient';
time=time';
falk_id = falk_id';


T=table(file_id,pahts,time,pacient,falk_id);


T_train = T;
T_valid = T;

T_train=T_train(train_id,:);
T_valid=T_valid(valid_id,:);

writetable(T_train,'D:/foky/data_zenodo/foci_detection/train/data_description.xlsx')
writetable(T_valid,'D:/foky/data_zenodo/foci_detection/valid/data_description.xlsx')








