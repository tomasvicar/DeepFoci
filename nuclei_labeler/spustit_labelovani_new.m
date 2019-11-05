clc;clear all; close all force;
addpath('utils')
slozka='data_na_labely';


names=subdir([slozka '/data_norm_*']);
names={names.name};



for kk=171:length(names)
    
    name=names{kk};
    
    info=imfinfo(name);

    clear a b c
    
    
    img=zeros(info(1).Height,info(1).Width,3,length(info));
    for k=1:length(info)
        rgb=imread(name,k);
        a(:,:,k)=rgb(:,:,1);
        b(:,:,k)=rgb(:,:,2);
        c(:,:,k)=rgb(:,:,3);
    end
    
    
%     img_shape=size(a);
%     a=imresize3(a,[img_shape(1) img_shape(2) img_shape(3)*5],'linear');
%     img_shape=size(b);
%     b=imresize3(b,[img_shape(1) img_shape(2) img_shape(3)*5],'linear');
%     img_shape=size(c);
%     c=imresize3(c,[img_shape(1)/3 img_shape(2)/3 img_shape(3)],'linear');
    

    c=imresize3(c,[337  454   50]);
    

%     II=squeeze(img(:,:,3,:));
%     level = poisson_tresh(II(:));
%     maska=II>level;

    
    A=c;
    
    [L,N] = superpixels3(A,2500);
    imSize = size(A);
    
    se=zeros(3,3,3);
    se(2,2,:)=1;
    se(2,:,2)=1;
    se(:,2,2)=1;
    
    Boundaries=(L-imerode(L,se))>0;
    
%     Boundaries = zeros(imSize(1),imSize(2),imSize(3));
%     for plane = 1:imSize(3)
%         BW = boundarymask(L(:, :, plane));
% 
%         Boundaries(:, :, plane) = BW;
%     end
    
%     imshow4(imPlusBoundaries)
    mask=Boundaries;
    
        
        
%         [maska,reset]=malovatko_freehand(img,maska,num2str(citac));

    [mask,drop]=superpix_labeler(c,mask,num2str(kk));

    name_mask=name;
    name_mask=strrep(name_mask,'\data_','\mask_');
    
%     name_mask=strrep(name_mask,'.tif','.png');
%     imwrite(uint8((maska>0)*255),name_mask)
    close all force
    if drop==0
        for k=1:size(mask,3)

            tiff_stack_single(name_mask,single(mask(:,:,k)),k)

        end
    end
    
end

