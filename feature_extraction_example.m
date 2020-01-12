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




for img_num=170:300
    
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
    
    
    save_features=strrep(name,'3D_','features_');
    save_features=strrep(save_features,'.tif','.mat');
    
    
    [a,b,~]=read_3d_rgb_tif(name);
    
    ab=a.*b;
    
     
     
     
     mask_foci=imread(name_mask_foci)>0;
     
     lbl_foci=bwlabeln(mask_foci);
     
     clear mask foci
     
     
     
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
     

     
     stats_filters=array2table(zeros(N,0));
     
     
     tic
     sigmas=[6,9,15,25];
     
     for sigma = sigmas
     
         sigma3=[sigma,sigma,round(sigma/3)];
         hsize=2*ceil(2*sigma3)+1;
         h = fspecial3('gaussian',hsize,sigma3);
         
         tmp=window_operator(a,lbl_foci,hsize,@(x) sum(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueaG' num2str(sigma)]);
         
         tmp=window_operator(b,lbl_foci,hsize,@(x) sum(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValuebG' num2str(sigma)]);
         
         tmp=window_operator(ab,lbl_foci,hsize,@(x) sum(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueabG' num2str(sigma)]);
        
     end
     

     toc
   
     
     

     tic
     sigmas=[6,9,15,25];
     
     for sigma = sigmas
     
         sigma3=[sigma,sigma,round(sigma/3)];
         hsize=2*ceil(2*sigma3)+1;
         h = fspecial3('gaussian',hsize,sigma3);
         
         tmp=window_operator(a,lbl_foci,hsize,@(x) corr(h(:),x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueaGcorr' num2str(sigma)]);
         
         tmp=window_operator(b,lbl_foci,hsize,@(x) corr(h(:),x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValuebGcorr' num2str(sigma)]);
         
         tmp=window_operator(ab,lbl_foci,hsize,@(x) corr(h(:),x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueabGcorr' num2str(sigma)]);
        
     end
     

     toc
     
     
     
     
     
     
     tic
     sigmas=[6,9,15,25];
     
     for sigma = sigmas
     
         sigma3=[sigma,sigma,round(sigma/3)];
         hsize=2*ceil(2*sigma3)+1;
         [X,Y,Z] = meshgrid(linspace(-1,1,hsize(1)),linspace(-1,1,hsize(2)),linspace(-1,1,hsize(3)));
         h=double(sqrt(X.^2+Y.^2+Z.^2)<1);
         h(h==0)=nan;
         
         tmp=window_operator(a,lbl_foci,hsize,@(x) nanmin(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueaMin' num2str(sigma)]);
         
         tmp=window_operator(b,lbl_foci,hsize,@(x) nanmin(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValuebMin' num2str(sigma)]);
         
         tmp=window_operator(ab,lbl_foci,hsize,@(x) nanmin(h(:).*x(:)));

         stats_filters = addvars(stats_filters,tmp,'NewVariableNames',['CentroidValueabMin' num2str(sigma)]);
        
     end
     

    toc
    
    features=[stats_shape,stats_values,stats_filters];
    
     
    save(save_features,'features')
     

end
    
    
    
