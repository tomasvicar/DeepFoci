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


test_id=1:20;
valid_id=21:30;
train_id=41:1000;





% load('net_dice.mat')
% load('net_ce_rot.mat')

% load('ce_rot_fast.mat')

% load('dice_rot_fast.mat')

load('dice_rot_new.mat')




dices0=[];

segs0=[];


dices1=[];

segs1=[];


dices2=[];

segs2=[];


dices3=[];

segs3=[];

dices4=[];

segs4=[];


dices5=[];

segs5=[];

dices6=[];

segs6=[];

for kkk=test_id
    kkk
    
    name_mask=names{kkk};
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
    
    a=medfilt3(double(a),[5 5 1]);
    b=medfilt3(double(b),[5 5 1]);
    c=medfilt3(double(c),[5 5 1]);
    
    a=imgaussfilt3(double(a),[2 2 1]);
    b=imgaussfilt3(double(b),[2 2 1]);
    c=imgaussfilt3(double(c),[2 2 1]);

    a=norm_percentile(a,0.0001)-0.5;
    b=norm_percentile(b,0.0001)-0.5;
    c=norm_percentile(c,0.0001)-0.5;
    
    
    a=imresize3(a,[337  454   48]);
    b=imresize3(b,[337  454   48]);
    c=imresize3(c,[337  454   48]);
    
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
    
    data=cat(4,a,b,c);
    clear a b c


    patchSize=[128 128];
    
    border=24;
    
    img_size=size(mask);
    
    
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


%             [img_out_tmp,~,scores] = semanticseg(imgg,net);
%             img_out=zeros(size(img_out_tmp,1),size(img_out_tmp,2),'single');
%             for kq=1:length(classNames)               
%                 img_out(img_out_tmp==classNames(kq))=pixelLabelIDs(kq);
%             end

            img_out=predict(net,imgg);

%             img_out=permute(img_out(:,:,:,2),[2,1,3]);
            img_out=img_out(:,:,:,2);
            
%             imshow4(cat(2,img_out,imgg+0.5))


            poskladany(x:xx,y:yy,:)=poskladany(x:xx,y:yy,:)+img_out.*vahokno;
            podelit(x:xx,y:yy,:)=podelit(x:xx,y:yy,:)+vahokno;


         end
    end
    
    
    cely=poskladany./podelit;
    
    mask(mask==2)=0;
    
%     imshow5(cat(2,cely,double(mask),data+0.5))
    vys=cely>0.5;
    
    
    dices0=[dices0 dice(mask==1,vys)]

    segs0=[segs0 seg_3d(vys,mask==1)]
    
    
    vys=cely>0.5;
    D = -bwdist(vys==0);
    D = imhmin(D,5);
    D=watershed(D)>0;
    vys=(vys.*D)>0;

   
    dices1=[dices1 dice(mask==1,vys)]

    segs1=[segs1 seg_3d(vys,mask==1)]
    
    
    vys=cely>0.5;
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    D = -bwdist(vys==0);
    D = imhmin(D,5);
    D=watershed(D)>0;
    vys=(vys.*D)>0;
    vys=imclose(vys,sphere);
    vys = bwareaopen(vys,6000);
    vys=imfill(vys,'holes');
   
    dices2=[dices2 dice(mask==1,vys)]

    segs2=[segs2 seg_3d(vys,mask==1)]
    
    
    
    
    vys=cely>0.5;
    D = -bwdist(vys==0);
    D = imhmin(D,8);
    D=watershed(D)>0;
    vys=(vys.*D)>0;

   
    dices3=[dices3 dice(mask==1,vys)]

    segs3=[segs3 seg_3d(vys,mask==1)]
    
    
    vys=cely>0.5;
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    D = -bwdist(vys==0);
    D = imhmin(D,8);
    D=watershed(D)>0;
    vys=(vys.*D)>0;
    vys=imclose(vys,sphere);
    vys = bwareaopen(vys,6000);
    vys=imfill(vys,'holes');
   
    dices4=[dices4 dice(mask==1,vys)]

    segs4=[segs4 seg_3d(vys,mask==1)]
    
    
    
    
    
    
    vys=cely>0.5;
    D = -bwdist(vys==0);
    D = imhmin(D,3);
    D=watershed(D)>0;
    vys=(vys.*D)>0;

   
    dices5=[dices5 dice(mask==1,vys)]

    segs5=[segs5 seg_3d(vys,mask==1)]
    
    
    vys=cely>0.5;
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    D = -bwdist(vys==0);
    D = imhmin(D,3);
    D=watershed(D)>0;
    vys=(vys.*D)>0;
    vys=imclose(vys,sphere);
    vys = bwareaopen(vys,6000);
    vys=imfill(vys,'holes');
   
    dices6=[dices6 dice(mask==1,vys)]

    segs6=[segs6 seg_3d(vys,mask==1)]
    
    
    

end

diceeee0=mean(dices0)

segsssss0=mean(segs0)


diceee1=mean(dices1)

segsssss1=mean(segs1)


diceeee2=mean(dices2)

segsssss2=mean(segs2)

diceeee3=mean(dices3)

segsssss3=mean(segs3)

diceeee4=mean(dices4)

segsssss4=mean(segs4)

diceeee5=mean(dices5)

segsssss5=mean(segs5)

diceeee6=mean(dices6)

segsssss6=mean(segs6)

% net_ce_rot 0.6925*


% ce_rot_fast 0.6602 0.4458

% dice_rot_fast 0.8509 0.6792   - to pouzij vole ;)


