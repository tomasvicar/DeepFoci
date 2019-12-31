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


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');


        [a,b,c]=read_3d_rgb_tif(name);


        mask=imread(mask_name_split);

        [a,b,c]=preprocess_filters(a,b,c,gpu);

        rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));



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

            tic
            %    try
            r=vl_mser(ab_uint,'MinDiversity',0.1,...
                'MaxVariation',0.8,...
                'Delta',1,...
                'MinArea', 50/ numel(ab_uint),...
                'MaxArea',2400/ numel(ab_uint));
            %     catch
            %         r=[] ;
            %     end

            M = zeros(size(ab_uint),'uint16') ;
            for x=1:length(r)
                s = vl_erfill(ab_uint,r(x)) ;
                M(s) = M(s) + 1;
            end

            shape=[9,9,3];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

            dilated=imdilate(ab_uint,sphere);
            ab_maxima=imregionalmax(dilated);

            s = regionprops(ab_maxima>0,'Centroid');
            maxima = round(cat(1, s.Centroid));
            ab_maxima=false(size(ab_maxima)) ;
            for k=1:size(maxima,1)
                ab_maxima(maxima(k,2),maxima(k,1),maxima(k,3)) =1;
            end

            pom=-double(ab_uint);
            pom=imimposemin(pom,ab_maxima);
            wab_krajeny=watershed(pom)>0;
            wab_krajeny(M==0)=0;
            wab_krajeny=imfill(wab_krajeny,'holes');

            toc

            result(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1)=wab_krajeny;


        end

        wab_krajeny=result;

        mask_2d_split1=mask_2d_split(mask,3);



        close all
        imshow(rgb_2d)
        hold on
        visboundaries(sum(wab_krajeny,3)>0,'LineWidth',0.5,'Color','r','EnhanceVisibility',0)
        visboundaries(mask_2d_split1,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
        s = regionprops(wab_krajeny>0,'Centroid');
        maxima = round(cat(1, s.Centroid));
        if ~isempty(maxima)
            plot(maxima(:,1), maxima(:,2), 'k+')
            plot(maxima(:,1), maxima(:,2), 'yx')
        end
        name_orig_tmp=split(name,'\');
        name_orig_tmp=join(name_orig_tmp(end-3:end),'\');
        title(name_orig_tmp)
        drawnow;



        print(save_control_seg,'-dpng')

        imwrite_uint16_3D(name_mask_foci,wab_krajeny)
        
        
    end


end






