clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')


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


    load('test3_value_aug_mult.mat')

    for img_num=1:length(names)
       img_num

       name=names{img_num};


       name_mask=strrep(name,'3D_','mask_');
       
       save_name_split=strrep(name,'3D_','mask_split_fix');
       
       save_unet_foci_segmentation_res=strrep(name,'3D_','unet_foci_segmentation_res');
       
       save_final_results_unet_control=strrep(name,'3D_','final_results_unet_control');
       save_final_results_unet_control=strrep(save_final_results_unet_control,'.tif','');
       
       if isfile(save_unet_foci_segmentation_res)
            continue
       end  
         
       
       [a,b,c]=read_3d_rgb_tif(name);
       shape_old=size(a);
       
       mask=imread(name_mask);
       mask=split_nuclei_hard(mask);

       mask=balloon(mask,[20 20 8]);
       shape=[5,5,2];
       [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
       sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
       mask_conected=imerode(mask,sphere);
       mask=imresize3(uint8(mask),shape_old,'nearest')>0;
       
       
       imwrite_uint16_3D(save_name_split,mask)

       
       
       [a,b,c]=preprocess_filters(a,b,c,gpu);
       rgb_2d=cat(3,norm_percentile(max(a,[],3),0.001),norm_percentile(max(b,[],3),0.001),norm_percentile(max(c,[],3),0.001));
        
       
       [as,bs,cs]=preprocess_norm_resize_foci(a,b,c);

       
       vys=predict_by_parts_detection(as,bs,cs,net);
       
       h=0.3;
       d=12;
       t=2.9;
       
        [X,Y,Z] = meshgrid(linspace(-1,1,d),linspace(-1,1,d),linspace(-1,1,int16(d/3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
        
        tmp=imdilate(vys,sphere);
        tmp = imhmax(tmp,h);
        tmp = imregionalmax(tmp).*(vys>t);

        detection_results=false(size(a));
        s = regionprops(tmp>0,'centroid');
        centroids = round(cat(1, s.Centroid));
        
        factor=size(a)./size(vys);
        if ~isempty(centroids)
            centroids(:,1)=round(centroids(:,1)*factor(1));
            centroids(:,2)=round(centroids(:,2)*factor(2));
            centroids(:,3)=round(centroids(:,3)*factor(3));

            for kp=1:size(centroids,1)
                detection_results(centroids(kp,2),centroids(kp,1),centroids(kp,3))=1;
            end
        end

        a=norm_percentile(a,0.00001);
        b=norm_percentile(b,0.00001);
        
        ab=a.*b;
        ab_uint_whole=uint8(mat2gray(ab)*255).*uint8(mask);
        clear a b ab c
       
        result=zeros(size(ab_uint_whole),'uint16');
        
        
        s = regionprops(mask>0,'BoundingBox');
        bbs = cat(1,s.BoundingBox);
        
        for cell_num =1:size(bbs,1)
            
            bb=round(bbs(cell_num,:));
            ab_uint = ab_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
            detection_results_crop=detection_results(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
            %             ab_uint=max(ab_uint,[],3);
            
            
            tic
            %    try
            
            min_area=50/ numel(ab_uint);
            min_area(min_area>1)=1;
            
            max_area=2400/ numel(ab_uint);
            max_area(max_area>1)=1;
            
            r=vl_mser(ab_uint,'MinDiversity',0.1,...
                'MaxVariation',0.8,...
                'Delta',1,...
                'MinArea', min_area,...
                'MaxArea',max_area);
            %     catch
            %         r=[] ;
            %     end
            
            M = zeros(size(ab_uint),'uint16') ;
            for x=1:length(r)
                s = vl_erfill(ab_uint,r(x)) ;
                M(s) = M(s) + 1;
            end
            
            
            
            M=M>0;
            
            %             shape=[5,5,3];
            %             [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            %             sphere=sqrt(X.^2+Y.^2+Z.^2)<=1;
            %             M=imerode(M,sphere);
            
            
            
            shape=[9,9,3];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
            
            
            
            
            pom=-double(ab_uint);
            pom=imimposemin(pom,detection_results_crop);
            wab_krajeny=watershed(pom)>0;
            wab_krajeny(M==0)=0;
            wab_krajeny=imfill(wab_krajeny,'holes');
            
            
            wab_krajeny_orez=wab_krajeny;
            tmp=~wab_krajeny_orez;
            %             shape0=size(tmp);
            %             tmp=imresize3(uint8(tmp),[shape0(1)*3,shape0(2)*3,shape0(3)],'nearest')>0;
            %             D = bwdist(tmp);
            D=bwdistsc(tmp,[1,1,3]);
            D=imhmax(D,1);
            %             D=imresize3(D,shape0,'linear');
            wab_krajeny_orez=(watershed(-D)>0) & wab_krajeny_orez;
            
            
            L=bwlabeln(wab_krajeny_orez);
            s=regionprops3(L,detection_results_crop,'MaxIntensity');
            s = s.MaxIntensity;
            for k=1:length(s)
                if s(k)==0
                    L(L==k)=0;
                end
            end
            wab_krajeny=L>0;
            
            toc
            
            result(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1)=wab_krajeny;
            
            
        end
        
        wab_krajeny=result;
        
        mask2d=mask_2d_split(mask,3);
        hold off
        imshow(rgb_2d)
        hold on
        visboundaries(max(wab_krajeny,[],3),'Color','r')
        visboundaries(mask2d,'Color','g')
        if ~isempty(centroids)
            plot(centroids(:,1), centroids(:,2), 'ro','MarkerSize',3)
            plot(centroids(:,1), centroids(:,2), 'g*','MarkerSize',3)
        end
        
        print(save_final_results_unet_control,'-dpng')
        
        imwrite_uint16_3D(save_unet_foci_segmentation_res,wab_krajeny)
        
        
        
       

    end
    
    
end




