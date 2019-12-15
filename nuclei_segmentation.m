clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


path='D:\tmp\test';



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


    for img_num=1:length(names)
       img_num

       name=names{img_num};


       [a,b,c]=read_3d_rgb_tif(name);


       [af,bf,cf]=preprocess_filters(a,b,c);

       [a,b,c]=preprocess_norm_resize(af,bf,cf);

       mask=predict_by_parts(a,b,c,net);


       save_name=strrep(name,'3D_','mask_');
       save_name_split=strrep(name,'3D_','mask_split');
       
       save_control_seg=strrep(name,'3D_','control_seg_');
       save_control_seg=strrep(save_control_seg,'.tif','');


       imwrite_uint16_3D(save_name,mask)




       mask=split_nuclei(mask);
       mask=balloon(mask,[20 20 8]);
       shape=[5,5,2];
       [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
       sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
       mask_conected=imerode(mask,sphere);
       mask=imresize3(uint8(mask),size(af),'nearest')>0;
       
       
       
       imwrite_uint16_3D(save_name_split,mask)


       s = regionprops3(mask,"Centroid");
       centers = s.Centroid;


       mask2d=mask_2d_split(mask,3);
       rgb2d=cat(3,norm_percentile(mean(af,3),0.001),norm_percentile(mean(bf,3),0.001),norm_percentile(mean(cf,3),0.001));
    
       
       mask2d2=mask_2d_split(mask,2);
       rgb2d2=cat(3,norm_percentile(squeeze(mean(af,2)),0.001),norm_percentile(squeeze(mean(bf,2)),0.001),norm_percentile(squeeze(mean(cf,2)),0.001));
       
       
       mask2d1=mask_2d_split(mask,1);
       rgb2d1=cat(3,norm_percentile(squeeze(mean(af,1)),0.001),norm_percentile(squeeze(mean(bf,1)),0.001),norm_percentile(squeeze(mean(cf,1)),0.001));

       n=size(a,3);
       mask_corner=zeros([n,n]);
       rgb2d_corner=zeros([n,n,3]);
       
       tmp=cat(2,mask2d,mask2d2 );
       tmp2=cat(2,mask2d1',mask_corner);
       mask2d=cat(1,tmp,tmp2);
       
       
       tmp=cat(2,rgb2d,rgb2d2 );
       tmp2=cat(2,permute(rgb2d1,[2 1 3]),rgb2d_corner);
       rgb2d=cat(1,tmp,tmp2);
       
       close all;
       imshow(rgb2d)
       hold on
       visboundaries(mask2d,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
       drawnow()
       print(save_control_seg,'-dpng')


    end
    
end





function [a,b,c]=preprocess_norm_resize(a,b,c)



    a=norm_percentile(a,0.0001)-0.5;
    b=norm_percentile(b,0.0001)-0.5;
    c=norm_percentile(c,0.0001)-0.5;
    
    
    a=imresize3(a,[337  454   48]);
    b=imresize3(b,[337  454   48]);
    c=imresize3(c,[337  454   48]);

end



function mask=predict_by_parts(a,b,c,net)

%     patchSize=[96 96];
    patchSize=[128 128];
    
    border=24;


    img_size=size(a);
    
%     data=c;
    data=cat(4,a,b,c);
    
    
    poskladany=zeros(img_size);
    podelit=zeros(img_size);


    vahokno=2*ones(patchSize);
    vahokno=conv2(vahokno,ones(2*border+1)/sum(sum(ones(2*border+1))),'same');
    vahokno=vahokno-1;
    vahokno(vahokno<0.01)=0.01;
    
    vahokno=repmat(vahokno,[1 1 48]);
    
    
    
    posx_start=1:patchSize(1)-border-2:img_size(1);
    posx_start=posx_start(1:end-1);
    posx_end=posx_start+patchSize(1)-1;
    posx_end= [posx_end img_size(1)];
    posx_start=[posx_start posx_end(end)-patchSize(1)+1];


    posy_start=1:patchSize(2)-border-2:img_size(2);
    posy_start=posy_start(1:end-1);
    posy_end=posy_start+patchSize(2)-1;
    posy_end= [posy_end img_size(2)];
    posy_start=[posy_start posy_end(end)-patchSize(2)+1];

    k=0;
    for x=posx_start
        k=k+1;
        xx=posx_end(k);
        kk=0;
         for y=posy_start
            kk=kk+1;
            yy=posy_end(kk);


            imgg = data(x:xx,y:yy,:,:);


            img_out=predict(net,imgg);

            img_out=img_out(:,:,:,2);
            


            poskladany(x:xx,y:yy,:)=poskladany(x:xx,y:yy,:)+img_out.*vahokno;
            podelit(x:xx,y:yy,:)=podelit(x:xx,y:yy,:)+vahokno;


         end
    end
    
    
    cely=poskladany./podelit;

    mask=cely>0.5;
    
    
    
    

end



