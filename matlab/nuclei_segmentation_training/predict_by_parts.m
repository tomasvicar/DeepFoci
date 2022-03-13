function cely = predict_by_parts(data,out_layers,net,patchSize)

    
    border=16;


    img_size=size(data);
    
%     data=c;

    poskladany = zeros([img_size(1:3) out_layers]);
    podelit = zeros([img_size(1:3) out_layers]);


    vahokno=2*ones(patchSize(1:2));
    vahokno=conv2(vahokno,ones(2*border+1)/sum(sum(ones(2*border+1))),'same');
    vahokno=vahokno-1;
    vahokno(vahokno<0.01)=0.01;
    
    vahokno=repmat(vahokno,[1 1 img_size(3), out_layers]);
    
    
    
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

            imgg_dl = dlarray(imgg,"SSSCB");
            
            img_out=predict(net,imgg_dl);

            img_out = gather(img_out(:,:,:,:,1));


            poskladany(x:xx,y:yy,:,:)=poskladany(x:xx,y:yy,:,:)+img_out.*vahokno;
            podelit(x:xx,y:yy,:,:)=podelit(x:xx,y:yy,:,:)+vahokno;


         end
    end
    
    
    cely=poskladany./podelit;

    
    
    
    

end