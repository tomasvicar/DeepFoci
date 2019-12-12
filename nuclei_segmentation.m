clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif';
folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;


for folder_num=11:length(folders)

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
       
       save_control_seg=strrep(name,'3D_','control_seg_');
       save_control_seg=strrep(save_control_seg,'.tif','');


       imwrite_binary_3D(save_name,mask)




       mask=split_nuclei(mask);
       tic
       mask=balloon(mask,[26 26 10]);
       toc

       s = regionprops3(mask,"Centroid");
       centers = s.Centroid;


       mask2d=squeeze(sum(mask,3))>0;
       rgb2d=cat(3,norm_percentile(mean(a,3),0.005),norm_percentile(mean(b,3),0.005),norm_percentile(mean(c,3),0.005));
       
       mask2d2=squeeze(sum(mask,2))>0;
       rgb2d2=cat(3,norm_percentile(squeeze(mean(a,2)),0.005),norm_percentile(squeeze(mean(b,2)),0.005),norm_percentile(squeeze(mean(c,2)),0.005));
       
       
       mask2d1=squeeze(sum(mask,1))>0;
       rgb2d1=cat(3,norm_percentile(squeeze(mean(a,1)),0.005),norm_percentile(squeeze(mean(b,1)),0.005),norm_percentile(squeeze(mean(c,1)),0.005));

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
       visboundaries(mask2d)
       if ~isempty(centers)
           plot(centers(:,1),centers(:,2),'y*');
           plot(centers(:,1),centers(:,2),'kx');
       end
       drawnow()
       print(save_control_seg,'-dpng')


    end
    
end




function [a,b,c]=read_3d_rgb_tif(name)

    info=imfinfo(name);
    a=zeros(info(1).Height,info(1).Width,length(info));
    b=zeros(info(1).Height,info(1).Width,length(info));
    c=zeros(info(1).Height,info(1).Width,length(info));
    for k=1:length(info)
        rgb=imread(name,k);
        a(:,:,k)=rgb(:,:,1);
        b(:,:,k)=rgb(:,:,2);
        c(:,:,k)=rgb(:,:,3);
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


function [a,b,c]=preprocess_filters(a,b,c)
    a=medfilt3(double(a),[5 5 1]);
    b=medfilt3(double(b),[5 5 1]);
    c=medfilt3(double(c),[5 5 1]);
    
    a=imgaussfilt3(double(a),[2 2 1]);
    b=imgaussfilt3(double(b),[2 2 1]);
    c=imgaussfilt3(double(c),[2 2 1]);
    
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


function mask=split_nuclei(mask)

    vys=mask>0.5;
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    D = -bwdist(vys==0);
    D = imhmin(D,5);
    D=watershed(D)>0;
    vys=(vys.*D)>0;
    vys=imclose(vys,sphere);
    vys = bwareaopen(vys,6000);
    mask=imfill(vys,'holes');
    
    
end



function mask=balloon(mask,shape)

    [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    mask_conected=imdilate(mask,sphere);
    
    D = bwdistgeodesic(mask_conected,mask,'quasi-euclidean');
    
    D(isnan(D))=-5;
    
    D=-D;
    
    D = imimposemin(D,mask);
    
    
    mask=(watershed(D)>0)&mask_conected;
    
    
    


end