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



for img_num=1:length(names)
    
    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};



    for img_num=1:length(names)
        img_num
    
        name=names{img_num};

        name_orig=names_orig{img_num};

        save_name=strrep(name,'3D_','mask_');
        save_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg');
        save_control_seg=strrep(save_control_seg,'.tif','');


        [a,b,c]=read_3d_rgb_tif(name);

        mask=imread(save_name_split);


        [a,b,c]=preprocess_filters(a,b,c,gpu);

        rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));



        a=norm_percentile(a,0.00001);
        b=norm_percentile(b,0.00001);

        %    a_percentile=prctile(a(:),0.95*100);
        %    b_percentile=prctile(b(:),0.95*100);

        %    a(a<a_percentile)=a_percentile;
        %    b(b<b_percentile)=b_percentile;

        ab=a.*b;


        ab_uint=uint8(mat2gray(ab)*255);
    %     ab_percentile=prctile(ab_uint(:),0.98*100);
    %     ab_uint(ab_uint<ab_percentile)=ab_percentile;
        ab_uint=ab_uint.*uint8(mask);


        tic
        %    try
        r=vl_mser(ab_uint,'MinDiversity',0.1,...
            'MaxVariation',0.8,...
            'Delta',1,...
            'MinArea', 50/ numel(ab),...
            'MaxArea',2400/ numel(ab));
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
        name_orig_tmp=split(name_orig,'\');
        name_orig_tmp=join(name_orig_tmp(end-3:end),'\');
        title(name_orig_tmp)
        drawnow;

        print(save_control_seg,'-dpng')


        imwrite_uint16_3D(name_mask_foci,wab_krajeny)
        
        
    end


end