% dice_rot_new 0.8510 0.7002   - to pouzij vole ;)





% 
% 
% 
% dices1 =
% 
%   Columns 1 through 13
% 
%     0.9348    0.8883    0.8919    0.5974    0.8003    0.8946    0.7897    0.8918    0.8628    0.8730    0.8628    0.8293    0.7699
% 
%   Columns 14 through 20
% 
%     0.8655    0.8117    0.9241    0.8615    0.9167    0.8854    0.8673
% 
% 
% segs1 =
% 
%   Columns 1 through 13
% 
%     0.8782    0.7981    0.7889    0.2386    0.0578    0.8436    0.6540    0.7933    0.7636    0.7560    0.7636    0.3161    0.5005
% 
%   Columns 14 through 20
% 
%     0.7896    0.6614    0.8542    0.7122    0.8464    0.7912    0.7719
% 
% 
% dices2 =
% 
%   Columns 1 through 13
% 
%     0.9351    0.8878    0.8918    0.5908    0.7990    0.9196    0.7897    0.8963    0.8628    0.8728    0.8635    0.8280    0.7704
% 
%   Columns 14 through 20
% 
%     0.8815    0.8115    0.9241    0.8465    0.9176    0.8840    0.8666
% 
% 
% segs2 =
% 
%   Columns 1 through 13
% 
%     0.8787    0.7974    0.7884    0.2100    0.0578    0.8437    0.6524    0.7926    0.7613    0.7557    0.7644    0.3153    0.4989
% 
%   Columns 14 through 20
% 
%     0.7871    0.6608    0.8541    0.6189    0.8475    0.7892    0.7713
% 
% 
% dices3 =
% 
%   Columns 1 through 13
% 
%     0.9348    0.8841    0.8919    0.5974    0.8003    0.8946    0.7897    0.8917    0.8628    0.8730    0.8628    0.8293    0.7699
% 
%   Columns 14 through 20
% 
%     0.8647    0.8117    0.9241    0.8627    0.9167    0.8854    0.8673
% 
% 
% segs3 =
% 
%   Columns 1 through 13
% 
%     0.8782    0.7300    0.7889    0.2386    0.0578    0.8436    0.6540    0.7933    0.7636    0.7560    0.7636    0.3161    0.5005
% 
%   Columns 14 through 20
% 
%     0.7896    0.6614    0.8542    0.7171    0.8464    0.7912    0.7719
% 
% 
% dices4 =
% 
%   Columns 1 through 13
% 
%     0.9351    0.8878    0.8918    0.5908    0.7990    0.9196    0.7897    0.8963    0.8628    0.8728    0.8635    0.8280    0.7704
% 
%   Columns 14 through 20
% 
%     0.8815    0.8115    0.9241    0.8464    0.9176    0.8840    0.8666
% 
% 
% segs4 =
% 
%   Columns 1 through 13
% 
%     0.8787    0.7973    0.7884    0.2100    0.0578    0.8437    0.6524    0.7926    0.7613    0.7557    0.7644    0.3153    0.4989
% 
%   Columns 14 through 20
% 
%     0.7871    0.6608    0.8541    0.6188    0.8475    0.7892    0.7713
% 
% 
% dices5 =
% 
%   Columns 1 through 13
% 
%     0.9348    0.8883    0.8919    0.5974    0.8014    0.8946    0.7897    0.8917    0.8628    0.8730    0.8628    0.8293    0.7696
% 
%   Columns 14 through 20
% 
%     0.8647    0.8117    0.9241    0.8627    0.9167    0.8854    0.8673
% 
% 
% segs5 =
% 
%   Columns 1 through 13
% 
%     0.8782    0.7981    0.7889    0.2386    0.2338    0.8436    0.6540    0.7933    0.7636    0.7560    0.7636    0.3161    0.5005
% 
%   Columns 14 through 20
% 
%     0.7896    0.6614    0.8542    0.7171    0.8464    0.7912    0.7719
% 
% 
% dices6 =
% 
%   Columns 1 through 13
% 
%     0.9351    0.8878    0.8918    0.5908    0.7991    0.9196    0.7897    0.8963    0.8628    0.8728    0.8635    0.8280    0.7704
% 
%   Columns 14 through 20
% 
%     0.8815    0.8115    0.9241    0.8464    0.9176    0.8840    0.8666
% 
% 
% segs6 =
% 
%   Columns 1 through 13
% 
%     0.8787    0.7974    0.7884    0.2100    0.0578    0.8437    0.6524    0.7926    0.7613    0.7557    0.7644    0.3153    0.4989
% 
%   Columns 14 through 20
% 
%     0.7871    0.6608    0.8541    0.6188    0.8475    0.7892    0.7713
% 
% 
% diceeee0 =
% 
%     0.8509
% 
% 
% segsssss0 =
% 
%     0.6792
% 
% 
% diceee1 =
% 
%     0.8509
% 
% 
% segsssss1 =
% 
%     0.6790
% 
% 
% diceeee2 =
% 
%     0.8520
% 
% 
% segsssss2 =
% 
%     0.6723
% 
% 
% diceeee3 =
% 
%     0.8507
% 
% 
% segsssss3 =
% 
%     0.6758
% 
% 
% diceeee4 =
% 
%     0.8520
% 
% 
% segsssss4 =
% 
%     0.6723
% 
% 
% diceeee5 =
% 
%     0.8510
% 
% 
% segsssss5 =
% 
%     0.6880
% 
% 
% diceeee6 =
% 
%     0.8520
% 
% 
% segsssss6 =
% 
%     0.6723





