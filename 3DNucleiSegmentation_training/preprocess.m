clc;clear all; close all force;
addpath('utils')
folder1='../../data_na_labely';
folder2='../../data_na_labely2';

names1=subdir([folder1 '/mask_norm_*']);
names1={names1.name};

names2=subdir([folder2 '/mask_norm_*']);
names2={names2.name};

names=[names1 names2];

rng(1)

p = randperm(length(names));

names=names(p);


folder_save='D:/vicar/foci_3d_seg/trenovaci_data_preprocess';
slozka=folder_save;


mkdir([folder_save '/train/img'])
mkdir([folder_save '/train/lbl'])
mkdir([folder_save '/test/img'])
mkdir([folder_save '/test/lbl'])


test_id=1:20;
valid_id=21:30;
train_id=41:1000;





for kk=1:length(names)

    kk
    name_mask=names{kk};
    name=strrep(name_mask,'\mask_norm_','\data_');
    
    
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
    
%     tic
    a=medfilt3(double(a),[5 5 1]);%old 5 5 3
    b=medfilt3(double(b),[5 5 1]);
    c=medfilt3(double(c),[5 5 1]);
%     toc
    
%     tic
    a=imgaussfilt3(double(a),[2 2 1]);
    b=imgaussfilt3(double(b),[2 2 1]);
    c=imgaussfilt3(double(c),[2 2 1]);
%     toc

    a=norm_percentile(a,0.0001)-0.5;
    b=norm_percentile(b,0.0001)-0.5;
    c=norm_percentile(c,0.0001)-0.5;
    
%     tic
    a=imresize3(a,[337  454   48]);
    b=imresize3(b,[337  454   48]);
    c=imresize3(c,[337  454   48]);
%     toc
    
    info=imfinfo(name_mask);
    mask=zeros(info(1).Height,info(1).Width,length(info));
    for k=1:length(info)
        rgb=imread(name_mask,k);
        mask(:,:,k)=rgb;
    end
    
    mask=imresize3(mask,[337  454   48],'nearest');
    
    
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    
    mask_tmp=zeros(size(mask))>0;
    mask_tmp2=uint8(zeros(size(mask)));
    for k=1:4
        cells0=mask==k;
        cells=imerode(imclose(cells0,sphere),sphere);
%         imshow4(cat(2,cells,cells0))

        cells = bwareaopen(cells,6000);

        mask_tmp(cells)=1;
        mask_tmp2(imdilate(cells,sphere))=2;
    end
    mask_tmp2(mask_tmp>0)=1;
    mask=mask_tmp2;
    
%     s = regionprops3(mask,'Volume');
%     V = s.Volume;



%         name_save=strrep(name,'trenovaci_data_1','trenovaci_data_preprocess_1/data');
%         name_onlyc=strrep(name,'trenovaci_data_1','trenovaci_data_preprocess_1/onlyc');
%         name_mask_save=strrep(name,'trenovaci_data_1','trenovaci_data_preprocess_1/mask');
% 
%         save(name_save,'a','b','c');
%         save(name_onlyc,'c');
%         save(name_mask_save,'mask');

    img_size=[128 128 48];
    data=cat(4,a,b,c);
    clear a b c

    if sum(kk==train_id)>0
        
        for kkk=1:50
            r=randi([1 4]);
                
            
            dataa=rot90(data,r);
            lbll=rot90(mask,r);





            f1=randi([0 1]);
            if f1
                dataa=fliplr(dataa);
                lbll=fliplr(lbll);
            end
            f2=randi([0 1]);
            if f2
                dataa=flipud(dataa);
                lbll=flipud(lbll);
            end

            img_size_tmp=img_size;


            posx=randi([1 size(dataa,1)-img_size_tmp(1)]);
            posy=randi([1 size(dataa,2)-img_size_tmp(2)]);




            dataa=dataa(posx:posx+img_size_tmp(1)-1,posy:posy+img_size_tmp(2)-1,:);
            lbll=lbll(posx:posx+img_size_tmp(1)-1,posy:posy+img_size_tmp(2)-1,:);

%             bile=bile+sum(lbll(:));
%             celkem=celkem+numel(lbll(:));

            disp(size(dataa));

            dataa=dataa*(0.8+0.4*rand());

%             imwrite_single(dataa,[slozka '/train/img/' num2str(cislo_snimku) '_' num2str(kk) '.tif'])
%             imwrite(uint8(lbll),[slozka '/train/lbl/' num2str(cislo_snimku) '_' num2str(kk) '.tif'])

            save([slozka '/train/img/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'dataa');
            save([slozka '/train/lbl/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'lbll');
            
        end


        
    else
        
        shape=size(data);
        patch_size=96;
        
        
        
        
        
        
        pos_startx=1:(patch_size):shape(1);
        pos_startx(2:end)=pos_startx(2:end)-16;
        pos_startx(end)=pos_startx(end)-((pos_startx(end)+patch_size)-shape(1)-1);
        
        pos_starty=1:(patch_size):shape(2);
        pos_starty(2:end)=pos_starty(2:end)-16;
        pos_starty(end)=pos_starty(end)-((pos_starty(end)+patch_size)-shape(2)-1);
        
        patch_num=0;
        for x=pos_startx
            xx=x+patch_size-1;
             for y=pos_starty
                yy=y+patch_size-1;
                patch_num=patch_num+1;
                kkk=patch_num;
                
                
                
                dataa=data(x:xx,y:yy,:);
                lbll=mask(x:xx,y:yy,:);
                
                
                if sum(kk==test_id)>0 
                    save([slozka '/test/img/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'dataa');
                    save([slozka '/test/lbl/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'lbll');
        
                elseif sum(kk==valid_id)>0  
                    save([slozka '/valid/img/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'dataa');
                    save([slozka '/valid/lbl/' num2str(kk,'%03.f') '_' num2str(kkk,'%03.f') '.mat'],'lbll');

                end
                
                
                

             end
        
        end
        

        
    end
        
    
end



