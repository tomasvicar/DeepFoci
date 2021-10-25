function [a,b,c]=preprocess_filtersxxx(a,b,c,gpu)

%     a=single(a);
%     b=single(b);
%     c=single(c);

    a=double(a);
    b=double(b);
    c=double(c);
    
    if gpu
        a=gpuArray(a);
        b=gpuArray(b);
        c=gpuArray(c);
    end 


%     a=medfilt3(a,[5 5 1],'symmetric');
%     b=medfilt3(b,[5 5 1],'symmetric');
%     c=medfilt3(c,[5 5 1],'symmetric');
    
    for k=1:size(a,3)
        a(:,:,k)=medfilt2(a(:,:,k),[3 3]);
        b(:,:,k)=medfilt2(b(:,:,k),[3 3]);
        c(:,:,k)=medfilt2(c(:,:,k),[3 3]);
    end
    
    
    a=imgaussfilt3(a,[0.5 0.5 0.2]);
    b=imgaussfilt3(b,[0.5 0.7 0.2]);
    c=imgaussfilt3(c,[0.5 0.7 0.2]);
    
    if gpu
        a=gather(a);
        b=gather(b);
        c=gather(c);
    end
    
    
end