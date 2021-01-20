function seg=seg_3d(data,gt)
        
    data=data>0;
    gt=gt>0;

    counter=0;

    ll=bwlabeln(data);
    l=bwlabeln(gt);
    seg_all=zeros(1,max(l(:)));
    for k=1:max(l(:))
        counter=counter+1;
        b=k==l;
        bb=ll(b);
        qq=unique(bb(find(bb)));
        seg_all(counter)=0;

        for q=qq'
            cell=(ll==q);
            if (sum(b(:))*0.5)<sum(sum(sum((b&cell))))
                ll(cell)=0;
                seg_all(counter)=sum(sum(sum((b&cell))))/sum(sum(sum((b|cell))));
            end

        end
    end


    seg=mean(seg_all);
    
    
    
    
   
    
    

end