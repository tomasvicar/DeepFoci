clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

load('names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names={names(:).name};

gpu=1;


features_cell={};
labels_cell={};
for img_num=1:170
    
    img_num
    
    name=names{img_num};
    
    name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'3D_','mask_');
    mask_name_split=strrep(name,'3D_','mask_split');

    
    name_mask_foci=strrep(name,'3D_','mask_foci_');
    
    
    save_control_seg=strrep(name,'3D_','control_seg_foci');
    save_control_seg=strrep(save_control_seg,'.tif','');
    
    save_manual_label=strrep(name,'3D_','manual_label_');
    save_manual_label=strrep(save_manual_label,'.tif','.mat');
    
    
    [a,b,~]=read_3d_rgb_tif(name);
    
    ab=a.*b;
    
%     mask=read_mask(name_mask);
%     mask=split_nuclei(mask);
%     mask=balloon(mask,[20 20 8]);
%     shape=[5,5,2];
%     [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
%     sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
%     mask_conected=imerode(mask,sphere);
%     mask=imresize3(uint8(mask),size(a),'nearest')>0;
%     
    
    
    
%      mask=imread(mask_name_split);
     
     
     
     mask_foci=imread(name_mask_foci)>0;
     
     lbl_foci=bwlabeln(mask_foci);
     
     clear mask foci
     
     load(save_manual_label);
     
     labels_cell=[labels_cell,labels];
     
     
     lbl_foci_resize=imresize3(lbl_foci,[size(lbl_foci,1),size(lbl_foci,2),size(lbl_foci,3)*3],'nearest');
     
     
     stats_shape = regionprops3(lbl_foci_resize,'EquivDiameter','Solidity','Orientation');
     
     stats_tmp = regionprops3(lbl_foci_resize,'Volume','SurfaceArea');
     
     stats_shape = addvars(stats_shape,stats_tmp.Volume./stats_tmp.SurfaceArea,'NewVariableNames','crtVolumeDivSqrtSurfaceArea');
     
     
     clear lbl_foci_resize
     
     

     tic
          
     N=size(stats_shape,1);
     
     
     stats_values=array2table(zeros(N,0));
     
     
     stats_tmp = regionprops3(lbl_foci,a,'MaxIntensity','MeanIntensity');
     
     stats_tmp.Properties.VariableNames={'MeanIntensitya','MaxIntensitya'};
     
     
     stats_values=[stats_values,stats_tmp];
     

     stats_values = addvars(stats_values,get_centroid_value(lbl_foci,a),'NewVariableNames','CentroidValuea');
   
     
     stats_tmp = regionprops3(lbl_foci,b,'MaxIntensity','MeanIntensity');
     
     stats_tmp.Properties.VariableNames={'MeanIntensityb','MaxIntensityb'};
     
     
     stats_values=[stats_values,stats_tmp];
     
     
     stats_values = addvars(stats_values,get_centroid_value(lbl_foci,b),'NewVariableNames','CentroidValueb');
     
     
     
     stats_tmp = regionprops3(lbl_foci,ab,'MaxIntensity','MeanIntensity');
     
     stats_tmp.Properties.VariableNames={'MeanIntensityab','MaxIntensityab'};
     
     
     stats_values=[stats_values,stats_tmp];
     
     stats_values = addvars(stats_values,get_centroid_value(lbl_foci,ab),'NewVariableNames','CentroidValueab');
    
     
     toc
     tic

     if gpu
        a_gpu=gpuArray(a);
     else
        a_gpu=a;
     end  
     p=99;    
     mediana=repmat(gather(median(a_gpu(:))),[N,1]);    
     meana=repmat(gather(mean(a_gpu(:))),[N,1]);  
     percentile99a=repmat(gather(prctile(a_gpu(:),p)),[N,1]);
     clear a_gpu
         
     
     if gpu
        b_gpu=gpuArray(b);
     else
        b_gpu=b;
     end  
     p=99; 
     medianb=repmat(gather(median(b_gpu(:))),[N,1]);
     meanb=repmat(gather(mean(b_gpu(:))),[N,1]);
     percentile99b=repmat(gather(prctile(b_gpu(:),p)),[N,1]);
     clear b_gpu
     
     
     if gpu
        ab_gpu=gpuArray(ab);
     else
        ab_gpu=ab;
     end  
     p=99; 
     medianab=repmat(gather(median(ab_gpu(:))),[N,1]);
     meanab=repmat(gather(mean(ab_gpu(:))),[N,1]);
     percentile99ab=repmat(gather(prctile(ab_gpu(:),p)),[N,1]);
     clear ab_gpu

     
     stats_values = addvars(stats_values,mediana,medianb,medianab,meana,meanb,meanab,percentile99a,percentile99b,percentile99ab);
     
     toc
     
     tic
     
     stats_filters=array2table(zeros(N,0));
     
     
     sigmas=[6,12,20,40];
     
     
     if gpu
        a_gpu=gpuArray(a);
     else
        a_gpu=a;
     end  

     for sigma = sigmas
     
         tmp = gather(imgaussfilt3(a_gpu,[sigma,sigma,sigma/3],'FilterDomain','spatial'));

         stats_tmp = regionprops3(lbl_foci,gather(tmp),'MaxIntensity','MeanIntensity');
     
         stats_tmp.Properties.VariableNames={['meanIntensityaG' num2str(sigma)],['MaxIntensityaG' num2str(sigma)]};

         stats_filters=[stats_filters,stats_tmp];
         
         stats_filters = addvars(stats_filters,get_centroid_value(lbl_foci,gather(tmp)),'NewVariableNames',['CentroidValueaG' num2str(sigma)]);
         
     end
     clear a_gpu
     
     
     
     if gpu
        b_gpu=gpuArray(b);
     else
        b_gpu=b;
     end  
     
     for sigma = sigmas    
         
         tmp = gather(imgaussfilt3(b_gpu,[sigma,sigma,sigma/3],'FilterDomain','spatial'));

         stats_tmp = regionprops3(lbl_foci,gather(tmp),'MaxIntensity','MeanIntensity');
     
         stats_tmp.Properties.VariableNames={['meanIntensitybG' num2str(sigma)],['MaxIntensitybG' num2str(sigma)]};

         stats_filters=[stats_filters,stats_tmp];
         
         stats_filters = addvars(stats_filters,get_centroid_value(lbl_foci,gather(tmp)),'NewVariableNames',['CentroidValuebG' num2str(sigma)]);
        
         
     end 
     clear b_gpu
     
     
     
      if gpu
        ab_gpu=gpuArray(ab);
     else
        ab_gpu=ab;
     end  
     
     for sigma = sigmas
         
         tmp = gather(imgaussfilt3(ab_gpu,[sigma,sigma,sigma/3],'FilterDomain','spatial'));

         stats_tmp = regionprops3(lbl_foci,gather(tmp),'MaxIntensity','MeanIntensity');
     
         stats_tmp.Properties.VariableNames={['meanIntensityabG' num2str(sigma)],['MaxIntensityabG' num2str(sigma)]};

         stats_filters=[stats_filters,stats_tmp];
         
         stats_filters = addvars(stats_filters,get_centroid_value(lbl_foci,gather(tmp)),'NewVariableNames',['CentroidValueabG' num2str(sigma)]);
 
     end
     clear ab_gpu
     
     
     

     
     
     
     
     
     
     
     
     

end
    
    
    
